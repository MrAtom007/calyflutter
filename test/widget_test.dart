// Smoke test di base per l'app CaliStrack.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp si costruisce senza errori',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('CaliStrack'))),
      ),
    );

    expect(find.text('CaliStrack'), findsOneWidget);
  });
}
