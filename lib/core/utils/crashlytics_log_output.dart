import 'dart:async';

import 'package:logger/logger.dart';

import 'error_reporting_service.dart';

class CrashlyticsLogOutput extends LogOutput {
  CrashlyticsLogOutput() : _console = ConsoleOutput();

  final LogOutput _console;

  @override
  void output(OutputEvent event) {
    _console.output(event);

    if (event.level != Level.error && event.level != Level.fatal) {
      return;
    }

    final logEvent = event.origin;
    if (logEvent.error == null) {
      return;
    }

    unawaited(
      ErrorReportingService.recordError(
        logEvent.error!,
        logEvent.stackTrace,
        reason: event.lines.join('\n'),
        context: {
          'logger_level': event.level.toString(),
          'message': logEvent.message.toString(),
          'error_type': logEvent.error.runtimeType.toString(),
        },
      ),
    );
  }
}
