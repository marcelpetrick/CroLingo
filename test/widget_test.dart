import 'package:crolingo/app/crolingo_app.dart';
import 'package:crolingo/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    appRouter.go('/');
    await tester.pumpWidget(const CroLingoApp());
    await tester.pumpAndSettle();
  }

  testWidgets('shows the Croatian dashboard', (tester) async {
    await pumpApp(tester);

    expect(find.text('Bok! Bereit für Kroatisch?'), findsOneWidget);
    expect(find.text('Deutsch → Hrvatski'), findsOneWidget);
    expect(find.text('Keine Herzen'), findsNothing);
  });

  testWidgets('opens the learning path from the dashboard', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Lernweg öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Dein Lernweg'), findsOneWidget);
    expect(find.text('Lektion 1 · Begrüßen'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
  });

  testWidgets('navigates to review and more', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Üben'));
    await tester.pumpAndSettle();
    expect(find.text('Noch nichts fällig'), findsOneWidget);

    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();
    expect(find.text('Wortschatz'), findsOneWidget);
    expect(find.text('Offline · Keine Werbung · Keine Herzen'), findsOneWidget);
  });
}
