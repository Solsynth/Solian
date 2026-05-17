// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driveFileInfo)
final driveFileInfoProvider = DriveFileInfoFamily._();

final class DriveFileInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<SnCloudFile>,
          SnCloudFile,
          FutureOr<SnCloudFile>
        >
    with $FutureModifier<SnCloudFile>, $FutureProvider<SnCloudFile> {
  DriveFileInfoProvider._({
    required DriveFileInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driveFileInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driveFileInfoHash();

  @override
  String toString() {
    return r'driveFileInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SnCloudFile> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SnCloudFile> create(Ref ref) {
    final argument = this.argument as String;
    return driveFileInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriveFileInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driveFileInfoHash() => r'475f3c29be4b108319e065c8dae326449c93ed23';

final class DriveFileInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SnCloudFile>, String> {
  DriveFileInfoFamily._()
    : super(
        retry: null,
        name: r'driveFileInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DriveFileInfoProvider call(String fileId) =>
      DriveFileInfoProvider._(argument: fileId, from: this);

  @override
  String toString() => r'driveFileInfoProvider';
}

@ProviderFor(driveFilePermissions)
final driveFilePermissionsProvider = DriveFilePermissionsFamily._();

final class DriveFilePermissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SnFilePermission>>,
          List<SnFilePermission>,
          FutureOr<List<SnFilePermission>>
        >
    with
        $FutureModifier<List<SnFilePermission>>,
        $FutureProvider<List<SnFilePermission>> {
  DriveFilePermissionsProvider._({
    required DriveFilePermissionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'driveFilePermissionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$driveFilePermissionsHash();

  @override
  String toString() {
    return r'driveFilePermissionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SnFilePermission>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SnFilePermission>> create(Ref ref) {
    final argument = this.argument as String;
    return driveFilePermissions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DriveFilePermissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$driveFilePermissionsHash() =>
    r'016b24346de525706d1dfeeded5b0e120353c0dd';

final class DriveFilePermissionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SnFilePermission>>, String> {
  DriveFilePermissionsFamily._()
    : super(
        retry: null,
        name: r'driveFilePermissionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DriveFilePermissionsProvider call(String fileId) =>
      DriveFilePermissionsProvider._(argument: fileId, from: this);

  @override
  String toString() => r'driveFilePermissionsProvider';
}
