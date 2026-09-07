import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nebu_mobile_flutter/core/constants/storage_keys.dart';
import 'package:nebu_mobile_flutter/core/errors/app_exception.dart';
import 'package:nebu_mobile_flutter/data/services/api_service.dart';

import 'mocks.dart';

/// All credentials below are synthetic, in-memory test values. No sockets,
/// platform secure storage, Firebase initialization or real account are used.
class _SessionHarness {
  _SessionHarness() {
    for (final key in [StorageKeys.accessToken, StorageKeys.refreshToken]) {
      when(storage.read(key: key)).thenAnswer((_) async => values[key]);
      when(storage.delete(key: key)).thenAnswer((_) async {
        deletedKeys.add(key);
        values.remove(key);
      });
    }
    when(
      storage.write(
        key: StorageKeys.accessToken,
        value: 'synthetic-refreshed-access',
      ),
    ).thenAnswer((_) async {
      values[StorageKeys.accessToken] = 'synthetic-refreshed-access';
    });
    when(
      storage.write(
        key: StorageKeys.refreshToken,
        value: 'synthetic-rotated-refresh',
      ),
    ).thenAnswer((_) async {
      values[StorageKeys.refreshToken] = 'synthetic-rotated-refresh';
    });
    dio = Dio()..httpClientAdapter = adapter;
    service = ApiService(
      dio: dio,
      secureStorage: storage,
      logger: MockLogger(),
      onSessionExpired: () => expiredCalls++,
    );
  }

  final storage = MockFlutterSecureStorage();
  final adapter = _SessionAdapter();
  final values = <String, String>{
    StorageKeys.accessToken: 'synthetic-old-access',
    StorageKeys.refreshToken: 'synthetic-old-refresh',
  };
  final deletedKeys = <String>[];
  int expiredCalls = 0;
  late final Dio dio;
  late final ApiService service;

  Map<String, Object> get sessionState => {
    'expiredCalls': expiredCalls,
    'deletedKeys': deletedKeys,
    'hasRefreshedAccess':
        values[StorageKeys.accessToken] == 'synthetic-refreshed-access',
    'hasRotatedRefresh':
        values[StorageKeys.refreshToken] == 'synthetic-rotated-refresh',
  };
}

class _SessionAdapter implements HttpClientAdapter {
  late FutureOr<ResponseBody> Function(RequestOptions) handle;
  final calls = <String, int>{};
  final authorizationByPath = <String, List<Object?>>{};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.update(options.path, (count) => count + 1, ifAbsent: () => 1);
    authorizationByPath
        .putIfAbsent(options.path, () => [])
        .add(options.headers['Authorization']);
    return handle(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, int status) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

void main() {
  const minimumRelease = bool.fromEnvironment('MINIMAL_IOS_RELEASE');

  for (final retryFailure in ['server500', 'receiveTimeout']) {
    test(
      'successful refresh followed by $retryFailure preserves the session',
      () async {
        final harness = _SessionHarness();
        addTearDown(() => harness.dio.close(force: true));
        harness.adapter.handle = (options) {
          if (options.path == '/auth/refresh') {
            return _json({
              'accessToken': 'synthetic-refreshed-access',
              'refreshToken': 'synthetic-rotated-refresh',
            }, 200);
          }
          if (options.path == '/secure') {
            if (options.extra['retried'] != true) {
              return _json({'message': 'expired'}, 401);
            }
            if (retryFailure == 'receiveTimeout') {
              throw DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
                message: 'Synthetic timeout after successful refresh',
              );
            }
            return _json({'message': 'Synthetic temporary failure'}, 500);
          }
          throw StateError('Unexpected synthetic request: ${options.path}');
        };

        await expectLater(
          harness.service.get<Map<String, dynamic>>('/secure'),
          throwsA(isA<AppException>()),
        );

        expect(harness.adapter.calls['/auth/refresh'], 1);
        expect(harness.adapter.calls['/secure'], 2);
        expect(harness.adapter.authorizationByPath['/auth/refresh'], [null]);
        expect(
          harness.adapter.authorizationByPath['/secure']!.last,
          'Bearer synthetic-refreshed-access',
        );
        expect(harness.sessionState, {
          'expiredCalls': 0,
          'deletedKeys': <String>[],
          'hasRefreshedAccess': true,
          'hasRotatedRefresh': true,
        });
      },
      skip: minimumRelease,
    );
  }

