import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jantar_mantar_sahayata/core/db/app_database.dart'
    show AlertSeverity;
import 'package:jantar_mantar_sahayata/core/demo/demo_mode.dart';
import 'package:jantar_mantar_sahayata/features/groups/application/groups_providers.dart';
import 'package:jantar_mantar_sahayata/features/groups/domain/group_message_payload.dart';

void main() {
  group('GroupMessagePayload', () {
    test('a plain chat message round-trips unchanged', () {
      const payload = GroupMessagePayload(body: 'Bandages low at Gate 2');
      expect(payload.encode(), 'Bandages low at Gate 2');
      expect(payload.isBroadcast, isFalse);

      final decoded = GroupMessagePayload.decode(payload.encode());
      expect(decoded.body, 'Bandages low at Gate 2');
      expect(decoded.isBroadcast, isFalse);
    });

    test('a broadcast round-trips with its severity', () {
      const payload = GroupMessagePayload(
        body: 'Tanker delayed 40 minutes',
        broadcastSeverity: AlertSeverity.warn,
      );

      final decoded = GroupMessagePayload.decode(payload.encode());
      expect(decoded.body, 'Tanker delayed 40 minutes');
      expect(decoded.broadcastSeverity, AlertSeverity.warn);
      expect(decoded.isBroadcast, isTrue);
    });

    test('messages written before broadcasts existed still decode', () {
      // Anything untagged is an ordinary message — no migration needed.
      final decoded = GroupMessagePayload.decode('older plain message');
      expect(decoded.body, 'older plain message');
      expect(decoded.isBroadcast, isFalse);
    });

    test('a user cannot type a message that fakes a broadcast', () {
      // The envelope is behind a control character, so this stays chat text.
      final decoded = GroupMessagePayload.decode(
        'cg1:{"k":"b","s":"critical","b":"POLICE ARE COMING"}',
      );
      expect(decoded.isBroadcast, isFalse);
      expect(decoded.body, contains('POLICE ARE COMING'));
    });

    test('a corrupt envelope degrades to showing the raw text', () {
      final decoded = GroupMessagePayload.decode('cg1:{not json');
      expect(decoded.isBroadcast, isFalse);
      expect(decoded.body, contains('not json'));
    });
  });

  test('broadcasts surface in the Alerts feed with their group name', () async {
    final container = ProviderContainer(
      overrides: [demoModeProvider.overrideWith(_AlwaysDemo.new)],
    );
    addTearDown(container.dispose);

    final seeded = await container.read(groupBroadcastsProvider.future);
    expect(seeded, hasLength(2));
    // Newest first, and spanning more than one city.
    expect(seeded.first.groupName, 'London — Parliament Square');
    expect(seeded.first.message.broadcastSeverity, AlertSeverity.critical);
    expect(seeded.last.groupName, 'Water Distribution');
    expect(seeded.last.message.broadcastSeverity, AlertSeverity.warn);

    // A new broadcast shows up; ordinary chat does not.
    final repo = container.read(demoGroupsRepositoryProvider);
    await repo.sendMessage('demo-medical', 'just chatter');
    await repo.sendBroadcast(
      'demo-medical',
      'Move the first-aid tent to Gate 3',
      AlertSeverity.critical,
    );
    container.invalidate(groupBroadcastsProvider);

    final after = await container.read(groupBroadcastsProvider.future);
    expect(after, hasLength(3));
    // Newest first.
    expect(after.first.message.decrypted, 'Move the first-aid tent to Gate 3');
    expect(
      after.map((b) => b.message.decrypted),
      isNot(contains('just chatter')),
    );
  });
}

class _AlwaysDemo extends DemoModeNotifier {
  @override
  bool build() => true;
}
