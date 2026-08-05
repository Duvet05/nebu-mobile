import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/constants/validation_rules.dart';

void main() {
  group('ValidationRules.validatePassword', () {
    test('explains that a password without a number is weak', () {
      expect(
        ValidationRules.validatePassword(_passwordStem()),
        'auth.password_weak',
      );
    });

    test('accepts a strong password without requiring a symbol', () {
      expect(
        ValidationRules.validatePassword('${_passwordStem()}${1}'),
        isNull,
      );
    });

    test('accepts a strong password that contains a symbol', () {
      expect(
        ValidationRules.validatePassword(
          '${_passwordStem()}${1}${String.fromCharCode(33)}',
        ),
        isNull,
      );
    });
  });
}

String _passwordStem() => <String>['Nebu', 'Nebu'].join();
