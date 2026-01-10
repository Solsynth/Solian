import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/models/file.dart';
import 'package:island/widgets/chat/chat_link_attachments.dart';

class RoomFilePicker {
  final List<UniversalFile> attachments;
  final void Function(List<UniversalFile>) updateAttachments;
  final Future<void> Function() pickPhotos;
  final Future<void> Function() pickVideos;
  final Future<void> Function() pickAudio;
  final Future<void> Function() pickFiles;
  final Future<void> Function() linkAttachment;

  RoomFilePicker({
    required this.attachments,
    required this.updateAttachments,
    required this.pickPhotos,
    required this.pickVideos,
    required this.pickAudio,
    required this.pickFiles,
    required this.linkAttachment,
  });
}

RoomFilePicker useRoomFilePicker(
  BuildContext context,
  List<UniversalFile> currentAttachments,
  Function(List<UniversalFile>) onAttachmentsChanged,
) {
  final attachments = useState<List<UniversalFile>>(currentAttachments);

  Future<void> pickPhotos() async {
    final picker = ImagePicker();
    final results = await picker.pickMultiImage();
    if (results.isEmpty) return;
    attachments.value = [
      ...attachments.value,
      ...results.map(
        (xfile) => UniversalFile(data: xfile, type: UniversalFileType.image),
      ),
    ];
    onAttachmentsChanged(attachments.value);
  }

  Future<void> pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
      allowCompression: false,
    );
    if (result == null || result.count == 0) return;
    attachments.value = [
      ...attachments.value,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.video),
      ),
    ];
    onAttachmentsChanged(attachments.value);
  }

  Future<void> pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
      allowCompression: false,
    );
    if (result == null || result.count == 0) return;
    attachments.value = [
      ...attachments.value,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.audio),
      ),
    ];
    onAttachmentsChanged(attachments.value);
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowCompression: false,
    );
    if (result == null || result.count == 0) return;
    attachments.value = [
      ...attachments.value,
      ...result.files.map(
        (e) => UniversalFile(data: e.xFile, type: UniversalFileType.file),
      ),
    ];
    onAttachmentsChanged(attachments.value);
  }

  Future<void> linkAttachment() async {
    final cloudFile = await showModalBottomSheet<SnCloudFile?>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => const ChatLinkAttachment(),
    );
    if (cloudFile == null) return;

    attachments.value = [
      ...attachments.value,
      UniversalFile(
        data: cloudFile,
        type: switch (cloudFile.mimeType?.split('/').firstOrNull) {
          'image' => UniversalFileType.image,
          'video' => UniversalFileType.video,
          'audio' => UniversalFileType.audio,
          _ => UniversalFileType.file,
        },
        isLink: true,
      ),
    ];
    onAttachmentsChanged(attachments.value);
  }

  void updateAttachments(List<UniversalFile> newAttachments) {
    attachments.value = newAttachments;
    onAttachmentsChanged(attachments.value);
  }

  return RoomFilePicker(
    attachments: attachments.value,
    updateAttachments: updateAttachments,
    pickPhotos: pickPhotos,
    pickVideos: pickVideos,
    pickAudio: pickAudio,
    pickFiles: pickFiles,
    linkAttachment: linkAttachment,
  );
}
