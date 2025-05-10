import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              minLeadingWidth: 48,
              title: Text('settingsDisplayLanguage').tr(),
              contentPadding: const EdgeInsets.only(left: 24, right: 17),
              leading: const Icon(Symbols.translate),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton2<Locale?>(
                  isExpanded: true,
                  items: [
                    ...EasyLocalization.of(
                      context,
                    )!.supportedLocales.mapIndexed((idx, ele) {
                      return DropdownMenuItem<Locale?>(
                        value: ele,
                        child: Text(
                          '${ele.languageCode}-${ele.countryCode}',
                        ).fontSize(14),
                      );
                    }),
                    DropdownMenuItem<Locale?>(
                      value: null,
                      child: Text('languageFollowSystem').tr().fontSize(14),
                    ),
                  ],
                  value: EasyLocalization.of(context)!.currentLocale,
                  onChanged: (Locale? value) {
                    if (value != null) {
                      EasyLocalization.of(context)!.setLocale(value);
                    } else {
                      EasyLocalization.of(context)!.resetLocale();
                    }
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    height: 40,
                    width: 160,
                  ),
                  menuItemStyleData: const MenuItemStyleData(height: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
