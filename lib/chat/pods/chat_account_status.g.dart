// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_account_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatAccountStatus)
final chatAccountStatusProvider = ChatAccountStatusProvider._();

final class ChatAccountStatusProvider
    extends $AsyncNotifierProvider<ChatAccountStatus, SnChatAccountStatus?> {
  ChatAccountStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatAccountStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatAccountStatusHash();

  @$internal
  @override
  ChatAccountStatus create() => ChatAccountStatus();
}

String _$chatAccountStatusHash() => r'47168b3c5167f7f8f91cea7489bfd35264531aca';

abstract class _$ChatAccountStatus
    extends $AsyncNotifier<SnChatAccountStatus?> {
  FutureOr<SnChatAccountStatus?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<SnChatAccountStatus?>, SnChatAccountStatus?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SnChatAccountStatus?>,
                SnChatAccountStatus?
              >,
              AsyncValue<SnChatAccountStatus?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
