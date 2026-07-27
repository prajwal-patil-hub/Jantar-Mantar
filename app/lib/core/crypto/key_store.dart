import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal secret store abstraction so the identity service is testable and
/// platform-agnostic. Production uses the OS keystore (Android Keystore /
/// iOS Keychain) via flutter_secure_storage.
abstract interface class KeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  /// Drop every secret this app holds. Used by panic-wipe, where enumerating
  /// key names would be a way to miss one.
  Future<void> deleteAll();
}

class SecureKeyStore implements KeyStore {
  const SecureKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}

/// In-memory store for tests (no platform channels).
class InMemoryKeyStore implements KeyStore {
  final _map = <String, String>{};

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;

  @override
  Future<void> delete(String key) async => _map.remove(key);

  @override
  Future<void> deleteAll() async => _map.clear();
}
