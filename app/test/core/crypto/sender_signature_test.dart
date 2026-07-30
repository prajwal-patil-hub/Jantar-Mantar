import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/crypto/device_identity_service.dart';
import 'package:jantar_mantar_sahayata/core/crypto/e2e_crypto.dart';
import 'package:jantar_mantar_sahayata/core/crypto/key_store.dart';

/// Cryptographic sender attribution (ADR-29).
///
/// The threat this exists for: AES-GCM under a key SHARED by the whole group
/// proves a message came from *someone holding the key*, not from which
/// member. Without a signature, any member could originate a message
/// attributed to any other the moment the transport is not a server stamping
/// sender_id — a forged "the medical tent has moved" from a trusted organiser.
///
/// So the tests that matter are the forgeries.
void main() {
  final crypto = E2ECrypto();

  const groupId = 'group-1';
  const epoch = 3;
  const context = '$groupId|$epoch';

  test(
    'a signed message verifies against the sender\'s published key',
    () async {
      final key = crypto.generateGroupKey();
      final asha = await crypto.generateSigningKey();

      final packed = await crypto.encryptMessage(
        groupKey: key,
        plaintext: 'Medical tent is at Gate 2',
        signingKey: asha,
        context: context,
      );

      final opened = await crypto.openMessage(
        groupKey: key,
        packed: packed,
        senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
        context: context,
      );

      expect(opened.plaintext, 'Medical tent is at Gate 2');
      expect(opened.signature, SenderSignature.valid);
    },
  );

  test(
    'THE ATTACK: another member holding the group key cannot forge',
    () async {
      // Ravi is a legitimate member — he has the group key. He composes a
      // message and tries to pass it off as Asha's.
      final key = crypto.generateGroupKey();
      final asha = await crypto.generateSigningKey();
      final ravi = await crypto.generateSigningKey();

      final forged = await crypto.encryptMessage(
        groupKey: key,
        plaintext: 'Medical tent has MOVED to the far side',
        signingKey: ravi,
        context: context,
      );

      final opened = await crypto.openMessage(
        groupKey: key,
        packed: forged,
        // Recipients look up Asha's key, because the row claims Asha sent it.
        senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
        context: context,
      );

      // It still decrypts — he had the group key — but it is not from Asha.
      expect(opened.plaintext, contains('MOVED'));
      expect(opened.signature, SenderSignature.invalid);
    },
  );

  test('THE DOWNGRADE: dropping the signature does not buy silence', () async {
    // The obvious way around a signature scheme is to simply not sign. That
    // is indistinguishable from an old client UNLESS the sender has already
    // published a signing key — which is what makes this checkable.
    final key = crypto.generateGroupKey();
    final asha = await crypto.generateSigningKey();

    final unsigned = await crypto.encryptMessage(
      groupKey: key,
      plaintext: 'Trust me',
    );

    final asAsha = await crypto.openMessage(
      groupKey: key,
      packed: unsigned,
      senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
      context: context,
    );
    expect(
      asAsha.signature,
      SenderSignature.invalid,
      reason: 'a sender with a published key must not send unsigned',
    );

    // The same bytes from a peer that has never published a key is an old
    // client, not an attack: unverifiable, but not called a forgery.
    final asOldPeer = await crypto.openMessage(
      groupKey: key,
      packed: unsigned,
      senderSigningPublicKey: null,
      context: context,
    );
    expect(asOldPeer.signature, SenderSignature.unsigned);
  });

  test('a signature does not carry across groups', () async {
    final key = crypto.generateGroupKey();
    final asha = await crypto.generateSigningKey();

    final packed = await crypto.encryptMessage(
      groupKey: key,
      plaintext: 'Water is out at Gate 1',
      signingKey: asha,
      context: context,
    );

    // Replayed into a different group (same key would have to leak too, but
    // the binding must hold regardless).
    final opened = await crypto.openMessage(
      groupKey: key,
      packed: packed,
      senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
      context: 'group-2|$epoch',
    );
    expect(opened.signature, SenderSignature.invalid);
  });

  test('a signature does not carry across key epochs', () async {
    final key = crypto.generateGroupKey();
    final asha = await crypto.generateSigningKey();

    final packed = await crypto.encryptMessage(
      groupKey: key,
      plaintext: 'Shelter is full',
      signingKey: asha,
      context: context,
    );

    final opened = await crypto.openMessage(
      groupKey: key,
      packed: packed,
      senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
      context: '$groupId|${epoch + 1}',
    );
    expect(
      opened.signature,
      SenderSignature.invalid,
      reason: 'a message re-sealed to a new epoch must be re-signed',
    );
  });

  test('tampering with the ciphertext breaks the signature too', () async {
    final key = crypto.generateGroupKey();
    final asha = await crypto.generateSigningKey();

    final packed = await crypto.encryptMessage(
      groupKey: key,
      plaintext: 'Legal aid at the north gate',
      signingKey: asha,
      context: context,
    );

    // Flip a character inside the base64 envelope.
    final tampered = packed.replaceRange(10, 11, packed[10] == 'A' ? 'B' : 'A');
    await expectLater(
      crypto.openMessage(
        groupKey: key,
        packed: tampered,
        senderSigningPublicKey: (await asha.extractPublicKey()).bytes,
        context: context,
      ),
      throwsA(anything),
      reason: 'AEAD rejects it before the signature is even consulted',
    );
  });

  test('a garbage signature is invalid, never an exception', () async {
    final key = crypto.generateGroupKey();
    final asha = await crypto.generateSigningKey();
    final packed = await crypto.encryptMessage(
      groupKey: key,
      plaintext: 'hello',
      signingKey: asha,
      context: context,
    );

    final opened = await crypto.openMessage(
      groupKey: key,
      packed: packed,
      // Wrong length / not a real Ed25519 key — must not crash the chat.
      senderSigningPublicKey: const [1, 2, 3],
      context: context,
    );
    expect(opened.signature, SenderSignature.invalid);
  });

  group('device identity', () {
    test(
      'the signing key is separate, stable and wiped with the rest',
      () async {
        final store = InMemoryKeyStore();
        final service = DeviceIdentityService(crypto, store);

        final signing = await service.signingPublicKeyBase64();
        final identity = await service.publicKeyBase64();
        expect(signing, isNotEmpty);
        // Two keys, two jobs — an X25519 key cannot sign.
        expect(signing, isNot(identity));

        // Stable across reloads: a rotating key would orphan every past
        // signature in the group's history.
        final reloaded = DeviceIdentityService(crypto, store);
        expect(await reloaded.signingPublicKeyBase64(), signing);

        // Panic-wipe must take BOTH seeds, or a seized device still holds a key
        // that can sign as its owner.
        await service.wipe();
        final after = DeviceIdentityService(crypto, store);
        expect(await after.signingPublicKeyBase64(), isNot(signing));
      },
    );

    test('the stored signing key really is the one that signs', () async {
      final store = InMemoryKeyStore();
      final service = DeviceIdentityService(crypto, store);
      final key = crypto.generateGroupKey();

      final packed = await crypto.encryptMessage(
        groupKey: key,
        plaintext: 'from this device',
        signingKey: await service.signingKey(),
        context: context,
      );

      final published = await service.signingPublicKeyBase64();
      final opened = await crypto.openMessage(
        groupKey: key,
        packed: packed,
        senderSigningPublicKey: decodePublicKey(published),
        context: context,
      );
      expect(opened.signature, SenderSignature.valid);
    });
  });
}
