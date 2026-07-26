import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Events list (ui-ux-spec §1.6). Renders sample events so the screen is
/// explorable; server-backed events land with their own epic. All strings go
/// through AppL10n so the screen is bilingual like the rest of the app.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final events = <_EventData>[
      _EventData(
        title: l10n.eventMainTitle,
        status: _EventStatus.live,
        time: l10n.eventLiveNow,
        location: l10n.eventMainLocation,
        note: l10n.eventMainNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventMedicalTitle,
        status: _EventStatus.today,
        time: l10n.eventMedicalTime,
        location: l10n.eventMedicalLocation,
        note: l10n.eventMedicalNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventLegalTitle,
        status: _EventStatus.today,
        time: l10n.eventLegalTime,
        location: l10n.eventLegalLocation,
        note: l10n.eventLegalNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventLangarTitle,
        status: _EventStatus.upcoming,
        time: l10n.eventLangarTime,
        location: l10n.eventLangarLocation,
        note: l10n.eventLangarNote,
        verified: false,
      ),
    ];

    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: events.length,
        itemBuilder: (context, i) => _EventCard(event: events[i]),
      ),
    );
  }
}

enum _EventStatus { live, today, upcoming }

class _EventData {
  _EventData({
    required this.title,
    required this.status,
    required this.time,
    required this.location,
    required this.note,
    required this.verified,
  });

  final String title;
  final _EventStatus status;
  final String time;
  final String location;
  final String note;
  final bool verified;
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final _EventData event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Status is colour + icon + text (never colour alone).
    final (Color color, IconData icon, String label) = switch (event.status) {
      _EventStatus.live => (
        const Color(0xFFC62828),
        Icons.podcasts,
        l10n.eventLive,
      ),
      _EventStatus.today => (
        const Color(0xFFF9A825),
        Icons.today,
        l10n.eventToday,
      ),
      _EventStatus.upcoming => (
        const Color(0xFF1976D2),
        Icons.event_outlined,
        l10n.eventUpcoming,
      ),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (event.verified)
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        l10n.eventVerified,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 16),
                    const SizedBox(width: 4),
                    Text(event.time),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place_outlined, size: 16),
                    const SizedBox(width: 4),
                    Text(event.location),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.note, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.eventDetailsSoon(event.title))),
                ),
                icon: Icon(Icons.chevron_right, color: scheme.primary),
                label: Text(l10n.eventDetails),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
