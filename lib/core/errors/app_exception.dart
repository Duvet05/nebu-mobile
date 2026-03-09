/// Typed exceptions for the app.
/// Use these instead of generic `Exception('message')` to enable
/// type-based error handling in providers and UI.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Network-level errors: no connection, timeout, DNS failure.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

/// 401/403 — authentication or authorization failure.
class AuthException extends AppException {
  const AuthException(super.message, {super.statusCode});
}

/// 404 — requested resource does not exist.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode});
}

/// 409 — conflict (duplicate, already assigned, etc.)
class ConflictException extends AppException {
  const ConflictException(super.message, {super.statusCode});
}

/// 422 — validation error from backend.
class ValidationException extends AppException {
  const ValidationException(super.message, {this.fields, super.statusCode});

  /// Optional map of field-level errors, e.g. {'email': 'already exists'}.
  final Map<String, String>? fields;
}

/// 429 — rate limited.
class RateLimitException extends AppException {
  const RateLimitException(super.message, {this.retryAfter, super.statusCode});

  /// Seconds until the client can retry, if provided by backend.
  final int? retryAfter;
}

/// 5xx — server-side error.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}
