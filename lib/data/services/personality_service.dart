import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/personality.dart';
import 'api_service.dart';

class PersonalityService {
  PersonalityService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  Future<List<Personality>> getPersonalities() async {
    try {
      _logger.d('Fetching personalities');
      final response = await _apiService.get<dynamic>('/agent/personalities');

      if (response is List) {
        return response
            .cast<Map<String, dynamic>>()
            .map(Personality.fromJson)
            .toList();
      }

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response['personalities'];
        if (data is List) {
          return data
              .cast<Map<String, dynamic>>()
              .map(Personality.fromJson)
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching personalities: ${e.message}');
      rethrow;
    }
  }

  Future<Personality?> getPersonality(String id) async {
    try {
      _logger.d('Fetching personality: $id');
      final response = await _apiService
          .get<Map<String, dynamic>>('/agent/personalities/$id');
      return Personality.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching personality: ${e.message}');
      return null;
    }
  }

  Future<void> assignPersonalityToToy({
    required String toyId,
    required String personalityId,
  }) async {
    try {
      _logger.d('Assigning personality $personalityId to toy $toyId');
      await _apiService.patch<dynamic>(
        '/toys/$toyId',
        data: {'personalityId': personalityId},
      );
    } on DioException catch (e) {
      _logger.e('Error assigning personality: ${e.message}');
      rethrow;
    }
  }
}
