import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/db/app_database.dart' show AlertSeverity;
import '../../../core/l10n/l10n_labels.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/presentation/widgets/alert_visuals.dart';
import '../application/groups_providers.dart';
import '../data/groups_repo.dart';
import '../domain/group_models.dart';
import 'invite_sheet.dart';
import 'pick_location_screen.dart';

/// Group home: E2E Chat · Members · Amenities. Admins also get Invite and
/// member-approval actions.
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({required this.group, super.key});

  final Group group;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  GroupsRepo get _repo => ref.read(groupsRepositoryProvider)!;

  Future<void> _invite() async {
    final l10n = AppL10n.of(context);
    try {
      final code = await _repo.createInvite(widget.group.id);
      if (!mounted) return;
      await showInviteSheet(context, code);
    } on Object catch (e) {
      _snack(l10n.groupActionFailed('$e'));
    }
  }

  Future<void> _broadcast() async {
    final l10n = AppL10n.of(context);
    final result = await showBroadcastComposer(context, widget.group.name);
    if (result == null) return;
    try {
      await _repo.sendBroadcast(widget.group.id, result.body, result.severity);
      ref.invalidate(groupBroadcastsProvider);
    } on Object catch (e) {
      _snack(l10n.groupActionFailed('$e'));
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
          actions: [
            if (widget.group.isAdmin) ...[
              IconButton(
                icon: const Icon(Icons.campaign_outlined),
                tooltip: l10n.broadcast,
                onPressed: _broadcast,
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt),
                tooltip: l10n.invite,
                onPressed: _invite,
              ),
            ],
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabChat),
              Tab(text: l10n.tabMembers),
              Tab(text: l10n.tabPins),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ChatTab(group: widget.group),
            _MembersTab(group: widget.group, onError: _snack),
            _PinsTab(group: widget.group, onError: _snack),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ chat

class _ChatTab extends ConsumerStatefulWidget {
  const _ChatTab({required this.group});
  final Group group;

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _controller = TextEditingController();
  List<GroupMessage>? _messages;
  Timer? _poll;
  bool _sending = false;
  bool _loading = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    // Local-first: paint the cached conversation before any request is made,
    // then refresh. Offline the chat still opens, fully readable.
    _loadCached();
    _refresh();
    // Live updates: poll while the chat is open (simple + reliable; Realtime
    // is a later optimisation). Held state avoids spinner flicker.
    _poll = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCached() async {
    try {
      final list = await ref
          .read(groupsRepositoryProvider)!
          .cachedMessages(widget.group.id);
      // Don't clobber a network refresh that already won the race.
      if (mounted && _messages == null) setState(() => _messages = list);
    } on Object {
      // Nothing cached yet — the refresh below decides what to show.
    }
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _loading = true;
    final repo = ref.read(groupsRepositoryProvider)!;
    try {
      final list = await repo.messages(widget.group.id);
      if (mounted) {
        setState(() {
          _messages = list;
          _offline = false;
        });
      }
    } on Object {
      // Degrade visibly instead of erroring: keep serving the cache and say
      // so, per the offline-first rule.
      try {
        final cached = await repo.cachedMessages(widget.group.id);
        if (mounted) {
          setState(() {
            _messages = cached;
            _offline = true;
          });
        }
      } on Object {
        if (mounted) setState(() => _offline = true);
      }
    } finally {
      _loading = false;
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(groupsRepositoryProvider)!
          .sendMessage(widget.group.id, text);
      _controller.clear();
      // Show the queued message immediately, even with no network.
      await _loadCachedForce();
      await _refresh();
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).groupActionFailed('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _loadCachedForce() async {
    try {
      final list = await ref
          .read(groupsRepositoryProvider)!
          .cachedMessages(widget.group.id);
      if (mounted) setState(() => _messages = list);
    } on Object {
      // Best effort; the refresh that follows is authoritative.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final messages = _messages;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(Icons.lock, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.e2eNotice,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        // Visible degraded state (icon + text, never colour alone): the chat
        // still works, it is just not live.
        if (_offline)
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.chatOffline,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: messages == null
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? Center(child: Text(l10n.noMessages))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _bubble(context, messages[i]),
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: l10n.messageHint,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send),
                  tooltip: l10n.send,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bubble(BuildContext context, GroupMessage m) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    if (m.isBroadcast && m.decrypted != null) {
      return _BroadcastCard(message: m);
    }
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: m.mine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          // The tail squares off the corner nearest the speaker, so which
          // side a message came from survives without relying on the fill
          // colour — the same reason status is never colour alone. Mirrors
          // for RTL because "my side" is a reading-direction idea, not a
          // fixed edge.
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(AppTokens.radiusBubble),
            topEnd: const Radius.circular(AppTokens.radiusBubble),
            bottomStart: Radius.circular(
              m.mine ? AppTokens.radiusBubble : AppTokens.radiusBubbleTail,
            ),
            bottomEnd: Radius.circular(
              m.mine ? AppTokens.radiusBubbleTail : AppTokens.radiusBubble,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              m.decrypted ?? l10n.cantDecrypt,
              style: TextStyle(
                fontStyle: m.decrypted == null ? FontStyle.italic : null,
                color: m.decrypted == null ? scheme.error : null,
              ),
            ),
            if (m.pending)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      l10n.messageSending,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            // Only shown when the signature actually FAILED (ADR-29). Most
            // messages during rollout are legitimately unverifiable, and
            // flagging those too would train people to ignore this.
            if (m.senderUnverified)
              _UnverifiedSender(text: l10n.senderUnverified),
          ],
        ),
      ),
    );
  }
}