  test(
    '401 from refresh completes with auth failure instead of awaiting itself',
    () async {
      final harness = _SessionHarness();
      addTearDown(() => harness.dio.close(force: true));
      harness.adapter.handle = (options) {
        if (options.path == '/auth/refresh' || options.path == '/secure') {
          return _json({'message': 'Synthetic auth rejection'}, 401);
        }
        throw StateError('Unexpected synthetic request: ${options.path}');
      };

      await expectLater(
        harness.service
            .get<Map<String, dynamic>>('/secure')
            .timeout(const Duration(milliseconds: 500)),
        throwsA(isA<AuthException>()),
      );
      expect(harness.adapter.calls['/auth/refresh'], 1);
    },
    skip: minimumRelease,
  );

  for (final failure in ['server500', 'receiveTimeout']) {
    test(
      'transient refresh $failure preserves credentials and can recover',
      () async {
        final harness = _SessionHarness();
        addTearDown(() => harness.dio.close(force: true));
        var recover = false;
        harness.adapter.handle = (options) {
          if (options.path == '/auth/refresh') {
            if (recover) {
              return _json({
                'accessToken': 'synthetic-refreshed-access',
                'refreshToken': 'synthetic-rotated-refresh',
              }, 200);
            }
            if (failure == 'receiveTimeout') {
              throw DioException(
                requestOptions: options,
                type: DioExceptionType.receiveTimeout,
              );
            }
            return _json({'message': 'Synthetic outage'}, 500);
          }
          return _json({}, options.extra['retried'] == true ? 200 : 401);
        };

        await expectLater(
          harness.service.get<Map<String, dynamic>>('/secure'),
          throwsA(
            failure == 'receiveTimeout'
                ? isA<NetworkException>()
                : isA<ServerException>(),
          ),
        );
        expect(harness.expiredCalls, 0);
        expect(harness.deletedKeys, isEmpty);
        expect(harness.values, {
          StorageKeys.accessToken: 'synthetic-old-access',
          StorageKeys.refreshToken: 'synthetic-old-refresh',
        });
        expect(harness.adapter.authorizationByPath['/auth/refresh'], [null]);

        recover = true;
        expect(
          await harness.service.get<Map<String, dynamic>>('/secure'),
          isEmpty,
        );
        expect(harness.adapter.calls['/auth/refresh'], 2);
        expect(harness.expiredCalls, 0);
        expect(harness.deletedKeys, isEmpty);
      },
      skip: minimumRelease,
    );
  }

  for (final refreshStatus in [200, 401, 403]) {
    test(
      'concurrent 401s share delayed storage and refresh $refreshStatus once',
      () async {
        final harness = _SessionHarness();
        addTearDown(() => harness.dio.close(force: true));
        final storageStarted = Completer<void>();
        final storageGate = Completer<void>();
        when(harness.storage.read(key: StorageKeys.refreshToken)).thenAnswer((
          _,
        ) async {
          if (!storageStarted.isCompleted) {
            storageStarted.complete();
          }
          await storageGate.future;
          return harness.values[StorageKeys.refreshToken];
        });
        harness.adapter.handle = (options) {
          if (options.path == '/auth/refresh') {
            return _json(
              refreshStatus == 200
                  ? {
                      'accessToken': 'synthetic-refreshed-access',
                      'refreshToken': 'synthetic-rotated-refresh',
                    }
                  : {'message': 'Synthetic auth rejection'},
              refreshStatus,
            );
          }
          return _json({}, options.extra['retried'] == true ? 200 : 401);
        };
        final requests = [
          for (final path in ['/first', '/second', '/third'])
            expectLater(
              harness.service.get<Map<String, dynamic>>(path),
              refreshStatus == 200
                  ? completion(isEmpty)
                  : throwsA(isA<AuthException>()),
            ),
        ];
        await storageStarted.future.timeout(const Duration(seconds: 1));
        await pumpEventQueue();
        storageGate.complete();
        await Future.wait(requests).timeout(const Duration(seconds: 1));

        expect(harness.adapter.calls['/auth/refresh'], 1);
        expect(harness.adapter.authorizationByPath['/auth/refresh'], [null]);
        expect(harness.expiredCalls, refreshStatus == 200 ? 0 : 1);
        expect(
          harness.deletedKeys,
          refreshStatus == 200
              ? <String>[]
              : [StorageKeys.accessToken, StorageKeys.refreshToken],
        );
        if (refreshStatus == 200) {
          for (final path in ['/first', '/second', '/third']) {
            expect(
              harness.adapter.authorizationByPath[path]!.last,
              'Bearer synthetic-refreshed-access',
            );
          }
        }
      },
      skip: minimumRelease,
    );
  }

