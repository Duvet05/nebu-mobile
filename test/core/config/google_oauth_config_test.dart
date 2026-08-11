import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/core/config/config.dart';

void main() {
  test('web uses the web OAuth client as its browser client', () {
    expect(
      Config.googleClientIdForPlatform(
        isWeb: true,
        platform: TargetPlatform.iOS,
      ),
      Config.googleWebClientId,
    );
    expect(Config.googleServerClientIdForPlatform(isWeb: true), isNull);
  });

  test('iOS uses the native client and web server client', () {
    expect(
      Config.googleClientIdForPlatform(
        isWeb: false,
        platform: TargetPlatform.iOS,
      ),
      Config.googleIosClientId,
    );
    expect(
      Config.googleServerClientIdForPlatform(isWeb: false),
      Config.googleWebClientId,
    );
  });

  test('Android discovers its native client from google-services.json', () {
    expect(
      Config.googleClientIdForPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isNull,
    );
  });
}
