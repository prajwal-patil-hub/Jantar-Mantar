import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/crypto/device_identity_service.dart';
import 'package:jantar_mantar_sahayata/core/crypto/e2e_crypto.dart';
import 'package:jantar_mantar_sahayata/core/crypto/key_store.dart';

void main() {
  test('loadOrCreate persists one identity and returns it stably', () async {
    final store = InMemoryKeyStore();
    final crypto = E2ECrypto();

    final service = DeviceIdentityService(crypto, store);
    final first = await service.publicKeyBase64();
    final second = await service.publicKeyBase64();
    expect(first, second);

    // A fresh service instance reading the same store gets the same identity
    // (persisted, not regenerated).
    final reloaded = DeviceIdentityService(crypto, store);
    expect(await reloaded.publicKeyBase64(), first);
  });

  test(
    'wipe forgets the identity; a new one is generated afterwards',
    () async {
      final store = InMemoryKeyStore();
      final service = DeviceIdentityService(E2ECrypto(), store);

      final before = await service.publicKeyBase64();
      await service.wipe();
      final after = await service.publicKeyBase64();
      expect(after, isNot(before));
    },
  );
}
