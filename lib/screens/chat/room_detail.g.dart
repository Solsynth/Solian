// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMemberListNotifierHash() =>
    r'f2191a631ba00ae3de39ccac10e4cdd065ffee17';

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
