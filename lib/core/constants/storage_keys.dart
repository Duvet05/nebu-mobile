class StorageKeys {
  StorageKeys._();

  // Secure Storage
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String user = 'user';

  // SharedPreferences
  static const String language = 'language';
  static const String themeMode = 'theme_mode';
  static const String currentDeviceId = 'current_device_id';

  // Setup Wizard
  static const String setupLanguage = 'setup_language';
  static const String setupTheme = 'setup_theme';
  static const String setupNotifications = 'setup_notifications';
  static const String setupVoice = 'setup_voice';
  static const String setupHapticFeedback = 'setup_haptic_feedback';
  static const String setupAutoSave = 'setup_auto_save';
  static const String setupAnalytics = 'setup_analytics';
  static const String setupCompleted = 'setup_completed';
  static const String setupToyName = 'setup_toy_name';
  static const String setupCompletedLocally = 'setup_completed_locally';

  // Local Child Data
  static const String localChildName = 'local_child_name';
  static const String localChildAge = 'local_child_age';
  static const String localChildPersonality = 'local_child_personality';
  static const String localCustomPrompt = 'local_custom_prompt';

  // Setup Personality
  static const String setupPersonalityId = 'setup_personality_id';

  // Local Toys
  static const String localToys = 'local_toys';
  static const String setupDeviceRegistered = 'setup_device_registered';

  // Avatar
  static const String localAvatar = 'local_avatar_path';

  // Activity Migration
  static const String localUserId = 'local_user_id';
  static const String activitiesMigrated = 'activities_migrated';

  // Personality Cache
  static const String personalitiesCache = 'personalities_cache';
  static const String personalitiesCacheTs = 'personalities_cache_ts';

  // Voice Metrics Cache
  static const String voiceMetricsCache = 'voice_metrics_cache';
  static const String voiceMetricsCacheTs = 'voice_metrics_cache_ts';

  // Voice Sessions Cache
  static const String voiceSessionsCache = 'voice_sessions_cache';
  static const String voiceSessionsCacheTs = 'voice_sessions_cache_ts';

  // User Limits Cache
  static const String userLimitsCache = 'user_limits_cache';
  static const String userLimitsCacheTs = 'user_limits_cache_ts';
}
