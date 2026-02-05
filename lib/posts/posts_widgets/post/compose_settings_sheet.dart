import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/posts/post/post_categories.dart';
import 'package:island/posts/posts_models/post_category.dart';
import 'package:island/posts/posts_models/post_tag.dart';
import 'package:island/posts/posts_widgets/post/compose_shared.dart';
import 'package:island/realms/realm/realms.dart';
import 'package:island/realms/realms_models/realm.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:island/core/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ComposeSettingsSheet extends HookConsumerWidget {
  final ComposeState state;

  const ComposeSettingsSheet({super.key, required this.state});

  Future<List<SnPostTag>> _fetchTagSuggestions(
    String query,
    WidgetRef ref,
  ) async {
    if (query.isEmpty) return [];

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get(
        '/sphere/posts/tags',
        queryParameters: {'query': query},
      );
      return response.data
          .map<SnPostTag>((json) => SnPostTag.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to visibility changes to trigger rebuilds
    final currentVisibility = useValueListenable(state.visibility);
    final currentCategories = useValueListenable(state.categories);
    final currentTags = useValueListenable(state.tags);
    final currentRealm = useValueListenable(state.realm);
    final postCategories = ref.watch(postCategoriesProvider);
    final userRealms = ref.watch(realmsJoinedProvider);

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
        builder: (context) => SheetScaffold(
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

    final tagInputController = useTextEditingController();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          // Slug field
          TextField(
            controller: state.slugController,
            decoration: InputDecoration(
              labelText: 'postSlug'.tr(),
              hintText: 'postSlugHint'.tr(),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 9,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),

          // Tags field
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Text(
                  'tags'.tr(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                // Existing tags display
                if (currentTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentTags.map((tag) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#$tag',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 14,
                              ),
                            ),
                            const Gap(4),
                            InkWell(
                              onTap: () {
                                final newTags = List<String>.from(
                                  state.tags.value,
                                )..remove(tag);
                                state.tags.value = newTags;
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                // Tag input with autocomplete
                TypeAheadField<SnPostTag>(
                  controller: tagInputController,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'addTag'.tr(),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (value) {
                        state.tags.value = [...state.tags.value, value];
                        controller.clear();
                      },
                    );
                  },
                  suggestionsCallback: (pattern) =>
                      _fetchTagSuggestions(pattern, ref),
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      title: Text('#${suggestion.slug}'),
                      subtitle: Text('${suggestion.usage} posts'),
                      dense: true,
                    );
                  },
                  onSelected: (suggestion) {
                    if (!state.tags.value.contains(suggestion.slug)) {
                      state.tags.value = [...state.tags.value, suggestion.slug];
                    }
                    tagInputController.clear();
                  },
                  direction: VerticalDirection.down,
                  hideOnEmpty: true,
                  hideOnLoading: true,
                  debounceDuration: const Duration(milliseconds: 300),
                ),
              ],
            ),
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
            items: (postCategories.value?.items ?? <SnPostCategory>[]).map((
              item,
            ) {
              return DropdownMenuItem(
                value: item,
                enabled: false,
                child: StatefulBuilder(
                  builder: (context, menuSetState) {
                    final isSelected = state.categories.value.contains(item);
                    return InkWell(
                      onTap: () {
                        isSelected
                            ? state.categories.value = state.categories.value
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              return (postCategories.value?.items ?? []).map((item) {
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
              height: 38,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 38,
              padding: EdgeInsets.zero,
            ),
          ),

          // Realm selection
          DropdownButtonFormField2<SnRealm?>(
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            hint: Text('realm'.tr(), style: const TextStyle(fontSize: 15)),
            items: [
              DropdownMenuItem<SnRealm?>(
                value: null,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      child: Icon(Symbols.link_off, fill: 1),
                    ),
                    const SizedBox(width: 12),
                    Text('postUnlinkRealm').tr(),
                  ],
                ).padding(left: 16, right: 8),
              ),
              // Include current realm if it's not null and not in joined realms
              if (currentRealm != null &&
                  !(userRealms.value ?? []).any((r) => r.id == currentRealm.id))
                DropdownMenuItem<SnRealm?>(
                  value: currentRealm,
                  child: Row(
                    children: [
                      ProfilePictureWidget(
                        file: currentRealm.picture,
                        fallbackIcon: Symbols.workspaces,
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Text(currentRealm.name),
                    ],
                  ).padding(left: 16, right: 8),
                ),
              if (userRealms.hasValue)
                ...(userRealms.value ?? []).map(
                  (realm) => DropdownMenuItem<SnRealm?>(
                    value: realm,
                    child: Row(
                      children: [
                        ProfilePictureWidget(
                          file: realm.picture,
                          fallbackIcon: Symbols.workspaces,
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(realm.name),
                      ],
                    ).padding(left: 16, right: 8),
                  ),
                ),
            ],
            value: currentRealm,
            onChanged: (value) {
              state.realm.value = value;
            },
            selectedItemBuilder: (context) {
              return (userRealms.value ?? []).map((_) {
                return Row(
                  children: [
                    if (currentRealm == null)
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Symbols.link_off, fill: 1),
                      )
                    else
                      ProfilePictureWidget(
                        file: currentRealm.picture,
                        fallbackIcon: Symbols.workspaces,
                        radius: 16,
                      ),
                    const SizedBox(width: 12),
                    Text(currentRealm?.name ?? 'postUnlinkRealm'.tr()),
                  ],
                );
              }).toList();
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(left: 16, right: 8),
              height: 40,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 56,
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
    );
  }
}
