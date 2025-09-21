import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:croppy/croppy.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:island/models/file.dart';
import 'package:island/services/file_uploader.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';

enum FileUploadMode { generic, mediaSafe }

Future<XFile?> cropImage(
  BuildContext context, {
  required XFile image,
  List<CropAspectRatio?>? allowedAspectRatios,
  bool replacePath = true,
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

Completer<SnCloudFile?> putFileToCloud({
  required UniversalFile fileData,
  required String atk,
  required String baseUrl,
  String? poolId,
  String? filename,
  String? mimetype,
  FileUploadMode? mode,
  Function(double progress, Duration estimate)? onProgress,
}) {
  final completer = Completer<SnCloudFile?>();

  final effectiveMode =
      mode ??
      (fileData.type == UniversalFileType.file
          ? FileUploadMode.generic
          : FileUploadMode.mediaSafe);

  if (effectiveMode == FileUploadMode.mediaSafe &&
      fileData.isOnDevice &&
      fileData.type == UniversalFileType.image) {
    final data = fileData.data;
    if (data is XFile && !kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      Exif.fromPath(data.path)
          .then((exif) async {
            final gpsAttributes = {
              'GPSLatitude': '',
              'GPSLatitudeRef': '',
              'GPSLongitude': '',
              'GPSLongitudeRef': '',
              'GPSAltitude': '',
              'GPSAltitudeRef': '',
              'GPSTimeStamp': '',
              'GPSProcessingMethod': '',
              'GPSDateStamp': '',
            };
            await exif.writeAttributes(gpsAttributes);
          })
          .then(
            (_) => _processUpload(
              fileData,
              atk,
              baseUrl,
              poolId,
              filename,
              mimetype,
              onProgress,
              completer,
            ),
          )
          .catchError((e) {
            debugPrint('Error removing GPS EXIF data: $e');
            return _processUpload(
              fileData,
              atk,
              baseUrl,
              poolId,
              filename,
              mimetype,
              onProgress,
              completer,
            );
          });

      return completer;
    }
  }

  _processUpload(
    fileData,
    atk,
    baseUrl,
    poolId,
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
  String? poolId,
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

  // Create Dio instance
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Authorization': 'AtField $atk',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  final uploader = FileUploader(dio);

  // Get File object
  File fileObj;
  if (file.path.isNotEmpty) {
    fileObj = File(file.path);
    // Call progress start
    onProgress?.call(0.0, Duration.zero);
    uploader
        .uploadFile(
          file: fileObj,
          fileName: actualFilename,
          contentType: actualMimetype,
          poolId: poolId,
        )
        .then((result) {
          // Call progress end
          onProgress?.call(1.0, Duration.zero);
          completer.complete(result);
        })
        .catchError((e) {
          completer.completeError(e);
          throw e;
        });
  } else {
    // Write to temp file
    getTemporaryDirectory()
        .then((tempDir) {
          final tempFile = File('${tempDir.path}/temp_upload_$actualFilename');
          file
              .readAsBytes()
              .then((bytes) => tempFile.writeAsBytes(bytes))
              .then((_) {
                fileObj = tempFile;
                // Call progress start
                onProgress?.call(0.0, Duration.zero);
                uploader
                    .uploadFile(
                      file: fileObj,
                      fileName: actualFilename,
                      contentType: actualMimetype,
                      poolId: poolId,
                    )
                    .then((result) {
                      // Call progress end
                      onProgress?.call(1.0, Duration.zero);
                      completer.complete(result);
                    })
                    .catchError((e) {
                      completer.completeError(e);
                      throw e;
                    });
              })
              .catchError((e) {
                completer.completeError(e);
                throw e;
              });
        })
        .catchError((e) {
          completer.completeError(e);
          throw e;
        });
  }

  return completer;
}
