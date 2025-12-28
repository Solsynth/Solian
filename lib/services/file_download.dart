import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/drive_task.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/drive/upload_tasks.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileDownloadService {
  final WidgetRef ref;

  FileDownloadService(this.ref);

  String _getFileExtension(SnCloudFile item) {
    var extName = p.extension(item.name).trim();
    if (extName.isEmpty) {
      extName = item.mimeType?.split('/').lastOrNull ?? 'jpeg';
    }
    return extName.replaceFirst('.', '');
  }

  String _getFileName(SnCloudFile item, String extName) {
    return item.name.isEmpty ? '${item.id}.$extName' : item.name;
  }

  Future<String> _downloadToTemp(SnCloudFile item, String extName) async {
    final client = ref.read(apiClientProvider);
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${item.id}.$extName';

    await client.download(
      '/drive/files/${item.id}',
      filePath,
      queryParameters: {'original': true},
    );

    return filePath;
  }

  Future<void> saveToGallery(SnCloudFile item) async {
    try {
      showSnackBar('Saving image...');

      final extName = _getFileExtension(item);
      final filePath = await _downloadToTemp(item, extName);

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImage(filePath, album: 'Solar Network');
        showSnackBar('Image saved to gallery');
      } else {
        await FileSaver.instance.saveFile(
          name: _getFileName(item, extName),
          file: File(filePath),
        );
        showSnackBar('Image saved to downloads');
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadFile(SnCloudFile item) async {
    try {
      showSnackBar('Downloading file...');

      final extName = _getFileExtension(item);
      final filePath = await _downloadToTemp(item, extName);

      await FileSaver.instance.saveFile(
        name: _getFileName(item, extName),
        file: File(filePath),
      );
      showSnackBar('File saved to downloads');
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> downloadWithProgress(
    SnCloudFile item, {
    void Function(int received, int total)? onProgress,
  }) async {
    final taskNotifier = ref.read(uploadTasksProvider.notifier);
    final taskId = taskNotifier.addLocalDownloadTask(item);

    try {
      showSnackBar('Downloading file...');

      final client = ref.read(apiClientProvider);
      final extName = _getFileExtension(item);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${item.id}.$extName';

      await client.download(
        '/drive/files/${item.id}',
        filePath,
        queryParameters: {'original': true},
        onReceiveProgress: (count, total) {
          onProgress?.call(count, total);
          if (total > 0) {
            taskNotifier.updateDownloadProgress(taskId, count, total);
            taskNotifier.updateTransmissionProgress(taskId, count / total);
          }
        },
      );

      await FileSaver.instance.saveFile(
        name: _getFileName(item, extName),
        file: File(filePath),
      );
      taskNotifier.updateTaskStatus(taskId, DriveTaskStatus.completed);
      showSnackBar('File saved to downloads');
    } catch (e) {
      taskNotifier.updateTaskStatus(
        taskId,
        DriveTaskStatus.failed,
        errorMessage: e.toString(),
      );
      showErrorAlert(e);
    }
  }
}
