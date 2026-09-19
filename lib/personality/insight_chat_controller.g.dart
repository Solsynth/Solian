// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_chat_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Insight page: one live conversation against the Personality backend,
/// plus the account's thread list. Port of FloatLand's `pages/pet/index.vue` run
/// handling, including its reasoning/tool trace folding rules.

@ProviderFor(InsightChatController)
final insightChatControllerProvider = InsightChatControllerProvider._();

/// The Insight page: one live conversation against the Personality backend,
/// plus the account's thread list. Port of FloatLand's `pages/pet/index.vue` run
/// handling, including its reasoning/tool trace folding rules.
final class InsightChatControllerProvider
    extends $NotifierProvider<InsightChatController, InsightChatState> {
  /// The Insight page: one live conversation against the Personality backend,
  /// plus the account's thread list. Port of FloatLand's `pages/pet/index.vue` run
  /// handling, including its reasoning/tool trace folding rules.
  InsightChatControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'insightChatControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$insightChatControllerHash();

  @$internal
  @override
  InsightChatController create() => InsightChatController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InsightChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InsightChatState>(value),
    );
  }
}

String _$insightChatControllerHash() =>
    r'10000b3c2ee6498f379cbc8d81d6ea59d5e01d0e';

/// The Insight page: one live conversation against the Personality backend,
/// plus the account's thread list. Port of FloatLand's `pages/pet/index.vue` run
/// handling, including its reasoning/tool trace folding rules.

abstract class _$InsightChatController extends $Notifier<InsightChatState> {
  InsightChatState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<InsightChatState, InsightChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InsightChatState, InsightChatState>,
              InsightChatState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
