import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gap/gap.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/account.dart';
import 'package:surface/types/chat.dart';
import 'package:surface/widgets/chat/call/call_no_content.dart';
import 'package:surface/widgets/chat/call/call_participant_info.dart';
import 'package:surface/widgets/chat/call/call_participant_menu.dart';
import 'package:surface/widgets/chat/call/call_participant_stats.dart';

abstract class ParticipantWidget extends StatefulWidget {
  static ParticipantWidget widgetFor(
    ParticipantTrack participantTrack, {
    double? avatarSize,
    EdgeInsets? padding,
    bool showStatsLayer = false,
    bool isList = false,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.videoTrack,
        avatarSize,
        participantTrack.isScreenShare,
        showStatsLayer,
        isList,
        padding,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.videoTrack,
        avatarSize,
        participantTrack.isScreenShare,
        showStatsLayer,
        isList,
        padding,
      );
    }
    throw UnimplementedError('Unknown participant type');
  }

  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
  abstract final bool isScreenShare;
  abstract final double? avatarSize;
  abstract final bool showStatsLayer;
  abstract final bool isList;
  abstract final EdgeInsets? padding;
  final VideoQuality quality;

  const ParticipantWidget({
    super.key,
    this.quality = VideoQuality.MEDIUM,
  });
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final double? avatarSize;
  @override
  final bool isScreenShare;
  @override
  final bool showStatsLayer;
  @override
  final bool isList;
  @override
  final EdgeInsets? padding;

  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.avatarSize,
    this.isScreenShare,
    this.showStatsLayer,
    this.isList,
    this.padding, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final double? avatarSize;
  @override
  final bool isScreenShare;
  @override
  final bool showStatsLayer;
  @override
  final bool isList;
  @override
  final EdgeInsets? padding;

  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.avatarSize,
    this.isScreenShare,
    this.showStatsLayer,
    this.isList,
    this.padding, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget>
    extends State<T> {
  VideoTrack? get _activeVideoTrack;

  TrackPublication? get _firstAudioPublication;

  SnAccount? _userinfoMetadata;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(onParticipantChanged);
    onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(onParticipantChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(onParticipantChanged);
    widget.participant.addListener(onParticipantChanged);
    onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  void onParticipantChanged() {
    setState(() {
      if (widget.participant.metadata != null) {
        _userinfoMetadata = SnAccount.fromJson(
          jsonDecode(widget.participant.metadata!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isList) {
      return Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: (widget.avatarSize ?? 32) * 2,
                  height: (widget.avatarSize ?? 32) * 2,
                  child: Center(
                    child: NoContentWidget(
                      userinfo: _userinfoMetadata,
                      avatarSize: widget.avatarSize,
                      isSpeaking: widget.participant.isSpeaking,
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: SizedBox(
                    height: (widget.avatarSize ?? 32) * 2,
                    child: ParticipantInfoWidget(
                      isList: true,
                      title: widget.participant.name.isNotEmpty
                          ? widget.participant.name
                          : widget.participant.identity,
                      audioAvailable: _firstAudioPublication?.muted == false &&
                          _firstAudioPublication?.subscribed == true,
                      connectionQuality: widget.participant.connectionQuality,
                      isScreenShare: widget.isScreenShare,
                    ),
                  ),
                ),
              ],
            ),
            if (_activeVideoTrack != null && !_activeVideoTrack!.muted)
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainer
                        .withOpacity(0.75),
                    child: VideoTrackRenderer(
                      _activeVideoTrack!,
                      fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  ),
                ).padding(top: 8),
              ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        if (_activeVideoTrack != null && !_activeVideoTrack!.muted)
          VideoTrackRenderer(
            _activeVideoTrack!,
            fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
          )
        else
          Center(
            child: NoContentWidget(
              userinfo: _userinfoMetadata,
              avatarSize: widget.avatarSize,
              isSpeaking: widget.participant.isSpeaking,
            ),
          ),
        if (widget.showStatsLayer)
          Positioned(
            top: 30,
            right: 30,
            child: ParticipantStatsWidget(participant: widget.participant),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ParticipantInfoWidget(
                title: widget.participant.name.isNotEmpty
                    ? widget.participant.name
                    : widget.participant.identity,
                audioAvailable: _firstAudioPublication?.muted == false &&
                    _firstAudioPublication?.subscribed == true,
                connectionQuality: widget.participant.connectionQuality,
                isScreenShare: widget.isScreenShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalAudioTrack>? get _firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get _activeVideoTrack => widget.videoTrack;
}

class _RemoteParticipantWidgetState
    extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteAudioTrack>? get _firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get _activeVideoTrack => widget.videoTrack;
}

class InteractiveParticipantWidget extends StatelessWidget {
  final double? avatarSize;
  final bool isList;
  final ParticipantTrack participant;
  final Function? onTap;
  final EdgeInsets? padding;

  const InteractiveParticipantWidget({
    super.key,
    this.avatarSize,
    this.isList = false,
    this.padding,
    required this.participant,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                onTap?.call();
              }
            : null,
        onLongPress: () {
          if (participant.participant is LocalParticipant) return;
          showModalBottomSheet(
            context: context,
            builder: (context) => ParticipantMenu(
              participant: participant.participant as RemoteParticipant,
              videoTrack: participant.videoTrack,
              isScreenShare: participant.isScreenShare,
            ),
          );
        },
        child: Container(
          child: ParticipantWidget.widgetFor(
            participant,
            avatarSize: avatarSize,
            isList: isList,
            padding: padding,
          ),
        ),
      ),
    );
  }
}
