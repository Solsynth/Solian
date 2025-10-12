import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';

part 'post_reaction_sheet.g.dart';

@riverpod
class ReactionListNotifier extends _$ReactionListNotifier
    with CursorPagingNotifierMixin<SnPostReaction> {
  static const int _pageSize = 20;

  int? totalCount;

  @override
  Future<CursorPagingData<SnPostReaction>> build({
    required String symbol,
    required String postId,
  }) {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnPostReaction>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    final response = await client.get(
      '/sphere/posts/$postId/reactions',
      queryParameters: {'symbol': symbol, 'offset': offset, 'take': _pageSize},
    );

    totalCount = int.tryParse(response.headers.value('x-total') ?? '0') ?? 0;

    final List<dynamic> data = response.data;
    final reactions =
        data.map((json) => SnPostReaction.fromJson(json)).toList();

    final hasMore = reactions.length == _pageSize;
    final nextCursor = hasMore ? (offset + reactions.length).toString() : null;

    return CursorPagingData(
      items: reactions,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}

const kAvailableStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
};

bool _getReactionImageAvailable(String symbol) {
  return kAvailableStickers.contains(symbol);
}

Widget _buildReactionIcon(String symbol, double size, {double iconSize = 24}) {
  if (_getReactionImageAvailable(symbol)) {
    return Image.asset(
      'assets/images/stickers/$symbol.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  } else {
    return Text(
      kReactionTemplates[symbol]?.icon ?? '',
      style: TextStyle(fontSize: iconSize),
    );
  }
}

class PostReactionSheet extends StatelessWidget {
  final Map<String, int> reactionsCount;
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude) onReact;
  final String postId;
  const PostReactionSheet({
    super.key,
    required this.reactionsCount,
    required this.reactionsMade,
    required this.onReact,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16,
            left: 20,
            right: 16,
            bottom: 12,
          ),
          child: Row(
            children: [
              Text(
                'reactions'.plural(
                  reactionsCount.isNotEmpty
                      ? reactionsCount.values.reduce((a, b) => a + b)
                      : 0,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Symbols.close),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              _buildReactionSection(
                context,
                Symbols.mood,
                'reactionPositive'.tr(),
                0,
              ),
              _buildReactionSection(
                context,
                Symbols.sentiment_neutral,
                'reactionNeutral'.tr(),
                1,
              ),
              _buildReactionSection(
                context,
                Symbols.mood_bad,
                'reactionNegative'.tr(),
                2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionSection(
    BuildContext context,
    IconData icon,
    String title,
    int attitude,
  ) {
    final allReactions =
        kReactionTemplates.entries
            .where((entry) => entry.value.attitude == attitude)
            .map((entry) => entry.key)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [Icon(icon), Text(title).fontSize(17).bold()],
        ).padding(horizontal: 24, top: 16, bottom: 6),
        SizedBox(
          height: 120,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 120,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              childAspectRatio: 1.0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allReactions.length,
            itemBuilder: (context, index) {
              final symbol = allReactions[index];
              final count = reactionsCount[symbol] ?? 0;
              final hasImage = _getReactionImageAvailable(symbol);
              return GestureDetector(
                onLongPressStart: (details) {
                  if (count > 0) {
                    showReactionDetailsPopup(
                      context,
                      symbol,
                      details.localPosition,
                      postId,
                      reactionsCount[symbol] ?? 0,
                    );
                  }
                },
                onSecondaryTapUp: (details) {
                  if (count > 0) {
                    showReactionDetailsPopup(
                      context,
                      symbol,
                      details.localPosition,
                      postId,
                      reactionsCount[symbol] ?? 0,
                    );
                  }
                },
                child: Badge(
                  label: Text('x$count'),
                  isLabelVisible: count > 0,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  offset: Offset(0, 0),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        onReact(symbol, attitude);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration:
                            hasImage
                                ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/stickers/$symbol.png',
                                    ),
                                    fit: BoxFit.cover,
                                    colorFilter:
                                        (reactionsMade[symbol] ?? false)
                                            ? ColorFilter.mode(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer
                                                  .withOpacity(0.7),
                                              BlendMode.srcATop,
                                            )
                                            : null,
                                  ),
                                )
                                : null,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasImage)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                    stops: [0.0, 0.3],
                                  ),
                                ),
                              ),
                            Column(
                              mainAxisAlignment:
                                  hasImage
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.center,
                              children: [
                                if (!hasImage) _buildReactionIcon(symbol, 36),
                                Text(
                                  ReactInfo.getTranslationKey(symbol),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: hasImage ? Colors.white : null,
                                    shadows:
                                        hasImage
                                            ? [
                                              const Shadow(
                                                blurRadius: 4,
                                                offset: Offset(0.5, 0.5),
                                                color: Colors.black,
                                              ),
                                            ]
                                            : null,
                                  ),
                                ).tr(),
                                if (hasImage) const Gap(4),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReactionDetailsPopup extends HookConsumerWidget {
  final String symbol;
  final String postId;
  final int totalCount;
  const ReactionDetailsPopup({
    super.key,
    required this.symbol,
    required this.postId,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = reactionListNotifierProvider(
      symbol: symbol,
      postId: postId,
    );

    final width = math.min(MediaQuery.of(context).size.width * 0.8, 480.0);
    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        width: width,
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildReactionIcon(symbol, 24),
                  const Gap(8),
                  Text(
                    ReactInfo.getTranslationKey(symbol),
                    style: Theme.of(context).textTheme.titleMedium,
                  ).tr(),
                  const Spacer(),
                  Text('reactions'.plural(totalCount)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PagingHelperView(
                provider: provider,
                futureRefreshable: provider.future,
                notifierRefreshable: provider.notifier,
                contentBuilder:
                    (data, widgetCount, endItemView) => ListView.builder(
                      itemCount: widgetCount,
                      itemBuilder: (context, index) {
                        if (index == widgetCount - 1) {
                          return endItemView;
                        }

                        final reaction = data.items[index];
                        return ListTile(
                          leading: AccountPfcGestureDetector(
                            uname: reaction.account?.name ?? 'unknown',
                            child: ProfilePictureWidget(
                              file: reaction.account?.profile.picture,
                            ),
                          ),
                          title: Text(reaction.account?.nick ?? 'unknown'.tr()),
                          subtitle: Text(
                            '${reaction.createdAt.formatRelative(context)} · ${reaction.createdAt.formatSystem()}',
                          ),
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showReactionDetailsPopup(
  BuildContext context,
  String symbol,
  Offset offset,
  String postId,
  int totalCount,
) async {
  await showPopupCard<void>(
    offset: offset,
    context: context,
    builder:
        (context) => ReactionDetailsPopup(
          symbol: symbol,
          postId: postId,
          totalCount: totalCount,
        ),
    alignment: Alignment.center,
    dimBackground: true,
  );
}
