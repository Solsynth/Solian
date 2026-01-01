import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/publication_site.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/screens/creators/sites/site_edit.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

final siteListNotifierProvider = AsyncNotifierProvider.family.autoDispose(
  SiteListNotifier.new,
);

class SiteListNotifier extends AsyncNotifier<PaginationState<SnPublicationSite>>
    with AsyncPaginationController<SnPublicationSite> {
  static const int pageSize = 20;

  final String arg;
  SiteListNotifier(this.arg);

  @override
  Future<List<SnPublicationSite>> fetch() async {
    final client = ref.read(apiClientProvider);

    // read the current family argument passed to provider
    final queryParams = {'offset': fetchedCount.toString(), 'take': pageSize};

    final response = await client.get(
      '/zone/sites/$arg',
      queryParameters: queryParams,
    );
    totalCount = int.parse(response.headers.value('X-Total') ?? '0');
    final items = response.data
        .map((json) => SnPublicationSite.fromJson(json))
        .cast<SnPublicationSite>()
        .toList();

    return items;
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
      body: PaginationList(
        footerSkeletonMaxWidth: 640,
        provider: siteListNotifierProvider(pubName),
        notifier: siteListNotifierProvider(pubName).notifier,
        padding: const EdgeInsets.only(top: 12),
        itemBuilder: (context, index, site) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640),
            child: _CreatorSiteItem(site: site, pubName: pubName),
          ).center();
        },
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
                itemBuilder: (context) => [
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
                        builder: (context) =>
                            SiteForm(pubName: pubName, siteSlug: site.slug),
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
                      final confirmed = await showConfirmAlert(
                        'publicationSiteDeleteConfirm'.tr(),
                        'deleteSite'.tr(),
                        isDanger: true,
                      );
                      if (confirmed == true) {
                        try {
                          final client = ref.read(apiClientProvider);
                          await client.delete(
                            '/zone/sites/$pubName/${site.slug}',
                          );
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
