import 'dart:math';

import '../../../core/db/app_database.dart' show AlertSeverity;
import '../domain/group_models.dart';
import 'groups_repo.dart';

/// In-memory Groups implementation with realistic sample data, used by Demo
/// Mode so the whole Groups experience (chat, members, amenities, invites)
/// can be explored with NO backend and NO login.
///
/// Everything lives in memory for the session: messages you send appear
/// immediately, approvals work, created groups persist until reload. Nothing
/// is encrypted here because nothing leaves the device — the real
/// Supabase-backed repository is the one that does E2E crypto.
class DemoGroupsRepository implements GroupsRepo {
  DemoGroupsRepository() {
    _seed();
  }

  static const demoUserId = 'demo-you';

  final _groups = <Group>[];
  final _members = <String, List<GroupMember>>{};
  final _messages = <String, List<GroupMessage>>{};
  final _pins = <String, List<GroupPin>>{};
  final _rng = Random();

  void _seed() {
    final now = DateTime.now();

    _groups.addAll([
      const Group(
        id: 'demo-medical',
        name: 'Medical Volunteers',
        description: 'First-aid team covering Gates 1–3',
        visibility: 'hidden',
        myRole: GroupRole.admin,
        myState: MemberState.active,
      ),
      const Group(
        id: 'demo-water',
        name: 'Water Distribution',
        description: 'Tanker coordination and refill scheduling',
        visibility: 'hidden',
        myRole: GroupRole.member,
        myState: MemberState.active,
      ),
      const Group(
        id: 'demo-legal',
        name: 'Legal Aid Desk',
        description: 'Volunteer lawyers on call',
        visibility: 'public',
        myRole: GroupRole.member,
        myState: MemberState.active,
      ),
      const Group(
        id: 'demo-london',
        name: 'London — Parliament Square',
        description: 'Westminster support crew',
        visibility: 'hidden',
        myRole: GroupRole.admin,
        myState: MemberState.active,
      ),
      const Group(
        id: 'demo-bengaluru',
        name: 'Bengaluru — Town Hall',
        description: 'Water, food and shade coordination',
        visibility: 'public',
        myRole: GroupRole.member,
        myState: MemberState.active,
      ),
      // Awaiting approval — the list shows the hourglass and the tile is not
      // tappable, which is the mandatory-approval rule made visible.
      const Group(
        id: 'demo-pending',
        name: 'Press & Documentation',
        description: 'Requested to join — waiting on an admin',
        visibility: 'hidden',
        myRole: GroupRole.member,
        myState: MemberState.pending,
      ),
    ]);

    _members['demo-medical'] = const [
      GroupMember(
        userId: demoUserId,
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'You (admin)',
        isMe: true,
      ),
      GroupMember(
        userId: 'demo-asha',
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'Asha',
      ),
      GroupMember(
        userId: 'demo-rahul',
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'Rahul',
      ),
      // Pending request so the Approve button is visible in the demo.
      GroupMember(
        userId: 'demo-priya',
        role: GroupRole.member,
        state: MemberState.pending,
        displayName: 'Priya (wants to join)',
      ),
    ];
    _members['demo-water'] = const [
      GroupMember(
        userId: 'demo-vikram',
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'Vikram (admin)',
      ),
      GroupMember(
        userId: demoUserId,
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'You',
        isMe: true,
      ),
    ];
    _members['demo-legal'] = const [
      GroupMember(
        userId: 'demo-meera',
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'Adv. Meera (admin)',
      ),
      GroupMember(
        userId: demoUserId,
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'You',
        isMe: true,
      ),
    ];

    _messages['demo-medical'] = [
      GroupMessage(
        id: 'm1',
        senderId: 'demo-asha',
        createdAt: now.subtract(const Duration(minutes: 24)),
        decrypted: 'First-aid kit at Gate 2 is running low on bandages.',
        mine: false,
      ),
      GroupMessage(
        id: 'm2',
        senderId: demoUserId,
        createdAt: now.subtract(const Duration(minutes: 21)),
        decrypted: 'Sending a resupply from the main tent in 10 minutes.',
        mine: true,
      ),
      GroupMessage(
        id: 'm3',
        senderId: 'demo-rahul',
        createdAt: now.subtract(const Duration(minutes: 8)),
        decrypted:
            'दो लोगों को पानी की कमी से चक्कर आ रहे हैं — Gate 3 भेज रहा हूँ।',
        mine: false,
      ),
    ];
    _messages['demo-water'] = [
      // A broadcast, so the alerts treatment is visible in the demo.
      GroupMessage(
        id: 'w0',
        senderId: 'demo-vikram',
        createdAt: now.subtract(const Duration(minutes: 45)),
        decrypted:
            'Water tanker delayed by 40 minutes. Ration the Gate 1 supply '
            'until it arrives.',
        mine: false,
        broadcastSeverity: AlertSeverity.warn,
      ),
      GroupMessage(
        id: 'w1',
        senderId: 'demo-vikram',
        createdAt: now.subtract(const Duration(minutes: 40)),
        decrypted: 'Tanker refills at 5 PM near Parliament St.',
        mine: false,
      ),
      GroupMessage(
        id: 'w2',
        senderId: demoUserId,
        createdAt: now.subtract(const Duration(minutes: 12)),
        decrypted: 'Noted — I will keep the queue organised at Gate 1.',
        mine: true,
      ),
    ];
    _messages['demo-legal'] = [
      GroupMessage(
        id: 'l1',
        senderId: 'demo-meera',
        createdAt: now.subtract(const Duration(hours: 1)),
        decrypted:
            'If anyone is detained, note the time and location and '
            'call the helpline immediately.',
        mine: false,
      ),
    ];

    _pins['demo-medical'] = const [
      GroupPin(
        id: 'p1',
        type: 'medical',
        label: 'First-aid tent (main)',
        lat: 28.6265,
        lng: 77.2151,
        note: 'Stocked; two volunteers on duty',
      ),
      GroupPin(
        id: 'p2',
        type: 'meeting',
        label: 'Volunteer meeting point',
        lat: 28.6278,
        lng: 77.2160,
        note: 'Shift handover every 2 hours',
      ),
    ];
    _pins['demo-water'] = const [
      GroupPin(
        id: 'p3',
        type: 'supply',
        label: 'Spare water cans store',
        lat: 28.6252,
        lng: 77.2178,
        note: '40 cans remaining',
      ),
    ];
    _pins['demo-legal'] = const [];

    // --- London ---------------------------------------------------------
    _members['demo-london'] = const [
      GroupMember(
        userId: demoUserId,
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'You (admin)',
        isMe: true,
      ),
      GroupMember(
        userId: 'demo-sam',
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'Sam',
      ),
      GroupMember(
        userId: 'demo-nadia',
        role: GroupRole.member,
        state: MemberState.pending,
        displayName: 'Nadia (wants to join)',
      ),
    ];
    _messages['demo-london'] = [
      GroupMessage(
        id: 'ldn0',
        senderId: 'demo-sam',
        createdAt: now.subtract(const Duration(minutes: 18)),
        decrypted:
            'Bridge St is being kettled — do not go east from the square.',
        mine: false,
        broadcastSeverity: AlertSeverity.critical,
      ),
      GroupMessage(
        id: 'ldn1',
        senderId: 'demo-sam',
        createdAt: now.subtract(const Duration(minutes: 15)),
        decrypted: 'Legal observers are wearing orange hi-vis.',
        mine: false,
      ),
      GroupMessage(
        id: 'ldn2',
        senderId: demoUserId,
        createdAt: now.subtract(const Duration(minutes: 9)),
        decrypted: 'Understood — routing people to the west side.',
        mine: true,
      ),
    ];
    _pins['demo-london'] = const [
      GroupPin(
        id: 'ldn-p1',
        type: 'meeting',
        label: 'Legal observer rally point',
        lat: 51.4998,
        lng: -0.1272,
        note: 'Orange hi-vis, by the Gandhi statue',
      ),
      GroupPin(
        id: 'ldn-p2',
        type: 'supply',
        label: 'Spare water crates',
        lat: 51.5012,
        lng: -0.1290,
        note: 'Under the gazebo',
      ),
    ];

    // --- Bengaluru ------------------------------------------------------
    _members['demo-bengaluru'] = const [
      GroupMember(
        userId: 'demo-arun',
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'Arun (admin)',
      ),
      GroupMember(
        userId: demoUserId,
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'You',
        isMe: true,
      ),
      GroupMember(
        userId: 'demo-lakshmi',
        role: GroupRole.member,
        state: MemberState.active,
        displayName: 'Lakshmi',
      ),
    ];
    _messages['demo-bengaluru'] = [
      GroupMessage(
        id: 'blr1',
        senderId: 'demo-arun',
        createdAt: now.subtract(const Duration(minutes: 50)),
        decrypted: 'ಟೌನ್ ಹಾಲ್ ಬಳಿ ನೀರಿನ ಟ್ಯಾಂಕರ್ ಬಂದಿದೆ.',
        mine: false,
      ),
      GroupMessage(
        id: 'blr2',
        senderId: 'demo-lakshmi',
        createdAt: now.subtract(const Duration(minutes: 22)),
        decrypted: 'शाम 4 बजे तक छाया वाले टेंट तैयार हो जाएँगे।',
        mine: false,
      ),
      GroupMessage(
        id: 'blr3',
        senderId: demoUserId,
        createdAt: now.subtract(const Duration(minutes: 6)),
        decrypted: 'I can cover the food counter until 6.',
        mine: true,
      ),
    ];
    _pins['demo-bengaluru'] = const [
      GroupPin(
        id: 'blr-p1',
        type: 'supply',
        label: 'Shade tent store',
        lat: 12.9648,
        lng: 77.5866,
        note: 'Poles and tarps for 6 more tents',
      ),
    ];

    // Pending membership: no roster, no chat, no pins are readable yet —
    // exactly what the RLS negative tests assert on the real backend.
    _members['demo-pending'] = const [];
    _messages['demo-pending'] = [];
    _pins['demo-pending'] = const [];
  }

