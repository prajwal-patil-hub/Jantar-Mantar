import '../db/app_database.dart';

/// Transport for draining the sync queue. The Supabase implementation lands
/// with E5/E8; until then [UnconfiguredRemoteApi] keeps everything queued
/// locally, which is indistinguishable from being offline — by design.
abstract interface class RemoteSyncApi {
  /// Pushes one queue entry. Throwing marks the attempt failed and schedules
  /// a retry with backoff; returning normally marks it done.
  Future<void> push(SyncQueueEntry entry);
}

class RemoteUnavailable implements Exception {
  const RemoteUnavailable([this.message = 'Remote not reachable']);

  final String message;

  @override
  String toString() => 'RemoteUnavailable: $message';
}

class UnconfiguredRemoteApi implements RemoteSyncApi {
  const UnconfiguredRemoteApi();

  @override
  Future<void> push(SyncQueueEntry entry) async {
    throw const RemoteUnavailable('Backend not configured yet');
  }
}
