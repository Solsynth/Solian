import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/screens/upload_tasks.dart';
import 'package:island/tasks/app_task.dart';
import 'package:island/tasks/tasks_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Fake DysonFS direct-upload API: prepare (single-PUT and multipart),
/// per-part presign, and complete-direct. Part PUTs go to a real loopback
/// HTTP server, matching the client's bare-Dio PUT behavior.
class _FakeDysonFSAdapter implements HttpClientAdapter {
  final String s3Base;

  _FakeDysonFSAdapter(this.s3Base);

  int prepareCalls = 0;
  bool lastPrepareMultipart = false;
  bool? lastWantThumbnail;
  bool? lastWantCompression;
  Map<String, dynamic>? lastClientAnalysis;
  int completeCalls = 0;
  int lastFileSize = 0;
  String? lastFileName;
  final List<int> partRequests = [];

  /// When true, prepare responds with a single `upload_url` (the
  /// pre-multipart contract) instead of multipart session fields.
  bool singlePut = false;
  bool includeClientDerivativeUrls = false;

  /// Part numbers the fake server reports as already uploaded, so prepare
  /// returns a resumed session the client must skip.
  List<int> preloadedParts = const [];

  static const int partSize = 5 * 1024 * 1024;

  Future<Map<String, dynamic>> _readJsonBody(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
  ) async {
    if (requestStream != null) {
      final builder = BytesBuilder(copy: false);
      await for (final chunk in requestStream) {
        builder.add(chunk);
      }
      return jsonDecode(utf8.decode(builder.takeBytes()))
          as Map<String, dynamic>;
    }
    final data = options.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  ResponseBody _json(int status, Map<String, dynamic> body) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.path;
    if (path.startsWith('/drive/files/upload/prepare')) {
      prepareCalls++;
      final body = await _readJsonBody(options, requestStream);
      lastPrepareMultipart = body['multipart'] == true;
      lastWantThumbnail = body['want_thumbnail'] as bool?;
      lastWantCompression = body['want_compression'] as bool?;
      final rawAnalysis = body['client_analysis'];
      lastClientAnalysis = rawAnalysis is Map
          ? Map<String, dynamic>.from(rawAnalysis)
          : null;
      lastFileSize = body['file_size'] as int;
      lastFileName = body['file_name']?.toString();
      final size = lastFileSize;
      if (singlePut) {
        return _json(200, {
          'task_id': 'task-1',
          'upload_id': 'upload-1',
          'status': 1,
          'object_key': 'objects/task-1',
          'upload_url': '$s3Base/single',
          'compression_upload_url': includeClientDerivativeUrls
              ? '$s3Base/compression'
              : null,
          'thumbnail_upload_url': includeClientDerivativeUrls
              ? '$s3Base/thumbnail'
              : null,
          'content_type': body['content_type'],
        });
      }
      return _json(200, {
        'task_id': 'task-1',
        'upload_id': 'upload-1',
        'status': 1,
        'object_key': 'objects/task-1',
        'part_size': partSize,
        'part_count': (size / partSize).ceil(),
        'uploaded_parts': [...preloadedParts],
        'content_type': body['content_type'],
      });
    }
    if (path.endsWith('/part')) {
      final body = await _readJsonBody(options, requestStream);
      final partNumber = body['part_number'] as int;
      partRequests.add(partNumber);
      return _json(200, {
        'part_number': partNumber,
        'upload_url': '$s3Base/part/$partNumber',
        'expires_in': 900,
        'content_type': body['content_type'],
      });
    }
    if (path.endsWith('/complete')) {
      completeCalls++;
      return _json(200, {
        'file': {
          'id': 'cloud-file-1',
          'account_id': 'account-1',
          'description': null,
          'indexed': false,
          'is_folder': false,
          'is_marked_recycle': false,
          'name': 'big.bin',
          'object': {
            'id': 'object-1',
            'size': lastFileSize,
            'hash': 'hash-1',
            'meta': {},
            'has_compression': false,
            'has_thumbnail': false,
            'file_replicas': <Object>[],
            'created_at': '2026-08-01T00:00:00Z',
            'updated_at': '2026-08-01T00:00:00Z',
            'deleted_at': null,
          },
          'object_id': 'object-1',
          'parent_id': 'parent-1',
          'resource_identifier': 'resource-1',
          'storage_id': 'pool-1',
          'storage_url': s3Base,
          'mime_type': 'application/octet-stream',
          'application_type': null,
          'usage': null,
          'uploaded_at': '2026-08-01T00:00:00Z',
          'expired_at': null,
          'updated_at': '2026-08-01T00:00:00Z',
          'created_at': '2026-08-01T00:00:00Z',
          'deleted_at': null,
        },
      });
    }
    return _json(404, {'error': 'not found'});
  }
}