  @override
  Future<List<Group>> myGroups() async => List.unmodifiable(_groups);

  @override
  Future<Group> createGroup({
    required String name,
    String? description,
    String visibility = 'hidden',
  }) async {
    final group = Group(
      id: 'demo-${_rng.nextInt(1 << 32)}',
      name: name,
      description: description,
      visibility: visibility,
      myRole: GroupRole.admin,
      myState: MemberState.active,
    );
    _groups.insert(0, group);
    _members[group.id] = const [
      GroupMember(
        userId: demoUserId,
        role: GroupRole.admin,
        state: MemberState.active,
        displayName: 'You (admin)',
        isMe: true,
      ),
    ];
    _messages[group.id] = [];
    _pins[group.id] = [];
    return group;
  }

  @override
  Future<List<GroupMember>> members(String groupId) async =>
      List.unmodifiable(_members[groupId] ?? const []);

  @override
  Future<void> approveMember(String groupId, String userId) async {
    final list = [...?_members[groupId]];
    final i = list.indexWhere((m) => m.userId == userId);
    if (i == -1) return;
    final m = list[i];
    list[i] = GroupMember(
      userId: m.userId,
      role: m.role,
      state: MemberState.active,
      displayName: (m.displayName ?? '').replaceAll(' (wants to join)', ''),
    );
    _members[groupId] = list;
  }

