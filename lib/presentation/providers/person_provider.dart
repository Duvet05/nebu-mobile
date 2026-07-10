import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/person.dart';
import '../../data/services/person_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final personProvider = AsyncNotifierProvider<PersonNotifier, List<Person>>(
  PersonNotifier.new,
);

class PersonNotifier extends AsyncNotifier<List<Person>> {
  @override
  Future<List<Person>> build() {
    ref.watch(authProvider).value?.id;
    return Future.value([]);
  }

  PersonService get _personService => ref.read(personServiceProvider);
  String? get _userId => ref.read(authProvider).value?.id;

  /// Returns the current list, reloading from API if state has error.
  Future<List<Person>> _currentPersons(String userId) async {
    if (_userId != userId) {
      return [];
    }
    if (state.hasError) {
      ref.read(loggerProvider).w('Person state was error, reloading from API');
      final persons = await _personService.getMyPersons();
      if (_userId == userId) {
        state = AsyncValue.data(persons);
      }
      return persons;
    }
    return state.value ?? [];
  }

  /// Load all persons for the current user
  Future<void> loadMyPersons() async {
    final userId = _userId;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      final persons = await _personService.getMyPersons();
      ref.read(loggerProvider).d('Loaded ${persons.length} persons');
      return persons;
    });
    if (_userId == userId) {
      state = result;
    }
  }

  /// Create a new person (child)
  Future<Person> createPerson({
    String? givenName,
    String? familyName,
    String? gender,
    DateTime? birthDate,
  }) async {
    final userId = _userId;
    try {
      final person = await _personService.createPerson(
        givenName: givenName,
        familyName: familyName,
        gender: gender,
        birthDate: birthDate,
      );

      ref.read(loggerProvider).d('Person created: ${person.givenName}');
      if (userId == null || _userId != userId) {
        return person;
      }

      final current = await _currentPersons(userId);
      if (_userId != userId) {
        return person;
      }
      // Deduplicate: API reload may already include the new person
      if (current.any((p) => p.id == person.id)) {
        state = AsyncValue.data(current);
      } else {
        state = AsyncValue.data([...current, person]);
      }

      return person;
    } on Exception catch (e) {
      ref.read(loggerProvider).e('Error creating person: $e');
      rethrow;
    }
  }

  /// Update a person
  Future<Person> updatePerson({
    required String id,
    String? givenName,
    String? familyName,
    String? gender,
    DateTime? birthDate,
  }) async {
    final userId = _userId;
    try {
      final updated = await _personService.updatePerson(
        id: id,
        givenName: givenName,
        familyName: familyName,
        gender: gender,
        birthDate: birthDate,
      );

      ref.read(loggerProvider).d('Person updated: ${updated.givenName}');
      if (userId == null || _userId != userId) {
        return updated;
      }

      final current = await _currentPersons(userId);
      if (_userId != userId) {
        return updated;
      }
      final index = current.indexWhere((p) => p.id == updated.id);
      final newList = [...current];
      if (index != -1) {
        newList[index] = updated;
      } else {
        newList.add(updated);
      }
      state = AsyncValue.data(newList);

      return updated;
    } on Exception catch (e) {
      ref.read(loggerProvider).e('Error updating person: $e');
      rethrow;
    }
  }

  /// Delete a person
  Future<void> deletePerson(String id) async {
    final userId = _userId;
    try {
      await _personService.deletePerson(id);
      ref.read(loggerProvider).d('Person deleted: $id');
      if (userId == null || _userId != userId) {
        return;
      }

      final current = await _currentPersons(userId);
      if (_userId == userId) {
        state = AsyncValue.data(current.where((p) => p.id != id).toList());
      }
    } on Exception catch (e) {
      ref.read(loggerProvider).e('Error deleting person: $e');
      rethrow;
    }
  }

  /// Clear state
  void clear() {
    state = const AsyncValue.data([]);
  }
}
