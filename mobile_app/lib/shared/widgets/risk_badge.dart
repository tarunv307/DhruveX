import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RiskBadge extends StatelessWidget {
  final String category; // LOW, MODERATE, HIGH, INCOMPLETE
  final int? score;
  final bool showScore;

  const RiskBadge({
    Key? key,
    required this.category,
    this.score,
    this.showScore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    String label;

    switch (category.toUpperCase()) {
      case 'LOW':
        bg = AppColors.successGreenBg;
        border = AppColors.successGreen;
        text = AppColors.successGreen;
        label = 'Low Risk';
        break;
      case 'MODERATE':
        bg = AppColors.warningYellowBg;
        border = AppColors.warningYellow;
        text = const Color(0xFFB7791F);
        label = 'Moderate Risk';
        break;
      case 'HIGH':
        bg = AppColors.criticalRedBg;
        border = AppColors.criticalRed;
        text = AppColors.criticalRed;
        label = 'High Risk';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFF94A3B8);
        text = const Color(0xFF475569);
        label = 'Incomplete';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: border,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            (showScore && score != null) ? '$label ($score/100)' : label,
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
