import 'package:flutter/material.dart';

/// Events list (ui-ux-spec §1.6). Currently renders sample events so the
/// screen is explorable; server-backed events land with their own epic.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  static final _events = <_DemoEvent>[
    _DemoEvent(
      title: 'Main gathering — Jantar Mantar',
      status: _EventStatus.live,
      time: 'Live now',
      location: 'Jantar Mantar Road',
      note: 'Peak crowd expected until 6 PM. Water points at Gates 1 and 3.',
      verified: true,
    ),
    _DemoEvent(
      title: 'Medical volunteer briefing',
      status: _EventStatus.today,
      time: 'Starts 3:00 PM',
      location: 'First-aid tent (main)',
      note: 'Shift handover and supply check for all first-aid volunteers.',
      verified: true,
    ),
    _DemoEvent(
      title: 'Legal aid desk hours',
      status: _EventStatus.today,
      time: 'Starts 4:30 PM',
      location: 'Gate 2 pavilion',
      note: 'Volunteer lawyers available for detention-related queries.',
      verified: true,
    ),
    _DemoEvent(
      title: 'Community langar',
      status: _EventStatus.upcoming,
      time: 'Tomorrow, 12:00 PM',
      location: 'Parliament Street corner',
      note: 'Food for ~500 people; volunteers needed from 10 AM.',
      verified: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _events.length,
        itemBuilder: (context, i) => _EventCard(event: _events[i]),
      ),
    );
  }
}

enum _EventStatus { live, today, upcoming }

class _DemoEvent {
  _DemoEvent({
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

  final _DemoEvent event;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color color, IconData icon, String label) = switch (event.status) {
      _EventStatus.live => (const Color(0xFFC62828), Icons.podcasts, 'Live'),
      _EventStatus.today => (const Color(0xFFF9A825), Icons.today, 'Today'),
      _EventStatus.upcoming => (
        const Color(0xFF1976D2),
        Icons.event_outlined,
        'Upcoming',
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
                        'Verified',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(event.time),
                const SizedBox(width: 12),
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Flexible(child: Text(event.location)),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.note, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${event.title} — details soon')),
                ),
                icon: Icon(Icons.chevron_right, color: scheme.primary),
                label: const Text('Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
