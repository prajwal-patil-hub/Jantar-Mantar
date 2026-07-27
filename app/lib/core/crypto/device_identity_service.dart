import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'e2e_crypto.dart';
import 'key_store.dart';

/// Loads (or creates on first run) this device's X25519 identity key pair.
/// The 32-byte private seed lives in the OS keystore and never leaves the
/// device; only the public key is ever shared (for sealed group-key delivery).
class DeviceIdentityService {
  DeviceIdentityService(this._crypto, this._store);

  static const _seedKey = 'device_identity_x25519_seed_v1';

  final E2ECrypto _crypto;
  final KeyStore _store;

  SimpleKeyPair? _cached;

  Future<SimpleKeyPair> loadOrCreate() async {
    if (_cached != null) return _cached!;

    final existing = await _store.read(_seedKey);
    if (existing != null) {
      _cached = await _crypto.identityFromPrivateKey(base64Decode(existing));
      return _cached!;
    }

    final identity = await _crypto.generateIdentity();
    final seed = await identity.extractPrivateKeyBytes();
    await _store.write(_seedKey, base64Encode(seed));
    _cached = identity;
    return identity;
  }

  Future<String> publicKeyBase64() async {
    final identity = await loadOrCreate();
    final pub = await identity.extractPublicKey();
    return encodePublicKey(pub);
  }

  /// Panic-wipe hook (Phase 2): forget the identity so seized devices reveal
  /// nothing. Callers also clear group keys.
  Future<void> wipe() async {
    _cached = null;
    await _store.delete(_seedKey);
  }
}
