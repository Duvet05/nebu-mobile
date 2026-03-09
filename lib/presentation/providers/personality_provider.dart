import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/personality.dart';
import '../../data/services/personality_service.dart';
import 'api_provider.dart';

final personalityServiceProvider = Provider<PersonalityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return PersonalityService(apiService: apiService, logger: logger);
});

/// Personalities — endpoint is public, no auth required.
final personalitiesProvider = FutureProvider<List<Personality>>((ref) async {
  final service = ref.watch(personalityServiceProvider);
  return service.getPersonalities();
});
