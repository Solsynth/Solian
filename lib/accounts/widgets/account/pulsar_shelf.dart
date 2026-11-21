import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/activity/pulsar_models.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// One case on a shelf.
///
/// The types this app puts on a shelf — albums, games, films, books, plays —
/// are all things a person owns and keeps, so the case is the unit: artwork
/// first, then name and maker beneath it, the way a spine label sits under a
/// box. Badges that describe *state* (status, rating, how often it was played)
/// ride on the artwork rather than competing with the title.
class PulsarShelfEntry {
  final String title;
  final String? subtitle;

  /// Candidate artwork addresses in priority order. The first that loads
  /// wins; the rest exist because Steam only ships portrait art for games
  /// that got library assets.
  final List<String> artwork;
  final IconData fallbackIcon;
  final String? badge;
  final Color? badgeColor;
  final String? cornerLabel;
  final IconData? cornerIcon;
  final IconData? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  const PulsarShelfEntry({
    required this.title,
    this.subtitle,
    this.artwork = const [],
    this.fallbackIcon = Symbols.category,
    this.badge,
    this.badgeColor,
    this.cornerLabel,
    this.cornerIcon,
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
    this.onTap,
  });
}

/// Case proportions by domain. Music is a square sleeve; everything else is a
/// portrait case with roughly the same shape as a game box or a book.
double pulsarShelfAspect(String? domain) {
  return domain == 'music' ? 1.0 : 2 / 3;
}

