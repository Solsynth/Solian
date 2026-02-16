import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/stickers/widgets/stickers/sticker_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const kAvailableReactionStickers = {
  'angry',
  'clap',
  'confuse',
  'pray',
  'thumb_up',
  'party',
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
      'assets/images/stickers/$symbol.png',
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

  const ChatMessageReactionSheet({
    super.key,
    required this.reactionsCount,
    required this.reactionsMade,
    required this.onReact,
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
              tabs: [
                Tab(text: 'overview'.tr()),
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
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                      color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                                      'assets/images/stickers/$symbol.png',
                                    ),
                                    fit: BoxFit.cover,
                                    colorFilter: (reactionsMade[symbol] ?? false)
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
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
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
                    onPick: (placeholder) {
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
