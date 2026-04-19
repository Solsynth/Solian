// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_subscribe.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatSubscribeNotifier)
final chatSubscribeProvider = ChatSubscribeNotifierFamily._();

final class ChatSubscribeNotifierProvider
    extends $NotifierProvider<ChatSubscribeNotifier, List<SnChatMember>> {
  ChatSubscribeNotifierProvider._({
    required ChatSubscribeNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chatSubscribeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatSubscribeNotifierHash();

  @override
  String toString() {
    return r'chatSubscribeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatSubscribeNotifier create() => ChatSubscribeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SnChatMember> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SnChatMember>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatSubscribeNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatSubscribeNotifierHash() =>
    r'9055097976f8cf308bfe9f1582ab57c445c2828e';

final class ChatSubscribeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatSubscribeNotifier,
          List<SnChatMember>,
          List<SnChatMember>,
          List<SnChatMember>,
          String
        > {
  ChatSubscribeNotifierFamily._()
    : super(
        retry: null,
        name: r'chatSubscribeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatSubscribeNotifierProvider call(String roomId) =>
      ChatSubscribeNotifierProvider._(argument: roomId, from: this);

  @override
  String toString() => r'chatSubscribeProvider';
}

abstract class _$ChatSubscribeNotifier extends $Notifier<List<SnChatMember>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  List<SnChatMember> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SnChatMember>, List<SnChatMember>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SnChatMember>, List<SnChatMember>>,
              List<SnChatMember>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
