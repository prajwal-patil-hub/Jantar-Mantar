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
/// - Every device also has an **Ed25519 signing key pair** (ADR-29). AES-GCM
///   under a *shared* group key proves a message came from someone holding
///   the key — not from which member. The signature is what attributes it.
///
/// This module is transport-agnostic and fully offline-testable; Supabase is
/// only ever a carrier of the opaque ciphertext/sealed blobs.
/// Whether a message could be attributed to the member it claims to be from.
enum SenderSignature {
  /// Signed by the sender's published key over this exact group + epoch.
  valid,

  /// Signature failed, was malformed, or was **absent from a sender who has
  /// published a signing key** — the downgrade case.
  invalid,

  /// Nothing to check against: an older peer with no published signing key,
  /// or a roster this device has not fetched yet.
  unsigned,
}

class OpenedMessage {
  const OpenedMessage({required this.plaintext, required this.signature});

  final String plaintext;
  final SenderSignature signature;
}

class E2ECrypto {
  E2ECrypto({X25519? x25519, AesGcm? aead, Hkdf? hkdf, Ed25519? ed25519})
    : _x25519 = x25519 ?? X25519(),
      _aead = aead ?? AesGcm.with256bits(),
      _hkdf = hkdf ?? Hkdf(hmac: Hmac.sha256(), outputLength: 32),
      _ed25519 = ed25519 ?? Ed25519();

  final X25519 _x25519;
  final AesGcm _aead;
  final Hkdf _hkdf;
  final Ed25519 _ed25519;

  /// New device identity key pair (X25519).
  Future<SimpleKeyPair> generateIdentity() => _x25519.newKeyPair();

  /// Rebuild a key pair from the stored 32-byte private seed (secure storage).
  Future<SimpleKeyPair> identityFromPrivateKey(List<int> privateSeed) =>
      _x25519.newKeyPairFromSeed(privateSeed);

  /// New device **signing** key pair (Ed25519). Separate from the X25519
  /// identity because an X25519 key cannot sign — and keeping the roles
  /// separate means a future rotation of one does not force the other.
  Future<SimpleKeyPair> generateSigningKey() => _ed25519.newKeyPair();

  Future<SimpleKeyPair> signingKeyFromSeed(List<int> seed) =>
      _ed25519.newKeyPairFromSeed(seed);

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
  ///
  /// Pass [signingKey] and [context] to attribute the message to this device.
  /// [context] binds the ciphertext to one group and one key epoch, so a
  /// signed message cannot be lifted into another group or replayed under a
  /// different epoch and still verify.
  Future<String> encryptMessage({
    required List<int> groupKey,
    required String plaintext,
    SimpleKeyPair? signingKey,
    String? context,
  }) async {
    final box = await _aead.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(groupKey),
    );
    final envelope = <String, Object?>{
      'v': 1,
      'n': base64Encode(box.nonce),
      'ct': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    };
    if (signingKey != null) {
      final signature = await _ed25519.sign(
        _signedBytes(envelope, context),
        keyPair: signingKey,
      );
      envelope['sig'] = base64Encode(signature.bytes);
    }
    return _encode(envelope);
  }

  /// The exact bytes a sender signs: a domain separator, the group+epoch
  /// context, and the whole AEAD box. Anything outside this is unauthenticated
  /// and must not be trusted.
  List<int> _signedBytes(Map<String, Object?> envelope, String? context) =>
      utf8.encode(
        'commonground/msg-sig/v1|${context ?? ''}'
        '|${envelope['n']}|${envelope['ct']}|${envelope['mac']}',
      );

  /// Decrypt AND attribute in one step (ADR-29).
  ///
  /// The signature status is returned rather than thrown, because the three
  /// outcomes need three different UI treatments: a forged or tampered
  /// message must be called out, whereas one from a device that has not
  /// published a signing key yet is merely unverifiable.
  Future<OpenedMessage> openMessage({
    required List<int> groupKey,
    required String packed,
    required List<int>? senderSigningPublicKey,
    String? context,
  }) async {
    final envelope = _decode(packed);
    final plaintext = await _decryptEnvelope(envelope, groupKey);
    return OpenedMessage(
      plaintext: plaintext,
      signature: await _verify(envelope, senderSigningPublicKey, context),
    );
  }

  Future<SenderSignature> _verify(
    Map<String, Object?> envelope,
    List<int>? senderSigningPublicKey,
    String? context,
  ) async {
    final packedSig = envelope['sig'] as String?;

    if (packedSig == null) {
      // A sender who has published a signing key and then sends an unsigned
      // message is the downgrade attack, not an old client. Treat it as bad.
      return senderSigningPublicKey == null
          ? SenderSignature.unsigned
          : SenderSignature.invalid;
    }
    // Signed, but we have no key to check it against (offline before the
    // roster synced, or an old peer). Claiming "valid" here would be a lie.
    if (senderSigningPublicKey == null) return SenderSignature.unsigned;

    try {
      final ok = await _ed25519.verify(
        _signedBytes(envelope, context),
        signature: Signature(
          base64Decode(packedSig),
          publicKey: SimplePublicKey(
            senderSigningPublicKey,
            type: KeyPairType.ed25519,
          ),
        ),
      );
      return ok ? SenderSignature.valid : SenderSignature.invalid;
    } on Object {
      // Malformed signature or key: unverifiable is not verified.
      return SenderSignature.invalid;
    }
  }

  /// Decrypt a message; throws [SecretBoxAuthenticationError] on tamper or
  /// wrong key (the caller shows a "can't decrypt" placeholder).
  Future<String> decryptMessage({
    required List<int> groupKey,
    required String packed,
  }) => _decryptEnvelope(_decode(packed), groupKey);

  Future<String> _decryptEnvelope(
    Map<String, Object?> envelope,
    List<int> groupKey,
  ) async {
    final box = SecretBox(
      base64Decode(envelope['ct'] as String),
      nonce: base64Decode(envelope['n'] as String),
      mac: Mac(base64Decode(envelope['mac'] as String)),
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
