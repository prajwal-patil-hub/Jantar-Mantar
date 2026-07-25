import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/crypto/e2e_crypto.dart';

void main() {
  final crypto = E2ECrypto();

  test('a sealed group key round-trips to the intended recipient', () async {
    final alice = await crypto.generateIdentity();
    final bob = await crypto.generateIdentity();
    final groupKey = crypto.generateGroupKey();
    expect(groupKey, hasLength(32));

    final bobPub = (await bob.extractPublicKey()).bytes;
    final sealed = await crypto.sealGroupKey(
      groupKey: groupKey,
      recipientPublicKey: bobPub,
    );

    final opened = await crypto.openGroupKey(sealed: sealed, identity: bob);
    expect(opened, groupKey);

    // Alice (not the recipient) cannot open Bob's sealed key.
    await expectLater(
      crypto.openGroupKey(sealed: sealed, identity: alice),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('messages encrypt and decrypt under the group key', () async {
    final groupKey = crypto.generateGroupKey();
    const plaintext = 'Meet at Gate 3 — पानी खत्म हो रहा है';

    final packed = await crypto.encryptMessage(
      groupKey: groupKey,
      plaintext: plaintext,
    );
    expect(packed, isNot(contains('Gate 3'))); // opaque ciphertext

    final decrypted = await crypto.decryptMessage(
      groupKey: groupKey,
      packed: packed,
    );
    expect(decrypted, plaintext);
  });

  test('a wrong group key cannot decrypt a message', () async {
    final groupKey = crypto.generateGroupKey();
    final wrongKey = crypto.generateGroupKey();
    final packed = await crypto.encryptMessage(
      groupKey: groupKey,
      plaintext: 'secret',
    );

    await expectLater(
      crypto.decryptMessage(groupKey: wrongKey, packed: packed),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('each encryption uses a fresh nonce (ciphertexts differ)', () async {
    final groupKey = crypto.generateGroupKey();
    final a = await crypto.encryptMessage(groupKey: groupKey, plaintext: 'hi');
    final b = await crypto.encryptMessage(groupKey: groupKey, plaintext: 'hi');
    expect(a, isNot(b));
  });

  test('identity can be restored from its private seed', () async {
    final identity = await crypto.generateIdentity();
    final seed = await identity.extractPrivateKeyBytes();
    final pub = (await identity.extractPublicKey()).bytes;

    final restored = await crypto.identityFromPrivateKey(seed);
    final restoredPub = (await restored.extractPublicKey()).bytes;
    expect(restoredPub, pub);

    // A key sealed to the original public key opens with the restored identity.
    final groupKey = crypto.generateGroupKey();
    final sealed = await crypto.sealGroupKey(
      groupKey: groupKey,
      recipientPublicKey: pub,
    );
    expect(
      await crypto.openGroupKey(sealed: sealed, identity: restored),
      groupKey,
    );
  });
}
