import 'dart:io';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
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
import 'package:island/screens/posts/detail.dart';
import 'package:island/services/file.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class PostEditScreen extends HookConsumerWidget {
  final int id;
  const PostEditScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postProvider(id));
    return post.when(
      data: (post) => PostComposeScreen(originalPost: post),
      loading:
          () => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => AppScaffold(
            appBar: AppBar(leading: const PageBackButton()),
            body: Text('Error: $e', textAlign: TextAlign.center),
          ),
    );
  }
}

@RoutePage()
class PostComposeScreen extends HookConsumerWidget {
  final SnPost? originalPost;
  const PostComposeScreen({super.key, this.originalPost});

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
    final attachments = useState<List<UniversalFile>>(
      originalPost?.attachments
              .map(
                (e) => UniversalFile(
                  data: e,
                  type: switch (e.mimeType?.split('/').firstOrNull) {
                    'image' => UniversalFileType.image,
                    'video' => UniversalFileType.video,
                    'audio' => UniversalFileType.audio,
                    _ => UniversalFileType.file,
                  },
                ),
              )
              .toList() ??
          [],
    );
    final contentController = useTextEditingController(
      text: originalPost?.content,
    );
    final titleController = useTextEditingController(text: originalPost?.title);
    final descriptionController = useTextEditingController(
      text: originalPost?.description,
    );

    final submitting = useState(false);

    Future<void> pickPhotoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickMultiImage(requestFullMetadata: true);
      attachments.value = [
        ...attachments.value,
        ...result.map(
          (e) => UniversalFile(data: e, type: UniversalFileType.image),
        ),
      ];
    }

    Future<void> pickVideoMedia() async {
      final result = await ref
          .watch(imagePickerProvider)
          .pickVideo(source: ImageSource.gallery);
      attachments.value = [
        ...attachments.value,
        UniversalFile(data: result, type: UniversalFileType.video),
      ];
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
      try {
        attachmentProgress.value = {...attachmentProgress.value, index: 0};
        final cloudFile =
            await putMediaToCloud(
              fileData: attachment,
              atk: atk,
              baseUrl: baseUrl,
              filename: attachment.data.name ?? 'Post media',
              mimetype:
                  attachment.data.mimeType ??
                  switch (attachment.type) {
                    UniversalFileType.image => 'image/unknown',
                    UniversalFileType.video => 'video/unknown',
                    UniversalFileType.audio => 'audio/unknown',
                    UniversalFileType.file => 'application/octet-stream',
                  },
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
        clone[index] = UniversalFile(data: cloudFile, type: attachment.type);
        attachments.value = clone;
      } catch (err) {
        showErrorAlert(err);
      } finally {
        attachmentProgress.value = attachmentProgress.value..remove(index);
      }
    }

    Future<void> deleteAttachment(int index) async {
      final attachment = attachments.value[index];
      if (attachment.isOnCloud) {
        final client = ref.watch(apiClientProvider);
        await client.delete('/files/${attachment.data.id}');
      }
      final clone = List.of(attachments.value);
      clone.removeAt(index);
      attachments.value = clone;
    }

    Future<void> performAction() async {
      try {
        submitting.value = true;

        await Future.wait(
          attachments.value
              .where((e) => e.isOnDevice)
              .map((e) => uploadAttachment(e.data)),
        );

        final client = ref.watch(apiClientProvider);
        await client.request(
          originalPost == null ? '/posts' : '/posts/${originalPost!.id}',
          data: {
            'content': contentController.text,
            'attachments':
                attachments.value
                    .where((e) => e.isOnCloud)
                    .map((e) => e.data.id)
                    .toList(),
          },
          options: Options(
            headers: {'X-Pub': currentPublisher.value?.name},
            method: originalPost == null ? 'POST' : 'PATCH',
          ),
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
            icon:
                submitting.value
                    ? SizedBox(
                      width: 28,
                      height: 28,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ).center()
                    : originalPost != null
                    ? const Icon(LucideIcons.edit)
                    : const Icon(LucideIcons.upload),
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
                          controller: titleController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Title',
                          ),
                          style: TextStyle(fontSize: 20),
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration.collapsed(
                            hintText: 'Description',
                          ),
                          style: TextStyle(fontSize: 18),
                          onTapOutside:
                              (_) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                        const Gap(12),
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
                  onPressed: pickPhotoMedia,
                  icon: const Icon(LucideIcons.imagePlus),
                  color: Theme.of(context).colorScheme.primary,
                ),
                IconButton(
                  onPressed: pickVideoMedia,
                  icon: const Icon(LucideIcons.fileVideo2),
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
  final UniversalFile item;
  final double? progress;
  final Function(int)? onMove;
  final Function? onDelete;
  final Function? onRequestUpload;
  const _AttachmentPreview({
    required this.item,
    this.progress,
    this.onRequestUpload,
    this.onMove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio:
          (item.isOnCloud ? (item.data.fileMeta?['ratio'] ?? 1) : 1).toDouble(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              child: Builder(
                builder: (context) {
                  if (item.isOnCloud) {
                    return CloudFileWidget(item: item.data);
                  } else if (item.data is XFile) {
                    if (item.type == UniversalFileType.image) {
                      return Image.file(File(item.data.path));
                    } else {
                      return Center(
                        child: Text(
                          'Preview is not supported for ${item.type}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  } else if (item is List<int> || item is Uint8List) {
                    if (item.type == UniversalFileType.image) {
                      return Image.memory(item.data);
                    } else {
                      return Center(
                        child: Text(
                          'Preview is not supported for ${item.type}',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
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
                      Text('Uploading', style: TextStyle(color: Colors.white)),
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
                          (item.isOnCloud)
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
