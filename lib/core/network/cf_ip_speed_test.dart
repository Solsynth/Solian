import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:logging/logging.dart';

const cfIpv4Ranges = [
  '173.245.48.0/20',
  '103.21.244.0/22',
  '103.22.200.0/22',
  '103.31.4.0/22',
  '141.101.64.0/18',
  '108.162.192.0/18',
  '190.93.240.0/20',
  '188.114.96.0/20',
  '197.234.240.0/22',
  '198.41.128.0/17',
  '162.158.0.0/15',
  '104.16.0.0/13',
  '104.24.0.0/14',
  '172.64.0.0/13',
  '131.0.72.0/22',
];

const cfIpv6Ranges = [
  '2400:cb00::/32',
  '2606:4700::/32',
  '2803:f800::/32',
  '2405:b500::/32',
  '2405:8100::/32',
  '2a06:98c0::/29',
  '2c0f:f248::/32',
];

class CfIpTestResult {
  final String ip;
  final bool isIpv6;
  final int tcpPingMs;
  final int tcpReceived;
  final int tcpSended;
  final int? httpPingMs;
  final String? colo;
  final double? downloadSpeedMbps;

  CfIpTestResult({
    required this.ip,
    required this.isIpv6,
    required this.tcpPingMs,
    required this.tcpReceived,
    required this.tcpSended,
    this.httpPingMs,
    this.colo,
    this.downloadSpeedMbps,
  });

  double get tcpLossRate => tcpSended > 0 ? (tcpSended - tcpReceived) / tcpSended : 1.0;

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'isIpv6': isIpv6,
    'tcpPingMs': tcpPingMs,
    'tcpReceived': tcpReceived,
    'tcpSended': tcpSended,
    'httpPingMs': httpPingMs,
    'colo': colo,
    'downloadSpeedMbps': downloadSpeedMbps,
  };

  factory CfIpTestResult.fromJson(Map<String, dynamic> json) => CfIpTestResult(
    ip: json['ip'] as String,
    isIpv6: json['isIpv6'] as bool,
    tcpPingMs: json['tcpPingMs'] as int,
    tcpReceived: json['tcpReceived'] as int,
    tcpSended: json['tcpSended'] as int,
    httpPingMs: json['httpPingMs'] as int?,
    colo: json['colo'] as String?,
    downloadSpeedMbps: json['downloadSpeedMbps'] as double?,
  );
}

sealed class CfIpTestProgress {
  const CfIpTestProgress();
}

class CfIpTestPhase {
  final String name;
  final int current;
  final int total;

  const CfIpTestPhase({required this.name, required this.current, required this.total});
}

class CfIpTcpPingProgress extends CfIpTestProgress {
  final CfIpTestPhase phase;
  final int availableCount;
  final String? currentIp;
  final List<CfIpTestResult> results;

  const CfIpTcpPingProgress({
    required this.phase,
    required this.availableCount,
    required this.results,
    this.currentIp,
  });
}

class CfIpHttpPingProgress extends CfIpTestProgress {
  final CfIpTestPhase phase;
  final List<CfIpTestResult> results;
  final String? currentIp;

  const CfIpHttpPingProgress({required this.phase, required this.results, this.currentIp});
}

class CfIpDownloadProgress extends CfIpTestProgress {
  final CfIpTestPhase phase;
  final List<CfIpTestResult> results;
  final String? currentIp;

  const CfIpDownloadProgress({required this.phase, required this.results, this.currentIp});
}

class CfIpTestComplete extends CfIpTestProgress {
  final List<CfIpTestResult> results;

  const CfIpTestComplete({required this.results});
}

class CfIpTestError extends CfIpTestProgress {
  final String message;

  const CfIpTestError(this.message);
}

class CfIpTestCancelToken {
  bool _cancelled = false;
  bool _skipStageRequested = false;

  bool get cancelled => _cancelled;

  bool get skipStageRequested => _skipStageRequested;

  void cancel() {
    _cancelled = true;
  }

  void requestSkipStage() {
    _skipStageRequested = true;
  }

  bool consumeSkipStageRequest() {
    final requested = _skipStageRequested;
    _skipStageRequested = false;
    return requested;
  }
}

bool _isCancelled(CfIpTestCancelToken cancelToken) => cancelToken.cancelled;

class _Semaphore {
  final int max;
  int _current = 0;
  final _waiters = <Completer<void>>[];

  _Semaphore(this.max);

  Future<void> acquire() async {
    if (_current < max) {
      _current++;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete();
    } else {
      _current--;
    }
  }
}

