import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../application/verify_providers.dart';
import 'verification_queue_screen.dart';

/// Volunteer/admin sign-in (email + password). Regular users never need
/// this — anonymous is the default (ADR-4). The admin role is granted
/// server-side in app_metadata; signing in without it just shows a notice.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final l10n = AppL10n.of(context);
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() => _error = l10n.backendUnreachable);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      if (isAdminSession(client)) {
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const VerificationQueueScreen(),
            ),
          ),
        );
      } else {
        setState(() => _error = l10n.noAdminRole);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Object {
      setState(() => _error = l10n.serverTryAgain);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminSignInTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.adminSignInBlurb),
            const SizedBox(height: 16),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _signIn,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text(_busy ? l10n.signingIn : l10n.signIn),
            ),
          ],
        ),
      ),
    );
  }
}
