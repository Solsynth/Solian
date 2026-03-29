// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hub.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publisherStats)
final publisherStatsProvider = PublisherStatsFamily._();

final class PublisherStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherStats?>,
          SnPublisherStats?,
          FutureOr<SnPublisherStats?>
        >
    with
        $FutureModifier<SnPublisherStats?>,
        $FutureProvider<SnPublisherStats?> {
  PublisherStatsProvider._({
    required PublisherStatsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherStatsHash();

  @override
  String toString() {
    return r'publisherStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherStats?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherStats?> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherStatsHash() => r'eea4ed98bf165cc785874f83b912bb7e23d1f7bc';

final class PublisherStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisherStats?>, String?> {
  PublisherStatsFamily._()
    : super(
        retry: null,
        name: r'publisherStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherStatsProvider call(String? uname) =>
      PublisherStatsProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherStatsProvider';
}

@ProviderFor(publisherHeatmap)
final publisherHeatmapProvider = PublisherHeatmapFamily._();

final class PublisherHeatmapProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnHeatmap?>,
          SnHeatmap?,
          FutureOr<SnHeatmap?>
        >
    with $FutureModifier<SnHeatmap?>, $FutureProvider<SnHeatmap?> {
  PublisherHeatmapProvider._({
    required PublisherHeatmapFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherHeatmapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherHeatmapHash();

  @override
  String toString() {
    return r'publisherHeatmapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnHeatmap?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnHeatmap?> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherHeatmap(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherHeatmapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherHeatmapHash() => r'5f70c55e14629ec8628445a317888e02fccd9af2';

final class PublisherHeatmapFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnHeatmap?>, String?> {
  PublisherHeatmapFamily._()
    : super(
        retry: null,
        name: r'publisherHeatmapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherHeatmapProvider call(String? uname) =>
      PublisherHeatmapProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherHeatmapProvider';
}

@ProviderFor(publisherIdentity)
final publisherIdentityProvider = PublisherIdentityFamily._();

final class PublisherIdentityProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherMember?>,
          SnPublisherMember?,
          FutureOr<SnPublisherMember?>
        >
    with
        $FutureModifier<SnPublisherMember?>,
        $FutureProvider<SnPublisherMember?> {
  PublisherIdentityProvider._({
    required PublisherIdentityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherIdentityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherIdentityHash();

  @override
  String toString() {
    return r'publisherIdentityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherMember?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherMember?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherIdentity(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherIdentityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherIdentityHash() => r'299372f25fa4b2bf8e11a8ba2d645100fc38e76f';

final class PublisherIdentityFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnPublisherMember?>, String> {
  PublisherIdentityFamily._()
    : super(
        retry: null,
        name: r'publisherIdentityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherIdentityProvider call(String uname) =>
      PublisherIdentityProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherIdentityProvider';
}

@ProviderFor(publisherFeatures)
final publisherFeaturesProvider = PublisherFeaturesFamily._();

final class PublisherFeaturesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, bool>>,
          Map<String, bool>,
          FutureOr<Map<String, bool>>
        >
    with
        $FutureModifier<Map<String, bool>>,
        $FutureProvider<Map<String, bool>> {
  PublisherFeaturesProvider._({
    required PublisherFeaturesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherFeaturesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFeaturesHash();

  @override
  String toString() {
    return r'publisherFeaturesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, bool>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, bool>> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherFeatures(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFeaturesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFeaturesHash() => r'08bace2d9a3da227ecec0cbf8709e55ee0646ca2';

final class PublisherFeaturesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, bool>>, String?> {
  PublisherFeaturesFamily._()
    : super(
        retry: null,
        name: r'publisherFeaturesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFeaturesProvider call(String? uname) =>
      PublisherFeaturesProvider._(argument: uname, from: this);

  @override
  String toString() => r'publisherFeaturesProvider';
}

@ProviderFor(publisherQuotaInfo)
final publisherQuotaInfoProvider = PublisherQuotaInfoProvider._();

final class PublisherQuotaInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublisherQuotaInfo>,
          PublisherQuotaInfo,
          FutureOr<PublisherQuotaInfo>
        >
    with
        $FutureModifier<PublisherQuotaInfo>,
        $FutureProvider<PublisherQuotaInfo> {
  PublisherQuotaInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publisherQuotaInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publisherQuotaInfoHash();

  @$internal
  @override
  $FutureProviderElement<PublisherQuotaInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PublisherQuotaInfo> create(Ref ref) {
    return publisherQuotaInfo(ref);
  }
}

String _$publisherQuotaInfoHash() =>
    r'9c73aa7ee63e9e627ba8ac1333ea5f882ef89365';

@ProviderFor(publisherInvites)
final publisherInvitesProvider = PublisherInvitesProvider._();

final class PublisherInvitesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisherMember>>,
          List<SnPublisherMember>,
          FutureOr<List<SnPublisherMember>>
        >
    with
        $FutureModifier<List<SnPublisherMember>>,
        $FutureProvider<List<SnPublisherMember>> {
  PublisherInvitesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publisherInvitesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publisherInvitesHash();

  @$internal
  @override
  $FutureProviderElement<List<SnPublisherMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisherMember>> create(Ref ref) {
    return publisherInvites(ref);
  }
}

String _$publisherInvitesHash() => r'93aafc2f02af0a7a055ec1770b3999363dfaabdc';

@ProviderFor(publisherActorStatus)
final publisherActorStatusProvider = PublisherActorStatusFamily._();

final class PublisherActorStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnActorStatusResponse>,
          SnActorStatusResponse,
          FutureOr<SnActorStatusResponse>
        >
    with
        $FutureModifier<SnActorStatusResponse>,
        $FutureProvider<SnActorStatusResponse> {
  PublisherActorStatusProvider._({
    required PublisherActorStatusFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'publisherActorStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherActorStatusHash();

  @override
  String toString() {
    return r'publisherActorStatusProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnActorStatusResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnActorStatusResponse> create(Ref ref) {
    final argument = this.argument as String?;
    return publisherActorStatus(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherActorStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherActorStatusHash() =>
    r'406117cb99b2aef236945ef0ef59e857d8835029';

final class PublisherActorStatusFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnActorStatusResponse>, String?> {
  PublisherActorStatusFamily._()
    : super(
        retry: null,
        name: r'publisherActorStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherActorStatusProvider call(String? publisherName) =>
      PublisherActorStatusProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherActorStatusProvider';
}

@ProviderFor(publisherFollow)
final publisherFollowProvider = PublisherFollowFamily._();

final class PublisherFollowProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherFollowResponse>,
          SnPublisherFollowResponse,
          FutureOr<SnPublisherFollowResponse>
        >
    with
        $FutureModifier<SnPublisherFollowResponse>,
        $FutureProvider<SnPublisherFollowResponse> {
  PublisherFollowProvider._({
    required PublisherFollowFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherFollowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFollowHash();

  @override
  String toString() {
    return r'publisherFollowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherFollowResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherFollowResponse> create(Ref ref) {
    final argument = this.argument as String;
    return publisherFollow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFollowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFollowHash() => r'a5779972315b0311209346e93a2e0234544d8e5b';

final class PublisherFollowFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<SnPublisherFollowResponse>, String> {
  PublisherFollowFamily._()
    : super(
        retry: null,
        name: r'publisherFollowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFollowProvider call(String publisherName) =>
      PublisherFollowProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherFollowProvider';
}

@ProviderFor(publisherUnfollow)
final publisherUnfollowProvider = PublisherUnfollowFamily._();

final class PublisherUnfollowProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  PublisherUnfollowProvider._({
    required PublisherUnfollowFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherUnfollowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherUnfollowHash();

  @override
  String toString() {
    return r'publisherUnfollowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return publisherUnfollow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherUnfollowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherUnfollowHash() => r'bd602901677e6087646753f21ef532889411d247';

final class PublisherUnfollowFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  PublisherUnfollowFamily._()
    : super(
        retry: null,
        name: r'publisherUnfollowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherUnfollowProvider call(String publisherName) =>
      PublisherUnfollowProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherUnfollowProvider';
}

@ProviderFor(publisherFollowRequest)
final publisherFollowRequestProvider = PublisherFollowRequestFamily._();

final class PublisherFollowRequestProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnPublisherSubscriptionStatus?>,
          SnPublisherSubscriptionStatus?,
          FutureOr<SnPublisherSubscriptionStatus?>
        >
    with
        $FutureModifier<SnPublisherSubscriptionStatus?>,
        $FutureProvider<SnPublisherSubscriptionStatus?> {
  PublisherFollowRequestProvider._({
    required PublisherFollowRequestFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherFollowRequestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFollowRequestHash();

  @override
  String toString() {
    return r'publisherFollowRequestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnPublisherSubscriptionStatus?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnPublisherSubscriptionStatus?> create(Ref ref) {
    final argument = this.argument as String;
    return publisherFollowRequest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFollowRequestProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFollowRequestHash() =>
    r'dc0fd1f83ed0dd2658c23aeaecb434b12be1080c';

final class PublisherFollowRequestFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SnPublisherSubscriptionStatus?>,
          String
        > {
  PublisherFollowRequestFamily._()
    : super(
        retry: null,
        name: r'publisherFollowRequestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFollowRequestProvider call(String publisherName) =>
      PublisherFollowRequestProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherFollowRequestProvider';
}

@ProviderFor(publisherFollowRequests)
final publisherFollowRequestsProvider = PublisherFollowRequestsFamily._();

final class PublisherFollowRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisherFollowRequest>>,
          List<SnPublisherFollowRequest>,
          FutureOr<List<SnPublisherFollowRequest>>
        >
    with
        $FutureModifier<List<SnPublisherFollowRequest>>,
        $FutureProvider<List<SnPublisherFollowRequest>> {
  PublisherFollowRequestsProvider._({
    required PublisherFollowRequestsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publisherFollowRequestsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherFollowRequestsHash();

  @override
  String toString() {
    return r'publisherFollowRequestsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnPublisherFollowRequest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisherFollowRequest>> create(Ref ref) {
    final argument = this.argument as String;
    return publisherFollowRequests(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherFollowRequestsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherFollowRequestsHash() =>
    r'882f6c70adb96af83f94a724c7185436a7ecdad4';

final class PublisherFollowRequestsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SnPublisherFollowRequest>>,
          String
        > {
  PublisherFollowRequestsFamily._()
    : super(
        retry: null,
        name: r'publisherFollowRequestsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherFollowRequestsProvider call(String publisherName) =>
      PublisherFollowRequestsProvider._(argument: publisherName, from: this);

  @override
  String toString() => r'publisherFollowRequestsProvider';
}

@ProviderFor(publisherApproveFollow)
final publisherApproveFollowProvider = PublisherApproveFollowFamily._();

final class PublisherApproveFollowProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  PublisherApproveFollowProvider._({
    required PublisherApproveFollowFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'publisherApproveFollowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherApproveFollowHash();

  @override
  String toString() {
    return r'publisherApproveFollowProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, String);
    return publisherApproveFollow(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherApproveFollowProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherApproveFollowHash() =>
    r'd6873a0d4fdba0a292a9ab55bbdb61db046e4828';

final class PublisherApproveFollowFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, (String, String)> {
  PublisherApproveFollowFamily._()
    : super(
        retry: null,
        name: r'publisherApproveFollowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherApproveFollowProvider call(String publisherName, String requestId) =>
      PublisherApproveFollowProvider._(
        argument: (publisherName, requestId),
        from: this,
      );

  @override
  String toString() => r'publisherApproveFollowProvider';
}

@ProviderFor(publisherRejectFollow)
final publisherRejectFollowProvider = PublisherRejectFollowFamily._();

final class PublisherRejectFollowProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  PublisherRejectFollowProvider._({
    required PublisherRejectFollowFamily super.from,
    required (String, String, {String? reason}) super.argument,
  }) : super(
         retry: null,
         name: r'publisherRejectFollowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publisherRejectFollowHash();

  @override
  String toString() {
    return r'publisherRejectFollowProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as (String, String, {String? reason});
    return publisherRejectFollow(
      ref,
      argument.$1,
      argument.$2,
      reason: argument.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PublisherRejectFollowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publisherRejectFollowHash() =>
    r'b46e58068e5b66a3b0b2fef5cb4827bb0504c252';

final class PublisherRejectFollowFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          (String, String, {String? reason})
        > {
  PublisherRejectFollowFamily._()
    : super(
        retry: null,
        name: r'publisherRejectFollowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublisherRejectFollowProvider call(
    String publisherName,
    String requestId, {
    String? reason,
  }) => PublisherRejectFollowProvider._(
    argument: (publisherName, requestId, reason: reason),
    from: this,
  );

  @override
  String toString() => r'publisherRejectFollowProvider';
}
