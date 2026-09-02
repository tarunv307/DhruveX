import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/disclaimer_banner.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joint Health Guidance'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DisclaimerBanner(),
              const SizedBox(height: 12),

              const Text(
                'Evidence-Based Preventive Practices',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'General, safe lifestyle recommendations for joint health. Always follow customized advice from your doctor or physiotherapist.',
                style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              _GuidanceItem(
                icon: Icons.directions_walk_rounded,
                title: 'Gentle Low-Impact Movement',
                body:
                    'Daily walking on flat surfaces, swimming, or stationary cycling helps nourish joint cartilage without excessive impact.',
              ),

              _GuidanceItem(
                icon: Icons.monitor_weight_outlined,
                title: 'Healthy Body Weight Management',
                body:
                    'Every kilogram of excess body weight places approximately 4 kilograms of extra mechanical force across the knee joints during walking.',
              ),

              _GuidanceItem(
                icon: Icons.fitness_center_outlined,
                title: 'Quadriceps Muscle Strengthening',
                body:
                    'Strengthening the thigh muscles acts as a natural shock absorber for the knees. Consult a certified physiotherapist for safe isometric exercises.',
              ),

              _GuidanceItem(
                icon: Icons.chair_outlined,
                title: 'Ergonomic & Occupational Adjustments',
                body:
                    'Use low stools instead of deep floor squatting where possible. Take short walking breaks during prolonged manual sitting or farm labor.',
              ),

              _GuidanceItem(
                icon: Icons.emergency_outlined,
                title: 'When to Seek Urgent Medical Care',
                body:
                    'If you experience sudden severe joint swelling, high fever, inability to put weight on the leg, or joint locking, visit the nearest PHC immediately.',
                isAlert: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidanceItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final bool isAlert;

  const _GuidanceItem({
    required this.icon,
    required this.title,
    required this.body,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: isAlert ? AppColors.criticalRedBg : Colors.white,
      border: isAlert ? Border.all(color: AppColors.criticalRed.withOpacity(0.5)) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAlert ? AppColors.criticalRed.withOpacity(0.15) : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isAlert ? AppColors.criticalRed : AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isAlert ? AppColors.criticalRed : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
