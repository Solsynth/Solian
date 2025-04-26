import 'dart:io';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/models/post.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/screens/account/me/publishers.dart';
import 'package:island/services/file.dart';
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

    // Contains the XFile, ByteData, or SnCloudFile
    final attachments = useState<List<dynamic>>([]);
    final contentController = useTextEditingController();

    final submitting = useState(false);

    Future<void> pickAttachment() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickMultipleMedia(requestFullMetadata: true);
      attachments.value = [...attachments.value, ...result];
    }

    final attachmentProgress = useState<Map<int, double>>({});

    Future<void> uploadAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment is SnCloudFile) return;
      final baseUrl = ref.watch(serverUrlProvider);
      final atk = await getFreshAtk(
        ref.watch(tokenPairProvider),
        baseUrl,
        onRefreshed: (atk, rtk) {
          setTokenPair(ref.watch(sharedPreferencesProvider), atk, rtk);
          ref.invalidate(tokenPairProvider);
        },
      );
      if (atk == null) throw ArgumentError('Access token is null');
      attachmentProgress.value = {...attachmentProgress.value, index: 0};
      final cloudFile =
          await putMediaToCloud(
            fileData: attachment,
            atk: atk,
            baseUrl: baseUrl,
            filename: attachment.name ?? 'Post media',
            mimetype: attachment.mimeType ?? 'image/jpeg',
            onProgress: (progress, estimate) {
              attachmentProgress.value = {
                ...attachmentProgress.value,
                index: progress,
              };
            },
          ).future;
      if (cloudFile == null) {
        throw ArgumentError('Failed to upload the file...');
      }
      final clone = List.of(attachments.value);
      clone[index] = cloudFile;
      attachments.value = clone;
      attachmentProgress.value = attachmentProgress.value..remove(index);
    }

    Future<void> deleteAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment is SnCloudFile) {
        final client = ref.watch(apiClientProvider);
        await client.delete('/files/${attachment.id}');
      }
      final clone = List.of(attachments.value);
      clone.removeAt(index);
      attachments.value = clone;
    }

    Future<void> performAction() async {
      if (!contentController.text.isNotEmpty) {
        return;
      }

      try {
        submitting.value = true;

        await Future.wait(
          attachments.value
              .where((e) => e is! SnCloudFile)
              .map((e) => uploadAttachment(e)),
        );

        final client = ref.watch(apiClientProvider);
        await client.post(
          '/posts',
          data: {
            'content': contentController.text,
            'attachments':
                attachments.value
                    .whereType<SnCloudFile>()
                    .map((e) => e.id)
                    .toList(),
          },
        );
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
                ).padding(top: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        TextField(
                          controller: contentController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'What\'s happened?!',
                          ),
                          maxLines: null,
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        const Gap(8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            for (
                              var idx = 0;
                              idx < attachments.value.length;
                              idx++
                            )
                              _AttachmentPreview(
                                item: attachments.value[idx],
                                progress: attachmentProgress.value[idx],
                                onRequestUpload: () => uploadAttachment(idx),
                                onDelete: () => deleteAttachment(idx),
                                onMove: (delta) {
                                  if (idx + delta < 0 ||
                                      idx + delta >= attachments.value.length) {
                                    return;
                                  }
                                  final clone = List.of(attachments.value);
                                  clone.insert(
                                    idx + delta,
                                    clone.removeAt(idx),
                                  );
                                  attachments.value = clone;
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).padding(horizontal: 16),
          ),
          Material(
            elevation: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: pickAttachment,
                  icon: const Icon(LucideIcons.imagePlus),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ).padding(
              bottom: MediaQuery.of(context).padding.bottom,
              horizontal: 16,
              top: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final dynamic item;
  final double? progress;
  final Function(int)? onMove;
  final Function? onDelete;
  final Function? onRequestUpload;
  const _AttachmentPreview({
    this.item,
    this.progress,
    this.onRequestUpload,
    this.onMove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Builder(
                builder: (context) {
                  if (item is SnCloudFile) {
                    return CloudFileWidget(item: item);
                  } else if (item is XFile) {
                    if (item.mimeType?.startsWith('image') ?? false) {
                      return Image.file(File(item.path));
                    } else {
                      return Center(
                        child: Text(
                          'Preview is not supported for ${item.mimeType}',
                        ),
                      );
                    }
                  } else if (item is List<int> || item is Uint8List) {
                    return Image.memory(item);
                  }
                  return Placeholder();
                },
              ),
            ),
            if (progress != null)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Uploading...',
                        style: TextStyle(color: Colors.white),
                      ),
                      Gap(4),
                      Center(child: LinearProgressIndicator(value: progress)),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 8,
              top: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            LucideIcons.trash,
                            size: 14,
                            color: Colors.white,
                          ).padding(horizontal: 8, vertical: 6),
                          onTap: () {
                            onDelete?.call();
                          },
                        ),
                        SizedBox(
                          height: 26,
                          child: const VerticalDivider(
                            width: 0.3,
                            color: Colors.white,
                            thickness: 0.3,
                          ),
                        ).padding(horizontal: 2),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            LucideIcons.arrowUp,
                            size: 14,
                            color: Colors.white,
                          ).padding(horizontal: 8, vertical: 6),
                          onTap: () {
                            onMove?.call(-1);
                          },
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          child: const Icon(
                            LucideIcons.arrowDown,
                            size: 14,
                            color: Colors.white,
                          ).padding(horizontal: 8, vertical: 6),
                          onTap: () {
                            onMove?.call(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onRequestUpload?.call(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child:
                          (item is SnCloudFile)
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.cloud,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'On-cloud',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              )
                              : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.cloudOff,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'On-device',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
