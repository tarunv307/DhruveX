import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:osteoguard_ner/core/bluetooth/ble_packet_parser.dart';
import 'package:osteoguard_ner/core/bluetooth/ble_models.dart';

void main() {
  group('BlePacketParser Tests', () {
    test('Correctly parses valid 24-byte binary packet', () {
      final bytes = Uint8List(24);
      final byteData = ByteData.sublistView(bytes);

      byteData.setUint8(0, 0xAA); // Magic Header
      byteData.setUint8(1, 0x01); // Protocol Version
      byteData.setUint8(2, 0x01); // Sensor Type: Thigh
      byteData.setUint8(3, 42);   // Sequence Number
      byteData.setUint32(4, 123456, Endian.big); // Timestamp

      // Accel ±16g
      byteData.setInt16(8, 2048, Endian.big); // 1.0 g
      byteData.setInt16(10, 0, Endian.big);
      byteData.setInt16(12, 0, Endian.big);

      // Gyro ±2000 dps
      byteData.setInt16(14, 164, Endian.big); // 10.0 dps
      byteData.setInt16(16, 0, Endian.big);
      byteData.setInt16(18, 0, Endian.big);

      byteData.setUint8(20, 92); // Battery 92%
      byteData.setUint8(21, 95); // Signal 95%

      // Compute CRC
      final crc = BlePacketParser.computeCrc16(bytes.sublist(0, 22));
      byteData.setUint16(22, crc, Endian.big);

      final packet = BlePacketParser.parseBinaryPacket(bytes);
      expect(packet, isNotNull);
      expect(packet!.sensorType, SensorType.thigh);
      expect(packet.sequenceNumber, 42);
      expect(packet.accelX, 1.0);
      expect(packet.gyroX, closeTo(10.0, 0.1));
      expect(packet.batteryPct, 92);
      expect(packet.signalQuality, 95);
      expect(packet.isValid, isTrue);
    });

    test('Rejects malformed packets with invalid header', () {
      final invalidBytes = List.filled(24, 0x00);
      final packet = BlePacketParser.parseBinaryPacket(invalidBytes);
      expect(packet, isNull);
    });
  });
}
