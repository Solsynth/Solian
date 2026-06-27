// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey_list.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(surveyWithStats)
final surveyWithStatsProvider = SurveyWithStatsFamily._();

final class SurveyWithStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnSurveyWithStats>,
          SnSurveyWithStats,
          FutureOr<SnSurveyWithStats>
        >
    with
        $FutureModifier<SnSurveyWithStats>,
        $FutureProvider<SnSurveyWithStats> {
  SurveyWithStatsProvider._({
    required SurveyWithStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'surveyWithStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$surveyWithStatsHash();

  @override
  String toString() {
    return r'surveyWithStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnSurveyWithStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnSurveyWithStats> create(Ref ref) {
    final argument = this.argument as String;
    return surveyWithStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SurveyWithStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$surveyWithStatsHash() => r'1f22a5ca8b0e218e53a914c5a1dd7a66d4742b34';

final class SurveyWithStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnSurveyWithStats>, String> {
  SurveyWithStatsFamily._()
    : super(
        retry: null,
        name: r'surveyWithStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SurveyWithStatsProvider call(String id) =>
      SurveyWithStatsProvider._(argument: id, from: this);

  @override
  String toString() => r'surveyWithStatsProvider';
}
