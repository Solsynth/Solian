import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/widgets/compose/article_sidebar_panel.dart';
import 'package:island/shared/widgets/responsive_sidebar.dart';

/// A specialized responsive sidebar widget for article composition.
///
/// This widget wraps the general-purpose [ResponsiveSidebar] and provides
/// the article-specific sidebar panel with attachments and settings tabs.
class ArticleResponsiveSidebar extends HookConsumerWidget {
  /// The content for the attachments panel
  final Widget attachmentsContent;

  /// The content for the settings panel
  final Widget settingsContent;

  /// The main content widget
  final Widget mainContent;

  /// The width of the sidebar when displayed on wide screens
  final double sidebarWidth;

  /// Controls whether the sidebar is visible
  final ValueNotifier<bool> showSidebar;

  const ArticleResponsiveSidebar({
    super.key,
    required this.attachmentsContent,
    required this.settingsContent,
    required this.mainContent,
    required this.showSidebar,
    this.sidebarWidth = 480,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveSidebar(
      sidebarWidth: sidebarWidth,
      showSidebar: showSidebar,
      mainContent: mainContent,
      // Build the article-specific sidebar panel
      sidebarContent: ArticleSidebarPanelWidget(
        attachmentsContent: attachmentsContent,
        settingsContent: settingsContent,
        onClose: () => showSidebar.value = false,
        isWide: true,
        width: sidebarWidth,
      ),
      // Custom drawer for narrow screens that includes the close handler
      drawerWidget: Drawer(
        width: sidebarWidth,
        child: ArticleSidebarPanelWidget(
          attachmentsContent: attachmentsContent,
          settingsContent: settingsContent,
          onClose: () {
            showSidebar.value = false;
          },
          isWide: false,
          width: sidebarWidth,
        ),
      ),
    );
  }
}
