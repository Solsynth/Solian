import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const _libwebpRepo = 'https://github.com/swipelab/libwebp.git';

// Pinned commit for reproducible builds: the upstream repo is untagged and
// `--depth 1` floating-HEAD clones would silently change the toolchain between
// builds (and break entirely if the repo moves or is deleted). Bump
// deliberately, then re-verify the Windows build.
const _libwebpCommit = '45102247a82396fabac5241c64305b13ed711335';

String _getCacheDir() {
  if (Platform.isWindows) {
    // Use LOCALAPPDATA on Windows (e.g., C:\Users\<user>\AppData\Local)
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null) {
      return '$localAppData\\swipelab_webp';
    }
    // Fallback to USERPROFILE
    final userProfile = Platform.environment['USERPROFILE'] ?? '';
    return '$userProfile\\.cache\\swipelab_webp';
  }
  // Unix-like systems (macOS, Linux)
  final home = Platform.environment['HOME'] ?? '';
  return '$home/.cache/swipelab_webp';
}

Future<String> _ensureLibwebp(Logger logger) async {
  final cacheDir = _getCacheDir();
  final separator = Platform.isWindows ? '\\' : '/';
  final libwebpPath = '$cacheDir${separator}libwebp';

  if (Directory(libwebpPath).existsSync()) {
    logger.info('libwebp found at $libwebpPath');
    return libwebpPath;
  }

  logger.info('libwebp not found, cloning from $_libwebpRepo...');

  // Create cache directory if it doesn't exist
  await Directory(cacheDir).create(recursive: true);

  // Clone libwebp at the pinned commit so every build (local and CI) uses the
  // same source. Shallow-fetch the specific commit; no branch moving under us.
  final init = await Process.run(
    'git',
    ['init', libwebpPath],
    workingDirectory: cacheDir,
  );
  if (init.exitCode != 0) {
    throw Exception('Failed to init libwebp repo: ${init.stderr}');
  }
  final remote = await Process.run(
    'git',
    ['remote', 'add', 'origin', _libwebpRepo],
    workingDirectory: libwebpPath,
  );
  if (remote.exitCode != 0) {
    throw Exception('Failed to add libwebp remote: ${remote.stderr}');
  }
  final fetch = await Process.run(
    'git',
    ['fetch', '--depth', '1', 'origin', _libwebpCommit],
    workingDirectory: libwebpPath,
  );
  if (fetch.exitCode != 0) {
    throw Exception(
      'Failed to fetch libwebp $_libwebpCommit: ${fetch.stderr}\n'
      'Please ensure git is installed and you have internet access.\n'
      'Alternatively, manually clone $_libwebpRepo to $libwebpPath',
    );
  }
  final checkout = await Process.run(
    'git',
    ['checkout', 'FETCH_HEAD'],
    workingDirectory: libwebpPath,
  );
  if (checkout.exitCode != 0) {
    throw Exception(
      'Failed to check out libwebp $_libwebpCommit: ${checkout.stderr}',
    );
  }

  logger.info('libwebp cloned successfully to $libwebpPath');
  return libwebpPath;
}

void main(List<String> args) async {
  await build(args, (input, output) async {
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message));

    final packageName = input.packageName;

    // Ensure libwebp is available (clone if needed)
    final libwebpPath = await _ensureLibwebp(logger);

    // Collect all libwebp source files
    final webpSources = <String>[
      // Our wrapper
      'src/swipelab_webp.c',
      // sharpyuv
      ...Directory('$libwebpPath/sharpyuv')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.c'))
          .map((f) => f.path),
      // src/enc
      ...Directory('$libwebpPath/src/enc')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.c'))
          .map((f) => f.path),
      // src/dsp
      ...Directory('$libwebpPath/src/dsp')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.c'))
          .map((f) => f.path),
      // src/utils
      ...Directory('$libwebpPath/src/utils')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.c'))
          .map((f) => f.path),
    ];

    // On Windows, cl.exe rejects command lines longer than 8191 characters.
    // libwebp's source tree (110+ files with absolute paths) blows past that
    // limit, so pass the sources via a response file (`@file`), which cl.exe
    // expands without the command-line length restriction. Other platforms
    // keep passing sources directly.
    final isWindows = Platform.isWindows;
    final String? sourcesRsp;
    if (isWindows) {
      // cl.exe resolves relative paths against its working directory, not the
      // package root, so make every entry absolute before writing the file.
      final absoluteSources = [
        for (final source in webpSources)
          Uri.file(source).isAbsolute
              ? Uri.file(source).toFilePath()
              : input.packageRoot.resolve(source).toFilePath(),
      ];
      final rsp = input.outputDirectory.resolve('webp_sources.rsp');
      final rspFile = File.fromUri(rsp);
      await rspFile.parent.create(recursive: true);
      // Quote each path so paths containing spaces survive cl.exe's
      // whitespace-separated response-file parsing.
      await rspFile.writeAsString(
        absoluteSources.map((s) => '"$s"').join('\n'),
      );
      sourcesRsp = '@${rsp.toFilePath()}';
    } else {
      sourcesRsp = null;
    }

    final builder = CBuilder.library(
      name: packageName,
      assetName: 'swipelab_webp.dart',
      sources: isWindows ? const [] : webpSources,
      includes: [
        libwebpPath,
        '$libwebpPath/src',
      ],
      flags: [
        '-DWEBP_USE_THREAD=1',
        '-DWEBP_NEAR_LOSSLESS=1',
        if (sourcesRsp != null) sourcesRsp,
      ],
      // Link against libm for math functions (not needed on Windows)
      libraries: isWindows ? [] : ['m'],
    );

    await builder.run(
      input: input,
      output: output,
      logger: logger,
    );

    // CBuilder only records `sources` as dependencies; the response-file
    // sources are invisible to it, so track them here to keep incremental
    // builds correct.
    if (isWindows) {
      output.dependencies.addAll(webpSources.map(Uri.file));
    }
  });
}
