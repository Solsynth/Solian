import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ComposeEmbedSheet extends HookConsumerWidget {
  final ComposeState state;

  const ComposeEmbedSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to embed view changes
    final currentEmbedView = useValueListenable(state.embedView);

    // Form state
    final uriController = useTextEditingController();
    final aspectRatioController = useTextEditingController();
    final selectedRenderer = useState<PostEmbedViewRenderer>(
      PostEmbedViewRenderer.webView,
    );
    final tabController = useTabController(initialLength: 2);
    final iframeController = useTextEditingController();

    void clearForm() {
      uriController.clear();
      aspectRatioController.clear();
      iframeController.clear();
      selectedRenderer.value = PostEmbedViewRenderer.webView;
    }

    // Populate form when embed view changes
    useEffect(() {
      if (currentEmbedView != null) {
        uriController.text = currentEmbedView.uri;
        aspectRatioController.text =
            currentEmbedView.aspectRatio?.toString() ?? '';
        selectedRenderer.value = currentEmbedView.renderer;
      } else {
        clearForm();
      }
      return null;
    }, [currentEmbedView]);

    void saveEmbedView() {
      final uri = uriController.text.trim();
      if (uri.isEmpty) {
        showSnackBar('embedUriRequired'.tr());
        return;
      }

      final aspectRatio = aspectRatioController.text.trim().isNotEmpty
          ? double.tryParse(aspectRatioController.text.trim())
          : null;

      final embedView = SnPostEmbedView(
        uri: uri,
        aspectRatio: aspectRatio,
        renderer: selectedRenderer.value,
      );

      if (currentEmbedView != null) {
        ComposeLogic.updateEmbedView(state, embedView);
      } else {
        ComposeLogic.setEmbedView(state, embedView);
      }
    }

    void parseIframe() {
      final iframe = iframeController.text.trim();
      if (iframe.isEmpty) return;

      final srcMatch = RegExp(r'src="([^"]*)"').firstMatch(iframe);
      final widthMatch = RegExp(r'width="([^"]*)"').firstMatch(iframe);
      final heightMatch = RegExp(r'height="([^"]*)"').firstMatch(iframe);

      if (srcMatch != null) {
        uriController.text = srcMatch.group(1)!;
      }

      if (widthMatch != null && heightMatch != null) {
        final w = double.tryParse(widthMatch.group(1)!);
        final h = double.tryParse(heightMatch.group(1)!);
        if (w != null && h != null && h != 0) {
          aspectRatioController.text = (w / h).toStringAsFixed(3);
        }
      }

      tabController.animateTo(1);
    }

    void deleteEmbed(BuildContext context) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('deleteEmbed').tr(),
          content: Text('deleteEmbedConfirm').tr(),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                ComposeLogic.deleteEmbedView(state);
                clearForm();
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('delete').tr(),
            ),
          ],
        ),
      );
    }

    return SheetScaffold(
      titleText: 'embedView'.tr(),
      heightFactor: 0.7,
      child: Column(
        children: [
          // Header with save button when editing
          if (currentEmbedView != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'editEmbed'.tr(),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: saveEmbedView,
                    style: ButtonStyle(visualDensity: VisualDensity.compact),
                    child: Text('save'.tr()),
                  ),
                ],
              ),
            ),

          // Tab bar
          TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'auto'.tr()),
              Tab(text: 'manual'.tr()),
            ],
          ),

          // Content area
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // Auto tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: iframeController,
                        decoration: InputDecoration(
                          labelText: 'iframeCode'.tr(),
                          hintText: 'iframeCodeHint'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 5,
                      ),
                      const Gap(16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: parseIframe,
                          icon: const Icon(Symbols.auto_fix),
                          label: Text('parseIframe'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
                // Manual tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form fields
                      TextField(
                        controller: uriController,
                        decoration: InputDecoration(
                          labelText: 'embedUri'.tr(),
                          hintText: 'https://example.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const Gap(16),
                      TextField(
                        controller: aspectRatioController,
                        decoration: InputDecoration(
                          labelText: 'aspectRatio'.tr(),
                          hintText: '16/9 = 1.777',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$'),
                          ),
                        ],
                      ),
                      const Gap(16),
                      DropdownButtonFormField2<PostEmbedViewRenderer>(
                        value: selectedRenderer.value,
                        decoration: InputDecoration(
                          labelText: 'renderer'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        selectedItemBuilder: (context) {
                          return PostEmbedViewRenderer.values.map((renderer) {
                            return Text(renderer.name).tr();
                          }).toList();
                        },
                        menuItemStyleData: MenuItemStyleData(
                          padding: EdgeInsets.zero,
                        ),
                        items: PostEmbedViewRenderer.values.map((renderer) {
                          return DropdownMenuItem(
                            value: renderer,
                            child: Text(
                              renderer.name,
                            ).tr().padding(horizontal: 20),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedRenderer.value = value;
                          }
                        },
                      ),

                      // Current embed view display (when exists)
                      if (currentEmbedView != null) ...[
                        const Gap(32),
                        Text(
                          'currentEmbed'.tr(),
                          style: theme.textTheme.titleMedium,
                        ).padding(horizontal: 4),
                        const Gap(8),
                        Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHigh,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 12,
                              top: 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      currentEmbedView.renderer ==
                                              PostEmbedViewRenderer.webView
                                          ? Symbols.web
                                          : Symbols.web,
                                      color: colorScheme.primary,
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        currentEmbedView.uri,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Symbols.delete),
                                      onPressed: () => deleteEmbed(context),
                                      tooltip: 'delete'.tr(),
                                      color: colorScheme.error,
                                    ),
                                  ],
                                ),
                                const Gap(12),
                                Text(
                                  'aspectRatio'.tr(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  currentEmbedView.aspectRatio != null
                                      ? currentEmbedView.aspectRatio!
                                            .toStringAsFixed(2)
                                      : 'notSet'.tr(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        const Gap(16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: saveEmbedView,
                            icon: const Icon(Symbols.add),
                            label: Text('addEmbed'.tr()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
