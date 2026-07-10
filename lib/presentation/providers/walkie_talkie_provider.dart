import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/microphone_intent_guard.dart';
import '../../data/models/toy.dart';
import '../../data/services/api_service.dart';
import '../../data/services/livekit_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final _logger = Logger();
const _notProvided = Object();

enum WalkieTalkiePhase { idle, connecting, connected, error, disconnecting }

class WalkieTalkieState {
  const WalkieTalkieState({
    this.phase = WalkieTalkiePhase.idle,
    this.isTalking = false,
    this.isRemoteConnected = false,
    this.isRemoteMuted = false,
    this.remoteParticipantName,
    this.roomName,
    this.error,
  });

  final WalkieTalkiePhase phase;
  final bool isTalking;
  final bool isRemoteConnected;
  final bool isRemoteMuted;
  final String? remoteParticipantName;
  final String? roomName;
  final String? error;

  WalkieTalkieState copyWith({
    WalkieTalkiePhase? phase,
    bool? isTalking,
    bool? isRemoteConnected,
    bool? isRemoteMuted,
    Object? remoteParticipantName = _notProvided,
    String? roomName,
    String? error,
  }) => WalkieTalkieState(
    phase: phase ?? this.phase,
    isTalking: isTalking ?? this.isTalking,
    isRemoteConnected: isRemoteConnected ?? this.isRemoteConnected,
    isRemoteMuted: isRemoteMuted ?? this.isRemoteMuted,
    remoteParticipantName: identical(remoteParticipantName, _notProvided)
        ? this.remoteParticipantName
        : remoteParticipantName as String?,
    roomName: roomName ?? this.roomName,
    error: error,
  );
}

final walkieTalkieProvider =
    NotifierProvider<WalkieTalkieNotifier, WalkieTalkieState>(
      WalkieTalkieNotifier.new,
    );

class WalkieTalkieNotifier extends Notifier<WalkieTalkieState> {
  late LiveKitService _liveKitService;
  late ApiService _apiService;
  late MicrophoneIntentGuard _microphoneIntent;

  StreamSubscription<LiveKitConnectionStatus>? _statusSub;
  StreamSubscription<dynamic>? _participantsSub;

  @override
  WalkieTalkieState build() {
    _liveKitService = ref.read(liveKitServiceProvider);
    _apiService = ref.read(apiServiceProvider);
    _microphoneIntent = MicrophoneIntentGuard(
      ({required enabled}) =>
          _liveKitService.setMicrophoneEnabled(enabled: enabled),
    );

    ref.onDispose(() {
      _microphoneIntent.invalidate();
      unawaited(_shutdown());
    });

    return const WalkieTalkieState();
  }

