import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/dialog.dart';

class AttachmentInputDialog extends StatefulWidget {
  final String? title;
  final bool? analyzeNow;
  final SnMediaType? mediaType;
  final String pool;

  const AttachmentInputDialog({
    super.key,
    required this.title,
    required this.pool,
    this.analyzeNow = false,
    this.mediaType = SnMediaType.image,
  });

  @override
  State<AttachmentInputDialog> createState() => _AttachmentInputDialogState();
}

class _AttachmentInputDialogState extends State<AttachmentInputDialog> {
  final _randomIdController = TextEditingController();

  XFile? _file;
  double? _progress;

  void _pickMedia() async {
    final picker = ImagePicker();
    final result = switch (widget.mediaType) {
      SnMediaType.image => await picker.pickImage(source: ImageSource.gallery),
      SnMediaType.video => await picker.pickVideo(source: ImageSource.gallery),
      _ => await picker.pickMedia(),
    };
    if (result == null) return;
    setState(() => _file = result);
  }

  bool _isBusy = false;

  void _finishUp() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final attach = context.read<SnAttachmentProvider>();

    if (_randomIdController.text.isNotEmpty) {
      try {
        final attachment = await attach.getOne(_randomIdController.text);
        if (!mounted) return;
        Navigator.pop(context, attachment);
      } catch (err) {
        if (!mounted) return;
        context.showErrorDialog(err);
      }
    } else if (_file != null) {
      try {
        final place = await attach.chunkedUploadInitialize(
            await _file!.length(), _file!.name, widget.pool, null);

        final attachment = await attach.chunkedUploadParts(
          _file!,
          place.$1,
          place.$2,
          analyzeNow: widget.analyzeNow ?? false,
          onProgress: (value) {
            setState(() => _progress = value);
          },
        );

        if (!mounted) return;
        Navigator.pop(context, attachment);
      } catch (err) {
        if (!mounted) return;
        context.showErrorDialog(err);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title ?? 'attachmentInputDialog'.tr()),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('attachmentInputUseRandomId').tr().fontSize(14),
          const Gap(8),
          TextField(
            controller: _randomIdController,
            decoration: InputDecoration(
              labelText: 'fieldAttachmentRandomId'.tr(),
              border: const UnderlineInputBorder(),
              isDense: true,
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(24),
          Text('attachmentInputNew').tr().fontSize(14),
          Card(
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const Icon(Symbols.add_photo_alternate),
                  trailing: const Icon(Symbols.chevron_right),
                  title: Text('addAttachmentFromAlbum').tr(),
                  subtitle: _file == null
                      ? Text('unset').tr()
                      : Text('waitingForUpload').tr(),
                  onTap: () {
                    _pickMedia();
                  },
                ),
              ],
            ),
          ),
          if (_isBusy)
            LinearProgressIndicator(
              value: _progress,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ).padding(top: 16),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: Text('dialogDismiss').tr(),
        ),
        TextButton(
          onPressed: _isBusy ? null : () => _finishUp(),
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
