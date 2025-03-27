import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:uuid/uuid.dart';

class ChatManageScreen extends StatefulWidget {
  final String? editingChannelAlias;

  const ChatManageScreen({super.key, this.editingChannelAlias});

  @override
  State<ChatManageScreen> createState() => _ChatManageScreenState();
}

class _ChatManageScreenState extends State<ChatManageScreen> {
  bool _isBusy = false;

  final _aliasController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<SnRealm>? _realms;
  SnRealm? _belongToRealm;

  SnChannel? _editingChannel;

  bool _isPublic = false;
  bool _isCommunity = false;

  Future<void> _fetchRealms() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/realms/me/available');
      _realms = List<SnRealm>.from(
        resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
      );
      if (_editingChannel != null) {
        _belongToRealm =
            _realms?.firstWhereOrNull((e) => e.id == _editingChannel!.realmId);
      }
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _fetchChannel() async {
    setState(() => _isBusy = true);

    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get(
        '/cgi/im/channels/${widget.editingChannelAlias}',
      );
      _editingChannel = SnChannel.fromJson(resp.data);
      _aliasController.text = _editingChannel!.alias;
      _nameController.text = _editingChannel!.name;
      _descriptionController.text = _editingChannel!.description;
      _isPublic = _editingChannel!.isPublic;
      _isCommunity = _editingChannel!.isCommunity;
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _performAction() async {
    final uuid = const Uuid();
    final sn = context.read<SnNetworkProvider>();

    setState(() => _isBusy = true);

    final scope = _belongToRealm != null ? _belongToRealm!.alias : 'global';
    final payload = {
      'alias': _aliasController.text.isNotEmpty
          ? _aliasController.text.toLowerCase()
          : uuid.v4().replaceAll('-', '').substring(0, 12),
      'name': _nameController.text,
      'description': _descriptionController.text,
      'is_public': _isPublic,
      'is_community': _isCommunity,
      if (_editingChannel != null && _belongToRealm == null)
        'new_belongs_realm': 'global'
      else if (_editingChannel != null &&
          _belongToRealm?.id != _editingChannel?.realm?.id)
        'new_belongs_realm': _belongToRealm!.alias,
    };

    try {
      final resp = await sn.client.request(
        widget.editingChannelAlias != null
            ? '/cgi/im/channels/$scope/${_editingChannel!.id}'
            : '/cgi/im/channels/$scope',
        data: payload,
        options: Options(
          method: widget.editingChannelAlias != null ? 'PUT' : 'POST',
        ),
      );
      // ignore: use_build_context_synchronously
      if (context.mounted) Navigator.pop(context, resp.data);
    } catch (err) {
      // ignore: use_build_context_synchronously
      if (context.mounted) context.showErrorDialog(err);
    }

    setState(() => _isBusy = false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.editingChannelAlias != null) _fetchChannel();
    _fetchRealms();
  }

  @override
  void dispose() {
    super.dispose();
    _aliasController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        title: widget.editingChannelAlias != null
            ? Text('screenChatManage').tr()
            : Text('screenChatNew').tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            LoadingIndicator(isActive: _isBusy),
            if (_editingChannel != null)
              MaterialBanner(
                leading: const Icon(Symbols.edit),
                leadingPadding: const EdgeInsets.only(left: 10, right: 20),
                dividerColor: Colors.transparent,
                content: Text(
                  'channelEditingNotice'
                      .tr(args: ['#${_editingChannel!.alias}']),
                ),
                actions: [
                  TextButton(
                    child: Text('cancel').tr(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            DropdownButtonHideUnderline(
              child: DropdownButton2<SnRealm>(
                isExpanded: true,
                hint: Text(
                  'fieldChatBelongToRealm'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: [
                  ...(_realms?.map(
                        (SnRealm item) => DropdownMenuItem<SnRealm>(
                          value: item,
                          child: Row(
                            children: [
                              AccountImage(
                                content: item.avatar,
                                radius: 16,
                                fallbackWidget: const Icon(
                                  Symbols.group,
                                  size: 16,
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name).textStyle(Theme.of(context)
                                        .textTheme
                                        .bodyMedium!),
                                    Text(
                                      item.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).textStyle(
                                        Theme.of(context).textTheme.bodySmall!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ) ??
                      []),
                  DropdownMenuItem<SnRealm>(
                    value: null,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSurface,
                          child: const Icon(Symbols.clear),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('fieldChatBelongToRealmUnset')
                                  .tr()
                                  .textStyle(
                                    Theme.of(context).textTheme.bodyMedium!,
                                  ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                value: _belongToRealm,
                onChanged: (SnRealm? value) {
                  setState(() => _belongToRealm = value);
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.only(right: 16),
                  height: 48,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 48,
                ),
              ),
            ),
            const Divider(height: 1),
            const Gap(12),
            Column(
              children: [
                TextField(
                  controller: _aliasController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'fieldChatAlias'.tr(),
                    helperText: 'fieldChatAliasHint'.tr(),
                    helperMaxLines: 2,
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const Gap(4),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'fieldChatName'.tr(),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const Gap(4),
                TextField(
                  controller: _descriptionController,
                  maxLines: null,
                  minLines: 3,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'fieldChatDescription'.tr(),
                  ),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const Gap(12),
                CheckboxListTile(
                  value: _isPublic,
                  title: Text('channelIsPublic'.tr()),
                  subtitle: Text('channelIsPublicDescription'.tr()),
                  onChanged: (value) {
                    setState(() => _isPublic = value ?? false);
                  },
                ),
                CheckboxListTile(
                  value: _isCommunity,
                  title: Text('channelIsCommunity'.tr()),
                  subtitle: Text('channelIsCommunityDescription'.tr()),
                  onChanged: (value) {
                    setState(() => _isCommunity = value ?? false);
                  },
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isBusy ? null : _performAction,
                      icon: const Icon(Symbols.save),
                      label: Text('apply').tr(),
                    ),
                  ],
                ),
              ],
            ).padding(horizontal: 24),
          ],
        ),
      ),
    );
  }
}
