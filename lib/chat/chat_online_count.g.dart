// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_online_count.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatOnlineCountNotifier)
final chatOnlineCountProvider = ChatOnlineCountNotifierFamily._();

final class ChatOnlineCountNotifierProvider
    extends
        $AsyncNotifierProvider<ChatOnlineCountNotifier, SnChatOnlineStatus> {
  ChatOnlineCountNotifierProvider._({
    required ChatOnlineCountNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatOnlineCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatOnlineCountNotifierHash();

  @override
  String toString() {
    return r'chatOnlineCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatOnlineCountNotifier create() => ChatOnlineCountNotifier();

  @override
  bool operator ==(Object other) {
    return other is ChatOnlineCountNotifierProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatOnlineCountNotifierHash() =>
    r'a4553dfe12786b84bc0e0ad90285d028a1f00553';

final class ChatOnlineCountNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatOnlineCountNotifier,
          AsyncValue<SnChatOnlineStatus>,
          SnChatOnlineStatus,
          FutureOr<SnChatOnlineStatus>,
          String
        > {
  ChatOnlineCountNotifierFamily._()
    : super(
        retry: null,
        name: r'chatOnlineCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatOnlineCountNotifierProvider call(String chatroomId) =>
      ChatOnlineCountNotifierProvider._(argument: chatroomId, from: this);

  @override
  String toString() => r'chatOnlineCountProvider';
}

abstract class _$ChatOnlineCountNotifier
    extends $AsyncNotifier<SnChatOnlineStatus> {
  late final _$args = ref.$arg as String;
  String get chatroomId => _$args;

  FutureOr<SnChatOnlineStatus> build(String chatroomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SnChatOnlineStatus>, SnChatOnlineStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SnChatOnlineStatus>, SnChatOnlineStatus>,
              AsyncValue<SnChatOnlineStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
