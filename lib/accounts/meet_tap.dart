import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';

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
  static const _hostPort = 0x00;
  static final Uint8List _aid = Uint8List.fromList([
    0xA0,
    0x00,
    0x00,
    0x01,
    0x02,
    0x03,
    0x04,
  ]);
  static bool _hceInitialized = false;

  const MeetTapService();

  bool get supportsTapJoin =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get supportsTapHost =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Uri buildMeetUri(String meetId) {
    return Uri(
      scheme: 'solian',
      host: 'meet',
      pathSegments: [meetId],
      queryParameters: const {'entry': 'tap'},
    );
  }

  Future<void> ensureJoinAvailable() async {
    if (!supportsTapJoin) {
      throw StateError(
        'Tap Meet join is currently available on iPhone and Android only.',
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

  Future<void> ensureHostAvailable() async {
    if (!supportsTapHost) {
      throw StateError(
        'Tap Meet hosting is currently available on Android only.',
      );
    }

    final nfcState = await NfcHce.checkDeviceNfcState();
    if (nfcState != NfcState.enabled) {
      throw StateError(switch (nfcState) {
        NfcState.disabled => 'Turn on NFC before hosting a Tap Meet.',
        NfcState.notSupported =>
          'This Android device does not support Tap Meet hosting.',
        _ => 'NFC is not available right now.',
      });
    }

    if (!_hceInitialized) {
      await NfcHce.init(
        aid: _aid,
        permanentApduResponses: false,
        listenOnlyConfiguredPorts: true,
      );
      _hceInitialized = true;
    }
  }

  Future<void> startHostPresentation(String meetId) async {
    await ensureHostAvailable();
    final bytes = utf8.encode(buildMeetUri(meetId).toString());
    await NfcHce.addApduResponse(_hostPort, bytes);
  }

  Future<void> stopHostPresentation() async {
    if (!_hceInitialized) return;
    try {
      await NfcHce.removeApduResponse(_hostPort);
    } catch (_) {}
  }

  Future<MeetTapPayload> readPresentedMeet() async {
    await ensureJoinAvailable();
    try {
      final tag = await FlutterNfcKit.poll(
        androidReaderModeFlags: _androidFastFlags,
      );
      if (tag.type != NFCTagType.iso7816 && tag.standard != 'ISO 7816-4') {
        throw const FormatException('This phone is not presenting a Tap Meet.');
      }

      final response = await FlutterNfcKit.transceive<Uint8List>(
        _buildSelectApdu(),
      );
      final payload = _parseApduPayload(response);
      await FlutterNfcKit.finish(iosAlertMessage: 'Tap received');
      return payload;
    } catch (error) {
      await _finishWithError();
      rethrow;
    }
  }

  Uint8List _buildSelectApdu() {
    return Uint8List.fromList([
      0x00,
      0xA4,
      0x04,
      _hostPort,
      _aid.length,
      ..._aid,
    ]);
  }

  MeetTapPayload _parseApduPayload(Uint8List bytes) {
    if (bytes.length < 2) {
      throw const FormatException('Tap Meet response was empty.');
    }

    final status = bytes.sublist(bytes.length - 2);
    if (status[0] != 0x90 || status[1] != 0x00) {
      throw const FormatException('Tap Meet response was rejected.');
    }

    final raw = utf8.decode(bytes.sublist(0, bytes.length - 2)).trim();
    final uri = Uri.tryParse(raw);
    final meetId = _extractMeetId(raw);
    if (meetId == null) {
      throw const FormatException('This phone is not presenting a Tap Meet.');
    }

    return MeetTapPayload(meetId: meetId, uri: uri);
  }

  Future<void> _finishWithError() async {
    try {
      await FlutterNfcKit.finish(iosErrorMessage: 'Tap Meet was interrupted');
    } catch (_) {}
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
