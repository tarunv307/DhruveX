import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/gait_chart.dart';
import '../../shared/widgets/signal_quality_indicator.dart';
import '../../shared/providers/screening_provider.dart';
import '../../shared/providers/ble_provider.dart';

class ScreeningTestScreen extends ConsumerStatefulWidget {
  const ScreeningTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreeningTestScreen> createState() => _ScreeningTestScreenState();
}

class _ScreeningTestScreenState extends ConsumerState<ScreeningTestScreen> {
  int _activeTestIndex = 0; // 0: Normal Walking (30s), 1: Sit-to-Stand (15s)

  final List<Map<String, dynamic>> _tests = [
    {
      'title': 'Test 1: Normal Walking',
      'instruction': 'Ask the patient to walk back and forth comfortably at their natural pace along a 10-meter flat surface.',
      'duration': 30,
    },
    {
      'title': 'Test 2: Sit-to-Stand (5 Repetitions)',
      'instruction': 'Ask the patient to sit on a standard chair and stand up fully 5 times with arms crossed over chest.',
      'duration': 15,
    },
  ];

  void _startTest() {
    final duration = _tests[_activeTestIndex]['duration'] as int;
    ref.read(screeningProvider.notifier).startMovementTest(durationSec: duration);
  }

  void _stopTest() {
    ref.read(screeningProvider.notifier).stopMovementTest();
  }

  void _finishAndAnalyze() {
    _stopTest();
    context.push('/processing');
  }

  @override
  Widget build(BuildContext context) {
    final screeningState = ref.watch(screeningProvider);
    final bleState = ref.watch(bleProvider);
    final testInfo = _tests[_activeTestIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(testInfo['title'] as String),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SignalQualityIndicator(
              quality: bleState.signalQuality,
              batteryPct: bleState.batteryLevel,
              isConnected: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Safety Warning Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.criticalRedBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.criticalRed.withOpacity(0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, color: AppColors.criticalRed, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Safety First: Stop the test immediately if the patient experiences sharp knee pain or dizziness.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.criticalRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Test Selector Tabs
              Row(
                children: List.generate(
                  _tests.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: screeningState.isTestRunning
                          ? null
                          : () {
                              setState(() => _activeTestIndex = index);
                            },
                      child: Container(
                        margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTestIndex == index ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _activeTestIndex == index ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            index == 0 ? '1. Walking Test (30s)' : '2. Sit-to-Stand (15s)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeTestIndex == index ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Instructions Card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Instructions for Health Worker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      testInfo['instruction'] as String,
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Countdown Display
              CustomCard(
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        'Time Remaining',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${screeningState.testCountdown}s',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: screeningState.isTestRunning ? AppColors.primary : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!screeningState.isTestRunning)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start Sensor Recording'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          onPressed: _startTest,
                        )
                      else
                        ElevatedButton.icon(
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('Stop / Pause Test'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.criticalRed),
                          onPressed: _stopTest,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Live Dual-IMU Biomechanics Waveform
              CustomCard(
                child: GaitChart(
                  thighSpots: screeningState.thighSpots,
                  shinSpots: screeningState.shinSpots,
                  title: 'Live Sensor Stream (Thigh vs Shin Gyroscope)',
                ),
              ),
              const SizedBox(height: 20),

              // Finish & Calculate Action
              CustomButton(
                text: 'Complete Test & Analyze AI Risk',
                onPressed: _finishAndAnalyze,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
