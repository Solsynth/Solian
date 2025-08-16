import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/models/realm.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';

class RealmSelectionDropdown extends StatelessWidget {
  final SnRealm? value;
  final List<SnRealm> realms;
  final ValueChanged<SnRealm?> onChanged;
  final bool isLoading;
  final String? error;

  const RealmSelectionDropdown({
    super.key,
    required this.value,
    required this.realms,
    required this.onChanged,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<SnRealm?>(
        isExpanded: true,
        hint: Text('realmSelection').tr(),
        value: value,
        items: [
          DropdownMenuItem<SnRealm?>(
            value: null,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  child: Icon(Symbols.person, fill: 1),
                ),
                const SizedBox(width: 12),
                Text('individual').tr(),
              ],
            ),
          ),
          if (!isLoading && error == null)
            ...realms.map(
              (realm) => DropdownMenuItem<SnRealm?>(
                value: realm,
                child: Row(
                  children: [
                    ProfilePictureWidget(
                      fileId: realm.picture?.id,
                      fallbackIcon: Symbols.workspaces,
                      radius: 16,
                    ),
                    const SizedBox(width: 12),
                    Text(realm.name),
                  ],
                ),
              ),
            ),
        ],
        onChanged: onChanged,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(left: 4, right: 16),
        ),
      ),
    );
  }
}
