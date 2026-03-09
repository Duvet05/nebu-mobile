import 'package:logger/logger.dart';

import '../models/user_setup.dart';
import 'api_service.dart';

class UserSetupService {
  UserSetupService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Save complete setup configuration
  Future<SetupResponse> saveSetup({
    required String userId,
    required UserProfile profile,
    required UserPreferences preferences,
    required NotificationSettings notifications,
    required VoiceSettings voice,
  }) async {
    _logger.d('Saving setup for user: $userId');

    final response = await _apiService.post<Map<String, dynamic>>(
      '/users/$userId/setup',
      data: {
        'profile': profile.toJson(),
        'preferences': preferences.toJson(),
        'notifications': notifications.toJson(),
        'voice': voice.toJson(),
      },
    );

    _logger.d('Setup saved successfully');
    return SetupResponse.fromJson(response);
  }

  /// Get setup configuration
  Future<UserSetup> getSetup(String userId) async {
    _logger.d('Fetching setup for user: $userId');

    final response = await _apiService.get<Map<String, dynamic>>(
      '/users/$userId/setup',
    );

    _logger.d('Setup fetched successfully');
    return UserSetup.fromJson(response);
  }

  /// Update user preferences
  Future<void> updatePreferences({
    required String userId,
    String? language,
    String? theme,
    bool? hapticFeedback,
    bool? autoSave,
    bool? analytics,
  }) async {
    _logger.d('Updating preferences for user: $userId');

    await _apiService.patch<Map<String, dynamic>>(
      '/users/$userId/preferences',
      data: {
        ?'language': language,
        ?'theme': theme,
        ?'hapticFeedback': hapticFeedback,
        ?'autoSave': autoSave,
        ?'analytics': analytics,
      },
    );

    _logger.d('Preferences updated successfully');
  }
}
