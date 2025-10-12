import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/post.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

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
  const PostReactionSheet({
    required this.reactionsCount,
    required this.reactionsMade,
    required this.onReact,
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
              return Badge(
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
              );
            },
          ),
        ),
      ],
    );
  }
}
