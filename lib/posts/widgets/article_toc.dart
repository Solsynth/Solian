import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/posts/widgets/compose/post_shared.dart'
    show SnPostSection;
import 'package:island/shared/widgets/content/markdown.dart'
    show MarkdownHeadingAnchor;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';

/// Whether two captured heading-anchor lists describe the same headings.
/// Used to keep the scroll targets stable across markdown rebuilds.
bool sameHeadingAnchors(
  List<MarkdownHeadingAnchor> a,
  List<MarkdownHeadingAnchor> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].text != b[i].text || a[i].level != b[i].level) return false;
  }
  return true;
}

/// Pairs each scanned section with the rendered heading it points at, matching
/// by level/text and occurrence so repeated headings stay distinct. Entries the
/// renderer did not produce (or has not produced yet) stay null and simply are
/// not scrollable.
List<MarkdownHeadingAnchor?> matchSectionAnchors(
  List<SnPostSection> sections,
  List<MarkdownHeadingAnchor> anchors,
) {
  final usedOccurrences = <String, int>{};
  return [
    for (final section in sections)
      () {
        final signature = '${section.level}\u0000${section.title}';
        final occurrence = usedOccurrences.update(
          signature,
          (count) => count + 1,
          ifAbsent: () => 0,
        );
        var seen = 0;
        for (final anchor in anchors) {
          if (anchor.level != section.level || anchor.text != section.title) {
            continue;
          }
          if (seen == occurrence) return anchor;
          seen++;
        }
        return null;
      }(),
  ];
}

/// The contents list: every heading, indented by level, with the section being
/// read highlighted and finished sections dimmed. The list keeps the active
/// entry in view while the reader scrolls the article.
class ArticleTocList extends HookWidget {
  final List<SnPostSection> sections;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  const ArticleTocList({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryKeys = useRef(<int, GlobalKey>{});

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final entry = entryKeys.value[activeIndex]?.currentContext;
        if (entry == null) return;
        final entryBox = entry.findRenderObject();
        final scrollable = entry.findAncestorStateOfType<ScrollableState>();
        if (entryBox is! RenderBox || scrollable == null) return;
        final viewportBox = scrollable.context.findRenderObject();
        if (viewportBox is! RenderBox) return;

        final top = entryBox
            .localToGlobal(Offset.zero, ancestor: viewportBox)
            .dy;
        final inView =
            top >= 0 && top + entryBox.size.height <= viewportBox.size.height;
        if (inView) return;

        // Only the contents list scrolls; a horizontal tab view is untouched.
        scrollable.position.ensureVisible(
          entryBox,
          alignment: 0.5,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
      return null;
    }, [activeIndex]);

    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Text(
          'articleNoContents'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final isActive = index == activeIndex;
        final isRead = index < activeIndex;
        return InkWell(
          key: entryKeys.value.putIfAbsent(index, GlobalKey.new),
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelect(index),
          child: Padding(
            padding: EdgeInsets.only(
              left: 10 + (section.level - 1) * 14,
              right: 10,
              top: 7,
              bottom: 7,
            ),
            child: Text(
              section.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : isRead
                    ? theme.colorScheme.onSurface.withOpacity(0.4)
                    : theme.colorScheme.onSurface,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom-sheet presentation of the contents, hosted on [SheetScaffold].
/// Tapping an entry pops the sheet and jumps the reader to that section.
/// [activeIndex] is a listenable so the entry being read stays highlighted
/// while the sheet is open.
class PostTocSheet extends StatelessWidget {
  final List<SnPostSection> sections;
  final ValueListenable<int> activeIndex;
  final ValueChanged<int> onSelect;

  const PostTocSheet({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      titleText: 'articleContents'.tr(),
      heightFactor: 0.8,
      child: ValueListenableBuilder<int>(
        valueListenable: activeIndex,
        builder: (context, index, _) => ArticleTocList(
          sections: sections,
          activeIndex: index,
          onSelect: (selected) {
            Navigator.pop(context);
            onSelect(selected);
          },
        ),
      ),
    );
  }
}

/// Presents the article contents as a modal sheet, then jumps to the selected
/// section once the sheet is gone.
void showPostTocSheet(
  BuildContext context, {
  required List<SnPostSection> sections,
  required ValueListenable<int> activeIndex,
  required ValueChanged<int> onSelect,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => PostTocSheet(
      sections: sections,
      activeIndex: activeIndex,
      onSelect: onSelect,
    ),
  );
}
