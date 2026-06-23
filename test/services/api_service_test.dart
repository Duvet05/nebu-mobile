import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/errors/app_exception.dart';
import 'package:nebu_mobile_flutter/data/services/api_service.dart';
import 'mocks.dart';

class _TestAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handle;
  final Map<String, int> callCountByPath = <String, int>{};
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCountByPath[options.path] = (callCountByPath[options.path] ?? 0) + 1;
    requests.add(options);
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
    'get exitoso devuelve datos y agrega Authorization si hay token',
    () async {
      adapter.handle = (options) {
        if (options.path == '/health') {
          return _jsonResponse({'ok': true, 'token': 'sent'}, 200);
        }
        throw Exception('Unexpected request ${options.path}');
      };

      when(
        secureStorage.read(key: StorageKeys.accessToken),
      ).thenAnswer((_) async => 'token-123' as String?);

      final apiService = ApiService(
        dio: dio,
        secureStorage: secureStorage,
        logger: logger,
      );

      final payload = await apiService.get<Map<String, dynamic>>('/health');

      expect(payload, const {'ok': true, 'token': 'sent'});
      expect(adapter.callCountByPath['/health'], 1);
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer token-123',
      );
    },
  );

  test('get con 401 sin refresh token retorna AuthException', () async {
    adapter.handle = (options) {
      if (options.path == '/secure') {
        return _jsonResponse({'error': 'invalid token'}, 401);
      }
      throw Exception('Unexpected request ${options.path}');
    };

    when(
      secureStorage.read(key: StorageKeys.accessToken),
    ).thenAnswer((_) async => 'old-token' as String?);
    when(
      secureStorage.read(key: StorageKeys.refreshToken),
    ).thenAnswer((_) async => null);

    final apiService = ApiService(
      dio: dio,
      secureStorage: secureStorage,
      logger: logger,
    );

    expect(
      () async => apiService.get<Map<String, dynamic>>('/secure'),
      throwsA(
        predicate(
          (error) => error is AuthException && error.message.isNotEmpty,
        ),
      ),
    );
  });

  test(
    '401 con refresh disponible reintenta request y finalmente retorna respuesta',
    () async {
      adapter.handle = (options) {
        if (options.path == '/auth/refresh') {
          return _jsonResponse({'accessToken': 'new-token'}, 200);
        }
        if (options.path == '/secure') {
          if (options.extra['retried'] == true) {
            return _jsonResponse({'payload': 'after-refresh'}, 200);
          }
          return _jsonResponse({'message': 'expired'}, 401);
        }
        throw Exception('Unexpected request ${options.path}');
      };

      when(
        secureStorage.read(key: StorageKeys.accessToken),
      ).thenAnswer((_) async => 'old-token' as String?);
      when(
        secureStorage.read(key: StorageKeys.refreshToken),
      ).thenAnswer((_) async => 'refresh-token' as String?);
      when(
        secureStorage.write(key: StorageKeys.accessToken, value: 'new-token'),
      ).thenAnswer((_) async {});

      final apiService = ApiService(
        dio: dio,
        secureStorage: secureStorage,
        logger: logger,
      );

      final payload = await apiService.get<Map<String, dynamic>>('/secure');

      expect(payload, const {'payload': 'after-refresh'});
      expect(adapter.callCountByPath['/secure'], 2);
      expect(adapter.callCountByPath['/auth/refresh'], 1);
    },
  );
}
