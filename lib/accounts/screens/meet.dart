import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/meet_bluetooth.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/accounts/meet_tap.dart';
import 'package:island/accounts/widgets/account/account_nameplate.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

final meetHistoryProvider = FutureProvider.autoDispose<List<SnMeet>>((
  ref,
) async {
  return ref.watch(meetServiceProvider).listMeets(take: 20);
});

enum MeetEntryMode { nearby, tap }

@RoutePage()
class MeetScreen extends HookConsumerWidget {
  const MeetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeData = RouteData.of(context);
    final initialMeetId = routeData.queryParams.optString('meet_id') ?? '';
    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);
    final tapService = ref.watch(meetTapServiceProvider);
    final meetHistory = ref.watch(meetHistoryProvider);

    final joinController = useTextEditingController(text: initialMeetId);
    final topicController = useTextEditingController();
    final notesController = useTextEditingController();
    final tabController = useTabController(
      initialLength: 4,
      initialIndex: initialMeetId.isNotEmpty ? 1 : 0,
    );
    final entryMode = useState(MeetEntryMode.nearby);
    final visibility = useState(SnMeetVisibility.private);
    final selectedImage = useState<SnCloudFile?>(null);
    final locationDraft = useState<_MeetLocationDraft?>(null);
    final isLocating = useState(false);
    final actionBusy = useState(false);
    final isScanning = useState(false);
    final discoveries = useState<List<MeetBluetoothDiscovery>>([]);
    final didAutoJoin = useState(false);
    final scanResultSub = useRef<StreamSubscription<List<ScanResult>>?>(null);
    final scanStateSub = useRef<StreamSubscription<bool>?>(null);

    Future<void> startNearbyScan() async {
      if (!bluetoothService.supportsNearbyDiscovery) {
        showErrorAlert('meetBluetoothUnavailable'.tr());
        return;
      }

      await scanResultSub.value?.cancel();
      discoveries.value = [];

      scanResultSub.value = FlutterBluePlus.onScanResults.listen(
        (results) {
          discoveries.value = bluetoothService.parseDiscoveries(results);
        },
        onError: (error, _) {
          isScanning.value = false;
          showErrorAlert(error);
        },
      );
      FlutterBluePlus.cancelWhenScanComplete(scanResultSub.value!);

      isScanning.value = true;
      try {
        await bluetoothService.startScan();
      } catch (error) {
        isScanning.value = false;
        showErrorAlert(error);
      }

      scanStateSub.value ??= FlutterBluePlus.isScanning.listen((value) {
        isScanning.value = value;
      });
    }

    Future<void> fillCurrentLocation() async {
      isLocating.value = true;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw StateError('Location services are turned off.');
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw StateError(
            'Location permission is required to fill meet place.',
          );
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final latitude = position.latitude;
        final longitude = position.longitude;
        String? name;
        String? address;

        final canReverseGeocode =
            !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS);

        if (canReverseGeocode) {
          try {
            final placemarks = await placemarkFromCoordinates(
              latitude,
              longitude,
            );
            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              final names =
                  [placemark.name, placemark.subLocality, placemark.locality]
                      .where((e) => e?.trim().isNotEmpty ?? false)
                      .cast<String>()
                      .toList();
              name = names.isNotEmpty ? names.first : null;
              address =
                  [
                        placemark.street,
                        placemark.subAdministrativeArea,
                        placemark.administrativeArea,
                        placemark.country,
                      ]
                      .where((e) => e?.trim().isNotEmpty ?? false)
                      .cast<String>()
                      .join(', ');
            }
          } catch (_) {}
        }

        final fallbackName =
            'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}';
        final draft = _MeetLocationDraft(
          name: name ?? fallbackName,
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
        locationDraft.value = draft;
      } catch (error) {
        showErrorAlert(error);
      } finally {
        isLocating.value = false;
      }
    }

    Future<void> openMeetDetail(String meetId) async {
      if (!context.mounted) return;
      await context.router.push(MeetDetailRoute(id: meetId));
      ref.invalidate(meetHistoryProvider);
    }

    Future<void> startMeet() async {
      actionBusy.value = true;
      try {
        final metadata = <String, dynamic>{};
        if (topicController.text.trim().isNotEmpty) {
          metadata['topic'] = topicController.text.trim();
        }
        metadata['entry_mode'] = switch (entryMode.value) {
          MeetEntryMode.nearby => 'nearby',
          MeetEntryMode.tap => 'tap',
        };

        final meet = await meetService.createMeet(
          visibility: visibility.value,
          notes: notesController.text.trim(),
          imageId: selectedImage.value?.id,
          locationName: locationDraft.value?.name,
          locationAddress: locationDraft.value?.address,
          locationWkt: locationDraft.value?.wkt,
          metadata: metadata,
          expiresInSeconds: 1800,
        );

        ref.invalidate(meetHistoryProvider);
        if (entryMode.value == MeetEntryMode.tap) {
          try {
            await tapService.writeMeetTag(meet.id);
            if (context.mounted) {
              showSnackBar('meetTapReady'.tr());
            }
          } catch (error) {
            showErrorAlert(error);
          }
        }
        await openMeetDetail(meet.id);
      } catch (error) {
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
      try {
        await openMeetDetail(normalized);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> joinTapMeet() async {
      actionBusy.value = true;
      try {
        final payload = await tapService.readMeetTag();
        final snapshot = await meetService.joinMeet(payload.meetId).first;
        if (context.mounted) {
          await _showTapMeetNameCard(context, snapshot.meet);
        }
        await openMeetDetail(payload.meetId);
      } catch (error) {
        showErrorAlert(error);
      } finally {
        actionBusy.value = false;
      }
    }

    useEffect(() {
      void handleTabChange() {
        if (tabController.index == 1 &&
            !tabController.indexIsChanging &&
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
    }, [tabController, isScanning.value]);

    useEffect(() {
      if (initialMeetId.isNotEmpty && !didAutoJoin.value) {
        didAutoJoin.value = true;
        Future.microtask(() => openMeetDetail(initialMeetId));
      }

      return () {
        unawaited(bluetoothService.stopScan());
        unawaited(scanResultSub.value?.cancel() ?? Future.value());
        unawaited(scanStateSub.value?.cancel() ?? Future.value());
      };
    }, [initialMeetId]);

    return DefaultTabController(
      length: 3,
      child: AppScaffold(
        appBar: AppBar(
          title: Text('meet').tr(),
          leading: const AutoLeadingButton(),
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(
                child: Text(
                  'meetStart'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'meetNearbyTab'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'meetTap'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'meetHistory'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
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
                  topicController: topicController,
                  notesController: notesController,
                  busy: actionBusy.value,
                  advertising: false,
                  entryMode: entryMode.value,
                  locationDraft: locationDraft.value,
                  isLocating: isLocating.value,
                  visibility: visibility.value,
                  image: selectedImage.value,
                  tapSupported: tapService.supportsTapMeet,
                  onChangeEntryMode: (value) => entryMode.value = value,
                  onChangeVisibility: (value) => visibility.value = value,
                  onUseCurrentLocation: fillCurrentLocation,
                  onClearLocation: () => locationDraft.value = null,
                  onPickImage: () async {
                    final result = await showModalBottomSheet<SnCloudFile?>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => const CloudFilePicker(
                        allowedTypes: {UniversalFileType.image},
                      ),
                    );
                    if (result != null) {
                      selectedImage.value = result;
                    }
                  },
                  onRemoveImage: () => selectedImage.value = null,
                  onStart: startMeet,
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
                if (discoveries.value.isNotEmpty)
                  _MeetNearbyCard(
                    discoveries: discoveries.value,
                    onJoin: (meetId) => joinMeetById(meetId),
                  )
                else
                  _MeetInfoCard(
                    icon: Symbols.groups,
                    title: 'meetJoinReadyTitle'.tr(),
                    description: 'meetJoinReadyDescription'.tr(),
                  ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MeetTapCard(
                  busy: actionBusy.value,
                  supported: tapService.supportsTapMeet,
                  onTapJoin: joinTapMeet,
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MeetHistorySection(
                  history: meetHistory,
                  onOpen: (meet) => openMeetDetail(meet.id),
                  onRetry: () => ref.invalidate(meetHistoryProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@RoutePage()
class MeetDetailScreen extends HookConsumerWidget {
  final String id;

  const MeetDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userInfoProvider).value;
    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);

    final meet = useState<SnMeet?>(null);
    final error = useState<Object?>(null);
    final eventType = useState<String?>(null);
    final isWatching = useState(false);
    final isAdvertising = useState(false);
    final actionBusy = useState(false);
    final watchSub = useRef<StreamSubscription<SnMeetEvent>?>(null);

    Future<void> stopAdvertising() async {
      if (!isAdvertising.value) return;
      await bluetoothService.stopAdvertising();
      isAdvertising.value = false;
    }

    Future<void> stopWatching() async {
      await watchSub.value?.cancel();
      watchSub.value = null;
      isWatching.value = false;
    }

    Future<void> loadMeet() async {
      error.value = null;
      try {
        final item = await meetService.getMeet(id);
        meet.value = item;
      } catch (err) {
        error.value = err;
      }
    }

    Future<void> watchMeet() async {
      final current = meet.value;
      if (current == null || current.status != SnMeetStatus.active) return;

      await stopWatching();
      isWatching.value = true;
      watchSub.value = meetService
          .joinMeet(id)
          .listen(
            (event) {
              meet.value = event.meet;
              eventType.value = event.type;
              if (event.meet.isFinal) {
                isWatching.value = false;
                unawaited(stopAdvertising());
                ref.invalidate(meetHistoryProvider);
              }
            },
            onError: (err, _) {
              error.value = err;
              isWatching.value = false;
            },
          );
    }

    Future<void> maybeStartAdvertising() async {
      final current = meet.value;
      final isHost = current != null && current.hostId == currentUser?.id;
      if (!isHost || current.status != SnMeetStatus.active) return;
      if (_entryModeOf(current) != MeetEntryMode.nearby) return;
      if (!bluetoothService.supportsAdvertising) return;

      try {
        await bluetoothService.startAdvertising(current.id);
        isAdvertising.value = true;
      } catch (_) {
        isAdvertising.value = false;
      }
    }

    Future<void> completeMeet() async {
      final current = meet.value;
      if (current == null) return;
      actionBusy.value = true;
      try {
        await meetService.completeMeet(current.id);
        await loadMeet();
        ref.invalidate(meetHistoryProvider);
      } catch (err) {
        showErrorAlert(err);
      } finally {
        actionBusy.value = false;
      }
    }

    useEffect(() {
      Future.microtask(() async {
        await loadMeet();
        await maybeStartAdvertising();
        await watchMeet();
      });

      return () {
        unawaited(stopWatching());
        unawaited(stopAdvertising());
      };
    }, [id]);

    final current = meet.value;
    final participants = _displayParticipants(current, currentUser);
    final isHost = current != null && current.hostId == currentUser?.id;
    final entryMode = _entryModeOf(current);

    if (current != null && current.status == SnMeetStatus.active) {
      return _MeetActiveListeningPage(
        meet: current,
        entryMode: entryMode,
        participants: participants,
        isWatching: isWatching.value,
        isAdvertising: isAdvertising.value,
        isHost: isHost,
        actionBusy: actionBusy.value,
        onClose: context.router.maybePop,
        onComplete: completeMeet,
      );
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text('meetDetail').tr(),
        leading: const AutoLeadingButton(),
      ),
      body: error.value != null
          ? ResponseErrorWidget(error: error.value, onRetry: loadMeet)
          : current == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MeetDetailHero(
                  meet: current,
                  entryMode: entryMode,
                  participants: participants,
                  isWatching: isWatching.value,
                  isAdvertising: isAdvertising.value,
                ),
                const Gap(16),
                _MeetDetailInfo(
                  meet: current,
                  entryMode: entryMode,
                  eventType: eventType.value,
                  participants: participants,
                ),
                if (isHost) ...[
                  const Gap(16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: context.router.maybePop,
                          child: Text('close').tr(),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: FilledButton(
                          onPressed:
                              actionBusy.value ||
                                  current.status != SnMeetStatus.active
                              ? null
                              : completeMeet,
                          child: Text('meetComplete').tr(),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _MeetActiveListeningPage extends HookWidget {
  final SnMeet meet;
  final MeetEntryMode entryMode;
  final List<_MeetPerson> participants;
  final bool isWatching;
  final bool isAdvertising;
  final bool isHost;
  final bool actionBusy;
  final VoidCallback onClose;
  final VoidCallback onComplete;

  const _MeetActiveListeningPage({
    required this.meet,
    required this.entryMode,
    required this.participants,
    required this.isWatching,
    required this.isAdvertising,
    required this.isHost,
    required this.actionBusy,
    required this.onClose,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    final theme = Theme.of(context);
    final topic = meet.metadata['topic']?.toString();

    return AppScaffold(
      isNoBackground: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.surface,
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
                      icon: entryMode == MeetEntryMode.tap
                          ? Symbols.contactless
                          : Symbols.bluetooth_searching,
                      label: _entryModeLabel(entryMode, context),
                    ),
                    const Gap(8),
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
                              .map(
                                (participant) => _ParticipantBubble(
                                  key: ValueKey(participant.id),
                                  participant: participant,
                                ),
                              )
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
                        child: Text(isHost ? 'close'.tr() : 'close'.tr()),
                      ),
                    ),
                    if (isHost) ...[
                      const Gap(12),
                      Expanded(
                        child: FilledButton(
                          onPressed: actionBusy ? null : onComplete,
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

class _MeetDetailHero extends HookWidget {
  final SnMeet meet;
  final MeetEntryMode entryMode;
  final List<_MeetPerson> participants;
  final bool isWatching;
  final bool isAdvertising;

  const _MeetDetailHero({
    required this.meet,
    required this.entryMode,
    required this.participants,
    required this.isWatching,
    required this.isAdvertising,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = meet.metadata['topic']?.toString();
    final title = meet.status == SnMeetStatus.completed
        ? 'meetMemoryTitle'.tr()
        : meet.status == SnMeetStatus.expired
        ? 'meetExpiredTitle'.tr()
        : 'meetDetailTitle'.tr();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 340,
        child: Stack(
          children: [
            Positioned.fill(
              child: meet.image != null
                  ? CloudImageWidget(file: meet.image, fit: BoxFit.cover)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surfaceContainerHigh,
                            theme.colorScheme.surfaceContainer,
                          ],
                        ),
                      ),
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.08),
                      Colors.black.withOpacity(0.52),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(label: _entryModeLabel(entryMode, context)),
                      _HeroPill(label: _statusLabel(meet.status, context)),
                      _HeroPill(
                        label: _visibilityLabel(meet.visibility, context),
                      ),
                      if (isAdvertising)
                        _HeroPill(label: 'meetBroadcasting'.tr()),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    meet.locationName?.isNotEmpty == true
                        ? meet.locationName!
                        : 'meetLiveTitle'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (topic?.isNotEmpty ?? false)
                    Text(topic!, style: const TextStyle(color: Colors.white70)),
                  if (!(topic?.isNotEmpty ?? false) &&
                      (meet.notes?.isNotEmpty ?? false))
                    Text(
                      meet.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  const Gap(16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: participants
                        .map(
                          (participant) => _ParticipantBubble(
                            key: ValueKey(participant.id),
                            participant: participant,
                            isLight: true,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetDetailInfo extends StatelessWidget {
  final SnMeet meet;
  final MeetEntryMode entryMode;
  final String? eventType;
  final List<_MeetPerson> participants;

  const _MeetDetailInfo({
    required this.meet,
    required this.entryMode,
    required this.eventType,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_parseMeetPoint(meet.locationWkt) case final point?) ...[
              _MeetLocationMapCard(
                point: point,
                locationName: meet.locationName,
                locationAddress: meet.locationAddress,
              ),
              const Gap(16),
            ],
            if (meet.notes?.isNotEmpty ?? false) ...[
              Text('meetNotesLabel').tr().fontSize(16).bold(),
              const Gap(6),
              Text(meet.notes!),
              const Gap(16),
            ],
            if (meet.locationAddress?.isNotEmpty ?? false) ...[
              Text('meetAddress').tr().fontSize(16).bold(),
              const Gap(6),
              Text(meet.locationAddress!),
              const Gap(16),
            ],
            Text('meetRecordDetails').tr().fontSize(16).bold(),
            const Gap(10),
            _DetailRow(label: 'meetId'.tr(), value: meet.id, copyable: true),
            _DetailRow(
              label: 'meetMethod'.tr(),
              value: _entryModeLabel(entryMode, context),
            ),
            _DetailRow(
              label: 'meetVisibility'.tr(),
              value: _visibilityLabel(meet.visibility, context),
            ),
            if (meet.locationWkt?.isNotEmpty ?? false)
              _DetailRow(
                label: 'meetCoordinates'.tr(),
                value: meet.locationWkt!,
              ),
            if (meet.expiresAt != null)
              _DetailRow(
                label: 'meetExpiresAt'.tr(),
                value: DateFormat.yMd().add_Hm().format(meet.expiresAt!),
              ),
            if (eventType?.isNotEmpty ?? false)
              _DetailRow(
                label: 'meetLastUpdate'.tr(),
                value: _eventLabel(eventType!, context),
              ),
            const Gap(16),
            Text(
              'meetParticipantsCount'.tr(args: ['${participants.length}']),
            ).fontSize(16).bold(),
            const Gap(8),
            ...participants.map(
              (participant) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: participant.account != null
                    ? ProfilePictureWidget(
                        file: participant.account!.profile.picture,
                        radius: 20,
                      )
                    : const CircleAvatar(
                        radius: 20,
                        child: Icon(Symbols.person, size: 18),
                      ),
                title: Text(
                  participant.account?.nick.isNotEmpty == true
                      ? participant.account!.nick
                      : '@${participant.account?.name ?? participant.fallbackName}',
                ),
                subtitle: Text(participant.subtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetStartCard extends StatelessWidget {
  final TextEditingController topicController;
  final TextEditingController notesController;
  final bool busy;
  final bool advertising;
  final MeetEntryMode entryMode;
  final _MeetLocationDraft? locationDraft;
  final bool isLocating;
  final SnMeetVisibility visibility;
  final SnCloudFile? image;
  final bool tapSupported;
  final ValueChanged<MeetEntryMode> onChangeEntryMode;
  final ValueChanged<SnMeetVisibility> onChangeVisibility;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onClearLocation;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onStart;

  const _MeetStartCard({
    required this.topicController,
    required this.notesController,
    required this.busy,
    required this.advertising,
    required this.entryMode,
    required this.locationDraft,
    required this.isLocating,
    required this.visibility,
    required this.image,
    required this.tapSupported,
    required this.onChangeEntryMode,
    required this.onChangeVisibility,
    required this.onUseCurrentLocation,
    required this.onClearLocation,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              entryMode == MeetEntryMode.tap
                  ? 'meetTapStartTitle'.tr()
                  : 'meetStartTitle'.tr(),
            ).fontSize(18).bold(),
            const Gap(8),
            Text(
              entryMode == MeetEntryMode.tap
                  ? 'meetTapStartDescription'.tr()
                  : 'meetStartDescription'.tr(),
            ),
            const Gap(16),
            SegmentedButton<MeetEntryMode>(
              segments: [
                ButtonSegment(
                  value: MeetEntryMode.nearby,
                  icon: const Icon(Symbols.bluetooth_searching),
                  label: Text('meetNearbyTab').tr(),
                ),
                ButtonSegment(
                  value: MeetEntryMode.tap,
                  enabled: tapSupported,
                  icon: const Icon(Symbols.contactless),
                  label: Text('meetTap').tr(),
                ),
              ],
              selected: {entryMode},
              onSelectionChanged: (value) => onChangeEntryMode(value.first),
            ),
            const Gap(12),
            SegmentedButton<SnMeetVisibility>(
              segments: [
                ButtonSegment(
                  value: SnMeetVisibility.private,
                  icon: const Icon(Symbols.lock),
                  label: Text('meetVisibilityPrivate').tr(),
                ),
                ButtonSegment(
                  value: SnMeetVisibility.public,
                  icon: const Icon(Symbols.public),
                  label: Text('meetVisibilityPublic').tr(),
                ),
              ],
              selected: {visibility},
              onSelectionChanged: (value) => onChangeVisibility(value.first),
            ),
            const Gap(12),
            TextField(
              controller: notesController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'meetNotesLabel'.tr(),
                hintText: 'meetNotesHint'.tr(),
              ),
            ),
            const Gap(12),
            Text('meetLocationLabel').tr().fontSize(16).bold(),
            const Gap(8),
            Card.outlined(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationDraft?.name ?? 'meetLocationUnavailable'.tr(),
                    ).fontSize(15).bold(),
                    const Gap(4),
                    Text(
                      locationDraft?.address?.isNotEmpty == true
                          ? locationDraft!.address!
                          : locationDraft?.wkt ??
                                'meetLocationGpsOnlyHint'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: isLocating ? null : onUseCurrentLocation,
                  icon: Icon(
                    isLocating
                        ? Symbols.progress_activity
                        : Symbols.my_location,
                  ),
                  label: Text(
                    isLocating
                        ? 'meetLocating'.tr()
                        : 'meetUseCurrentLocation'.tr(),
                  ),
                ),
                if (locationDraft != null)
                  TextButton(
                    onPressed: onClearLocation,
                    child: Text('meetRemoveLocation').tr(),
                  ),
              ],
            ),
            const Gap(12),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: 'meetTopicLabel'.tr(),
                hintText: 'meetTopicHint'.tr(),
              ),
            ),
            const Gap(12),
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CloudImageWidget(file: image, fit: BoxFit.cover),
                ),
              ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onPickImage,
                  icon: const Icon(Symbols.image),
                  label: Text(
                    image == null
                        ? 'meetAddImage'.tr()
                        : 'meetChangeImage'.tr(),
                  ),
                ),
                if (image != null)
                  TextButton(
                    onPressed: onRemoveImage,
                    child: Text('remove').tr(),
                  ),
              ],
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : onStart,
                icon: Icon(
                  entryMode == MeetEntryMode.tap
                      ? Symbols.contactless
                      : Symbols.add_circle,
                ),
                label: Text(
                  entryMode == MeetEntryMode.tap
                      ? 'meetTapPrepare'.tr()
                      : (advertising
                            ? 'meetRestartBroadcast'.tr()
                            : 'meetStartNow'.tr()),
                ),
              ),
            ),
            if (entryMode == MeetEntryMode.tap) ...[
              const Gap(12),
              Text(
                tapSupported
                    ? 'meetTapStartHint'.tr()
                    : 'meetTapUnsupported'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
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
              scanning
                  ? 'meetJoinScanningHint'.tr()
                  : 'meetJoinNearbyHint'.tr(),
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

class _MeetTapCard extends StatelessWidget {
  final bool busy;
  final bool supported;
  final VoidCallback onTapJoin;

  const _MeetTapCard({
    required this.busy,
    required this.supported,
    required this.onTapJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Symbols.contactless,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('meetTapTitle').tr().fontSize(18).bold(),
                        const Gap(4),
                        Text('meetTapDescription').tr(),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                      effects: [
                        MoveEffect(
                          begin: Offset.zero,
                          end: const Offset(0, -6),
                          duration: 900.ms,
                          curve: Curves.easeInOut,
                        ),
                      ],
                      child: Icon(
                        Symbols.waving_hand,
                        size: 42,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Gap(12),
                    Text('meetTapPrompt').tr().fontSize(16).bold(),
                    const Gap(6),
                    Text(
                      supported
                          ? 'meetTapHint'.tr()
                          : 'meetTapUnsupported'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy || !supported ? null : onTapJoin,
                  icon: Icon(
                    busy ? Symbols.progress_activity : Symbols.contactless,
                  ),
                  label: Text(
                    busy ? 'meetTapScanning'.tr() : 'meetTapJoin'.tr(),
                  ),
                ),
              ),
            ],
          ),
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
                  args: [estimateDistancePercent(item.rssi).toString()],
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

class _MeetHistorySection extends StatelessWidget {
  final AsyncValue<List<SnMeet>> history;
  final ValueChanged<SnMeet> onOpen;
  final VoidCallback onRetry;

  const _MeetHistorySection({
    required this.history,
    required this.onOpen,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: history.when(
          data: (items) {
            if (items.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('meetHistory').tr().fontSize(18).bold(),
                  const Gap(8),
                  Text('meetHistoryEmpty').tr(),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('meetHistory').tr().fontSize(18).bold(),
                const Gap(12),
                ...items.map((meet) {
                  final subtitle = [
                    if (meet.locationName?.isNotEmpty ?? false)
                      meet.locationName!,
                    if (meet.notes?.isNotEmpty ?? false) meet.notes!,
                  ].join(' · ');

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: meet.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: CloudImageWidget(
                                file: meet.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : const CircleAvatar(
                            child: Icon(Symbols.groups, size: 20),
                          ),
                    title: Text(
                      subtitle.isNotEmpty
                          ? subtitle
                          : _statusLabel(meet.status, context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        _entryModeLabel(_entryModeOf(meet), context),
                        _statusLabel(meet.status, context),
                        _visibilityLabel(meet.visibility, context),
                        if (meet.expiresAt != null)
                          DateFormat.yMd().add_Hm().format(meet.expiresAt!),
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Symbols.chevron_right),
                    onTap: () => onOpen(meet),
                  );
                }),
              ],
            );
          },
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('meetHistory').tr().fontSize(18).bold(),
              const Gap(12),
              const LinearProgressIndicator(),
            ],
          ),
          error: (error, _) =>
              ResponseErrorWidget(error: error, onRetry: onRetry),
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

class _MeetLocationMapCard extends StatelessWidget {
  final latlong.LatLng point;
  final String? locationName;
  final String? locationAddress;

  const _MeetLocationMapCard({
    required this.point,
    required this.locationName,
    required this.locationAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 280,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15.2,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.solsynth.solian',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 72,
                      height: 72,
                      child: _MeetMapPin(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Symbols.location_on,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                locationName?.isNotEmpty == true
                                    ? locationName!
                                    : 'meetLocationLabel'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).fontSize(15).bold(),
                              if (locationAddress?.isNotEmpty == true)
                                Text(
                                  locationAddress!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetMapPin extends StatelessWidget {
  final Color color;

  const _MeetMapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
            ),
          ),
          Container(width: 2, height: 18, color: color),
        ],
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

class _ParticipantBubble extends HookWidget {
  final _MeetPerson participant;
  final bool isLight;

  const _ParticipantBubble({
    super.key,
    required this.participant,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 420),
    );
    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    );
    final scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

    useEffect(() {
      controller.forward();
      return null;
    }, const []);

    final account = participant.account;
    final label = account?.nick.isNotEmpty == true
        ? account!.nick
        : '@${account?.name ?? participant.fallbackName}';
    final secondaryColor = isLight
        ? Colors.white70
        : Theme.of(context).colorScheme.secondary;
    final textColor = isLight ? Colors.white : null;

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale,
        child: SizedBox(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              account != null
                  ? ProfilePictureWidget(
                      file: account.profile.picture,
                      radius: 28,
                    )
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
                style: textColor != null ? TextStyle(color: textColor) : null,
              ),
              Text(
                participant.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryColor),
              ).fontSize(12),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
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
        children: [Icon(icon, size: 18), const Gap(8), Text(label)],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
          if (copyable)
            IconButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: value));
                showSnackBar('copyToClipboard'.tr());
              },
              icon: const Icon(Symbols.content_copy),
            ),
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

class _MeetLocationDraft {
  final String name;
  final String? address;
  final double latitude;
  final double longitude;

  const _MeetLocationDraft({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  String get wkt =>
      'POINT(${longitude.toStringAsFixed(6)} ${latitude.toStringAsFixed(6)})';
}

List<_MeetPerson> _displayParticipants(SnMeet? meet, SnAccount? currentUser) {
  if (meet == null) return const [];

  final people = <_MeetPerson>[];
  final seen = <String>{};
  final hostAccount =
      meet.host ?? (currentUser?.id == meet.hostId ? currentUser : null);

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

String _visibilityLabel(SnMeetVisibility visibility, BuildContext context) {
  return switch (visibility) {
    SnMeetVisibility.public => 'meetVisibilityPublic'.tr(),
    SnMeetVisibility.private => 'meetVisibilityPrivate'.tr(),
    SnMeetVisibility.unknown => 'unknown'.tr(),
  };
}

MeetEntryMode _entryModeOf(SnMeet? meet) {
  final raw = meet?.metadata['entry_mode']?.toString().trim().toLowerCase();
  return raw == 'tap' ? MeetEntryMode.tap : MeetEntryMode.nearby;
}

String _entryModeLabel(MeetEntryMode mode, BuildContext context) {
  return switch (mode) {
    MeetEntryMode.nearby => 'meetNearbyTab'.tr(),
    MeetEntryMode.tap => 'meetTap'.tr(),
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

latlong.LatLng? _parseMeetPoint(String? wkt) {
  final raw = wkt?.trim();
  if (raw == null || raw.isEmpty) return null;

  final match = RegExp(
    r'^POINT\s*\(\s*(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s*\)$',
    caseSensitive: false,
  ).firstMatch(raw);
  if (match == null) return null;

  final longitude = double.tryParse(match.group(1)!);
  final latitude = double.tryParse(match.group(2)!);
  if (longitude == null || latitude == null) return null;

  return latlong.LatLng(latitude, longitude);
}

Future<void> _showTapMeetNameCard(BuildContext context, SnMeet meet) async {
  final host = meet.host;
  if (host == null) return;

  await showOverlayDialog<void>(
    barrierDismissible: false,
    builder: (context, close) {
      return HookBuilder(
        builder: (context) {
          final theme = Theme.of(context);
          useEffect(() {
            final timer = Timer(
              const Duration(milliseconds: 1400),
              () => close(null),
            );
            return timer.cancel;
          }, const []);

          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Animate(
                    onPlay: (controller) => controller.repeat(),
                    effects: [
                      ScaleEffect(
                        begin: const Offset(0.82, 0.82),
                        end: const Offset(1.08, 1.08),
                        duration: 1800.ms,
                        curve: Curves.easeOut,
                      ),
                      FadeEffect(begin: 1, end: 0, duration: 1800.ms),
                    ],
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Animate(
                    effects: [
                      FadeEffect(
                        begin: 0,
                        end: 1,
                        duration: 260.ms,
                        curve: Curves.easeOutCubic,
                      ),
                      ScaleEffect(
                        begin: const Offset(0.94, 0.94),
                        end: const Offset(1, 1),
                        duration: 420.ms,
                        curve: Curves.easeOutBack,
                      ),
                    ],
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('meetTapMatched').tr().fontSize(18).bold(),
                            const Gap(8),
                            Text(
                              'meetTapMatchedDescription'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            const Gap(12),
                            AccountNameplate(
                              name: host.name,
                              isOutlined: false,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
