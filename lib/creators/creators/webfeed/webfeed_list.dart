import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/creators/creators/webfeed/webfeed_edit.dart';
import 'package:island/discovery/webfeed.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class WebFeedListScreen extends ConsumerWidget {
  final String pubName;

  const WebFeedListScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedsAsync = ref.watch(webFeedListProvider(pubName));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: const Text('Web Feeds')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Symbols.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SheetScaffold(
              titleText: 'New Web Feed',
              child: WebfeedForm(pubName: pubName, feedId: null),
            ),
          );
        },
      ),
      body: feedsAsync.when(
        data: (feeds) {
          if (feeds.isEmpty) {
            return EmptyState(
              icon: Symbols.rss_feed,
              title: 'No Web Feeds',
              description: 'Add a new web feed to get started',
            );
          }
          return ExtendedRefreshIndicator(
            onRefresh: () => ref.refresh(webFeedListProvider(pubName).future),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8),
              itemCount: feeds.length,
              itemBuilder: (context, index) {
                final feed = feeds[index];
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 640),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(Symbols.rss_feed, size: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        feed.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        feed.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Symbols.chevron_right),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SheetScaffold(
                            titleText: 'Edit Web Feed',
                            child: WebfeedForm(
                              pubName: pubName,
                              feedId: feed.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ).center();
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
