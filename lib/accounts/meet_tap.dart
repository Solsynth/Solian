import 'package:hooks_riverpod/hooks_riverpod.dart';

final meetTapServiceProvider = Provider<MeetTapService>((ref) {
  return const MeetTapService();
});

class MeetTapPayload {
  final String meetId;
  final Uri uri;

  const MeetTapPayload({required this.meetId, required this.uri});
}

class MeetTapService {
  const MeetTapService();

  Uri buildMeetUri(String meetId) {
    return Uri(scheme: 'solian', host: 'meets', pathSegments: [meetId]);
  }

  String? extractMeetId(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final uri = Uri.tryParse(text);
    if (uri != null && uri.scheme == 'solian' && uri.host == 'meets') {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    return text;
  }

  MeetTapPayload? parsePayload(String raw) {
    final meetId = extractMeetId(raw);
    if (meetId == null) return null;
    return MeetTapPayload(meetId: meetId, uri: buildMeetUri(meetId));
  }
}
