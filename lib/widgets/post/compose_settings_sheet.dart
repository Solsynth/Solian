import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/post_category.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/widgets/post/compose_shared.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:textfield_tags/textfield_tags.dart';

part 'compose_settings_sheet.g.dart';

@riverpod
Future<List<SnPostCategory>> postCategories(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/posts/categories');
  return resp.data
      .map((e) => SnPostCategory.fromJson(e))
      .cast<SnPostCategory>()
      .toList();
}

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

class ComposeSettingsSheet extends HookConsumerWidget {
  final ComposeState state;

  const ComposeSettingsSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to visibility changes to trigger rebuilds
    final currentVisibility = useValueListenable(state.visibility);
    final currentCategories = useValueListenable(state.categories);
    final postCategories = ref.watch(postCategoriesProvider);

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
          state.visibility.value = value;
          Navigator.pop(context);
        },
        selected: state.visibility.value == value,
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
      heightFactor: 0.6,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            // Tags field
            TextFieldTags(
              textfieldTagsController: state.tagsController,
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
            DropdownButtonFormField2<SnPostCategory>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: Text('categories'.tr(), style: TextStyle(fontSize: 15)),
              items:
                  (postCategories.value ?? <SnPostCategory>[]).map((item) {
                    return DropdownMenuItem(
                      value: item,
                      enabled: false,
                      child: StatefulBuilder(
                        builder: (context, menuSetState) {
                          final isSelected = state.categories.value.contains(
                            item,
                          );
                          return InkWell(
                            onTap: () {
                              isSelected
                                  ? state.categories.value =
                                      state.categories.value
                                          .where((e) => e != item)
                                          .toList()
                                  : state.categories.value = [
                                    ...state.categories.value,
                                    item,
                                  ];
                              menuSetState(() {});
                            },
                            child: Container(
                              height: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Row(
                                children: [
                                  if (isSelected)
                                    const Icon(Icons.check_box_outlined)
                                  else
                                    const Icon(Icons.check_box_outline_blank),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      item.categoryDisplayTitle,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
              value: currentCategories.isEmpty ? null : currentCategories.last,
              onChanged: (_) {},
              selectedItemBuilder: (context) {
                return (postCategories.value ?? []).map((item) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in currentCategories)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                            child: Text(
                              category.categoryDisplayTitle,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList();
              },
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(left: 16, right: 8),
                height: 40,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.zero,
              ),
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
