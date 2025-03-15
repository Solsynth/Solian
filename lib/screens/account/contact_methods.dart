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
import 'package:surface/types/account.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/loading_indicator.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';

const kContactMethodsIcons = [Symbols.email, Symbols.phone, Symbols.map];
const kContactMethodsName = ['Email', 'Phone', 'Address'];

class AccountContactMethod extends StatefulWidget {
  const AccountContactMethod({super.key});

  @override
  State<AccountContactMethod> createState() => _AccountContactMethodState();
}

class _AccountContactMethodState extends State<AccountContactMethod> {
  bool _isBusy = false;
  List<SnAccountContact> _contactMethods = List.empty(growable: true);

  Future<void> _fetchContactMethods() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      final resp = await sn.client.get('/cgi/id/users/me/contacts');
      _contactMethods = List.from((resp.data as List<dynamic>)
          .map((e) => SnAccountContact.fromJson(e)));
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
    _fetchContactMethods();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('accountContactMethods').tr(),
      ),
      body: Column(
        children: [
          LoadingIndicator(isActive: _isBusy),
          ListTile(
            title: Text('accountContactMethodsAdd').tr(),
            subtitle: Text('accountContactMethodsAddDescription').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Symbols.add),
            trailing: const Icon(Symbols.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => _ContactMethodEditor(),
              ).then((value) {
                if (value) {
                  _fetchContactMethods();
                }
              });
            },
          ),
          Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchContactMethods,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _contactMethods.length,
                itemBuilder: (context, index) {
                  final method = _contactMethods[index];
                  return ListTile(
                    title: Text(method.content),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'accountContactMethodsName${kContactMethodsName[method.type]}',
                        ).tr().bold(),
                        if (method.isPrimary ||
                            method.isPublic ||
                            method.verifiedAt != null)
                          Row(
                            spacing: 4,
                            children: [
                              if (method.isPrimary)
                                Text('accountContactMethodsPrimary').tr(),
                              if (method.isPublic)
                                Text('accountContactMethodsPublic').tr(),
                              if (method.verifiedAt != null)
                                Text('accountContactMethodsVerified').tr(),
                            ],
                          ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Icon(
                      kContactMethodsIcons[method.type],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Symbols.edit),
                              const Gap(8),
                              Text('edit').tr(),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => _ContactMethodEditor(
                                contact: method,
                              ),
                            ).then((value) {
                              if (value) {
                                _fetchContactMethods();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactMethodEditor extends StatefulWidget {
  final SnAccountContact? contact;
  const _ContactMethodEditor({this.contact});

  @override
  State<_ContactMethodEditor> createState() => _ContactMethodEditorState();
}

class _ContactMethodEditorState extends State<_ContactMethodEditor> {
  int _type = 0;
  bool _isPublic = false;
  final TextEditingController _contentController = TextEditingController();

  bool _isBusy = false;

  Future<void> _saveContactMethod() async {
    setState(() => _isBusy = true);
    try {
      final sn = context.read<SnNetworkProvider>();
      await sn.client.request(
        widget.contact == null
            ? '/cgi/id/users/me/contacts'
            : '/cgi/id/users/me/contacts/${widget.contact!.id}',
        data: {
          'content': _contentController.text,
          'type': _type,
          'is_public': _isPublic,
        },
        options: Options(
          method: widget.contact == null ? 'POST' : 'PUT',
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
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
    if (widget.contact != null) {
      _type = widget.contact!.type;
      _isPublic = widget.contact!.isPublic;
      _contentController.text = widget.contact!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.contact == null
          ? Text('accountContactMethodsAdd').tr()
          : Text('accountContactMethodsEdit').tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton2<int>(
              value: _type,
              items: kContactMethodsName
                  .mapIndexed((idx, ele) => DropdownMenuItem<int>(
                        value: idx,
                        child: Text('accountContactMethodsName$ele').tr(),
                      ))
                  .toList(),
              buttonStyleData: ButtonStyleData(
                height: 48,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 48,
                padding: EdgeInsets.only(left: 14, right: 14),
              ),
              onChanged: (value) {
                setState(() => _type = value ?? 0);
              },
            ),
          ),
          const Gap(8),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              isDense: true,
              border: const OutlineInputBorder(),
              labelText: 'fieldContactContent'.tr(),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const Gap(8),
          Card(
            margin: EdgeInsets.zero,
            child: CheckboxListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              title: Text('accountContactMethodsPublic').tr(),
              subtitle: Text('accountContactMethodsPublicHint').tr(),
              secondary: const Icon(Symbols.globe),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value ?? false);
              },
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isBusy
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text('dialogDismiss').tr(),
        ),
        TextButton(
          onPressed: _isBusy
              ? null
              : () {
                  _saveContactMethod();
                },
          child: Text('dialogConfirm').tr(),
        ),
      ],
    );
  }
}
