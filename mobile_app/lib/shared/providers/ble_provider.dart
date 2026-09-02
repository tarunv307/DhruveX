import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/bluetooth/ble_models.dart';
import '../../core/bluetooth/ble_service.dart';
import '../../core/bluetooth/demo_ble_service.dart';

final isDemoBleModeProvider = StateProvider<bool>((ref) => true); // Default demo mode enabled for jury testing

final bleRepositoryProvider = Provider<BleRepository>((ref) {
  final isDemo = ref.watch(isDemoBleModeProvider);
  return isDemo ? DemoBleService() : RealBleService();
});

class BleState {
  final BleConnectionStatus status;
  final List<BleDeviceInfo> discoveredDevices;
  final BleDeviceInfo? connectedDevice;
  final int batteryLevel;
  final int signalQuality;
  final bool isThighReady;
  final bool isShinReady;

  BleState({
    this.status = BleConnectionStatus.disconnected,
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.batteryLevel = 100,
    this.signalQuality = 100,
    this.isThighReady = false,
    this.isShinReady = false,
  });

  BleState copyWith({
    BleConnectionStatus? status,
    List<BleDeviceInfo>? discoveredDevices,
    BleDeviceInfo? connectedDevice,
    int? batteryLevel,
    int? signalQuality,
    bool? isThighReady,
    bool? isShinReady,
  }) {
    return BleState(
      status: status ?? this.status,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalQuality: signalQuality ?? this.signalQuality,
      isThighReady: isThighReady ?? this.isThighReady,
      isShinReady: isShinReady ?? this.isShinReady,
    );
  }
}

class BleNotifier extends StateNotifier<BleState> {
  final BleRepository _bleRepo;
  StreamSubscription? _connSub;
  StreamSubscription? _devicesSub;
  StreamSubscription? _packetSub;

  BleNotifier(this._bleRepo) : super(BleState()) {
    _connSub = _bleRepo.connectionState.listen((status) {
      state = state.copyWith(status: status);
      if (status == BleConnectionStatus.connected) {
        state = state.copyWith(
          isThighReady: true,
          isShinReady: true,
          batteryLevel: 94,
          signalQuality: 98,
        );
      }
    });

    _devicesSub = _bleRepo.discoveredDevicesStream.listen((devices) {
      state = state.copyWith(discoveredDevices: devices);
    });

    _packetSub = _bleRepo.sensorPacketStream.listen((packet) {
      state = state.copyWith(
        batteryLevel: packet.batteryPct,
        signalQuality: packet.signalQuality,
        isThighReady: packet.sensorType == SensorType.thigh ? true : state.isThighReady,
        isShinReady: packet.sensorType == SensorType.shin ? true : state.isShinReady,
      );
    });
  }

  Future<void> startScan() async => await _bleRepo.startScan();
  Future<void> stopScan() async => await _bleRepo.stopScan();
  Future<void> connect(String deviceId) async => await _bleRepo.connect(deviceId);
  Future<void> disconnect() async => await _bleRepo.disconnect();
  Future<void> startStreaming() async => await _bleRepo.startStreaming();
  Future<void> stopStreaming() async => await _bleRepo.stopStreaming();

  @override
  void dispose() {
    _connSub?.cancel();
    _devicesSub?.cancel();
    _packetSub?.cancel();
    super.dispose();
  }
}

final bleProvider = StateNotifierProvider<BleNotifier, BleState>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return BleNotifier(repo);
});

final sensorPacketStreamProvider = StreamProvider<ImuSensorPacket>((ref) {
  final repo = ref.watch(bleRepositoryProvider);
  return repo.sensorPacketStream;
});