class _MovingAverage {
  double _sum = 0;
  int _count = 0;

  void add(double value) {
    _sum += value;
    _count++;
  }

  double get value => _count > 0 ? _sum / _count : 0;
}

List<String> _generateIps(List<String> ranges, {bool quick = false, bool ipv6 = false}) {
  return _generateReferenceStyleIps(ranges, ipv6);
}

List<String> _interleaveIps(List<String> a, List<String> b) {
  final out = <String>[];
  final maxLen = a.length > b.length ? a.length : b.length;

  for (var i = 0; i < maxLen; i++) {
    if (i < a.length) out.add(a[i]);
    if (i < b.length) out.add(b[i]);
  }

  return out;
}

List<String> _generateReferenceStyleIps(List<String> ranges, bool ipv6) {
  final ips = <String>[];

  for (final range in ranges) {
    final parts = range.split('/');
    final ipStr = parts[0];
    final cidr = int.parse(parts[1]);
    if (ipv6) {
      ips.addAll(_generateReferenceStyleIpv6(ipStr, cidr));
    } else {
      ips.addAll(_generateReferenceStyleIpv4(ipStr, cidr));
    }
  }

  return ips;
}

List<String> _generateReferenceStyleIpv4(String ip, int cidr) {
  final octets = ip.split('.').map(int.parse).toList();
  final hostBits = 32 - cidr;

  if (hostBits <= 0) return [ip];

  final ipInt = _ipv4ToInt(octets);
  final mask = hostBits >= 32 ? 0 : (0xFFFFFFFF << hostBits) & 0xFFFFFFFF;
  final networkStart = ipInt & mask;
  final networkEnd = networkStart | (~mask & 0xFFFFFFFF);
  final random = Random();
  final out = <String>[];

  for (var blockStart = networkStart; blockStart <= networkEnd; blockStart += 256) {
    final blockEnd = blockStart + 255 <= networkEnd ? blockStart + 255 : networkEnd;
    final candidate = blockStart + random.nextInt(blockEnd - blockStart + 1);
    out.add(_formatIpv4Int(candidate));
  }

  return out;
}

int _ipv4ToInt(List<int> octets) {
  return (octets[0] << 24) | (octets[1] << 16) | (octets[2] << 8) | octets[3];
}

String _formatIpv4Int(int value) {
  final a = (value >> 24) & 0xFF;
  final b = (value >> 16) & 0xFF;
  final c = (value >> 8) & 0xFF;
  final d = value & 0xFF;
  return '$a.$b.$c.$d';
}

List<String> _generateReferenceStyleIpv6(String ip, int cidr) {
  final full = _expandIpv6(ip);
  final bytes = Uint8List(16);
  for (var i = 0; i < 8; i++) {
    final val = int.parse(full[i], radix: 16);
    bytes[i * 2] = (val >> 8) & 0xFF;
    bytes[i * 2 + 1] = val & 0xFF;
  }

  final hostBits = 128 - cidr;
  if (hostBits <= 0) return [_formatIpv6(bytes)];

  final random = Random();
  final out = <String>[];
  final current = Uint8List.fromList(bytes);

  while (_ipv6InNetwork(current, bytes, cidr)) {
    current[15] = random.nextInt(255);
    current[14] = random.nextInt(255);

    final targetIP = Uint8List.fromList(current);
    out.add(_formatIpv6(targetIP));

    for (var i = 13; i >= 0; i--) {
      final tempIP = current[i];
      current[i] = (current[i] + random.nextInt(255)) & 0xFF;
      if (current[i] >= tempIP) {
        break;
      }
    }
  }

  return out;
}

bool _ipv6InNetwork(Uint8List current, Uint8List network, int cidr) {
  final fullBytes = cidr ~/ 8;
  final remainingBits = cidr % 8;

  for (var i = 0; i < fullBytes; i++) {
    if (current[i] != network[i]) return false;
  }

  if (remainingBits == 0) return true;

  final mask = 0xFF << (8 - remainingBits) & 0xFF;
  return (current[fullBytes] & mask) == (network[fullBytes] & mask);
}

List<List<String>> _chunkIps(List<String> ips, int chunkSize) {
  if (chunkSize <= 0) return [ips];
  final chunks = <List<String>>[];
  for (var i = 0; i < ips.length; i += chunkSize) {
    final end = i + chunkSize > ips.length ? ips.length : i + chunkSize;
    chunks.add(ips.sublist(i, end));
  }
  return chunks;
}

