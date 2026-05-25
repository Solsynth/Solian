import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/time.dart';
import 'package:logging/logging.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:styled_widget/styled_widget.dart';

class UniversalAudio extends ConsumerStatefulWidget {
  final String uri;
  final String filename;
  final bool autoplay;
  const UniversalAudio({
    super.key,
    required this.uri,
    required this.filename,
    this.autoplay = false,
  });

  @override
  ConsumerState<UniversalAudio> createState() => _UniversalAudioState();
}

class _UniversalAudioState extends ConsumerState<UniversalAudio> {
  Player? _player;

  Duration _duration = Duration(seconds: 1);
  Duration _duartionBuffered = Duration(seconds: 1);
  Duration _position = Duration(seconds: 0);

  bool _sliderWorking = false;
  Duration _sliderPosition = Duration(seconds: 0);

  Future<void> _initPlayer() async {
    final url = widget.uri;
    MediaKit.ensureInitialized();

    final serverUrl = ref.read(serverUrlProvider);
    final token = ref.read(tokenProvider);
    final authHeaders = url.startsWith(serverUrl) && token != null
        ? {'Authorization': 'Bearer ${token.token}'}
        : null;

    String uri;
    final inCacheInfo = await DefaultCacheManager().getFileFromCache(url);
    if (inCacheInfo == null) {
      Logger.root.info('[MediaPlayer] Miss cache: $url');
      final result = await DefaultCacheManager().downloadFile(
        url,
        authHeaders: authHeaders,
      );
      uri = result.file.path;
    } else {
      uri = inCacheInfo.file.path;
      Logger.root.info('[MediaPlayer] Hit cache: $url');
    }

    if (!mounted) return;

    _player = Player();
    _player!.stream.position.listen((value) {
      _position = value;
      if (!_sliderWorking) _sliderPosition = _position;
      if (mounted) setState(() {});
    });
    _player!.stream.buffer.listen((value) {
      _duartionBuffered = value;
      if (mounted) setState(() {});
    });
    _player!.stream.duration.listen((value) {
      _duration = value;
      if (mounted) setState(() {});
    });

    final Map<String, String>? httpHeaders =
        uri.startsWith(serverUrl) && token != null
            ? {'Authorization': 'Bearer ${token.token}'}
            : null;

    await _player!.open(Media(uri, httpHeaders: httpHeaders),
        play: widget.autoplay);

    if (mounted) setState(() {});
  }

  void _disposePlayer() {
    _player?.dispose();
    _player = null;
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void didUpdateWidget(UniversalAudio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri) {
      _disposePlayer();
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_player == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          IconButton.filled(
            onPressed: () {
              _player!.playOrPause().then((_) {
                if (mounted) setState(() {});
              });
            },
            icon: _player!.state.playing
                ? const Icon(Symbols.pause, fill: 1, color: Colors.white)
                : const Icon(Symbols.play_arrow, fill: 1, color: Colors.white),
          ),
          const Gap(20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: (_player!.state.playing || _sliderWorking)
                      ? SizedBox(
                          width: double.infinity,
                          key: const ValueKey('playing'),
                          child: Text(
                            '${_position.formatShortDuration()} / ${_duration.formatShortDuration()}',
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          key: const ValueKey('filename'),
                          child: Text(
                            widget.filename.isEmpty ? 'Audio' : widget.filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                Slider(
                  value: _sliderPosition.inMilliseconds.toDouble(),
                  secondaryTrackValue: _duartionBuffered.inMilliseconds
                      .toDouble(),
                  max: _duration.inMilliseconds.toDouble(),
                  onChangeStart: (_) {
                    _sliderWorking = true;
                  },
                  onChanged: (value) {
                    _sliderPosition = Duration(milliseconds: value.toInt());
                    setState(() {});
                  },
                  onChangeEnd: (value) {
                    _sliderPosition = Duration(milliseconds: value.toInt());
                    _sliderWorking = false;
                    _player!.seek(_sliderPosition);
                  },
                  year2023: true,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}
