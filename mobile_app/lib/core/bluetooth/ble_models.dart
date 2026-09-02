enum BleConnectionStatus {
  disconnected,
  scanning,
  connecting,
  connected,
  poorSignal,
  batteryLow,
  firmwareMismatch,
  calibrationRequired,
  dataInvalid,
  error
}

enum SensorType {
  thigh,
  shin
}

class ImuSensorPacket {
  final int magicHeader;
  final int protocolVersion;
  final SensorType sensorType;
  final int sequenceNumber;
  final int timestampMs;
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final int batteryPct;
  final int signalQuality;
  final int checksum;
  final bool isValid;

  ImuSensorPacket({
    required this.magicHeader,
    required this.protocolVersion,
    required this.sensorType,
    required this.sequenceNumber,
    required this.timestampMs,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.batteryPct,
    required this.signalQuality,
    required this.checksum,
    this.isValid = true,
  });
}

class BleDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final int batteryLevel;
  final bool isThighConnected;
  final bool isShinConnected;

  BleDeviceInfo({
    required this.id,
    required this.name,
    this.rssi = -60,
    this.batteryLevel = 100,
    this.isThighConnected = false,
    this.isShinConnected = false,
  });
}
