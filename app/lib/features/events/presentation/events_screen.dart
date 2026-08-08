import 'package:flutter/material.dart';

import '../../../core/theme/depth.dart';
import '../../../core/theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../alerts/presentation/widgets/alert_visuals.dart';

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
      _EventData(
        title: l10n.eventDelhiSitInTitle,
        status: _EventStatus.upcoming,
        time: l10n.eventDelhiSitInTime,
        location: l10n.eventDelhiSitInLocation,
        note: l10n.eventDelhiSitInNote,
        verified: true,
      ),
      // Other cities, matching the map's site switcher.
      _EventData(
        title: l10n.eventLondonTitle,
        status: _EventStatus.live,
        time: l10n.eventLondonTime,
        location: l10n.eventLondonLocation,
        note: l10n.eventLondonNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventLondonLegalTitle,
        status: _EventStatus.today,
        time: l10n.eventLondonLegalTime,
        location: l10n.eventLondonLegalLocation,
        note: l10n.eventLondonLegalNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventBengaluruTitle,
        status: _EventStatus.live,
        time: l10n.eventBengaluruTime,
        location: l10n.eventBengaluruLocation,
        note: l10n.eventBengaluruNote,
        verified: true,
      ),
      _EventData(
        title: l10n.eventBengaluruWaterTitle,
        status: _EventStatus.upcoming,
        time: l10n.eventBengaluruWaterTime,
        location: l10n.eventBengaluruWaterLocation,
        note: l10n.eventBengaluruWaterNote,
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
    final colors = Theme.of(context).extension<StatusColors>()!;
    // Status is colour + icon + text (never colour alone). The three tones
    // come from the audited palette rather than from literals that happened
    // to match it — a copied hex does not follow the token when the token is
    // corrected, and the contrast suite cannot see it at all.
    final (Color color, IconData icon, String label) = switch (event.status) {
      _EventStatus.live => (colors.out, Icons.podcasts, l10n.eventLive),
      _EventStatus.today => (colors.low, Icons.today, l10n.eventToday),
      _EventStatus.upcoming => (
        AlertSeverityVisuals.infoBlue,
        Icons.event_outlined,
        l10n.eventUpcoming,
      ),
    };

    return DepthSurface(
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
