import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/pods/post/post_list.dart';
import 'package:material_symbols_icons/symbols.dart';

class PostFilterWidget extends StatefulWidget {
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
  State<PostFilterWidget> createState() => _PostFilterWidgetState();
}

class _PostFilterWidgetState extends State<PostFilterWidget> {
  late bool? _includeReplies;
  late bool _mediaOnly;
  late String? _queryTerm;
  late String? _order;
  late bool _orderDesc;
  late int? _periodStart;
  late int? _periodEnd;
  late int? _type;
  late bool _showAdvancedFilters;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _includeReplies = widget.initialQuery.includeReplies;
    _mediaOnly = widget.initialQuery.mediaOnly ?? false;
    _queryTerm = widget.initialQuery.queryTerm;
    _order = widget.initialQuery.order;
    _orderDesc = widget.initialQuery.orderDesc;
    _periodStart = widget.initialQuery.periodStart;
    _periodEnd = widget.initialQuery.periodEnd;
    _type = widget.initialQuery.type;
    _showAdvancedFilters = false;
    _searchController = TextEditingController(text: _queryTerm);

    widget.categoryTabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.categoryTabController.removeListener(_onTabChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    final tabIndex = widget.categoryTabController.index;
    setState(() {
      _type = switch (tabIndex) {
        1 => 0,
        2 => 1,
        _ => null,
      };
    });
    _updateQuery();
  }

  void _updateQuery() {
    final newQuery = widget.initialQuery.copyWith(
      includeReplies: _includeReplies,
      mediaOnly: _mediaOnly,
      queryTerm: _queryTerm,
      order: _order,
      periodStart: _periodStart,
      periodEnd: _periodEnd,
      orderDesc: _orderDesc,
      type: _type,
    );
    widget.onQueryChanged(newQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          TabBar(
            controller: widget.categoryTabController,
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
                      value: _includeReplies,
                      tristate: true,
                      onChanged: (value) {
                        // Cycle through: null -> false -> true -> null
                        setState(() {
                          if (_includeReplies == null) {
                            _includeReplies = false;
                          } else if (_includeReplies == false) {
                            _includeReplies = true;
                          } else {
                            _includeReplies = null;
                          }
                        });
                        _updateQuery();
                      },
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: const Icon(Symbols.reply),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: Text('attachments'.tr()),
                      value: _mediaOnly,
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            _mediaOnly = value;
                          }
                        });
                        _updateQuery();
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
                value: _orderDesc,
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      _orderDesc = value;
                    }
                  });
                  _updateQuery();
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
              _showAdvancedFilters ? Symbols.expand_less : Symbols.expand_more,
            ),
            onTap: () {
              setState(() {
                _showAdvancedFilters = !_showAdvancedFilters;
              });
            },
          ),
          if (_showAdvancedFilters) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.hideSearch)
                    TextField(
                      controller: _searchController,
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
                        setState(() {
                          _queryTerm = value.isEmpty ? null : value;
                        });
                        _updateQuery();
                      },
                    ),
                  if (!widget.hideSearch) const Gap(12),
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
                    value: _order,
                    items: [
                      DropdownMenuItem(value: 'date', child: Text('date'.tr())),
                      DropdownMenuItem(
                        value: 'popularity',
                        child: Text('popularity'.tr()),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _order = value;
                      });
                      _updateQuery();
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
                              initialDate: _periodStart != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      _periodStart! * 1000,
                                    )
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _periodStart =
                                    pickedDate.millisecondsSinceEpoch ~/ 1000;
                              });
                              _updateQuery();
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
                              _periodStart != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      _periodStart! * 1000,
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
                              initialDate: _periodEnd != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      _periodEnd! * 1000,
                                    )
                                  : DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _periodEnd =
                                    pickedDate.millisecondsSinceEpoch ~/ 1000;
                              });
                              _updateQuery();
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
                              _periodEnd != null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                      _periodEnd! * 1000,
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
