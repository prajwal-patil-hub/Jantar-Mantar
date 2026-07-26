import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jantar_mantar_sahayata/features/groups/application/groups_providers.dart';
import 'package:jantar_mantar_sahayata/features/groups/data/groups_repo.dart';
import 'package:jantar_mantar_sahayata/features/groups/domain/group_models.dart';
import 'package:jantar_mantar_sahayata/features/groups/presentation/group_detail_screen.dart';

import '../../support/l10n_harness.dart';

/// A repo that has chat cached on the device but no working network — the
/// case the offline-first rule exists for.
class _OfflineRepo implements GroupsRepo {
  _OfflineRepo({required this.cached});

  List<GroupMessage> cached;
  int refreshAttempts = 0;

  @override
  Future<List<GroupMessage>> cachedMessages(String groupId) async => cached;

  @override
  Future<List<GroupMessage>> messages(String groupId) async {
    refreshAttempts++;
    throw StateError('no network');
  }

  @override
  Future<void> sendMessage(String groupId, String text) async {
    // Encrypted and queued locally; the server never sees it yet.
    cached = [
      ...cached,
      GroupMessage(
        id: 'local:1',
        senderId: 'me',
        createdAt: DateTime.now(),
        decrypted: text,
        mine: true,
        pending: true,
      ),
    ];
  }

  @override
  Future<List<GroupMember>> members(String groupId) async => const [];
  @override
  Future<List<GroupPin>> pins(String groupId) async => const [];
  @override
  Future<List<Group>> myGroups() async => const [];
  @override
  Future<Group> createGroup({
    required String name,
    String? description,
    String visibility = 'hidden',
  }) async => throw UnimplementedError();
  @override
  Future<void> approveMember(String groupId, String userId) async {}
  @override
  Future<void> addPin({
    required String groupId,
    required String type,
    required String label,
    required double lat,
    required double lng,
    String? note,
  }) async {}
  @override
  Future<String> createInvite(String groupId) async => 'CODE';
  @override
  Future<String> joinByCode(String code) async => 'group';
}

const _group = Group(
  id: 'g1',
  name: 'Medical Volunteers',
  description: null,
  visibility: 'hidden',
  myRole: GroupRole.admin,
  myState: MemberState.active,
);

Future<void> _pumpChat(WidgetTester tester, _OfflineRepo repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [groupsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: testSupportedLocales,
        home: const GroupDetailScreen(group: _group),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('offline chat renders cached messages and says it is offline', (
    tester,
  ) async {
    final repo = _OfflineRepo(
      cached: [
        GroupMessage(
          id: 'm1',
          senderId: 'asha',
          createdAt: DateTime.now(),
          decrypted: 'Bandages low at Gate 2',
          mine: false,
        ),
      ],
    );

    await _pumpChat(tester, repo);

    // The conversation is readable with no network at all…
    expect(find.text('Bandages low at Gate 2'), findsOneWidget);
    // …and the degraded state is visible (icon + text, not colour alone).
    expect(find.text('Offline — showing saved messages'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    expect(repo.refreshAttempts, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('a message composed offline is queued and marked Sending', (
    tester,
  ) async {
    final repo = _OfflineRepo(cached: []);
    await _pumpChat(tester, repo);

    await tester.enterText(find.byType(TextField), 'Need water at Gate 3');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Sending offline is not an error: the message is kept and shown queued.
    expect(find.text('Need water at Gate 3'), findsOneWidget);
    expect(find.text('Sending…'), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