void _generateRandomIpv4(String ip, int cidr, int count, Random random, List<String> out, int remainingBudget) {
  final ipBytes = ip.split('.').map(int.parse).toList();
  final maskBits = 32 - cidr;
  final hostBits4 = maskBits > 16 ? 16 : (maskBits > 8 ? maskBits - 8 : 0);
  final hostBits3 = maskBits > 8 ? (maskBits > 16 ? 8 : maskBits - 8) : 0;
  final hostBits2 = maskBits > 16 ? 8 : 0;

  final max4 = (1 << hostBits4) - 1;
  final max3 = (1 << hostBits3) - 1;
  final max2 = (1 << hostBits2) - 1;

  final base2 = ipBytes[2] & (~max3 & 0xFF);
  final base3 = ipBytes[3] & (~max4 & 0xFF);

  final limit = count < remainingBudget ? count : remainingBudget;
  for (var i = 0; i < limit; i++) {
    final b2 = base2 + (max2 > 0 ? random.nextInt(max2 + 1) : 0);
    final b3 = base3 + (max3 > 0 ? random.nextInt(max3 + 1) : 0);
    final b4 = random.nextInt(max4 + 1);
    out.add('${ipBytes[0]}.$b2.$b3.$b4');
  }
}

void _generateRandomIpv6(String ip, int cidr, int count, Random random, List<String> out, int remainingBudget) {
  final full = _expandIpv6(ip);
  final bytes = Uint8List(16);
  for (var i = 0; i < 8; i++) {
    final val = int.parse(full[i], radix: 16);
    bytes[i * 2] = (val >> 8) & 0xFF;
    bytes[i * 2 + 1] = val & 0xFF;
  }

  final limit = count < remainingBudget ? count : remainingBudget;

  if (limit <= 0) return;

  final current = Uint8List.fromList(bytes);
  while (out.length < limit && _ipv6InNetwork(current, bytes, cidr)) {
    current[15] = random.nextInt(255);
    current[14] = random.nextInt(255);

    final targetIP = Uint8List.fromList(current);
    out.add(_formatIpv6(targetIP));

    for (var i = 13; i >= 0; i--) {
      final tempIP = current[i];
      current[i] = (current[i] + random.nextInt(255)) & 0xFF;
      if (current[i] >= tempIP) {
        break;
      }
    }
  }
}

List<String> _expandIpv6(String ip) {
  final parts = ip.split('::');
  if (parts.length == 2) {
    final left = parts[0].isNotEmpty ? parts[0].split(':') : <String>[];
    final right = parts[1].isNotEmpty ? parts[1].split(':') : <String>[];
    final missing = 8 - left.length - right.length;
    final full = [...left, ...List.filled(missing, '0'), ...right];
    return full.map((s) => s.padLeft(4, '0')).toList();
  }
  return ip.split(':').map((s) => s.padLeft(4, '0')).toList();
}

String _formatIpv6(Uint8List bytes) {
  final groups = <String>[];
  for (var i = 0; i < 16; i += 2) {
    final val = (bytes[i] << 8) | bytes[i + 1];
    groups.add(val.toRadixString(16).padLeft(4, '0'));
  }
  var result = groups.join(':');
  result = result.replaceAll(RegExp(r'(:0){2,}'), '::');
  if (result.endsWith(':') && !result.endsWith('::')) result += '0';
  return result;
}

Future<(bool, Duration)> _tcpPing(String ip, int port, Duration timeout) async {
  try {
    final sw = Stopwatch()..start();
    final socket = await Socket.connect(ip, port, timeout: timeout);
    sw.stop();
    await socket.close();
    return (true, sw.elapsed);
  } catch (_) {
    return (false, Duration.zero);
  }
}

Future<CfIpTestResult> _tcpPingIp(String ip, int port, int times, Duration timeout) async {
  var received = 0;
  var totalDelay = Duration.zero;

  for (var i = 0; i < times; i++) {
    final (ok, delay) = await _tcpPing(ip, port, timeout);
    if (ok) {
      received++;
      totalDelay += delay;
    }
  }

  return CfIpTestResult(
    ip: ip,
    isIpv6: ip.contains(':'),
    tcpPingMs: received > 0 ? totalDelay.inMilliseconds ~/ received : 9999,
    tcpReceived: received,
    tcpSended: times,
  );
}

