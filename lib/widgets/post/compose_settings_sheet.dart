import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';

class ComposeSettingsSheet extends HookWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final ValueNotifier<int> visibility;
  final VoidCallback? onVisibilityChanged;

  const ComposeSettingsSheet({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.visibility,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to visibility changes to trigger rebuilds
    final currentVisibility = useValueListenable(visibility);

    IconData getVisibilityIcon(int visibilityValue) {
      switch (visibilityValue) {
        case 1:
          return Symbols.group;
        case 2:
          return Symbols.link_off;
        case 3:
          return Symbols.lock;
        default:
          return Symbols.public;
      }
    }

    String getVisibilityText(int visibilityValue) {
      switch (visibilityValue) {
        case 1:
          return 'postVisibilityFriends';
        case 2:
          return 'postVisibilityUnlisted';
        case 3:
          return 'postVisibilityPrivate';
        default:
          return 'postVisibilityPublic';
      }
    }

    Widget buildVisibilityOption(
      BuildContext context,
      int value,
      IconData icon,
      String textKey,
    ) {
      return ListTile(
        leading: Icon(icon),
        title: Text(textKey.tr()),
        onTap: () {
          visibility.value = value;
          onVisibilityChanged?.call();
          Navigator.pop(context);
        },
        selected: visibility.value == value,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      );
    }

    void showVisibilitySheet() {
      showModalBottomSheet(
        context: context,
        builder:
            (context) => SheetScaffold(
              titleText: 'postVisibility'.tr(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildVisibilityOption(
                    context,
                    0,
                    Symbols.public,
                    'postVisibilityPublic',
                  ),
                  buildVisibilityOption(
                    context,
                    1,
                    Symbols.group,
                    'postVisibilityFriends',
                  ),
                  buildVisibilityOption(
                    context,
                    2,
                    Symbols.link_off,
                    'postVisibilityUnlisted',
                  ),
                  buildVisibilityOption(
                    context,
                    3,
                    Symbols.lock,
                    'postVisibilityPrivate',
                  ),
                ],
              ),
            ),
      );
    }

    return SheetScaffold(
      titleText: 'postSettings'.tr(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'postTitle'.tr(),
                hintText: 'postTitle'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: theme.textTheme.titleMedium,
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(16),

            // Description field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'postDescription'.tr(),
                hintText: 'postDescription'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              onTapOutside:
                  (_) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const Gap(16),

            // Visibility setting
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(getVisibilityIcon(currentVisibility)),
                title: Text('postVisibility'.tr()),
                subtitle: Text(getVisibilityText(currentVisibility).tr()),
                trailing: const Icon(Symbols.chevron_right),
                onTap: showVisibilitySheet,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
