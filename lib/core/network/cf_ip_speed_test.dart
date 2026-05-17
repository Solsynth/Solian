import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

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

  const CfIpTcpPingProgress({required this.phase, required this.availableCount, this.currentIp});
}

class CfIpHttpPingProgress extends CfIpTestProgress {
  final CfIpTestPhase phase;
  final List<CfIpTestResult> results;

  const CfIpHttpPingProgress({required this.phase, required this.results});
}

class CfIpDownloadProgress extends CfIpTestProgress {
  final CfIpTestPhase phase;
  final List<CfIpTestResult> results;

  const CfIpDownloadProgress({required this.phase, required this.results});
}

class CfIpTestComplete extends CfIpTestProgress {
  final List<CfIpTestResult> results;

  const CfIpTestComplete({required this.results});
}

class CfIpTestError extends CfIpTestProgress {
  final String message;

  const CfIpTestError(this.message);
}

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
  if (quick) {
    return _generateRandomIps(ranges, ipv6);
  }
  return _generateAllIps(ranges, ipv6);
}

List<String> _generateRandomIps(List<String> ranges, bool ipv6) {
  const count = 10;
  final random = Random();
  final ips = <String>[];
  final perRange = (count / ranges.length).ceil();

  for (final range in ranges) {
    final parts = range.split('/');
    final ipStr = parts[0];
    final cidr = int.parse(parts[1]);

    if (ipv6) {
      _generateRandomIpv6(ipStr, cidr, perRange, random, ips);
    } else {
      _generateRandomIpv4(ipStr, cidr, perRange, random, ips);
    }
  }

  return ips.take(count).toList();
}

List<String> _generateAllIps(List<String> ranges, bool ipv6) {
  final ips = <String>[];

  for (final range in ranges) {
    final parts = range.split('/');
    final ipStr = parts[0];
    final cidr = int.parse(parts[1]);

    if (ipv6) {
      _generateAllIpv6(ipStr, cidr, ips);
    } else {
      _generateAllIpv4(ipStr, cidr, ips);
    }
  }

  return ips;
}

void _generateAllIpv4(String ip, int cidr, List<String> out) {
  final ipBytes = ip.split('.').map(int.parse).toList();
  final maskBits = 32 - cidr;

  final max4 = (1 << maskBits) - 1;
  final base4 = ipBytes[3] & (~max4 & 0xFF);

  for (var i = 0; i <= max4; i++) {
    out.add('${ipBytes[0]}.${ipBytes[1]}.${ipBytes[2]}.${base4 + i}');
  }
}

void _generateAllIpv6(String ip, int cidr, List<String> out) {
  final full = _expandIpv6(ip);
  final bytes = Uint8List(16);
  for (var i = 0; i < 8; i++) {
    final val = int.parse(full[i], radix: 16);
    bytes[i * 2] = (val >> 8) & 0xFF;
    bytes[i * 2 + 1] = val & 0xFF;
  }

  final hostBits = 128 - cidr;
  final totalIps = BigInt.from(2).pow(hostBits);

  if (totalIps > BigInt.from(1000000)) {
    for (var i = 0; i < 1000000; i++) {
      final newBytes = Uint8List.fromList(bytes);
      final bigI = BigInt.from(i);
      var bitOffset = 0;
      for (var byteIdx = 15; byteIdx >= 0; byteIdx--) {
        if (bitOffset >= hostBits) break;
        final bitsInByte = hostBits - bitOffset > 8 ? 8 : hostBits - bitOffset;
        final mask = (1 << bitsInByte) - 1;
        final shift = bitOffset;
        final byteBits = (bigI >> shift).toInt() & mask;
        final networkMask = ~((1 << bitsInByte) - 1) & 0xFF;
        newBytes[byteIdx] = (newBytes[byteIdx] & networkMask) | byteBits;
        bitOffset += bitsInByte;
      }
      out.add(_formatIpv6(newBytes));
    }
    return;
  }

  var counter = BigInt.zero;
  while (counter < totalIps) {
    final newBytes = Uint8List.fromList(bytes);
    var bigI = counter;
    var bitOffset = 0;
    for (var byteIdx = 15; byteIdx >= 0; byteIdx--) {
      if (bitOffset >= hostBits) break;
      final bitsInByte = hostBits - bitOffset > 8 ? 8 : hostBits - bitOffset;
      final mask = (1 << bitsInByte) - 1;
      final byteBits = bigI.toInt() & mask;
      final networkMask = ~((1 << bitsInByte) - 1) & 0xFF;
      newBytes[byteIdx] = (newBytes[byteIdx] & networkMask) | byteBits;
      bigI >>= bitsInByte;
      bitOffset += bitsInByte;
    }
    out.add(_formatIpv6(newBytes));
    counter += BigInt.one;
  }
}

