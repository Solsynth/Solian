import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostFilterWidget extends HookConsumerWidget {
  final TabController categoryTabController;
  final PostListQuery initialQuery;
  final ValueChanged<PostListQuery> onQueryChanged;
  final bool hideSearch;

  const PostFilterWidget({
    super.key,
    required this.categoryTabController,
    required this.initialQuery,
    required this.onQueryChanged,
    this.hideSearch = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initialShowAdvancedFilters =
        (initialQuery.queryTerm?.isNotEmpty ?? false) ||
        initialQuery.searchEngine != null ||
        initialQuery.periodStart != null ||
        initialQuery.periodEnd != null ||
        initialQuery.order != null;

    final includeReplies = useState<bool?>(initialQuery.includeReplies);
    final mediaOnly = useState<bool>(initialQuery.mediaOnly ?? false);
    final queryTerm = useState<String?>(initialQuery.queryTerm);
    final searchEngine = useState<String?>(initialQuery.searchEngine);
    final order = useState<String?>(initialQuery.order);
    final orderDesc = useState<bool>(initialQuery.orderDesc);
    final periodStart = useState<int?>(initialQuery.periodStart);
    final periodEnd = useState<int?>(initialQuery.periodEnd);
    final type = useState<int?>(initialQuery.type);
    final showAdvancedFilters = useState<bool>(initialShowAdvancedFilters);
    final searchController = useTextEditingController(
      text: initialQuery.queryTerm,
    );

    void updateQuery() {
      final newQuery = initialQuery.copyWith(
        includeReplies: includeReplies.value,
        mediaOnly: mediaOnly.value,
        queryTerm: queryTerm.value,
        searchEngine: searchEngine.value,
        order: order.value,
        periodStart: periodStart.value,
        periodEnd: periodEnd.value,
        orderDesc: orderDesc.value,
        type: type.value,
      );
      onQueryChanged(newQuery);
    }

    Future<void> pickDate(ValueNotifier<int?> target) async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: target.value != null
            ? DateTime.fromMillisecondsSinceEpoch(target.value! * 1000)
            : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (pickedDate != null) {
        target.value = pickedDate.millisecondsSinceEpoch ~/ 1000;
        updateQuery();
      }
    }

    void resetAdvancedFilters() {
      queryTerm.value = null;
      searchController.clear();
      searchEngine.value = null;
      order.value = null;
      periodStart.value = null;
      periodEnd.value = null;
      updateQuery();
    }

    final activeAdvancedCount = [
      queryTerm.value?.isNotEmpty == true,
      searchEngine.value != null,
      order.value != null,
      periodStart.value != null,
      periodEnd.value != null,
    ].where((it) => it).length;

    useEffect(() {
      includeReplies.value = initialQuery.includeReplies;
      mediaOnly.value = initialQuery.mediaOnly ?? false;
      queryTerm.value = initialQuery.queryTerm;
      searchEngine.value = initialQuery.searchEngine;
      order.value = initialQuery.order;
      orderDesc.value = initialQuery.orderDesc;
      periodStart.value = initialQuery.periodStart;
      periodEnd.value = initialQuery.periodEnd;
      type.value = initialQuery.type;
      showAdvancedFilters.value = initialShowAdvancedFilters;
      if (searchController.text != (initialQuery.queryTerm ?? '')) {
        searchController.text = initialQuery.queryTerm ?? '';
      }
      return null;
    }, [initialQuery, initialShowAdvancedFilters]);

    useEffect(() {
      void onTabChanged() {
        final tabIndex = categoryTabController.index;
        type.value = switch (tabIndex) {
          1 => 0,
          2 => 1,
          _ => null,
        };
        updateQuery();
      }

      categoryTabController.addListener(onTabChanged);
      return () => categoryTabController.removeListener(onTabChanged);
    }, [categoryTabController]);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _TypeFilterChip(
                      value: type.value,
                      onSelected: (value) {
                        type.value = value;
                        final tabIndex = switch (value) {
                          0 => 1,
                          1 => 2,
                          _ => 0,
                        };
                        if (categoryTabController.index != tabIndex) {
                          categoryTabController.animateTo(tabIndex);
                        } else {
                          updateQuery();
                        }
                      },
                    ),
                    _FilterChipButton(
                      icon: Symbols.reply,
                      label: 'reply'.tr(),
                      stateIcon: switch (includeReplies.value) {
                        true => Symbols.check_circle,
                        false => Symbols.remove_circle,
                        null => Symbols.radio_button_unchecked,
                      },
                      emphasized: includeReplies.value != null,
                      onTap: () {
                        includeReplies.value = switch (includeReplies.value) {
                          false => true,
                          true => null,
                          null => false,
                        };
                        updateQuery();
                      },
                    ),
                    _FilterChipButton(
                      icon: Symbols.attachment,
                      label: 'attachments'.tr(),
                      stateIcon: mediaOnly.value
                          ? Symbols.check_circle
                          : Symbols.radio_button_unchecked,
                      emphasized: mediaOnly.value,
                      onTap: () {
                        mediaOnly.value = !mediaOnly.value;
                        updateQuery();
                      },
                    ),
                  ],
                ),
                const Gap(8),
                Material(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      showAdvancedFilters.value = !showAdvancedFilters.value;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Symbols.tune,
                              size: 18,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'advancedFilters'.tr(),
                                  style: theme.textTheme.labelLarge,
                                ),
                                Text(
                                  'searchPostsDescription'.tr(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (activeAdvancedCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                activeAdvancedCount.toString(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Gap(6),
                          ],
                          Icon(
                            showAdvancedFilters.value
                                ? Symbols.expand_less
                                : Symbols.expand_more,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!hideSearch) ...[
                            TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                labelText: 'search'.tr(),
                                hintText: 'searchPosts'.tr(),
                                prefixIcon: const Icon(Symbols.search),
                                suffixIcon:
                                    (queryTerm.value?.isNotEmpty ?? false)
                                    ? IconButton(
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        icon: const Icon(
                                          Symbols.close,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          searchController.clear();
                                          queryTerm.value = null;
                                          updateQuery();
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                queryTerm.value = value.isEmpty ? null : value;
                                updateQuery();
                              },
                            ),
                            const Gap(8),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  decoration: InputDecoration(
                                    labelText: 'searchEngine'.tr(),
                                    prefixIcon: const Icon(
                                      Symbols.travel_explore,
                                    ),
                                  ),
                                  initialValue: searchEngine.value,
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('searchEngineDefault'.tr()),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'semantic',
                                      child: Text('searchEngineSemantic'.tr()),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'fulltext',
                                      child: Text('searchEngineFulltext'.tr()),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    searchEngine.value = value;
                                    updateQuery();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String?>(
                                  decoration: InputDecoration(
                                    labelText: 'sortBy'.tr(),
                                    isDense: true,
                                  ),
                                  initialValue: order.value,
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: 'date',
                                      child: Text('date'.tr()),
                                    ),
                                    DropdownMenuItem<String?>(
                                      value: 'popularity',
                                      child: Text('popularity'.tr()),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    order.value = value;
                                    updateQuery();
                                  },
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: DropdownButtonFormField<bool>(
                                  decoration: InputDecoration(
                                    labelText: 'order'.tr(),
                                    isDense: true,
                                  ),
                                  initialValue: orderDesc.value,
                                  items: [
                                    const DropdownMenuItem<bool>(
                                      value: true,
                                      child: Text('Descending'),
                                    ),
                                    const DropdownMenuItem<bool>(
                                      value: false,
                                      child: Text('Ascending'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    orderDesc.value = value ?? true;
                                    updateQuery();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: _DateFieldButton(
                                  label: 'fromDate'.tr(),
                                  value: periodStart.value,
                                  onTap: () => pickDate(periodStart),
                                  onClear: periodStart.value == null
                                      ? null
                                      : () {
                                          periodStart.value = null;
                                          updateQuery();
                                        },
                                ),
                              ),
                              const Gap(8),
                              Expanded(
                                child: _DateFieldButton(
                                  label: 'toDate'.tr(),
                                  value: periodEnd.value,
                                  onTap: () => pickDate(periodEnd),
                                  onClear: periodEnd.value == null
                                      ? null
                                      : () {
                                          periodEnd.value = null;
                                          updateQuery();
                                        },
                                ),
                              ),
                            ],
                          ),
                          if (activeAdvancedCount > 0) ...[
                            const Gap(6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: resetAdvancedFilters,
                                icon: const Icon(Symbols.restart_alt),
                                label: Text('clear'.tr()),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  crossFadeState: showAdvancedFilters.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 180),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData stateIcon;
  final bool emphasized;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.stateIcon,
    required this.emphasized,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: emphasized
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: emphasized
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const Gap(6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: emphasized
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
              const Gap(6),
              Icon(
                stateIcon,
                size: 16,
                color: emphasized
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onSelected;

  const _TypeFilterChip({required this.value, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = switch (value) {
      0 => 'postTypePost'.tr(),
      1 => 'postArticle'.tr(),
      2 => 'postBlog'.tr(),
      _ => 'all'.tr(),
    };

    return PopupMenuButton<int?>(
      initialValue: value,
      tooltip: 'type'.tr(),
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem<int?>(value: null, child: Text('all'.tr())),
        PopupMenuItem<int?>(value: 0, child: Text('postTypePost'.tr())),
        PopupMenuItem<int?>(value: 1, child: Text('postArticle'.tr())),
        PopupMenuItem<int?>(value: 2, child: Text('postBlog'.tr())),
      ],
      child: Material(
        color: value != null
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.category,
                size: 16,
                color: value != null
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              const Gap(6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: value != null
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
              const Gap(6),
              Icon(
                Symbols.expand_more,
                size: 16,
                color: value != null
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateFieldButton extends StatelessWidget {
  final String label;
  final int? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateFieldButton({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final formattedDate = value != null
        ? DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.fromMillisecondsSinceEpoch(value! * 1000))
        : 'selectDate'.tr();

    return Material(
      color: colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      formattedDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: value != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Symbols.close, size: 18),
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  onPressed: onClear,
                )
              else
                Icon(
                  Symbols.calendar_today,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
