import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/types/realm.dart';
import 'package:surface/widgets/account/account_image.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

class AccountPublisherNewScreen extends StatefulWidget {
  const AccountPublisherNewScreen({super.key});

  @override
  State<AccountPublisherNewScreen> createState() =>
      _AccountPublisherNewScreenState();
}

class _AccountPublisherNewScreenState extends State<AccountPublisherNewScreen> {
  String mode = 'personal';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('screenAccountPublisherNew').tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                      value: 'personal',
                      label: Text('Personal'),
                      icon: Icon(Symbols.account_box)),
                  ButtonSegment<String>(
                      value: 'organization',
                      label: Text('Organization'),
                      icon: Icon(Symbols.group)),
                ],
                selected: {mode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => mode = newSelection.first);
                },
              ),
            ),
            switch (mode) {
              'personal' => const _PublisherNewPersonal(),
              'organization' => const _PublisherNewOrganization(),
              _ => const Placeholder(),
            },
          ],
        ).padding(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _PublisherNewPersonal extends StatefulWidget {
  const _PublisherNewPersonal();

  @override
  State<_PublisherNewPersonal> createState() => _PublisherNewPersonalState();
}

class _PublisherNewPersonalState extends State<_PublisherNewPersonal> {
  bool _isBusy = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _performAction() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;

    setState(() => _isBusy = true);

    try {
      await sn.client.post('/cgi/co/publishers/personal', data: {
        'name': _nameController.text,
        'nick': _nickController.text,
        'description': _descriptionController.text,
        'avatar': ua.user!.avatar,
        'banner': ua.user!.banner,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _syncState() {
    final ua = context.read<UserProvider>();
    if (ua.user == null) return;

    _nameController.text = ua.user!.name;
    _nickController.text = ua.user!.nick;
    _descriptionController.text = ua.user!.profile!.description;
  }

  @override
  void initState() {
    super.initState();
    _syncState();
    _nameController.addListener(() => setState(() => {}));
    _nickController.addListener(() => setState(() => {}));
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _nickController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'fieldUsername'.tr(),
                helperText: 'fieldUsernameCannotEditHint'.tr(),
                helperMaxLines: 2,
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _nickController,
              decoration: InputDecoration(
                labelText: 'fieldNickname'.tr(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'fieldDescription'.tr(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ],
        ).padding(horizontal: 8),
        const Gap(16),
        Card(
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                AccountImage(content: ua.user!.avatar, radius: 24),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_nickController.text)
                        .textStyle(Theme.of(context).textTheme.titleLarge!),
                    const Gap(4),
                    Text('@${_nameController.text}')
                        .textStyle(Theme.of(context).textTheme.bodySmall!),
                  ],
                ),
              ],
            ),
          ).padding(all: 16),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isBusy ? null : _performAction,
            icon: const Icon(Symbols.add),
            label: Text('create').tr(),
          ),
        ).padding(horizontal: 2),
      ],
    );
  }
}

class _PublisherNewOrganization extends StatefulWidget {
  const _PublisherNewOrganization();

  @override
  State<_PublisherNewOrganization> createState() =>
      _PublisherNewOrganizationState();
}

class _PublisherNewOrganizationState extends State<_PublisherNewOrganization> {
  bool _isBusy = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _performAction() async {
    final sn = context.read<SnNetworkProvider>();
    final ua = context.read<UserProvider>();
    if (!ua.isAuthorized) return;
    if (_belongToRealm == null) return;

    setState(() => _isBusy = true);

    try {
      await sn.client.post('/cgi/co/publishers/organization', data: {
        'realm': _belongToRealm!.alias,
        'name': _nameController.text,
        'nick': _nickController.text,
        'description': _descriptionController.text,
        'avatar': _belongToRealm!.avatar,
        'banner': _belongToRealm!.banner,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  List<SnRealm>? _realms;
  SnRealm? _belongToRealm;

  Future<void> _fetchRealms() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/realms/me/available');
      _realms = List<SnRealm>.from(
        resp.data?.map((e) => SnRealm.fromJson(e)) ?? [],
      );
    } catch (err) {
      if (mounted) context.showErrorDialog(err);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _syncState() {
    if (_belongToRealm == null) return;

    _nameController.text = _belongToRealm!.alias;
    _nickController.text = _belongToRealm!.name;
    _descriptionController.text = _belongToRealm!.description;
  }

  @override
  void initState() {
    super.initState();
    _fetchRealms();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _nickController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<SnRealm>(
            isExpanded: true,
            hint: Text(
              'fieldPublisherBelongToRealm'.tr(),
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
                                Text(item.name).textStyle(
                                    Theme.of(context).textTheme.bodyMedium!),
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
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      child: const Icon(Symbols.clear),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('fieldPublisherBelongToRealmUnset')
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
              _belongToRealm = value;
              _syncState();
              setState(() {});
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 16),
              height: 60,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 60,
            ),
          ),
        ),
        Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'fieldUsername'.tr(),
                helperText: 'fieldUsernameCannotEditHint'.tr(),
                helperMaxLines: 2,
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _nickController,
              decoration: InputDecoration(
                labelText: 'fieldNickname'.tr(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(4),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'fieldDescription'.tr(),
              ),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
            ),
          ],
        ).padding(horizontal: 8),
        const Gap(16),
        Card(
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                AccountImage(content: _belongToRealm?.avatar, radius: 24),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(_nickController.text)
                        .textStyle(Theme.of(context).textTheme.titleLarge!),
                    const Gap(4),
                    Text('@${_nameController.text}')
                        .textStyle(Theme.of(context).textTheme.bodySmall!),
                  ],
                ),
              ],
            ),
          ).padding(all: 16),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isBusy ? null : _performAction,
            icon: const Icon(Symbols.add),
            label: Text('create').tr(),
          ),
        ).padding(horizontal: 2),
      ],
    );
  }
}
