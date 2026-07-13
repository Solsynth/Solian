// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postCategory)
final postCategoryProvider = PostCategoryFamily._();

final class PostCategoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPostCategory>,
          SnPostCategory,
          FutureOr<SnPostCategory>
        >
    with $FutureModifier<SnPostCategory>, $FutureProvider<SnPostCategory> {
  PostCategoryProvider._({
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

String _$postCategoryHash() => r'e7e69d5fcae11f276d027b766b7edbe334e6543f';

final class PostCategoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPostCategory>, String> {
  PostCategoryFamily._()
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
final postTagProvider = PostTagFamily._();

final class PostTagProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPostTag>,
          SnPostTag,
          FutureOr<SnPostTag>
        >
    with $FutureModifier<SnPostTag>, $FutureProvider<SnPostTag> {
  PostTagProvider._({
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

String _$postTagHash() => r'fa337421ae0326806dbd75e89fd2385b8ce7895c';

final class PostTagFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPostTag>, String> {
  PostTagFamily._()
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

@ProviderFor(postCategorySubscription)
final postCategorySubscriptionProvider = PostCategorySubscriptionFamily._();

final class PostCategorySubscriptionProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnCategorySubscription?>,
          SnCategorySubscription?,
          FutureOr<SnCategorySubscription?>
        >
    with
        $FutureModifier<SnCategorySubscription?>,
        $FutureProvider<SnCategorySubscription?> {
  PostCategorySubscriptionProvider._({
    required PostCategorySubscriptionFamily super.from,
    required (String, bool) super.argument,
  }) : super(
         retry: null,
         name: r'postCategorySubscriptionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCategorySubscriptionHash();

  @override
  String toString() {
    return r'postCategorySubscriptionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SnCategorySubscription?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnCategorySubscription?> create(Ref ref) {
    final argument = this.argument as (String, bool);
    return postCategorySubscription(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCategorySubscriptionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCategorySubscriptionHash() =>
    r'94a3d750093738b1dd74feac72f9d8b1abfa01f4';

final class PostCategorySubscriptionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnCategorySubscription?>,
          (String, bool)
        > {
  PostCategorySubscriptionFamily._()
    : super(
        retry: null,
        name: r'postCategorySubscriptionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostCategorySubscriptionProvider call(String slug, bool isCategory) =>
      PostCategorySubscriptionProvider._(
        argument: (slug, isCategory),
        from: this,
      );

  @override
  String toString() => r'postCategorySubscriptionProvider';
}
