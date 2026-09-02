class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message, code: 'NETWORK_ERROR');
}

class ServerException extends AppException {
  ServerException(String message, {dynamic details}) : super(message, code: 'SERVER_ERROR', details: details);
}

class BleException extends AppException {
  BleException(String message) : super(message, code: 'BLE_ERROR');
}

class CacheException extends AppException {
  CacheException(String message) : super(message, code: 'CACHE_ERROR');
}
