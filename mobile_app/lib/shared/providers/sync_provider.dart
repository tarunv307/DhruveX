import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/storage/local_db.dart';
import '../../core/networking/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/sync_queue_item.dart';
import 'auth_provider.dart';

class SyncState {
  final int pendingCount;
  final bool isSyncing;
  final String? lastSyncTime;
  final String? lastError;

  SyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastError,
  });

  SyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    String? lastSyncTime,
    String? lastError,
  }) {
    return SyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastError: lastError ?? this.lastError,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final ApiClient _apiClient;
  final LocalDatabase _localDb = LocalDatabase.instance;
  final _uuid = const Uuid();

  SyncNotifier(this._apiClient) : super(SyncState()) {
    refreshPendingCount();
  }

  Future<void> refreshPendingCount() async {
    try {
      final db = await _localDb.database;
      final count = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM sync_queue WHERE status = 'PENDING'"),
      ) ?? 0;
      state = state.copyWith(pendingCount: count);
    } catch (_) {}
  }

  Future<void> enqueueItem({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = await _localDb.database;
    final item = SyncQueueItem(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payloadJson: jsonEncode(payload),
      status: 'PENDING',
    );

    await db.insert('sync_queue', item.toMap());
    await refreshPendingCount();
  }

  Future<bool> syncNow() async {
    if (state.isSyncing) return false;
    state = state.copyWith(isSyncing: true, lastError: null);

    try {
      final db = await _localDb.database;
      final pendingRows = await db.query(
        'sync_queue',
        where: "status = 'PENDING'",
        limit: 50,
      );

      if (pendingRows.isEmpty) {
        state = state.copyWith(
          isSyncing: false,
          pendingCount: 0,
          lastSyncTime: DateTime.now().toLocal().toString().substring(0, 16),
        );
        return true;
      }

      final items = pendingRows.map((r) => SyncQueueItem.fromMap(r)).toList();
      final idempotencyKey = _uuid.v4();

      final batchPayload = {
        'idempotency_key': idempotencyKey,
        'client_device_id': 'FLUTTER-CLIENT',
        'items': items.map((it) => {
          'entity_type': it.entityType,
          'entity_id': it.entityId,
          'operation': it.operation,
          'data': jsonDecode(it.payloadJson),
        }).toList(),
      };

      final res = await _apiClient.post(ApiConstants.syncBatch, data: batchPayload);

      if (res.statusCode == 200 || res.statusCode == 201) {
        // Mark items completed in local DB
        for (var it in items) {
          await db.update(
            'sync_queue',
            {'status': 'COMPLETED', 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [it.id],
          );
        }

        await refreshPendingCount();
        state = state.copyWith(
          isSyncing: false,
          lastSyncTime: DateTime.now().toLocal().toString().substring(0, 16),
        );
        return true;
      } else {
        state = state.copyWith(
          isSyncing: false,
          lastError: 'Server returned error status during sync',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Offline: Data stored locally. Will sync when online.',
      );
      return false;
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref.watch(apiClientProvider));
});
