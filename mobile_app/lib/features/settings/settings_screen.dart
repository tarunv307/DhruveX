import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/disclaimer_banner.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/sync_provider.dart';
import '../../shared/providers/ble_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);
    final isDemo = ref.watch(isDemoBleModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings & System'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              CustomCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.person, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.user?.displayName ?? 'Health Worker',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Role: ${authState.user?.role ?? "HEALTH_WORKER"} • ${authState.user?.phone ?? ""}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Synchronization & Offline Storage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              CustomCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.sync_rounded, color: AppColors.primary),
                      title: const Text('Sync Queued Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('Pending records: ${syncState.pendingCount} • Last: ${syncState.lastSyncTime ?? "Never"}', style: const TextStyle(fontSize: 11)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12)),
                        onPressed: syncState.isSyncing
                            ? null
                            : () async {
                                final ok = await ref.read(syncProvider.notifier).syncNow();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(ok ? 'Sync completed successfully!' : 'Offline cache preserved.')),
                                  );
                                }
                              },
                        child: Text(syncState.isSyncing ? 'Syncing...' : 'Sync Now', style: const TextStyle(fontSize: 11, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Hardware & Demo Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              CustomCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  secondary: const Icon(Icons.developer_board, color: AppColors.primary),
                  title: const Text('Simulated Demo BLE Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Allows running full movement tests without physical ESP32-S3 hardware attached.', style: TextStyle(fontSize: 11)),
                  value: isDemo,
                  onChanged: (val) {
                    ref.read(isDemoBleModeProvider.notifier).state = val;
                  },
                ),
              ),
              const SizedBox(height: 16),

              const Text('Medical Safety & Compliance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              CustomCard(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Medical Disclaimer & Ethics'),
                      content: const Text(
                        'OSTEOGUARD-NER is strictly an AI-assisted risk screening and referral decision support system. '
                        'It does not provide definitive medical diagnoses. Clinical evaluation by a certified doctor/radiologist is required.\n\n'
                        'Data Minimization: No permanent raw high-frequency IMU arrays are retained without research opt-in.\n\n'
                        'Team: DhruveX\nAuthor: TARUN V\nProblem ID: SIH26004',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                      ],
                    ),
                  );
                },
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.verified_user_outlined, color: AppColors.secondary),
                  title: Text('Privacy Policy & Clinical Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('Review data minimization and non-diagnostic terms', style: TextStyle(fontSize: 11)),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 20),

              // App Version Details
              Center(
                child: Column(
                  children: [
                    Text(
                      '${AppStrings.appName} v1.0.0+1',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Team ${AppStrings.teamName} • Written by ${AppStrings.authorName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Log Out of Account',
                type: ButtonType.danger,
                icon: Icons.logout,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