  /// Demo mode has no crypto, so there is no key to rotate — the member just
  /// disappears from the roster.
  @override
  Future<int> removeMember(String groupId, String userId) async {
    _members[groupId] = [
      ...?_members[groupId]?.where((m) => m.userId != userId),
    ];
    return 0;
  }

  /// Demo data is already local, so the cached and live reads are the same
  /// list — the demo chat behaves identically online and offline.
  @override
  Future<List<GroupMessage>> cachedMessages(String groupId) =>
      messages(groupId);

  @override
  Future<List<GroupMessage>> messages(String groupId) async =>
      List.unmodifiable(_messages[groupId] ?? const []);

  @override
  Future<void> sendMessage(String groupId, String text) =>
      _append(groupId, text, null);

  @override
  Future<void> sendBroadcast(
    String groupId,
    String body,
    AlertSeverity severity,
  ) => _append(groupId, body, severity);

  Future<void> _append(
    String groupId,
    String text,
    AlertSeverity? severity,
  ) async {
    final list = [...?_messages[groupId]];
    list.add(
      GroupMessage(
        id: 'msg-${_rng.nextInt(1 << 32)}',
        senderId: demoUserId,
        createdAt: DateTime.now(),
        decrypted: text,
        mine: true,
        broadcastSeverity: severity,
      ),
    );
    _messages[groupId] = list;
  }

  @override
  Future<List<GroupPin>> pins(String groupId) async =>
      List.unmodifiable(_pins[groupId] ?? const []);

  @override
  Future<void> addPin({
    required String groupId,
    required String type,
    required String label,
    required double lat,
    required double lng,
    String? note,
  }) async {
    final list = [...?_pins[groupId]];
    list.add(
      GroupPin(
        id: 'pin-${_rng.nextInt(1 << 32)}',
        type: type,
        label: label,
        lat: lat,
        lng: lng,
        note: note,
      ),
    );
    _pins[groupId] = list;
  }

  @override
  Future<String> createInvite(String groupId) async => 'DEMO2026';

  @override
  Future<String> joinByCode(String code) async {
    final group = Group(
      id: 'demo-joined-${_rng.nextInt(1 << 32)}',
      name: 'Joined group ($code)',
      description: 'Demo join — pending admin approval',
      visibility: 'hidden',
      myRole: GroupRole.member,
      myState: MemberState.pending,
    );
    _groups.add(group);
    _members[group.id] = const [];
    _messages[group.id] = [];
    _pins[group.id] = [];
    return group.name;
  }
}
