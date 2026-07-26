import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/core/db/app_database.dart';
import 'package:jantar_mantar_sahayata/core/demo/demo_mode.dart';
import 'package:jantar_mantar_sahayata/core/providers.dart';
import 'package:jantar_mantar_sahayata/features/groups/application/groups_providers.dart';
import 'package:jantar_mantar_sahayata/features/groups/data/demo_groups_repository.dart';
import 'package:jantar_mantar_sahayata/features/groups/domain/group_models.dart';
import 'package:jantar_mantar_sahayata/features/groups/presentation/groups_screen.dart';

import '../../support/l10n_harness.dart';

void main() {
  group('DemoGroupsRepository', () {
    test('seeds sample groups, members, messages and pins', () async {
      final repo = DemoGroupsRepository();

      final groups = await repo.myGroups();
      expect(groups, hasLength(3));
      expect(groups.first.name, 'Medical Volunteers');
      expect(groups.first.isAdmin, isTrue);

      final members = await repo.members('demo-medical');
      expect(members, hasLength(4));
      expect(
        members.any((m) => m.state == MemberState.pending),
        isTrue,
        reason: 'a pending request makes the Approve button visible',
      );

      expect(await repo.messages('demo-medical'), hasLength(3));
      expect(await repo.pins('demo-medical'), hasLength(2));
    });

    test('sending a message appends it as mine', () async {
      final repo = DemoGroupsRepository();
      await repo.sendMessage('demo-medical', 'Testing 1 2 3');

      final messages = await repo.messages('demo-medical');
      expect(messages.last.decrypted, 'Testing 1 2 3');
      expect(messages.last.mine, isTrue);
    });

    test('approving a pending member activates them', () async {
      final repo = DemoGroupsRepository();
      await repo.approveMember('demo-medical', 'demo-priya');

      final members = await repo.members('demo-medical');
      final priya = members.firstWhere((m) => m.userId == 'demo-priya');
      expect(priya.state, MemberState.active);
    });

    test('removing a member drops them from the roster', () async {
      final repo = DemoGroupsRepository();
      expect(await repo.removeMember('demo-medical', 'demo-rahul'), 0);

      final members = await repo.members('demo-medical');
      expect(members.any((m) => m.userId == 'demo-rahul'), isFalse);
      expect(members, hasLength(3));
    });

    test(
      'exactly one roster row is flagged as me, so I cannot remove myself',
      () async {
        final repo = DemoGroupsRepository();
        for (final group in await repo.myGroups()) {
          final members = await repo.members(group.id);
          expect(members.where((m) => m.isMe), hasLength(1));
        }
      },
    );

    test('creating a group makes you its admin', () async {
      final repo = DemoGroupsRepository();
      final created = await repo.createGroup(name: 'Gate 4 crew');

      expect(created.isAdmin, isTrue);
      expect((await repo.myGroups()).first.name, 'Gate 4 crew');
    });
  });

  test('group pins map layer is off by default and collects when on', () async {
    final container = ProviderContainer(
      overrides: [demoModeProvider.overrideWith(() => _AlwaysDemo())],
    );
    addTearDown(container.dispose);

    // Off by default: the public verified map stays the default view.
    expect(container.read(showGroupPinsProvider), isFalse);
    expect(await container.read(groupPinsForMapProvider.future), isEmpty);

    container.read(showGroupPinsProvider.notifier).toggle();
    final pins = await container.read(groupPinsForMapProvider.future);
    expect(pins, isNotEmpty);
    expect(pins.map((p) => p.groupName), contains('Medical Volunteers'));
    expect(pins.map((p) => p.pin.label), contains('First-aid tent (main)'));
  });

  testWidgets('Groups tab shows demo groups and Create with no backend', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        // No Supabase client at all — demo mode must still work.
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: testSupportedLocales,
          home: const GroupsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create group'), findsOneWidget);
    expect(find.text('Medical Volunteers'), findsOneWidget);
    expect(find.text('Water Distribution'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}

class _AlwaysDemo extends DemoModeNotifier {
  @override
  bool build() => true;
}
