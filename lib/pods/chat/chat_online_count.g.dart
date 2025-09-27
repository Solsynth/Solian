// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_online_count.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatOnlineCountNotifierHash() =>
    r'254ed141ffd99585d898203b3d2b86c4d18db80d';

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

abstract class _$ChatOnlineCountNotifier
    extends BuildlessAutoDisposeAsyncNotifier<int> {
  late final String chatroomId;

  FutureOr<int> build(String chatroomId);
}

/// See also [ChatOnlineCountNotifier].
@ProviderFor(ChatOnlineCountNotifier)
const chatOnlineCountNotifierProvider = ChatOnlineCountNotifierFamily();

/// See also [ChatOnlineCountNotifier].
class ChatOnlineCountNotifierFamily extends Family<AsyncValue<int>> {
  /// See also [ChatOnlineCountNotifier].
  const ChatOnlineCountNotifierFamily();

  /// See also [ChatOnlineCountNotifier].
  ChatOnlineCountNotifierProvider call(String chatroomId) {
    return ChatOnlineCountNotifierProvider(chatroomId);
  }

  @override
  ChatOnlineCountNotifierProvider getProviderOverride(
    covariant ChatOnlineCountNotifierProvider provider,
  ) {
    return call(provider.chatroomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatOnlineCountNotifierProvider';
}

/// See also [ChatOnlineCountNotifier].
class ChatOnlineCountNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatOnlineCountNotifier, int> {
  /// See also [ChatOnlineCountNotifier].
  ChatOnlineCountNotifierProvider(String chatroomId)
    : this._internal(
        () => ChatOnlineCountNotifier()..chatroomId = chatroomId,
        from: chatOnlineCountNotifierProvider,
        name: r'chatOnlineCountNotifierProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatOnlineCountNotifierHash,
        dependencies: ChatOnlineCountNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatOnlineCountNotifierFamily._allTransitiveDependencies,
        chatroomId: chatroomId,
      );

  ChatOnlineCountNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatroomId,
  }) : super.internal();

  final String chatroomId;

  @override
  FutureOr<int> runNotifierBuild(covariant ChatOnlineCountNotifier notifier) {
    return notifier.build(chatroomId);
  }

  @override
  Override overrideWith(ChatOnlineCountNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatOnlineCountNotifierProvider._internal(
        () => create()..chatroomId = chatroomId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatroomId: chatroomId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatOnlineCountNotifier, int>
  createElement() {
    return _ChatOnlineCountNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatOnlineCountNotifierProvider &&
        other.chatroomId == chatroomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatroomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatOnlineCountNotifierRef on AutoDisposeAsyncNotifierProviderRef<int> {
  /// The parameter `chatroomId` of this provider.
  String get chatroomId;
}

class _ChatOnlineCountNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<ChatOnlineCountNotifier, int>
    with ChatOnlineCountNotifierRef {
  _ChatOnlineCountNotifierProviderElement(super.provider);

  @override
  String get chatroomId =>
      (origin as ChatOnlineCountNotifierProvider).chatroomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
