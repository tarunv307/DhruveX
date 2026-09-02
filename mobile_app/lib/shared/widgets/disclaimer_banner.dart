import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class DisclaimerBanner extends StatelessWidget {
  final String? customText;
  final bool isRedFlag;

  const DisclaimerBanner({
    Key? key,
    this.customText,
    this.isRedFlag = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isRedFlag ? AppColors.criticalRedBg : AppColors.warningYellowBg;
    final borderColor = isRedFlag ? AppColors.criticalRed : AppColors.warningYellow;
    final iconColor = isRedFlag ? AppColors.criticalRed : AppColors.warningYellow;
    final title = isRedFlag ? AppStrings.redFlagAlertTitle : 'Medical Notice';
    final text = customText ?? (isRedFlag ? AppStrings.redFlagAlertMessage : AppStrings.mandatoryDisclaimer);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRedFlag ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
