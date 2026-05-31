// test/widget_test.dart
//
// Tests de widgets del proyecto Rhema.
// Este archivo es un placeholder inicial. Los tests reales
// se agregarán a medida que construyamos cada feature.

import 'package:flutter_test/flutter_test.dart';
import 'package:rhema/main.dart';

void main() {
  testWidgets('RhemaApp renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const RhemaApp());
    expect(find.text('Rhema'), findsOneWidget);
  });
}