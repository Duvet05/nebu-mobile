import 'package:dio/dio.dart';
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

  static const List<Map<String, dynamic>> _fallbackPersonalities = [
    {
      'id': 'neutral',
      'display_name': '{name} Estandar',
      'description':
          'Companero empatico y carismatico para aprender cosas increibles',
      'category': 'general',
    },
    {
      'id': 'peruvian',
      'display_name': '{name} Etnocacerista',
      'description':
          'Patriota andino cosmico que cree que los incas inventaron todo',
      'category': 'culture',
    },
    {
      'id': 'mexican',
      'display_name': '{name} Azteca',
      'description':
          'Peluche mexicano orgulloso que cree que los aztecas y mayas inventaron todo',
      'category': 'culture',
    },
    {
      'id': 'kpop',
      'display_name': '{name} K-pop Warrior',
      'description':
          'Peluche fan del K-pop que mezcla datos curiosos con energia de idol coreano',
      'category': 'music',
    },
    {
      'id': 'roblox',
      'display_name': '{name} Gamer',
      'description':
          'Peluche gamer que habla en jerga de Roblox y cultura gaming para ninos',
      'category': 'gaming',
    },
  ];

  Future<List<Personality>> getPersonalities() async {
    _logger.d('Fetching personalities');
    try {
      final response = await _apiService.get<dynamic>(
        '/agent/personalities',
        options: Options(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          sendTimeout: const Duration(seconds: 6),
        ),
      );

      final items = _extractItems(response);
      if (items.isEmpty) {
        _logger.w('No personalities returned by API, using fallback');
        return _fallback();
      }

      _logger.d('Personality[0] keys: ${(items.first as Map).keys.toList()}');

      return items
          .cast<Map<String, dynamic>>()
          .map(_normalizePersonalityJson)
          .map(Personality.fromJson)
          .toList();
    } on Exception catch (e) {
      _logger.w('Failed to fetch personalities, using fallback: $e');
      return _fallback();
    }
  }

  List<dynamic> _extractItems(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response['personalities'];
      if (data is List) {
        return data;
      } else {
        _logger.e(
          'getPersonalities: unexpected response shape: ${response.runtimeType}',
        );
        throw const ServerException(
          'Unexpected response format from /agent/personalities',
          statusCode: 500,
        );
      }
    }

    _logger.e(
      'getPersonalities: unexpected response shape: ${response.runtimeType}',
    );
    throw const ServerException(
      'Unexpected response format from /agent/personalities',
      statusCode: 500,
    );
  }

  Map<String, dynamic> _normalizePersonalityJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['display_name'] ??= normalized['name'];
    normalized['description'] ??= '';
    return normalized;
  }

  List<Personality> _fallback() {
    return _fallbackPersonalities
        .map(_normalizePersonalityJson)
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
