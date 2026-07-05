import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/discovery/widgets/discovery_feedback_widget.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/screens/publisher_profile.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class PublisherDiscoveryCard extends ConsumerWidget {
  final SnPublisher publisher;
  final double? maxWidth;
  final bool showFeedback;

  const PublisherDiscoveryCard({
    super.key,
    required this.publisher,
    this.maxWidth,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageWidget;
    if (publisher.picture != null) {
      imageWidget = CloudImageWidget(
        file: publisher.background,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = ColoredBox(
        color: Theme.of(context).colorScheme.secondaryContainer,
      );
    }

    Widget card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: () {
          showPublisherProfileAttentionModal(publisher.name);
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageWidget,
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ProfilePictureWidget(
                          file: publisher.picture,
                          radius: 12,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        publisher.nick,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (showFeedback)
                Positioned(
                  top: 8,
                  right: 8,
                  child: DiscoveryFeedbackWidget(
                    kind: 'publisher',
                    referenceId: publisher.id,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: card,
    );
  }
}
