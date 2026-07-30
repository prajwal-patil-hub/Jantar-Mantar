import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'e2e_crypto.dart';
import 'key_store.dart';

/// Loads (or creates on first run) this device's key pairs. Both 32-byte
/// private seeds live in the OS keystore and never leave the device; only the
/// public halves are ever shared.
///
/// Two keys, two jobs (ADR-29):
/// - **X25519 identity** — sealed group-key delivery (ECDH). Cannot sign.
/// - **Ed25519 signing** — attributes a message to this device. Needed
///   because AES-GCM under a *shared* group key proves only that the sender
///   held the key, not which member they are.
class DeviceIdentityService {
  DeviceIdentityService(this._crypto, this._store);

  static const _seedKey = 'device_identity_x25519_seed_v1';
  static const _signingSeedKey = 'device_signing_ed25519_seed_v1';

  final E2ECrypto _crypto;
  final KeyStore _store;

  SimpleKeyPair? _cached;
  SimpleKeyPair? _cachedSigning;

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

  /// The Ed25519 signing key pair, created on first use.
  Future<SimpleKeyPair> signingKey() async {
    if (_cachedSigning != null) return _cachedSigning!;

    final existing = await _store.read(_signingSeedKey);
    if (existing != null) {
      _cachedSigning = await _crypto.signingKeyFromSeed(base64Decode(existing));
      return _cachedSigning!;
    }

    final key = await _crypto.generateSigningKey();
    await _store.write(
      _signingSeedKey,
      base64Encode(await key.extractPrivateKeyBytes()),
    );
    _cachedSigning = key;
    return key;
  }

  Future<String> signingPublicKeyBase64() async {
    final key = await signingKey();
    return encodePublicKey(await key.extractPublicKey());
  }

  /// Panic-wipe hook (Phase 2): forget both identities so seized devices
  /// reveal nothing. Callers also clear group keys.
  Future<void> wipe() async {
    _cached = null;
    _cachedSigning = null;
    await _store.delete(_seedKey);
    await _store.delete(_signingSeedKey);
  }
}
