// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessagesNotifier)
final messagesProvider = MessagesNotifierFamily._();

final class MessagesNotifierProvider
    extends $AsyncNotifierProvider<MessagesNotifier, List<LocalChatMessage>> {
  MessagesNotifierProvider._({
    required MessagesNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'messagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$messagesNotifierHash();

  @override
  String toString() {
    return r'messagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MessagesNotifier create() => MessagesNotifier();

  @override
  bool operator ==(Object other) {
    return other is MessagesNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$messagesNotifierHash() => r'20023fd99345accf59372952ecf5774fa3544b8f';

final class MessagesNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          MessagesNotifier,
          AsyncValue<List<LocalChatMessage>>,
          List<LocalChatMessage>,
          FutureOr<List<LocalChatMessage>>,
          String
        > {
  MessagesNotifierFamily._()
    : super(
        retry: null,
        name: r'messagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MessagesNotifierProvider call(String roomId) =>
      MessagesNotifierProvider._(argument: roomId, from: this);

  @override
  String toString() => r'messagesProvider';
}

abstract class _$MessagesNotifier
    extends $AsyncNotifier<List<LocalChatMessage>> {
  late final _$args = ref.$arg as String;
  String get roomId => _$args;

  FutureOr<List<LocalChatMessage>> build(String roomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<LocalChatMessage>>, List<LocalChatMessage>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<LocalChatMessage>>,
                List<LocalChatMessage>
              >,
              AsyncValue<List<LocalChatMessage>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
