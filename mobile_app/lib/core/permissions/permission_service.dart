import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestBleAndLocationPermissions() async {
    // Bluetooth Scan & Connect (Android 12+)
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    
    // Location (required for Bluetooth on Android 11 and below)
    final locationStatus = await Permission.locationWhenInUse.request();

    return (scanStatus.isGranted || scanStatus.isLimited) &&
           (connectStatus.isGranted || connectStatus.isLimited) &&
           (locationStatus.isGranted || locationStatus.isLimited);
  }

  static Future<bool> hasBlePermissions() async {
    final scan = await Permission.bluetoothScan.isGranted;
    final connect = await Permission.bluetoothConnect.isGranted;
    return scan && connect;
  }
}
