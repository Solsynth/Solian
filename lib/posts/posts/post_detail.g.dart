// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(post)
final postProvider = PostFamily._();

final class PostProvider
    extends $FunctionalProvider<AsyncValue<SnPost?>, SnPost?, FutureOr<SnPost?>>
    with $FutureModifier<SnPost?>, $FutureProvider<SnPost?> {
  PostProvider._({
    required PostFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postHash();

  @override
  String toString() {
    return r'postProvider'
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
    return post(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postHash() => r'66c2eb074c6d7467fef81cab70a13356e648e661';

final class PostFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPost?>, String> {
  PostFamily._()
    : super(
        retry: null,
        name: r'postProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostProvider call(String id) => PostProvider._(argument: id, from: this);

  @override
  String toString() => r'postProvider';
}
