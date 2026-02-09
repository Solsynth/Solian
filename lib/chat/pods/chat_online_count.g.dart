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
    extends $AsyncNotifierProvider<ChatOnlineCountNotifier, int> {
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
    r'b2f9f17bfece1937ec90590b8f11db2bec923156';

final class ChatOnlineCountNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatOnlineCountNotifier,
          AsyncValue<int>,
          int,
          FutureOr<int>,
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

abstract class _$ChatOnlineCountNotifier extends $AsyncNotifier<int> {
  late final _$args = ref.$arg as String;
  String get chatroomId => _$args;

  FutureOr<int> build(String chatroomId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
