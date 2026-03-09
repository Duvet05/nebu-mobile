import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/personality.dart';
import '../../data/services/personality_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final personalityServiceProvider = Provider<PersonalityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return PersonalityService(apiService: apiService, logger: logger);
});

final personalitiesProvider = FutureProvider<List<Personality>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    return [];
  }
  final service = ref.watch(personalityServiceProvider);
  return service.getPersonalities();
});
