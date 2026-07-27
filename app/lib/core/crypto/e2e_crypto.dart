import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// End-to-end encryption primitives for group chat (ADR-16).
///
/// Design (server never sees plaintext or any private key):
/// - Every device has an **X25519 identity key pair**. Only the public key is
///   ever uploaded; the private key stays in secure storage.
/// - Each group has a random 256-bit **group key**. Messages are encrypted
///   with AES-GCM-256 under that key, so the server stores ciphertext only.
/// - To hand the group key to a new member we use a **sealed box (ECIES)**:
///   an ephemeral X25519 key pair → ECDH with the member's public key → HKDF
///   → AES-GCM. Only the holder of the member's private key can open it.
///
/// This module is transport-agnostic and fully offline-testable; Supabase is
/// only ever a carrier of the opaque ciphertext/sealed blobs.
class E2ECrypto {
  E2ECrypto({X25519? x25519, AesGcm? aead, Hkdf? hkdf})
    : _x25519 = x25519 ?? X25519(),
      _aead = aead ?? AesGcm.with256bits(),
      _hkdf = hkdf ?? Hkdf(hmac: Hmac.sha256(), outputLength: 32);

  final X25519 _x25519;
  final AesGcm _aead;
  final Hkdf _hkdf;

  /// New device identity key pair (X25519).
  Future<SimpleKeyPair> generateIdentity() => _x25519.newKeyPair();

  /// Rebuild a key pair from the stored 32-byte private seed (secure storage).
  Future<SimpleKeyPair> identityFromPrivateKey(List<int> privateSeed) =>
      _x25519.newKeyPairFromSeed(privateSeed);

  /// Fresh random 256-bit symmetric group key.
  List<int> generateGroupKey() => SecretKeyData.random(length: 32).bytes;

  /// Seal [groupKey] so only the holder of [recipientPublicKey]'s private key
  /// can open it. Returns a compact, transport-safe string.
  Future<String> sealGroupKey({
    required List<int> groupKey,
    required List<int> recipientPublicKey,
  }) async {
    final ephemeral = await _x25519.newKeyPair();
    final shared = await _x25519.sharedSecretKey(
      keyPair: ephemeral,
      remotePublicKey: SimplePublicKey(
        recipientPublicKey,
        type: KeyPairType.x25519,
      ),
    );
    final wrapKey = await _deriveWrapKey(shared);
    final box = await _aead.encrypt(groupKey, secretKey: wrapKey);
    final ephemeralPub = await ephemeral.extractPublicKey();
    return _encode({
      'v': 1,
      'epk': base64Encode(ephemeralPub.bytes),
      'n': base64Encode(box.nonce),
      'ct': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Open a sealed group key with the recipient's own identity key pair.
  Future<List<int>> openGroupKey({
    required String sealed,
    required SimpleKeyPair identity,
  }) async {
    final m = _decode(sealed);
    final shared = await _x25519.sharedSecretKey(
      keyPair: identity,
      remotePublicKey: SimplePublicKey(
        base64Decode(m['epk'] as String),
        type: KeyPairType.x25519,
      ),
    );
    final wrapKey = await _deriveWrapKey(shared);
    final box = SecretBox(
      base64Decode(m['ct'] as String),
      nonce: base64Decode(m['n'] as String),
      mac: Mac(base64Decode(m['mac'] as String)),
    );
    return _aead.decrypt(box, secretKey: wrapKey);
  }

  /// Encrypt a chat message under the group key. Output is opaque base64 the
  /// server stores verbatim.
  Future<String> encryptMessage({
    required List<int> groupKey,
    required String plaintext,
  }) async {
    final box = await _aead.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(groupKey),
    );
    return _encode({
      'v': 1,
      'n': base64Encode(box.nonce),
      'ct': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Decrypt a message; throws [SecretBoxAuthenticationError] on tamper or
  /// wrong key (the caller shows a "can't decrypt" placeholder).
  Future<String> decryptMessage({
    required List<int> groupKey,
    required String packed,
  }) async {
    final m = _decode(packed);
    final box = SecretBox(
      base64Decode(m['ct'] as String),
      nonce: base64Decode(m['n'] as String),
      mac: Mac(base64Decode(m['mac'] as String)),
    );
    final clear = await _aead.decrypt(box, secretKey: SecretKey(groupKey));
    return utf8.decode(clear);
  }

  Future<SecretKey> _deriveWrapKey(SecretKey shared) => _hkdf.deriveKey(
    secretKey: shared,
    info: utf8.encode('commonground/group-key-wrap/v1'),
  );

  String _encode(Map<String, Object?> m) =>
      base64Encode(utf8.encode(jsonEncode(m)));

  Map<String, Object?> _decode(String s) =>
      jsonDecode(utf8.decode(base64Decode(s))) as Map<String, Object?>;
}

/// Base64 of a public key, as published to the server / embedded in invites.
String encodePublicKey(SimplePublicKey key) => base64Encode(key.bytes);

Uint8List decodePublicKey(String encoded) => base64Decode(encoded);
