import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/attachment/attachment_input.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class StickerPackScreen extends StatefulWidget {
  final int id;
  const StickerPackScreen({super.key, required this.id});

  @override
  State<StickerPackScreen> createState() => _StickerPackScreenState();
}

class _StickerPackScreenState extends State<StickerPackScreen> {
  SnStickerPack? _pack;

  Future<void> _fetchPack() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/uc/stickers/packs/${widget.id}');
      _pack = SnStickerPack.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _fetchPack();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(_pack?.name ?? 'loading'.tr()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingIndicator(isActive: _isBusy),
          if (_pack != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_pack!.name).bold(),
                Text(
                  _pack!.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).padding(horizontal: 24, vertical: 16),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Symbols.add),
            title: Text('stickersNew').tr(),
            subtitle: Text('stickersNewDescription').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _StickerCreateDialog(pack: _pack!),
              ).then((value) {
                if (value) _fetchPack();
              });
            },
          ),
          const Divider(height: 1),
          if (_pack?.stickers != null)
            Expanded(
              child: GridView.extent(
                padding: EdgeInsets.only(left: 20, right: 20, top: 16),
                maxCrossAxisExtent: 48,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: _pack!.stickers!
                    .map(
                      (ele) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHigh,
                          child: AttachmentItem(
                            data: ele.attachment,
                            heroTag: 'sticker-pack-${ele.attachment.rid}',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _StickerCreateDialog extends StatefulWidget {
  final SnStickerPack pack;
  const _StickerCreateDialog({required this.pack});

  @override
  State<_StickerCreateDialog> createState() => _StickerCreateDialogState();
}

class _StickerCreateDialogState extends State<_StickerCreateDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _attachmentController = TextEditingController();

  bool _isBusy = false;

  Future<void> _createSticker() async {
    if (_nameController.text.isEmpty ||
        _aliasController.text.isEmpty ||
        _attachmentController.text.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/uc/stickers',
        data: {
          'name': _nameController.text,
          'alias': _aliasController.text,
          'attachment_id': _attachmentController.text,
          'pack_id': widget.pack.id,
        },
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('stickersNew'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerName'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(4),
          TextField(
            controller: _aliasController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerAlias'.tr(),
              helperText: 'fieldStickerAliasHint'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(4),
          TextField(
            controller: _attachmentController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerAttachment'.tr(),
            ),
            readOnly: true,
            onTap: () async {
              final attachment = await showDialog<SnAttachment?>(
                context: context,
                builder: (context) => AttachmentInputDialog(
                  title: 'fieldStickerAttachment'.tr(),
                  pool: 'sticker',
                  mediaType: SnMediaType.image,
                ),
              );
              if (attachment != null) {
                setState(() {
                  _attachmentController.text = attachment.rid;
                });
              }
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
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
          onPressed: _isBusy ? null : () => _createSticker(),
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
