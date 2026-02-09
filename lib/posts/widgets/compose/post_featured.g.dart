// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_featured.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(featuredPosts)
final featuredPostsProvider = FeaturedPostsProvider._();

final class FeaturedPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPost>>,
          List<SnPost>,
          FutureOr<List<SnPost>>
        >
    with $FutureModifier<List<SnPost>>, $FutureProvider<List<SnPost>> {
  FeaturedPostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredPostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredPostsHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPost>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPost>> create(Ref ref) {
    return featuredPosts(ref);
  }
}

String _$featuredPostsHash() => r'4b7fffb02eac72f5861b02af1b1e5da36b571698';
