class BmiCalculator {
  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  static String getCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 23.0) return 'Normal Weight';
    if (bmi < 27.5) return 'Overweight';
    return 'Obese';
  }
}
