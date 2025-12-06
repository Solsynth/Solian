// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postCategory)
const postCategoryProvider = PostCategoryFamily._();

final class PostCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPostCategory>,
          SnPostCategory,
          FutureOr<SnPostCategory>
        >
    with $FutureModifier<SnPostCategory>, $FutureProvider<SnPostCategory> {
  const PostCategoryProvider._({
    required PostCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCategoryHash();

  @override
  String toString() {
    return r'postCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPostCategory> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPostCategory> create(Ref ref) {
    final argument = this.argument as String;
    return postCategory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCategoryHash() => r'0df2de729ba96819ee37377314615abef0c99547';

final class PostCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPostCategory>, String> {
  const PostCategoryFamily._()
    : super(
        retry: null,
        name: r'postCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostCategoryProvider call(String slug) =>
      PostCategoryProvider._(argument: slug, from: this);

  @override
  String toString() => r'postCategoryProvider';
}

@ProviderFor(postTag)
const postTagProvider = PostTagFamily._();

final class PostTagProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPostTag>,
          SnPostTag,
          FutureOr<SnPostTag>
        >
    with $FutureModifier<SnPostTag>, $FutureProvider<SnPostTag> {
  const PostTagProvider._({
    required PostTagFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postTagProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postTagHash();

  @override
  String toString() {
    return r'postTagProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPostTag> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnPostTag> create(Ref ref) {
    final argument = this.argument as String;
    return postTag(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostTagProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postTagHash() => r'e050fdf9af81a843a9abd9cf979dd2672e0a2b93';

final class PostTagFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPostTag>, String> {
  const PostTagFamily._()
    : super(
        retry: null,
        name: r'postTagProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostTagProvider call(String slug) =>
      PostTagProvider._(argument: slug, from: this);

  @override
  String toString() => r'postTagProvider';
}

@ProviderFor(postCategorySubscriptionStatus)
const postCategorySubscriptionStatusProvider =
    PostCategorySubscriptionStatusFamily._();

final class PostCategorySubscriptionStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const PostCategorySubscriptionStatusProvider._({
    required PostCategorySubscriptionStatusFamily super.from,
    required (String, bool) super.argument,
  }) : super(
         retry: null,
         name: r'postCategorySubscriptionStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCategorySubscriptionStatusHash();

  @override
  String toString() {
    return r'postCategorySubscriptionStatusProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, bool);
    return postCategorySubscriptionStatus(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCategorySubscriptionStatusProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCategorySubscriptionStatusHash() =>
    r'407dc7fcaeffc461b591b4ee2418811aa4f0a63f';

final class PostCategorySubscriptionStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, bool)> {
  const PostCategorySubscriptionStatusFamily._()
    : super(
        retry: null,
        name: r'postCategorySubscriptionStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostCategorySubscriptionStatusProvider call(String slug, bool isCategory) =>
      PostCategorySubscriptionStatusProvider._(
        argument: (slug, isCategory),
        from: this,
      );

  @override
  String toString() => r'postCategorySubscriptionStatusProvider';
}
