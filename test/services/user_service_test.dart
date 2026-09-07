import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/data/services/user_service.dart';
import 'mocks.dart';

void main() {
  late MockApiService apiService;
  late MockLogger logger;
  late UserService userService;

  setUp(() {
    apiService = MockApiService();
    logger = MockLogger();
    userService = UserService(apiService: apiService, logger: logger);
  });

  test('getCurrentUserProfile obtiene y parsea usuario actual', () async {
    when(apiService.get<Map<String, dynamic>>('/users/me')).thenAnswer(
      (_) async => <String, dynamic>{
        'id': 'user-1',
        'email': 'user@email.com',
        'firstName': 'Ada',
        'lastName': 'Lovelace',
      },
    );

    final user = await userService.getCurrentUserProfile();

    expect(user.id, 'user-1');
    expect(user.email, 'user@email.com');
    expect(user.name, 'Ada Lovelace');
  });

  test('updateCurrentUserProfile propaga errores de ApiService', () async {
    when(
      apiService.patch<Map<String, dynamic>>(
        '/users/me',
        data: anyNamed('data') as Object?,
      ),
    ).thenThrow(Exception('network error'));

    await expectLater(
      () => userService.updateCurrentUserProfile(firstName: 'Ana'),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'deleteOwnAccount retorna texto por defecto cuando backend no provee message',
    () async {
      when(
        apiService.delete<Map<String, dynamic>>(
          '/users/me',
          data: anyNamed('data') as Object?,
        ),
      ).thenAnswer((_) async => <String, dynamic>{'ok': true});

      final message = await userService.deleteOwnAccount(
        expectedUserId: 'confirmed-user',
        password: 'pass',
      );

      expect(message, 'Account deleted');
    },
  );

  test(
    'OAuth deletion omits password instead of sending a placeholder',
    () async {
      when(
        apiService.delete<Map<String, dynamic>>(
          '/users/me',
          data: anyNamed('data') as Object?,
        ),
      ).thenAnswer((_) async => {'message': 'Account deleted'});

      await userService.deleteOwnAccount(expectedUserId: 'confirmed-user');

      verify(
        apiService.delete<Map<String, dynamic>>(
          '/users/me',
          data: {'expectedUserId': 'confirmed-user'},
        ),
      );
    },
  );

  test('local deletion sends the password without changing it', () async {
    when(
      apiService.delete<Map<String, dynamic>>(
        '/users/me',
        data: anyNamed('data') as Object?,
      ),
    ).thenAnswer((_) async => {'message': 'Account deleted'});

    await userService.deleteOwnAccount(
      expectedUserId: 'confirmed-user',
      password: ' LocalPassword1 ',
    );

    verify(
      apiService.delete<Map<String, dynamic>>(
        '/users/me',
        data: {
          'expectedUserId': 'confirmed-user',
          'password': ' LocalPassword1 ',
        },
      ),
    );
  });

  test(
    'deletion propagates server failure instead of reporting success',
    () async {
      when(
        apiService.delete<Map<String, dynamic>>(
          '/users/me',
          data: anyNamed('data') as Object?,
        ),
      ).thenThrow(Exception('Deletion denied'));

      await expectLater(
        userService.deleteOwnAccount(expectedUserId: 'confirmed-user'),
        throwsException,
      );
    },
  );
}
