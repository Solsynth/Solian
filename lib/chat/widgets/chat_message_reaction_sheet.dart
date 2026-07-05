import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_room_member_card.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/stickers/widgets/stickers/sticker_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatReactionListQuery {
  final String roomId;
  final String messageId;
  final String? symbol;

  const ChatReactionListQuery({
    required this.roomId,
    required this.messageId,
    this.symbol,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatReactionListQuery &&
            roomId == other.roomId &&
            messageId == other.messageId &&
            symbol == other.symbol;
  }

  @override
  int get hashCode => Object.hash(roomId, messageId, symbol);
}

final chatReactionListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family(ChatReactionListNotifier.new);

class ChatReactionListNotifier
    extends AsyncNotifier<PaginationState<SnChatReaction>>
    with AsyncPaginationController<SnChatReaction> {
  static const int pageSize = 20;

  final ChatReactionListQuery arg;
  ChatReactionListNotifier(this.arg);

  @override
  Future<List<SnChatReaction>> fetch() async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get(
      '/messager/chat/${arg.roomId}/messages/${arg.messageId}/reactions',
      queryParameters: {
        'symbol': arg.symbol,
        'offset': fetchedCount,
        'take': pageSize,
      },
    );

    totalCount = int.tryParse(response.headers.value('X-Total') ?? '0') ?? 0;

    final data = response.data as List<dynamic>;
    return data
        .map((json) => SnChatReaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

const kAvailableReactionStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
  'sorry',
  'laugh',
  'cry',
  'thumb_down',
};

bool getReactionImageAvailable(String symbol) {
  return kAvailableReactionStickers.contains(symbol);
}

Widget buildReactionIcon(String symbol, double size, {double iconSize = 24}) {
  if (symbol.contains('+')) {
    return const Icon(Symbols.sticky_note_2);
  }
  if (getReactionImageAvailable(symbol)) {
    return Image.asset(
      'assets/images/stickers/$symbol.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
  }
  return Text(
    kReactionTemplates[symbol]?.icon ?? '',
    style: TextStyle(fontSize: iconSize),
  );
}

class ChatMessageReactionSheet extends StatelessWidget {
  final Map<String, int> reactionsCount;
  final Map<String, bool> reactionsMade;
  final Function(String symbol, int attitude) onReact;
  final String roomId;
  final String messageId;
  final int initialTabIndex;

  const ChatMessageReactionSheet({
    super.key,
    required this.reactionsCount,
    required this.reactionsMade,
    required this.onReact,
    required this.roomId,
    required this.messageId,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialTabIndex,
      length: 3,
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
              tabs: [
                Tab(text: 'overview'.tr()),
                Tab(text: 'history'.tr()),
                Tab(text: 'custom'.tr()),
              ],
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
                  ChatReactionHistoryTab(
                    roomId: roomId,
                    messageId: messageId,
                    reactionsCount: reactionsCount,
                  ),
                  _CustomReactionForm(
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
    final customReactions = reactionsCount.entries
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
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: customReactions.length,
                itemBuilder: (context, index) {
                  final symbol = customReactions[index];
                  final count = reactionsCount[symbol] ?? 0;
                  final stickerUri =
                      '$baseUrl/sphere/stickers/lookup/$symbol/open';
                  return Badge(
                    label: Text('x$count'),
                    isLabelVisible: count > 0,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    offset: const Offset(0, 0),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        onTap: () {
                          onReact(symbol, 1);
                          Navigator.pop(context);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: double.infinity),
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: UniversalImage(
                                uri: stickerUri,
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
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
                            if (reactionsMade[symbol] == true)
                              Icon(
                                Symbols.check_small,
                                size: 12,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
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
    final allReactions = kReactionTemplates.entries
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
              final hasImage = getReactionImageAvailable(symbol);
              return GestureDetector(
                onTap: () {
                  onReact(symbol, attitude);
                  Navigator.pop(context);
                },
                child: Badge(
                  label: Text('x$count'),
                  isLabelVisible: count > 0,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      child: InkWell(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                        onTap: () {
                          onReact(symbol, attitude);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: hasImage
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/stickers/$symbol.webp',
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
                                      stops: const [0.0, 0.3],
                                    ),
                                  ),
                                ),
                              Column(
                                mainAxisAlignment: hasImage
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.center,
                                children: [
                                  if (!hasImage) buildReactionIcon(symbol, 36),
                                  Text(
                                    ReactInfo.getTranslationKey(symbol),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: hasImage ? Colors.white : null,
                                      shadows: hasImage
                                          ? const [
                                              Shadow(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChatReactionHistoryTab extends HookConsumerWidget {
  final String roomId;
  final String messageId;
  final Map<String, int> reactionsCount;

  const ChatReactionHistoryTab({
    super.key,
    required this.roomId,
    required this.messageId,
    required this.reactionsCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbols = reactionsCount.keys.toList()
      ..sort(
        (a, b) => (reactionsCount[b] ?? 0).compareTo(reactionsCount[a] ?? 0),
      );
    final selectedSymbol = useState<String?>('all');
    final provider = chatReactionListNotifierProvider(
      ChatReactionListQuery(
        roomId: roomId,
        messageId: messageId,
        symbol: selectedSymbol.value == 'all' ? null : selectedSymbol.value,
      ),
    );

    final skeletonItem = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: const ReactionHistoryListItemSkeleton(),
    );

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            spacing: 8,
            children: [
              _ReactionHistoryFilterChip(
                label: 'all'.tr(),
                selected: selectedSymbol.value == 'all',
                onTap: () => selectedSymbol.value = 'all',
              ),
              for (final symbol in symbols)
                _ReactionHistoryFilterChip(
                  label: 'x${reactionsCount[symbol] ?? 0}',
                  leading: buildReactionIcon(symbol, 20, iconSize: 14),
                  selected: selectedSymbol.value == symbol,
                  onTap: () => selectedSymbol.value = symbol,
                ),
            ],
          ),
        ),
        Expanded(
          child: PaginationList(
            provider: provider,
            notifier: provider.notifier,
            isRefreshable: false,
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            footerSkeletonChild: skeletonItem,
            itemBuilder: (context, index, reaction) {
              final showHeader =
                  index == 0 ||
                  ref
                          .watch(provider)
                          .value
                          ?.items
                          .elementAt(index - 1)
                          .symbol !=
                      reaction.symbol;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader && selectedSymbol.value == 'all')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Row(
                        children: [
                          buildReactionIcon(reaction.symbol, 20, iconSize: 14),
                          const Gap(8),
                          Text(
                            ReactInfo.getTranslationKey(reaction.symbol),
                            style: Theme.of(context).textTheme.titleSmall,
                          ).tr(),
                        ],
                      ),
                    ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 4,
                    ),
                    child: ChatReactionHistoryListItem(
                      roomId: roomId,
                      reaction: reaction,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChatReactionHistoryListItem extends StatelessWidget {
  final String roomId;
  final SnChatReaction reaction;

  const ChatReactionHistoryListItem({
    super.key,
    required this.roomId,
    required this.reaction,
  });

  @override
  Widget build(BuildContext context) {
    final sender = reaction.sender;
    final displayName = sender.nick?.isNotEmpty == true
        ? sender.nick!
        : sender.realmNick?.isNotEmpty == true
        ? sender.realmNick!
        : sender.account.nick;

    return ListTile(
      leading: ChatRoomMemberRegion(
        roomId: roomId,
        member: sender,
        child: ProfilePictureWidget(
          file: sender.account.profile.picture,
          radius: 20,
        ),
      ),
      title: Text(displayName),
      subtitle: Text(
        '${reaction.createdAt.formatRelative(context)} · ${reaction.createdAt.formatSystem()}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          Text(ReactInfo.getTranslationKey(reaction.symbol)).tr(),
          buildReactionIcon(reaction.symbol, 28, iconSize: 16),
        ],
      ),
    );
  }
}

class _ReactionHistoryFilterChip extends StatelessWidget {
  final String label;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;

  const _ReactionHistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: leading,
      label: Text(label),
      showCheckmark: false,
    );
  }
}

class ReactionHistoryListItemSkeleton extends StatelessWidget {
  const ReactionHistoryListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 120,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomReactionForm extends HookConsumerWidget {
  final Function(String symbol, int attitude) onReact;

  const _CustomReactionForm({required this.onReact});

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
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'stickerPlaceholder'.tr(),
              hintText: 'prefix+slug',

              suffixIcon: InkWell(
                onTapDown: (details) async {
                  final screenSize = MediaQuery.sizeOf(context);
                  const popoverWidth = 500.0;
                  const popoverHeight = 500.0;
                  const padding = 20.0;

                  final maxHorizontalOffset = math.max(
                    padding,
                    screenSize.width - popoverWidth - padding,
                  );
                  final horizontalOffset =
                      ((screenSize.width - popoverWidth) / 2).clamp(
                        padding,
                        maxHorizontalOffset,
                      );

                  final maxVerticalOffset = math.max(
                    padding,
                    screenSize.height - popoverHeight - padding,
                  );
                  final verticalOffset =
                      (screenSize.height - popoverHeight - padding).clamp(
                        padding,
                        maxVerticalOffset,
                      );

                  await showStickerPickerPopover(
                    context,
                    Offset(horizontalOffset, verticalOffset),
                    alignment: Alignment.topLeft,
                    onPick: (pack, sticker) {
                      symbol.value = '${pack.prefix}+${sticker.slug}';
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
