// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publishers_form.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publishersManaged)
const publishersManagedProvider = PublishersManagedProvider._();

final class PublishersManagedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisher>>,
          List<SnPublisher>,
          FutureOr<List<SnPublisher>>
        >
    with
        $FutureModifier<List<SnPublisher>>,
        $FutureProvider<List<SnPublisher>> {
  const PublishersManagedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publishersManagedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publishersManagedHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPublisher>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisher>> create(Ref ref) {
    return publishersManaged(ref);
  }
}

String _$publishersManagedHash() => r'ea83759fed9bd5119738b4d09f12b4476959e0a3';

@ProviderFor(publisher)
const publisherProvider = PublisherFamily._();

final class PublisherProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisher?>,
          SnPublisher?,
          FutureOr<SnPublisher?>
        >
    with $FutureModifier<SnPublisher?>, $FutureProvider<SnPublisher?> {
  const PublisherProvider._({
    required PublisherFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherHash();

  @override
  String toString() {
    return r'publisherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisher?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisher?> create(Ref ref) {
    final argument = this.argument as String?;
    return publisher(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherHash() => r'18fb5c6b3d79dd8af4fbee108dec1a0e8a034038';

final class PublisherFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisher?>, String?> {
  const PublisherFamily._()
    : super(
        retry: null,
        name: r'publisherProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherProvider call(String? identifier) =>
      PublisherProvider._(argument: identifier, from: this);

  @override
  String toString() => r'publisherProvider';
}
