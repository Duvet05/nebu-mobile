import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/data/services/auth_service.dart';
import 'mocks.dart';

class _TestAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handle;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final handler = handle;
    if (handler == null) {
      throw Exception('No handler configured for ${options.path}');
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object payload, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(payload),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  late MockFlutterSecureStorage secureStorage;
  late MockLogger logger;
  late _TestAdapter adapter;
  late Dio dio;

  setUp(() {
    secureStorage = MockFlutterSecureStorage();
    logger = MockLogger();
    adapter = _TestAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    reset(secureStorage);
    reset(logger);
  });

  test(
    'login exitoso guarda tokens y devuelve AuthResponse con success=true',
    () async {
      adapter.handle = (options) {
        if (options.path == '/auth/login') {
          return _jsonResponse({
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
            'user': <String, dynamic>{
              'id': 'user-1',
              'email': 'user@email.com',
            },
          }, 200);
        }
        throw Exception('Unexpected request ${options.path}');
      };

      final service = AuthService(
        dio: dio,
        secureStorage: secureStorage,
        logger: logger,
      );

      final response = await service.login(
        identifier: 'user@email.com',
        password: 'secret',
      );

      expect(response.success, isTrue);
      expect(response.tokens?.accessToken, 'access-token');
      expect(response.tokens?.refreshToken, 'refresh-token');
      verify(
        secureStorage.write(
          key: StorageKeys.accessToken,
          value: 'access-token',
        ),
      ).called(1);
      verify(
        secureStorage.write(
          key: StorageKeys.refreshToken,
          value: 'refresh-token',
        ),
      ).called(1);
    },
  );

  test('login devuelve error mapeado para credenciales inválidas', () async {
    adapter.handle = (options) {
      if (options.path == '/auth/login') {
        return _jsonResponse({'errorCode': 'UNAUTHORIZED'}, 401);
      }
      throw Exception('Unexpected request ${options.path}');
    };

    final service = AuthService(
      dio: dio,
      secureStorage: secureStorage,
      logger: logger,
    );

    final response = await service.login(
      identifier: 'user@email.com',
      password: 'wrong',
    );

    expect(response.success, isFalse);
    expect(response.error, 'auth.error_unauthorized');
  });

  test(
    'refreshAccessToken sin refresh token hace logout y limpia almacenamiento',
    () async {
      adapter.handle = (options) {
        if (options.path == '/auth/logout') {
          return _jsonResponse({}, 200);
        }
        throw Exception('Unexpected request ${options.path}');
      };

      when(
        secureStorage.read(key: StorageKeys.refreshToken),
      ).thenAnswer((_) async => null);
      when(
        secureStorage.read(key: StorageKeys.accessToken),
      ).thenAnswer((_) async => 'existing-access-token' as String?);
      when(
        secureStorage.delete(key: StorageKeys.accessToken),
      ).thenAnswer((_) async {});
      when(
        secureStorage.delete(key: StorageKeys.refreshToken),
      ).thenAnswer((_) async {});
      when(
        secureStorage.delete(key: StorageKeys.user),
      ).thenAnswer((_) async {});

      final service = AuthService(
        dio: dio,
        secureStorage: secureStorage,
        logger: logger,
      );

      final refreshedToken = await service.refreshAccessToken();

      expect(refreshedToken, isNull);
      verify(secureStorage.delete(key: StorageKeys.accessToken)).called(1);
      verify(secureStorage.delete(key: StorageKeys.refreshToken)).called(1);
      verify(secureStorage.delete(key: StorageKeys.user)).called(1);
    },
  );
}
