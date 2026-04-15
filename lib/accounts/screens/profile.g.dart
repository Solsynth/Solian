// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(account)
final accountProvider = AccountFamily._();

final class AccountProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnAccount>,
          SnAccount,
          FutureOr<SnAccount>
        >
    with $FutureModifier<SnAccount>, $FutureProvider<SnAccount> {
  AccountProvider._({
    required AccountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @override
  String toString() {
    return r'accountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnAccount> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SnAccount> create(Ref ref) {
    final argument = this.argument as String;
    return account(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountHash() => r'7df5f0ab9fcbc59977d28a4edb5865858a06f610';

final class AccountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnAccount>, String> {
  AccountFamily._()
    : super(
        retry: null,
        name: r'accountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountProvider call(String uname) =>
      AccountProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountProvider';
}

@ProviderFor(accountBadges)
final accountBadgesProvider = AccountBadgesFamily._();

final class AccountBadgesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnAccountBadge>>,
          List<SnAccountBadge>,
          FutureOr<List<SnAccountBadge>>
        >
    with
        $FutureModifier<List<SnAccountBadge>>,
        $FutureProvider<List<SnAccountBadge>> {
  AccountBadgesProvider._({
    required AccountBadgesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountBadgesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountBadgesHash();

  @override
  String toString() {
    return r'accountBadgesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnAccountBadge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnAccountBadge>> create(Ref ref) {
    final argument = this.argument as String;
    return accountBadges(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBadgesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBadgesHash() => r'9a5d278bc344838724446bd6474bb2b453df8b8f';

final class AccountBadgesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnAccountBadge>>, String> {
  AccountBadgesFamily._()
    : super(
        retry: null,
        name: r'accountBadgesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountBadgesProvider call(String uname) =>
      AccountBadgesProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountBadgesProvider';
}

@ProviderFor(accountDirectChat)
final accountDirectChatProvider = AccountDirectChatFamily._();

final class AccountDirectChatProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnChatRoom?>,
          SnChatRoom?,
          FutureOr<SnChatRoom?>
        >
    with $FutureModifier<SnChatRoom?>, $FutureProvider<SnChatRoom?> {
  AccountDirectChatProvider._({
    required AccountDirectChatFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountDirectChatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountDirectChatHash();

  @override
  String toString() {
    return r'accountDirectChatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnChatRoom?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnChatRoom?> create(Ref ref) {
    final argument = this.argument as String;
    return accountDirectChat(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountDirectChatProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountDirectChatHash() => r'67f73a15aaddfe7fed3ecc4a3b36b55675999a86';

final class AccountDirectChatFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnChatRoom?>, String> {
  AccountDirectChatFamily._()
    : super(
        retry: null,
        name: r'accountDirectChatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountDirectChatProvider call(String uname) =>
      AccountDirectChatProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountDirectChatProvider';
}

@ProviderFor(accountRelationship)
final accountRelationshipProvider = AccountRelationshipFamily._();

final class AccountRelationshipProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnRelationship?>,
          SnRelationship?,
          FutureOr<SnRelationship?>
        >
    with $FutureModifier<SnRelationship?>, $FutureProvider<SnRelationship?> {
  AccountRelationshipProvider._({
    required AccountRelationshipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountRelationshipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountRelationshipHash();

  @override
  String toString() {
    return r'accountRelationshipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnRelationship?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnRelationship?> create(Ref ref) {
    final argument = this.argument as String;
    return accountRelationship(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountRelationshipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountRelationshipHash() =>
    r'0e8fe5ace3174402694acfecdd766b6d1a5a85ec';

final class AccountRelationshipFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnRelationship?>, String> {
  AccountRelationshipFamily._()
    : super(
        retry: null,
        name: r'accountRelationshipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountRelationshipProvider call(String uname) =>
      AccountRelationshipProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountRelationshipProvider';
}

@ProviderFor(accountBotDeveloper)
final accountBotDeveloperProvider = AccountBotDeveloperFamily._();

final class AccountBotDeveloperProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnDeveloper?>,
          SnDeveloper?,
          FutureOr<SnDeveloper?>
        >
    with $FutureModifier<SnDeveloper?>, $FutureProvider<SnDeveloper?> {
  AccountBotDeveloperProvider._({
    required AccountBotDeveloperFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountBotDeveloperProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountBotDeveloperHash();

  @override
  String toString() {
    return r'accountBotDeveloperProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnDeveloper?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnDeveloper?> create(Ref ref) {
    final argument = this.argument as String;
    return accountBotDeveloper(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountBotDeveloperProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountBotDeveloperHash() =>
    r'673534770640a8cf1484ea0af0f4d0ef283ef157';

final class AccountBotDeveloperFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnDeveloper?>, String> {
  AccountBotDeveloperFamily._()
    : super(
        retry: null,
        name: r'accountBotDeveloperProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountBotDeveloperProvider call(String uname) =>
      AccountBotDeveloperProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountBotDeveloperProvider';
}

@ProviderFor(accountPublishers)
final accountPublishersProvider = AccountPublishersFamily._();

final class AccountPublishersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnPublisher>>,
          List<SnPublisher>,
          FutureOr<List<SnPublisher>>
        >
    with
        $FutureModifier<List<SnPublisher>>,
        $FutureProvider<List<SnPublisher>> {
  AccountPublishersProvider._({
    required AccountPublishersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountPublishersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountPublishersHash();

  @override
  String toString() {
    return r'accountPublishersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnPublisher>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnPublisher>> create(Ref ref) {
    final argument = this.argument as String;
    return accountPublishers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountPublishersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountPublishersHash() => r'bbe05ec72c9f070406b8fdf68a5038cf52aaba4d';

final class AccountPublishersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnPublisher>>, String> {
  AccountPublishersFamily._()
    : super(
        retry: null,
        name: r'accountPublishersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountPublishersProvider call(String id) =>
      AccountPublishersProvider._(argument: id, from: this);

  @override
  String toString() => r'accountPublishersProvider';
}

@ProviderFor(accountPunishmentOverview)
final accountPunishmentOverviewProvider = AccountPunishmentOverviewFamily._();

final class AccountPunishmentOverviewProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnAccountPunishment?>,
          SnAccountPunishment?,
          FutureOr<SnAccountPunishment?>
        >
    with
        $FutureModifier<SnAccountPunishment?>,
        $FutureProvider<SnAccountPunishment?> {
  AccountPunishmentOverviewProvider._({
    required AccountPunishmentOverviewFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountPunishmentOverviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountPunishmentOverviewHash();

  @override
  String toString() {
    return r'accountPunishmentOverviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnAccountPunishment?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnAccountPunishment?> create(Ref ref) {
    final argument = this.argument as String;
    return accountPunishmentOverview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountPunishmentOverviewProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountPunishmentOverviewHash() =>
    r'baf11e22c68d5fb2ec142245814c07823c20206e';

final class AccountPunishmentOverviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnAccountPunishment?>, String> {
  AccountPunishmentOverviewFamily._()
    : super(
        retry: null,
        name: r'accountPunishmentOverviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountPunishmentOverviewProvider call(String uname) =>
      AccountPunishmentOverviewProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountPunishmentOverviewProvider';
}
