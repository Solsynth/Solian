import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/poll.dart';
import 'package:island/models/publisher.dart';
import 'package:island/screens/creators/poll/poll_list.dart';
import 'package:island/screens/poll/poll_editor.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/widgets/post/publishers_modal.dart';

/// Bottom sheet for selecting or creating a poll. Returns SnPoll via Navigator.pop.
class ComposePollSheet extends HookConsumerWidget {
  final SnPublisher? pub;

  const ComposePollSheet({super.key, this.pub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPublisher = useState<SnPublisher?>(pub);
    final isPushing = useState(false);
    final errorText = useState<String?>(null);

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'poll'.tr(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              tabs: [
                Tab(text: 'pollsRecent'.tr()),
                Tab(text: 'pollCreateNew'.tr()),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Link/Select existing poll list
                  PagingHelperView(
                    provider: pollListNotifierProvider(pub?.name),
                    futureRefreshable:
                        pollListNotifierProvider(pub?.name).future,
                    notifierRefreshable:
                        pollListNotifierProvider(pub?.name).notifier,
                    contentBuilder:
                        (data, widgetCount, endItemView) => ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widgetCount,
                          itemBuilder: (context, index) {
                            if (index == widgetCount - 1) {
                              return endItemView;
                            }

                            final poll = data.items[index];

                            return ListTile(
                              leading: const Icon(Symbols.how_to_vote, fill: 1),
                              title: Text(poll.title ?? 'untitled'.tr()),
                              subtitle: _buildPollSubtitle(poll),
                              onTap: () {
                                Navigator.of(context).pop(poll);
                              },
                            );
                          },
                        ),
                  ),

                  // Create new poll and return it
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'pollCreateNewHint',
                        ).tr().fontSize(13).opacity(0.85).padding(bottom: 8),
                        Card(
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            title: Text(
                              selectedPublisher.value == null
                                  ? 'publisher'.tr()
                                  : selectedPublisher.value!.nick,
                            ),
                            subtitle: Text(
                              selectedPublisher.value == null
                                  ? 'publisherHint'.tr()
                                  : '@${selectedPublisher.value?.name}',
                            ),
                            leading:
                                selectedPublisher.value == null
                                    ? const Icon(Symbols.account_circle)
                                    : ProfilePictureWidget(
                                      file: selectedPublisher.value?.picture,
                                    ),
                            trailing: const Icon(Symbols.chevron_right),
                            onTap: () async {
                              final picked =
                                  await showModalBottomSheet<SnPublisher>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder:
                                        (context) => const PublisherModal(),
                                  );
                              if (picked != null) {
                                try {
                                  selectedPublisher.value = picked;
                                  errorText.value = null;
                                } catch (_) {
                                  // ignore
                                }
                              }
                            },
                          ),
                        ),
                        if (errorText.value != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 4,
                            ),
                            child: Text(
                              errorText.value!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                        const Gap(16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            icon:
                                isPushing.value
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Symbols.add_circle),
                            label: Text('create'.tr()),
                            onPressed:
                                isPushing.value
                                    ? null
                                    : () async {
                                      if (pub == null) {
                                        errorText.value =
                                            'publisherCannotBeEmpty'.tr();
                                        return;
                                      }
                                      errorText.value = null;

                                      isPushing.value = true;
                                      // Show modal bottom sheet with poll editor and await result
                                      final result =
                                          await showModalBottomSheet<SnPoll>(
                                            context: context,
                                            isScrollControlled: true,
                                            isDismissible: false,
                                            enableDrag: false,
                                            builder:
                                                (context) => PollEditorScreen(
                                                  initialPublisher: pub?.name,
                                                ),
                                          );

                                      if (result == null) {
                                        isPushing.value = false;
                                        return;
                                      }

                                      if (!context.mounted) return;

                                      // Return created poll to caller of this bottom sheet
                                      Navigator.of(context).pop(result);
                                    },
                          ),
                        ),
                      ],
                    ).padding(horizontal: 24, vertical: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildPollSubtitle(SnPollWithStats poll) {
    try {
      final List<SnPollQuestion> options = poll.questions;
      if (options.isEmpty) return null;
      final preview = options.take(3).map((e) => e.title).join(' · ');
      if (preview.trim().isEmpty) return null;
      return Text(preview);
    } catch (_) {
      return null;
    }
  }
}