void _generateRandomIpv4(String ip, int cidr, int count, Random random, List<String> out) {
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

  for (var i = 0; i < count; i++) {
    final b2 = base2 + (max2 > 0 ? random.nextInt(max2 + 1) : 0);
    final b3 = base3 + (max3 > 0 ? random.nextInt(max3 + 1) : 0);
    final b4 = random.nextInt(max4 + 1);
    out.add('${ipBytes[0]}.$b2.$b3.$b4');
  }
}

void _generateRandomIpv6(String ip, int cidr, int count, Random random, List<String> out) {
  final full = _expandIpv6(ip);
  final bytes = Uint8List(16);
  for (var i = 0; i < 8; i++) {
    final val = int.parse(full[i], radix: 16);
    bytes[i * 2] = (val >> 8) & 0xFF;
    bytes[i * 2 + 1] = val & 0xFF;
  }

  final hostBits = 128 - cidr;
  final networkBytes = hostBits ~/ 8;
  final remainingBits = hostBits % 8;

  for (var i = 0; i < count; i++) {
    final newBytes = Uint8List.fromList(bytes);
    for (var j = 15; j > 15 - networkBytes; j--) {
      newBytes[j] = random.nextInt(256);
    }
    if (networkBytes < 16 && remainingBits > 0) {
      final idx = 15 - networkBytes;
      final mask = (1 << remainingBits) - 1;
      newBytes[idx] = (newBytes[idx] & ~mask) | random.nextInt(mask + 1);
    }
    out.add(_formatIpv6(newBytes));
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
  final allIps = [
    ..._generateIps(ipRangesV4, quick: quickTest, ipv6: false),
    ..._generateIps(ipRangesV6, quick: quickTest, ipv6: true),
  ];

  final tcpResults = <CfIpTestResult>[];
  var tcpCompleted = 0;
  String? currentTestingIp;
  final semaphore = _Semaphore(maxRoutines);
  final tcpDone = Completer<void>();

  for (final ip in allIps) {
    unawaited(semaphore.acquire().then((_) async {
      currentTestingIp = ip;
      try {
        final result = await _tcpPingIp(ip, tcpPort, tcpPingTimes, tcpTimeout);
        if (result.tcpReceived > 0) {
          tcpResults.add(result);
        }
      } finally {
        semaphore.release();
      }
      tcpCompleted++;
      if (tcpCompleted == allIps.length) {
        currentTestingIp = null;
        tcpDone.complete();
      }
    }));
  }

  while (!tcpDone.isCompleted) {
    await Future.delayed(const Duration(milliseconds: 200));
    yield CfIpTcpPingProgress(
      phase: CfIpTestPhase(name: 'TCP Ping', current: tcpCompleted, total: allIps.length),
      availableCount: tcpResults.length,
      currentIp: currentTestingIp,
    );
  }

  tcpResults.sort((a, b) => a.tcpPingMs.compareTo(b.tcpPingMs));

  if (tcpResults.isEmpty) {
    yield const CfIpTestError('No reachable IPs found');
    return;
  }

  final httpTargets = tcpResults.take(httpPingCount).toList();
  final httpResults = <CfIpTestResult>[];
  var httpCompleted = 0;

  yield CfIpHttpPingProgress(
    phase: CfIpTestPhase(name: 'HTTP Ping', current: 0, total: httpTargets.length),
    results: [],
  );

  for (final target in httpTargets) {
    final result = await _httpPingIp(target, httpUrl, httpPingTimes, httpTimeout);
    httpCompleted++;
    if (result.httpPingMs != null) {
      httpResults.add(result);
    }
    yield CfIpHttpPingProgress(
      phase: CfIpTestPhase(name: 'HTTP Ping', current: httpCompleted, total: httpTargets.length),
      results: List.from(httpResults),
    );
  }

  httpResults.sort((a, b) => (a.httpPingMs ?? 9999).compareTo(b.httpPingMs ?? 9999));

  final downloadTargets = httpResults.take(downloadCount).toList();
  final downloadResults = <CfIpTestResult>[];
  var downloadCompleted = 0;

  yield CfIpDownloadProgress(
    phase: CfIpTestPhase(name: 'Download', current: 0, total: downloadTargets.length),
    results: [],
  );

  for (final target in downloadTargets) {
    final result = await _downloadTestIp(target, downloadUrl, downloadTimeout);
    downloadCompleted++;
    if (result.downloadSpeedMbps != null && result.downloadSpeedMbps! > 0) {
      downloadResults.add(result);
    }
    yield CfIpDownloadProgress(
      phase: CfIpTestPhase(name: 'Download', current: downloadCompleted, total: downloadTargets.length),
      results: List.from(downloadResults),
    );
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
}
