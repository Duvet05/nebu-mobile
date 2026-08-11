import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/adaptive_icon.dart';

void main() {
  group('AdaptiveIconResolver', () {
    test('uses Cupertino on iOS, Material on Android, and Phosphor on Web', () {
      final ios = AdaptiveIconSymbol.home.resolveFor(AdaptiveIconPlatform.ios);
      final android = AdaptiveIconSymbol.home.resolveFor(
        AdaptiveIconPlatform.android,
      );
      final web = AdaptiveIconSymbol.home.resolveFor(AdaptiveIconPlatform.web);

      expect(ios.fontFamily, 'CupertinoIcons');
      expect(ios.fontPackage, 'cupertino_icons');
      expect(android.fontFamily, 'MaterialIcons');
      expect(web.fontFamily, 'PhosphorRegular');
      expect(web.fontPackage, 'phosphoricons_flutter');
    });

    test('defines every semantic icon on every supported platform', () {
      for (final symbol in AdaptiveIconSymbol.values) {
        for (final platform in AdaptiveIconPlatform.values) {
          final icon = symbol.resolveFor(platform);
          expect(
            icon.codePoint,
            greaterThan(0),
            reason: '$symbol must resolve on $platform',
          );
        }
      }
    });

    test('keeps platform navigation glyphs semantically distinct', () {
      for (final platform in AdaptiveIconPlatform.values) {
        final icons = {
          AdaptiveIconSymbol.home.resolveFor(platform).codePoint,
          AdaptiveIconSymbol.toys.resolveFor(platform).codePoint,
          AdaptiveIconSymbol.activity.resolveFor(platform).codePoint,
          AdaptiveIconSymbol.settings.resolveFor(platform).codePoint,
        };

        expect(icons, hasLength(4));
      }
    });
  });
}
