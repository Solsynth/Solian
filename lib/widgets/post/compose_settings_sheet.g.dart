// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_settings_sheet.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postCategories)
const postCategoriesProvider = PostCategoriesProvider._();

final class PostCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPostCategory>>,
          List<SnPostCategory>,
          FutureOr<List<SnPostCategory>>
        >
    with
        $FutureModifier<List<SnPostCategory>>,
        $FutureProvider<List<SnPostCategory>> {
  const PostCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postCategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPostCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPostCategory>> create(Ref ref) {
    return postCategories(ref);
  }
}

String _$postCategoriesHash() => r'8799c10eb91cf8c8c7ea72eff3475e1eaa7b9a2b';
