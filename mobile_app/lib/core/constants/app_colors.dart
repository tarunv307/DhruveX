import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Secondary
  static const Color primary = Color(0xFF135D9E); // Trustworthy medical deep blue
  static const Color primaryLight = Color(0xFFE8F1F8);
  static const Color secondary = Color(0xFF0B8F87); // Clinical teal
  static const Color secondaryLight = Color(0xFFE6F6F5);

  // Status & Risk Indicator Colors
  static const Color successGreen = Color(0xFF2E9D59); // Low risk
  static const Color successGreenBg = Color(0xFFE8F5E9);
  
  static const Color warningYellow = Color(0xFFE7AA18); // Moderate risk / Warning
  static const Color warningYellowBg = Color(0xFFFFF8E1);
  
  static const Color highRiskOrange = Color(0xFFE97819); // High risk
  static const Color highRiskOrangeBg = Color(0xFFFBE9E7);
  
  static const Color criticalRed = Color(0xFFC62828); // Critical / Red flag
  static const Color criticalRedBg = Color(0xFFFFEBEE);

  // Backgrounds & Neutrals
  static const Color background = Color(0xFFF5F9FC); // Clean clinical backdrop
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF17202A);
  static const Color textSecondary = Color(0xFF566573);
  static const Color textTertiary = Color(0xFF85929E);
  static const Color border = Color(0xFFD6DBDF);
  static const Color divider = Color(0xFFEAECEE);
  
  // Sensor Status
  static const Color sensorGood = Color(0xFF2E9D59);
  static const Color sensorFair = Color(0xFFE7AA18);
  static const Color sensorPoor = Color(0xFFC62828);
}
