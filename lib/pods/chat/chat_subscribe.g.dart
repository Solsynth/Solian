// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_subscribe.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSubscribeNotifierHash() =>
    r'10a6b2c687149ebb419e4c96349d8bab1f183ec6';

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

abstract class _$ChatSubscribeNotifier
    extends BuildlessAutoDisposeNotifier<List<SnChatMember>> {
  late final String roomId;

  List<SnChatMember> build(String roomId);
}

/// See also [ChatSubscribeNotifier].
@ProviderFor(ChatSubscribeNotifier)
const chatSubscribeNotifierProvider = ChatSubscribeNotifierFamily();

/// See also [ChatSubscribeNotifier].
class ChatSubscribeNotifierFamily extends Family<List<SnChatMember>> {
  /// See also [ChatSubscribeNotifier].
  const ChatSubscribeNotifierFamily();

  /// See also [ChatSubscribeNotifier].
  ChatSubscribeNotifierProvider call(String roomId) {
    return ChatSubscribeNotifierProvider(roomId);
  }

  @override
  ChatSubscribeNotifierProvider getProviderOverride(
    covariant ChatSubscribeNotifierProvider provider,
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
  String? get name => r'chatSubscribeNotifierProvider';
}

/// See also [ChatSubscribeNotifier].
class ChatSubscribeNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ChatSubscribeNotifier,
          List<SnChatMember>
        > {
  /// See also [ChatSubscribeNotifier].
  ChatSubscribeNotifierProvider(String roomId)
    : this._internal(
        () => ChatSubscribeNotifier()..roomId = roomId,
        from: chatSubscribeNotifierProvider,
        name: r'chatSubscribeNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatSubscribeNotifierHash,
        dependencies: ChatSubscribeNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatSubscribeNotifierFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  ChatSubscribeNotifierProvider._internal(
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
  List<SnChatMember> runNotifierBuild(
    covariant ChatSubscribeNotifier notifier,
  ) {
    return notifier.build(roomId);
  }

  @override
  Override overrideWith(ChatSubscribeNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatSubscribeNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<ChatSubscribeNotifier, List<SnChatMember>>
  createElement() {
    return _ChatSubscribeNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSubscribeNotifierProvider && other.roomId == roomId;
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
mixin ChatSubscribeNotifierRef
    on AutoDisposeNotifierProviderRef<List<SnChatMember>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _ChatSubscribeNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ChatSubscribeNotifier,
          List<SnChatMember>
        >
    with ChatSubscribeNotifierRef {
  _ChatSubscribeNotifierProviderElement(super.provider);

  @override
  String get roomId => (origin as ChatSubscribeNotifierProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
