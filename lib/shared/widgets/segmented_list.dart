import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';

/// Material 3 Expressive segmented list section: outer corners at 16 dp,
/// inner corners at 4 dp, and a 2 dp gap between items.
class SegmentedListSection extends StatelessWidget {
  final List<Widget> children;
  final Color? color;

  const SegmentedListSection({super.key, required this.children, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tileColor = color ?? colorScheme.surfaceContainerLow;
    const outer = Radius.circular(SolRadius.md);
    const inner = Radius.circular(SolSpace.xs);

    return Column(
      spacing: SolSpace.xxs,
      children: [
        for (var i = 0; i < children.length; i++)
          Builder(
            builder: (context) {
              final borderRadius = BorderRadius.vertical(
                top: i == 0 ? outer : inner,
                bottom: i == children.length - 1 ? outer : inner,
              );
              final shape = RoundedRectangleBorder(borderRadius: borderRadius);

              return Material(
                color: tileColor,
                shape: shape,
                clipBehavior: Clip.antiAlias,
                child: ListTileTheme.merge(
                  shape: shape,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  minTileHeight: 42,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SolSpace.lg,
                  ),
                  child: children[i],
                ),
              );
            },
          ),
      ],
    );
  }
}
