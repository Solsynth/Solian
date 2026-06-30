import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart'
    show DraggableOverlaySheet;
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/drive/file_permissions.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/core/widgets/content/file_viewer_contents.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final fileAuthorProvider = FutureProvider.family<SnAccount, String>((
  ref,
  accountId,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  return client.accounts.getAccountById(accountId);
});

@RoutePage()
class FileDetailScreen extends HookConsumerWidget {
  final String id;
  final String? heroTag;
  final SnPost? sourcePost;

  const FileDetailScreen({
    super.key,
    required this.id,
    this.heroTag,
    this.sourcePost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final isWide = isWideScreen(context);
    final currentUser = ref.watch(userInfoProvider).value;
    final fileAsync = ref.watch(driveFileInfoProvider(id));
    final currentItem = fileAsync.asData?.value;

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

    if (fileAsync.hasError) {
      return AppScaffold(
        isNoBackground: true,
        body: Center(child: Text(fileAsync.error.toString())),
      );
    }

    if (fileAsync.isLoading || currentItem == null) {
      return const AppScaffold(
        isNoBackground: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final file = currentItem;
    final showOwnerBar =
        file.accountId.isNotEmpty && file.accountId != currentUser?.id;
    final hasContextPanel = sourcePost != null || showOwnerBar;
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        kToolbarHeight;
    final collapsedPanelHeight = hasContextPanel ? 26.0 : 0.0;
    final minPanelHeight = collapsedPanelHeight;
    final maxPanelHeight = hasContextPanel
        ? (availableHeight * 0.45).clamp(180.0, 420.0)
        : 0.0;
    final midPanelHeight = hasContextPanel
        ? (availableHeight * 0.24).clamp(140.0, 240.0)
        : 0.0;
    final expandedPanelHeight = hasContextPanel
        ? (availableHeight * 0.34).clamp(200.0, 320.0)
        : 0.0;
    final snapPoints = hasContextPanel
        ? (() {
            final points = <double>{
              collapsedPanelHeight,
              midPanelHeight,
              expandedPanelHeight,
              maxPanelHeight,
            }.toList();
            points.sort();
            return points;
          })()
        : <double>[];
    final panelHeight = useState(hasContextPanel ? midPanelHeight : 0.0);

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
          builder: (context) => FileInfoSheet(item: file),
        );
      }
    }

    return Stack(
      children: [
        _buildBackground(file, serverUrl),
        AppScaffold(
          isNoBackground: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              file.name.isEmpty ? 'File Details' : file.name,
              style: const TextStyle(color: Colors.white),
            ),
            actions: _buildAppBarActions(context, ref, file, showInfoSheet),
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
                        child: _buildMainContent(
                          context,
                          ref,
                          serverUrl,
                          file,
                          showOwnerBar: showOwnerBar,
                          panelHeight: panelHeight.value,
                          collapsedPanelHeight: collapsedPanelHeight,
                          minPanelHeight: minPanelHeight,
                          maxPanelHeight: maxPanelHeight,
                          snapPoints: snapPoints,
                          onPanelHeightChanged: (value) =>
                              panelHeight.value = value,
                        ),
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
                                  item: file,
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
        ),
      ],
    );
  }

  List<Widget> _buildAppBarActions(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile item,
    VoidCallback showInfoSheet,
  ) {
    final actions = <Widget>[];

    // Add content-specific actions
    switch (item.mimeType.split('/').firstOrNull) {
      case 'image':
        if (!kIsWeb) {
          actions.add(
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.white),
              onPressed: () => ref
                  .read(driveFileDownloaderProvider)
                  .saveToGallery(
                    item,
                    useDownloadsFolder:
                        HardwareKeyboard.instance.isShiftPressed,
                  ),
            ),
          );
        }
        // HD/SD toggle will be handled in the image content overlay
        break;
      default:
        if (!kIsWeb) {
          actions.add(
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.white),
              onPressed: () => ref
                  .read(driveFileDownloaderProvider)
                  .downloadWithProgress(
                    item,
                    useDownloadsFolder:
                        HardwareKeyboard.instance.isShiftPressed,
                  ),
            ),
          );
        }
        break;
    }

    // Always add info button
    actions.add(
      IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.white),
        onPressed: showInfoSheet,
      ),
    );

    actions.add(const Gap(8));

    return actions;
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    String serverUrl,
    SnCloudFile item,
  ) {
    final uri = '$serverUrl/drive/files/${item.id}';

    Widget content = switch (item.mimeType.split('/').firstOrNull) {
      'image' => ImageFileContent(item: item, uri: uri),
      'video' => VideoFileContent(item: item, uri: uri),
      'audio' => AudioFileContent(item: item, uri: uri),
      _ when item.mimeType.startsWith('text/') == true => TextFileContent(
        uri: uri,
      ),
      _ => GenericFileContent(item: item),
    };

    if (heroTag != null && item.mimeType.startsWith('image') == true) {
      content = Hero(tag: heroTag!, child: content);
    }

    return content;
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    String serverUrl,
    SnCloudFile item, {
    required bool showOwnerBar,
    required double panelHeight,
    required double collapsedPanelHeight,
    required double minPanelHeight,
    required double maxPanelHeight,
    required List<double> snapPoints,
    required ValueChanged<double> onPanelHeightChanged,
  }) {
    final hasContextPanel = sourcePost != null || showOwnerBar;
    final content = _buildContent(context, ref, serverUrl, item);
    if (!hasContextPanel) return content;

    return DraggableOverlaySheet(
      body: content,
      minHeight: minPanelHeight,
      initialHeight: panelHeight,
      maxHeight: maxPanelHeight,
      snapHeights: snapPoints,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.96),
      onHeightChanged: onPanelHeightChanged,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sourcePost != null)
              PostItem(
                item: sourcePost!,
                padding: EdgeInsets.zero,
                isCompact: true,
                hideAttachments: true,
                isEmbedReply: false,
                isShowReference: false,
                isTextSelectable: false,
                isTranslatable: false,
              ),
            if (sourcePost != null && showOwnerBar) const Gap(12),
            if (showOwnerBar) _buildOwnerBar(context, ref, item.accountId),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(SnCloudFile item, String serverUrl) {
    final uri = '$serverUrl/drive/files/${item.id}?thumbnail=true';
    final isVideo = item.mimeType.startsWith('video') == true;
    final isImage = item.mimeType.startsWith('image') == true;

    if (isVideo || isImage) {
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: isImage
                  ? CloudImageWidget(
                      file: item,
                      fit: BoxFit.cover,
                      noBlurhash: true,
                    )
                  : Image.network(
                      uri,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.black),
                    ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.black38),
            ),
          ],
        ),
      );
    }

    return Container(color: Colors.black);
  }

  Widget _buildOwnerBar(BuildContext context, WidgetRef ref, String accountId) {
    final owner = ref.watch(fileAuthorProvider(accountId));
    final theme = Theme.of(context);

    return owner.when(
      data: (account) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.router.push(AccountProfileRoute(name: account.name)),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                ProfilePictureWidget(file: account.profile.picture, radius: 18),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Original uploader',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      AccountName(
                        account: account,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        hideOverlay: true,
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const Gap(12),
            Text('Loading uploader...', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
