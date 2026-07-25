import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/groups_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  String _visibility = 'hidden';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppL10n.of(context);
    final repo = ref.read(groupsRepositoryProvider);
    if (repo == null || _name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await repo.createGroup(
        name: _name.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        visibility: _visibility,
      );
      ref.read(groupsRefreshProvider.notifier).bump();
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.groupActionFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createGroup)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: l10n.groupName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.groupDescription,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.groupVisibility),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'hidden',
                  icon: const Icon(Icons.lock_outline),
                  label: Text(l10n.visibilityHidden),
                ),
                ButtonSegment(
                  value: 'public',
                  icon: const Icon(Icons.public),
                  label: Text(l10n.visibilityPublic),
                ),
              ],
              selected: {_visibility},
              onSelectionChanged: (s) => setState(() => _visibility = s.single),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _create,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }
}
