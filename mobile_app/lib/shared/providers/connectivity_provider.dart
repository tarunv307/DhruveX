import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/networking/network_info.dart';

final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  final netInfo = ref.watch(networkInfoProvider);
  return netInfo.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final asyncVal = ref.watch(connectivityStreamProvider);
  return asyncVal.maybeWhen(
    data: (res) => res != ConnectivityResult.none,
    orElse: () => true, // default optimistic
  );
});
