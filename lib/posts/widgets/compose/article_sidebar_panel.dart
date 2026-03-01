import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum SidebarPanelType { attachments, settings }

class ArticleSidebarPanelWidget extends HookConsumerWidget {
  final Widget attachmentsContent;
  final Widget settingsContent;
  final VoidCallback onClose;
  final bool isWide;
  final double width;

  const ArticleSidebarPanelWidget({
    super.key,
    required this.attachmentsContent,
    required this.settingsContent,
    required this.onClose,
    required this.isWide,
    this.width = 480,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activePanel = useState<SidebarPanelType>(
      SidebarPanelType.attachments,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, activePanel, colorScheme, onClose, theme),
        const Divider(height: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: activePanel.value == SidebarPanelType.attachments
                ? Container(
                    key: const ValueKey(SidebarPanelType.attachments),
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(child: attachmentsContent),
                  )
                : Container(
                    key: const ValueKey(SidebarPanelType.settings),
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(child: settingsContent),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ValueNotifier<SidebarPanelType> activePanel,
    ColorScheme colorScheme,
    VoidCallback onClose,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildSegmentedTabs(activePanel, colorScheme, theme),
          const Spacer(),
          if (!isWide)
            IconButton(
              icon: const Icon(Symbols.close),
              onPressed: onClose,
              tooltip: 'close'.tr(),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs(
    ValueNotifier<SidebarPanelType> activePanel,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return SegmentedButton<SidebarPanelType>(
      segments: [
        ButtonSegment(
          value: SidebarPanelType.attachments,
          label: Text('attachments'.tr()),
          icon: const Icon(Symbols.attach_file, size: 18),
        ),
        ButtonSegment(
          value: SidebarPanelType.settings,
          label: Text('settings'.tr()),
          icon: const Icon(Symbols.settings, size: 18),
        ),
      ],
      selected: {activePanel.value},
      onSelectionChanged: (Set<SidebarPanelType> selected) {
        if (selected.isNotEmpty) {
          activePanel.value = selected.first;
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onSecondaryContainer;
          }
          return colorScheme.onSurface;
        }),
      ),
    );
  }
}