String? _extractColo(Map<String, String> headers) {
  final server = headers['server'] ?? '';
  if (server.contains('cloudflare')) {
    final cfRay = headers['cf-ray'] ?? '';
    if (cfRay.isNotEmpty) {
      final match = RegExp(r'[A-Z]{3}').firstMatch(cfRay);
      return match?.group(0);
    }
  }
  final cfPop = headers['x-amz-cf-pop'] ?? '';
  if (cfPop.isNotEmpty) {
    final match = RegExp(r'[A-Z]{3}').firstMatch(cfPop);
    return match?.group(0);
  }
  return null;
}

Future<CfIpTestResult> _httpPingIp(
  CfIpTestResult result,
  String url,
  int times,
  Duration timeout,
) async {
  var received = 0;
  var totalDelay = Duration.zero;
  String? colo;

  final uri = Uri.parse(url);
  final targetPort = uri.scheme == 'https' ? 443 : 80;

  for (var i = 0; i < times; i++) {
    try {
      final sw = Stopwatch()..start();
      final socket = await SecureSocket.connect(
        result.ip,
        targetPort,
        timeout: timeout,
        onBadCertificate: (_) => true,
      );
      final client = HttpClient();
      client.connectionFactory = (uri, proxyHost, proxyPort) async {
        return ConnectionTask.fromSocket(
          Future.value(socket),
          () {},
        );
      };

      final request = await client.getUrl(uri);
      request.followRedirects = false;
      final response = await request.close();
      sw.stop();

      if (response.statusCode == 200 || response.statusCode == 301 || response.statusCode == 302) {
        received++;
        totalDelay += sw.elapsed;
        if (colo == null) {
          final headers = <String, String>{};
          response.headers.forEach((key, values) {
            headers[key] = values.join(',');
          });
          colo = _extractColo(headers);
        }
      }

      await response.drain();
      client.close();
      await socket.close();
    } catch (_) {
      // skip
    }
  }

  return CfIpTestResult(
    ip: result.ip,
    isIpv6: result.isIpv6,
    tcpPingMs: result.tcpPingMs,
    tcpReceived: result.tcpReceived,
    tcpSended: result.tcpSended,
    httpPingMs: received > 0 ? totalDelay.inMilliseconds ~/ received : null,
    colo: colo,
  );
}

Future<CfIpTestResult> _downloadTestIp(
  CfIpTestResult result,
  String url,
  Duration timeout,
) async {
  try {
    final uri = Uri.parse(url);
    final targetPort = uri.scheme == 'https' ? 443 : 80;

    final socket = await SecureSocket.connect(
      result.ip,
      targetPort,
      timeout: timeout,
      onBadCertificate: (_) => true,
    );

    final client = HttpClient();
    client.connectionFactory = (uri, proxyHost, proxyPort) async {
      return ConnectionTask.fromSocket(
        Future.value(socket),
        () {},
      );
    };

    final request = await client.getUrl(uri);
    request.followRedirects = false;
    final response = await request.close();

    if (response.statusCode != 200) {
      client.close();
      await socket.close();
      return result;
    }

    final startTime = DateTime.now();
    final endTime = startTime.add(timeout);
    var contentRead = 0;
    final timeSlice = timeout ~/ 100;
    var timeCounter = 1;
    var lastContentRead = 0;
    var nextTime = startTime.add(timeSlice * timeCounter);
    final ewma = _MovingAverage();

    while (DateTime.now().isBefore(endTime)) {
      final now = DateTime.now();
      if (now.isAfter(nextTime)) {
        timeCounter++;
        nextTime = startTime.add(timeSlice * timeCounter);
        ewma.add((contentRead - lastContentRead).toDouble());
        lastContentRead = contentRead;
      }

      try {
        final chunk = response.contentLength;
        if (chunk == 0) break;
        await for (final data in response) {
          contentRead += data.length;
        }
        break;
      } catch (_) {
        break;
      }
    }

    client.close();
    await socket.close();

    final speedMbps = (ewma.value * 8) / (timeout.inMilliseconds * 1000);

    return CfIpTestResult(
      ip: result.ip,
      isIpv6: result.isIpv6,
      tcpPingMs: result.tcpPingMs,
      tcpReceived: result.tcpReceived,
      tcpSended: result.tcpSended,
      httpPingMs: result.httpPingMs,
      colo: result.colo,
      downloadSpeedMbps: speedMbps,
    );
  } catch (_) {
    return result;
  }
}

