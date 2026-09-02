import 'dart:async';
import 'dart:math';
import 'ble_models.dart';
import 'ble_service.dart';

class DemoBleService implements BleRepository {
  final _connectionStateController = StreamController<BleConnectionStatus>.broadcast();
  final _packetController = StreamController<ImuSensorPacket>.broadcast();
  final _devicesController = StreamController<List<BleDeviceInfo>>.broadcast();

  Timer? _streamTimer;
  int _sequence = 0;
  BleConnectionStatus _currentStatus = BleConnectionStatus.disconnected;

  DemoBleService() {
    _connectionStateController.add(_currentStatus);
  }

  @override
  Stream<BleConnectionStatus> get connectionState => _connectionStateController.stream;

  @override
  Stream<ImuSensorPacket> get sensorPacketStream => _packetController.stream;

  @override
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream => _devicesController.stream;

  @override
  bool get isConnected => _currentStatus == BleConnectionStatus.connected;

  @override
  Future<void> startScan() async {
    _connectionStateController.add(BleConnectionStatus.scanning);
    await Future.delayed(const Duration(milliseconds: 800));

    final demoDevices = [
      BleDeviceInfo(
        id: "DEMO-ESP32-S3-01",
        name: "OSTEOGUARD-DEMO-WEARABLE",
        rssi: -52,
        batteryLevel: 94,
        isThighConnected: true,
        isShinConnected: true,
      ),
    ];
    _devicesController.add(demoDevices);
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String deviceId) async {
    _connectionStateController.add(BleConnectionStatus.connecting);
    await Future.delayed(const Duration(milliseconds: 1000));
    _currentStatus = BleConnectionStatus.connected;
    _connectionStateController.add(_currentStatus);
  }

  @override
  Future<void> disconnect() async {
    await stopStreaming();
    _currentStatus = BleConnectionStatus.disconnected;
    _connectionStateController.add(_currentStatus);
  }

  @override
  Future<void> sendCommand(String command) async {}

  @override
  Future<void> startStreaming() async {
    _streamTimer?.cancel();
    _sequence = 0;

    // Simulate 20Hz stream (every 50ms)
    _streamTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _sequence = (_sequence + 1) % 256;
      final t = DateTime.now().millisecondsSinceEpoch;
      final phase = (_sequence * 0.15);

      // Thigh Packet (Sine wave movement)
      final thighPacket = ImuSensorPacket(
        magicHeader: 0xAA,
        protocolVersion: 1,
        sensorType: SensorType.thigh,
        sequenceNumber: _sequence,
        timestampMs: t,
        accelX: 0.1 + 0.3 * sin(phase),
        accelY: 0.8 + 0.2 * cos(phase),
        accelZ: 0.2,
        gyroX: 45.0 * sin(phase),
        gyroY: 15.0 * cos(phase),
        gyroZ: 5.0,
        batteryPct: 94,
        signalQuality: 98,
        checksum: 0,
        isValid: true,
      );
      _packetController.add(thighPacket);

      // Shin Packet (Slightly lagging phase)
      final shinPacket = ImuSensorPacket(
        magicHeader: 0xAA,
        protocolVersion: 1,
        sensorType: SensorType.shin,
        sequenceNumber: _sequence,
        timestampMs: t,
        accelX: 0.15 + 0.35 * sin(phase - 0.4),
        accelY: 0.85 + 0.25 * cos(phase - 0.4),
        accelZ: 0.1,
        gyroX: 55.0 * sin(phase - 0.4),
        gyroY: 20.0 * cos(phase - 0.4),
        gyroZ: 8.0,
        batteryPct: 94,
        signalQuality: 98,
        checksum: 0,
        isValid: true,
      );
      _packetController.add(shinPacket);
    });
  }

  @override
  Future<void> stopStreaming() async {
    _streamTimer?.cancel();
    _streamTimer = null;
  }
}
