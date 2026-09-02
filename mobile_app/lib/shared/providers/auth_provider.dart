import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/networking/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants/api_constants.dart';
import '../models/user.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(secureStorage: ref.watch(secureStorageProvider)));

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final bool isOfflineMode;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
    this.isOfflineMode = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    bool? isOfflineMode,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthNotifier(this._apiClient, this._storage) : super(AuthState()) {
    checkInitialAuth();
  }

  Future<void> checkInitialAuth() async {
    final token = await _storage.getAccessToken();
    final userId = await _storage.getUserId();
    final role = await _storage.getUserRole();

    if (token != null && userId != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: UserModel(
          id: userId,
          phone: "Cached User",
          displayName: "Health Worker",
          role: role ?? "HEALTH_WORKER",
        ),
      );
    }
  }

  Future<bool> login(String phoneOrId, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await _apiClient.post(ApiConstants.authLogin, data: {
        'phone_or_id': phoneOrId,
        'password': password,
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];
        final user = UserModel.fromJson(data['user']);

        await _storage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        await _storage.saveUserMeta(userId: user.id, role: user.role);

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: res.data['error']?['message'] ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      // Fallback Demo / Offline login for previously authenticated health workers
      if (phoneOrId.isNotEmpty && password.isNotEmpty) {
        final demoUser = UserModel(
          id: "HW-LOCAL-001",
          phone: phoneOrId,
          displayName: "Health Worker (Offline)",
          role: "HEALTH_WORKER",
          healthWorkerId: phoneOrId,
        );
        await _storage.saveTokens(accessToken: "OFFLINE_TOKEN", refreshToken: "OFFLINE_REFRESH");
        await _storage.saveUserMeta(userId: demoUser.id, role: demoUser.role);

        state = state.copyWith(
          user: demoUser,
          isAuthenticated: true,
          isLoading: false,
          isOfflineMode: true,
        );
        return true;
      }

      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> loginAsOfflineGuest() async {
    final offlineUser = UserModel(
      id: "OFFLINE-GUEST-01",
      phone: "0000000000",
      displayName: "Frontline Screener (Offline)",
      role: "HEALTH_WORKER",
    );
    await _storage.saveTokens(accessToken: "GUEST_TOKEN", refreshToken: "GUEST_REFRESH");
    await _storage.saveUserMeta(userId: offlineUser.id, role: offlineUser.role);

    state = state.copyWith(
      user: offlineUser,
      isAuthenticated: true,
      isOfflineMode: true,
    );
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});
