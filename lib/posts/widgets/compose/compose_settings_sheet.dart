import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/posts/post_collections_manage.dart';
import 'package:island/posts/pods/post_categories.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/typeahead_enter_handler.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ComposeSettingsSheet extends HookConsumerWidget {
  final ComposeState state;

  const ComposeSettingsSheet({super.key, required this.state});

  Future<List<SnPostTag>> _fetchTagSuggestions(
    String query,
    WidgetRef ref,
  ) async {
    if (query.isEmpty) return [];

    try {
      final client = ref.read(solarNetworkClientProvider);
      // Note: No typed API for tag search
      // We fall back to raw Dio call
      final response = await client.dio.get(
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
    // Listen to visibility changes to trigger rebuilds
    final currentVisibility = useValueListenable(state.visibility);
    final currentLanguage = useValueListenable(state.language);
    final currentCategories = useValueListenable(state.categories);
    final currentTags = useValueListenable(state.tags);
    final currentRealm = useValueListenable(state.realm);
    final currentCollectionIds = useValueListenable(state.collectionIds);
    final postCategories = ref.watch(postCategoriesProvider);
    final userRealms = ref.watch(realmsJoinedProvider);
    final publisherName = state.currentPublisher.value?.name;
    final isIndividualPublisher = state.currentPublisher.value?.type == 0;
    final publisherCollections =
        publisherName != null && publisherName.isNotEmpty
        ? ref.watch(publisherCollectionsProvider(publisherName))
        : null;

    final languages = [
      (code: null, name: 'languageAuto'.tr()),
      (code: 'en', name: 'languageEN'.tr()),
      (code: 'zh', name: 'languageCN'.tr()),
      (code: 'ja', name: 'languageJA'.tr()),
      (code: 'ko', name: 'languageKO'.tr()),
      (code: 'es', name: 'languageES'.tr()),
      (code: 'fr', name: 'languageFR'.tr()),
      (code: 'de', name: 'languageDE'.tr()),
      (code: 'ru', name: 'languageRU'.tr()),
      (code: 'pt', name: 'languagePT'.tr()),
    ];

    String getLanguageDisplayName(String? code) {
      if (code == null) return 'Auto'.tr();
      final lang = languages.firstWhere(
        (l) => l.code == code,
        orElse: () => (code: code, name: code),
      );
      return lang.name;
    }

    final tagInputController = useTextEditingController();
    final tagSuggestionsController = useMemoized(
      () => SuggestionsController<SnPostTag>(),
      [],
    );

    return SheetScaffold(
      heightFactor: 0.6,
      showHeader: false,
      child: SingleChildScrollView(
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
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
                    suggestionsController: tagSuggestionsController,
                    builder: (context, controller, focusNode) {
                      return TypeAheadEnterHandler<SnPostTag>(
                        suggestionsController: tagSuggestionsController,
                        onEnter: () {
                          final value = controller.text;
                          state.tags.value = [...state.tags.value, value];
                          controller.clear();
                        },
                        child: TextField(
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
                        ),
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
                        state.tags.value = [
                          ...state.tags.value,
                          suggestion.slug,
                        ];
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
                return DropdownItem(
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
                                  item.categoryTranslationKey.tr(),
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
              valueListenable: ValueNotifier(
                currentCategories.isEmpty ? null : currentCategories.last,
              ),
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
                              category.categoryTranslationKey.tr(),
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
              buttonStyleData: const FormFieldButtonStyleData(
                padding: EdgeInsets.only(left: 16, right: 8),
                height: 38,
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.zero,
              ),
            ),

            // Collections field
            if (publisherCollections != null && publisherCollections.hasValue)
              DropdownButtonFormField2<SnPostCollection>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: Text('collections'.tr(), style: TextStyle(fontSize: 15)),
                items: (publisherCollections.value ?? <SnPostCollection>[]).map(
                  (item) {
                    return DropdownItem(
                      value: item,
                      enabled: false,
                      child: StatefulBuilder(
                        builder: (context, menuSetState) {
                          final isSelected = currentCollectionIds.contains(
                            item.id,
                          );
                          return InkWell(
                            onTap: () {
                              isSelected
                                  ? state.collectionIds.value = state
                                        .collectionIds
                                        .value
                                        .where((e) => e != item.id)
                                        .toList()
                                  : state.collectionIds.value = [
                                      ...state.collectionIds.value,
                                      item.id,
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
                                      item.name?.isNotEmpty == true
                                          ? item.name!
                                          : item.slug,
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
                  },
                ).toList(),
                valueListenable: ValueNotifier(
                  currentCollectionIds.isEmpty
                      ? null
                      : (publisherCollections.value ?? []).firstWhere(
                          (c) => c.id == currentCollectionIds.last,
                          orElse: () =>
                              (publisherCollections.value ?? []).first,
                        ),
                ),
                onChanged: (_) {},
                selectedItemBuilder: (context) {
                  final collections = publisherCollections.value ?? [];
                  return collections.map((item) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final id in currentCollectionIds)
                            Builder(
                              builder: (context) {
                                final collection = collections.firstWhere(
                                  (c) => c.id == id,
                                  orElse: () => item,
                                );
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    collection.name?.isNotEmpty == true
                                        ? collection.name!
                                        : collection.slug,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                buttonStyleData: const FormFieldButtonStyleData(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  height: 38,
                ),
                menuItemStyleData: const MenuItemStyleData(
                  padding: EdgeInsets.zero,
                ),
              ),

            // Language selection
            DropdownButtonFormField2<String?>(
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              hint: Text('language'.tr(), style: const TextStyle(fontSize: 15)),
              items: languages.map((lang) {
                return DropdownItem<String?>(
                  value: lang.code,
                  child: Text(lang.name).padding(left: 16, right: 8),
                );
              }).toList(),
              valueListenable: ValueNotifier(currentLanguage),
              onChanged: (value) {
                state.language.value = value;
              },
              selectedItemBuilder: (context) {
                return languages.map((lang) {
                  return Text(getLanguageDisplayName(lang.code));
                }).toList();
              },
              buttonStyleData: const FormFieldButtonStyleData(
                padding: EdgeInsets.only(left: 16, right: 8),
                height: 40,
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.zero,
              ),
            ),

            // Language selection            // Realm selection
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
                DropdownItem<SnRealm?>(
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
                    !(userRealms.value ?? []).any(
                      (r) => r.id == currentRealm.id,
                    ))
                  DropdownItem<SnRealm?>(
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
                    (realm) => DropdownItem<SnRealm?>(
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
              valueListenable: ValueNotifier(currentRealm),
              onChanged: (value) {
                state.realm.value = value;
              },
              selectedItemBuilder: (context) {
                final items = <Widget>[];
                items.add(
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Symbols.link_off, fill: 1),
                      ),
                      const SizedBox(width: 12),
                      Text('postUnlinkRealm'.tr()),
                    ],
                  ),
                );
                if (currentRealm != null &&
                    !(userRealms.value ?? []).any(
                      (r) => r.id == currentRealm.id,
                    )) {
                  items.add(
                    Row(
                      children: [
                        ProfilePictureWidget(
                          file: currentRealm.picture,
                          fallbackIcon: Symbols.workspaces,
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(currentRealm.name),
                      ],
                    ),
                  );
                }
                items.addAll(
                  (userRealms.value ?? []).map((realm) {
                    return Row(
                      children: [
                        ProfilePictureWidget(
                          file: realm.picture,
                          fallbackIcon: Symbols.workspaces,
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Text(realm.name),
                      ],
                    );
                  }),
                );
                return items;
              },
              buttonStyleData: const FormFieldButtonStyleData(
                padding: EdgeInsets.only(left: 16, right: 8),
                height: 40,
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.zero,
              ),
            ),

            DropdownButtonFormField2<int>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'postVisibility'.tr(),
                contentPadding: const EdgeInsets.symmetric(vertical: 9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items:
                  [
                    (
                      value: 0,
                      icon: Symbols.public,
                      title: 'postVisibilityPublic',
                      description: 'postVisibilityPublicDescription',
                      requiresIndividual: false,
                    ),
                    (
                      value: 1,
                      icon: Symbols.group,
                      title: 'postVisibilityFriends',
                      description: 'postVisibilityFriendsDescription',
                      requiresIndividual: true,
                    ),
                    (
                      value: 2,
                      icon: Symbols.link_off,
                      title: 'postVisibilityUnlisted',
                      description: 'postVisibilityUnlistedDescription',
                      requiresIndividual: false,
                    ),
                    (
                      value: 3,
                      icon: Symbols.lock,
                      title: 'postVisibilityPrivate',
                      description: 'postVisibilityPrivateDescription',
                      requiresIndividual: false,
                    ),
                    (
                      value: 4,
                      icon: Symbols.favorite,
                      title: 'postVisibilityCloseFriends',
                      description: 'postVisibilityCloseFriendsDescription',
                      requiresIndividual: true,
                    ),
                    (
                      value: 5,
                      icon: Symbols.public,
                      title: 'postVisibilityQuitePublic',
                      description: 'postVisibilityQuitePublicDescription',
                      requiresIndividual: false,
                    ),
                  ].map((option) {
                    final enabled =
                        !option.requiresIndividual || isIndividualPublisher;
                    return DropdownItem<int>(
                      height: 66,
                      value: option.value,
                      enabled: enabled,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            option.icon,
                            color: enabled
                                ? null
                                : Theme.of(context).disabledColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  option.title.tr(),
                                  style: TextStyle(
                                    color: enabled
                                        ? null
                                        : Theme.of(context).disabledColor,
                                  ),
                                ),
                                Text(
                                  option.description.tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: enabled
                                        ? Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color
                                        : Theme.of(context).disabledColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).padding(horizontal: 16, vertical: 12),
                    );
                  }).toList(),
              valueListenable: ValueNotifier(currentVisibility),
              onChanged: (value) {
                if (value != null) {
                  state.visibility.value = value;
                }
              },
              selectedItemBuilder: (context) {
                return [
                  (icon: Symbols.public, title: 'postVisibilityPublic'),
                  (icon: Symbols.group, title: 'postVisibilityFriends'),
                  (icon: Symbols.link_off, title: 'postVisibilityUnlisted'),
                  (icon: Symbols.lock, title: 'postVisibilityPrivate'),
                  (icon: Symbols.favorite, title: 'postVisibilityCloseFriends'),
                  (icon: Symbols.public, title: 'postVisibilityQuitePublic'),
                ].map((option) {
                  return Row(
                    children: [
                      Icon(option.icon),
                      const SizedBox(width: 12),
                      Flexible(child: Text(option.title.tr())),
                    ],
                  );
                }).toList();
              },
              buttonStyleData: const FormFieldButtonStyleData(
                padding: EdgeInsets.only(left: 16, right: 8),
                height: 40,
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
