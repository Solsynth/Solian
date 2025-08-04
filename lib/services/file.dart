import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:croppy/croppy.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:island/models/file.dart';
import 'package:native_exif/native_exif.dart';
import 'package:tus_client_dart/tus_client_dart.dart';

Future<XFile?> cropImage(
  BuildContext context, {
  required XFile image,
  List<CropAspectRatio?>? allowedAspectRatios,
  bool replacePath = false,
}) async {
  final result = await showMaterialImageCropper(
    context,
    imageProvider:
        kIsWeb ? NetworkImage(image.path) : FileImage(File(image.path)),
    showLoadingIndicatorOnSubmit: true,
    allowedAspectRatios: allowedAspectRatios,
  );
  if (result == null) return null; // Cancelled operation
  final croppedFile = result.uiImage;
  final croppedBytes = await croppedFile.toByteData(
    format: ImageByteFormat.png,
  );
  if (croppedBytes == null) {
    return image;
  }
  croppedFile.dispose();
  return XFile.fromData(
    croppedBytes.buffer.asUint8List(),
    path: !replacePath ? image.path : null,
    mimeType: image.mimeType,
  );
}

Completer<SnCloudFile?> putMediaToCloud({
  required UniversalFile fileData,
  required String atk,
  required String baseUrl,
  String? filename,
  String? mimetype,
  Function(double progress, Duration estimate)? onProgress,
}) {
  final completer = Completer<SnCloudFile?>();

  // Process the image to remove GPS EXIF data if needed
  if (fileData.isOnDevice && fileData.type == UniversalFileType.image) {
    final data = fileData.data;
    if (data is XFile && !kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Use native_exif to selectively remove GPS data
      Exif.fromPath(data.path)
          .then((exif) {
            // Remove GPS-related attributes
            final gpsAttributes = [
              'GPSLatitude',
              'GPSLatitudeRef',
              'GPSLongitude',
              'GPSLongitudeRef',
              'GPSAltitude',
              'GPSAltitudeRef',
              'GPSTimeStamp',
              'GPSProcessingMethod',
              'GPSDateStamp',
            ];

            // Create a map of attributes to clear
            final clearAttributes = <String, String>{};
            for (final attr in gpsAttributes) {
              clearAttributes[attr] = '';
            }

            // Write empty values to remove GPS data
            return exif.writeAttributes(clearAttributes);
          })
          .then((_) {
            // Continue with upload after GPS data is removed
            _processUpload(
              fileData,
              atk,
              baseUrl,
              filename,
              mimetype,
              onProgress,
              completer,
            );
          })
          .catchError((e) {
            // If there's an error, continue with the original file
            debugPrint('Error removing GPS EXIF data: $e');
            _processUpload(
              fileData,
              atk,
              baseUrl,
              filename,
              mimetype,
              onProgress,
              completer,
            );
          });

      return completer;
    }
  }

  // If not an image or on web, continue with normal upload
  _processUpload(
    fileData,
    atk,
    baseUrl,
    filename,
    mimetype,
    onProgress,
    completer,
  );
  return completer;
}

// Helper method to process the upload after any EXIF processing
Completer<SnCloudFile?> _processUpload(
  UniversalFile fileData,
  String atk,
  String baseUrl,
  String? filename,
  String? mimetype,
  Function(double progress, Duration estimate)? onProgress,
  Completer<SnCloudFile?> completer,
) {
  late XFile file;
  String actualFilename = filename ?? 'randomly_file';
  String actualMimetype = mimetype ?? '';
  Uint8List? byteData;

  // Handle the data based on what's in the UniversalFile
  final data = fileData.data;

  if (data is XFile) {
    file = data;
    actualFilename = filename ?? data.name;
    actualMimetype = mimetype ?? data.mimeType ?? '';
  } else if (data is List<int> || data is Uint8List) {
    byteData = data is List<int> ? Uint8List.fromList(data) : data;
    actualFilename = filename ?? 'uploaded_file';
    actualMimetype = mimetype ?? 'application/octet-stream';
    if (mimetype == null) {
      completer.completeError(
        ArgumentError('Mimetype is required when providing raw bytes.'),
      );
      return completer;
    }
    file = XFile.fromData(byteData!, mimeType: actualMimetype);
  } else if (data is SnCloudFile) {
    // If the file is already on the cloud, just return it
    completer.complete(data);
    return completer;
  } else {
    completer.completeError(
      ArgumentError(
        'Invalid fileData type. Expected data to be XFile, List<int>, Uint8List, or SnCloudFile.',
      ),
    );
    return completer;
  }

  final Map<String, String> metadata = {
    'filename': actualFilename,
    'content-type': actualMimetype,
  };

  final client = TusClient(file);
  client
      .upload(
        uri: Uri.parse('$baseUrl/drive/tus'),
        headers: {'Authorization': 'AtField $atk'},
        metadata: metadata,
        onComplete: (lastResponse) {
          final resp = jsonDecode(lastResponse!.headers['x-fileinfo']!);
          completer.complete(SnCloudFile.fromJson(resp));
        },
        onProgress: (double progress, Duration estimate) {
          onProgress?.call(progress, estimate);
        },
      )
      .catchError(completer.completeError);

  return completer;
}