/// "Not from who it says" — a failed signature, or an unsigned message from a
/// sender who has published a signing key (the downgrade case). Icon + text +
/// colour, never colour alone.
class _UnverifiedSender extends StatelessWidget {
  const _UnverifiedSender({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gpp_bad_outlined, size: 14, color: scheme.error),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// A broadcast inside the chat: same severity treatment as the Alerts feed
/// (icon + label + colour + text), full width so it cannot read as chatter.
class _BroadcastCard extends StatelessWidget {
  const _BroadcastCard({required this.message});

  final GroupMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final colors = Theme.of(context).extension<StatusColors>()!;
    final severity = message.broadcastSeverity!;
    final color = severity.colorOf(colors);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        side: BorderSide(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severity.icon, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${l10n.broadcast} · ${severity.label(l10n)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.decrypted!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

/// Composer for an admin broadcast. Returns the body + severity, or null.
Future<({String body, AlertSeverity severity})?> showBroadcastComposer(
  BuildContext context,
  String groupName,
) {
  final controller = TextEditingController();
  var severity = AlertSeverity.warn;

  return showDialog<({String body, AlertSeverity severity})>(
    context: context,
    builder: (context) {
      final l10n = AppL10n.of(context);
      final colors = Theme.of(context).extension<StatusColors>()!;
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.broadcastTitle(groupName)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.broadcastHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Text(l10n.broadcastSeverity),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in AlertSeverity.values)
                    ChoiceChip(
                      selected: severity == s,
                      onSelected: (_) => setState(() => severity = s),
                      avatar: Icon(s.icon, size: 18, color: s.colorOf(colors)),
                      label: Text(s.label(l10n)),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final body = controller.text.trim();
                if (body.isEmpty) return;
                Navigator.of(context).pop((body: body, severity: severity));
              },
              child: Text(l10n.broadcastSend),
            ),
          ],
        ),
      );
    },
  );
}

// --------------------------------------------------------------- members

class _MembersTab extends ConsumerStatefulWidget {
  const _MembersTab({required this.group, required this.onError});
  final Group group;
  final void Function(String) onError;

