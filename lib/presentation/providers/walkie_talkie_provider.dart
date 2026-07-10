import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart' show RemoteParticipant;
import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/livekit_participant_selector.dart';
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
  StreamSubscription<List<RemoteParticipant>>? _participantsSub;
  int _sessionGeneration = 0;
  int _remoteParticipantGeneration = 0;
  String? _deviceIdentity;
  bool _isDisposed = false;

  @override
  WalkieTalkieState build() {
    _liveKitService = ref.read(liveKitServiceProvider);
    _apiService = ref.read(apiServiceProvider);
    _microphoneIntent = MicrophoneIntentGuard(
      ({required enabled}) =>
          _liveKitService.setMicrophoneEnabled(enabled: enabled),
    );

    ref.onDispose(() {
      _isDisposed = true;
      _sessionGeneration++;
      _microphoneIntent.invalidate();
      unawaited(_shutdown());
    });

    return const WalkieTalkieState();
  }

  Future<void> startSession(Toy toy) async {
    final generation = ++_sessionGeneration;
    _remoteParticipantGeneration++;
    _deviceIdentity = null;
    state = const WalkieTalkieState(phase: WalkieTalkiePhase.connecting);
    _cleanupSubscriptions();

    // Cancel any previous or in-flight connection before starting another
    // token request. LiveKitService detaches its current room synchronously.
    final disconnectFuture = _liveKitService.disconnect();
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic before connecting: $e');
    }
    await disconnectFuture;
    if (!_isCurrentSession(generation)) {
      return;
    }

    if (toy.iotDeviceId == null) {
      await _failStart(generation, 'no_iot_device');
      return;
    }

    try {
      // 1. Get parent token to join the toy's active LiveKit room.
      // The agent already has the toy's settings (childAge, interests,
      // voicePreference) from the room metadata set at device join time,
      // so we only need to send the toyId here.
      final tokenResponse = await _apiService.post<Map<String, dynamic>>(
        '/livekit/token/user',
        data: {'toyId': toy.id},
      );
      if (!_isCurrentSession(generation)) {
        return;
      }

      final token = tokenResponse['token'] as String?;
      final roomName = tokenResponse['roomName'] as String?;
      final serverUrl = tokenResponse['serverUrl'] as String?;
      if (token == null || roomName == null || serverUrl == null) {
        throw Exception('Missing token fields from server');
      }
      final rawDeviceIdentity = tokenResponse['deviceIdentity'];
      _deviceIdentity =
          rawDeviceIdentity is String && rawDeviceIdentity.trim().isNotEmpty
          ? rawDeviceIdentity.trim()
          : null;

      final user = ref.read(authProvider).value;
      // The IoT room session is created and ended by trusted LiveKit webhooks.
      // A parent joining walkie-talkie must not create or end a second session.
      _listenToRoomState(generation);
      final connected = await _liveKitService.connect(
        LiveKitConfig(
          serverUrl: serverUrl,
          roomName: roomName,
          participantName: user?.firstName ?? user?.id ?? 'parent',
          token: token,
        ),
      );
      if (!connected || !_isCurrentSession(generation)) {
        return;
      }

      _updateParticipants(_liveKitService.participants, generation);
      if (!_isCurrentSession(generation)) {
        return;
      }

      state = state.copyWith(
        phase: WalkieTalkiePhase.connected,
        roomName: roomName,
      );
    } on NotFoundException {
      await _failStart(generation, 'no_iot_device');
    } on ValidationException {
      await _failStart(generation, 'toy_not_connected');
    } on AppException catch (e) {
      _logger.e('Walkie-talkie session failed: $e');
      await _failStart(
        generation,
        e is NetworkException ? 'no_connection' : 'connection_failed',
      );
    } on Exception catch (e) {
      _logger.e('Walkie-talkie session failed: $e');
      await _failStart(generation, 'connection_failed');
    }
  }

  bool _isCurrentSession(int generation) =>
      !_isDisposed && generation == _sessionGeneration;

  Future<void> _failStart(int generation, String error) async {
    if (!_isCurrentSession(generation)) {
      return;
    }
    _deviceIdentity = null;
    state = WalkieTalkieState(phase: WalkieTalkiePhase.error, error: error);
    _cleanupSubscriptions();
    final disconnectFuture = _liveKitService.disconnect();
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic after connection failure: $e');
    }
    await disconnectFuture;
  }

  void _listenToRoomState(int generation) {
    _cleanupSubscriptions();
    _statusSub = _liveKitService.statusStream.listen(
      (status) => _onStatusChanged(status, generation),
    );
    _participantsSub = _liveKitService.participantsStream.listen(
      (participants) => _updateParticipants(participants, generation),
    );
  }

  void _updateParticipants(
    List<RemoteParticipant> participants,
    int generation,
  ) {
    if (!_isCurrentSession(generation) ||
        (state.phase != WalkieTalkiePhase.connecting &&
            state.phase != WalkieTalkiePhase.connected)) {
      return;
    }
    final selectedIdentity = selectLiveKitDeviceIdentity(
      participants.map((participant) => participant.identity),
      expectedIdentity: _deviceIdentity,
    );
    final wasTalking = state.isTalking;
    final participantChanged =
        selectedIdentity == null ||
        selectedIdentity != state.remoteParticipantName;
    if (participantChanged) {
      _remoteParticipantGeneration++;
    }
    state = state.copyWith(
      isRemoteConnected: selectedIdentity != null,
      isRemoteMuted: !participantChanged && state.isRemoteMuted,
      remoteParticipantName: selectedIdentity,
    );
    if (selectedIdentity == null && wasTalking) {
      unawaited(suspendAudio());
    }
  }

  void _onStatusChanged(LiveKitConnectionStatus status, int generation) {
    if (!_isCurrentSession(generation)) {
      return;
    }
    if (status == LiveKitConnectionStatus.disconnected &&
        state.phase == WalkieTalkiePhase.connected) {
      _remoteParticipantGeneration++;
      _deviceIdentity = null;
      _cleanupSubscriptions();
      unawaited(_disableMicrophoneAfterDisconnect());
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        isTalking: false,
        isRemoteConnected: false,
        isRemoteMuted: false,
        remoteParticipantName: null,
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
    final generation = _sessionGeneration;
    final participantGeneration = _remoteParticipantGeneration;
    final roomName = state.roomName!;
    final identity = state.remoteParticipantName!;
    try {
      await _liveKitService.muteParticipant(
        roomName: roomName,
        identity: identity,
        mute: newMuted,
      );
      if (_isCurrentSession(generation) &&
          participantGeneration == _remoteParticipantGeneration &&
          state.phase == WalkieTalkiePhase.connected &&
          state.roomName == roomName &&
          state.remoteParticipantName == identity) {
        state = state.copyWith(isRemoteMuted: newMuted);
      }
    } on Exception catch (e) {
      _logger.e('Failed to toggle mute: $e');
    }
  }

  Future<void> endSession() async {
    final generation = ++_sessionGeneration;
    _remoteParticipantGeneration++;
    _deviceIdentity = null;
    state = state.copyWith(phase: WalkieTalkiePhase.disconnecting);
    _cleanupSubscriptions();
    final disconnectFuture = _liveKitService.disconnect();

    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic during cleanup: $e');
    }

    await disconnectFuture;
    if (_isCurrentSession(generation)) {
      state = const WalkieTalkieState();
    }
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
    _deviceIdentity = null;
    _cleanupSubscriptions();
    final disconnectFuture = _liveKitService.disconnect();
    try {
      await _microphoneIntent.forceDisable();
    } on Exception catch (e) {
      _logger.w('Failed to disable mic during provider disposal: $e');
    }
    await disconnectFuture;
  }

  void _cleanupSubscriptions() {
    _statusSub?.cancel();
    _participantsSub?.cancel();
    _statusSub = null;
    _participantsSub = null;
  }
}
