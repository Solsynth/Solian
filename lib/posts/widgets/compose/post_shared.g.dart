// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_shared.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RepliesNotifier)
final repliesProvider = RepliesNotifierFamily._();

final class RepliesNotifierProvider
    extends $NotifierProvider<RepliesNotifier, RepliesState> {
  RepliesNotifierProvider._({
    required RepliesNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'repliesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$repliesNotifierHash();

  @override
  String toString() {
    return r'repliesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RepliesNotifier create() => RepliesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RepliesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RepliesState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RepliesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$repliesNotifierHash() => r'd1385005e4a8e386adb2c20336fdb9ff5541d148';

final class RepliesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          RepliesNotifier,
          RepliesState,
          RepliesState,
          RepliesState,
          String
        > {
  RepliesNotifierFamily._()
    : super(
        retry: null,
        name: r'repliesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RepliesNotifierProvider call(String parentId) =>
      RepliesNotifierProvider._(argument: parentId, from: this);

  @override
  String toString() => r'repliesProvider';
}

abstract class _$RepliesNotifier extends $Notifier<RepliesState> {
  late final _$args = ref.$arg as String;
  String get parentId => _$args;

  RepliesState build(String parentId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RepliesState, RepliesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RepliesState, RepliesState>,
              RepliesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(postFeaturedReply)
final postFeaturedReplyProvider = PostFeaturedReplyFamily._();

final class PostFeaturedReplyProvider
    extends $FunctionalProvider<AsyncValue<SnPost?>, SnPost?, FutureOr<SnPost?>>
    with $FutureModifier<SnPost?>, $FutureProvider<SnPost?> {
  PostFeaturedReplyProvider._({
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
  PostFeaturedReplyFamily._()
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
