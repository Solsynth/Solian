import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/poll/poll_list.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/polls/polls_widgets/poll/poll_submit.dart';
import 'package:island/route.gr.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

@RoutePage()
class PollSubmitPage extends ConsumerWidget {
  final String pollId;
  final bool isReadonly;
  final bool isInitiallyExpanded;

  const PollSubmitPage({
    super.key,
    @PathParam("id") required this.pollId,
    this.isReadonly = false,
    this.isInitiallyExpanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollAsync = ref.watch(pollWithStatsProvider(pollId));

    return Scaffold(
      appBar: AppBar(
        title: pollAsync.whenOrNull(
          data: (poll) => poll.title != null ? Text(poll.title!) : null,
        ),
        actions: [
          if (pollAsync case AsyncData(:final value) when value.publisher != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _PublisherChip(publisher: value.publisher!),
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 540,
            child: PollSubmit(
              pollId: pollId,
              disableCollapse: true,
              onSubmit: (_) {
                context.maybePop();
              },
              isReadonly: isReadonly,
              isInitiallyExpanded: isInitiallyExpanded,
            ),
          ),
        ),
      ),
    );
  }
}

class _PublisherChip extends StatelessWidget {
  final SnPublisher publisher;

  const _PublisherChip({required this.publisher});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: publisher.picture != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CloudImageWidget(
                  file: publisher.picture!,
                  fit: BoxFit.cover,
                  noBlurhash: true,
                ),
              ),
            )
          : Icon(
              Icons.account_circle,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      label: Text(
        publisher.nick,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      onPressed: () {
        context.router.push(PublisherProfileRoute(name: publisher.name));
      },
    );
  }
}
