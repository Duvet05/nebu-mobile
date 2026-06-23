import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nebu_mobile_flutter/core/utils/error_reporting_service.dart';

void main() {
  test(
    'initialize no habilita crash reporting en entornos debug de pruebas',
    () async {
      await ErrorReportingService.initialize();

      expect(ErrorReportingService.isEnabled, isFalse);
    },
  );

  test(
    'recordError no lanza si colección de crash reporting está deshabilitada',
    () async {
      await ErrorReportingService.recordError(
        Exception('test error'),
        StackTrace.current,
        reason: 'unit test',
        context: {'feature': 'unit-test'},
      );

      expect(ErrorReportingService.isEnabled, isFalse);
    },
  );

  test(
    'installGlobalErrorHandlers mantiene handlers previos y es idempotente',
    () async {
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;

      var wasPreviousFlutterCalled = false;
      var wasPreviousPlatformCalled = false;

      FlutterError.onError = (details) {
        wasPreviousFlutterCalled = true;
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        wasPreviousPlatformCalled = true;
        return false;
      };

      try {
        ErrorReportingService.installGlobalErrorHandlers();
        final currentFlutter = FlutterError.onError;
        final currentPlatform = PlatformDispatcher.instance.onError;

        expect(currentFlutter, isNotNull);
        expect(currentPlatform, isNotNull);

        currentFlutter?.call(
          FlutterErrorDetails(exception: Exception('service')),
        );
        expect(wasPreviousFlutterCalled, isTrue);

        currentPlatform?.call(Exception('platform'), StackTrace.current);
        expect(wasPreviousPlatformCalled, isTrue);

        ErrorReportingService.installGlobalErrorHandlers();
        expect(FlutterError.onError, same(currentFlutter));
      } finally {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
      }
    },
  );
}