/// A row of cases on a shelf, with the shelf head above it.
///
/// The head is the shelf's label, so it is quiet: a small glyph, the name, a
/// count, and an action. The ledge is drawn, not implied: cases stand on a
/// hairline with a little shadow falling below it, which is what makes a rail
/// of images read as a shelf instead of a carousel.
class PulsarShelf extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final int? count;
  final Widget? trailing;
  final VoidCallback? onSeeAll;
  final List<PulsarShelfEntry> entries;
  final double tileWidth;
  final double aspectRatio;
  final EdgeInsetsGeometry padding;

  const PulsarShelf({
    super.key,
    this.title,
    this.icon,
    this.count,
    this.trailing,
    this.onSeeAll,
    required this.entries,
    this.tileWidth = 124,
    this.aspectRatio = 2 / 3,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight = tileWidth / aspectRatio;
    // Two lines of caption under each case. Scaled with the reader's text
    // size so a large type setting does not clip the second line.
    final captionHeight = MediaQuery.textScalerOf(context).scale(42);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SolSpace.md,
      children: [
        if (title != null)
          Padding(
            padding: padding,
            child: Row(
              spacing: SolSpace.sm,
              children: [
                if (icon != null)
                  Icon(icon, size: 14, color: theme.colorScheme.primary),
                Expanded(
                  child: Row(
                    spacing: SolSpace.sm,
                    children: [
                      Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (count != null)
                        Text(
                          '$count',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
                if (onSeeAll != null)
                  TextButton(
                    onPressed: onSeeAll,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: SolSpace.sm,
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text('seeAll'.tr()),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: imageHeight + captionHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Gap(SolSpace.sm),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return SizedBox(
                width: tileWidth,
                child: _ShelfCase(
                  key: ValueKey('$index\u0000${entry.title}'),
                  entry: entry,
                  imageHeight: imageHeight,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShelfCase extends StatelessWidget {
  final PulsarShelfEntry entry;
  final double imageHeight;

  const _ShelfCase({super.key, required this.entry, required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: entry.onTap,
      borderRadius: BorderRadius.circular(SolRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: imageHeight,
            child: PulsarCover(
              artwork: entry.artwork,
              fallbackIcon: entry.fallbackIcon,
              badge: entry.badge,
              badgeColor: entry.badgeColor,
              cornerLabel: entry.cornerLabel,
              cornerIcon: entry.cornerIcon,
              actionIcon: entry.actionIcon,
              actionTooltip: entry.actionTooltip,
              onAction: entry.onAction,
            ),
          ),
          const Gap(SolSpace.xs + 2),
          Text(
            entry.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          if (entry.subtitle != null && entry.subtitle!.isNotEmpty)
            Text(
              entry.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// A single artwork case: the image, an optional status pill, and a fallback
/// that says which kind of thing it is when the picture never arrives.
class PulsarCover extends HookConsumerWidget {
  final List<String> artwork;
  final IconData fallbackIcon;
  final String? badge;
  final Color? badgeColor;
  final String? cornerLabel;
  final IconData? cornerIcon;
  final IconData? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;
  final BorderRadius? borderRadius;

  const PulsarCover({
    super.key,
    required this.artwork,
    required this.fallbackIcon,
    this.badge,
    this.badgeColor,
    this.cornerLabel,
    this.cornerIcon,
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final attempt = useState(0);
    final serverUrl = ref.watch(serverUrlProvider);
    final token = ref.watch(tokenProvider);
    final radius = borderRadius ?? BorderRadius.circular(SolRadius.sm);

    // Rows recycle their State as the shelves rebuild, so the fallback index
    // is reset synchronously against the artwork it belongs to — an effect
    // would run a frame later and briefly show the previous entry's picture.
    final urls = artwork;
    final signature = urls.join('\u0000');
    final lastSignature = useRef<String?>(null);
    if (lastSignature.value != signature) {
      lastSignature.value = signature;
      attempt.value = 0;
    }
    final url = attempt.value < urls.length ? urls[attempt.value] : null;

    Widget placeholder() {
      // A case with no picture still shows what it is: the domain glyph on the
      // card stock, not a broken image.
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: radius,
        ),
        alignment: Alignment.center,
        child: Icon(
          fallbackIcon,
          size: 26,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      );
    }

    Widget cover = url == null
        ? placeholder()
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            memCacheWidth: 384,
            httpHeaders: url.startsWith(serverUrl) && token != null
                ? {'Authorization': 'Bearer ${token.token}'}
                : null,
            fadeInDuration: const Duration(milliseconds: 120),
            placeholder: (_, _) => placeholder(),
            errorWidget: (_, _, _) {
              if (attempt.value + 1 < urls.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) attempt.value = attempt.value + 1;
                });
              }
              return placeholder();
            },
          );

    cover = AnimatedSwitcher(
      duration: const Duration(milliseconds: 120),
      child: KeyedSubtree(
        key: ValueKey(url ?? 'placeholder'),
        child: ClipRRect(borderRadius: radius, child: cover),
      ),
    );

    if (badge == null && cornerLabel == null && actionIcon == null) {
      return cover;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        cover,
        if (cornerLabel != null)
          Positioned(
            left: SolSpace.xs,
            top: SolSpace.xs,
            child: _ShelfPill(
              label: cornerLabel!,
              icon: cornerIcon,
              background: Colors.black.withValues(alpha: 0.62),
              foreground: Colors.white,
            ),
          ),
        ?badge == null
            ? null
            : Positioned(
                left: SolSpace.xs,
                right: SolSpace.xs,
                bottom: SolSpace.xs,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _ShelfPill(
                    label: badge!,
                    dotColor: badgeColor ?? theme.colorScheme.primary,
                    background: Colors.black.withValues(alpha: 0.62),
                    foreground: Colors.white,
                  ),
                ),
              ),
        if (actionIcon != null)
          Positioned(
            right: SolSpace.xs,
            top: SolSpace.xs,
            child: Tooltip(
              message: actionTooltip ?? '',
              child: Material(
                color: Colors.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAction,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(actionIcon, size: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A label read over artwork.
///
/// The scrim is always near-black rather than the status color: status hues
/// include light greens and oranges that cannot carry white text, and a cover
/// is an arbitrary picture anyway, so a neutral scrim is the only background
/// that holds on every image. Colour survives as a dot, where contrast rules
/// do not apply.
class _ShelfPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? dotColor;
  final Color background;
  final Color foreground;

  const _ShelfPill({
    required this.label,
    this.icon,
    this.dotColor,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SolRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 10, color: foreground),
            const SizedBox(width: 2),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The domain filter above a shelf. Domains are the file system this library
/// sorts by, so the row reads as tabs, not as tags.
class PulsarDomainFilterRow extends StatelessWidget {
  final String? selectedDomain;
  final List<String> domains;
  final bool includeAll;
  final ValueChanged<String?> onChanged;

  const PulsarDomainFilterRow({
    super.key,
    required this.selectedDomain,
    required this.domains,
    required this.onChanged,
    this.includeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: SolSpace.xs,
        children: [
          if (includeAll)
            ChoiceChip(
              selected: selectedDomain == null,
              onSelected: (_) => onChanged(null),
              label: Text('all'.tr()),
              visualDensity: VisualDensity.compact,
            ),
          for (final domain in domains)
            ChoiceChip(
              selected: selectedDomain == domain,
              onSelected: (_) => onChanged(domain),
              avatar: Icon(PulsarDomain.icon(domain), size: 16),
              label: Text(PulsarDomain.label(domain)),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// The status filter above work shelves. Ordered by how far through the work
/// the reader is, so the chips double as a progress ladder.
class PulsarStatusFilterRow extends StatelessWidget {
  final String? selectedStatus;
  final ValueChanged<String?> onChanged;

  const PulsarStatusFilterRow({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: SolSpace.xs,
        children: [
          ChoiceChip(
            selected: selectedStatus == null,
            onSelected: (_) => onChanged(null),
            label: Text('all'.tr()),
            visualDensity: VisualDensity.compact,
          ),
          for (final status in PulsarWorkStatus.all)
            ChoiceChip(
              selected: selectedStatus == status,
              onSelected: (_) => onChanged(status),
              avatar: Icon(PulsarWorkStatus.icon(status), size: 16),
              label: Text(PulsarWorkStatus.label(status)),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// What a shelf says when it has nothing on it: the next action, not an
/// apology.
class PulsarShelfEmptyHint extends StatelessWidget {
  final String text;
  final Widget? action;

  const PulsarShelfEmptyHint({super.key, required this.text, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SolSpace.md,
        vertical: SolSpace.lg,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SolRadius.sm),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Symbols.inventory_2,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const Gap(SolSpace.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class PulsarShelfLoading extends StatelessWidget {
  const PulsarShelfLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
