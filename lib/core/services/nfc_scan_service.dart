import 'dart:async';

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

      // Handle URI record directly
      if (record is ndef.UriRecord && record.uri != null) {
        Logger.root.info('NfcScanService: URI record found: ${record.uri}');
        return record.uri;
      }

      // Handle text record containing a URL
      if (record is ndef.TextRecord) {
        final text = record.text;
        if (text == null) {
          Logger.root.info('NfcScanService: Text record has null text');
          continue;
        }

        Logger.root.info('NfcScanService: Text record[$i]: "$text"');
        final trimmed = text.trim();

        // Check if it looks like a solian:// URL
        if (trimmed.toLowerCase().startsWith('solian://')) {
          final uri = Uri.tryParse(trimmed);
          if (uri != null) {
            Logger.root.info('NfcScanService: Parsed solian URI: $uri');
            return uri;
          }
        }
      }
    }

    Logger.root.info('NfcScanService: No valid URI found in records');
    return null;
  }
}
