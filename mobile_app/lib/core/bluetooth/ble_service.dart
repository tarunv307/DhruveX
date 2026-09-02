import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_models.dart';
import 'ble_packet_parser.dart';
import '../constants/ble_constants.dart';

abstract class BleRepository {
  Stream<BleConnectionStatus> get connectionState;
  Stream<ImuSensorPacket> get sensorPacketStream;
  Stream<List<BleDeviceInfo>> get discoveredDevicesStream;
  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<void> sendCommand(String command);
  Future<void> startStreaming();
  Future<void> stopStreaming();
  bool get isConnected;
}

class RealBleService implements BleRepository {
  final _connectionStateController = StreamController<BleConnectionStatus>.broadcast();
  final _packetController = StreamController<ImuSensorPacket>.broadcast();
  final _devicesController = StreamController<List<BleDeviceInfo>>.broadcast();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandCharacteristic;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _thighDataSubscription;
  StreamSubscription? _shinDataSubscription;

  BleConnectionStatus _currentStatus = BleConnectionStatus.disconnected;

  RealBleService() {
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
    final discovered = <BleDeviceInfo>[];

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      withServices: [Guid(BleConstants.osteoServiceUuid)],
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!discovered.any((d) => d.id == r.device.remoteId.str)) {
          discovered.add(BleDeviceInfo(
            id: r.device.remoteId.str,
            name: r.device.platformName.isNotEmpty ? r.device.platformName : "OSTEOGUARD-WEARABLE",
            rssi: r.rssi,
            batteryLevel: 90,
          ));
          _devicesController.add(List.from(discovered));
        }
      }
    });
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
  }

  @override
  Future<void> connect(String deviceId) async {
    _connectionStateController.add(BleConnectionStatus.connecting);
    _connectedDevice = BluetoothDevice.fromId(deviceId);

    try {
      await _connectedDevice!.connect(timeout: const Duration(seconds: 15));
      final services = await _connectedDevice!.discoverServices();

      for (var s in services) {
        if (s.uuid.toString().toUpperCase() == BleConstants.osteoServiceUuid) {
          for (var c in s.characteristics) {
            final uuidStr = c.uuid.toString().toUpperCase();
            if (uuidStr == BleConstants.commandCharacteristicUuid) {
              _commandCharacteristic = c;
            } else if (uuidStr == BleConstants.thighDataCharacteristicUuid) {
              await c.setNotifyValue(true);
              _thighDataSubscription = c.onValueReceived.listen((bytes) {
                final packet = BlePacketParser.parseBinaryPacket(bytes);
                if (packet != null) _packetController.add(packet);
              });
            } else if (uuidStr == BleConstants.shinDataCharacteristicUuid) {
              await c.setNotifyValue(true);
              _shinDataSubscription = c.onValueReceived.listen((bytes) {
                final packet = BlePacketParser.parseBinaryPacket(bytes);
                if (packet != null) _packetController.add(packet);
              });
            }
          }
        }
      }

      _currentStatus = BleConnectionStatus.connected;
      _connectionStateController.add(_currentStatus);
    } catch (e) {
      _currentStatus = BleConnectionStatus.error;
      _connectionStateController.add(_currentStatus);
    }
  }

  @override
  Future<void> disconnect() async {
    _thighDataSubscription?.cancel();
    _shinDataSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _currentStatus = BleConnectionStatus.disconnected;
    _connectionStateController.add(_currentStatus);
  }

  @override
  Future<void> sendCommand(String command) async {
    if (_commandCharacteristic != null) {
      await _commandCharacteristic!.write(command.codeUnits);
    }
  }

  @override
  Future<void> startStreaming() async {
    await sendCommand("START_TEST");
  }

  @override
  Future<void> stopStreaming() async {
    await sendCommand("STOP_TEST");
  }
}
