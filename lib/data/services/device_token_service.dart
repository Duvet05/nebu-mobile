import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import 'api_service.dart';

/// Device token request payload
class DeviceTokenRequest {
  const DeviceTokenRequest({required this.deviceId});
  final String deviceId;

  Map<String, dynamic> toJson() => {'deviceId': deviceId};
}

/// Device token response from backend
class DeviceTokenResponse {
  const DeviceTokenResponse({
    required this.accessToken,
    required this.roomName,
    required this.expiresIn,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      DeviceTokenResponse(
        accessToken: json['access_token'] as String,
        roomName: json['room_name'] as String,
        expiresIn: json['expires_in'] as int,
      );
  final String accessToken;
  final String roomName;
  final int expiresIn;
}

/// Device token service — uses ApiService for auth-aware requests.
class DeviceTokenService {
  DeviceTokenService({required Logger logger, required ApiService apiService})
    : _logger = logger,
      _apiService = apiService;
  final Logger _logger;
  final ApiService _apiService;

  static const String _baseEndpoint = '/livekit/iot/token';
  static final RegExp _deviceIdFormat = RegExp(r'^[A-Za-z0-9_-]{6,32}$');
  static const int _cacheBufferSeconds = 300; // 5 min before expiry

  // Token cache
  final Map<String, DeviceTokenResponse> _tokenCache = {};
  final Map<String, DateTime> _tokenExpiry = {};

  /// Request a LiveKit token for an IoT device.
  Future<DeviceTokenResponse> requestDeviceToken(String deviceId) async {
    _logger.d('Requesting device token for: $deviceId');

    if (!_deviceIdFormat.hasMatch(deviceId)) {
      throw const ValidationException(
        'Invalid device ID format',
        statusCode: 422,
      );
    }

    // Return cached token if still valid
    if (_isTokenValid(deviceId)) {
      _logger.d('Using cached token for device: $deviceId');
      return _tokenCache[deviceId]!;
    }

    final response = await _apiService.post<Map<String, dynamic>>(
      _baseEndpoint,
      data: DeviceTokenRequest(deviceId: deviceId).toJson(),
    );

    final tokenResponse = DeviceTokenResponse.fromJson(response);

    // Cache with buffer before expiry (floor at 0 to prevent negative Duration)
    _tokenCache[deviceId] = tokenResponse;
    final cacheSeconds = (tokenResponse.expiresIn - _cacheBufferSeconds)
        .clamp(0, tokenResponse.expiresIn);
    _tokenExpiry[deviceId] = DateTime.now().add(
      Duration(seconds: cacheSeconds),
    );

    _logger.d('Device token obtained for: $deviceId');
    return tokenResponse;
  }

  /// Get a valid token (cached or fresh).
  Future<DeviceTokenResponse> getValidToken(String deviceId) async {
    if (_isTokenValid(deviceId)) {
      return _tokenCache[deviceId]!;
    }
    return requestDeviceToken(deviceId);
  }

  /// Revoke a device token.
  /// Throws [AppException] on failure so callers can distinguish error types.
  Future<bool> revokeDeviceToken(String deviceId) async {
    _logger.d('Revoking device token for: $deviceId');
    await _apiService.delete<void>('$_baseEndpoint/$deviceId');
    _removeFromCache(deviceId);
    _logger.d('Device token revoked for: $deviceId');
    return true;
  }

  /// Verify token status with backend.
  /// Throws [AppException] on failure so callers can distinguish error types.
  Future<bool> verifyTokenStatus(String deviceId) async {
    _logger.d('Verifying token status for: $deviceId');
    final response = await _apiService.get<Map<String, dynamic>>(
      '$_baseEndpoint/$deviceId/status',
    );

    final isValid = response['valid'] as bool? ?? false;
    if (!isValid) {
      _removeFromCache(deviceId);
    }

    _logger.d('Token status for $deviceId: ${isValid ? 'valid' : 'invalid'}');
    return isValid;
  }

  /// Clear expired tokens from cache.
  void clearExpiredTokens() {
    final now = DateTime.now();
    final expired = _tokenExpiry.entries
        .where((e) => now.isAfter(e.value))
        .map((e) => e.key)
        .toList();

    for (final deviceId in expired) {
      _removeFromCache(deviceId);
    }

    if (expired.isNotEmpty) {
      _logger.d('Cleared ${expired.length} expired tokens');
    }
  }

  /// Clear all cached tokens.
  void clearTokenCache() {
    _tokenCache.clear();
    _tokenExpiry.clear();
  }

  /// Get cached token if valid.
  DeviceTokenResponse? getCachedToken(String deviceId) =>
      _isTokenValid(deviceId) ? _tokenCache[deviceId] : null;

  /// Get remaining time for a cached token.
  Duration? getTokenTimeRemaining(String deviceId) {
    final expiry = _tokenExpiry[deviceId];
    if (expiry == null) {
      return null;
    }
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  bool _isTokenValid(String deviceId) {
    final expiry = _tokenExpiry[deviceId];
    return expiry != null &&
        _tokenCache.containsKey(deviceId) &&
        DateTime.now().isBefore(expiry);
  }

  void _removeFromCache(String deviceId) {
    _tokenCache.remove(deviceId);
    _tokenExpiry.remove(deviceId);
  }

  Future<void> dispose() async {
    clearTokenCache();
  }
}
