import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osteoguard_ner/shared/widgets/disclaimer_banner.dart';
import 'package:osteoguard_ner/core/constants/app_strings.dart';

void main() {
  testWidgets('DisclaimerBanner displays mandatory medical disclaimer', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DisclaimerBanner(),
        ),
      ),
    );

    expect(find.text(AppStrings.mandatoryDisclaimer), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('DisclaimerBanner renders red-flag alert styling when isRedFlag is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DisclaimerBanner(isRedFlag: true),
        ),
      ),
    );

    expect(find.text(AppStrings.redFlagAlertTitle), findsOneWidget);
    expect(find.text(AppStrings.redFlagAlertMessage), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
