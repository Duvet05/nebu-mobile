import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nebu_mobile_flutter/presentation/widgets/nebu_dots_loader.dart';

void main() {
  testWidgets('renders the three-dot Nebu loader with reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Center(child: NebuDotsLoader(semanticLabel: 'Loading toys')),
          ),
        ),
      ),
    );

    for (var index = 0; index < 3; index++) {
      expect(find.byKey(ValueKey('nebu-loader-dot-$index')), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Loading toys'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
