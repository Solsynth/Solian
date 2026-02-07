import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/posts_models/post.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class PostPinSheet extends HookConsumerWidget {
  final SnPost post;
  const PostPinSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = useState(0);

    Future<void> pinPost() async {
      try {
        showLoadingModal(context);
        final client = ref.watch(apiClientProvider);
        await client.post(
          '/sphere/posts/${post.id}/pin',
          data: {'mode': mode.value},
        );

        if (context.mounted) Navigator.of(context).pop(mode.value);
      } catch (e) {
        showErrorAlert(e);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    return SheetScaffold(
      titleText: 'pinPost'.tr(),
      heightFactor: 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Publisher page pin option (always available)
          ListTile(
            leading: Radio<int>(
              value: 0,
              groupValue: mode.value,
              onChanged: (value) {
                mode.value = value!;
              },
            ),
            title: Text('publisherPage'.tr()),
            subtitle: Text('pinPostPublisherHint'.tr()),
            onTap: () {
              mode.value = 0;
            },
          ),

          // Realm page pin option (show always, but disabled when not available)
          ListTile(
            leading: Radio<int>(
              value: 1,
              groupValue: mode.value,
              onChanged: post.realmId != null && post.realmId!.isNotEmpty
                  ? (value) {
                      mode.value = value!;
                    }
                  : null,
            ),
            title: Text('realmPage'.tr()),
            subtitle: post.realmId != null && post.realmId!.isNotEmpty
                ? Text('pinPostRealmHint'.tr())
                : Text('pinPostRealmDisabledHint'.tr()),
            onTap: post.realmId != null && post.realmId!.isNotEmpty
                ? () {
                    mode.value = 1;
                  }
                : null,
            enabled: post.realmId != null && post.realmId!.isNotEmpty,
          ),

          // Reply page pin option (show always, but disabled when not available)
          // Disabled for now because im being lazy
          // ListTile(
          //   leading: Radio<int>(
          //     value: 2,
          //     groupValue: mode.value,
          //     onChanged:
          //         post.repliedPostId != null && post.repliedPostId!.isNotEmpty
          //             ? (value) {
          //               mode.value = value!;
          //             }
          //             : null,
          //   ),
          //   title: Text('replyPage'.tr()),
          //   subtitle:
          //       post.repliedPostId != null && post.repliedPostId!.isNotEmpty
          //           ? Text('pinPostReplyHint'.tr())
          //           : Text('pinPostReplyDisabledHint'.tr()),
          //   onTap:
          //       post.repliedPostId != null && post.repliedPostId!.isNotEmpty
          //           ? () {
          //             mode.value = 2;
          //           }
          //           : null,
          //   enabled:
          //       post.repliedPostId != null && post.repliedPostId!.isNotEmpty,
          // ),
          const SizedBox(height: 16),

          // Pin button
          FilledButton.icon(
            onPressed: pinPost,
            icon: const Icon(Symbols.keep),
            label: Text('pin'.tr()),
          ).padding(horizontal: 24),
        ],
      ),
    );
  }
}
