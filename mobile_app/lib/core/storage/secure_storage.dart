import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: keyAccessToken, value: accessToken);
    await _storage.write(key: keyRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: keyRefreshToken);
  }

  Future<void> saveUserMeta({required String userId, required String role}) async {
    await _storage.write(key: keyUserId, value: userId);
    await _storage.write(key: keyUserRole, value: role);
  }

  Future<String?> getUserId() async => await _storage.read(key: keyUserId);
  Future<String?> getUserRole() async => await _storage.read(key: keyUserRole);

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
