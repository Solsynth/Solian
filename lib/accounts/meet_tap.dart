import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ndef/ndef.dart' as ndef;

final meetTapServiceProvider = Provider<MeetTapService>((ref) {
  return const MeetTapService();
});

class MeetTapPayload {
  final String meetId;
  final Uri? uri;

  const MeetTapPayload({required this.meetId, this.uri});
}

class MeetTapService {
  static const _androidFastFlags = 0x80 | 0x100;

  const MeetTapService();

  bool get supportsTapMeet =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Uri buildMeetUri(String meetId) {
    return Uri(
      scheme: 'solian',
      host: 'meet',
      pathSegments: [meetId],
      queryParameters: const {'entry': 'tap'},
    );
  }

  Future<void> ensureAvailable() async {
    if (!supportsTapMeet) {
      throw StateError(
        'Tap Meet is currently available on iPhone and Android only.',
      );
    }

    final availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      throw StateError(switch (availability) {
        NFCAvailability.disabled => 'Turn on NFC before using Tap Meet.',
        NFCAvailability.not_supported =>
          'This device does not support Tap Meet over NFC.',
        _ => 'NFC is not available right now.',
      });
    }
  }

  Future<void> writeMeetTag(String meetId) async {
    await ensureAvailable();
    try {
      await FlutterNfcKit.poll(androidReaderModeFlags: _androidFastFlags);
      await FlutterNfcKit.writeNDEFRecords([
        ndef.UriRecord.fromString(buildMeetUri(meetId).toString()),
      ]);
      await FlutterNfcKit.finish(iosAlertMessage: 'Tap card ready');
    } catch (error) {
      await _finishWithError();
      rethrow;
    }
  }

  Future<MeetTapPayload> readMeetTag() async {
    await ensureAvailable();
    try {
      await FlutterNfcKit.poll(androidReaderModeFlags: _androidFastFlags);
      final records = await FlutterNfcKit.readNDEFRecords(cached: false);
      final payload = _parseRecords(records);
      await FlutterNfcKit.finish(iosAlertMessage: 'Tap received');
      return payload;
    } catch (error) {
      await _finishWithError();
      rethrow;
    }
  }

  Future<void> _finishWithError() async {
    try {
      await FlutterNfcKit.finish(iosErrorMessage: 'Tap Meet was interrupted');
    } catch (_) {}
  }

  MeetTapPayload _parseRecords(List<Object?> records) {
    for (final record in records) {
      if (record is ndef.UriRecord) {
        final rawUri = record.uri?.toString();
        if (rawUri == null) continue;
        final uri = Uri.tryParse(rawUri);
        final meetId = _extractMeetId(rawUri);
        if (meetId != null) {
          return MeetTapPayload(meetId: meetId, uri: uri);
        }
      }

      if (record is ndef.TextRecord) {
        final text = record.text;
        if (text == null) continue;
        final meetId = _extractMeetId(text);
        if (meetId != null) {
          return MeetTapPayload(meetId: meetId);
        }
      }
    }

    throw const FormatException('This NFC tag does not contain a Tap Meet.');
  }

  String? _extractMeetId(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final uri = Uri.tryParse(text);
    if (uri != null && uri.scheme == 'solian') {
      if (uri.host == 'meet' && uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }

      final meetId = uri.queryParameters['meet_id'];
      if (meetId?.isNotEmpty ?? false) {
        return meetId;
      }
    }

    return text;
  }
}
