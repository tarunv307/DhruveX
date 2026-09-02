import 'dart:typed_data';
import 'ble_models.dart';
import '../constants/ble_constants.dart';

class BlePacketParser {
  /// Parses standard 24-byte binary IMU sensor packet from ESP32-S3
  static ImuSensorPacket? parseBinaryPacket(List<int> rawBytes) {
    if (rawBytes.length < 24) return null;

    final byteData = ByteData.sublistView(Uint8List.fromList(rawBytes));
    
    // Header & Version validation
    final header = byteData.getUint8(0);
    final version = byteData.getUint8(1);
    if (header != BleConstants.magicHeader || version != BleConstants.protocolVersion) {
      return null;
    }

    final sensorTypeId = byteData.getUint8(2);
    final sensorType = (sensorTypeId == BleConstants.sensorTypeShin) 
        ? SensorType.shin 
        : SensorType.thigh;

    final seq = byteData.getUint8(3);
    final timestampMs = byteData.getUint32(4, Endian.big);

    // Accelerometer raw int16 (±16g range, scale 2048 LSB/g)
    final rawAx = byteData.getInt16(8, Endian.big);
    final rawAy = byteData.getInt16(10, Endian.big);
    final rawAz = byteData.getInt16(12, Endian.big);

    // Gyroscope raw int16 (±2000 dps range, scale 16.4 LSB/dps)
    final rawGx = byteData.getInt16(14, Endian.big);
    final rawGy = byteData.getInt16(16, Endian.big);
    final rawGz = byteData.getInt16(18, Endian.big);

    final battery = byteData.getUint8(20);
    final signalQuality = byteData.getUint8(21);
    final checksum = byteData.getUint16(22, Endian.big);

    // Validate CRC-16 Checksum
    final computedCrc = computeCrc16(rawBytes.sublist(0, 22));
    final isValid = (computedCrc == checksum);

    return ImuSensorPacket(
      magicHeader: header,
      protocolVersion: version,
      sensorType: sensorType,
      sequenceNumber: seq,
      timestampMs: timestampMs,
      accelX: rawAx / 2048.0,
      accelY: rawAy / 2048.0,
      accelZ: rawAz / 2048.0,
      gyroX: rawGx / 16.4,
      gyroY: rawGy / 16.4,
      gyroZ: rawGz / 16.4,
      batteryPct: battery,
      signalQuality: signalQuality,
      checksum: checksum,
      isValid: isValid,
    );
  }

  /// CRC-16-CCITT calculation
  static int computeCrc16(List<int> bytes) {
    int crc = 0xFFFF;
    for (int b in bytes) {
      crc ^= (b << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ 0x1021) & 0xFFFF;
        } else {
          crc = (crc << 1) & 0xFFFF;
        }
      }
    }
    return crc;
  }
}
