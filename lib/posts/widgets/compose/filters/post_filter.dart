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
    final includeReplies = useState<bool?>(initialQuery.includeReplies);
    final mediaOnly = useState<bool>(initialQuery.mediaOnly ?? false);
    final queryTerm = useState<String?>(initialQuery.queryTerm);
    final searchEngine = useState<String?>(initialQuery.searchEngine);
    final order = useState<String?>(initialQuery.order);
    final orderDesc = useState<bool>(initialQuery.orderDesc);
    final periodStart = useState<int?>(initialQuery.periodStart);
    final periodEnd = useState<int?>(initialQuery.periodEnd);
    final type = useState<int?>(initialQuery.type);
    final showAdvancedFilters = useState<bool>(false);
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
      child: Column(
        children: [
          TabBar(
            controller: categoryTabController,
            dividerColor: Colors.transparent,
            splashBorderRadius: const BorderRadius.all(Radius.circular(8)),
            tabs: [
              Tab(text: 'all'.tr()),
              Tab(text: 'postTypePost'.tr()),
              Tab(text: 'postArticle'.tr()),
            ],
          ),
          const Divider(height: 1),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('reply'.tr()),
                      value: includeReplies.value,
                      tristate: true,
                      onChanged: (value) {
                        final current = includeReplies.value;
                        if (current == null) {
                          includeReplies.value = false;
                        } else if (current == false) {
                          includeReplies.value = true;
                        } else {
                          includeReplies.value = null;
                        }
                        updateQuery();
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: const Icon(Symbols.reply),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('attachments'.tr()),
                      value: mediaOnly.value,
                      onChanged: (value) {
                        if (value != null) {
                          mediaOnly.value = value;
                        }
                        updateQuery();
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: const Icon(Symbols.attachment),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                title: Text('descendingOrder'.tr()),
                value: orderDesc.value,
                onChanged: (value) {
                  if (value != null) {
                    orderDesc.value = value;
                  }
                  updateQuery();
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                secondary: const Icon(Symbols.sort),
              ),
            ],
          ),
          const Divider(height: 1),
          ListTile(
            title: Text('advancedFilters'.tr()),
            leading: const Icon(Symbols.filter_list),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(const Radius.circular(8)),
            ),
            trailing: Icon(
              showAdvancedFilters.value
                  ? Symbols.expand_less
                  : Symbols.expand_more,
            ),
            onTap: () {
              showAdvancedFilters.value = !showAdvancedFilters.value;
            },
          ),
          if (showAdvancedFilters.value) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!hideSearch)
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'search'.tr(),
                        hintText: 'searchPosts'.tr(),
                        prefixIcon: const Icon(Symbols.search),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        queryTerm.value = value.isEmpty ? null : value;
                        updateQuery();
                      },
                    ),
                  if (!hideSearch) const Gap(12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'searchEngine'.tr(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: searchEngine.value,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('searchEngineDefault'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'semantic',
                        child: Text('searchEngineSemantic'.tr()),
                      ),
                      DropdownMenuItem(
                        value: 'fulltext',
                        child: Text('searchEngineFulltext'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      searchEngine.value = value;
                      updateQuery();
                    },
                  ),
                  const Gap(12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'sortBy'.tr(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    value: order.value,
                    items: [
                      DropdownMenuItem(value: 'date', child: Text('date'.tr())),
                      DropdownMenuItem(
                        value: 'popularity',
                        child: Text('popularity'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      order.value = value;
                      updateQuery();
                    },
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: periodStart.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      periodStart.value! * 1000,
                                    )
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              periodStart.value =
                                  pickedDate.millisecondsSinceEpoch ~/ 1000;
                              updateQuery();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'fromDate'.tr(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: const Icon(Symbols.calendar_today),
                            ),
                            child: Text(
                              periodStart.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      periodStart.value! * 1000,
                                    ).toString().split(' ')[0]
                                  : 'selectDate'.tr(),
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: periodEnd.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      periodEnd.value! * 1000,
                                    )
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              periodEnd.value =
                                  pickedDate.millisecondsSinceEpoch ~/ 1000;
                              updateQuery();
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'toDate'.tr(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              suffixIcon: const Icon(Symbols.calendar_today),
                            ),
                            child: Text(
                              periodEnd.value != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      periodEnd.value! * 1000,
                                    ).toString().split(' ')[0]
                                  : 'selectDate'.tr(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
