import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/discovery_profile_sheet.dart';
import 'package:island/posts/widgets/compose/filters/post_subscription_filter.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Opens the explore page's quick configuration sheet.
///
/// The same three knobs the settings screen owns — the ranking mode, the
/// aggressive filter and the discovery profile — plus the subscription
/// publisher/category/tag filter, reachable without leaving the feed.
///
/// [selectedPublisherNames] is the page's session-scoped publisher pick: it
/// supersedes the persisted category/tag filters while it is non-empty, so the
/// sheet writes it back to the caller instead of persisting it.
void showExploreConfigSheet(
  BuildContext context, {
  required ValueNotifier<List<String>> selectedPublisherNames,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (sheetContext) {
      return SheetScaffold(
        titleText: 'explorePreferred'.tr(),
        heightFactor: 0.7,
        child: _ExploreConfigSheet(
          selectedPublisherNames: selectedPublisherNames,
        ),
      );
    },
  );
}

class _ExploreConfigSheet extends ConsumerWidget {
  final ValueNotifier<List<String>> selectedPublisherNames;

  const _ExploreConfigSheet({required this.selectedPublisherNames});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(appSettingsProvider);
    final exploreSettings = settings.exploreSettings;
    final notifier = ref.read(appSettingsProvider.notifier);

    void apply(ExploreSettings value) => notifier.setExploreSettings(value);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SolSpace.lg,
        SolSpace.sm,
        SolSpace.lg,
        SolSpace.xxl,
      ),
      children: [
        _ConfigGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SolSpace.lg,
                  SolSpace.md,
                  SolSpace.lg,
                  SolSpace.sm,
                ),
                child: Text(
                  'explorePreferred'.tr(),
                  style: theme.textTheme.titleSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SolSpace.md,
                  0,
                  SolSpace.md,
                  SolSpace.md,
                ),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'personalized',
                      label: Text('exploreModePersonalized'.tr()),
                      icon: const Icon(Symbols.mindfulness, size: 18),
                    ),
                    ButtonSegment(
                      value: 'top',
                      label: Text('exploreModeTop'.tr()),
                      icon: const Icon(Symbols.trending_up, size: 18),
                    ),
                    ButtonSegment(
                      value: 'latest',
                      label: Text('exploreModeLatest'.tr()),
                      icon: const Icon(Symbols.schedule, size: 18),
                    ),
                  ],
                  selected: {exploreSettings.mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      apply(exploreSettings.copyWith(mode: selection.first)),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: Text('exploreAggressiveMode'.tr()),
                subtitle: Text('exploreAggressiveModeDescription'.tr()),
                secondary: const Icon(Symbols.bolt),
                value: exploreSettings.aggressiveMode,
                onChanged: (value) =>
                    apply(exploreSettings.copyWith(aggressiveMode: value)),
              ),
              if (exploreSettings.mode == 'personalized') ...[
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Symbols.mindfulness),
                  title: Text('exploreDiscoveryProfile'.tr()),
                  subtitle: Text('exploreDiscoveryProfileDescription'.tr()),
                  trailing: const Icon(Symbols.chevron_right),
                  onTap: () => showDiscoveryProfileSheet(context),
                ),
              ],
            ],
          ),
        ),
        const Gap(SolSpace.lg),
        _ConfigGroup(
          child: PostSubscriptionFilterWidget(
            initialSelectedPublishers: selectedPublisherNames.value,
            initialSelectedCategories: exploreSettings.selectedCategoryIds,
            initialSelectedTags: exploreSettings.selectedTagIds,
            onSelectedPublishersChanged: (names) {
              selectedPublisherNames.value = names;
            },
            onSelectedCategoriesChanged: (ids) =>
                apply(exploreSettings.copyWith(selectedCategoryIds: ids)),
            onSelectedTagsChanged: (ids) =>
                apply(exploreSettings.copyWith(selectedTagIds: ids)),
          ),
        ),
      ],
    );
  }
}

/// A tonal card grouping the sheet's rows, matching the page's own cards.
class _ConfigGroup extends StatelessWidget {
  final Widget child;

  const _ConfigGroup({required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHigh.withOpacity(0.55),
      borderRadius: SolRadius.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
