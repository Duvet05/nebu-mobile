import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logger/logger.dart';

import '../../core/config/config.dart';

/// Configuración de LiveKit
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

/// Datos de dispositivo IoT
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
  final String deviceType; // 'sensor' | 'actuator' | 'camera' | 'microphone'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceType': deviceType,
    'data': data,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}

/// Estados de conexión
enum LiveKitConnectionStatus { disconnected, connecting, connected, error }

/// Servicio de LiveKit para IoT
class LiveKitService {
  LiveKitService({required Logger logger, required Dio dio})
    : _logger = logger,
      _dio = dio;
  final Logger _logger;
  final Dio _dio;

  Room? _room;
  // LiveKitConfig? _config; // Unused field, commented for future use
  LiveKitConnectionStatus _status = LiveKitConnectionStatus.disconnected;

  // Streams para notificaciones
  final StreamController<LiveKitConnectionStatus> _statusController =
      StreamController<LiveKitConnectionStatus>.broadcast();
  final StreamController<IoTDeviceData> _deviceDataController =
      StreamController<IoTDeviceData>.broadcast();
  final StreamController<List<RemoteParticipant>> _participantsController =
      StreamController<List<RemoteParticipant>>.broadcast();

  // Callbacks
  void Function(IoTDeviceData)? onDeviceDataCallback;
  void Function(LiveKitConnectionStatus)? onConnectionStatusCallback;

  /// Conectar a LiveKit
  Future<void> connect(LiveKitConfig config) async {
    try {
      // _config = config; // Unused assignment
      _setStatus(LiveKitConnectionStatus.connecting);

      // Usar servidor local en desarrollo, demo server como fallback
      final serverUrl =
          config.serverUrl ??
          (Config.isDevelopment
              ? 'ws://localhost:7880'
              : 'wss://livekit-demo.livekit.cloud');

      final roomName = config.roomName;
      final participantName = config.participantName;

      // Generar token demo para LiveKit demo server
      final token =
          config.token ?? await _generateDemoToken(participantName, roomName);

      _room = Room();
      _setupRoomEventHandlers();

      await _room!.connect(serverUrl, token);
      _setStatus(LiveKitConnectionStatus.connected);

      _logger.i('Connected to LiveKit room: $roomName');
    } catch (error) {
      _logger.e('Failed to connect to LiveKit: $error');
      _setStatus(LiveKitConnectionStatus.error);
      rethrow;
    }
  }

  /// Configurar manejadores de eventos de la sala
  void _setupRoomEventHandlers() {
    if (_room == null) {
      return;
    }

    _room!.createListener()
      ..on<RoomConnectedEvent>((event) {
        _logger.i('LiveKit room connected');
        _setStatus(LiveKitConnectionStatus.connected);
      })
      ..on<RoomDisconnectedEvent>((event) {
        _logger.i('LiveKit room disconnected');
        _setStatus(LiveKitConnectionStatus.disconnected);
      })
      ..on<DataReceivedEvent>((event) {
        _handleDataReceived(event.data);
      })
      ..on<ParticipantConnectedEvent>((event) {
        _logger.i('Participant connected: ${event.participant.identity}');
        _participantsController.add(_room?.remoteParticipants.values.toList() ?? []);
      })
      ..on<ParticipantDisconnectedEvent>((event) {
        _logger.i('Participant disconnected: ${event.participant.identity}');
        _participantsController.add(_room?.remoteParticipants.values.toList() ?? []);
      });
  }

  /// Manejar datos recibidos
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

  /// Cambiar estado y notificar
  void _setStatus(LiveKitConnectionStatus status) {
    _status = status;
    _statusController.add(status);
    onConnectionStatusCallback?.call(status);
    _logger.d('LiveKit status changed to: $status');
  }

  /// Generar token demo
  Future<String> _generateDemoToken(
    String participantName,
    String roomName,
  ) async {
    try {
      // En desarrollo, usar token demo simple
      if (Config.isDevelopment) {
        return _createSimpleToken(participantName, roomName);
      }

      // En producción, obtener token del servidor
      final response = await _dio.post<Map<String, dynamic>>(
        '${Config.apiBaseUrl}/livekit/token',
        data: {'participantName': participantName, 'roomName': roomName},
      );

      return response.data?['token'] as String;
    } on Exception catch (e) {
      _logger.w('Failed to generate token from server, using demo token: $e');
      return _createSimpleToken(participantName, roomName);
    }
  }

