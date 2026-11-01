// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_summary.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatUnreadCountNotifier)
final chatUnreadCountProvider = ChatUnreadCountNotifierProvider._();

final class ChatUnreadCountNotifierProvider
    extends $AsyncNotifierProvider<ChatUnreadCountNotifier, int> {
  ChatUnreadCountNotifierProvider._()
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
    r'4e5c8ae77e6b004cd401268aff67ad4c6fe09a1d';

abstract class _$ChatUnreadCountNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ChatSummary)
final chatSummaryProvider = ChatSummaryProvider._();

final class ChatSummaryProvider
    extends $AsyncNotifierProvider<ChatSummary, Map<String, SnChatSummary>> {
  ChatSummaryProvider._()
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

String _$chatSummaryHash() => r'aeb8ffb455f5b2558dea548970726bc16821237d';

abstract class _$ChatSummary
    extends $AsyncNotifier<Map<String, SnChatSummary>> {
  FutureOr<Map<String, SnChatSummary>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}
