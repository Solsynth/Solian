// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatroomInvitesHash() => r'5cd6391b09c5517ede19bacce43b45c8d71dd087';

/// See also [chatroomInvites].
@ProviderFor(chatroomInvites)
final chatroomInvitesProvider =
    AutoDisposeFutureProvider<List<SnChatMember>>.internal(
      chatroomInvites,
      name: r'chatroomInvitesProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$chatroomInvitesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatroomInvitesRef = AutoDisposeFutureProviderRef<List<SnChatMember>>;
String _$chatRoomJoinedNotifierHash() =>
    r'c8092225ba0d9c08b2b5bca6f800f1877303b4ff';

/// See also [ChatRoomJoinedNotifier].
@ProviderFor(ChatRoomJoinedNotifier)
final chatRoomJoinedNotifierProvider = AutoDisposeAsyncNotifierProvider<
  ChatRoomJoinedNotifier,
  List<SnChatRoom>
>.internal(
  ChatRoomJoinedNotifier.new,
  name: r'chatRoomJoinedNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatRoomJoinedNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatRoomJoinedNotifier = AutoDisposeAsyncNotifier<List<SnChatRoom>>;
String _$chatRoomNotifierHash() => r'1e6391e2ab4eeb114fa001aaa6b06ab2bd646f38';

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

abstract class _$ChatRoomNotifier
    extends BuildlessAutoDisposeAsyncNotifier<SnChatRoom?> {
  late final String? identifier;

  FutureOr<SnChatRoom?> build(String? identifier);
}

/// See also [ChatRoomNotifier].
@ProviderFor(ChatRoomNotifier)
const chatRoomNotifierProvider = ChatRoomNotifierFamily();

/// See also [ChatRoomNotifier].
class ChatRoomNotifierFamily extends Family<AsyncValue<SnChatRoom?>> {
  /// See also [ChatRoomNotifier].
  const ChatRoomNotifierFamily();

  /// See also [ChatRoomNotifier].
  ChatRoomNotifierProvider call(String? identifier) {
    return ChatRoomNotifierProvider(identifier);
  }

  @override
  ChatRoomNotifierProvider getProviderOverride(
    covariant ChatRoomNotifierProvider provider,
  ) {
    return call(provider.identifier);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatRoomNotifierProvider';
}

/// See also [ChatRoomNotifier].
class ChatRoomNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<ChatRoomNotifier, SnChatRoom?> {
  /// See also [ChatRoomNotifier].
  ChatRoomNotifierProvider(String? identifier)
    : this._internal(
        () => ChatRoomNotifier()..identifier = identifier,
        from: chatRoomNotifierProvider,
        name: r'chatRoomNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatRoomNotifierHash,
        dependencies: ChatRoomNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatRoomNotifierFamily._allTransitiveDependencies,
        identifier: identifier,
      );

  ChatRoomNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.identifier,
  }) : super.internal();

  final String? identifier;

  @override
  FutureOr<SnChatRoom?> runNotifierBuild(covariant ChatRoomNotifier notifier) {
    return notifier.build(identifier);
  }

  @override
  Override overrideWith(ChatRoomNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatRoomNotifierProvider._internal(
        () => create()..identifier = identifier,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        identifier: identifier,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatRoomNotifier, SnChatRoom?>
  createElement() {
    return _ChatRoomNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRoomNotifierProvider && other.identifier == identifier;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, identifier.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatRoomNotifierRef on AutoDisposeAsyncNotifierProviderRef<SnChatRoom?> {
  /// The parameter `identifier` of this provider.
  String? get identifier;
}

class _ChatRoomNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ChatRoomNotifier, SnChatRoom?>
    with ChatRoomNotifierRef {
  _ChatRoomNotifierProviderElement(super.provider);

  @override
  String? get identifier => (origin as ChatRoomNotifierProvider).identifier;
}

String _$chatRoomIdentityNotifierHash() =>
    r'27c17d55366d39be81d7209837e5c01f80a68a24';

abstract class _$ChatRoomIdentityNotifier
    extends BuildlessAutoDisposeAsyncNotifier<SnChatMember?> {
  late final String? identifier;

  FutureOr<SnChatMember?> build(String? identifier);
}

/// See also [ChatRoomIdentityNotifier].
@ProviderFor(ChatRoomIdentityNotifier)
const chatRoomIdentityNotifierProvider = ChatRoomIdentityNotifierFamily();

/// See also [ChatRoomIdentityNotifier].
class ChatRoomIdentityNotifierFamily extends Family<AsyncValue<SnChatMember?>> {
  /// See also [ChatRoomIdentityNotifier].
  const ChatRoomIdentityNotifierFamily();

  /// See also [ChatRoomIdentityNotifier].
  ChatRoomIdentityNotifierProvider call(String? identifier) {
    return ChatRoomIdentityNotifierProvider(identifier);
  }

  @override
  ChatRoomIdentityNotifierProvider getProviderOverride(
    covariant ChatRoomIdentityNotifierProvider provider,
  ) {
    return call(provider.identifier);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatRoomIdentityNotifierProvider';
}

/// See also [ChatRoomIdentityNotifier].
class ChatRoomIdentityNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ChatRoomIdentityNotifier,
          SnChatMember?
        > {
  /// See also [ChatRoomIdentityNotifier].
  ChatRoomIdentityNotifierProvider(String? identifier)
    : this._internal(
        () => ChatRoomIdentityNotifier()..identifier = identifier,
        from: chatRoomIdentityNotifierProvider,
        name: r'chatRoomIdentityNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatRoomIdentityNotifierHash,
        dependencies: ChatRoomIdentityNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatRoomIdentityNotifierFamily._allTransitiveDependencies,
        identifier: identifier,
      );

  ChatRoomIdentityNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.identifier,
  }) : super.internal();

  final String? identifier;

  @override
  FutureOr<SnChatMember?> runNotifierBuild(
    covariant ChatRoomIdentityNotifier notifier,
  ) {
    return notifier.build(identifier);
  }

  @override
  Override overrideWith(ChatRoomIdentityNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatRoomIdentityNotifierProvider._internal(
        () => create()..identifier = identifier,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        identifier: identifier,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ChatRoomIdentityNotifier,
    SnChatMember?
  >
  createElement() {
    return _ChatRoomIdentityNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatRoomIdentityNotifierProvider &&
        other.identifier == identifier;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, identifier.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatRoomIdentityNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<SnChatMember?> {
  /// The parameter `identifier` of this provider.
  String? get identifier;
}

class _ChatRoomIdentityNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ChatRoomIdentityNotifier,
          SnChatMember?
        >
    with ChatRoomIdentityNotifierRef {
  _ChatRoomIdentityNotifierProviderElement(super.provider);

  @override
  String? get identifier =>
      (origin as ChatRoomIdentityNotifierProvider).identifier;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
