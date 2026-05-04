import 'package:flutter/material.dart';
import 'package:island/shared/widgets/content/video.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

String? resolveLivestreamHlsUrl(SnLiveStream stream) {
  final raw = stream.hlsPlaylistPath?.trim();
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

  final base = Uri.parse("https://ls.solian.app"); // TODO Change this
  final normalizedPath = raw.startsWith('/') ? raw : '/$raw';
  return base
      .replace(path: normalizedPath, query: null, fragment: null)
      .toString();
}

class LivestreamHlsVideo extends StatelessWidget {
  final SnLiveStream stream;
  final String? hlsUrl;
  final bool showVodBadge;

  const LivestreamHlsVideo({
    super.key,
    required this.stream,
    required this.hlsUrl,
    this.showVodBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    if (hlsUrl == null || hlsUrl!.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        UniversalVideo(uri: hlsUrl!, autoplay: true),
        if (showVodBadge)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'VOD 回放',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
