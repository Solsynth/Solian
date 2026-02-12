// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driveFileUploader)
final driveFileUploaderProvider = DriveFileUploaderProvider._();

final class DriveFileUploaderProvider
    extends $FunctionalProvider<FileUploader, FileUploader, FileUploader>
    with $Provider<FileUploader> {
  DriveFileUploaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveFileUploaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveFileUploaderHash();

  @$internal
  @override
  $ProviderElement<FileUploader> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FileUploader create(Ref ref) {
    return driveFileUploader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileUploader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileUploader>(value),
    );
  }
}

String _$driveFileUploaderHash() => r'0ee829472568dea37bfa7dd90a498282a94fb659';

@ProviderFor(driveFileDownloader)
final driveFileDownloaderProvider = DriveFileDownloaderProvider._();

final class DriveFileDownloaderProvider
    extends
        $FunctionalProvider<
          FileDownloadService,
          FileDownloadService,
          FileDownloadService
        >
    with $Provider<FileDownloadService> {
  DriveFileDownloaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveFileDownloaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveFileDownloaderHash();

  @$internal
  @override
  $ProviderElement<FileDownloadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FileDownloadService create(Ref ref) {
    return driveFileDownloader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FileDownloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FileDownloadService>(value),
    );
  }
}

String _$driveFileDownloaderHash() =>
    r'c8c55bd60d200b381a2e5a1fd80f342b8109b5e3';
