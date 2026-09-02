import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osteoguard_ner/shared/widgets/risk_badge.dart';

void main() {
  testWidgets('RiskBadge renders Low Risk correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskBadge(category: 'LOW', score: 24),
        ),
      ),
    );

    expect(find.text('Low Risk (24/100)'), findsOneWidget);
  });

  testWidgets('RiskBadge renders High Risk correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiskBadge(category: 'HIGH', score: 78),
        ),
      ),
    );

    expect(find.text('High Risk (78/100)'), findsOneWidget);
  });
}
