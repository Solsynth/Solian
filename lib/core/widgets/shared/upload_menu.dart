import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class UploadMenuItemData {
  final IconData icon;
  final String textKey;
  final VoidCallback onPressed;

  const UploadMenuItemData(this.icon, this.textKey, this.onPressed);
}

class UploadMenu extends StatelessWidget {
  final List<UploadMenuItemData> items;
  final bool isCompact;
  final Color? iconColor;

  const UploadMenu({
    super.key,
    required this.items,
    this.isCompact = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      builder:
          (context, controller, child) => IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            tooltip: 'uploadFile'.tr(),
            icon: const Icon(Symbols.file_upload),
            color: iconColor ?? colorScheme.primary,
            visualDensity:
                isCompact
                    ? const VisualDensity(horizontal: -4, vertical: -2)
                    : null,
          ),
      menuChildren:
          items
              .map(
                (item) => MenuItemButton(
                  onPressed: item.onPressed,
                  leadingIcon: Icon(item.icon),
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.only(left: 12, right: 16, top: 20, bottom: 20),
                    ),
                  ),
                  child: Text(item.textKey.tr()),
                ),
              )
              .toList(),
    );
  }
}
