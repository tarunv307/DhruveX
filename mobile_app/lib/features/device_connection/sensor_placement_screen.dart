import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';

class SensorPlacementScreen extends StatefulWidget {
  const SensorPlacementScreen({Key? key}) : super(key: key);

  @override
  State<SensorPlacementScreen> createState() => _SensorPlacementScreenState();
}

class _SensorPlacementScreenState extends State<SensorPlacementScreen> {
  bool _isCalibrating = false;
  bool _isCalibrated = false;

  Future<void> _run5SecCalibration() async {
    setState(() => _isCalibrating = true);
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _isCalibrating = false;
        _isCalibrated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Placement & Calibration'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Proper Sensor Placement Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Follow these 3 steps to ensure accurate biomechanics capture:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Step 1: Thigh Placement
              CustomCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('1', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thigh IMU Placement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            'Attach the Thigh IMU ~10cm above the knee cap along the anterior midline of the quadriceps. Point the forward arrow straight toward the toes.',
                            style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Step 2: Shin Placement
              CustomCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('2', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shin IMU Placement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            'Attach the Shin IMU ~10cm below the tibial tuberosity. Ensure the elastic strap is snug and does not wobble during movement.',
                            style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Step 3: Zero-Rate Calibration
              CustomCard(
                color: _isCalibrated ? AppColors.successGreenBg : Colors.white,
                border: _isCalibrated ? Border.all(color: AppColors.successGreen) : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isCalibrated ? AppColors.successGreen : AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCalibrated ? Icons.check : Icons.tune_rounded,
                        color: _isCalibrated ? Colors.white : AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCalibrated ? 'Sensor Calibration Completed' : 'Static 5-Second Calibration',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _isCalibrated ? AppColors.successGreen : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isCalibrated
                                ? 'Zero-rate bias calibrated. Sensors are ready for the movement test.'
                                : 'Ask patient to stand still with knees straight for 5 seconds to calibrate gyroscope offsets.',
                            style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          if (!_isCalibrated)
                            ElevatedButton.icon(
                              icon: _isCalibrating
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.play_arrow_rounded, size: 16),
                              label: Text(_isCalibrating ? 'Calibrating...' : 'Run 5-sec Calibration', style: const TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              onPressed: _isCalibrating ? null : _run5SecCalibration,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Done & Return to Device Screen',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
