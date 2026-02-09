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

String _$accountHash() => r'5e2b7bd59151b4638a5561f495537c259f767123';

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

String _$accountBadgesHash() => r'68db63f49827020beecbdbf20529520d0cd14a7d';

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

@ProviderFor(accountAppbarForcegroundColor)
final accountAppbarForcegroundColorProvider =
    AccountAppbarForcegroundColorFamily._();

final class AccountAppbarForcegroundColorProvider
    extends $FunctionalProvider<AsyncValue<Color?>, Color?, FutureOr<Color?>>
    with $FutureModifier<Color?>, $FutureProvider<Color?> {
  AccountAppbarForcegroundColorProvider._({
    required AccountAppbarForcegroundColorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountAppbarForcegroundColorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountAppbarForcegroundColorHash();

  @override
  String toString() {
    return r'accountAppbarForcegroundColorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Color?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Color?> create(Ref ref) {
    final argument = this.argument as String;
    return accountAppbarForcegroundColor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AccountAppbarForcegroundColorProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountAppbarForcegroundColorHash() =>
    r'59e0049a5158ea653f0afd724df9ff2312b90050';

final class AccountAppbarForcegroundColorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Color?>, String> {
  AccountAppbarForcegroundColorFamily._()
    : super(
        retry: null,
        name: r'accountAppbarForcegroundColorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AccountAppbarForcegroundColorProvider call(String uname) =>
      AccountAppbarForcegroundColorProvider._(argument: uname, from: this);

  @override
  String toString() => r'accountAppbarForcegroundColorProvider';
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

String _$accountDirectChatHash() => r'71bc9eed34a436a3743e8ef87f7aaae861fc5746';

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
    r'319f743261b113a1d3c6a397d48d13c858312669';

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

String _$accountPublishersHash() => r'25f5695b4a5154163d77f1769876d826bf736609';

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
