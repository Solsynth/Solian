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

@ProviderFor(publisherNullable)
const publisherNullableProvider = PublisherNullableFamily._();

final class PublisherNullableProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisher?>,
          SnPublisher?,
          FutureOr<SnPublisher?>
        >
    with $FutureModifier<SnPublisher?>, $FutureProvider<SnPublisher?> {
  const PublisherNullableProvider._({
    required PublisherNullableFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherNullableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherNullableHash();

  @override
  String toString() {
    return r'publisherNullableProvider'
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
    return publisherNullable(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherNullableProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherNullableHash() => r'49b28083a2f351c5e5cde0b1a97f6c7503969041';

final class PublisherNullableFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisher?>, String?> {
  const PublisherNullableFamily._()
    : super(
        retry: null,
        name: r'publisherNullableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherNullableProvider call(String? identifier) =>
      PublisherNullableProvider._(argument: identifier, from: this);

  @override
  String toString() => r'publisherNullableProvider';
}