  test(
    'late 401 reuses the known rotation without a second refresh',
    () async {
      final harness = _SessionHarness();
      addTearDown(() => harness.dio.close(force: true));
      final lateStarted = Completer<void>();
      final lateResponse = Completer<void>();
      harness.adapter.handle = (options) async {
        if (options.path == '/auth/refresh') {
          return _json({
            'accessToken': 'synthetic-refreshed-access',
            'refreshToken': 'synthetic-rotated-refresh',
          }, 200);
        }
        if (options.path == '/late' && options.extra['retried'] != true) {
          lateStarted.complete();
          await lateResponse.future;
        }
        return _json({}, options.extra['retried'] == true ? 200 : 401);
      };
      final first = harness.service.get<Map<String, dynamic>>('/first');
      final late = harness.service.get<Map<String, dynamic>>('/late');
      await lateStarted.future.timeout(const Duration(seconds: 1));
      await first;
      lateResponse.complete();
      await late.timeout(const Duration(seconds: 1));
      expect(harness.adapter.calls['/auth/refresh'], 1);
      expect(harness.adapter.authorizationByPath['/late'], [
        'Bearer synthetic-old-access',
        'Bearer synthetic-refreshed-access',
      ]);
      expect(harness.expiredCalls, 0);
    },
    skip: minimumRelease,
  );

  for (final refreshStatus in [200, 401, 403]) {
    for (final changedRefresh in [false, true]) {
      test(
        'stale refresh $refreshStatus does not replace or clear a newer login '
        '(refresh changed: $changedRefresh)',
        () async {
          final harness = _SessionHarness();
          addTearDown(() => harness.dio.close(force: true));
          final started = Completer<void>();
          final responseGate = Completer<void>();
          harness.adapter.handle = (options) async {
            if (options.path == '/auth/refresh') {
              started.complete();
              await responseGate.future;
              return _json(
                refreshStatus == 200
                    ? {
                        'accessToken': 'synthetic-refreshed-access',
                        'refreshToken': 'synthetic-rotated-refresh',
                      }
                    : {'message': 'Synthetic old-session rejection'},
                refreshStatus,
              );
            }
            return _json({}, 401);
          };
          final request = expectLater(
            harness.service.get<Map<String, dynamic>>('/secure'),
            throwsA(isA<AuthException>()),
          );
          await started.future.timeout(const Duration(seconds: 1));
          harness.values[StorageKeys.accessToken] =
              'synthetic-new-login-access';
          if (changedRefresh) {
            harness.values[StorageKeys.refreshToken] =
                'synthetic-new-login-refresh';
          }
          final expected = Map<String, String>.of(harness.values);
          responseGate.complete();
          await request.timeout(const Duration(seconds: 1));
          expect(harness.values, expected);
          expect(harness.expiredCalls, 0);
          expect(harness.deletedKeys, isEmpty);
        },
        skip: minimumRelease,
      );
    }
  }

