import 'package:flutter/material.dart';
import 'package:island/models/embed.dart';
import 'package:island/utils/mapping.dart';
import 'package:island/widgets/content/embed/link.dart';
import 'package:island/widgets/poll/poll_submit.dart';
import 'package:island/widgets/wallet/fund_envelope.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class EmbedListWidget extends StatelessWidget {
  final List<dynamic> embeds;
  final bool isInteractive;
  final bool isFullPost;
  final EdgeInsets renderingPadding;
  final double? maxWidth;

  const EmbedListWidget({
    super.key,
    required this.embeds,
    this.isInteractive = true,
    this.isFullPost = false,
    this.renderingPadding = EdgeInsets.zero,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedEmbeds =
        embeds
            .map((e) => convertMapKeysToSnakeCase(e as Map<String, dynamic>))
            .toList();
    final linkEmbeds =
        normalizedEmbeds.where((e) => e['type'] == 'link').toList();
    final otherEmbeds =
        normalizedEmbeds.where((e) => e['type'] != 'link').toList();

    return Column(
      children: [
        if (linkEmbeds.isNotEmpty)
          Container(
            margin: EdgeInsets.only(
              top: 8,
              left: renderingPadding.horizontal,
              right: renderingPadding.horizontal,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                dense: true,
                leading: const Icon(Symbols.link),
                title: Text('${linkEmbeds.length} links'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child:
                        linkEmbeds.length == 1
                            ? EmbedLinkWidget(
                              link: SnScrappedLink.fromJson(linkEmbeds.first),
                            )
                            : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    linkEmbeds
                                        .map(
                                          (embedData) => EmbedLinkWidget(
                                            link: SnScrappedLink.fromJson(
                                              embedData,
                                            ),
                                            maxWidth:
                                                200, // Fixed width for horizontal scroll
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ...otherEmbeds.map(
          (embedData) => switch (embedData['type']) {
            'poll' => Card(
              margin: EdgeInsets.symmetric(
                horizontal: renderingPadding.horizontal,
                vertical: 8,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child:
                    embedData['id'] == null
                        ? const Text('Poll was unavailable...')
                        : PollSubmit(
                          pollId: embedData['id'],
                          onSubmit: (_) {},
                          isReadonly: !isInteractive,
                          isInitiallyExpanded: isFullPost,
                        ),
              ),
            ),
            'fund' =>
              embedData['id'] == null
                  ? const Text('Fund envelope was unavailable...')
                  : FundEnvelopeWidget(
                    fundId: embedData['id'],
                    margin: EdgeInsets.symmetric(
                      horizontal: renderingPadding.horizontal,
                      vertical: 8,
                    ),
                  ),
            _ => Text('Unable show embed: ${embedData['type']}'),
          },
        ),
      ],
    );
  }
}