  Future<void> startSession(Toy toy) async {
    if (toy.iotDeviceId == null) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'no_iot_device',
      );
      return;
    }

    state = state.copyWith(phase: WalkieTalkiePhase.connecting);

    try {
      // 1. Get parent token to join the toy's active LiveKit room.
      // The agent already has the toy's settings (childAge, interests,
      // voicePreference) from the room metadata set at device join time,
      // so we only need to send the toyId here.
      final tokenResponse = await _apiService.post<Map<String, dynamic>>(
        '/livekit/token/user',
        data: {'toyId': toy.id},
      );

      final token = tokenResponse['token'] as String?;
      final roomName = tokenResponse['roomName'] as String?;
      final serverUrl = tokenResponse['serverUrl'] as String?;
      if (token == null || roomName == null || serverUrl == null) {
        throw Exception('Missing token fields from server');
      }

      final user = ref.read(authProvider).value;
      // The IoT room session is created and ended by trusted LiveKit webhooks.
      // A parent joining walkie-talkie must not create or end a second session.
      _listenToRoomState();
      await _liveKitService.connect(
        LiveKitConfig(
          serverUrl: serverUrl,
          roomName: roomName,
          participantName: user?.firstName ?? user?.id ?? 'parent',
          token: token,
        ),
      );

      _updateParticipants(_liveKitService.participants);

      state = state.copyWith(
        phase: WalkieTalkiePhase.connected,
        roomName: roomName,
      );
    } on NotFoundException {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'no_iot_device',
      );
    } on ValidationException {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'toy_not_connected',
      );
    } on AppException catch (e) {
      _logger.e('Walkie-talkie session failed: $e');
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: e is NetworkException ? 'no_connection' : 'connection_failed',
      );
    } on Exception catch (e) {
      _logger.e('Walkie-talkie session failed: $e');
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'connection_failed',
      );
    } finally {
      if (state.phase == WalkieTalkiePhase.error) {
        _cleanupSubscriptions();
        await _liveKitService.disconnect();
      }
    }
  }

  void _listenToRoomState() {
    _cleanupSubscriptions();
    _statusSub = _liveKitService.statusStream.listen(_onStatusChanged);
    _participantsSub = _liveKitService.participantsStream.listen(
      _updateParticipants,
    );
  }

  void _updateParticipants(List<dynamic> participants) {
    state = state.copyWith(
      isRemoteConnected: participants.isNotEmpty,
      remoteParticipantName: participants.isNotEmpty
          ? participants.first.identity as String?
          : null,
    );
    if (participants.isEmpty && state.isTalking) {
      unawaited(suspendAudio());
    }
  }

  void _onStatusChanged(LiveKitConnectionStatus status) {
    if (status == LiveKitConnectionStatus.disconnected &&
        state.phase == WalkieTalkiePhase.connected) {
      unawaited(_disableMicrophoneAfterDisconnect());
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'connection_lost',
      );
    }
  }

  Future<void> startTalking() async {
    if (state.phase != WalkieTalkiePhase.connected ||
        !state.isRemoteConnected) {
      return;
    }
    try {
      final enabled = await _microphoneIntent.setEnabled(enabled: true);
      if (enabled &&
          state.phase == WalkieTalkiePhase.connected &&
          state.isRemoteConnected) {
        state = state.copyWith(isTalking: true);
      } else if (enabled) {
        await _microphoneIntent.forceDisable();
      }
    } on Exception catch (e) {
      _logger.e('Failed to enable microphone: $e');
      state = state.copyWith(isTalking: false);
    }
  }

  Future<void> stopTalking() async {
    state = state.copyWith(isTalking: false);
    try {
      await _microphoneIntent.setEnabled(enabled: false);
    } on Exception catch (e) {
      _logger.w('Failed to disable microphone: $e');
    }
  }

  Future<void> toggleRemoteMute() async {
    if (state.phase != WalkieTalkiePhase.connected ||
        state.roomName == null ||
        state.remoteParticipantName == null) {
      return;
    }

    final newMuted = !state.isRemoteMuted;
    try {
      await _liveKitService.muteParticipant(
        roomName: state.roomName!,
        identity: state.remoteParticipantName!,
        mute: newMuted,
      );
      state = state.copyWith(isRemoteMuted: newMuted);
    } on Exception catch (e) {
      _logger.e('Failed to toggle mute: $e');
    }
  }

  Future<void> endSession() async {
    state = state.copyWith(phase: WalkieTalkiePhase.disconnecting);

    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic during cleanup: $e');
    }

    try {
      await _liveKitService.disconnect();
    } on Exception catch (e) {
      _logger.w('Failed to disconnect LiveKit during cleanup: $e');
    }

    _cleanupSubscriptions();
    state = const WalkieTalkieState();
  }

  Future<void> suspendAudio() async {
    state = state.copyWith(isTalking: false);
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic while app is inactive: $e');
    }
  }

  Future<void> _disableMicrophoneAfterDisconnect() async {
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic after disconnect: $e');
    }
  }

  Future<void> _shutdown() async {
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic during provider disposal: $e');
    }
    await _liveKitService.disconnect();
    _cleanupSubscriptions();
  }

  void _cleanupSubscriptions() {
    _statusSub?.cancel();
    _participantsSub?.cancel();
    _statusSub = null;
    _participantsSub = null;
  }
}
