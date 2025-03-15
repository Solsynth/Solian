import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/news.dart';
import 'package:surface/types/post.dart';

class NewsFeedEntry extends StatelessWidget {
  final SnFeedEntry data;
  const NewsFeedEntry({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List<SnNewsArticle> news = data.data
        .map((ele) => SnNewsArticle.fromJson(ele))
        .cast<SnNewsArticle>()
        .toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.newspaper),
              const Gap(8),
              Text(
                'newsToday',
                style: Theme.of(context).textTheme.titleLarge,
              ).tr()
            ],
          ).padding(horizontal: 18, top: 12, bottom: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: news.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, idx) {
                return Container(
                  width: 360,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Material(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news[idx].title,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.titleMedium,
                          ).padding(horizontal: 16, top: 12, bottom: 4),
                          Text(
                            news[idx].description,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ).padding(horizontal: 16, vertical: 4),
                          const Gap(4),
                          Row(
                            children: [
                              Text(
                                DateFormat('y/M/d HH:mm')
                                    .format(news[idx].createdAt.toLocal()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Gap(4),
                              Text(
                                RelativeTime(context)
                                    .format(news[idx].createdAt.toLocal()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ).opacity(0.8).padding(horizontal: 16),
                        ],
                      ),
                      onTap: () {
                        GoRouter.of(context).pushNamed(
                          'newsDetail',
                          pathParameters: {'hash': news[idx].hash},
                        );
                      },
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const Gap(12),
            ),
          ),
        ],
      ),
    );
  }
}
