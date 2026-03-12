import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../models/personality.dart';
import 'api_service.dart';

class PersonalityService {
  PersonalityService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  Future<List<Personality>> getPersonalities() async {
    _logger.d('Fetching personalities');
    final response = await _apiService.get<dynamic>('/agent/personalities');

    List<dynamic> items;
    if (response is List) {
      items = response;
    } else if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['personalities'];
      if (data is List) {
        items = data;
      } else {
        _logger.e(
          'getPersonalities: unexpected response shape: ${response.runtimeType}',
        );
        throw const ServerException(
          'Unexpected response format from /agent/personalities',
          statusCode: 500,
        );
      }
    } else {
      _logger.e(
        'getPersonalities: unexpected response shape: ${response.runtimeType}',
      );
      throw const ServerException(
        'Unexpected response format from /agent/personalities',
        statusCode: 500,
      );
    }

    if (items.isNotEmpty) {
      _logger.d('Personality[0] keys: ${(items.first as Map).keys.toList()}');
    }

    return items
        .cast<Map<String, dynamic>>()
        .map(Personality.fromJson)
        .toList();

  }

  Future<void> assignPersonalityToToy({
    required String toyId,
    required String personalityId,
  }) async {
    _logger.d('Assigning personality $personalityId to toy $toyId');
    await _apiService.patch<dynamic>(
      '/toys/$toyId',
      data: {'personalityProfile': personalityId},
    );
  }
}
