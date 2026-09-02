import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SignalQualityIndicator extends StatelessWidget {
  final int quality; // 0 to 100
  final int batteryPct; // 0 to 100
  final bool isConnected;

  const SignalQualityIndicator({
    Key? key,
    required this.quality,
    required this.batteryPct,
    this.isConnected = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color signalColor = AppColors.sensorPoor;
    String signalText = 'Poor';
    if (quality >= 75) {
      signalColor = AppColors.sensorGood;
      signalText = 'Excellent';
    } else if (quality >= 45) {
      signalColor = AppColors.sensorFair;
      signalText = 'Fair';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth_connected, size: 16, color: isConnected ? AppColors.primary : AppColors.textTertiary),
          const SizedBox(width: 4),
          Icon(Icons.signal_cellular_alt, size: 16, color: signalColor),
          const SizedBox(width: 4),
          Text(
            signalText,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: signalColor),
          ),
          const SizedBox(width: 8),
          Icon(
            batteryPct > 20 ? Icons.battery_charging_full : Icons.battery_alert,
            size: 16,
            color: batteryPct > 20 ? AppColors.successGreen : AppColors.criticalRed,
          ),
          const SizedBox(width: 2),
          Text(
            '$batteryPct%',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
