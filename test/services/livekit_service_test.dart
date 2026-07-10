import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/data/services/api_service.dart';
import 'package:nebu_mobile_flutter/data/services/livekit_service.dart';

class _MockApiService extends Mock implements ApiService {}

class _ControlledRoom extends Room {
  final connectCompletion = Completer<void>();
  bool connectCalled = false;
  int disconnectCalls = 0;
  int disposeCalls = 0;

  @override
  Future<void> connect(
    String url,
    String token, {
    ConnectOptions? connectOptions,
    RoomOptions? roomOptions,
    FastConnectOptions? fastConnectOptions,
  }) {
    connectCalled = true;
    return connectCompletion.future;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<bool> dispose() async {
    disposeCalls++;
    return super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<_ControlledRoom> rooms;
  late LiveKitService service;

  setUp(() {
    rooms = [];
    service = LiveKitService(
      logger: Logger(level: Level.off),
      apiService: _MockApiService(),
      roomFactory: () {
        final room = _ControlledRoom();
        rooms.add(room);
        return room;
      },
    );
  });

  tearDown(() async {
    for (final room in rooms) {
      if (!room.connectCompletion.isCompleted) {
        room.connectCompletion.complete();
      }
    }
    await service.dispose();
  });

  test('disconnect invalidates an in-flight connection', () async {
    final connecting = service.connect(_config('room-a'));
    await Future<void>.delayed(Duration.zero);
    final room = rooms.single;
    expect(room.connectCalled, isTrue);

    await service.disconnect();
    room.connectCompletion.complete();

    expect(await connecting, isFalse);
    expect(room.disconnectCalls, 1);
    expect(room.disposeCalls, 1);
    expect(service.status, LiveKitConnectionStatus.disconnected);
  });

  test(
    'a newer connect owns the service when an older one completes late',
    () async {
      final firstConnect = service.connect(_config('room-a'));
      await Future<void>.delayed(Duration.zero);
      final firstRoom = rooms.single;

      final secondConnect = service.connect(_config('room-b'));
      await Future<void>.delayed(Duration.zero);
      final secondRoom = rooms.last;
      expect(rooms, hasLength(2));
      expect(firstRoom.disconnectCalls, 1);

      secondRoom.connectCompletion.complete();
      expect(await secondConnect, isTrue);
      expect(service.status, LiveKitConnectionStatus.connected);

      firstRoom.connectCompletion.complete();
      expect(await firstConnect, isFalse);
      expect(service.status, LiveKitConnectionStatus.connected);
      expect(firstRoom.disconnectCalls, 1);
      expect(firstRoom.disposeCalls, 1);
    },
  );
}

LiveKitConfig _config(String roomName) => LiveKitConfig(
  serverUrl: 'wss://livekit.example',
  roomName: roomName,
  participantName: 'parent',
  token: 'signed-token',
);
