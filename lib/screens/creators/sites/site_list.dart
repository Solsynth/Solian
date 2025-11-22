import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/creators/sites/site_edit.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/widgets/extended_refresh_indicator.dart';
import 'package:styled_widget/styled_widget.dart';

part 'site_list.g.dart';

@riverpod
class SiteListNotifier extends _$SiteListNotifier
    with CursorPagingNotifierMixin<SnPublicationSite> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnPublicationSite>> build(String? pubName) {
    // immediately load first page
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPublicationSite>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    // read the current family argument passed to provider
    final queryParams = {'offset': offset, 'take': _pageSize};

    final response = await client.get(
      '/zone/sites/$pubName',
      queryParameters: queryParams,
    );
    final total = int.parse(response.headers.value('X-Total') ?? '0');
    final List<dynamic> data = response.data;
    final items = data.map((json) => SnPublicationSite.fromJson(json)).toList();

    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

class CreatorSiteListScreen extends HookConsumerWidget {
  const CreatorSiteListScreen({super.key, required this.pubName});

  final String pubName;

  Future<void> _createSite(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SiteForm(pubName: pubName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text('publicationSites'.tr())),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createSite(context),
        child: Icon(Icons.add),
      ),
      body: ExtendedRefreshIndicator(
        onRefresh: () => ref.refresh(siteListNotifierProvider(pubName).future),
        child: CustomScrollView(
          slivers: [
            const SliverGap(8),
            PagingHelperSliverView(
              provider: siteListNotifierProvider(pubName),
              futureRefreshable: siteListNotifierProvider(pubName).future,
              notifierRefreshable: siteListNotifierProvider(pubName).notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => SliverList.builder(
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }
                      final site = data.items[index];
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 640),
                        child: _CreatorSiteItem(site: site, pubName: pubName),
                      ).center();
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorSiteItem extends HookConsumerWidget {
  final String pubName;
  const _CreatorSiteItem({required this.site, required this.pubName});

  final SnPublicationSite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to site detail screen
          context.pushNamed(
            'creatorSiteDetail',
            pathParameters: {'name': pubName, 'siteSlug': site.slug},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  spacing: 2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.globe,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Gap(6),
                        Text(site.name).bold(),
                      ],
                    ),
                    if (site.description != null &&
                        site.description!.isNotEmpty)
                      Text(
                        site.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Divider(height: 8),
                    Text(
                      '${site.slug}.solian.page',
                      style: GoogleFonts.robotoMono(fontSize: 11),
                    ).opacity(0.8),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Symbols.edit),
                            const Gap(16),
                            Text('edit').tr(),
                          ],
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder:
                                (context) => SiteForm(
                                  pubName: pubName,
                                  siteSlug: site.slug,
                                ),
                          );
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Symbols.delete, color: Colors.red),
                            const Gap(16),
                            Text('delete').tr().textColor(Colors.red),
                          ],
                        ),
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('deleteSite'.tr()),
                                  content: Text('deleteSiteConfirm'.tr()),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: Text('cancel'.tr()),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: Text('delete'.tr()),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmed == true) {
                            try {
                              final client = ref.read(apiClientProvider);
                              await client.delete('/zone/sites/${site.id}');
                              ref.invalidate(siteListNotifierProvider(pubName));
                              showSnackBar('siteDeletedSuccess'.tr());
                            } catch (e) {
                              showErrorAlert(e);
                            }
                          }
                        },
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
