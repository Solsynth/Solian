import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/meet_bluetooth.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

@RoutePage()
class MeetScreen extends HookConsumerWidget {
  const MeetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeData = RouteData.of(context);
    final initialMeetId = routeData.queryParams.optString('meet_id') ?? '';
    final currentUser = ref.watch(userInfoProvider).value;

    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);

    final joinController = useTextEditingController(text: initialMeetId);
    final locationController = useTextEditingController();
    final topicController = useTextEditingController();
    final tabController = useTabController(
      initialLength: 2,
      initialIndex: initialMeetId.isNotEmpty ? 1 : 0,
    );

    final activeMeet = useState<SnMeet?>(null);
    final activeMeetEventType = useState<String?>(null);
    final activeMeetError = useState<Object?>(null);
    final actionBusy = useState(false);
    final isWatching = useState(false);
    final isHostSession = useState(false);
    final isAdvertising = useState(false);
    final isScanning = useState(false);
    final discoveries = useState<List<MeetBluetoothDiscovery>>([]);
    final didAutoJoin = useState(false);

    final meetWatchSub = useRef<StreamSubscription<SnMeetEvent>?>(null);
    final scanResultSub = useRef<StreamSubscription<List<ScanResult>>?>(null);
    final scanStateSub = useRef<StreamSubscription<bool>?>(null);

    Future<void> stopWatching() async {
      await meetWatchSub.value?.cancel();
      meetWatchSub.value = null;
      isWatching.value = false;
    }

    Future<void> stopAdvertising() async {
      if (!isAdvertising.value) return;
      await bluetoothService.stopAdvertising();
      isAdvertising.value = false;
    }

    Future<void> closeLiveView() async {
      await stopWatching();
      await stopAdvertising();
      activeMeet.value = null;
      activeMeetEventType.value = null;
      activeMeetError.value = null;
      isHostSession.value = false;
    }

    Future<void> watchMeet(String meetId, {required bool asHost}) async {
      await stopWatching();
      activeMeetError.value = null;
      activeMeetEventType.value = null;
      isHostSession.value = asHost;
      isWatching.value = true;

      meetWatchSub.value = meetService
          .joinMeet(meetId)
          .listen(
            (event) async {
              activeMeet.value = event.meet;
              activeMeetEventType.value = event.type;
              if (event.meet.isFinal) {
                isWatching.value = false;
                if (asHost) {
                  await stopAdvertising();
                }
              }
            },
            onError: (error, _) {
              activeMeetError.value = error;
              isWatching.value = false;
            },
          );
    }

    Future<void> startMeet() async {
      actionBusy.value = true;
      activeMeetError.value = null;
      try {
        final metadata = <String, dynamic>{};
        if (topicController.text.trim().isNotEmpty) {
          metadata['topic'] = topicController.text.trim();
        }

        final meet = await meetService.createMeet(
          locationName: locationController.text.trim(),
          metadata: metadata,
          expiresInSeconds: 1800,
        );

        activeMeet.value = meet;
        await bluetoothService.startAdvertising(meet.id);
        isAdvertising.value = true;
        await watchMeet(meet.id, asHost: true);
      } catch (error) {
        activeMeetError.value = error;
        showErrorAlert(error);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> joinMeetById(String meetId) async {
      final normalized = meetId.trim();
      if (normalized.isEmpty) {
        showErrorAlert('meetJoinIdRequired'.tr());
        return;
      }

      actionBusy.value = true;
      activeMeetError.value = null;
      try {
        await stopAdvertising();
        await watchMeet(normalized, asHost: false);
      } catch (error) {
        activeMeetError.value = error;
        showErrorAlert(error);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> completeMeet() async {
      final meet = activeMeet.value;
      if (meet == null) return;

      actionBusy.value = true;
      try {
        await meetService.completeMeet(meet.id);
        await stopAdvertising();
      } catch (error) {
        showErrorAlert(error);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> startNearbyScan() async {
      if (!bluetoothService.supportsNearbyDiscovery) {
        showErrorAlert('meetBluetoothUnavailable'.tr());
        return;
      }

      await scanResultSub.value?.cancel();
      discoveries.value = [];
      activeMeetError.value = null;

      scanResultSub.value = FlutterBluePlus.onScanResults.listen(
        (results) {
          discoveries.value = bluetoothService.parseDiscoveries(results);
        },
        onError: (error, _) {
          activeMeetError.value = error;
          isScanning.value = false;
        },
      );
      FlutterBluePlus.cancelWhenScanComplete(scanResultSub.value!);

      isScanning.value = true;
      try {
        await bluetoothService.startScan();
      } catch (error) {
        await scanResultSub.value?.cancel();
        scanResultSub.value = null;
        isScanning.value = false;
        activeMeetError.value = error;
        showErrorAlert(error);
        return;
      }

      scanStateSub.value ??= FlutterBluePlus.isScanning.listen((value) {
        isScanning.value = value;
      });
    }

    useEffect(() {
      void handleTabChange() {
        if (tabController.index == 1 &&
            !tabController.indexIsChanging &&
            activeMeet.value == null &&
            !isScanning.value) {
          unawaited(startNearbyScan());
        }
      }

      tabController.addListener(handleTabChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleTabChange();
      });

      return () {
        tabController.removeListener(handleTabChange);
      };
    }, [tabController, activeMeet.value, isScanning.value]);

    useEffect(() {
      if (initialMeetId.isNotEmpty && !didAutoJoin.value) {
        didAutoJoin.value = true;
        Future.microtask(() => joinMeetById(initialMeetId));
      }

      return () {
        unawaited(stopWatching());
        unawaited(stopAdvertising());
        unawaited(bluetoothService.stopScan());
        unawaited(scanResultSub.value?.cancel() ?? Future.value());
        unawaited(scanStateSub.value?.cancel() ?? Future.value());
      };
    }, [initialMeetId]);

    final displayedParticipants = _displayParticipants(activeMeet.value, currentUser);

    if (activeMeet.value != null &&
        activeMeet.value!.status == SnMeetStatus.active &&
        activeMeetError.value == null) {
      return _MeetActivePage(
        meet: activeMeet.value!,
        isHost: isHostSession.value,
        isWatching: isWatching.value,
        isAdvertising: isAdvertising.value,
        participants: displayedParticipants,
        onComplete: isHostSession.value ? completeMeet : null,
        onClose: closeLiveView,
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('meet').tr(),
        leading: const AutoLeadingButton(),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(
              child: Text(
                'meetStart',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ).tr(),
            ),
            Tab(
              child: Text(
                'meetJoin',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor,
                ),
              ).tr(),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MeetStartCard(
                locationController: locationController,
                topicController: topicController,
                busy: actionBusy.value,
                advertising: isAdvertising.value,
                onStart: startMeet,
              ),
              const Gap(16),
              if (activeMeetError.value != null)
                ResponseErrorWidget(
                  error: activeMeetError.value,
                  onRetry: startMeet,
                )
              else if (activeMeet.value != null)
                _MeetSummaryCard(
                  meet: activeMeet.value!,
                  eventType: activeMeetEventType.value,
                  isWatching: isWatching.value,
                  participants: displayedParticipants,
                )
              else
                _MeetInfoCard(
                  icon: Symbols.bluetooth_searching,
                  title: 'meetStartReadyTitle'.tr(),
                  description: 'meetStartReadyDescription'.tr(),
                ),
            ],
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MeetJoinCard(
                joinController: joinController,
                busy: actionBusy.value,
                scanning: isScanning.value,
                bluetoothSupported: bluetoothService.supportsNearbyDiscovery,
                advertiseSupported: bluetoothService.supportsAdvertising,
                onJoin: () => joinMeetById(joinController.text),
                onPaste: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final text = data?.text?.trim();
                  if (text?.isNotEmpty ?? false) {
                    joinController.text = text!;
                  }
                },
                onScanNearby: startNearbyScan,
              ),
              const Gap(16),
              if (discoveries.value.isNotEmpty) ...[
                _MeetNearbyCard(
                  discoveries: discoveries.value,
                  onJoin: (meetId) {
                    joinController.text = meetId;
                    joinMeetById(meetId);
                  },
                ),
                const Gap(16),
              ],
              if (activeMeetError.value != null)
                ResponseErrorWidget(
                  error: activeMeetError.value,
                  onRetry: () => joinMeetById(joinController.text),
                )
              else if (activeMeet.value != null && !isHostSession.value)
                _MeetSummaryCard(
                  meet: activeMeet.value!,
                  eventType: activeMeetEventType.value,
                  isWatching: isWatching.value,
                  participants: displayedParticipants,
                )
              else
                _MeetInfoCard(
                  icon: Symbols.groups,
                  title: 'meetJoinReadyTitle'.tr(),
                  description: 'meetJoinReadyDescription'.tr(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeetStartCard extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController topicController;
  final bool busy;
  final bool advertising;
  final VoidCallback onStart;

  const _MeetStartCard({
    required this.locationController,
    required this.topicController,
    required this.busy,
    required this.advertising,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('meetStartTitle').tr().fontSize(18).bold(),
            const Gap(8),
            Text('meetStartDescription').tr(),
            const Gap(16),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'meetLocationLabel'.tr(),
                hintText: 'meetLocationHint'.tr(),
              ),
            ),
            const Gap(12),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: 'meetTopicLabel'.tr(),
                hintText: 'meetTopicHint'.tr(),
              ),
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onStart,
                    icon: const Icon(Symbols.add_circle),
                    label: Text(
                      advertising
                          ? 'meetRestartBroadcast'.tr()
                          : 'meetStartNow'.tr(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetJoinCard extends StatelessWidget {
  final TextEditingController joinController;
  final bool busy;
  final bool scanning;
  final bool bluetoothSupported;
  final bool advertiseSupported;
  final VoidCallback onJoin;
  final VoidCallback onPaste;
  final VoidCallback onScanNearby;

  const _MeetJoinCard({
    required this.joinController,
    required this.busy,
    required this.scanning,
    required this.bluetoothSupported,
    required this.advertiseSupported,
    required this.onJoin,
    required this.onPaste,
    required this.onScanNearby,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('meetJoinTitle').tr().fontSize(18).bold(),
            const Gap(8),
            Text('meetJoinDescription').tr(),
            const Gap(16),
            TextField(
              controller: joinController,
              decoration: InputDecoration(
                labelText: 'meetId'.tr(),
                hintText: 'meetIdHint'.tr(),
                suffixIcon: IconButton(
                  onPressed: onPaste,
                  icon: const Icon(Symbols.content_paste),
                ),
              ),
            ),
            const Gap(16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onJoin,
                    icon: const Icon(Symbols.login),
                    label: Text('meetJoinNow').tr(),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: scanning || !bluetoothSupported
                        ? null
                        : onScanNearby,
                    icon: Icon(
                      scanning
                          ? Symbols.progress_activity
                          : Symbols.bluetooth_searching,
                    ),
                    label: Text(
                      scanning ? 'meetScanning'.tr() : 'meetScanNearby'.tr(),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(12),
            Text(
              scanning ? 'meetJoinScanningHint'.tr() : 'meetJoinNearbyHint'.tr(),
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            if (!bluetoothSupported) ...[
              const Gap(12),
              Text(
                'meetBluetoothUnavailable',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ).tr(),
            ] else if (!advertiseSupported) ...[
              const Gap(12),
              Text(
                'meetBroadcastLimited',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ).tr(),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeetNearbyCard extends StatelessWidget {
  final List<MeetBluetoothDiscovery> discoveries;
  final ValueChanged<String> onJoin;

  const _MeetNearbyCard({required this.discoveries, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('meetNearby').tr().fontSize(18).bold(),
          ),
          ...discoveries.map((item) {
            return ListTile(
              leading: const Icon(Symbols.bluetooth),
              title: Text(
                item.name?.isNotEmpty == true
                    ? item.name!
                    : 'meetNearbyHost'.tr(),
              ),
              subtitle: Text(
                'meetNearbySubtitle'.tr(
                  args: [
                    estimateDistancePercent(item.rssi).toString(),
                  ],
                ),
              ),
              trailing: const Icon(Symbols.arrow_outward),
              onTap: () => onJoin(item.meetId),
            );
          }),
        ],
      ),
    );
  }
}

class _MeetSummaryCard extends StatelessWidget {
  final SnMeet meet;
  final String? eventType;
  final bool isWatching;
  final List<_MeetPerson> participants;

  const _MeetSummaryCard({
    required this.meet,
    required this.eventType,
    required this.isWatching,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    final topic = meet.metadata['topic']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('meetRecentTitle').tr().fontSize(18).bold(),
            const Gap(6),
            Text(_statusLabel(meet.status, context)),
            if (meet.locationName?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(meet.locationName!).fontSize(16).bold(),
              ),
            if (topic?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  topic!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            const Gap(16),
            Row(
              children: [
                Icon(
                  isWatching ? Symbols.wifi_tethering : Symbols.wifi_off,
                  size: 18,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    isWatching ? 'meetWatching'.tr() : 'meetWatchStopped'.tr(),
                  ),
                ),
              ],
            ),
            const Gap(16),
            Text(
              'meetParticipantsCount'.tr(args: ['${participants.length}']),
            ).fontSize(16).bold(),
            const Gap(8),
            if (participants.isEmpty)
              Text('meetParticipantsEmpty').tr()
            else
              ...participants.map((participant) {
                final account = participant.account;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: account != null
                      ? ProfilePictureWidget(
                          file: account.profile.picture,
                          radius: 20,
                        )
                      : const CircleAvatar(
                          radius: 20,
                          child: Icon(Symbols.person, size: 18),
                        ),
                  title: Text(
                    account?.nick.isNotEmpty == true
                        ? account!.nick
                        : '@${account?.name ?? participant.fallbackName}',
                  ),
                  subtitle: Text(
                    participant.subtitle,
                  ),
                );
              }),
            if (eventType?.isNotEmpty ?? false) ...[
              const Gap(12),
              Text(
                _eventLabel(eventType!, context),
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeetInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MeetInfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 36),
            const Gap(12),
            Text(title).fontSize(18).bold(),
            const Gap(8),
            Text(description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _MeetActivePage extends HookWidget {
  final SnMeet meet;
  final bool isHost;
  final bool isWatching;
  final bool isAdvertising;
  final List<_MeetPerson> participants;
  final VoidCallback? onComplete;
  final VoidCallback onClose;

  const _MeetActivePage({
    required this.meet,
    required this.isHost,
    required this.isWatching,
    required this.isAdvertising,
    required this.participants,
    required this.onComplete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    final topic = meet.metadata['topic']?.toString();

    return AppScaffold(
      isNoBackground: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Symbols.close),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            meet.locationName?.isNotEmpty == true
                                ? meet.locationName!
                                : 'meetLiveTitle'.tr(),
                          ).fontSize(18).bold(),
                          Text(
                            (topic?.isNotEmpty ?? false)
                                ? topic!
                                : _statusLabel(meet.status, context),
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: meet.id));
                        showSnackBar('copyToClipboard'.tr());
                      },
                      icon: const Icon(Symbols.content_copy),
                    ),
                  ],
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isAdvertising)
                      _InfoPill(
                        icon: Symbols.bluetooth,
                        label: 'meetBroadcasting'.tr(),
                      ),
                    if (isAdvertising) const Gap(8),
                    _InfoPill(
                      icon: isWatching
                          ? Symbols.wifi_tethering
                          : Symbols.wifi_off,
                      label: isWatching
                          ? 'meetWatching'.tr()
                          : 'meetWatchStopped'.tr(),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 360,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _MeetRippleField(
                        animation: animation,
                        color: theme.colorScheme.primary,
                      ),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 18,
                          runSpacing: 18,
                          children: participants
                              .map((participant) => _ParticipantBubble(
                                    participant: participant,
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'meetParticipantsCount'.tr(args: ['${participants.length}']),
                  style: TextStyle(color: theme.colorScheme.secondary),
                ),
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onClose,
                        child: Text(
                          isHost ? 'cancel'.tr() : 'close'.tr(),
                        ),
                      ),
                    ),
                    if (isHost && onComplete != null) ...[
                      const Gap(12),
                      Expanded(
                        child: FilledButton(
                          onPressed: onComplete,
                          child: Text('meetComplete').tr(),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeetRippleField extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _MeetRippleField({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final progress = (animation.value + index / 3) % 1.0;
            final size = 120 + (progress * 220);
            final opacity = (1 - progress).clamp(0.0, 1.0) * 0.18;
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(opacity), width: 2),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ParticipantBubble extends StatelessWidget {
  final _MeetPerson participant;

  const _ParticipantBubble({required this.participant});

  @override
  Widget build(BuildContext context) {
    final account = participant.account;
    final label = account?.nick.isNotEmpty == true
        ? account!.nick
        : '@${account?.name ?? participant.fallbackName}';

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          account != null
              ? ProfilePictureWidget(file: account.profile.picture, radius: 28)
              : const CircleAvatar(
                  radius: 28,
                  child: Icon(Symbols.person, size: 22),
                ),
          const Gap(8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            participant.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ).fontSize(12),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const Gap(8),
          Text(label),
        ],
      ),
    );
  }
}

class _MeetPerson {
  final String id;
  final SnAccount? account;
  final String subtitle;
  final String fallbackName;

  const _MeetPerson({
    required this.id,
    required this.account,
    required this.subtitle,
    required this.fallbackName,
  });
}

List<_MeetPerson> _displayParticipants(SnMeet? meet, SnAccount? currentUser) {
  if (meet == null) return const [];

  final people = <_MeetPerson>[];
  final seen = <String>{};

  final hostAccount = meet.host ?? (currentUser?.id == meet.hostId ? currentUser : null);
  if (seen.add(meet.hostId)) {
    people.add(
      _MeetPerson(
        id: meet.hostId,
        account: hostAccount,
        subtitle: 'meetHost'.tr(),
        fallbackName: meet.hostId,
      ),
    );
  }

  for (final participant in meet.participants) {
    if (!seen.add(participant.accountId)) continue;
    people.add(
      _MeetPerson(
        id: participant.accountId,
        account: participant.account,
        subtitle: participant.joinedAt != null
            ? DateFormat.Hm().format(participant.joinedAt!)
            : 'meetParticipant'.tr(),
        fallbackName: participant.accountId,
      ),
    );
  }

  return people;
}

String _statusLabel(SnMeetStatus status, BuildContext context) {
  return switch (status) {
    SnMeetStatus.active => 'meetStatusActive'.tr(),
    SnMeetStatus.completed => 'meetStatusCompleted'.tr(),
    SnMeetStatus.expired => 'meetStatusExpired'.tr(),
    SnMeetStatus.cancelled => 'meetStatusCancelled'.tr(),
    SnMeetStatus.unknown => 'unknown'.tr(),
  };
}

String _eventLabel(String type, BuildContext context) {
  return switch (type) {
    'snapshot' => 'meetEventSnapshot'.tr(),
    'participant_joined' => 'meetEventParticipantJoined'.tr(),
    'completed' => 'meetEventCompleted'.tr(),
    'expired' => 'meetEventExpired'.tr(),
    _ => type,
  };
}
