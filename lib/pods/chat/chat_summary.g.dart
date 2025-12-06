// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_summary.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatUnreadCountNotifier)
const chatUnreadCountProvider = ChatUnreadCountNotifierProvider._();

final class ChatUnreadCountNotifierProvider
    extends $AsyncNotifierProvider<ChatUnreadCountNotifier, int> {
  const ChatUnreadCountNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatUnreadCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatUnreadCountNotifierHash();

  @$internal
  @override
  ChatUnreadCountNotifier create() => ChatUnreadCountNotifier();
}

String _$chatUnreadCountNotifierHash() =>
    r'b8d93589dc37f772d4c3a07d9afd81c37026e57d';

abstract class _$ChatUnreadCountNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatSummary)
const chatSummaryProvider = ChatSummaryProvider._();

final class ChatSummaryProvider
    extends $AsyncNotifierProvider<ChatSummary, Map<String, SnChatSummary>> {
  const ChatSummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatSummaryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatSummaryHash();

  @$internal
  @override
  ChatSummary create() => ChatSummary();
}

String _$chatSummaryHash() => r'dfa5e487586482ebdafef8d711f74db68ee86f84';

abstract class _$ChatSummary
    extends $AsyncNotifier<Map<String, SnChatSummary>> {
  FutureOr<Map<String, SnChatSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, SnChatSummary>>,
              Map<String, SnChatSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, SnChatSummary>>,
                Map<String, SnChatSummary>
              >,
              AsyncValue<Map<String, SnChatSummary>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