  for (final malformed in <Map<String, Object?>>[
    {},
    {'accessToken': ''},
    {'accessToken': 42},
    {'accessToken': 'synthetic-refreshed-access', 'refreshToken': 42},
  ]) {
    test(
      'malformed refresh $malformed preserves all credentials',
      () async {
        final harness = _SessionHarness();
        addTearDown(() => harness.dio.close(force: true));
        harness.adapter.handle = (options) => options.path == '/auth/refresh'
            ? _json(malformed, 200)
            : _json({}, 401);
        await expectLater(
          harness.service.get<Map<String, dynamic>>('/secure'),
          throwsA(
            isA<ServerException>().having((e) => e.statusCode, 'status', 502),
          ),
        );
        expect(harness.values, {
          StorageKeys.accessToken: 'synthetic-old-access',
          StorageKeys.refreshToken: 'synthetic-old-refresh',
        });
        expect(harness.expiredCalls, 0);
        expect(harness.deletedKeys, isEmpty);
      },
      skip: minimumRelease,
    );
  }

  test(
    'old account 401 cannot join a different account refresh',
    () async {
      final harness = _SessionHarness();
      addTearDown(() => harness.dio.close(force: true));
      final oldStarted = Completer<void>();
      final oldResponse = Completer<void>();
      final newRefreshStarted = Completer<void>();
      final newRefreshResponse = Completer<void>();
      harness.adapter.handle = (options) async {
        if (options.path == '/old-account') {
          oldStarted.complete();
          await oldResponse.future;
          return _json({}, 401);
        }
        if (options.path == '/auth/refresh') {
          newRefreshStarted.complete();
          await newRefreshResponse.future;
          return _json({
            'accessToken': 'synthetic-refreshed-access',
            'refreshToken': 'synthetic-rotated-refresh',
          }, 200);
        }
        return _json({}, options.extra['retried'] == true ? 200 : 401);
      };
      final oldRequest = expectLater(
        harness.service.get<Map<String, dynamic>>('/old-account'),
        throwsA(isA<AuthException>()),
      );
      await oldStarted.future.timeout(const Duration(seconds: 1));
      harness.values[StorageKeys.accessToken] = 'synthetic-new-login-access';
      harness.values[StorageKeys.refreshToken] = 'synthetic-new-login-refresh';
      final newRequest = harness.service.get<Map<String, dynamic>>(
        '/new-account',
      );
      await newRefreshStarted.future.timeout(const Duration(seconds: 1));
      oldResponse.complete();
      await oldRequest.timeout(const Duration(seconds: 1));
      newRefreshResponse.complete();
      await newRequest.timeout(const Duration(seconds: 1));
      expect(harness.adapter.calls['/old-account'], 1);
      expect(harness.adapter.authorizationByPath['/old-account'], [
        'Bearer synthetic-old-access',
      ]);
      expect(harness.adapter.calls['/auth/refresh'], 1);
      expect(harness.expiredCalls, 0);
      expect(harness.deletedKeys, isEmpty);
    },
    skip: minimumRelease,
  );

  test(
    'login change before retry cancels without sending under the new account',
    () async {
      final harness = _SessionHarness();
      addTearDown(() => harness.dio.close(force: true));
      when(harness.storage.read(key: StorageKeys.accessToken)).thenAnswer((
        _,
      ) async {
        if (harness.values[StorageKeys.accessToken] ==
            'synthetic-refreshed-access') {
          // Simulate login completing immediately before the retry interceptor.
          harness.values[StorageKeys.accessToken] =
              'synthetic-new-login-access';
          harness.values[StorageKeys.refreshToken] =
              'synthetic-new-login-refresh';
        }
        return harness.values[StorageKeys.accessToken];
      });
      harness.adapter.handle = (options) => options.path == '/auth/refresh'
          ? _json({
              'accessToken': 'synthetic-refreshed-access',
              'refreshToken': 'synthetic-rotated-refresh',
            }, 200)
          : _json({}, options.extra['retried'] == true ? 200 : 401);
      await expectLater(
        harness.service.get<Map<String, dynamic>>('/secure'),
        throwsA(isA<AuthException>()),
      );
      expect(harness.adapter.calls['/secure'], 1);
      expect(harness.adapter.calls['/auth/refresh'], 1);
      expect(harness.values, {
        StorageKeys.accessToken: 'synthetic-new-login-access',
        StorageKeys.refreshToken: 'synthetic-new-login-refresh',
      });
      expect(harness.expiredCalls, 0);
      expect(harness.deletedKeys, isEmpty);
    },
    skip: minimumRelease,
  );
}
