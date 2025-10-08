import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:island/models/embed.dart';
import 'package:island/models/poll.dart';
import 'package:island/services/responsive.dart';
import 'package:island/utils/mapping.dart';
import 'package:island/widgets/content/embed/link.dart';
import 'package:island/widgets/poll/poll_submit.dart';
import 'package:styled_widget/styled_widget.dart';

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
    return Column(
      children:
          embeds
              .map((embedData) => convertMapKeysToSnakeCase(embedData))
              .map(
                (embedData) => switch (embedData['type']) {
                  'link' => EmbedLinkWidget(
                    link: SnScrappedLink.fromJson(embedData),
                    maxWidth:
                        maxWidth ??
                        math.min(
                          MediaQuery.of(context).size.width,
                          kWideScreenWidth,
                        ),
                    margin: EdgeInsets.only(
                      top: 4,
                      bottom: 4,
                      left: renderingPadding.horizontal,
                      right: renderingPadding.horizontal,
                    ),
                  ),
                  'poll' => Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: renderingPadding.horizontal,
                      vertical: 8,
                    ),
                    child:
                        embedData['poll'] == null
                            ? const Text('Poll was not loaded...')
                            : PollSubmit(
                              initialAnswers:
                                  embedData['poll']?['user_answer']?['answer'],
                              stats: embedData['poll']?['stats'],
                              poll: SnPollWithStats.fromJson(embedData['poll']),
                              onSubmit: (_) {},
                              isReadonly: !isInteractive,
                              isInitiallyExpanded: isFullPost,
                            ).padding(horizontal: 16, vertical: 12),
                  ),
                  _ => Text('Unable show embed: ${embedData['type']}'),
                },
              )
              .toList(),
    );
  }
}
