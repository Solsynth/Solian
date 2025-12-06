import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostFilterWidget extends StatelessWidget {
  final TabController categoryTabController;
  final ValueNotifier<bool?> includeReplies;
  final ValueNotifier<bool> mediaOnly;
  final ValueNotifier<String?> queryTerm;
  final ValueNotifier<String?> order;
  final ValueNotifier<bool> orderDesc;
  final ValueNotifier<int?> periodStart;
  final ValueNotifier<int?> periodEnd;
  final ValueNotifier<bool> showAdvancedFilters;
  final bool hideSearch;

  const PostFilterWidget({
    super.key,
    required this.categoryTabController,
    required this.includeReplies,
    required this.mediaOnly,
    required this.queryTerm,
    required this.order,
    required this.orderDesc,
    required this.periodStart,
    required this.periodEnd,
    required this.showAdvancedFilters,
    this.hideSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        // Cycle through: null -> false -> true -> null
                        if (includeReplies.value == null) {
                          includeReplies.value = false;
                        } else if (includeReplies.value == false) {
                          includeReplies.value = true;
                        } else {
                          includeReplies.value = null;
                        }
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
                      decoration: InputDecoration(
                        labelText: 'search'.tr(),
                        hintText: 'searchPosts'.tr(),
                        prefixIcon: const Icon(Symbols.search),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (value) {
                        queryTerm.value = value.isEmpty ? null : value;
                      },
                    ),
                  if (!hideSearch) const Gap(12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'sortBy'.tr(),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
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
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'fromDate'.tr(),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
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
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'toDate'.tr(),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                              ),
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
