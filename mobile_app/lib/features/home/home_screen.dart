import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/risk_badge.dart';
import '../../shared/widgets/disclaimer_banner.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../../shared/providers/ble_provider.dart';
import '../../shared/providers/patient_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);
    final bleState = ref.watch(bleProvider);
    final isDemoBle = ref.watch(isDemoBleModeProvider);
    final patientState = ref.watch(patientProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(patientProvider.notifier).loadPatients();
            await ref.read(syncProvider.notifier).refreshPendingCount();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Welcome Card
                CustomCard(
                  color: AppColors.primary,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_pin_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authState.user?.displayName ?? 'Health Worker',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authState.isOfflineMode ? 'Field Offline Mode' : 'Connected to PHC Cloud',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Demo Badge
                      if (isDemoBle)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'DEMO MODE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Status Strip (BLE & Sync Queue)
                Row(
                  children: [
                    Expanded(
                      child: CustomCard(
                        onTap: () => context.push('/device-connection'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bluetooth,
                              size: 20,
                              color: bleState.status.toString().contains('connected')
                                  ? AppColors.successGreen
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Wearable', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  Text(
                                    bleState.status.toString().contains('connected') ? 'Connected' : 'Tap to Pair',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomCard(
                        onTap: () async {
                          final ok = await ref.read(syncProvider.notifier).syncNow();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ok ? 'Sync completed successfully!' : 'Offline: Synced queue preserved.'),
                                backgroundColor: ok ? AppColors.successGreen : AppColors.primary,
                              ),
                            );
                          }
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync,
                              size: 20,
                              color: syncState.pendingCount > 0 ? AppColors.warningYellow : AppColors.successGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pending Sync: ${syncState.pendingCount}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    syncState.isSyncing ? 'Syncing...' : (syncState.pendingCount > 0 ? 'Tap to Sync' : 'Up to date'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Primary Call to Action
                CustomButton(
                  text: 'Start New Patient Screening',
                  icon: Icons.add_circle_outline,
                  onPressed: () => context.push('/patient-registration'),
                ),
                const SizedBox(height: 16),

                // Clinical Disclaimer
                const DisclaimerBanner(),
                const SizedBox(height: 12),

                // Quick Navigation Grid
                const Text(
                  'Clinical Management',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    _NavCard(
                      icon: Icons.history_rounded,
                      title: 'Patient History',
                      onTap: () => context.push('/patient-history'),
                    ),
                    _NavCard(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'PHC Referrals',
                      onTap: () => context.push('/referrals'),
                    ),
                    _NavCard(
                      icon: Icons.calendar_month_outlined,
                      title: 'Follow-ups',
                      onTap: () => context.push('/follow-up'),
                    ),
                    _NavCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'Safe Guidance',
                      onTap: () => context.push('/guidance'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Patients List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Patients',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${patientState.patients.length} Registered',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (patientState.patients.isEmpty)
                  const CustomCard(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No patient records found. Start a new screening!'),
                      ),
                    ),
                  )
                else
                  ...patientState.patients.take(4).map((p) => CustomCard(
                        onTap: () {
                          ref.read(patientProvider.notifier).selectPatient(p);
                          context.push('/clinical-questionnaire');
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                p.initials ?? p.patientCode.substring(0, 2),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p.patientCode} • ${p.age} yrs (${p.gender})',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.village}, ${p.district} • BMI: ${p.bmi}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
