import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/drive/file_references.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/drive/upload_tasks.dart';
import 'package:island/models/drive_task.dart';
import 'package:island/services/responsive.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:island/widgets/content/file_viewer_contents.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:path/path.dart' show extension;
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';

class FileDetailScreen extends HookConsumerWidget {
  final SnCloudFile item;

  const FileDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final isWide = isWideScreen(context);

    // Animation controller for the drawer
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final animation = useMemoized(
      () => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      ),
      [animationController],
    );

    final showDrawer = useState(false);

    void showInfoSheet() {
      if (isWide) {
        // Show as animated right panel on wide screens
        showDrawer.value = !showDrawer.value;
        if (showDrawer.value) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      } else {
        // Show as bottom sheet on narrow screens
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          builder: (context) => FileInfoSheet(item: item),
        );
      }
    }

    // Listen to drawer state changes
    useEffect(() {
      void listener() {
        if (!animationController.isAnimating) {
          if (animationController.value == 0) {
            showDrawer.value = false;
          }
        }
      }

      animationController.addListener(listener);
      return () => animationController.removeListener(listener);
    }, [animationController]);

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(item.name.isEmpty ? 'File Details' : item.name),
        actions: _buildAppBarActions(context, ref, showInfoSheet),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Main content area - resizes with animation
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: constraints.maxWidth - animation.value * 400,
                    child: _buildContent(context, ref, serverUrl),
                  ),
                  // Animated drawer panel - overlays
                  if (isWide)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 400,
                      child: Transform.translate(
                        offset: Offset((1 - animation.value) * 400, 0),
                        child: SizedBox(
                          width: 400,
                          child: Material(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            elevation: 8,
                            child: FileInfoSheet(
                              item: item,
                              onClose: showInfoSheet,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    WidgetRef ref,
    VoidCallback showInfoSheet,
  ) {
    final actions = <Widget>[];

    // Add content-specific actions
    switch (item.mimeType?.split('/').firstOrNull) {
      case 'image':
        if (!kIsWeb) {
          actions.add(
            IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () async => _saveToGallery(ref),
            ),
          );
        }
        // HD/SD toggle will be handled in the image content overlay
        break;
      default:
        if (!kIsWeb) {
          actions.add(
            IconButton(
              icon: Icon(Icons.save_alt),
              onPressed: () async => _downloadFile(ref),
            ),
          );
        }
        break;
    }

    // Add references button
    actions.add(
      IconButton(
        icon: Icon(Icons.link),
        onPressed: () => showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          isScrollControlled: true,
          builder: (context) => SheetScaffold(
            titleText: 'File References',
            child: ReferencesList(fileId: item.id),
          ),
        ),
      ),
    );

    // Always add info button
    actions.add(
      IconButton(icon: Icon(Icons.info_outline), onPressed: showInfoSheet),
    );

    actions.add(const Gap(8));

    return actions;
  }

  Future<void> _saveToGallery(WidgetRef ref) async {
    try {
      showSnackBar('Saving image...');

      final client = ref.read(apiClientProvider);
      final tempDir = await getTemporaryDirectory();
      var extName = extension(item.name).trim();
      if (extName.isEmpty) {
        extName = item.mimeType?.split('/').lastOrNull ?? 'jpeg';
      }
      final filePath = '${tempDir.path}/${item.id}.$extName';

      await client.download(
        '/drive/files/${item.id}',
        filePath,
        queryParameters: {'original': true},
      );
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await Gal.putImage(filePath, album: 'Solar Network');
        showSnackBar('Image saved to gallery');
      } else {
        await FileSaver.instance.saveFile(
          name: item.name.isEmpty ? '${item.id}.$extName' : item.name,
          file: File(filePath),
        );
        showSnackBar('Image saved to $filePath');
      }
    } catch (e) {
      showErrorAlert(e);
    }
  }

  Future<void> _downloadFile(WidgetRef ref) async {
    final taskNotifier = ref.read(uploadTasksProvider.notifier);
    final taskId = taskNotifier.addLocalDownloadTask(item);
    try {
      showSnackBar('Downloading file...');

      final client = ref.read(apiClientProvider);
      final tempDir = await getTemporaryDirectory();
      var extName = extension(item.name).trim();
      if (extName.isEmpty) {
        extName = item.mimeType?.split('/').lastOrNull ?? 'bin';
      }
      final filePath = '${tempDir.path}/${item.id}.$extName';

      await client.download(
        '/drive/files/${item.id}',
        filePath,
        queryParameters: {'original': true},
        onReceiveProgress: (count, total) {
          if (total > 0) {
            taskNotifier.updateDownloadProgress(taskId, count, total);
            taskNotifier.updateTransmissionProgress(taskId, count / total);
          }
        },
      );

      await FileSaver.instance.saveFile(
        name: item.name.isEmpty ? '${item.id}.$extName' : item.name,
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

  Widget _buildContent(BuildContext context, WidgetRef ref, String serverUrl) {
    final uri = '$serverUrl/drive/files/${item.id}';

    return switch (item.mimeType?.split('/').firstOrNull) {
      'image' => ImageFileContent(item: item, uri: uri),
      'video' => VideoFileContent(item: item, uri: uri),
      'audio' => AudioFileContent(item: item, uri: uri),
      _ when item.mimeType == 'application/pdf' => PdfFileContent(uri: uri),
      _ when item.mimeType?.startsWith('text/') == true => TextFileContent(
        uri: uri,
      ),
      _ => GenericFileContent(item: item),
    };
  }
}

class ReferencesList extends ConsumerWidget {
  const ReferencesList({super.key, required this.fileId});

  final String fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncReferences = ref.watch(fileReferencesProvider(fileId));

    return asyncReferences.when(
      data: (references) => ListView.builder(
        itemCount: references.length,
        itemBuilder: (context, index) {
          final reference = references[index];
          return ListTile(
            leading: const Icon(Icons.link),
            title: Row(
              spacing: 6,
              children: [
                Text(
                  reference.usage,
                  style: GoogleFonts.robotoMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(reference.id, style: GoogleFonts.robotoMono(fontSize: 13)),
              ],
            ),
            subtitle: Row(
              spacing: 8,
              children: [
                Text(reference.createdAt.formatRelative(context)),
                const VerticalDivider(width: 1, thickness: 1).height(12),
                Text(reference.createdAt.formatSystem()),
              ],
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Error loading references: $error')),
    );
  }
}