  @override
  ConsumerState<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends ConsumerState<_MembersTab> {
  List<GroupMember>? _members;
  Timer? _poll;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Poll so an admin sees new join requests appear live (held list avoids
    // spinner flicker).
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => _refresh());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_loading) return;
    _loading = true;
    try {
      final list = await ref
          .read(groupsRepositoryProvider)!
          .members(widget.group.id);
      if (mounted) setState(() => _members = list);
    } on Object {
      // Transient; next poll retries.
    } finally {
      _loading = false;
    }
  }

  Future<void> _approve(String userId) async {
    final l10n = AppL10n.of(context);
    try {
      await ref
          .read(groupsRepositoryProvider)!
          .approveMember(widget.group.id, userId);
      await _refresh();
    } on Object catch (e) {
      widget.onError(l10n.groupActionFailed('$e'));
    }
  }

  Future<void> _remove(GroupMember member) async {
    final l10n = AppL10n.of(context);
    final name = member.displayName ?? member.userId.substring(0, 8);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeMemberTitle(name)),
        // Say plainly what rotation does and does not undo.
        content: Text(l10n.removeMemberBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.removeMember),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final unkeyed = await ref
          .read(groupsRepositoryProvider)!
          .removeMember(widget.group.id, member.userId);
      await _refresh();
      widget.onError(
        unkeyed > 0 ? l10n.rekeyWarning(unkeyed) : l10n.memberRemoved,
      );
    } on Object catch (e) {
      widget.onError(l10n.groupActionFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final members = _members;
    if (members == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: [
        for (final m in members)
          ListTile(
            leading: Icon(
              m.role == GroupRole.admin ? Icons.shield : Icons.person_outline,
            ),
            title: Text(m.displayName ?? m.userId.substring(0, 8)),
            subtitle: Text(
              m.role == GroupRole.admin ? l10n.admin : l10n.member,
            ),
            trailing: _trailing(context, m, l10n),
          ),
      ],
    );
  }

  /// Admins approve pending members and remove active ones; everyone else
  /// just sees whether a member is still waiting.
  Widget? _trailing(BuildContext context, GroupMember m, AppL10n l10n) {
    if (widget.group.isAdmin && m.state == MemberState.pending) {
      return FilledButton(
        onPressed: () => _approve(m.userId),
        child: Text(l10n.approveMember),
      );
    }
    if (widget.group.isAdmin && !m.isMe && m.state == MemberState.active) {
      return IconButton(
        icon: const Icon(Icons.person_remove_outlined),
        tooltip: l10n.removeMember,
        onPressed: () => _remove(m),
      );
    }
    if (m.state == MemberState.pending) return Text(l10n.membershipPending);
    return null;
  }
}

// ----------------------------------------------------------------- pins

class _PinsTab extends ConsumerStatefulWidget {
  const _PinsTab({required this.group, required this.onError});
  final Group group;
  final void Function(String) onError;

  @override
  ConsumerState<_PinsTab> createState() => _PinsTabState();
}

class _PinsTabState extends ConsumerState<_PinsTab> {
  late Future<List<GroupPin>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<GroupPin>> _load() =>
      ref.read(groupsRepositoryProvider)!.pins(widget.group.id);

  Future<void> _add() async {
    final l10n = AppL10n.of(context);
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addAmenity),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.amenityLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.create),
          ),
        ],
      ),
    );
    if (label == null || label.isEmpty) return;
    if (!mounted) return;
    // Place the amenity on the map instead of assuming the site centre.
    final location = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(builder: (_) => const PickLocationScreen()),
    );
    if (location == null) return;

    try {
      await ref
          .read(groupsRepositoryProvider)!
          .addPin(
            groupId: widget.group.id,
            type: 'meeting',
            label: label,
            lat: location.latitude,
            lng: location.longitude,
          );
      setState(() => _future = _load());
    } on Object catch (e) {
      widget.onError(l10n.groupActionFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: _add,
        child: const Icon(Icons.add_location_alt),
      ),
      body: FutureBuilder<List<GroupPin>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pins = snap.data!;
          if (pins.isEmpty) {
            return Center(child: Text(l10n.noAmenities));
          }
          return ListView(
            children: [
              for (final p in pins)
                ListTile(
                  leading: const Icon(Icons.place),
                  title: Text(p.label),
                  subtitle: Text(p.note ?? p.type),
                ),
            ],
          );
        },
      ),
    );
  }
}
