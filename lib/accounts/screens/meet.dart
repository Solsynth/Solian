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
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final payload = tapService.parsePayload(data?.text ?? '');
        if (payload == null) {
          throw StateError('Copy a Solian Meet link or meet ID first.');
        }
        await openMeetDetail(payload.meetId);
      } catch (error) {
        showErrorAlert(error);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> scanMeetWithCamera() async {
      final payload = await showModalBottomSheet<MeetTapPayload>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _MeetQrScannerSheet(service: tapService),
      );
      if (payload == null) return;

      actionBusy.value = true;
      try {
        await openMeetDetail(payload.meetId);
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
      length: 4,
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
                  'meetScan'.tr(),
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
                  tapSupported: true,
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
                  supported: true,
                  onTapJoin: joinTapMeet,
                  onScan: scanMeetWithCamera,
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
    final client = ref.watch(apiClientProvider);
    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);

    final meet = useState<SnMeet?>(null);
    final error = useState<Object?>(null);
    final eventType = useState<String?>(null);
    final isWatching = useState(false);
    final isAdvertising = useState(false);
    final actionBusy = useState(false);
    final watchSub = useRef<StreamSubscription<SnMeetEvent>?>(null);
    final latestArrival = useState<_MeetPerson?>(null);
    final knownParticipantIds = useRef<Set<String>>(<String>{});

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
        knownParticipantIds.value = _participantIdsOf(item);
      } catch (err) {
        error.value = err;
      }
    }

    Future<void> requestFriend(SnAccount account) async {
      if (account.id == currentUser?.id) return;

      showLoadingModal(context);
      try {
        await client.post('/passport/relationships/${account.id}/friends');
        showSnackBar('pendingRequest'.tr());
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
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
              final previousIds = Set<String>.from(knownParticipantIds.value);
              final nextIds = _participantIdsOf(event.meet);
              meet.value = event.meet;
              eventType.value = event.type;
              knownParticipantIds.value = nextIds;
              if (event.type == 'participant_joined') {
                final newcomer = _findLatestArrival(
                  meet: event.meet,
                  previousIds: previousIds,
                  currentUserId: currentUser?.id,
                );
                if (newcomer != null) {
                  latestArrival.value = newcomer;
                }
              }
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
        latestArrival: latestArrival.value,
        currentUserId: currentUser?.id,
        canRequestFriend: current.visibility == SnMeetVisibility.public,
        onRequestFriend: requestFriend,
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
                  isScanShareReady:
                      entryMode == MeetEntryMode.tap &&
                      current.hostId == currentUser?.id &&
                      current.status == SnMeetStatus.active,
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
  final _MeetPerson? latestArrival;
  final String? currentUserId;
  final bool canRequestFriend;
  final ValueChanged<SnAccount> onRequestFriend;
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
    required this.latestArrival,
    required this.currentUserId,
    required this.canRequestFriend,
    required this.onRequestFriend,
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
    final scanUri = MeetTapService().buildMeetUri(meet.id);

    if (entryMode == MeetEntryMode.tap) {
      return _MeetScanExchangePage(
        meet: meet,
        participants: participants,
        isWatching: isWatching,
        isHost: isHost,
        actionBusy: actionBusy,
        scanUri: scanUri,
        latestArrival: latestArrival,
        currentUserId: currentUserId,
        canRequestFriend: canRequestFriend,
        onRequestFriend: onRequestFriend,
        onClose: onClose,
        onComplete: onComplete,
      );
    }

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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isAdvertising)
                        _InfoPill(
                          icon: Symbols.bluetooth,
                          label: 'meetBroadcasting'.tr(),
                        ),
                      if (isAdvertising) const Gap(8),
                      if (entryMode == MeetEntryMode.tap && isHost)
                        _InfoPill(
                          icon: Symbols.qr_code_2,
                          label: 'meetScanReady'.tr(),
                        ),
                      if (entryMode == MeetEntryMode.tap && isHost)
                        const Gap(8),
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
                if (entryMode == MeetEntryMode.tap && isHost) ...[
                  _MeetScanCodeCard(uri: scanUri),
                  const Gap(16),
                ],
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
  final bool isScanShareReady;

  const _MeetDetailHero({
    required this.meet,
    required this.entryMode,
    required this.participants,
    required this.isWatching,
    required this.isAdvertising,
    required this.isScanShareReady,
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
                      if (isScanShareReady)
                        _HeroPill(label: 'meetScanReady'.tr()),
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

class _MeetScanExchangePage extends HookWidget {
  final SnMeet meet;
  final List<_MeetPerson> participants;
  final bool isWatching;
  final bool isHost;
  final bool actionBusy;
  final Uri scanUri;
  final _MeetPerson? latestArrival;
  final String? currentUserId;
  final bool canRequestFriend;
  final ValueChanged<SnAccount> onRequestFriend;
  final VoidCallback onClose;
  final VoidCallback onComplete;

  const _MeetScanExchangePage({
    required this.meet,
    required this.participants,
    required this.isWatching,
    required this.isHost,
    required this.actionBusy,
    required this.scanUri,
    required this.latestArrival,
    required this.currentUserId,
    required this.canRequestFriend,
    required this.onRequestFriend,
    required this.onClose,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    final topic = meet.metadata['topic']?.toString();
    final arrivalCard = useState<_MeetPerson?>(null);
    final participantCards = participants;

    useEffect(() {
      final arrival = latestArrival;
      if (arrival == null) return null;
      arrivalCard.value = arrival;
      final timer = Timer(const Duration(milliseconds: 2600), () {
        if (arrivalCard.value?.id == arrival.id) {
          arrivalCard.value = null;
        }
      });
      return timer.cancel;
    }, [latestArrival?.id]);

    return AppScaffold(
      isNoBackground: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primaryContainer.withOpacity(0.28),
              theme.colorScheme.secondaryContainer.withOpacity(0.24),
            ],
          ),
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
                                : 'meetScanLiveSubtitle'.tr(),
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: scanUri.toString()),
                        );
                        showSnackBar('copyToClipboard'.tr());
                      },
                      icon: const Icon(Symbols.content_copy),
                    ),
                  ],
                ),
                const Gap(12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _InfoPill(
                        icon: Symbols.badge,
                        label: 'meetScanReady'.tr(),
                      ),
                      const Gap(8),
                      _InfoPill(
                        icon: isWatching ? Symbols.sync : Symbols.sync_disabled,
                        label: isWatching
                            ? 'meetWatching'.tr()
                            : 'meetWatchStopped'.tr(),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: ListView(
                    children: [
                      _MeetScanStageCard(
                        isHost: isHost,
                        scanUri: scanUri,
                        animation: pulse,
                      ),
                      if (arrivalCard.value != null) ...[
                        const Gap(16),
                        _MeetScanArrivalBanner(
                          participant: arrivalCard.value!,
                        ),
                      ],
                      const Gap(16),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'meetScanCardsTitle',
                              ).tr().fontSize(18).bold(),
                              const Gap(6),
                              Text(
                                isHost
                                    ? 'meetScanCardsHostHint'.tr()
                                    : 'meetScanCardsGuestHint'.tr(),
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              const Gap(16),
                              if (participantCards.isEmpty)
                                _MeetInfoCard(
                                  icon: Symbols.id_card,
                                  title: 'meetParticipantsEmpty'.tr(),
                                  description: 'meetScanCardsEmpty'.tr(),
                                )
                              else
                                Column(
                                  children: participantCards
                                      .map(
                                        (participant) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: _MeetNameCard(
                                            participant: participant,
                                            canRequestFriend:
                                                canRequestFriend,
                                            currentUserId: currentUserId,
                                            onRequestFriend: onRequestFriend,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        child: Text('close').tr(),
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

class _MeetScanStageCard extends StatelessWidget {
  final bool isHost;
  final Uri scanUri;
  final Animation<double> animation;

  const _MeetScanStageCard({
    required this.isHost,
    required this.scanUri,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              isHost
                  ? 'meetScanStageHostTitle'.tr()
                  : 'meetScanStageGuestTitle'.tr(),
            ).fontSize(20).bold(),
            const Gap(8),
            Text(
              isHost
                  ? 'meetScanStageHostHint'.tr()
                  : 'meetScanStageGuestHint'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
            const Gap(20),
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final scale = 0.92 + (animation.value * 0.12);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.08),
                        ),
                      ),
                    );
                  },
                ),
                if (isHost)
                  _MeetScanCodeCard(uri: scanUri)
                else
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Symbols.qr_code_scanner,
                      size: 88,
                      color: theme.colorScheme.primary,
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

class _MeetNameCard extends HookWidget {
  final _MeetPerson participant;
  final bool canRequestFriend;
  final String? currentUserId;
  final ValueChanged<SnAccount> onRequestFriend;

  const _MeetNameCard({
    required this.participant,
    required this.canRequestFriend,
    required this.currentUserId,
    required this.onRequestFriend,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 460),
    );

    useEffect(() {
      controller.forward();
      return null;
    }, const []);

    final account = participant.account;
    if (account == null) {
      return _MeetSimpleNameCard(participant: participant);
    }

    final allowFriendRequest =
        canRequestFriend && account.id != currentUserId;

    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
            ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AccountNameplate(
                  name: account.name,
                  isOutlined: false,
                  padding: EdgeInsets.zero,
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.32),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      participant.subtitle,
                      style: const TextStyle(color: Colors.white),
                    ).fontSize(12),
                  ),
                ),
              ],
            ),
            if (allowFriendRequest)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 6),
                  child: FilledButton.tonalIcon(
                    onPressed: () => onRequestFriend(account),
                    icon: const Icon(Symbols.person_add),
                    label: Text('meetAddFriend').tr(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeetSimpleNameCard extends StatelessWidget {
  final _MeetPerson participant;

  const _MeetSimpleNameCard({required this.participant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.primaryContainer.withOpacity(0.35),
            ],
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Symbols.person,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(participant.fallbackName).fontSize(18).bold(),
                  const Gap(4),
                  Text(
                    participant.subtitle,
                    style: TextStyle(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            Icon(Symbols.id_card, color: theme.colorScheme.primary),
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
                  ? 'meetScanStartTitle'.tr()
                  : 'meetStartTitle'.tr(),
            ).fontSize(18).bold(),
            const Gap(8),
            Text(
              entryMode == MeetEntryMode.tap
                  ? 'meetScanStartDescription'.tr()
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
                  icon: const Icon(Symbols.qr_code_2),
                  label: Text('meetScan').tr(),
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
                      ? Symbols.qr_code_2
                      : Symbols.add_circle,
                ),
                label: Text(
                  entryMode == MeetEntryMode.tap
                      ? 'meetScanPrepare'.tr()
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
                    ? 'meetScanStartHint'.tr()
                    : 'meetScanUnsupported'.tr(),
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
  final VoidCallback onScan;

  const _MeetTapCard({
    required this.busy,
    required this.supported,
    required this.onTapJoin,
    required this.onScan,
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
                      Symbols.qr_code_scanner,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('meetScanTitle').tr().fontSize(18).bold(),
                        const Gap(4),
                        Text('meetScanDescription').tr(),
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
                    Text(
                      'meetScanClipboardPrompt',
                      textAlign: TextAlign.center,
                    ).tr().fontSize(16).bold(),
                    const Gap(6),
                    Text(
                      supported
                          ? 'meetScanJoinHint'.tr()
                          : 'meetScanUnsupported'.tr(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: busy || !supported ? null : onScan,
                  icon: Icon(
                    busy ? Symbols.progress_activity : Symbols.qr_code_scanner,
                  ),
                  label: Text(
                    busy ? 'meetScanOpening'.tr() : 'meetScanOpenCamera'.tr(),
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: busy || !supported ? null : onTapJoin,
                  icon: Icon(
                    busy ? Symbols.progress_activity : Symbols.content_paste_go,
                  ),
                  label: Text(
                    busy
                        ? 'meetScanOpening'.tr()
                        : 'meetScanOpenClipboard'.tr(),
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
    return history.when(
      data: (items) {
        if (items.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('meetHistory').tr().fontSize(18).bold(),
                  const Gap(8),
                  Text('meetHistoryEmpty').tr(),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('meetHistory').tr().fontSize(18).bold(),
            const Gap(12),
            ...items.map(
              (meet) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MeetHistoryCard(meet: meet, onTap: () => onOpen(meet)),
              ),
            ),
          ],
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('meetHistory').tr().fontSize(18).bold(),
              const Gap(12),
              const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
      error: (error, _) => ResponseErrorWidget(error: error, onRetry: onRetry),
    );
  }
}

class _MeetHistoryCard extends StatelessWidget {
  final SnMeet meet;
  final VoidCallback onTap;

  const _MeetHistoryCard({required this.meet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participants = _displayParticipants(meet, null);
    final entryMode = _entryModeOf(meet);
    final topic = meet.metadata['topic']?.toString();
    final title = meet.locationName?.isNotEmpty == true
        ? meet.locationName!
        : (topic?.isNotEmpty == true ? topic! : _statusLabel(meet.status, context));
    final locationPoint = _parseMeetPoint(meet.locationWkt);
    final hasImage = meet.image != null;
    final hasLocation = locationPoint != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Show image if available, otherwise show map if location available
            if (hasImage)
              // Full-size image (16:9 aspect ratio)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CloudImageWidget(file: meet.image, fit: BoxFit.cover),
                    // Gradient overlay for text readability
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status pills
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _HeroPill(label: _statusLabel(meet.status, context)),
                          _HeroPill(label: _entryModeLabel(entryMode, context)),
                        ],
                      ),
                    ),
                    // Title overlay
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (hasLocation)
              // Show map card when no image but location available
              SizedBox(
                height: 180,
                child: Stack(
                  children: [
                    _MeetLocationMapCard(
                      point: locationPoint,
                      locationName: meet.locationName,
                      locationAddress: meet.locationAddress,
                    ),
                    // Status pills overlay
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _HeroPill(label: _statusLabel(meet.status, context)),
                          _HeroPill(label: _entryModeLabel(entryMode, context)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              // No image and no location - show simple header
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Symbols.groups,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    // Status pills
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _HeroPill(label: _statusLabel(meet.status, context)),
                          _HeroPill(label: _entryModeLabel(entryMode, context)),
                        ],
                      ),
                    ),
                    // Title overlay
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes or description
                  if (meet.notes?.isNotEmpty == true) ...[
                    Text(
                      meet.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const Gap(10),
                  ],
                  // Meta info row
                  Row(
                    children: [
                      Icon(
                        Symbols.schedule,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const Gap(4),
                      Text(
                        meet.expiresAt != null
                            ? DateFormat.yMd().add_Hm().format(meet.expiresAt!)
                            : _visibilityLabel(meet.visibility, context),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const Gap(12),
                      Icon(
                        Symbols.group,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const Gap(4),
                      Text(
                        '${participants.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Symbols.chevron_right,
                        size: 18,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  // Participants avatars
                  if (participants.isNotEmpty) ...[
                    const Gap(12),
                    SizedBox(
                      height: 36,
                      child: Row(
                        children: [
                          // Stacked avatars
                          ...participants.take(5).toList().asMap().entries.map(
                            (entry) {
                              final index = entry.key;
                              final participant = entry.value;
                              return Transform.translate(
                                offset: Offset(-index * 10.0, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.colorScheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: participant.account != null
                                      ? ProfilePictureWidget(
                                          file: participant
                                              .account!.profile.picture,
                                          radius: 16,
                                        )
                                      : CircleAvatar(
                                          radius: 16,
                                          backgroundColor: theme
                                              .colorScheme.primaryContainer,
                                          child: Icon(
                                            Symbols.person,
                                            size: 14,
                                            color: theme
                                                .colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          // Show remaining count if more than 5
                          if (participants.length > 5)
                            Transform.translate(
                              offset: Offset(-5 * 10.0, 0),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.secondaryContainer,
                                  border: Border.all(
                                    color: theme.colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${participants.length - 5}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          const Spacer(),
                          // Participant names hint
                          Flexible(
                            child: Text(
                              participants
                                  .take(2)
                                  .map(
                                    (p) =>
                                        p.account?.nick.isNotEmpty == true
                                            ? p.account!.nick
                                            : '@${p.account?.name ?? p.fallbackName}',
                                  )
                                  .join(', ') +
                                  (participants.length > 2
                                      ? ' +${participants.length - 2}'
                                      : ''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

class _MeetScanCodeCard extends StatelessWidget {
  final Uri uri;

  const _MeetScanCodeCard({required this.uri});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = uri.toString();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            QrImageView(
              data: data,
              size: 148,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: theme.colorScheme.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: theme.colorScheme.onSurface,
              ),
            ).clipRRect(all: 8),
          ],
        ),
      ),
    );
  }
}

class _MeetQrScannerSheet extends HookWidget {
  final MeetTapService service;

  const _MeetQrScannerSheet({required this.service});

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => MobileScannerController(
        formats: const [BarcodeFormat.qrCode],
        detectionSpeed: DetectionSpeed.noDuplicates,
      ),
    );
    final didHandle = useState(false);

    useEffect(() {
      return controller.dispose;
    }, [controller]);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: Stack(
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    if (didHandle.value) return;
                    final raw = capture.barcodes
                        .map((e) => e.rawValue?.trim())
                        .whereType<String>()
                        .firstWhere(
                          (value) => value.isNotEmpty,
                          orElse: () => '',
                        );
                    if (raw.isEmpty) return;

                    final payload = service.parsePayload(raw);
                    if (payload == null) return;
                    didHandle.value = true;
                    Navigator.of(context).pop(payload);
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.52),
                          Colors.transparent,
                          Colors.black.withOpacity(0.52),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Symbols.close),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: controller.toggleTorch,
                          icon: const Icon(Symbols.flashlight_on),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 236,
                  height: 236,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.92),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('meetScanCameraPrompt').tr().fontSize(16).bold(),
                        const Gap(6),
                        Text(
                          'meetScanCameraHint'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
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

Set<String> _participantIdsOf(SnMeet meet) {
  final ids = <String>{meet.hostId};
  for (final participant in meet.participants) {
    ids.add(participant.accountId);
  }
  return ids;
}

_MeetPerson? _findLatestArrival({
  required SnMeet meet,
  required Set<String> previousIds,
  required String? currentUserId,
}) {
  final people = _displayParticipants(meet, null);
  for (final person in people.reversed) {
    if (person.id == currentUserId) continue;
    if (previousIds.contains(person.id)) continue;
    return person;
  }
  return null;
}

class _MeetScanArrivalBanner extends HookWidget {
  final _MeetPerson participant;

  const _MeetScanArrivalBanner({required this.participant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 700),
    );
    final account = participant.account;

    useEffect(() {
      controller.forward();
      return null;
    }, const []);

    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.92),
                    theme.colorScheme.tertiaryContainer.withOpacity(0.82),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Symbols.waving_hand,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('meetScanJoinedTitle').tr().fontSize(18).bold(),
                            const Gap(4),
                            Text(
                              'meetScanJoinedHint'.tr(),
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  if (account != null)
                    AccountNameplate(
                      name: account.name,
                      isOutlined: false,
                      padding: EdgeInsets.zero,
                    )
                  else
                    _MeetSimpleNameCard(participant: participant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    MeetEntryMode.tap => 'meetScan'.tr(),
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
