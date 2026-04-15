import 'dart:async';
import 'dart:convert';

export 'package:flutter_nfc_kit/flutter_nfc_kit.dart' show NFCAvailability;
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:logging/logging.dart';
import 'package:ndef/ndef.dart' as ndef;

class NfcScanService {
  static final NfcScanService _instance = NfcScanService._internal();
  factory NfcScanService() => _instance;
  NfcScanService._internal();

  Future<NFCAvailability> checkAvailability() async {
    return FlutterNfcKit.nfcAvailability;
  }

  Future<NFCTag> scanTag({Duration? timeout, String? iosAlertMessage}) async {
    Logger.root.info('NfcScanService: Starting NFC scan...');
    try {
      final tag = await FlutterNfcKit.poll(
        timeout: timeout,
        iosAlertMessage: iosAlertMessage ?? '',
      );
      Logger.root.info(
        'NfcScanService: Scanned tag: ${tag.id}, type: ${tag.type}, ndefAvailable: ${tag.ndefAvailable}',
      );
      return tag;
    } catch (e, st) {
      Logger.root.severe('NfcScanService: Error scanning tag: $e', st);
      rethrow;
    }
  }

  Future<List<ndef.NDEFRecord>> readNdefRecords(
    NFCTag tag, {
    bool cached = false,
  }) async {
    try {
      final records = await FlutterNfcKit.readNDEFRecords(cached: cached);
      Logger.root.info('NfcScanService: Read ${records.length} NDEF records');
      for (var i = 0; i < records.length; i++) {
        final rec = records[i];
        final recData = rec.toString();
        Logger.root.info(
          'NfcScanService: Record[$i] type: ${rec.runtimeType}, data: $recData',
        );
      }
      return records;
    } catch (e, st) {
      Logger.root.severe('NfcScanService: Error reading NDEF records: $e', st);
      rethrow;
    }
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
    if (records.isEmpty) {
      Logger.root.info('NfcScanService: No records found');
      return null;
    }

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      Logger.root.info(
        'NfcScanService: Record[$i] type: ${record.runtimeType}',
      );

      if (record is ndef.UriRecord && record.uri != null) {
        Logger.root.info('NfcScanService: URI record found: ${record.uri}');
        return record.uri;
      }

      if (record is ndef.TextRecord) {
        final text = record.text;
        if (text == null) {
          Logger.root.info('NfcScanService: Text record has null text');
          continue;
        }

        Logger.root.info('NfcScanService: Text record[$i]: "$text"');
        final uri = _tryParseUri(text);
        if (uri != null) {
          Logger.root.info('NfcScanService: Parsed URI from text: $uri');
          return uri;
        }
      }
    }

    Logger.root.info('NfcScanService: No valid URI found in records');
    return null;
  }

  Uri? _tryParseUri(String input) {
    final trimmed = input.trim();

    if (_looksLikeUrl(trimmed)) {
      return Uri.tryParse(trimmed);
    }

    if (!_isLikelyBase64(trimmed)) {
      return null;
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

  bool _isLikelyBase64(String input) {
    if (input.isEmpty) return false;
    final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
    return base64Regex.hasMatch(input);
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
