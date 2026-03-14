import 'dart:async';
import 'dart:convert';

import 'package:livekit_client/livekit_client.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';
import 'api_service.dart';

/// LiveKit room configuration
class LiveKitConfig {
  const LiveKitConfig({
    required this.roomName,
    required this.participantName,
    this.serverUrl,
    this.token,
  });
  final String? serverUrl;
  final String roomName;
  final String participantName;
  final String? token;
}

/// IoT device data payload
class IoTDeviceData {
  const IoTDeviceData({
    required this.deviceId,
    required this.deviceType,
    required this.data,
    required this.timestamp,
  });

  factory IoTDeviceData.fromJson(Map<String, dynamic> json) => IoTDeviceData(
    deviceId: json['deviceId'] as String,
    deviceType: json['deviceType'] as String,
    data: json['data'] as Map<String, dynamic>,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
  );
  final String deviceId;
  final String deviceType;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceType': deviceType,
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}

/// Connection states
enum LiveKitConnectionStatus { disconnected, connecting, connected, error }

/// LiveKit service for IoT real-time communication.
/// Uses ApiService for backend API calls (token generation, room management).
class LiveKitService {
  LiveKitService({required Logger logger, required ApiService apiService})
    : _logger = logger,
      _apiService = apiService;
  final Logger _logger;
  final ApiService _apiService;

  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  LiveKitConnectionStatus _status = LiveKitConnectionStatus.disconnected;

  final StreamController<LiveKitConnectionStatus> _statusController =
      StreamController<LiveKitConnectionStatus>.broadcast();
  final StreamController<IoTDeviceData> _deviceDataController =
      StreamController<IoTDeviceData>.broadcast();
  final StreamController<List<RemoteParticipant>> _participantsController =
      StreamController<List<RemoteParticipant>>.broadcast();

  void Function(IoTDeviceData)? onDeviceDataCallback;
  void Function(LiveKitConnectionStatus)? onConnectionStatusCallback;

  /// Connect to a LiveKit room.
  Future<void> connect(LiveKitConfig config) async {
    try {
      _setStatus(LiveKitConnectionStatus.connecting);

      final serverUrl = config.serverUrl ?? Config.livekitUrl;
      final token =
          config.token ??
          await _fetchToken(config.participantName, config.roomName);

      _room = Room();
      _setupRoomEventHandlers();

      await _room!.connect(serverUrl, token);
      _setStatus(LiveKitConnectionStatus.connected);

      _logger.d('Connected to LiveKit room: ${config.roomName}');
    } catch (error) {
      _logger.e('Failed to connect to LiveKit: $error');
      _setStatus(LiveKitConnectionStatus.error);
      rethrow;
    }
  }

  void _setupRoomEventHandlers() {
    if (_room == null) {
      return;
    }

    unawaited(_roomListener?.dispose());
    _roomListener = _room!.createListener()
      ..on<RoomConnectedEvent>((event) {
        _logger.d('LiveKit room connected');
        _setStatus(LiveKitConnectionStatus.connected);
      })
      ..on<RoomDisconnectedEvent>((event) {
        _logger.d('LiveKit room disconnected');
        _setStatus(LiveKitConnectionStatus.disconnected);
      })
      ..on<DataReceivedEvent>((event) {
        _handleDataReceived(event.data);
      })
      ..on<ParticipantConnectedEvent>((event) {
        _logger.d('Participant connected: ${event.participant.identity}');
        _participantsController.add(
          _room?.remoteParticipants.values.toList() ?? [],
        );
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        _logger.d('Participant disconnected: ${event.participant.identity}');
        _participantsController.add(
          _room?.remoteParticipants.values.toList() ?? [],
        );
      });
  }

  void _handleDataReceived(List<int> data) {
    try {
      final payload = utf8.decode(data);
      final deviceData = IoTDeviceData.fromJson(
        jsonDecode(payload) as Map<String, dynamic>,
      );

      _deviceDataController.add(deviceData);
      onDeviceDataCallback?.call(deviceData);

      _logger.d('Received IoT device data: ${deviceData.deviceId}');
    } on Exception catch (e) {
      _logger.e('Error handling received data: $e');
    }
  }

  void _setStatus(LiveKitConnectionStatus status) {
    _status = status;
    _statusController.add(status);
    onConnectionStatusCallback?.call(status);
  }

  /// Fetch token from backend via the user-accessible endpoint.
  Future<String> _fetchToken(String participantName, String roomName) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/livekit/token/user',
      data: {'participantName': participantName, 'roomName': roomName},
    );
    final token = response['token'];
    if (token is! String) {
      throw Exception('Invalid token response from server');
    }
    return token;
  }

  /// Mute/unmute a remote participant via backend API.
  Future<void> muteParticipant({
    required String roomName,
    required String identity,
    bool mute = true,
  }) async {
    _logger.d(
      '${mute ? "Muting" : "Unmuting"} participant $identity in $roomName',
    );
    await _apiService.post<dynamic>(
      '/livekit/rooms/$roomName/mute/$identity',
      data: {'muteAudio': mute},
    );
    _logger.d(
      'Participant $identity ${mute ? "muted" : "unmuted"} successfully',
    );
  }

  Future<void> setMicrophoneEnabled({required bool enabled}) async {
    if (_room == null) {
      return;
    }
    await _room!.localParticipant?.setMicrophoneEnabled(enabled);
    _logger.d('Microphone ${enabled ? 'enabled' : 'disabled'}');
  }

  List<RemoteParticipant> get participants =>
      _room?.remoteParticipants.values.toList() ?? [];

  LiveKitConnectionStatus get status => _status;

  Stream<LiveKitConnectionStatus> get statusStream => _statusController.stream;
  Stream<IoTDeviceData> get deviceDataStream => _deviceDataController.stream;
  Stream<List<RemoteParticipant>> get participantsStream =>
      _participantsController.stream;

  Future<void> disconnect() async {
    try {
      await _roomListener?.dispose();
      _roomListener = null;
      await _room?.disconnect();
      _room = null;
      _setStatus(LiveKitConnectionStatus.disconnected);
      _logger.d('Disconnected from LiveKit');
    } on Exception catch (e) {
      _logger.e('Error disconnecting from LiveKit: $e');
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _deviceDataController.close();
    await _participantsController.close();
  }
}
