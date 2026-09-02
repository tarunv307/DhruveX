import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/bluetooth/ble_models.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_card.dart';
import '../../shared/widgets/signal_quality_indicator.dart';
import '../../shared/providers/ble_provider.dart';

class DeviceConnectionScreen extends ConsumerStatefulWidget {
  const DeviceConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends ConsumerState<DeviceConnectionScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger auto-scan
    Future.microtask(() => ref.read(bleProvider.notifier).startScan());
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleProvider);
    final isDemo = ref.watch(isDemoBleModeProvider);
    final isConnected = bleState.status == BleConnectionStatus.connected;
    final canProceed = isConnected && bleState.isThighReady && bleState.isShinReady;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Wearable Device'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(bleProvider.notifier).startScan(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Demo Mode Switch Card
              CustomCard(
                color: isDemo ? AppColors.warningYellowBg : AppColors.background,
                child: Row(
                  children: [
                    Icon(
                      isDemo ? Icons.developer_mode : Icons.bluetooth_searching,
                      color: isDemo ? const Color(0xFFB7791F) : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDemo ? 'DEMO MODE ACTIVE' : 'REAL BLE HARDWARE',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            isDemo
                                ? 'Simulates dual-IMU sensor stream for jury & offline testing'
                                : 'Scans for physical ESP32-S3 wearable devices',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isDemo,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(isDemoBleModeProvider.notifier).state = val;
                        ref.read(bleProvider.notifier).startScan();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Sensor Hardware Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),

              // Dual-IMU Status Cards
              Row(
                children: [
                  Expanded(
                    child: _SensorStatusCard(
                      label: 'Thigh IMU Sensor',
                      position: 'Upper Quad Strap',
                      isReady: bleState.isThighReady,
                      icon: Icons.airline_seat_legroom_extra_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SensorStatusCard(
                      label: 'Shin IMU Sensor',
                      position: 'Lower Tibia Strap',
                      isReady: bleState.isShinReady,
                      icon: Icons.directions_walk_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Connection Status Header
              if (isConnected)
                CustomCard(
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESP32-S3 Wearable Ready',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text('Both IMU channels transmitting at 50Hz',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      SignalQualityIndicator(
                        quality: bleState.signalQuality,
                        batteryPct: bleState.batteryLevel,
                        isConnected: true,
                      ),
                    ],
                  ),
                )
              else
                CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Available Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (bleState.status == BleConnectionStatus.scanning)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (bleState.discoveredDevices.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text('Scanning for OSTEOGUARD wearable...'),
                          ),
                        )
                      else
                        ...bleState.discoveredDevices.map(
                          (dev) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.bluetooth, color: AppColors.primary),
                            title: Text(dev.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('ID: ${dev.id} • Signal: ${dev.rssi} dBm', style: const TextStyle(fontSize: 11)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: const Text('Connect', style: TextStyle(fontSize: 12, color: Colors.white)),
                              onPressed: () => ref.read(bleProvider.notifier).connect(dev.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.accessibility_new_rounded),
                label: const Text('View Sensor Placement Guide & Calibration'),
                onPressed: () => context.push('/sensor-placement'),
              ),
              const SizedBox(height: 20),

              CustomButton(
                text: 'Proceed to Movement Test',
                onPressed: canProceed ? () => context.push('/screening-test') : null,
              ),
              if (!canProceed)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      isConnected
                          ? 'Calibrating sensors...'
                          : 'Please pair your OSTEOGUARD wearable to continue',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorStatusCard extends StatelessWidget {
  final String label;
  final String position;
  final bool isReady;
  final IconData icon;

  const _SensorStatusCard({
    required this.label,
    required this.position,
    required this.isReady,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReady ? AppColors.successGreenBg : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? AppColors.successGreen : AppColors.border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: isReady ? AppColors.successGreen : AppColors.textTertiary),
              Icon(
                isReady ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: isReady ? AppColors.successGreen : AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(position, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
