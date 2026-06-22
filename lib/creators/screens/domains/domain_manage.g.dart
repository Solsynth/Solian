// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'domain_manage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publisherDomains)
final publisherDomainsProvider = PublisherDomainsFamily._();

final class PublisherDomainsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisherVerifiedDomain>>,
          List<SnPublisherVerifiedDomain>,
          FutureOr<List<SnPublisherVerifiedDomain>>
        >
    with
        $FutureModifier<List<SnPublisherVerifiedDomain>>,
        $FutureProvider<List<SnPublisherVerifiedDomain>> {
  PublisherDomainsProvider._({
    required PublisherDomainsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherDomainsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherDomainsHash();

  @override
  String toString() {
    return r'publisherDomainsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnPublisherVerifiedDomain>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisherVerifiedDomain>> create(Ref ref) {
    final argument = this.argument as String;
    return publisherDomains(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherDomainsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherDomainsHash() => r'1d90b5bb703377e0571e601f5de3e9c32dd2531f';

final class PublisherDomainsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnPublisherVerifiedDomain>>,
          String
        > {
  PublisherDomainsFamily._()
    : super(
        retry: null,
        name: r'publisherDomainsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherDomainsProvider call(String publisherName) =>
      PublisherDomainsProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherDomainsProvider';
}