Stream<CfIpTestProgress> runCfIpSpeedTest({
  required List<String> ipRangesV4,
  required List<String> ipRangesV6,
  required bool enableIpv4,
  required bool enableIpv6,
  required CfIpTestCancelToken cancelToken,
  required int ipCount,
  required int tcpPingTimes,
  required int maxRoutines,
  required int httpPingCount,
  required int httpPingTimes,
  required int downloadCount,
  required String httpUrl,
  required String downloadUrl,
  required Duration tcpTimeout,
  required Duration httpTimeout,
  required Duration downloadTimeout,
  required bool quickTest,
  int tcpPort = 443,
}) async* {
  final ipv4Ips = enableIpv4 ? _generateIps(ipRangesV4, quick: quickTest, ipv6: false) : <String>[];
  final ipv6Ips = enableIpv6 ? _generateIps(ipRangesV6, quick: quickTest, ipv6: true) : <String>[];
  final allIps = _interleaveIps(ipv4Ips, ipv6Ips);
  final effectiveMaxRoutines = max(1, min(maxRoutines, 32));
  final batchSize = effectiveMaxRoutines;

  Logger.root.info(
    '[CfIpSpeedTest] start quick=$quickTest ipv4=$enableIpv4(${ipv4Ips.length}) ipv6=$enableIpv6(${ipv6Ips.length}) total=${allIps.length} batchSize=$batchSize concurrency=$effectiveMaxRoutines',
  );

  if (allIps.isEmpty) {
    yield const CfIpTestError('No IP ranges enabled');
    return;
  }

  if (_isCancelled(cancelToken)) {
    return;
  }

  final tcpResults = <CfIpTestResult>[];
  var tcpCompleted = 0;
  String? currentTestingIp;

  for (final batch in _chunkIps(allIps, batchSize)) {
    if (_isCancelled(cancelToken)) {
      return;
    }
    Logger.root.info('[CfIpSpeedTest][TCP] batch size=${batch.length} done=$tcpCompleted/${allIps.length}');
    var skipTcpStage = false;
    final batchResults = await Future.wait(
      batch.map((ip) async {
        if (_isCancelled(cancelToken)) {
          return (ip: ip, result: null);
        }
        currentTestingIp = ip;
        Logger.root.info('[CfIpSpeedTest][TCP] start $ip');
        final result = await _tcpPingIp(ip, tcpPort, tcpPingTimes, tcpTimeout);
        return (ip: ip, result: result);
      }),
    );

    for (final item in batchResults) {
      if (_isCancelled(cancelToken)) {
        return;
      }
      final result = item.result;
      if (result == null) {
        continue;
      }
      if (result.tcpReceived > 0) {
        tcpResults.add(result);
        Logger.root.info('[CfIpSpeedTest][TCP] ok ${item.ip} received=${result.tcpReceived}/${result.tcpSended} ping=${result.tcpPingMs}ms');
      } else {
        Logger.root.info('[CfIpSpeedTest][TCP] timeout ${item.ip}');
      }
      tcpCompleted++;
      Logger.root.info('[CfIpSpeedTest][TCP] progress $tcpCompleted/${allIps.length} available=${tcpResults.length} current=$currentTestingIp');
      yield CfIpTcpPingProgress(
        phase: CfIpTestPhase(name: 'TCP Ping', current: tcpCompleted, total: allIps.length),
        availableCount: tcpResults.length,
        results: List.from(tcpResults),
        currentIp: currentTestingIp,
      );

      if (cancelToken.skipStageRequested && tcpResults.isNotEmpty) {
        cancelToken.consumeSkipStageRequest();
        skipTcpStage = true;
        break;
      }
    }

    if (skipTcpStage) {
      break;
    }
  }

  tcpResults.sort((a, b) => a.tcpPingMs.compareTo(b.tcpPingMs));

  if (tcpResults.isEmpty) {
    if (_isCancelled(cancelToken)) {
      return;
    }
    Logger.root.info('[CfIpSpeedTest] no reachable IPs found after TCP phase');
    yield const CfIpTestError('No reachable IPs found');
    return;
  }

  final httpTargets = tcpResults.take(httpPingCount).toList();
  Logger.root.info('[CfIpSpeedTest][HTTP] targets=${httpTargets.length}');
  final httpResults = <CfIpTestResult>[];
  var httpCompleted = 0;
  String? currentHttpIp;

  yield CfIpHttpPingProgress(
    phase: CfIpTestPhase(name: 'HTTP Ping', current: 0, total: httpTargets.length),
    results: [],
    currentIp: null,
  );

  for (final batch in _chunkIps(httpTargets.map((e) => e.ip).toList(), effectiveMaxRoutines)) {
    if (_isCancelled(cancelToken)) {
      return;
    }
    Logger.root.info('[CfIpSpeedTest][HTTP] batch size=${batch.length} done=$httpCompleted/${httpTargets.length}');
    var skipHttpStage = false;
    for (final ip in batch) {
      if (_isCancelled(cancelToken)) break;
      final target = httpTargets.firstWhere((e) => e.ip == ip);
      currentHttpIp = ip;
      Logger.root.info('[CfIpSpeedTest][HTTP] start $ip');
      final result = await _httpPingIp(target, httpUrl, httpPingTimes, httpTimeout);
      if (_isCancelled(cancelToken)) return;
      httpCompleted++;
      if (result.httpPingMs != null) {
        httpResults.add(result);
        Logger.root.info('[CfIpSpeedTest][HTTP] ok ${result.ip} ping=${result.httpPingMs}ms colo=${result.colo ?? '-'}');
      } else {
        Logger.root.info('[CfIpSpeedTest][HTTP] fail $ip');
        if (currentHttpIp == ip) currentHttpIp = null;
      }
      yield CfIpHttpPingProgress(
        phase: CfIpTestPhase(name: 'HTTP Ping', current: httpCompleted, total: httpTargets.length),
        results: List.from(httpResults),
        currentIp: currentHttpIp,
      );

      if (cancelToken.skipStageRequested && httpResults.isNotEmpty) {
        cancelToken.consumeSkipStageRequest();
        skipHttpStage = true;
        break;
      }
    }

    if (skipHttpStage) {
      break;
    }
  }

  httpResults.sort((a, b) => (a.httpPingMs ?? 9999).compareTo(b.httpPingMs ?? 9999));

  final downloadTargets = httpResults.take(downloadCount).toList();
  Logger.root.info('[CfIpSpeedTest][Download] targets=${downloadTargets.length}');
  final downloadResults = <CfIpTestResult>[];
  var downloadCompleted = 0;
  String? currentDownloadIp;

  yield CfIpDownloadProgress(
    phase: CfIpTestPhase(name: 'Download', current: 0, total: downloadTargets.length),
    results: [],
    currentIp: null,
  );

  for (final batch in _chunkIps(downloadTargets.map((e) => e.ip).toList(), effectiveMaxRoutines)) {
    if (_isCancelled(cancelToken)) {
      return;
    }
    Logger.root.info('[CfIpSpeedTest][Download] batch size=${batch.length} done=$downloadCompleted/${downloadTargets.length}');
    var skipDownloadStage = false;
    for (final ip in batch) {
      if (_isCancelled(cancelToken)) break;
      final target = downloadTargets.firstWhere((e) => e.ip == ip);
      currentDownloadIp = ip;
      Logger.root.info('[CfIpSpeedTest][Download] start $ip');
      final result = await _downloadTestIp(target, downloadUrl, downloadTimeout);
      if (_isCancelled(cancelToken)) return;
      downloadCompleted++;
      if (result.downloadSpeedMbps != null && result.downloadSpeedMbps! > 0) {
        downloadResults.add(result);
        Logger.root.info('[CfIpSpeedTest][Download] ok ${result.ip} speed=${result.downloadSpeedMbps!.toStringAsFixed(2)}MB/s');
      } else {
        Logger.root.info('[CfIpSpeedTest][Download] fail $ip');
        if (currentDownloadIp == ip) currentDownloadIp = null;
      }
      yield CfIpDownloadProgress(
        phase: CfIpTestPhase(name: 'Download', current: downloadCompleted, total: downloadTargets.length),
        results: List.from(downloadResults),
        currentIp: currentDownloadIp,
      );

      if (cancelToken.skipStageRequested && downloadResults.isNotEmpty) {
        cancelToken.consumeSkipStageRequest();
        skipDownloadStage = true;
        break;
      }
    }

    if (skipDownloadStage) {
      break;
    }
  }

  final allResults = downloadResults.isNotEmpty ? downloadResults : httpResults;
  allResults.sort((a, b) {
    if (a.downloadSpeedMbps != null && b.downloadSpeedMbps != null) {
      return b.downloadSpeedMbps!.compareTo(a.downloadSpeedMbps!);
    }
    final aPing = a.httpPingMs ?? a.tcpPingMs;
    final bPing = b.httpPingMs ?? b.tcpPingMs;
    return aPing.compareTo(bPing);
  });

  yield CfIpTestComplete(results: allResults);
  Logger.root.info('[CfIpSpeedTest] complete results=${allResults.length}');
}
