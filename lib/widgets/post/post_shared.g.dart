// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_shared.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(postFeaturedReply)
const postFeaturedReplyProvider = PostFeaturedReplyFamily._();

final class PostFeaturedReplyProvider
    extends $FunctionalProvider<AsyncValue<SnPost?>, SnPost?, FutureOr<SnPost?>>
    with $FutureModifier<SnPost?>, $FutureProvider<SnPost?> {
  const PostFeaturedReplyProvider._({
    required PostFeaturedReplyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postFeaturedReplyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postFeaturedReplyHash();

  @override
  String toString() {
    return r'postFeaturedReplyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPost?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnPost?> create(Ref ref) {
    final argument = this.argument as String;
    return postFeaturedReply(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostFeaturedReplyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postFeaturedReplyHash() => r'3f0ac0d51ad21f8754a63dd94109eb8ac4812293';

final class PostFeaturedReplyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPost?>, String> {
  const PostFeaturedReplyFamily._()
    : super(
        retry: null,
        name: r'postFeaturedReplyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostFeaturedReplyProvider call(String id) =>
      PostFeaturedReplyProvider._(argument: id, from: this);

  @override
  String toString() => r'postFeaturedReplyProvider';
}
