// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatRoomJoinedNotifier)
const chatRoomJoinedProvider = ChatRoomJoinedNotifierProvider._();

final class ChatRoomJoinedNotifierProvider
    extends $AsyncNotifierProvider<ChatRoomJoinedNotifier, List<SnChatRoom>> {
  const ChatRoomJoinedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRoomJoinedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRoomJoinedNotifierHash();

  @$internal
  @override
  ChatRoomJoinedNotifier create() => ChatRoomJoinedNotifier();
}

String _$chatRoomJoinedNotifierHash() =>
    r'e69955be56ef2c04a8062a8a65925e0a23bfcbaa';

abstract class _$ChatRoomJoinedNotifier
    extends $AsyncNotifier<List<SnChatRoom>> {
  FutureOr<List<SnChatRoom>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<SnChatRoom>>, List<SnChatRoom>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SnChatRoom>>, List<SnChatRoom>>,
              AsyncValue<List<SnChatRoom>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatRoomNotifier)
const chatRoomProvider = ChatRoomNotifierFamily._();

final class ChatRoomNotifierProvider
    extends $AsyncNotifierProvider<ChatRoomNotifier, SnChatRoom?> {
  const ChatRoomNotifierProvider._({
    required ChatRoomNotifierFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'chatRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatRoomNotifierHash();

  @override
  String toString() {
    return r'chatRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatRoomNotifier create() => ChatRoomNotifier();

  @override
  bool operator ==(Object other) {
    return other is ChatRoomNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRoomNotifierHash() => r'1e6391e2ab4eeb114fa001aaa6b06ab2bd646f38';

final class ChatRoomNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatRoomNotifier,
          AsyncValue<SnChatRoom?>,
          SnChatRoom?,
          FutureOr<SnChatRoom?>,
          String?
        > {
  const ChatRoomNotifierFamily._()
    : super(
        retry: null,
        name: r'chatRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatRoomNotifierProvider call(String? identifier) =>
      ChatRoomNotifierProvider._(argument: identifier, from: this);

  @override
  String toString() => r'chatRoomProvider';
}

abstract class _$ChatRoomNotifier extends $AsyncNotifier<SnChatRoom?> {
  late final _$args = ref.$arg as String?;
  String? get identifier => _$args;

  FutureOr<SnChatRoom?> build(String? identifier);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<SnChatRoom?>, SnChatRoom?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SnChatRoom?>, SnChatRoom?>,
              AsyncValue<SnChatRoom?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatRoomIdentityNotifier)
const chatRoomIdentityProvider = ChatRoomIdentityNotifierFamily._();

final class ChatRoomIdentityNotifierProvider
    extends $AsyncNotifierProvider<ChatRoomIdentityNotifier, SnChatMember?> {
  const ChatRoomIdentityNotifierProvider._({
    required ChatRoomIdentityNotifierFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'chatRoomIdentityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatRoomIdentityNotifierHash();

  @override
  String toString() {
    return r'chatRoomIdentityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatRoomIdentityNotifier create() => ChatRoomIdentityNotifier();

  @override
  bool operator ==(Object other) {
    return other is ChatRoomIdentityNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatRoomIdentityNotifierHash() =>
    r'27c17d55366d39be81d7209837e5c01f80a68a24';

final class ChatRoomIdentityNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatRoomIdentityNotifier,
          AsyncValue<SnChatMember?>,
          SnChatMember?,
          FutureOr<SnChatMember?>,
          String?
        > {
  const ChatRoomIdentityNotifierFamily._()
    : super(
        retry: null,
        name: r'chatRoomIdentityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatRoomIdentityNotifierProvider call(String? identifier) =>
      ChatRoomIdentityNotifierProvider._(argument: identifier, from: this);

  @override
  String toString() => r'chatRoomIdentityProvider';
}

abstract class _$ChatRoomIdentityNotifier
    extends $AsyncNotifier<SnChatMember?> {
  late final _$args = ref.$arg as String?;
  String? get identifier => _$args;

  FutureOr<SnChatMember?> build(String? identifier);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<SnChatMember?>, SnChatMember?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SnChatMember?>, SnChatMember?>,
              AsyncValue<SnChatMember?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(chatroomInvites)
const chatroomInvitesProvider = ChatroomInvitesProvider._();

final class ChatroomInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnChatMember>>,
          List<SnChatMember>,
          FutureOr<List<SnChatMember>>
        >
    with
        $FutureModifier<List<SnChatMember>>,
        $FutureProvider<List<SnChatMember>> {
  const ChatroomInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatroomInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatroomInvitesHash();

  @$internal
  @override
  $FutureProviderElement<List<SnChatMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnChatMember>> create(Ref ref) {
    return chatroomInvites(ref);
  }
}

String _$chatroomInvitesHash() => r'5cd6391b09c5517ede19bacce43b45c8d71dd087';
