// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messagesNotifierHash() => r'639286fd8e4e0cfdef5be6cf5d80eea769007cb3';

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

abstract class _$MessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<LocalChatMessage>> {
  late final String roomId;

  FutureOr<List<LocalChatMessage>> build(String roomId);
}

/// See also [MessagesNotifier].
@ProviderFor(MessagesNotifier)
const messagesNotifierProvider = MessagesNotifierFamily();

/// See also [MessagesNotifier].
class MessagesNotifierFamily
    extends Family<AsyncValue<List<LocalChatMessage>>> {
  /// See also [MessagesNotifier].
  const MessagesNotifierFamily();

  /// See also [MessagesNotifier].
  MessagesNotifierProvider call(String roomId) {
    return MessagesNotifierProvider(roomId);
  }

  @override
  MessagesNotifierProvider getProviderOverride(
    covariant MessagesNotifierProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesNotifierProvider';
}

/// See also [MessagesNotifier].
class MessagesNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessagesNotifier,
          List<LocalChatMessage>
        > {
  /// See also [MessagesNotifier].
  MessagesNotifierProvider(String roomId)
    : this._internal(
        () => MessagesNotifier()..roomId = roomId,
        from: messagesNotifierProvider,
        name: r'messagesNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$messagesNotifierHash,
        dependencies: MessagesNotifierFamily._dependencies,
        allTransitiveDependencies:
            MessagesNotifierFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  MessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  FutureOr<List<LocalChatMessage>> runNotifierBuild(
    covariant MessagesNotifier notifier,
  ) {
    return notifier.build(roomId);
  }

  @override
  Override overrideWith(MessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessagesNotifierProvider._internal(
        () => create()..roomId = roomId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MessagesNotifier,
    List<LocalChatMessage>
  >
  createElement() {
    return _MessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<LocalChatMessage>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _MessagesNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MessagesNotifier,
          List<LocalChatMessage>
        >
    with MessagesNotifierRef {
  _MessagesNotifierProviderElement(super.provider);

  @override
  String get roomId => (origin as MessagesNotifierProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
