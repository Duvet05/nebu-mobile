import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/data/models/user.dart';

void main() {
  const identity = {'id': 'account-1', 'email': 'test@example.com'};

  test('old server and cached profiles require a password by default', () {
    expect(User.fromJson(identity).requiresPasswordForDeletion, isTrue);
    expect(
      User.fromJson({
        ...identity,
        'requiresPasswordForDeletion': null,
      }).requiresPasswordForDeletion,
      isTrue,
    );
  });

  test(
    'deletion requirements round-trip without inferring the login method',
    () {
      for (final requiresPassword in [false, true]) {
        final user = User.fromJson({
          ...identity,
          'requiresPasswordForDeletion': requiresPassword,
        });
        expect(user.requiresPasswordForDeletion, requiresPassword);
        expect(
          User.fromJson(user.toJson()).requiresPasswordForDeletion,
          requiresPassword,
        );
      }
      expect(
        User.fromJson({
          ...identity,
          'oauthProvider': 'google',
        }).requiresPasswordForDeletion,
        isTrue,
      );
    },
  );
}
