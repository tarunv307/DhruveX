import 'package:flutter_test/flutter_test.dart';
import 'package:osteoguard_ner/core/utils/bmi_calculator.dart';

void main() {
  group('BmiCalculator Tests', () {
    test('Calculates BMI accurately for normal weight', () {
      final bmi = BmiCalculator.calculate(65.0, 170.0);
      expect(bmi, 22.5);
      expect(BmiCalculator.getCategory(bmi), 'Normal Weight');
    });

    test('Calculates BMI accurately for overweight', () {
      final bmi = BmiCalculator.calculate(75.0, 160.0);
      expect(bmi, 29.3);
      expect(BmiCalculator.getCategory(bmi), 'Obese');
    });

    test('Handles zero or negative height safely', () {
      final bmi = BmiCalculator.calculate(60.0, 0.0);
      expect(bmi, 0.0);
    });
  });
}
