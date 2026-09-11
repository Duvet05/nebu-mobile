import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/core/errors/app_exception.dart';
import 'package:nebu_mobile_flutter/data/models/toy.dart';
import 'package:nebu_mobile_flutter/data/services/toy_service.dart';
import 'mocks.dart';

void main() {
  late MockApiService apiService;
  late MockLogger logger;
  late ToyService toyService;

  setUp(() {
    apiService = MockApiService();
    logger = MockLogger();
    toyService = ToyService(apiService: apiService, logger: logger);
  });

  test('createToy crea un juguete y lo parsea correctamente', () async {
    when(
      apiService.post<Map<String, dynamic>>(
        '/toys',
        data: anyNamed('data') as Object?,
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'toy-1',
        'name': 'Dino',
        'status': 'active',
      },
    );

    final toy = await toyService.createToy(name: 'Dino');

    expect(toy.id, 'toy-1');
    expect(toy.name, 'Dino');
    expect(toy.status, ToyStatus.active);
  });

  test(
    'createToy registra el nombre exacto en el payload de creación',
    () async {
      when(
        apiService.post<Map<String, dynamic>>(
          '/toys',
          data: anyNamed('data') as Object?,
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 'toy-2',
          'name': 'Aventurero',
          'deviceId': 'ESP32_NODE_DIRECT',
          'macAddress': 'MACNODEDIRECT',
          'status': 'active',
        },
      );

      await toyService.createToy(
        name: 'Aventurero',
        deviceId: 'ESP32_NODE_DIRECT',
        macAddress: 'MACNODEDIRECT',
      );

      final payload =
          verify(
                apiService.post<Map<String, dynamic>>(
                  '/toys',
                  data: captureAnyNamed('data') as Object?,
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(payload['name'], 'Aventurero');
      expect(payload['deviceId'], 'ESP32_NODE_DIRECT');
      expect(payload['macAddress'], 'MACNODEDIRECT');
      expect(payload.containsKey('toyName'), isFalse);
      expect(payload.containsKey('userId'), isFalse);
    },
  );

  test(
    'createToy omite deviceId vacío y conserva macAddress fallback',
    () async {
      when(
        apiService.post<Map<String, dynamic>>(
          '/toys',
          data: anyNamed('data') as Object?,
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 'toy-3',
          'name': 'Aventurero',
          'macAddress': 'AA:BB:CC:11:22:33',
          'status': 'active',
        },
      );

      await toyService.createToy(
        name: 'Aventurero',
        deviceId: '  ',
        macAddress: ' AA:BB:CC:11:22:33 ',
      );

      final payload =
          verify(
                apiService.post<Map<String, dynamic>>(
                  '/toys',
                  data: captureAnyNamed('data') as Object?,
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(payload['name'], 'Aventurero');
      expect(payload.containsKey('deviceId'), isFalse);
      expect(payload['macAddress'], 'AA:BB:CC:11:22:33');
    },
  );

  test('getMyToys retorna lista vacía ante NotFoundException', () async {
    when(
      apiService.get<List<dynamic>>('/toys/my-toys'),
    ).thenThrow(const NotFoundException('No toys'));

    final toys = await toyService.getMyToys();

    expect(toys, isEmpty);
  });

  test(
    'updateToyConnectionStatus propaga AppException desde ApiService',
    () async {
      when(
        apiService.patch<Map<String, dynamic>>(
          '/toys/connection/device-1',
          data: anyNamed('data') as Object?,
        ),
      ).thenThrow(
        const ValidationException('Invalid payload', statusCode: 400),
      );

      await expectLater(
        () => toyService.updateToyConnectionStatus(
          deviceId: 'device-1',
          status: ToyStatus.connected,
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );

  test('updateToy envía voicePreference dentro de settings', () async {
    const voiceId = 'default-oklrorszoxbwzfdj8zjhng__nebu_pirat';

    when(
      apiService.patch<Map<String, dynamic>>(
        '/toys/toy-voice',
        data: anyNamed('data') as Object?,
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'toy-voice',
        'name': 'Nebu',
        'status': 'active',
        'settings': <String, dynamic>{
          'voicePreference': voiceId,
          'enableVarietyEngine': true,
        },
      },
    );

    await toyService.updateToy(
      id: 'toy-voice',
      settings: <String, dynamic>{
        'voicePreference': voiceId,
        'enableVarietyEngine': true,
      },
    );

    final payload =
        verify(
              apiService.patch<Map<String, dynamic>>(
                '/toys/toy-voice',
                data: captureAnyNamed('data') as Object?,
              ),
            ).captured.single
            as Map<String, dynamic>;

    expect(payload['settings'], containsPair('voicePreference', voiceId));
    expect(payload['settings'], containsPair('enableVarietyEngine', true));
  });

  test(
    'existing cloned voices and child profiles survive toy loading',
    () async {
      const settings = <String, dynamic>{
        'voicePreference': 'existing-custom-voice',
        'clonedVoice': <String, dynamic>{
          'id': 'existing-custom-voice',
          'name': 'Family voice',
        },
      };
      when(apiService.get<Map<String, dynamic>>('/toys/toy-legacy')).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 'toy-legacy',
          'name': 'Nebu',
          'status': 'disconnected',
          'ownerId': 'child-1',
          'personalityProfile': 'musical',
          'settings': settings,
        },
      );

      final toy = await toyService.getToyById('toy-legacy');

      expect(toy.settings, settings);
      expect(toy.personalityProfile, 'musical');
      expect(toy.ownerId, 'child-1');
      verify(
        apiService.get<Map<String, dynamic>>('/toys/toy-legacy'),
      ).called(1);
      verifyNoMoreInteractions(apiService);
    },
  );

  test('an existing cloned voice can still be removed by its owner', () async {
    when(
      apiService.delete<Map<String, dynamic>>('/toys/toy-legacy/voice-clone'),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'toy-legacy',
        'name': 'Nebu',
        'status': 'disconnected',
        'settings': <String, dynamic>{'voicePreference': 'nebu'},
      },
    );

    final toy = await toyService.removeClonedVoice('toy-legacy');

    expect(toy.settings?['voicePreference'], 'nebu');
    verify(
      apiService.delete<Map<String, dynamic>>('/toys/toy-legacy/voice-clone'),
    ).called(1);
    verifyNoMoreInteractions(apiService);
  });
}
