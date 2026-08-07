import 'package:crolingo/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the CroLingo application shell', (tester) async {
    await tester.pumpWidget(const app.CroLingoApp());

    expect(find.text('CroLingo'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('main starts CroLingo', (tester) async {
    app.main();
    await tester.pump();

    expect(find.text('CroLingo'), findsOneWidget);
  });
}
