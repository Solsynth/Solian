import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/me/publishers.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class PostComposeScreen extends HookConsumerWidget {
  const PostComposeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publishers = ref.watch(publishersManagedProvider);

    final currentPublisher = useState<SnPublisher?>(null);

    useEffect(() {
      if (publishers.value?.isNotEmpty ?? false) {
        currentPublisher.value = publishers.value!.first;
      }
      return null;
    }, [publishers]);

    final contentController = useTextEditingController();

    final submitting = useState(false);

    Future<void> performAction() async {
      if (!contentController.text.isNotEmpty) {
        return;
      }

      try {
        submitting.value = true;
        final client = ref.watch(apiClientProvider);
        await client.post('/posts', data: {'content': contentController.text});
        if (context.mounted) {
          context.maybePop(true);
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        actions: [
          IconButton(
            onPressed: submitting.value ? null : performAction,
            icon: const Icon(LucideIcons.upload),
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePictureWidget(
                  item: currentPublisher.value?.picture,
                  radius: 24,
                ),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    decoration: InputDecoration.collapsed(
                      hintText: 'What\'s happened?!',
                    ),
                    maxLines: null,
                    onTapOutside:
                        (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
              ],
            ).padding(all: 16),
          ),
        ],
      ),
    );
  }
}
