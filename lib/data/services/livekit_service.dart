import 'dart:async';
import 'dart:convert';

import 'package:livekit_client/livekit_client.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';
import 'api_service.dart';

typedef LiveKitRoomFactory = Room Function();

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
  LiveKitService({
    required Logger logger,
    required ApiService apiService,
    LiveKitRoomFactory? roomFactory,
  }) : _logger = logger,
       _apiService = apiService,
       _roomFactory = roomFactory ?? Room.new;
  final Logger _logger;
  final ApiService _apiService;
  final LiveKitRoomFactory _roomFactory;

  _LiveKitConnection? _connection;
  LiveKitConnectionStatus _status = LiveKitConnectionStatus.disconnected;
  int _connectionGeneration = 0;
  bool _disposed = false;

  final StreamController<LiveKitConnectionStatus> _statusController =
      StreamController<LiveKitConnectionStatus>.broadcast();
  final StreamController<IoTDeviceData> _deviceDataController =
      StreamController<IoTDeviceData>.broadcast();
  final StreamController<List<RemoteParticipant>> _participantsController =
      StreamController<List<RemoteParticipant>>.broadcast();

  void Function(IoTDeviceData)? onDeviceDataCallback;
  void Function(LiveKitConnectionStatus)? onConnectionStatusCallback;

  /// Connect to a LiveKit room.
  Future<bool> connect(LiveKitConfig config) async {
    if (_disposed) {
      return false;
    }

    final generation = ++_connectionGeneration;
    final previousConnection = _connection;
    _connection = null;
    _emitParticipants(const []);
    _setStatus(LiveKitConnectionStatus.connecting);

    // Close the previous room before publishing another one. The connection
    // handle makes this safe even when a stale connect is also cleaning up.
    await previousConnection?.close(_logger);
    if (!_isCurrentGeneration(generation)) {
      return false;
    }

    _LiveKitConnection? candidate;
    try {
      final serverUrl = config.serverUrl ?? Config.livekitUrl;
      final token =
          config.token ??
          await _fetchToken(config.participantName, config.roomName);
      if (!_isCurrentGeneration(generation)) {
        return false;
      }

      final room = _roomFactory();
      final listener = _createRoomEventHandlers(room, generation);
      candidate = _LiveKitConnection(room: room, listener: listener);
      _connection = candidate;

      await room.connect(serverUrl, token);
      if (!_ownsRoom(generation, room)) {
        await candidate.close(_logger);
        return false;
      }
      _setStatus(LiveKitConnectionStatus.connected);

      _logger.d('Connected to LiveKit room: ${config.roomName}');
      return true;
    } on Object catch (error) {
      if (candidate != null) {
        if (identical(_connection, candidate)) {
          _connection = null;
        }
        await candidate.close(_logger);
      }
      if (!_isCurrentGeneration(generation)) {
        return false;
      }
      _logger.e('Failed to connect to LiveKit: $error');
      _setStatus(LiveKitConnectionStatus.error);
      rethrow;
    }
  }

  EventsListener<RoomEvent> _createRoomEventHandlers(
    Room room,
    int generation,
  ) => room.createListener()
    ..on<RoomConnectedEvent>((event) {
      if (!_ownsRoom(generation, room)) {
        return;
      }
      _logger.d('LiveKit room connected');
      _setStatus(LiveKitConnectionStatus.connected);
    })
    ..on<RoomDisconnectedEvent>((event) {
      if (!_ownsRoom(generation, room)) {
        return;
      }
      _logger.d('LiveKit room disconnected');
      _emitParticipants(const []);
      _setStatus(LiveKitConnectionStatus.disconnected);
    })
    ..on<DataReceivedEvent>((event) {
      if (!_ownsRoom(generation, room)) {
        return;
      }
      _handleDataReceived(event.data);
    })
    ..on<ParticipantConnectedEvent>((event) {
      if (!_ownsRoom(generation, room)) {
        return;
      }
      _logger.d('Participant connected: ${event.participant.identity}');
      _emitParticipants(room.remoteParticipants.values.toList());
    })
    ..on<ParticipantDisconnectedEvent>((event) {
      if (!_ownsRoom(generation, room)) {
        return;
      }
      _logger.d('Participant disconnected: ${event.participant.identity}');
      _emitParticipants(room.remoteParticipants.values.toList());
    });

  bool _isCurrentGeneration(int generation) =>
      !_disposed && generation == _connectionGeneration;

  bool _ownsRoom(int generation, Room room) =>
      _isCurrentGeneration(generation) && identical(_connection?.room, room);

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
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
    onConnectionStatusCallback?.call(status);
  }

  void _emitParticipants(List<RemoteParticipant> participants) {
    if (!_participantsController.isClosed) {
      _participantsController.add(participants);
    }
  }

  /// Fetch token from backend via the user-accessible endpoint.
  Future<String> _fetchToken(String participantName, String toyId) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/livekit/token/user',
      data: {'toyId': toyId, 'identity': participantName},
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
    final connection = _connection;
    final participant = connection?.room.localParticipant;
    if (connection == null || participant == null) {
      return;
    }
    await participant.setMicrophoneEnabled(enabled);

    // An enable that completes after this room was replaced must never leave
    // the abandoned local participant publishing audio.
    if (enabled && !identical(_connection, connection)) {
      await participant.setMicrophoneEnabled(false);
      return;
    }
    _logger.d('Microphone ${enabled ? 'enabled' : 'disabled'}');
  }

  List<RemoteParticipant> get participants =>
      _connection?.room.remoteParticipants.values.toList() ?? [];

  LiveKitConnectionStatus get status => _status;

  Stream<LiveKitConnectionStatus> get statusStream => _statusController.stream;
  Stream<IoTDeviceData> get deviceDataStream => _deviceDataController.stream;
  Stream<List<RemoteParticipant>> get participantsStream =>
      _participantsController.stream;

  Future<void> disconnect() async {
    final generation = ++_connectionGeneration;
    final connection = _connection;
    _connection = null;
    _emitParticipants(const []);

    await connection?.close(_logger);
    if (generation == _connectionGeneration) {
      _setStatus(LiveKitConnectionStatus.disconnected);
      _logger.d('Disconnected from LiveKit');
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await disconnect();
    await _statusController.close();
    await _deviceDataController.close();
    await _participantsController.close();
  }
}

class _LiveKitConnection {
  _LiveKitConnection({required this.room, required this.listener});

  final Room room;
  final EventsListener<RoomEvent> listener;
  Future<void>? _closeFuture;

  Future<void> close(Logger logger) => _closeFuture ??= _close(logger);

  Future<void> _close(Logger logger) async {
    try {
      await listener.dispose();
    } on Object catch (error) {
      logger.w('Failed to dispose LiveKit room listener: $error');
    }
    try {
      await room.disconnect();
    } on Object catch (error) {
      logger.w('Failed to disconnect LiveKit room: $error');
    }
    try {
      await room.dispose();
    } on Object catch (error) {
      logger.w('Failed to dispose LiveKit room: $error');
    }
  }
}
