// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(translateString)
final translateStringProvider = TranslateStringFamily._();

final class TranslateStringProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  TranslateStringProvider._({
    required TranslateStringFamily super.from,
    required TranslateQuery super.argument,
  }) : super(
         retry: null,
         name: r'translateStringProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$translateStringHash();

  @override
  String toString() {
    return r'translateStringProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as TranslateQuery;
    return translateString(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TranslateStringProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$translateStringHash() => r'51d638cf07cbf3ffa9469298f5bd9c667bc0ccb7';

final class TranslateStringFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, TranslateQuery> {
  TranslateStringFamily._()
    : super(
        retry: null,
        name: r'translateStringProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TranslateStringProvider call(TranslateQuery query) =>
      TranslateStringProvider._(argument: query, from: this);

  @override
  String toString() => r'translateStringProvider';
}

@ProviderFor(detectStringLanguage)
final detectStringLanguageProvider = DetectStringLanguageFamily._();

final class DetectStringLanguageProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  DetectStringLanguageProvider._({
    required DetectStringLanguageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detectStringLanguageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detectStringLanguageHash();

  @override
  String toString() {
    return r'detectStringLanguageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    final argument = this.argument as String;
    return detectStringLanguage(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DetectStringLanguageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detectStringLanguageHash() =>
    r'24fbf52edbbffcc8dc4f09f7206f82d69728e703';

final class DetectStringLanguageFamily extends $Family
    with $FunctionalFamilyOverride<String?, String> {
  DetectStringLanguageFamily._()
    : super(
        retry: null,
        name: r'detectStringLanguageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetectStringLanguageProvider call(String text) =>
      DetectStringLanguageProvider._(argument: text, from: this);

  @override
  String toString() => r'detectStringLanguageProvider';
}
