import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/drive/drive_models/file.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/core/widgets/content/file_viewer_contents.dart';

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
              onPressed: () => FileDownloadService(ref).saveToGallery(item),
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
              onPressed: () =>
                  FileDownloadService(ref).downloadWithProgress(item),
            ),
          );
        }
        break;
    }

    // Always add info button
    actions.add(
      IconButton(icon: Icon(Icons.info_outline), onPressed: showInfoSheet),
    );

    actions.add(const Gap(8));

    return actions;
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
