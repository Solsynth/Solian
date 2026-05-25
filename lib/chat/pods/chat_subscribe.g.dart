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
    extends $NotifierProvider<ChatSubscribeNotifier, List<ChatActivityStatus>> {
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
  Override overrideWithValue(List<ChatActivityStatus> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ChatActivityStatus>>(value),
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
    r'2bcb515417c2d145bc82032ad4aafa41665b1530';

final class ChatSubscribeNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatSubscribeNotifier,
          List<ChatActivityStatus>,
          List<ChatActivityStatus>,
          List<ChatActivityStatus>,
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

abstract class _$ChatSubscribeNotifier
    extends $Notifier<List<ChatActivityStatus>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  List<ChatActivityStatus> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<ChatActivityStatus>, List<ChatActivityStatus>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ChatActivityStatus>, List<ChatActivityStatus>>,
              List<ChatActivityStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
