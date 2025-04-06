import 'dart:io';
import 'dart:ui';

import 'package:croppy/croppy.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/controllers/post_write_controller.dart';
import 'package:surface/providers/sn_attachment.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/attachment/attachment_input.dart';
import 'package:surface/widgets/attachment/attachment_zoom.dart';
import 'package:surface/widgets/attachment/pending_attachment_alt.dart';
import 'package:surface/widgets/attachment/pending_attachment_boost.dart';
import 'package:surface/widgets/attachment/pending_attachment_compress.dart';
import 'package:surface/widgets/attachment/pending_attachment_rating.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';

class PendingAttachmentActionSheet extends StatefulWidget {
  final PostWriteMedia media;
  final bool canInsertLink;
  const PendingAttachmentActionSheet({
    super.key,
    required this.media,
    this.canInsertLink = true,
  });

  @override
  State<PendingAttachmentActionSheet> createState() =>
      _PendingAttachmentActionSheetState();
}

class _PendingAttachmentActionSheetState
    extends State<PendingAttachmentActionSheet> {
  bool _isBusy = false;

  Future<void> _cropImage() async {
    final result = (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
        ? await showCupertinoImageCropper(
            // ignore: use_build_context_synchronously
            context,
            // ignore: use_build_context_synchronously
            imageProvider: widget.media.getImageProvider(context)!,
          )
        : await showMaterialImageCropper(
            // ignore: use_build_context_synchronously
            context,
            // ignore: use_build_context_synchronously
            imageProvider: widget.media.getImageProvider(context)!,
          );

    if (result == null) return;

    final rawBytes =
        (await result.uiImage.toByteData(format: ImageByteFormat.png))!
            .buffer
            .asUint8List();

    if (!mounted) return;
    final updatedMedia = PostWriteMedia.fromBytes(
        rawBytes, widget.media.name, widget.media.type);
    Navigator.pop(context, updatedMedia);
  }

  Future<void> _setThumbnail() async {
    final thumbnail = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => AttachmentInputDialog(
        title: 'attachmentSetThumbnail'.tr(),
        pool: 'interactive',
        analyzeNow: true,
      ),
    );
    if (thumbnail == null) return;
    if (!mounted) return;

    try {
      final attach = context.read<SnAttachmentProvider>();
      final newAttach = await attach.updateOne(widget.media.attachment!,
          thumbnailId: thumbnail.id);
      if (mounted) Navigator.pop(context, newAttach);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  Future<void> _deleteAttachment() async {
    if (_isBusy) return;
    if (widget.media.attachment == null) return;

    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client
          .delete('/cgi/uc/attachments/${widget.media.attachment!.id}');
      if (!mounted) return;
      Navigator.pop(context, false);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _createBoost() async {
    final result = await showDialog<SnAttachmentBoost?>(
      context: context,
      builder: (context) => PendingAttachmentBoostDialog(
        media: widget.media,
      ),
    );
    if (result == null) return;

    final newAttach = widget.media.attachment!
        .copyWith(boosts: [...widget.media.attachment!.boosts, result]);
    final newMedia = PostWriteMedia(newAttach);

    if (!mounted) return;
    Navigator.pop(context, newMedia);
  }

  Future<void> _compressVideo() async {
    final result = await showDialog<PostWriteMedia?>(
      context: context,
      builder: (context) => PendingVideoCompressDialog(media: widget.media),
    );
    if (result == null) return;

    if (!mounted) return;
    Navigator.pop(context, result);
  }

  Future<void> _setAlt() async {
    final result = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => PendingAttachmentAltDialog(media: widget.media),
    );
    if (result == null) return;

    if (!mounted) return;
    Navigator.pop(context, PostWriteMedia(result));
  }

  Future<void> _setRating() async {
    final result = await showDialog<SnAttachment?>(
      context: context,
      builder: (context) => PendingAttachmentRateDialog(media: widget.media),
    );
    if (result == null) return;

    if (!mounted) return;
    Navigator.pop(context, PostWriteMedia(result));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.edit, size: 24),
            const Gap(16),
            Text('attachmentEditor')
                .tr()
                .textStyle(Theme.of(context).textTheme.titleLarge!),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        if (widget.media.attachment == null)
          Text('attachmentEditorUnUploadHint')
              .tr()
              .textStyle(Theme.of(context).textTheme.bodyMedium!)
              .padding(horizontal: 20, bottom: 8)
              .opacity(0.8)
        else
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.media.attachment!.alt),
                Row(
                  spacing: 6,
                  children: [
                    Text(widget.media.attachment!.size.formatBytes()),
                    Text(
                      widget.media.attachment!.mimetype,
                      style: GoogleFonts.robotoMono(),
                    ),
                  ],
                ),
                Text('attachmentEditorUploadHint')
                    .tr()
                    .textStyle(Theme.of(context).textTheme.bodyMedium!)
                    .opacity(0.8),
              ],
            ).padding(horizontal: 16, vertical: 8),
          ).padding(horizontal: 16, bottom: 8),
        LoadingIndicator(isActive: _isBusy),
        if (widget.media.attachment == null)
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.upload),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentUpload').tr(),
                  onTap: () => Navigator.pop(context, true),
                ),
                if (widget.media.type == SnMediaType.video)
                  ListTile(
                    minTileHeight: 48,
                    leading: const Icon(Symbols.compress),
                    title: Text('attachmentCompressVideo').tr(),
                    onTap: () => _compressVideo(),
                  ),
                if (widget.media.type == SnMediaType.image)
                  ListTile(
                    minTileHeight: 48,
                    leading: const Icon(Symbols.crop),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    title: Text('crop').tr(),
                    onTap: () => _cropImage(),
                  ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.delete),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('delete').tr(),
                  onTap: () => Navigator.pop(context, false),
                ),
              ],
            ),
          )
        else
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.preview),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('preview').tr(),
                  onTap: () {
                    context.pushTransparentRoute(
                      AttachmentZoomView(data: [widget.media.attachment!]),
                      rootNavigator: true,
                    );
                  },
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.copy_all),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentCopyRandomId').tr(),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: widget.media.attachment!.rid,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                if (widget.canInsertLink)
                  ListTile(
                    minTileHeight: 48,
                    leading: const Icon(Symbols.add_link),
                    contentPadding: EdgeInsets.symmetric(horizontal: 24),
                    title: Text('attachmentInsertLink').tr(),
                    onTap: () {
                      Navigator.pop(context, 'link');
                    },
                  ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.bolt),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentBoost').tr(),
                  onTap: () => _createBoost(),
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.thumbnail_bar),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentSetThumbnail').tr(),
                  onTap: () => _setThumbnail(),
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.description),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentSetAlt').tr(),
                  onTap: () => _setAlt(),
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.star),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('attachmentRating').tr(),
                  onTap: () => _setRating(),
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.link_off),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('unlink').tr(),
                  onTap: () => Navigator.pop(context, false),
                ),
                ListTile(
                  minTileHeight: 48,
                  leading: const Icon(Symbols.delete),
                  contentPadding: EdgeInsets.symmetric(horizontal: 24),
                  title: Text('delete').tr(),
                  onTap: () => _deleteAttachment(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
