import 'dart:async';
import 'dart:convert';

export 'package:flutter_nfc_kit/flutter_nfc_kit.dart' show NFCAvailability;
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

class NfcScanService {
  static final NfcScanService _instance = NfcScanService._internal();
  factory NfcScanService() => _instance;
  NfcScanService._internal();

  Future<NFCAvailability> checkAvailability() async {
    return FlutterNfcKit.nfcAvailability;
  }

  Future<NFCTag> scanTag({Duration? timeout, String? iosAlertMessage}) async {
    return FlutterNfcKit.poll(
      timeout: timeout,
      iosAlertMessage: iosAlertMessage ?? '',
    );
  }

  Future<List<ndef.NDEFRecord>> readNdefRecords(
    NFCTag tag, {
    bool cached = false,
  }) async {
    return FlutterNfcKit.readNDEFRecords(cached: cached);
  }

  Future<void> finish({
    String? iosAlertMessage,
    String? iosErrorMessage,
  }) async {
    if (iosErrorMessage != null) {
      await FlutterNfcKit.finish(iosErrorMessage: iosErrorMessage);
    } else {
      await FlutterNfcKit.finish(iosAlertMessage: iosAlertMessage ?? 'Success');
    }
  }

  Uri? parseDeepLinkUri(List<ndef.NDEFRecord> records) {
    if (records.isEmpty) return null;

    final firstRecord = records.first;

    if (firstRecord is ndef.UriRecord && firstRecord.uri != null) {
      return firstRecord.uri;
    }

    if (firstRecord is ndef.TextRecord) {
      final text = firstRecord.text;
      if (text == null) return null;

      final uri = _tryParseUri(text);
      if (uri != null) return uri;
    }

    return null;
  }

  Uri? _tryParseUri(String input) {
    final trimmed = input.trim();

    if (_looksLikeUrl(trimmed)) {
      return Uri.tryParse(trimmed);
    }

    try {
      final decoded = base64Decode(trimmed);
      final decodedStr = utf8.decode(decoded, allowMalformed: true);

      final startIdx = _findUrlStart(decodedStr);
      if (startIdx < 0) return null;

      final cleanStr = decodedStr.substring(startIdx);
      final uri = Uri.tryParse(cleanStr.trim().split(' ').first);
      if (uri != null && _looksLikeUrl(uri.toString())) {
        return uri;
      }
    } catch (_) {}

    return null;
  }

  int _findUrlStart(String input) {
    final solianIdx = input.indexOf('solian://');
    if (solianIdx >= 0) return solianIdx;

    final httpsIdx = input.indexOf('https://');
    if (httpsIdx >= 0) return httpsIdx;

    final httpIdx = input.indexOf('http://');
    if (httpIdx >= 0) return httpIdx;

    return -1;
  }

  bool _looksLikeUrl(String input) {
    final lower = input.toLowerCase();
    return lower.startsWith('solian://') ||
        lower.startsWith('https://') ||
        lower.startsWith('http://');
  }
}
