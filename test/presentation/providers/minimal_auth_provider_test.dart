import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/presentation/providers/api_provider.dart';
import 'package:nebu_mobile_flutter/presentation/providers/auth_provider.dart';

void main() {
  const minimumRelease = bool.fromEnvironment('MINIMAL_IOS_RELEASE');

  test(
    'minimum release does not restore a stored account session',
    () async {
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith(
            (ref) => throw StateError('Auth service must not be initialized'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(authProvider.future), isNull);
    },
    skip: !minimumRelease,
  );
}
