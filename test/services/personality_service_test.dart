import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/core/errors/app_exception.dart';
import 'package:nebu_mobile_flutter/data/services/personality_service.dart';
import 'mocks.dart';

void main() {
  late MockApiService apiService;
  late MockLogger logger;
  late PersonalityService personalityService;

  setUp(() {
    apiService = MockApiService();
    logger = MockLogger();
    personalityService = PersonalityService(
      apiService: apiService,
      logger: logger,
    );
  });

  test(
    'getPersonalities normaliza name cuando backend no manda display_name',
    () async {
      when(
        apiService.get<dynamic>(
          '/agent/personalities',
          options: anyNamed('options') as Options?,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': 'neutral',
            'name': '{name} Estandar',
            'description': 'Companero base',
          },
        ],
      );

      final personalities = await personalityService.getPersonalities();

      expect(personalities, hasLength(1));
      expect(personalities.single.id, 'neutral');
      expect(personalities.single.name, '{name} Estandar');
      expect(personalities.single.description, 'Companero base');
    },
  );

  test(
    'getPersonalities usa fallback si backend responde lista vacía',
    () async {
      when(
        apiService.get<dynamic>(
          '/agent/personalities',
          options: anyNamed('options') as Options?,
        ),
      ).thenAnswer((_) async => <dynamic>[]);

      final personalities = await personalityService.getPersonalities();

      expect(personalities.map((p) => p.id), [
        'neutral',
        'peruvian',
        'mexican',
        'kpop',
        'roblox',
      ]);
    },
  );

  test('getPersonalities usa fallback si backend falla', () async {
    when(
      apiService.get<dynamic>(
        '/agent/personalities',
        options: anyNamed('options') as Options?,
      ),
    ).thenThrow(const NetworkException('Connection timed out'));

    final personalities = await personalityService.getPersonalities();

    expect(personalities, hasLength(5));
    expect(personalities.first.id, 'neutral');
    expect(personalities.last.id, 'roblox');
  });
}
