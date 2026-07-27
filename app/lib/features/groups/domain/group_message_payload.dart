import 'dart:convert';

import '../../../core/db/app_database.dart' show AlertSeverity;

/// Wire format for the plaintext *inside* a group message's ciphertext.
///
/// Broadcasts are encoded here rather than in a server column on purpose: the
/// server already cannot read the body, and this keeps it from learning which
/// messages are announcements or how urgent they are either. Metadata
/// minimisation is the whole point (SECURITY.md).
///
/// Backwards compatible by construction — anything that is not tagged with
/// [_marker] is an ordinary chat message, so messages written before
/// broadcasts existed still decode.
class GroupMessagePayload {
  const GroupMessagePayload({required this.body, this.broadcastSeverity});

  final String body;

  /// Non-null means this is a broadcast, rendered with the alerts treatment.
  final AlertSeverity? broadcastSeverity;

  bool get isBroadcast => broadcastSeverity != null;

  /// A control character no keyboard produces, so a user cannot type a string
  /// that impersonates the envelope.
  static const _marker = 'cg1:';

  String encode() {
    if (broadcastSeverity == null) return body;
    return _marker +
        jsonEncode({'k': 'b', 's': broadcastSeverity!.name, 'b': body});
  }

  static GroupMessagePayload decode(String plaintext) {
    if (!plaintext.startsWith(_marker)) {
      return GroupMessagePayload(body: plaintext);
    }
    try {
      final map =
          jsonDecode(plaintext.substring(_marker.length))
              as Map<String, Object?>;
      return GroupMessagePayload(
        body: map['b'] as String? ?? '',
        broadcastSeverity:
            AlertSeverity.values.asNameMap()[map['s']] ?? AlertSeverity.info,
      );
    } on Object {
      // Corrupt or future envelope — show the raw text rather than nothing.
      return GroupMessagePayload(body: plaintext);
    }
  }
}
