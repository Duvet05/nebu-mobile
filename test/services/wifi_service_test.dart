import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nebu_mobile_flutter/data/services/wifi_service.dart';

void main() {
  group('WiFiService.isScanSupported', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('es true en Android, la unica plataforma con API de escaneo', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(WiFiService.isScanSupported, isTrue);
    });

    test('es false en iOS: Apple no expone API para listar redes', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(WiFiService.isScanSupported, isFalse);
    });

    // La UI depende de este contrato: scanNetworks lanza UnsupportedError, que
    // al ser un Error y no una Exception no lo capturan los `on Exception
    // catch` de la capa de presentacion. Si esto vuelve a devolver true en
    // iOS, el sheet de redes queda en un spinner infinito.
    test('es false en macOS y otras plataformas Apple', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      expect(WiFiService.isScanSupported, isFalse);
    });
  });
}
