import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/data/models/parental_consent.dart';
import 'package:nebu_mobile_flutter/data/models/user_setup.dart';
import 'package:nebu_mobile_flutter/data/services/user_setup_service.dart';

import 'mocks.dart';

void main() {
  late MockApiService apiService;
  late MockLogger logger;
  late UserSetupService service;

  const profile = UserProfile(
    name: 'Adulto responsable',
    email: 'adult@example.test',
  );
  const preferences = UserPreferences(language: 'es', theme: 'system');
  const notifications = NotificationSettings();
  const voice = VoiceSettings(voiceModel: 'nebu-voice');

  setUp(() {
    apiService = MockApiService();
    logger = MockLogger();
    service = UserSetupService(apiService: apiService, logger: logger);
  });

  test('saveSetup submits the three versioned consent declarations', () async {
    when(
      apiService.post<Map<String, dynamic>>(
        '/users/user-1/setup',
        data: anyNamed('data') as Object?,
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{
        'success': true,
        'message': 'ok',
        'setupCompleted': true,
      },
    );

    await service.saveSetup(
      userId: 'user-1',
      profile: profile,
      preferences: preferences,
      notifications: notifications,
      voice: voice,
      parentalConsent: const ParentalConsent(locale: 'es'),
    );

    final payload =
        verify(
              apiService.post<Map<String, dynamic>>(
                '/users/user-1/setup',
                data: captureAnyNamed('data') as Object?,
              ),
            ).captured.single
            as Map<String, dynamic>;
    final consent = payload['parentalConsent'] as Map<String, dynamic>;

    expect(consent['parentOrGuardianDeclaration'], isTrue);
    expect(consent['childDataProcessing'], isTrue);
    expect(consent['sensitiveDataProcessing'], isTrue);
    expect(consent['privacyVersion'], ParentalConsent.currentPrivacyVersion);
    expect(consent['locale'], 'es');
  });

  test(
    'saveSetup omits inline consent for an existing backend record',
    () async {
      when(
        apiService.post<Map<String, dynamic>>(
          '/users/user-1/setup',
          data: anyNamed('data') as Object?,
        ),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'success': true,
          'message': 'ok',
          'setupCompleted': true,
        },
      );

      await service.saveSetup(
        userId: 'user-1',
        profile: profile,
        preferences: preferences,
        notifications: notifications,
        voice: voice,
      );

      final payload =
          verify(
                apiService.post<Map<String, dynamic>>(
                  '/users/user-1/setup',
                  data: captureAnyNamed('data') as Object?,
                ),
              ).captured.single
              as Map<String, dynamic>;

      expect(payload.containsKey('parentalConsent'), isFalse);
    },
  );

  test(
    'hasCurrentParentalConsent validates version and account owner',
    () async {
      when(
        apiService.get<Map<String, dynamic>>('/users/user-1/setup'),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'parentalConsent': <String, dynamic>{
            'parentOrGuardianDeclaration': true,
            'childDataProcessing': true,
            'sensitiveDataProcessing': true,
            'privacyVersion': ParentalConsent.currentPrivacyVersion,
            'authenticatedUserId': 'user-1',
          },
        },
      );

      expect(await service.hasCurrentParentalConsent('user-1'), isTrue);
    },
  );

  test(
    'hasCurrentParentalConsent rejects another account or stale version',
    () async {
      when(
        apiService.get<Map<String, dynamic>>('/users/user-1/setup'),
      ).thenAnswer(
        (_) async => <String, dynamic>{
          'parentalConsent': <String, dynamic>{
            'parentOrGuardianDeclaration': true,
            'childDataProcessing': true,
            'sensitiveDataProcessing': true,
            'privacyVersion': '2025-01-01',
            'authenticatedUserId': 'another-user',
          },
        },
      );

      expect(await service.hasCurrentParentalConsent('user-1'), isFalse);
    },
  );
}
