import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/providers/userinfo.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:intl/locale.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _setAccountLanguage(BuildContext context, Locale? value) async {
    if (value == null) return;
    try {
      final sn = context.read<SnNetworkProvider>();
      final ua = context.read<UserProvider>();
      await sn.client.put('/cgi/id/users/me/language', data: {
        'language': value.toString(),
      });
      if (!context.mounted) return;
      context.showSnackbar('accountSettingsApplied'.tr());
      await ua.refreshUser();
    } catch (err) {
      if (!context.mounted) return;
      context.showErrorDialog(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ua = context.watch<UserProvider>();

    return AppScaffold(
      noBackground: true,
      appBar: AppBar(
        leading: PageBackButton(),
        title: Text('screenAccountSettings').tr(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('settingsAccountLanguage').tr(),
              subtitle: Text('settingsAccountLanguageDescription').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.translate),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton2<Locale?>(
                  isExpanded: true,
                  items: [
                    ...EasyLocalization.of(context)!
                        .supportedLocales
                        .mapIndexed((idx, ele) {
                      return DropdownMenuItem<Locale?>(
                        value: Locale.parse(ele.toString()),
                        child: Text('${ele.languageCode}-${ele.countryCode}')
                            .fontSize(14),
                      );
                    }),
                  ],
                  value: ua.user?.language != null
                      ? (Locale.tryParse(ua.user!.language) ??
                          Locale.parse('en-US'))
                      : Locale.parse('en-US'),
                  onChanged: (Locale? value) {
                    if (value == null) return;
                    _setAccountLanguage(context, value);
                    ua.setLanguage(value.toString());
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 5,
                    ),
                    height: 40,
                    width: 160,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text('accountContactMethods').tr(),
              subtitle: Text('accountContactMethodsDescription').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.contacts),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed('accountContactMethods');
              },
            ),
            ListTile(
              title: Text('accountSettingsNotify').tr(),
              subtitle: Text('accountSettingsNotifyDescription').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.notifications),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed('accountSettingsNotify');
              },
            ),
            ListTile(
              title: Text('accountSettingsSecurity').tr(),
              subtitle: Text('accountSettingsSecurityDescription').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.shield),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed('accountSettingsSecurity');
              },
            ),
            ListTile(
              title: Text('factorSettings').tr(),
              subtitle: Text('factorSettingsSubtitle').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.lock),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed('factorSettings');
              },
            ),
            ListTile(
              title: Text('accountProfileEdit').tr(),
              subtitle: Text('accountProfileEditSubtitle').tr(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.contact_page),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                GoRouter.of(context).pushNamed('accountProfileEdit');
              },
            ),
            ListTile(
              title: Text('accountDeletion'.tr()),
              subtitle: Text('accountDeletionActionDescription'.tr()),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: const Icon(Symbols.person_cancel),
              trailing: const Icon(Symbols.chevron_right),
              onTap: () {
                context
                    .showConfirmDialog(
                  'accountDeletion'.tr(),
                  'accountDeletionDescription'.tr(),
                )
                    .then((value) {
                  if (!value || !context.mounted) return;
                  final sn = context.read<SnNetworkProvider>();
                  sn.client.post('/cgi/id/users/me/deletion').then((value) {
                    if (context.mounted) {
                      context.showSnackbar('accountDeletionSubmitted'.tr());
                    }
                  }).catchError((err) {
                    if (context.mounted) {
                      context.showErrorDialog(err);
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
