import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';
import '../application/groups_providers.dart';
import '../data/groups_repo.dart';
import '../domain/group_models.dart';
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
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: SelectableText(l10n.inviteCreated(code)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
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
            if (widget.group.isAdmin)
              IconButton(
                icon: const Icon(Icons.person_add_alt),
                tooltip: l10n.invite,
                onPressed: _invite,
              ),
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

  @override
  void initState() {
    super.initState();
    _refresh();
    // Live updates: poll while the chat is open (simple + reliable; Realtime
    // is a later optimisation). Held state avoids spinner flicker.
    _poll = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _refresh(silent: true),
    );
  }

  @override
  void dispose() {
    _poll?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    if (_loading) return;
    _loading = true;
    try {
      final list = await ref
          .read(groupsRepositoryProvider)!
          .messages(widget.group.id);
      if (mounted) setState(() => _messages = list);
    } on Object catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).groupActionFailed('$e'))),
        );
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
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: m.mine ? scheme.primaryContainer : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          m.decrypted ?? l10n.cantDecrypt,
          style: TextStyle(
            fontStyle: m.decrypted == null ? FontStyle.italic : null,
            color: m.decrypted == null ? scheme.error : null,
          ),
        ),
      ),
    );
  }
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
            trailing: (widget.group.isAdmin && m.state == MemberState.pending)
                ? FilledButton(
                    onPressed: () => _approve(m.userId),
                    child: Text(l10n.approveMember),
                  )
                : (m.state == MemberState.pending
                      ? Text(l10n.membershipPending)
                      : null),
          ),
      ],
    );
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
