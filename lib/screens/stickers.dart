import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/sn_sticker.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/attachment.dart';
import 'package:surface/widgets/attachment/attachment_item.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

class StickerScreen extends StatefulWidget {
  const StickerScreen({super.key});

  @override
  State<StickerScreen> createState() => _StickerScreenState();
}

class _StickerScreenState extends State<StickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  bool _isBusy = false;
  int? _totalCount;
  final List<SnStickerPack> _packs = List.empty(growable: true);

  Future<void> _fetchPacks() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final ua = context.read<UserProvider>();
      final resp = await sn.client.get(
        _tabController.index == 1
            ? '/cgi/uc/stickers/packs/own'
            : '/cgi/uc/stickers/packs',
        queryParameters: {
          'take': 10,
          'offset': _packs.length,
          if (_tabController.index == 2) 'author': ua.user?.id,
        },
      );
      if (resp.data is Map<String, dynamic>) {
        _totalCount = resp.data['count'] as int?;
        final out = List<SnStickerPack>.from(
          resp.data['data'].map((ele) => SnStickerPack.fromJson(ele)),
        );
        _packs.addAll(out);
      } else {
        _totalCount = 0;
        final out = List<SnStickerPack>.from(
          resp.data.map((ele) => SnStickerPack.fromJson(ele)),
        );
        _packs.addAll(out);
      }
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _removePack(SnStickerPack pack) async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete('/cgi/uc/stickers/packs/${pack.id}/own');
      if (!mounted) return;
      context.showSnackbar('stickersRemoved'.tr());
      _refreshPacks();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _deletePack(SnStickerPack pack) async {
    final confirm = await context.showConfirmDialog(
      'stickersPackDelete'.tr(args: [pack.name]),
      'stickersPackDeleteDescription'.tr(),
    );
    if (!confirm) return;
    if (!mounted) return;

    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      await sn.client.delete('/cgi/uc/stickers/packs/${pack.id}');
      if (!mounted) return;
      context.showSnackbar('stickersDeleted'.tr());
      _refreshPacks();
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _refreshPacks() async {
    _packs.clear();
    _totalCount = null;
    await _fetchPacks();
  }

  @override
  void initState() {
    super.initState();
    _fetchPacks();
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _refreshPacks();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: PageBackButton(),
        title: Text('screenStickers').tr(),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add_circle),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _StickerPackCreateDialog(),
              ).then((value) {
                if (value == true) _refreshPacks();
              });
            },
          ),
          const Gap(8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text('stickersDiscovery'.tr()).textColor(
                Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            Tab(
              child: Text('stickersOwned'.tr()).textColor(
                Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
            Tab(
              child: Text('stickersCreated'.tr()).textColor(
                Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
          ],
        ),
      ),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: RefreshIndicator(
          onRefresh: _refreshPacks,
          child: InfiniteList(
            itemCount: _packs.length,
            onFetchData: _fetchPacks,
            hasReachedMax:
                (_totalCount != null && _packs.length >= _totalCount!) ||
                    _tabController.index == 2,
            isLoading: _isBusy,
            itemBuilder: (context, idx) {
              final pack = _packs[idx];
              return ListTile(
                title: Text(pack.name),
                subtitle: Text(
                  pack.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                trailing: _tabController.index == 1
                    ? IconButton(
                        onPressed: () {
                          _removePack(pack);
                        },
                        icon: const Icon(Symbols.remove),
                      )
                    : _tabController.index == 2
                        ? IconButton(
                            onPressed: () {
                              _deletePack(pack);
                            },
                            icon: const Icon(Symbols.delete),
                          )
                        : null,
                onTap: () {
                  if (_tabController.index == 0) {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _StickerPackAddPopup(pack: pack),
                    ).then((value) {
                      if (value == true && _tabController.index == 1) {
                        _refreshPacks();
                      }
                    });
                  } else {
                    GoRouter.of(context).pushNamed(
                      'stickerPack',
                      pathParameters: {
                        'id': pack.id.toString(),
                      },
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StickerPackAddPopup extends StatefulWidget {
  final SnStickerPack pack;
  const _StickerPackAddPopup({required this.pack});

  @override
  State<_StickerPackAddPopup> createState() => _StickerPackAddPopupState();
}

class _StickerPackAddPopupState extends State<_StickerPackAddPopup> {
  SnStickerPack? _pack;

  bool _isBusy = false;

  Future<void> _fetchPack() async {
    try {
      setState(() => _isBusy = true);
      final sn = context.read<SnNetworkProvider>();
      final resp =
          await sn.client.get('/cgi/uc/stickers/packs/${widget.pack.id}');
      _pack = SnStickerPack.fromJson(resp.data);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPack();
  }

  bool _isAdding = false;

  Future<void> _addPack() async {
    if (_pack == null) return;

    try {
      setState(() => _isAdding = true);
      final sn = context.read<SnNetworkProvider>();
      final stickers = context.read<SnStickerProvider>();
      await sn.client.post(
        '/cgi/uc/stickers/packs/${widget.pack.id}/own',
      );
      if (!mounted) return;
      context.showSnackbar('stickersAdded'.tr());
      if (_pack?.stickers != null) {
        stickers.putSticker(
            _pack!.stickers!.map((ele) => ele.copyWith(pack: _pack!)));
      }
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Symbols.add, size: 24),
            const Gap(16),
            Text('stickersAdd', style: Theme.of(context).textTheme.titleLarge)
                .tr(),
          ],
        ).padding(horizontal: 20, top: 16, bottom: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pack.name).bold(),
                  Text(
                    widget.pack.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isAdding ? null : _addPack,
              child: Text('add').tr(),
            ),
          ],
        ).padding(horizontal: 24),
        LoadingIndicator(isActive: _isBusy),
        if (_pack?.stickers != null)
          Expanded(
            child: GridView.extent(
              padding: EdgeInsets.only(left: 20, right: 20, top: 8),
              maxCrossAxisExtent: 48,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: _pack!.stickers!
                  .map(
                    (ele) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
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
    );
  }
}

class _StickerPackCreateDialog extends StatefulWidget {
  const _StickerPackCreateDialog();

  @override
  State<_StickerPackCreateDialog> createState() =>
      _StickerPackCreateDialogState();
}

class _StickerPackCreateDialogState extends State<_StickerPackCreateDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isBusy = false;

  Future<void> _createPack() async {
    if (_nameController.text.isEmpty ||
        _prefixController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.post(
        '/cgi/uc/stickers/packs',
        data: {
          'name': _nameController.text,
          'prefix': _prefixController.text,
          'description': _descriptionController.text,
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
  void dispose() {
    _nameController.dispose();
    _prefixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('stickersPackNew').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerPackName'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(4),
          TextField(
            controller: _prefixController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerPackPrefix'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(4),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: 'fieldStickerPackDescription'.tr(),
            ),
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
          onPressed: _isBusy ? null : () => _createPack(),
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
