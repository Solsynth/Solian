import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/creators/publishers_form.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:styled_widget/styled_widget.dart';

class PublisherModal extends HookConsumerWidget {
  const PublisherModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);

    return SizedBox(
      height: math.min(MediaQuery.of(context).size.height * 0.4, 480),
      child: Column(
        children: [
          Expanded(
            child: publishers.when(
              data: (value) => value.isEmpty
                  ? ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 280),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'publishersEmpty',
                            textAlign: TextAlign.center,
                          ).tr().fontSize(17).bold(),
                          Text(
                            'publishersEmptyDescription',
                            textAlign: TextAlign.center,
                          ).tr(),
                          const Gap(12),
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    const NewPublisherScreen(),
                              ).then((value) {
                                if (value != null) {
                                  ref.invalidate(publishersManagedProvider);
                                }
                              });
                            },
                            child: Text('createPublisher').tr(),
                          ),
                        ],
                      ).center(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final publisher in value)
                            ListTile(
                              leading: ProfilePictureWidget(
                                file: publisher.picture,
                              ),
                              title: Text(publisher.nick),
                              subtitle: Text('@${publisher.name}'),
                              onTap: () {
                                Navigator.pop(context, publisher);
                              },
                            ),
                        ],
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
