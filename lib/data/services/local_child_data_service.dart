import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

/// Service for managing locally stored child information
/// This is used when the user configures the app without connecting a device
class LocalChildDataService {
  LocalChildDataService(this._prefs, {String? userId}) : _userId = userId;

  final SharedPreferences _prefs;
  final String? _userId;

  String _key(String base) =>
      _userId == null ? base : StorageKeys.scoped(base, _userId);

  /// Save child information
  Future<void> saveChildInfo({
    required String name,
    required String age,
    required String personality,
    String? customPrompt,
  }) async {
    await _prefs.setString(_key(StorageKeys.localChildName), name);
    await _prefs.setString(_key(StorageKeys.localChildAge), age);
    await _prefs.setString(
      _key(StorageKeys.localChildPersonality),
      personality,
    );

    if (customPrompt != null && customPrompt.isNotEmpty) {
      await _prefs.setString(_key(StorageKeys.localCustomPrompt), customPrompt);
    } else {
      await _prefs.remove(_key(StorageKeys.localCustomPrompt));
    }

    await _prefs.setBool(_key(StorageKeys.setupCompletedLocally), true);
  }

  /// Get child name
  String? getChildName() => _prefs.getString(_key(StorageKeys.localChildName));

  /// Get child age group
  String? getChildAge() => _prefs.getString(_key(StorageKeys.localChildAge));

  /// Get child personality preference
  String? getChildPersonality() =>
      _prefs.getString(_key(StorageKeys.localChildPersonality));

  /// Get custom prompt
  String? getCustomPrompt() =>
      _prefs.getString(_key(StorageKeys.localCustomPrompt));

  /// Check if local setup was completed
  bool isSetupCompleted() =>
      _prefs.getBool(_key(StorageKeys.setupCompletedLocally)) ?? false;

  /// Get all child data as a map
  Map<String, String?> getChildData() => {
    'name': getChildName(),
    'age': getChildAge(),
    'personality': getChildPersonality(),
    'customPrompt': getCustomPrompt(),
  };

  /// Check if child data exists
  bool hasChildData() =>
      getChildName() != null &&
      getChildAge() != null &&
      getChildPersonality() != null;

  /// Generate a system prompt based on stored child data
  String generateSystemPrompt() {
    if (!hasChildData()) {
      return _getDefaultPrompt();
    }

    final customPrompt = getCustomPrompt();
    if (customPrompt != null && customPrompt.isNotEmpty) {
      return customPrompt;
    }

    return _generatePromptFromData();
  }

  String _generatePromptFromData() {
    final name = getChildName() ?? 'the child';
    final age = getChildAge() ?? 'young';
    final personality = getChildPersonality() ?? 'friendly';

    final personalityLabels = {
      'friendly': 'Friendly & Cheerful',
      'curious': 'Curious & Adventurous',
      'calm': 'Calm & Patient',
      'energetic': 'Energetic & Playful',
      'creative': 'Creative & Imaginative',
    };

    final personalityLabel = personalityLabels[personality] ?? personality;

    return '''
You are Nebu, a friendly AI companion for children.

Child Information:
- Name: $name
- Age Group: $age years old
- Personality Preference: $personalityLabel

Your role:
- Be supportive, encouraging, and age-appropriate
- Help with learning and creativity
- Answer questions in a simple, understandable way
- Keep conversations fun and engaging
- Ensure safety and provide positive guidance

Communication style:
- Use simple, clear language suitable for a $age year old
- Be $personalityLabel in your interactions
- Encourage curiosity and learning
- Always maintain a positive, supportive tone
- Address the child as $name when appropriate''';
  }

  String _getDefaultPrompt() => '''
You are Nebu, a friendly AI companion for children.

Your role:
- Be supportive, encouraging, and age-appropriate
- Help with learning and creativity
- Answer questions in a simple, understandable way
- Keep conversations fun and engaging
- Ensure safety and provide positive guidance

Communication style:
- Use simple, clear language
- Be friendly and cheerful
- Encourage curiosity and learning
- Always maintain a positive, supportive tone''';

  /// Clear all local child data
  Future<void> clearChildData() async {
    await _prefs.remove(_key(StorageKeys.localChildName));
    await _prefs.remove(_key(StorageKeys.localChildAge));
    await _prefs.remove(_key(StorageKeys.localChildPersonality));
    await _prefs.remove(_key(StorageKeys.localCustomPrompt));
    await _prefs.remove(_key(StorageKeys.setupCompletedLocally));
  }

  /// Update child name only
  Future<void> updateChildName(String name) async {
    await _prefs.setString(_key(StorageKeys.localChildName), name);
  }

  /// Update child age only
  Future<void> updateChildAge(String age) async {
    await _prefs.setString(_key(StorageKeys.localChildAge), age);
  }

  /// Update personality only
  Future<void> updateChildPersonality(String personality) async {
    await _prefs.setString(
      _key(StorageKeys.localChildPersonality),
      personality,
    );
  }

  /// Update custom prompt only
  Future<void> updateCustomPrompt(String? prompt) async {
    if (prompt != null && prompt.isNotEmpty) {
      await _prefs.setString(_key(StorageKeys.localCustomPrompt), prompt);
    } else {
      await _prefs.remove(_key(StorageKeys.localCustomPrompt));
    }
  }

  /// Export child data as JSON-compatible map
  Map<String, dynamic> exportData() => {
    'childName': getChildName(),
    'childAge': getChildAge(),
    'childPersonality': getChildPersonality(),
    'customPrompt': getCustomPrompt(),
    'systemPrompt': generateSystemPrompt(),
    'setupCompleted': isSetupCompleted(),
  };
}
