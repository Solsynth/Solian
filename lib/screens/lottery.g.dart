// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lotteryTicketsHash() => r'dd17cd721fc3b176ffa0ee0a85d0d850740e5e80';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [lotteryTickets].
@ProviderFor(lotteryTickets)
const lotteryTicketsProvider = LotteryTicketsFamily();

/// See also [lotteryTickets].
class LotteryTicketsFamily extends Family<AsyncValue<List<SnLotteryTicket>>> {
  /// See also [lotteryTickets].
  const LotteryTicketsFamily();

  /// See also [lotteryTickets].
  LotteryTicketsProvider call({int offset = 0, int take = 20}) {
    return LotteryTicketsProvider(offset: offset, take: take);
  }

  @override
  LotteryTicketsProvider getProviderOverride(
    covariant LotteryTicketsProvider provider,
  ) {
    return call(offset: provider.offset, take: provider.take);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lotteryTicketsProvider';
}

/// See also [lotteryTickets].
class LotteryTicketsProvider
    extends AutoDisposeFutureProvider<List<SnLotteryTicket>> {
  /// See also [lotteryTickets].
  LotteryTicketsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => lotteryTickets(
          ref as LotteryTicketsRef,
          offset: offset,
          take: take,
        ),
        from: lotteryTicketsProvider,
        name: r'lotteryTicketsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$lotteryTicketsHash,
        dependencies: LotteryTicketsFamily._dependencies,
        allTransitiveDependencies:
            LotteryTicketsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  LotteryTicketsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offset,
    required this.take,
  }) : super.internal();

  final int offset;
  final int take;

  @override
  Override overrideWith(
    FutureOr<List<SnLotteryTicket>> Function(LotteryTicketsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LotteryTicketsProvider._internal(
        (ref) => create(ref as LotteryTicketsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offset: offset,
        take: take,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnLotteryTicket>> createElement() {
    return _LotteryTicketsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LotteryTicketsProvider &&
        other.offset == offset &&
        other.take == take;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);
    hash = _SystemHash.combine(hash, take.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LotteryTicketsRef on AutoDisposeFutureProviderRef<List<SnLotteryTicket>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _LotteryTicketsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnLotteryTicket>>
    with LotteryTicketsRef {
  _LotteryTicketsProviderElement(super.provider);

  @override
  int get offset => (origin as LotteryTicketsProvider).offset;
  @override
  int get take => (origin as LotteryTicketsProvider).take;
}

String _$lotteryRecordsHash() => r'55c657460f18d9777741d09013b445ca036863f3';

/// See also [lotteryRecords].
@ProviderFor(lotteryRecords)
const lotteryRecordsProvider = LotteryRecordsFamily();

/// See also [lotteryRecords].
class LotteryRecordsFamily extends Family<AsyncValue<List<SnLotteryRecord>>> {
  /// See also [lotteryRecords].
  const LotteryRecordsFamily();

  /// See also [lotteryRecords].
  LotteryRecordsProvider call({int offset = 0, int take = 20}) {
    return LotteryRecordsProvider(offset: offset, take: take);
  }

  @override
  LotteryRecordsProvider getProviderOverride(
    covariant LotteryRecordsProvider provider,
  ) {
    return call(offset: provider.offset, take: provider.take);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lotteryRecordsProvider';
}

/// See also [lotteryRecords].
class LotteryRecordsProvider
    extends AutoDisposeFutureProvider<List<SnLotteryRecord>> {
  /// See also [lotteryRecords].
  LotteryRecordsProvider({int offset = 0, int take = 20})
    : this._internal(
        (ref) => lotteryRecords(
          ref as LotteryRecordsRef,
          offset: offset,
          take: take,
        ),
        from: lotteryRecordsProvider,
        name: r'lotteryRecordsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$lotteryRecordsHash,
        dependencies: LotteryRecordsFamily._dependencies,
        allTransitiveDependencies:
            LotteryRecordsFamily._allTransitiveDependencies,
        offset: offset,
        take: take,
      );

  LotteryRecordsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offset,
    required this.take,
  }) : super.internal();

  final int offset;
  final int take;

  @override
  Override overrideWith(
    FutureOr<List<SnLotteryRecord>> Function(LotteryRecordsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LotteryRecordsProvider._internal(
        (ref) => create(ref as LotteryRecordsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offset: offset,
        take: take,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SnLotteryRecord>> createElement() {
    return _LotteryRecordsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LotteryRecordsProvider &&
        other.offset == offset &&
        other.take == take;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);
    hash = _SystemHash.combine(hash, take.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LotteryRecordsRef on AutoDisposeFutureProviderRef<List<SnLotteryRecord>> {
  /// The parameter `offset` of this provider.
  int get offset;

  /// The parameter `take` of this provider.
  int get take;
}

class _LotteryRecordsProviderElement
    extends AutoDisposeFutureProviderElement<List<SnLotteryRecord>>
    with LotteryRecordsRef {
  _LotteryRecordsProviderElement(super.provider);

  @override
  int get offset => (origin as LotteryRecordsProvider).offset;
  @override
  int get take => (origin as LotteryRecordsProvider).take;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
