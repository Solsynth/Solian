import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/posts/widgets/compose/compose_link_attachments.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/attachment_preview.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CloudFilePicker extends HookConsumerWidget {
  final bool allowMultiple;
  final Set<UniversalFileType> allowedTypes;
  const CloudFilePicker({
    super.key,
    this.allowMultiple = false,
    this.allowedTypes = const {
      UniversalFileType.image,
      UniversalFileType.video,
      UniversalFileType.file,
    },
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final files = useState<List<UniversalFile>>([]);

    final uploadPosition = useState<int?>(null);
    final uploadProgress = useState<double?>(null);

    final uploadOverallProgress = useMemoized<double?>(() {
      if (uploadPosition.value == null || uploadProgress.value == null) {
        return null;
      }

      // Calculate completed files (100% each) + current file progress
      final completedProgress = uploadPosition.value! * 100.0;
      final currentProgress = uploadProgress.value!;

      // Calculate overall progress as percentage
      return (completedProgress + currentProgress) /
          (files.value.length * 100.0);
    }, [uploadPosition.value, uploadProgress.value, files.value.length]);

    Future<void> startUpload() async {
      if (files.value.isEmpty) return;

      List<SnCloudFile> result = List.empty(growable: true);

      uploadProgress.value = 0;
      uploadPosition.value = 0;
      try {
        for (var idx = 0; idx < files.value.length; idx++) {
          uploadPosition.value = idx;
          final file = files.value[idx];
          final cloudFile = await ref
              .read(driveFileUploaderProvider)
              .createCloudFile(
                fileData: file,
                onProgress: (progress, _) {
                  uploadProgress.value = progress;
                },
              )
              .future;
          if (cloudFile == null) {
            throw ArgumentError('Failed to upload the file...');
          }
          result.add(cloudFile);
        }

        if (context.mounted) {
          if (allowMultiple) {
            Navigator.pop(context, result);
          } else {
            Navigator.pop(context, result.isNotEmpty ? result.first : null);
          }
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void pickFile() async {
      showLoadingModal(context);
      final result = await FilePicker.pickFiles(allowMultiple: allowMultiple);
      if (result == null) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      final newFiles = result.files.map((e) {
        final xfile = e.bytes != null
            ? XFile.fromData(e.bytes!, name: e.name)
            : XFile(e.path!);
        return UniversalFile(data: xfile, type: UniversalFileType.file);
      }).toList();

      if (!allowMultiple) {
        files.value = newFiles;
        if (context.mounted) {
          hideLoadingModal(context);
          startUpload();
        }
        return;
      }

      files.value = [...files.value, ...newFiles];
      if (context.mounted) hideLoadingModal(context);
    }

    void pickImage() async {
      showLoadingModal(context);
      final ImagePicker picker = ImagePicker();
      List<XFile> results;
      if (allowMultiple) {
        results = await picker.pickMultiImage();
      } else {
        final XFile? result = await picker.pickImage(
          source: ImageSource.gallery,
        );
        results = result != null ? [result] : [];
      }
      if (results.isEmpty) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      final newFiles = results
          .map(
            (xfile) =>
                UniversalFile(data: xfile, type: UniversalFileType.image),
          )
          .toList();

      if (!allowMultiple) {
        files.value = newFiles;
        if (context.mounted) {
          hideLoadingModal(context);
          startUpload();
        }
        return;
      }

      files.value = [...files.value, ...newFiles];
      if (context.mounted) hideLoadingModal(context);
    }

    void pickVideo() async {
      showLoadingModal(context);
      final result = await FilePicker.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.video,
      );
      if (result == null || result.files.isEmpty) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      final newFiles = result.files.map((e) {
        final xfile = e.bytes != null
            ? XFile.fromData(e.bytes!, name: e.name)
            : XFile(e.path!);
        return UniversalFile(data: xfile, type: UniversalFileType.video);
      }).toList();

      if (!allowMultiple) {
        files.value = newFiles;
        if (context.mounted) {
          hideLoadingModal(context);
          startUpload();
        }
        return;
      }

      files.value = [...files.value, ...newFiles];
      if (context.mounted) hideLoadingModal(context);
    }

    void pickLinkAttachment() async {
      final result = await showModalBottomSheet<SnCloudFile>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const ComposeLinkAttachment(),
      );

      if (result != null) {
        if (!context.mounted) return;
        if (allowMultiple) {
          Navigator.pop(context, [result]);
        } else {
          Navigator.pop(context, result);
        }
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 8, bottom: 12),
            child: Row(
              children: [
                Text(
                  'pickFile'.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (uploadOverallProgress != null)
                    Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('uploadingProgress')
                            .tr(
                              args: [
                                ((uploadPosition.value ?? 0) + 1).toString(),
                                files.value.length.toString(),
                              ],
                            )
                            .opacity(0.85),
                        const LinearProgressIndicator(),
                      ],
                    ),
                  if (files.value.isNotEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: startUpload,
                        icon: const Icon(Symbols.play_arrow),
                        label: Text('uploadAll'.tr()),
                      ),
                    ),
                  if (files.value.isNotEmpty)
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: files.value.length,
                        itemBuilder: (context, idx) {
                          return AttachmentPreview(
                            onDelete: uploadOverallProgress != null
                                ? null
                                : () {
                                    files.value = [
                                      ...files.value.where(
                                        (e) => e != files.value[idx],
                                      ),
                                    ];
                                  },
                            item: files.value[idx],
                            progress: null,
                          );
                        },
                        separatorBuilder: (_, _) => const Gap(8),
                      ),
                    ),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Symbols.link),
                          title: Text('addLinkAttachment'.tr()),
                          onTap: () => pickLinkAttachment(),
                        ),
                        if (allowedTypes.contains(UniversalFileType.image))
                          ListTile(
                            leading: const Icon(Symbols.photo),
                            title: Text('addPhoto'.tr()),
                            onTap: () => pickImage(),
                          ),
                        if (allowedTypes.contains(UniversalFileType.video))
                          ListTile(
                            leading: const Icon(Symbols.video_call),
                            title: Text('addVideo'.tr()),
                            onTap: () => pickVideo(),
                          ),
                        if (allowedTypes.contains(UniversalFileType.file))
                          ListTile(
                            leading: const Icon(Symbols.draft),
                            title: Text('addFile'.tr()),
                            onTap: () => pickFile(),
                          ),
                      ],
                    ),
                  ),
                ],
              ).padding(all: 20),
            ),
          ),
        ],
      ),
    );
  }
}
