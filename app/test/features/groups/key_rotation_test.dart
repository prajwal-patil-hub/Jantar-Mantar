import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/crypto/e2e_crypto.dart';

/// Rotation is a crypto property, not a UI one: after a member is removed the
/// group mints a new epoch key that is sealed only to the members who remain.
/// These assert what the removed device CAN and CANNOT do.
void main() {
  late E2ECrypto crypto;

  setUp(() => crypto = E2ECrypto());

  test('a removed member cannot read messages sent after rotation', () async {
    final stayed = await crypto.generateIdentity();
    final removed = await crypto.generateIdentity();

    // Epoch 1: both hold the key.
    final epoch1 = crypto.generateGroupKey();
    final sealedForRemoved = await crypto.openGroupKey(
      sealed: await crypto.sealGroupKey(
        groupKey: epoch1,
        recipientPublicKey: (await removed.extractPublicKey()).bytes,
      ),
      identity: removed,
    );
    expect(sealedForRemoved, epoch1, reason: 'they were a member at epoch 1');

    // Rotation: epoch 2 is sealed only to the members who remain.
    final epoch2 = crypto.generateGroupKey();
    final envelopeForStayed = await crypto.sealGroupKey(
      groupKey: epoch2,
      recipientPublicKey: (await stayed.extractPublicKey()).bytes,
    );

    final afterRemoval = await crypto.encryptMessage(
      groupKey: epoch2,
      plaintext: 'Regroup at Gate 4 at 6pm',
    );

    // The member who stayed reads it.
    expect(
      await crypto.decryptMessage(
        groupKey: await crypto.openGroupKey(
          sealed: envelopeForStayed,
          identity: stayed,
        ),
        packed: afterRemoval,
      ),
      'Regroup at Gate 4 at 6pm',
    );

    // The removed device holds only epoch 1 — and it is useless here.
    await expectLater(
      crypto.decryptMessage(groupKey: epoch1, packed: afterRemoval),
      throwsA(anything),
    );
    // It also cannot open the new envelope, which was not sealed to it.
    await expectLater(
      crypto.openGroupKey(sealed: envelopeForStayed, identity: removed),
      throwsA(anything),
    );
  });

  test(
    'old epochs stay readable, so history is not lost on rotation',
    () async {
      final epoch1 = crypto.generateGroupKey();
      final epoch2 = crypto.generateGroupKey();

      final old = await crypto.encryptMessage(
        groupKey: epoch1,
        plaintext: 'Bandages low at Gate 2',
      );
      final fresh = await crypto.encryptMessage(
        groupKey: epoch2,
        plaintext: 'Resupplied',
      );

      // A device that kept both keys reads the whole conversation — which is
      // why the cache stores the epoch alongside each ciphertext.
      final keys = {1: epoch1, 2: epoch2};
      expect(
        await crypto.decryptMessage(groupKey: keys[1]!, packed: old),
        'Bandages low at Gate 2',
      );
      expect(
        await crypto.decryptMessage(groupKey: keys[2]!, packed: fresh),
        'Resupplied',
      );
    },
  );

  test('re-sealing a queued message moves it to the current epoch', () async {
    final epoch1 = crypto.generateGroupKey();
    final epoch2 = crypto.generateGroupKey();

    // Typed while offline, before the rotation.
    final queued = await crypto.encryptMessage(
      groupKey: epoch1,
      plaintext: 'On my way',
    );
    // What _flushPending does before sending it.
    final resealed = await crypto.encryptMessage(
      groupKey: epoch2,
      plaintext: await crypto.decryptMessage(groupKey: epoch1, packed: queued),
    );

    expect(
      await crypto.decryptMessage(groupKey: epoch2, packed: resealed),
      'On my way',
    );
    // The removed member's key cannot open the message that actually went out.
    await expectLater(
      crypto.decryptMessage(groupKey: epoch1, packed: resealed),
      throwsA(anything),
    );
  });
}
