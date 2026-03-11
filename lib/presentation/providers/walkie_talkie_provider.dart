import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/toy.dart';
import '../../data/services/api_service.dart';
import '../../data/services/livekit_service.dart';
import '../../data/services/voice_session_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final _logger = Logger();

enum WalkieTalkiePhase { idle, connecting, connected, error, disconnecting }

class WalkieTalkieState {
  const WalkieTalkieState({
    this.phase = WalkieTalkiePhase.idle,
    this.isTalking = false,
    this.isRemoteConnected = false,
    this.isRemoteMuted = false,
    this.remoteParticipantName,
    this.sessionId,
    this.roomName,
    this.error,
  });

  final WalkieTalkiePhase phase;
  final bool isTalking;
  final bool isRemoteConnected;
  final bool isRemoteMuted;
  final String? remoteParticipantName;
  final String? sessionId;
  final String? roomName;
  final String? error;

  WalkieTalkieState copyWith({
    WalkieTalkiePhase? phase,
    bool? isTalking,
    bool? isRemoteConnected,
    bool? isRemoteMuted,
    String? remoteParticipantName,
    String? sessionId,
    String? roomName,
    String? error,
  }) => WalkieTalkieState(
    phase: phase ?? this.phase,
    isTalking: isTalking ?? this.isTalking,
    isRemoteConnected: isRemoteConnected ?? this.isRemoteConnected,
    isRemoteMuted: isRemoteMuted ?? this.isRemoteMuted,
    remoteParticipantName: remoteParticipantName ?? this.remoteParticipantName,
    sessionId: sessionId ?? this.sessionId,
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
  late VoiceSessionService _voiceSessionService;

  StreamSubscription<LiveKitConnectionStatus>? _statusSub;
  StreamSubscription<dynamic>? _participantsSub;

  @override
  WalkieTalkieState build() {
    _liveKitService = ref.read(liveKitServiceProvider);
    _apiService = ref.read(apiServiceProvider);
    _voiceSessionService = ref.read(voiceSessionServiceProvider);

    ref.onDispose(_cleanup);

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
      // 1. Get parent token to join the toy's active LiveKit room
      final tokenResponse = await _apiService.post<Map<String, dynamic>>(
        '/livekit/token/user',
        data: {'toyId': toy.id},
      );

      final token = tokenResponse['token'] as String?;
      final roomName = tokenResponse['roomName'] as String?;
      final serverUrl = tokenResponse['serverUrl'] as String?;
      if (token == null || roomName == null || serverUrl == null) {
        throw Exception('walkie_talkie.missing_token_fields');
      }

      // 2. Create voice session on backend
      final user = ref.read(authProvider).value;
      final session = await _voiceSessionService.createSession(
        userId: user?.id ?? 'anonymous',
        sessionToken: token,
        roomName: roomName,
      );
      final sessionId = session.id;

      // 3. Connect to LiveKit room using server URL from backend
      await _liveKitService.connect(
        LiveKitConfig(
          serverUrl: serverUrl,
          roomName: roomName,
          participantName: user?.firstName ?? user?.id ?? 'parent',
          token: token,
        ),
      );

      // 4. Listen to status and participant changes
      _statusSub = _liveKitService.statusStream.listen(_onStatusChanged);
      _participantsSub = _liveKitService.participantsStream.listen((
        participants,
      ) {
        state = state.copyWith(
          isRemoteConnected: participants.isNotEmpty,
          remoteParticipantName: participants.isNotEmpty
              ? participants.first.identity
              : null,
        );
      });

      state = state.copyWith(
        phase: WalkieTalkiePhase.connected,
        sessionId: sessionId,
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
    } on Exception catch (e) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: e.toString(),
      );
    }
  }

  void _onStatusChanged(LiveKitConnectionStatus status) {
    if (status == LiveKitConnectionStatus.disconnected &&
        state.phase == WalkieTalkiePhase.connected) {
      state = state.copyWith(
        phase: WalkieTalkiePhase.error,
        error: 'connection_lost',
      );
    }
  }

  Future<void> startTalking() async {
    if (state.phase != WalkieTalkiePhase.connected) {
      return;
    }
    state = state.copyWith(isTalking: true);
    await _liveKitService.setMicrophoneEnabled(enabled: true);
  }

  Future<void> stopTalking() async {
    state = state.copyWith(isTalking: false);
    await _liveKitService.setMicrophoneEnabled(enabled: false);
  }

  Future<void> toggleRemoteMute() async {
    if (state.phase != WalkieTalkiePhase.connected ||
        state.roomName == null ||
        state.remoteParticipantName == null) {
      return;
    }

    final newMuted = !state.isRemoteMuted;
    final success = await _liveKitService.muteParticipant(
      roomName: state.roomName!,
      identity: state.remoteParticipantName!,
      mute: newMuted,
    );

    if (success) {
      state = state.copyWith(isRemoteMuted: newMuted);
    }
  }

  Future<void> endSession() async {
    state = state.copyWith(phase: WalkieTalkiePhase.disconnecting);

    try {
      await _liveKitService.setMicrophoneEnabled(enabled: false);
    } on Exception catch (e) {
      _logger.w('Failed to disable mic during cleanup: $e');
    }

    try {
      await _liveKitService.disconnect();
    } on Exception catch (e) {
      _logger.w('Failed to disconnect LiveKit during cleanup: $e');
    }

    if (state.sessionId != null) {
      try {
        await _voiceSessionService.endSession(state.sessionId!);
      } on Exception catch (e) {
        _logger.w('Failed to end voice session during cleanup: $e');
      }
    }

    _cleanup();
    state = const WalkieTalkieState();
  }

  void _cleanup() {
    _statusSub?.cancel();
    _participantsSub?.cancel();
    _statusSub = null;
    _participantsSub = null;
  }
}
