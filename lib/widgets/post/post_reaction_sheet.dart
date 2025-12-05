import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:gap/gap.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/pods/paging.dart';
import 'package:island/services/time.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/paging/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/widgets/stickers/sticker_picker.dart';
import 'package:island/pods/config.dart';

class ReactionListParams {
  final String symbol;
  final String postId;

  const ReactionListParams({required this.symbol, required this.postId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionListParams &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol &&
          postId == other.postId;

  @override
  int get hashCode => symbol.hashCode ^ postId.hashCode;
}

final reactionListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<ReactionListNotifier, List<SnPostReaction>, ReactionListParams>(
      ReactionListNotifier.new,
    );

class ReactionListNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<List<SnPostReaction>, ReactionListParams>
    with FamilyAsyncPaginationController<SnPostReaction, ReactionListParams> {
  static const int _pageSize = 20;

  @override
  Future<List<SnPostReaction>> fetch() async {
    final client = ref.read(apiClientProvider);

    final response = await client.get(
      '/sphere/posts/${arg.postId}/reactions',
      queryParameters: {
        'symbol': arg.symbol,
        'offset': fetchedCount,
        'take': _pageSize,
      },
    );

    totalCount = int.tryParse(response.headers.value('x-total') ?? '0') ?? 0;

    final List<dynamic> data = response.data;
    return data.map((json) => SnPostReaction.fromJson(json)).toList();
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
    return DefaultTabController(
      length: 2,
      child: SheetScaffold(
        heightFactor: 0.75,
        titleText: 'reactions'.plural(
          reactionsCount.isNotEmpty
              ? reactionsCount.values.reduce((a, b) => a + b)
              : 0,
        ),
        child: Column(
          children: [
            TabBar(
              tabs: [Tab(text: 'overview'.tr()), Tab(text: 'custom'.tr())],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    children: [
                      _buildCustomReactionSection(context),
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
                      const Gap(8),
                    ],
                  ),
                  CustomReactionForm(
                    postId: postId,
                    onReact: (s, a) => onReact(s.replaceAll(':', ''), a),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReactionSection(BuildContext context) {
    final customReactions =
        reactionsCount.entries
            .where((entry) => entry.key.contains('+'))
            .map((entry) => entry.key)
            .toList();

    if (customReactions.isEmpty) return const SizedBox.shrink();

    return HookConsumer(
      builder: (context, ref, child) {
        final baseUrl = ref.watch(serverUrlProvider);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                const Icon(Symbols.emoji_symbols),
                Text('customReactions'.tr()).fontSize(17).bold(),
              ],
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
                itemCount: customReactions.length,
                itemBuilder: (context, index) {
                  final symbol = customReactions[index];
                  final count = reactionsCount[symbol] ?? 0;
                  final stickerUri =
                      '$baseUrl/sphere/stickers/lookup/$symbol/open';

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
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLowest,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(8),
                          ),
                          onTap: () {
                            onReact(
                              symbol,
                              1,
                            ); // Custom reactions use neutral attitude
                            Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: double.infinity),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(stickerUri),
                                    fit: BoxFit.contain,
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
                                ),
                              ),
                              const Gap(8),
                              Text(
                                symbol,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      offset: Offset(0.5, 0.5),
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
      },
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
    final params = ReactionListParams(symbol: symbol, postId: postId);
    final provider = reactionListNotifierProvider(params);

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
              child: PaginationList(
                provider: provider,
                notifier: provider.notifier,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index, reaction) {
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
          ],
        ),
      ),
    );
  }
}

class CustomReactionForm extends HookConsumerWidget {
  final String postId;
  final Function(String symbol, int attitude) onReact;

  const CustomReactionForm({
    super.key,
    required this.postId,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attitude = useState<int>(1);
    final symbol = useState<String>('');

    Future<void> submitCustomReaction() async {
      if (symbol.value.isEmpty) return;
      onReact(symbol.value, attitude.value);
      Navigator.pop(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.info,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(8),
                    Text(
                      'customReaction'.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'customReactionHint'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'stickerPlaceholder'.tr(),
              hintText: 'prefix+slug',
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              suffixIcon: InkWell(
                onTapDown: (details) async {
                  final screenSize = MediaQuery.sizeOf(context);
                  const popoverWidth = 500.0;
                  const popoverHeight = 500.0;
                  const padding = 20.0;

                  // Calculate safe horizontal position (centered, but within bounds)
                  final maxHorizontalOffset = math.max(
                    padding,
                    screenSize.width - popoverWidth - padding,
                  );
                  final horizontalOffset = ((screenSize.width - popoverWidth) /
                          2)
                      .clamp(padding, maxHorizontalOffset);

                  // Calculate safe vertical position (bottom-aligned, but within bounds)
                  final maxVerticalOffset = math.max(
                    padding,
                    screenSize.height - popoverHeight - padding,
                  );
                  final verticalOffset = (screenSize.height -
                          popoverHeight -
                          padding)
                      .clamp(padding, maxVerticalOffset);

                  await showStickerPickerPopover(
                    context,
                    Offset(horizontalOffset, verticalOffset),
                    alignment: Alignment.topLeft,
                    onPick: (placeholder) {
                      // Remove the surrounding : from the placeholder
                      symbol.value = placeholder.substring(
                        1,
                        placeholder.length - 1,
                      );
                    },
                  );
                },
                child: const Icon(Symbols.sticky_note_2),
              ),
            ),
            controller: TextEditingController(text: symbol.value),
            onChanged: (value) => symbol.value = value,
          ),
          const Gap(24),
          Text(
            'reactionAttitude'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          SegmentedButton(
            segments: [
              ButtonSegment(
                value: 0,
                icon: const Icon(Symbols.sentiment_satisfied),
                label: Text('attitudePositive'.tr()),
              ),
              ButtonSegment(
                value: 1,
                icon: const Icon(Symbols.sentiment_stressed),
                label: Text('attitudeNeutral'.tr()),
              ),
              ButtonSegment(
                value: 2,
                icon: const Icon(Symbols.sentiment_sad),
                label: Text('attitudeNegative'.tr()),
              ),
            ],
            selected: {attitude.value},
            onSelectionChanged: (Set<int> newSelection) {
              attitude.value = newSelection.first;
            },
          ),
          const Gap(32),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: symbol.value.isEmpty ? null : submitCustomReaction,
              icon: const Icon(Symbols.send),
              label: Text('addReaction'.tr()),
            ),
          ),
          Gap(MediaQuery.of(context).padding.bottom + 24),
        ],
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
