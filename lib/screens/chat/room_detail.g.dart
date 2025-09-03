// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalMessagesCountHash() =>
    r'd55f1507aba2acdce5e468c1c2e15dba7640c571';

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

/// See also [totalMessagesCount].
@ProviderFor(totalMessagesCount)
const totalMessagesCountProvider = TotalMessagesCountFamily();

/// See also [totalMessagesCount].
class TotalMessagesCountFamily extends Family<AsyncValue<int>> {
  /// See also [totalMessagesCount].
  const TotalMessagesCountFamily();

  /// See also [totalMessagesCount].
  TotalMessagesCountProvider call(String roomId) {
    return TotalMessagesCountProvider(roomId);
  }

  @override
  TotalMessagesCountProvider getProviderOverride(
    covariant TotalMessagesCountProvider provider,
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
  String? get name => r'totalMessagesCountProvider';
}

/// See also [totalMessagesCount].
class TotalMessagesCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [totalMessagesCount].
  TotalMessagesCountProvider(String roomId)
    : this._internal(
        (ref) => totalMessagesCount(ref as TotalMessagesCountRef, roomId),
        from: totalMessagesCountProvider,
        name: r'totalMessagesCountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$totalMessagesCountHash,
        dependencies: TotalMessagesCountFamily._dependencies,
        allTransitiveDependencies:
            TotalMessagesCountFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  TotalMessagesCountProvider._internal(
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
  Override overrideWith(
    FutureOr<int> Function(TotalMessagesCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TotalMessagesCountProvider._internal(
        (ref) => create(ref as TotalMessagesCountRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _TotalMessagesCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalMessagesCountProvider && other.roomId == roomId;
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
mixin TotalMessagesCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _TotalMessagesCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with TotalMessagesCountRef {
  _TotalMessagesCountProviderElement(super.provider);

  @override
  String get roomId => (origin as TotalMessagesCountProvider).roomId;
}

String _$chatMemberListNotifierHash() =>
    r'3ea30150278523e9f6b23f9200ea9a9fbae9c973';

abstract class _$ChatMemberListNotifier
    extends BuildlessAutoDisposeAsyncNotifier<CursorPagingData<SnChatMember>> {
  late final String roomId;

  FutureOr<CursorPagingData<SnChatMember>> build(String roomId);
}

/// See also [ChatMemberListNotifier].
@ProviderFor(ChatMemberListNotifier)
const chatMemberListNotifierProvider = ChatMemberListNotifierFamily();

/// See also [ChatMemberListNotifier].
class ChatMemberListNotifierFamily
    extends Family<AsyncValue<CursorPagingData<SnChatMember>>> {
  /// See also [ChatMemberListNotifier].
  const ChatMemberListNotifierFamily();

  /// See also [ChatMemberListNotifier].
  ChatMemberListNotifierProvider call(String roomId) {
    return ChatMemberListNotifierProvider(roomId);
  }

  @override
  ChatMemberListNotifierProvider getProviderOverride(
    covariant ChatMemberListNotifierProvider provider,
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
  String? get name => r'chatMemberListNotifierProvider';
}

/// See also [ChatMemberListNotifier].
class ChatMemberListNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatMemberListNotifier,
          CursorPagingData<SnChatMember>
        > {
  /// See also [ChatMemberListNotifier].
  ChatMemberListNotifierProvider(String roomId)
    : this._internal(
        () => ChatMemberListNotifier()..roomId = roomId,
        from: chatMemberListNotifierProvider,
        name: r'chatMemberListNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatMemberListNotifierHash,
        dependencies: ChatMemberListNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatMemberListNotifierFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  ChatMemberListNotifierProvider._internal(
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
  FutureOr<CursorPagingData<SnChatMember>> runNotifierBuild(
    covariant ChatMemberListNotifier notifier,
  ) {
    return notifier.build(roomId);
  }

  @override
  Override overrideWith(ChatMemberListNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMemberListNotifierProvider._internal(
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
    ChatMemberListNotifier,
    CursorPagingData<SnChatMember>
  >
  createElement() {
    return _ChatMemberListNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMemberListNotifierProvider && other.roomId == roomId;
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
mixin ChatMemberListNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<CursorPagingData<SnChatMember>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _ChatMemberListNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatMemberListNotifier,
          CursorPagingData<SnChatMember>
        >
    with ChatMemberListNotifierRef {
  _ChatMemberListNotifierProviderElement(super.provider);

  @override
  String get roomId => (origin as ChatMemberListNotifierProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