/// Minimal fake S3: accepts PUTs (presigned part uploads and the single-PUT
/// URL) and stores their bodies keyed by URL path.
class _FakeS3Server {
  final HttpServer server;
  final Map<String, Uint8List> objects = {};

  _FakeS3Server._(this.server);

  static Future<_FakeS3Server> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fake = _FakeS3Server._(server);
    server.listen((request) async {
      if (request.method == 'PUT') {
        final builder = BytesBuilder(copy: false);
        await for (final chunk in request) {
          builder.add(chunk);
        }
        fake.objects[request.uri.path] = builder.takeBytes();
        request.response.statusCode = 200;
        request.response.headers.set(HttpHeaders.etagHeader, '"etag"');
        await request.response.close();
        return;
      }
      request.response.statusCode = 404;
      await request.response.close();
    });
    return fake;
  }

  Future<void> close() => server.close(force: true);

  String get base => 'http://127.0.0.1:${server.port}';
}

final _enhancedFileUploaderProvider = Provider<EnhancedFileUploader>(
  (ref) => EnhancedFileUploader(ref),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeS3Server s3;
  late _FakeDysonFSAdapter dyson;
  late ProviderContainer container;

  setUpAll(() async {
    // flutter_test blocks real HTTP by default; the S3 PUTs need loopback.
    HttpOverrides.global = null;
    s3 = await _FakeS3Server.start();
  });

  tearDownAll(() async {
    await s3.close();
  });

  setUp(() async {
    s3.objects.clear();
    dyson = _FakeDysonFSAdapter(s3.base);
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        apiClientProvider.overrideWithValue(Dio()..httpClientAdapter = dyson),
        sharedPreferencesProvider.overrideWithValue(preferences),
        tokenProvider.overrideWithValue(null),
        weakInternetModeProvider.overrideWithValue(false),
      ],
    );
    // tasksProvider is autoDispose; in production the task tray listens to
    // it. Keep it alive here so in-flight uploads can update task state.
    container.listen(tasksProvider, (_, _) {});
  });

  tearDown(() {
    container.dispose();
  });

  test('large XFile uploads via S3 multipart: prepare, per-part presign, '
      'bare PUTs, complete-direct', () async {
    final file = File(
      '${Directory.systemTemp.path}/'
      's3_multipart_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    final source = Uint8List(driveS3DirectMultipartMinFileSizeBytes);
    await file.writeAsBytes(source, flush: true);
    addTearDown(() => file.deleteSync());
    final uploader = container.read(driveFileUploaderProvider);

    double? lastProgress;
    final stages = <String>[];
    final result = await uploader.tryUploadViaS3Direct(
      fileData: XFile(file.path),
      fileName: 'big.bin',
      contentType: 'application/octet-stream',
      parentId: 'parent-1',
      onStage: (stage, progress) {
        if (stages.isEmpty || stages.last != stage) {
          stages.add(stage);
        }
      },
      onProgress: (progress, estimate) {
        if (progress != null) {
          lastProgress = progress;
        }
      },
    );

    expect(result, isNotNull);
    expect(result!.id, 'cloud-file-1');

    // prepare asked for multipart exactly once; complete-direct ran once.
    expect(dyson.prepareCalls, 1);
    expect(dyson.lastPrepareMultipart, isTrue);
    expect(dyson.completeCalls, 1);

    // every part was presigned exactly once, in order.
    const partCount =
        driveS3DirectMultipartMinFileSizeBytes ~/ (5 * 1024 * 1024);
    expect(dyson.partRequests, List.generate(partCount, (index) => index + 1));

    // all part PUTs landed on the fake S3, sized correctly, and the
    // concatenation reproduces the source file byte-for-byte (this catches
    // range-read boundary bugs).
    expect(s3.objects.length, partCount);
    var total = 0;
    for (final part in s3.objects.values) {
      total += part.length;
    }
    expect(total, source.length);

    final rebuilt = Uint8List(source.length);
    var offset = 0;
    for (var n = 1; n <= partCount; n++) {
      final part = s3.objects['/part/$n']!;
      expect(part.length, lessThanOrEqualTo(5 * 1024 * 1024));
      rebuilt.setRange(offset, offset + part.length, part);
      offset += part.length;
    }
    expect(
      stages,
      containsAllInOrder([
        'hashing',
        'preparing_media',
        'creating_upload',
        'uploading_source',
        'finalizing',
      ]),
    );
    expect(rebuilt, equals(source));
    expect(offset, source.length);

    expect(lastProgress, 1.0);
  });

  test('resumed multipart session skips already-uploaded parts', () async {
    final file = File(
      '${Directory.systemTemp.path}/'
      's3_resume_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    final source = Uint8List(driveS3DirectMultipartMinFileSizeBytes);
    await file.writeAsBytes(source, flush: true);
    addTearDown(() => file.deleteSync());

    // The server reports parts 2, 5 and 8 as already uploaded (a resumed
    // session keyed by the file hash); the client must not presign or PUT
    // them, yet still count their bytes toward progress.
    dyson.preloadedParts = [2, 5, 8];

    final uploader = container.read(driveFileUploaderProvider);
    double? lastProgress;
    final result = await uploader.tryUploadViaS3Direct(
      fileData: XFile(file.path),
      fileName: 'big.bin',
      contentType: 'application/octet-stream',
      parentId: 'parent-1',
      onProgress: (progress, estimate) {
        if (progress != null) {
          lastProgress = progress;
        }
      },
    );

    expect(result, isNotNull);
    expect(dyson.completeCalls, 1);

    const partCount =
        driveS3DirectMultipartMinFileSizeBytes ~/ (5 * 1024 * 1024);
    final expected = [
      for (var n = 1; n <= partCount; n++)
        if (!dyson.preloadedParts.contains(n)) n,
    ];
    expect(dyson.partRequests, expected);

    // Skipped parts never reached the S3 server.
    expect(s3.objects.containsKey('/part/2'), isFalse);
    expect(s3.objects.containsKey('/part/5'), isFalse);
    expect(s3.objects.containsKey('/part/8'), isFalse);
    expect(s3.objects.length, expected.length);

    expect(lastProgress, 1.0);
  });

  test('small XFile still uses the single presigned PUT flow', () async {
    final file = File(
      '${Directory.systemTemp.path}/'
      's3_single_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    final source = Uint8List(1024 * 1024);
    await file.writeAsBytes(source, flush: true);
    addTearDown(() => file.deleteSync());

    // Single-PUT prepare returns an upload_url instead of multipart fields.
    dyson.singlePut = true;

    final uploader = container.read(driveFileUploaderProvider);
    final result = await uploader.tryUploadViaS3Direct(
      fileData: XFile(file.path),
      fileName: 'small.bin',
      contentType: 'application/octet-stream',
      parentId: 'parent-1',
    );

    expect(result, isNotNull);
    expect(result!.id, 'cloud-file-1');
    expect(dyson.lastPrepareMultipart, isFalse);
    expect(s3.objects['/single'], isNotNull);
    expect(s3.objects['/single']!.length, source.length);
    expect(s3.objects['/single'], equals(source));
  });
  test('enhanced upload tracks task progress during direct PUT', () async {
    final file = File(
      '${Directory.systemTemp.path}/'
      's3_task_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    final source = Uint8List(1024 * 1024);
    await file.writeAsBytes(source, flush: true);
    addTearDown(() => file.deleteSync());

    dyson.singlePut = true;
    final observedProgress = <double>[];
    final subscription = container.listen(tasksProvider, (_, next) {
      if (next.isNotEmpty) observedProgress.add(next.last.progress);
    });
    addTearDown(subscription.close);

    final uploader = container.read(_enhancedFileUploaderProvider);
    final result = await uploader.uploadFile(
      fileData: XFile(file.path),
      fileName: 'task.bin',
      contentType: 'application/octet-stream',
      parentId: 'parent-1',
    );

    expect(result.id, 'cloud-file-1');
    expect(observedProgress, contains(0.82));
    expect(observedProgress.last, 1.0);
    final task = container.read(tasksProvider).single;
    expect(task.status, AppTaskStatus.completed);
    expect(task.metadata?['stage'], DriveUploadStage.completed);
  });
  test(
    'audio upload preserves fallback when local probing is unavailable',
    () async {
      final file = File(
        '${Directory.systemTemp.path}/'
        's3_audio_${DateTime.now().microsecondsSinceEpoch}.mp3',
      );
      final source = Uint8List(64 * 1024);
      await file.writeAsBytes(source, flush: true);
      addTearDown(() => file.deleteSync());

      dyson.singlePut = true;
      final uploader = container.read(driveFileUploaderProvider);
      final result = await uploader.tryUploadViaS3Direct(
        fileData: XFile(file.path),
        fileName: 'audio.mp3',
        contentType: 'audio/mpeg',
        parentId: 'parent-1',
      );

      expect(result, isNotNull);
      expect(dyson.lastPrepareMultipart, isFalse);
      expect(s3.objects['/single'], equals(source));
    },
  );

  test(
    'image direct upload requests only the compression derivative',
    () async {
      dyson.singlePut = true;
      dyson.includeClientDerivativeUrls = true;
      final source = Uint8List.fromList(
        img.encodeJpg(img.Image(width: 2, height: 2)),
      );
      final uploader = container.read(driveFileUploaderProvider);
      final result = await uploader.tryUploadViaS3Direct(
        fileData: source,
        fileName: 'image.jpg',
        contentType: 'image/jpeg',
        parentId: 'parent-1',
      );

      expect(result, isNotNull);
      expect(dyson.lastWantThumbnail, isFalse);
      expect(dyson.lastWantCompression, isTrue);
      final analysis = dyson.lastClientAnalysis;
      expect(analysis?['width'], 2);
      expect(analysis?['height'], 2);
      final blurhash = analysis?['blurhash'] as String?;
      expect(blurhash, isNotNull);
      expect(blurhash, hasLength(28));
      expect(s3.objects['/thumbnail'], isNull);
      final compression = s3.objects['/compression'];
      expect(compression, isNotNull);
      expect(utf8.decode(compression!.sublist(0, 4)), 'RIFF');
      expect(utf8.decode(compression.sublist(8, 12)), 'WEBP');
      expect(compression.length, lessThan(source.length));
    },
  );
  test('image compression setting can disable the derivative', () async {
    dyson.singlePut = true;
    dyson.includeClientDerivativeUrls = true;
    final source = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 2, height: 2)),
    );
    final uploader = container.read(driveFileUploaderProvider);

    final result = await uploader.tryUploadViaS3Direct(
      fileData: source,
      fileName: 'image-disabled.jpg',
      contentType: 'image/jpeg',
      parentId: 'parent-1',
      imageCompressionEnabled: false,
    );

    expect(result, isNotNull);
    expect(dyson.lastWantCompression, isFalse);
    expect(s3.objects['/compression'], isNull);
  });

  test('image compression quality changes the WebP derivative', () async {
    dyson.singlePut = true;
    dyson.includeClientDerivativeUrls = true;
    final sourceImage = img.Image(width: 128, height: 128);
    for (var y = 0; y < sourceImage.height; y++) {
      for (var x = 0; x < sourceImage.width; x++) {
        sourceImage.setPixelRgb(
          x,
          y,
          (x * 17 + y * 3) % 256,
          (x * 5 + y * 19) % 256,
          (x * 11 + y * 7) % 256,
        );
      }
    }
    final source = Uint8List.fromList(img.encodeJpg(sourceImage, quality: 100));
    final settings = container.read(appSettingsProvider.notifier);
    container.listen(appSettingsProvider, (_, _) {});
    settings.setImageCompressionQuality(20);
    final uploader = container.read(driveFileUploaderProvider);

    await uploader.tryUploadViaS3Direct(
      fileData: source,
      fileName: 'image-low-quality.jpg',
      contentType: 'image/jpeg',
      parentId: 'parent-1',
    );
    final lowQuality = s3.objects['/compression'];
    expect(lowQuality, isNotNull);
    settings.setImageCompressionQuality(100);
    await uploader.tryUploadViaS3Direct(
      fileData: source,
      fileName: 'image-high-quality.jpg',
      contentType: 'image/jpeg',
      parentId: 'parent-1',
    );
    final highQuality = s3.objects['/compression'];
    expect(highQuality, isNotNull);
    expect(highQuality, isNot(equals(lowQuality)));
  });

  test('animated GIF upload skips the lossy compression derivative', () async {
    dyson.singlePut = true;
    dyson.includeClientDerivativeUrls = true;
    final animated = img.Image(width: 2, height: 2);
    animated.setPixelRgb(0, 0, 255, 0, 0);
    final secondFrame = img.Image(width: 2, height: 2);
    secondFrame.setPixelRgb(0, 0, 0, 0, 255);
    animated.addFrame(secondFrame);
    final source = Uint8List.fromList(img.encodeGif(animated));
    final uploader = container.read(driveFileUploaderProvider);

    final result = await uploader.tryUploadViaS3Direct(
      fileData: source,
      fileName: 'animated.gif',
      contentType: 'image/gif',
      parentId: 'parent-1',
    );

    expect(result, isNotNull);
    expect(dyson.lastWantCompression, isFalse);
    expect(s3.objects['/compression'], isNull);
    expect(s3.objects['/single'], equals(source));
  });

  test(
    'byte-backed upload (editor flow) sends displayName as file_name',
    () async {
      // Mirrors ImagePickerEditor.startUpload: picked bytes wrapped in an
      // in-memory XFile whose real name is carried via UniversalFile.displayName
      // (cross_file's io implementation drops `fromData`'s `name:` argument,
      // which previously produced an empty `file_name` and a server-side
      // "file_name and positive file_size are required" rejection).
      dyson.singlePut = true;
      final bytes = Uint8List.fromList(
        List.generate(1024 * 1024, (i) => i % 251),
      );
      final uploader = container.read(driveFileUploaderProvider);
      final result = await uploader
          .createCloudFile(
            fileData: UniversalFile(
              data: XFile.fromData(
                bytes,
                name: 'IMG_0001.jpg',
                mimeType: 'image/jpeg',
              ),
              type: UniversalFileType.image,
              displayName: 'IMG_0001.jpg',
            ),
          )
          .future;

      expect(result, isNotNull);
      expect(dyson.prepareCalls, 1);
      expect(dyson.lastFileName, 'IMG_0001.jpg');
      expect(dyson.lastFileSize, bytes.length);
      // The in-memory bytes reached the fake S3 intact.
      expect(s3.objects['/single'], equals(bytes));
    },
  );

  test('in-memory XFile without displayName has no file name on io', () async {
    // Documents the cross_file trap that broke profile uploads: on io
    // platforms `XFile.fromData` derives `name` from the (empty) path, so a
    // byte-backed XFile without a path has an empty name. Callers must pass
    // `UniversalFile.displayName` (as the editor now does); otherwise the
    // upload would hit the server's "file_name and positive file_size are
    // required" validation.
    dyson.singlePut = true;
    final uploader = container.read(driveFileUploaderProvider);
    final result = await uploader
        .createCloudFile(
          fileData: UniversalFile(
            data: XFile.fromData(
              Uint8List.fromList(List.generate(64, (i) => i)),
              name: 'dropped.jpg',
            ),
            type: UniversalFileType.image,
          ),
        )
        .future;

    expect(result, isNotNull);
    expect(dyson.lastFileName, isEmpty);
  });
}
