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
      'display_name': '{name} Companero',
      'description':
          'Amigo calido y curioso para conversar, imaginar y aprender juntos',
      'category': 'general',
    },
    {
      'id': 'peruvian',
      'display_name': '{name} Explorador Peruano',
      'description':
          'Aventurero respetuoso que comparte cuentos, juegos y cultura peruana',
      'category': 'culture',
    },
    {
      'id': 'mexican',
      'display_name': '{name} Explorador Mexicano',
      'description':
          'Companero alegre que comparte cuentos, juegos y cultura mexicana',
      'category': 'culture',
    },
    {
      'id': 'kpop',
      'display_name': '{name} Estrella Musical',
      'description':
          'Amigo musical con energia positiva para cantar, bailar y crear',
      'category': 'music',
    },
    {
      'id': 'roblox',
      'display_name': '{name} Constructor Gamer',
      'description':
          'Companero creativo que propone retos, construcciones y juego seguro',
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

      final firstItem = items.first;
      if (firstItem is Map) {
        _logger.d('Personality[0] keys: ${firstItem.keys.toList()}');
      }

      final personalities = <Personality>[];
      for (final item in items) {
        if (item is! Map) {
          _logger.w('Skipping invalid personality item: ${item.runtimeType}');
          continue;
        }

        try {
          final normalized = _normalizePersonalityJson(
            Map<String, dynamic>.from(item),
          );
          if (_nonBlank(normalized['id']?.toString()) == null) {
            _logger.w('Skipping personality without id: $normalized');
            continue;
          }
          personalities.add(Personality.fromJson(normalized));
        } on Exception catch (parseError) {
          _logger.w('Skipping invalid personality payload: $parseError');
        }
      }

      if (personalities.isEmpty) {
        _logger.w('No valid personalities parsed, using fallback');
        return _fallback();
      }

      return personalities;
    } on Exception catch (e) {
      _logger.w('Failed to fetch personalities, using fallback: $e');
      return _fallback();
    }
  }

  List<Object?> _extractItems(Object? response) {
    if (response is List) {
      return response;
    }
    if (response is Map<String, dynamic>) {
      final data =
          response['data'] ??
          response['personalities'] ??
          response['items'] ??
          response['results'];
      if (data is List) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        final nested =
            data['personalities'] ?? data['items'] ?? data['results'];
        if (nested is List) {
          return nested;
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
    normalized['id'] ??= normalized['key'] ?? normalized['slug'];
    normalized['display_name'] ??=
        normalized['name'] ?? normalized['displayName'] ?? normalized['title'];
    normalized['description'] = normalized['description']?.toString() ?? '';
    return normalized;
  }

  String? _nonBlank(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  List<Personality> _fallback() => _fallbackPersonalities
      .map(_normalizePersonalityJson)
      .map(Personality.fromJson)
      .toList();

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