  /// Crear token simple para desarrollo
  String _createSimpleToken(String participantName, String roomName) {
    // Token demo simple (en producción usar JWT real)
    final tokenData = {
      'sub': participantName,
      'room': roomName,
      'iss': 'nebu-demo',
      'exp':
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
          1000,
    };

    return base64Encode(utf8.encode(jsonEncode(tokenData)));
  }

  /// Mutear/desmutear un participante remoto en una sala
  Future<bool> muteParticipant({
    required String roomName,
    required String identity,
    bool mute = true,
  }) async {
    try {
      _logger.d('${mute ? "Muting" : "Unmuting"} participant $identity in room $roomName');
      await _dio.post<dynamic>(
        '${Config.apiBaseUrl}/livekit/rooms/$roomName/participants/$identity/mute',
        data: {'mute': mute},
      );
      _logger.i('Participant $identity ${mute ? "muted" : "unmuted"} successfully');
      return true;
    } on DioException catch (e) {
      _logger.e('Error muting participant: ${e.message}');
      return false;
    }
  }

  /// Enviar datos de dispositivo IoT
  Future<void> sendDeviceData(IoTDeviceData deviceData) async {
    if (_room == null || _status != LiveKitConnectionStatus.connected) {
      throw Exception('Not connected to LiveKit room');
    }

    try {
      final payload = utf8.encode(jsonEncode(deviceData.toJson()));

      await _room!.localParticipant?.publishData(
        payload,
        topic: 'iot-device-data',
        reliable: false,
      );

      _logger.d('Sent IoT device data: ${deviceData.deviceId}');
    } catch (e) {
      _logger.e('Error sending device data: $e');
      rethrow;
    }
  }

  /// Enviar comando a dispositivo
  Future<void> sendDeviceCommand({
    required String deviceId,
    required String command,
    required Map<String, dynamic> parameters,
  }) async {
    if (_room == null || _status != LiveKitConnectionStatus.connected) {
      throw Exception('Not connected to LiveKit room');
    }

    try {
      final commandData = {
        'deviceId': deviceId,
        'command': command,
        'parameters': parameters,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final payload = utf8.encode(jsonEncode(commandData));

      await _room!.localParticipant?.publishData(
        payload,
        topic: 'device-command',
        reliable: true,
      );

      _logger.d('Sent device command: $command to $deviceId');
    } catch (e) {
      _logger.e('Error sending device command: $e');
      rethrow;
    }
  }

  /// Habilitar/deshabilitar micrófono
  Future<void> setMicrophoneEnabled({required bool enabled}) async {
    if (_room == null) {
      return;
    }

    try {
      await _room!.localParticipant?.setMicrophoneEnabled(enabled);
      _logger.d('Microphone ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e) {
      _logger.e('Error setting microphone: $e');
    }
  }

  /// Habilitar/deshabilitar cámara
  Future<void> setCameraEnabled({required bool enabled}) async {
    if (_room == null) {
      return;
    }

    try {
      await _room!.localParticipant?.setCameraEnabled(enabled);
      _logger.d('Camera ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e) {
      _logger.e('Error setting camera: $e');
    }
  }

  /// Obtener participantes conectados
  List<RemoteParticipant> get participants =>
      _room?.remoteParticipants.values.toList() ?? [];

  /// Obtener estado de conexión
  LiveKitConnectionStatus get status => _status;

  /// Stream de estados de conexión
  Stream<LiveKitConnectionStatus> get statusStream => _statusController.stream;

  /// Stream de datos de dispositivos
  Stream<IoTDeviceData> get deviceDataStream => _deviceDataController.stream;

  /// Stream de participantes remotos
  Stream<List<RemoteParticipant>> get participantsStream => _participantsController.stream;

  /// Desconectar de LiveKit
  Future<void> disconnect() async {
    try {
      await _room?.disconnect();
      _room = null;
      _setStatus(LiveKitConnectionStatus.disconnected);
      _logger.i('Disconnected from LiveKit');
    } on Exception catch (e) {
      _logger.e('Error disconnecting from LiveKit: $e');
    }
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _deviceDataController.close();
    await _participantsController.close();
    _logger.i('LiveKit Service disposed');
  }
}
