import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:textfield_tags/textfield_tags.dart';

/// A reusable widget for tag input fields with chip display
class ChipTagInputField extends StatelessWidget {
  final InputFieldValues inputFieldValues;
  final String labelText;
  final String hintText;

  const ChipTagInputField({
    super.key,
    required this.inputFieldValues,
    required this.labelText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: inputFieldValues.textEditingController,
      focusNode: inputFieldValues.focusNode,
      decoration: InputDecoration(
        label: Text(labelText).tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        hintText: inputFieldValues.tags.isNotEmpty ? '' : hintText.tr(),
        errorText: inputFieldValues.error,
        prefixIconConstraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        prefixIcon:
            inputFieldValues.tags.isNotEmpty
                ? SingleChildScrollView(
                  controller: inputFieldValues.tagScrollController,
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                    child: Wrap(
                      runSpacing: 4.0,
                      spacing: 4.0,
                      children:
                          inputFieldValues.tags.map<Widget>((dynamic tag) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              margin: const EdgeInsets.only(left: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    child: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                  const Gap(4),
                                  InkWell(
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 14.0,
                                      color: Color.fromARGB(255, 233, 233, 233),
                                    ),
                                    onTap: () {
                                      inputFieldValues.onTagRemoved(tag);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                )
                : null,
      ),
      onChanged: inputFieldValues.onTagChanged,
      onSubmitted: inputFieldValues.onTagSubmitted,
    );
  }
}

class ComposeSettingsSheet extends HookWidget {
  final ValueNotifier<int> visibility;
  final VoidCallback? onVisibilityChanged;
  final StringTagController tagsController;
  final StringTagController categoriesController;

  const ComposeSettingsSheet({
    super.key,
    required this.visibility,
    this.onVisibilityChanged,
    required this.tagsController,
    required this.categoriesController,
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
          spacing: 16,
          children: [
            // Tags field
            TextFieldTags(
              textfieldTagsController: tagsController,
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                if (tag.isEmpty) {
                  return 'No, cannot be empty';
                }
                return null;
              },
              inputFieldBuilder: (context, inputFieldValues) {
                return ChipTagInputField(
                  inputFieldValues: inputFieldValues,
                  labelText: 'tags',
                  hintText: 'tagsHint',
                );
              },
            ),

            // Categories field
            TextFieldTags(
              textfieldTagsController: categoriesController,
              textSeparators: const [' ', ','],
              letterCase: LetterCase.small,
              validator: (String tag) {
                if (tag.isEmpty) return 'No, cannot be empty';
                if (tag.contains(' ')) return 'Tags should be URL-safe';
                return null;
              },
              inputFieldBuilder: (context, inputFieldValues) {
                return ChipTagInputField(
                  inputFieldValues: inputFieldValues,
                  labelText: 'categories',
                  hintText: 'categoriesHint',
                );
              },
            ),

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
