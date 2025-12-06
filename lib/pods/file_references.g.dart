// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_references.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fileReferences)
const fileReferencesProvider = FileReferencesFamily._();

final class FileReferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Reference>>,
          List<Reference>,
          FutureOr<List<Reference>>
        >
    with $FutureModifier<List<Reference>>, $FutureProvider<List<Reference>> {
  const FileReferencesProvider._({
    required FileReferencesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fileReferencesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fileReferencesHash();

  @override
  String toString() {
    return r'fileReferencesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Reference>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Reference>> create(Ref ref) {
    final argument = this.argument as String;
    return fileReferences(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FileReferencesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fileReferencesHash() => r'd66c678c221f61978bdb242b98e6dbe31d0c204b';

final class FileReferencesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Reference>>, String> {
  const FileReferencesFamily._()
    : super(
        retry: null,
        name: r'fileReferencesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FileReferencesProvider call(String fileId) =>
      FileReferencesProvider._(argument: fileId, from: this);

  @override
  String toString() => r'fileReferencesProvider';
}
