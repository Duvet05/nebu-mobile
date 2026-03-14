import 'package:logger/logger.dart';

import '../../core/errors/app_exception.dart';
import '../models/person.dart';
import 'api_service.dart';

class PersonService {
  PersonService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Extracts givenName/familyName from names[] into flat fields
  /// so Person.fromJson() can parse them.
  static Map<String, dynamic> _normalizePersonJson(Map<String, dynamic> json) {
    final names = json['names'] as List<dynamic>?;
    if (names == null || names.isEmpty) {
      return json;
    }
    final preferred =
        names.firstWhere(
              (n) => (n as Map<String, dynamic>)['preferred'] == true,
              orElse: () => names.first,
            )
            as Map<String, dynamic>;
    return {
      ...json,
      'givenName': json['givenName'] ?? preferred['givenName'],
      'familyName': json['familyName'] ?? preferred['familyName'],
    };
  }

  /// Create a new person (child)
  Future<Person> createPerson({
    String? givenName,
    String? familyName,
    String? gender,
    DateTime? birthDate,
  }) async {
    _logger.d('Creating person');
    final response = await _apiService.post<Map<String, dynamic>>(
      '/persons/me',
      data: {
        'givenName': ?givenName,
        'familyName': ?familyName,
        'gender': ?gender,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      },
    );
    _logger.d('Person created: ${response['id']}');
    return Person.fromJson(_normalizePersonJson(response));
  }

  /// Get a person by ID
  Future<Person> getPerson(String id) async {
    _logger.d('Fetching person: $id');
    final response = await _apiService.get<Map<String, dynamic>>(
      '/persons/me/$id',
    );
    return Person.fromJson(_normalizePersonJson(response));
  }

  /// Get all persons for the current user
  Future<List<Person>> getMyPersons() async {
    _logger.d('Fetching my persons');

    List<dynamic> response;
    try {
      response = await _apiService.get<List<dynamic>>('/persons/me');
    } on NotFoundException {
      _logger.i('No persons found (404), returning empty list');
      return [];
    }

    final persons = <Person>[];
    for (final item in response) {
      try {
        persons.add(
          Person.fromJson(_normalizePersonJson(item as Map<String, dynamic>)),
        );
      } on Exception catch (e) {
        _logger.e('Error parsing person: $e');
      }
    }
    _logger.i('Loaded ${persons.length} persons');
    return persons;
  }

  /// Update a person
  Future<Person> updatePerson({
    required String id,
    String? givenName,
    String? familyName,
    String? gender,
    DateTime? birthDate,
  }) async {
    _logger.d('Updating person: $id');
    final response = await _apiService.patch<Map<String, dynamic>>(
      '/persons/me/$id',
      data: {
        'givenName': ?givenName,
        'familyName': ?familyName,
        'gender': ?gender,
        if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
      },
    );
    _logger.d('Person updated');
    return Person.fromJson(_normalizePersonJson(response));
  }

  /// Delete a person
  Future<void> deletePerson(String id) async {
    _logger.d('Deleting person: $id');
    await _apiService.delete<void>('/persons/me/$id');
    _logger.d('Person deleted');
  }
}
