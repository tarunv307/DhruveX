class BleConstants {
  static const String osteoServiceUuid = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String sensorStatusCharacteristicUuid = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String thighDataCharacteristicUuid = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String shinDataCharacteristicUuid = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String commandCharacteristicUuid = "6E400005-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String resultCharacteristicUuid = "6E400006-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String batteryCharacteristicUuid = "00002A19-0000-1000-8000-00805F9B34FB";
  static const String firmwareCharacteristicUuid = "00002A26-0000-1000-8000-00805F9B34FB";

  // Packet Delimiters
  static const int magicHeader = 0xAA;
  static const int protocolVersion = 0x01;
  static const int sensorTypeThigh = 0x01;
  static const int sensorTypeShin = 0x02;

  // Thresholds
  static const int minAcceptableSignal = 40;
  static const int minAcceptableBattery = 15;
}
