import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/meet_bluetooth.dart';
import 'package:island/accounts/meet_service.dart';
import 'package:island/accounts/nearby_service.dart';
import 'package:island/accounts/pin_service.dart';
import 'package:island/core/widgets/content/cloud_file_picker.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

final _meetLogger = Logger('Meet');

final meetHistoryProvider = FutureProvider.autoDispose<List<SnMeet>>((
  ref,
) async {
  return ref.watch(meetServiceProvider).listMeets(take: 20);
});

final nearbyMeetsProvider = FutureProvider.autoDispose
    .family<List<SnMeet>, String>((ref, locationWkt) async {
      if (locationWkt.isEmpty) {
        return const [];
      }
      return ref
          .watch(meetServiceProvider)
          .listNearbyMeets(
            locationWkt: locationWkt,
            distanceMeters: 5000,
            take: 50,
          );
    });

enum MeetEntryMode { nearby }

@RoutePage()
class MeetScreen extends HookConsumerWidget {
  const MeetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeData = RouteData.of(context);
    final initialMeetId = routeData.queryParams.optString('meet_id') ?? '';
    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);
    final nearbyService = ref.watch(nearbyServiceProvider);
    final meetHistory = ref.watch(meetHistoryProvider);

    final joinController = useTextEditingController(text: initialMeetId);
    final topicController = useTextEditingController();
    final notesController = useTextEditingController();
    final tabController = useTabController(
      initialLength: 3,
      initialIndex: initialMeetId.isNotEmpty ? 0 : 0,
    );
    final historySubTabController = useTabController(initialLength: 2);
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
    final nearbyDiscoverable = useState(true);
    final nearbyFriendOnly = useState(true);
    final nearbyBusy = useState(false);
    final nearbyScanning = useState(false);
    final nearbyPeers = useState<List<NearbyPeer>>([]);
    final nearbyBundle = useState<NearbyPresenceBundle?>(null);
    final nearbyBroadcastToken = useState<String?>(null);
    final nearbyError = useState<Object?>(null);
    final nearbyObservationCount = useState(0);
    final nearbyScanResultSub =
        useRef<StreamSubscription<List<BluetoothHexDiscovery>>?>(null);
    final nearbyScanStateSub = useRef<StreamSubscription<bool>?>(null);
    final nearbyRefreshTimer = useRef<Timer?>(null);
    final nearbyResolveBusy = useRef(false);
    final nearbyDiscoveries = useState<List<BluetoothHexDiscovery>>([]);
    final nearbyIsResolving = useState(false);

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

    Future<void> stopNearbySession({bool stopScan = true}) async {
      nearbyScanning.value = false;
      nearbyBroadcastToken.value = null;
      nearbyRefreshTimer.value?.cancel();
      nearbyRefreshTimer.value = null;
      await nearbyScanResultSub.value?.cancel();
      nearbyScanResultSub.value = null;
      await nearbyScanStateSub.value?.cancel();
      nearbyScanStateSub.value = null;
      if (stopScan) {
        await bluetoothService.stopNearbyDiscovery();
      }
      await bluetoothService.stopAdvertising();
    }

    Future<void> syncNearbyAdvertising() async {
      final bundle = nearbyBundle.value;
      if (bundle == null) return;
      if (!nearbyDiscoverable.value) {
        nearbyBroadcastToken.value = null;
        await bluetoothService.stopAdvertising();
        return;
      }
      if (!bluetoothService.supportsAdvertising) return;

      final activeToken = bundle.tokenForNow();
      if (activeToken == null) return;
      if (nearbyBroadcastToken.value == activeToken.token) return;

      await bluetoothService.startAdvertisingHex(
        serviceUuid: bundle.serviceUuid,
        payloadHex: activeToken.token,
      );
      nearbyBroadcastToken.value = activeToken.token;
    }

    Future<void> resolveNearbyPeers() async {
      if (nearbyResolveBusy.value) return;
      nearbyResolveBusy.value = true;
      nearbyIsResolving.value = true;
      try {
        final discoveries = nearbyDiscoveries.value;
        if (discoveries.isEmpty) return;

        final now = DateTime.now().toUtc();
        final observations = discoveries
            .map(
              (d) => NearbyObservation(
                token: d.payloadHex,
                slot: nearbyService.currentSlot(
                  nearbyBundle.value?.slotDurationSec ?? 30,
                ),
                avgRssi: d.rssi,
                seenCount: 1,
                durationMs: 0,
                firstSeenAt: now,
                lastSeenAt: now,
              ),
            )
            .toList();

        final peers = await nearbyService.resolveObservations(observations);
        final uniquePeers = <String, NearbyPeer>{
          for (final peer in peers) peer.userId: peer,
        }.values.toList();
        nearbyPeers.value = uniquePeers;
      } catch (error) {
        nearbyError.value = error;
      } finally {
        nearbyResolveBusy.value = false;
        nearbyIsResolving.value = false;
      }
    }

    Future<void> startNearbyPresence() async {
      nearbyBusy.value = true;
      nearbyError.value = null;
      nearbyDiscoveries.value = [];
      try {
        final effectiveDiscoverable =
            bluetoothService.supportsAdvertising && nearbyDiscoverable.value;
        final deviceId = await nearbyService.getOrCreateDeviceId();
        final bundle = await nearbyService.issuePresenceTokens(
          deviceId: deviceId,
          discoverable: effectiveDiscoverable,
          friendOnly: nearbyFriendOnly.value,
        );
        Logger.root.info(
          '[Nearby] presence bundle deviceId=$deviceId serviceUuid=${bundle.serviceUuid} slotDurationSec=${bundle.slotDurationSec} tokenCount=${bundle.tokens.length} currentToken=${bundle.tokenForNow()?.token ?? "none"} discoverable=$effectiveDiscoverable friendOnly=${nearbyFriendOnly.value}',
        );
        nearbyBundle.value = bundle;
        nearbyObservationCount.value = 0;

        await nearbyScanResultSub.value?.cancel();
        nearbyScanResultSub.value = bluetoothService.nearbyDiscoveriesStream
            .listen(
              (discoveries) {
                nearbyDiscoveries.value = discoveries;
                if (discoveries.isEmpty) return;
                nearbyObservationCount.value = discoveries.length;
                if (tabController.index == 2) {
                  unawaited(resolveNearbyPeers());
                }
              },
              onError: (error, _) {
                nearbyScanning.value = false;
                nearbyError.value = error;
              },
            );
        nearbyScanStateSub.value ??= bluetoothService.nearbyDiscoveryStateStream
            .listen((value) {
              nearbyScanning.value = value;
            });

        await syncNearbyAdvertising();
        nearbyRefreshTimer.value?.cancel();
        nearbyRefreshTimer.value = Timer.periodic(const Duration(seconds: 5), (
          _,
        ) {
          if (nearbyBusy.value || tabController.index != 2) return;
          final activeToken = nearbyBundle.value?.tokenForNow();
          if (activeToken == null) {
            unawaited(startNearbyPresence());
          } else if (bluetoothService.supportsAdvertising) {
            unawaited(syncNearbyAdvertising());
          }
        });
        await bluetoothService.startNearbyDiscoveryForService(
          bundle.serviceUuid,
          expectedLength: kNearbyTokenHexLength ~/ 2,
        );
      } catch (error) {
        nearbyError.value = error;
        showErrorAlert(error);
      } finally {
        nearbyBusy.value = false;
      }
    }

    useEffect(() {
      void handleTabChange() {
        if (tabController.indexIsChanging) return;

        if (tabController.index == 1) {
          unawaited(startNearbyPresence());
          return;
        }

        unawaited(stopNearbySession());
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
        unawaited(stopNearbySession());
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
                  'meet'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'nearby'.tr(),
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
            _MeetTab(
              topicController: topicController,
              notesController: notesController,
              joinController: joinController,
              busy: actionBusy.value,
              entryMode: entryMode.value,
              locationDraft: locationDraft.value,
              isLocating: isLocating.value,
              visibility: visibility.value,
              image: selectedImage.value,
              discoveries: discoveries.value,
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
                    usage: 'meet',
                  ),
                );
                if (result != null) {
                  selectedImage.value = result;
                }
              },
              onRemoveImage: () => selectedImage.value = null,
              onStart: startMeet,
              onJoin: () => joinMeetById(joinController.text),
              onPaste: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                final text = data?.text?.trim();
                if (text?.isNotEmpty ?? false) {
                  joinController.text = text!;
                }
              },
              onScanQr: () =>
                  showQrScannerSheet(context, (meetId) => joinMeetById(meetId)),
              onJoinFromDiscovery: (meetId) => joinMeetById(meetId),
            ),
            _NearbyTab(
              nearbyBusy: nearbyBusy.value,
              nearbyScanning: nearbyScanning.value,
              nearbyDiscoverable: nearbyDiscoverable.value,
              nearbyFriendOnly: nearbyFriendOnly.value,
              advertiseSupported: bluetoothService.supportsAdvertising,
              nearbyObservationCount: nearbyObservationCount.value,
              nearbyIsResolving: nearbyIsResolving.value,
              nearbyDiscoveries: nearbyDiscoveries.value,
              nearbyPeers: nearbyPeers.value,
              nearbyError: nearbyError.value,
              onRefresh: startNearbyPresence,
              onToggleDiscoverable: (value) async {
                nearbyDiscoverable.value = value;
                await startNearbyPresence();
              },
              onToggleFriendOnly: (value) async {
                nearbyFriendOnly.value = value;
                await startNearbyPresence();
              },
            ),
            _HistoryTab(
              subTabController: historySubTabController,
              history: meetHistory,
              onOpen: (meet) => openMeetDetail(meet.id),
              onRetry: () => ref.invalidate(meetHistoryProvider),
              onOpenMeet: (meetId) => openMeetDetail(meetId),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetTab extends StatelessWidget {
  final TextEditingController topicController;
  final TextEditingController notesController;
  final TextEditingController joinController;
  final bool busy;
  final SnCloudFile? image;
  final MeetEntryMode entryMode;
  final _MeetLocationDraft? locationDraft;
  final bool isLocating;
  final SnMeetVisibility visibility;
  final List<MeetBluetoothDiscovery> discoveries;
  final ValueChanged<MeetEntryMode> onChangeEntryMode;
  final ValueChanged<SnMeetVisibility> onChangeVisibility;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onClearLocation;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onStart;
  final VoidCallback onJoin;
  final VoidCallback onPaste;
  final VoidCallback onScanQr;
  final ValueChanged<String> onJoinFromDiscovery;

  const _MeetTab({
    required this.topicController,
    required this.notesController,
    required this.joinController,
    required this.busy,
    required this.image,
    required this.entryMode,
    required this.locationDraft,
    required this.isLocating,
    required this.visibility,
    required this.discoveries,
    required this.onChangeEntryMode,
    required this.onChangeVisibility,
    required this.onUseCurrentLocation,
    required this.onClearLocation,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onStart,
    required this.onJoin,
    required this.onPaste,
    required this.onScanQr,
    required this.onJoinFromDiscovery,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MeetStartCard(
          topicController: topicController,
          notesController: notesController,
          busy: busy,
          advertising: false,
          entryMode: entryMode,
          locationDraft: locationDraft,
          isLocating: isLocating,
          visibility: visibility,
          image: image,
          onChangeEntryMode: onChangeEntryMode,
          onChangeVisibility: onChangeVisibility,
          onUseCurrentLocation: onUseCurrentLocation,
          onClearLocation: onClearLocation,
          onPickImage: onPickImage,
          onRemoveImage: onRemoveImage,
          onStart: onStart,
        ),
        const Gap(16),
        _MeetJoinCard(
          joinController: joinController,
          busy: busy,
          onJoin: onJoin,
          onPaste: onPaste,
          onScanQr: onScanQr,
        ),
        const Gap(16),
        if (discoveries.isNotEmpty)
          _MeetNearbyCard(discoveries: discoveries, onJoin: onJoinFromDiscovery)
        else
          _MeetInfoCard(
            icon: Symbols.groups,
            title: 'meetJoinReadyTitle'.tr(),
            description: 'meetJoinReadyDescription'.tr(),
          ),
      ],
    );
  }
}

class _NearbyTab extends StatelessWidget {
  final bool nearbyBusy;
  final bool nearbyScanning;
  final bool nearbyDiscoverable;
  final bool nearbyFriendOnly;
  final bool advertiseSupported;
  final int nearbyObservationCount;
  final bool nearbyIsResolving;
  final List<BluetoothHexDiscovery> nearbyDiscoveries;
  final List<NearbyPeer> nearbyPeers;
  final Object? nearbyError;
  final VoidCallback onRefresh;
  final ValueChanged<bool> onToggleDiscoverable;
  final ValueChanged<bool> onToggleFriendOnly;

  const _NearbyTab({
    required this.nearbyBusy,
    required this.nearbyScanning,
    required this.nearbyDiscoverable,
    required this.nearbyFriendOnly,
    required this.advertiseSupported,
    required this.nearbyObservationCount,
    required this.nearbyIsResolving,
    required this.nearbyDiscoveries,
    required this.nearbyPeers,
    required this.nearbyError,
    required this.onRefresh,
    required this.onToggleDiscoverable,
    required this.onToggleFriendOnly,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _NearbyPresenceCard(
          busy: nearbyBusy,
          scanning: nearbyScanning,
          discoverable: nearbyDiscoverable,
          friendOnly: nearbyFriendOnly,
          advertiseSupported: advertiseSupported,
          observationCount: nearbyObservationCount,
          isResolving: nearbyIsResolving,
          onRefresh: onRefresh,
          discoveries: nearbyDiscoveries,
          peers: nearbyPeers,
          onToggleDiscoverable: onToggleDiscoverable,
          onToggleFriendOnly: onToggleFriendOnly,
        ),
        const Gap(16),
        _NearbyPeersCard(
          peers: nearbyPeers,
          error: nearbyError,
          onRetry: onRefresh,
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final TabController subTabController;
  final AsyncValue<List<SnMeet>> history;
  final ValueChanged<SnMeet> onOpen;
  final VoidCallback onRetry;
  final ValueChanged<String> onOpenMeet;

  const _HistoryTab({
    required this.subTabController,
    required this.history,
    required this.onOpen,
    required this.onRetry,
    required this.onOpenMeet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: subTabController,
          tabs: [
            Tab(text: 'meetHistory'.tr()),
            Tab(text: 'meetDiscovery'.tr()),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: subTabController,
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MeetHistorySection(
                    history: history,
                    onOpen: onOpen,
                    onRetry: onRetry,
                  ),
                ],
              ),
              _MeetDiscoverySection(onOpenMeet: onOpenMeet),
            ],
          ),
        ),
      ],
    );
  }
}

@RoutePage()
class MeetDetailScreen extends HookConsumerWidget {
  final String id;

  const MeetDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(userInfoProvider).value;
    final meetService = ref.watch(meetServiceProvider);
    final bluetoothService = ref.watch(meetBluetoothServiceProvider);
    final pinService = ref.watch(pinServiceProvider);

    final meet = useState<SnMeet?>(null);
    final error = useState<Object?>(null);
    final eventType = useState<String?>(null);
    final isWatching = useState(false);
    final isAdvertising = useState(false);
    final actionBusy = useState(false);
    final watchSub = useRef<StreamSubscription<SnMeetEvent>?>(null);
    final currentLocation = useState<latlong.LatLng?>(null);
    final isLocating = useState(false);
    final myPin = useState<SnLocationPin?>(null);
    final isBroadcastingPin = useState(false);
    final pinStreamSub = useRef<StreamSubscription<SnLocationPinEvent>?>(null);
    final pinUpdateTimer = useRef<Timer?>(null);

    Future<void> getCurrentLocation() async {
      isLocating.value = true;
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return;
        }

        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        currentLocation.value = latlong.LatLng(
          position.latitude,
          position.longitude,
        );
      } catch (_) {
      } finally {
        isLocating.value = false;
      }
    }

    Future<void> stopAdvertising() async {
      if (!isAdvertising.value) return;
      await bluetoothService.stopAdvertising();
      isAdvertising.value = false;
    }

    Future<void> stopBroadcastingPin() async {
      if (!isBroadcastingPin.value) return;

      pinUpdateTimer.value?.cancel();
      pinUpdateTimer.value = null;
      await pinStreamSub.value?.cancel();
      pinStreamSub.value = null;

      final pin = myPin.value;
      if (pin != null) {
        try {
          await pinService.disconnectPin(pin.id);
        } catch (_) {}
      }
      myPin.value = null;
      isBroadcastingPin.value = false;
    }

    Future<void> startBroadcastingPin(String meetId) async {
      if (currentLocation.value == null) return;

      final locationWkt =
          'POINT(${currentLocation.value!.longitude.toStringAsFixed(6)} ${currentLocation.value!.latitude.toStringAsFixed(6)})';

      try {
        final pin = await pinService.createPin(
          meetId: meetId,
          visibility: LocationPinVisibility.public,
          locationWkt: locationWkt,
        );
        myPin.value = pin;
        isBroadcastingPin.value = true;

        pinStreamSub.value?.cancel();
        pinStreamSub.value = pinService
            .streamPin(pin.id)
            .listen(
              (event) {
                if (event.pin != null) {
                  myPin.value = event.pin;
                }
              },
              onError: (_) {
                isBroadcastingPin.value = false;
              },
            );

        pinUpdateTimer.value?.cancel();
        pinUpdateTimer.value = Timer.periodic(const Duration(seconds: 30), (
          _,
        ) async {
          if (!isBroadcastingPin.value || currentLocation.value == null) return;
          try {
            final wkt =
                'POINT(${currentLocation.value!.longitude.toStringAsFixed(6)} ${currentLocation.value!.latitude.toStringAsFixed(6)})';
            await pinService.updatePinLocation(
              pinId: myPin.value!.id,
              locationWkt: wkt,
            );
            _meetLogger.info('Pin location updated: $wkt');
          } catch (_) {}
        });
      } catch (e) {
        isBroadcastingPin.value = false;
      }
    }

    Future<void> stopWatching() async {
      await watchSub.value?.cancel();
      watchSub.value = null;
      isWatching.value = false;
      await stopBroadcastingPin();
    }

    Future<void> loadMeet() async {
      error.value = null;
      try {
        await getCurrentLocation();
        final locationWkt = currentLocation.value != null
            ? 'POINT(${currentLocation.value!.longitude.toStringAsFixed(6)} ${currentLocation.value!.latitude.toStringAsFixed(6)})'
            : null;
        final item = await meetService.getMeet(id, locationWkt: locationWkt);
        meet.value = item;
      } catch (err) {
        error.value = err;
      }
    }

    Future<void> watchMeet() async {
      final current = meet.value;
      if (current == null || current.status != SnMeetStatus.active) return;

      await stopWatching();
      await getCurrentLocation();

      final locationWkt = currentLocation.value != null
          ? 'POINT(${currentLocation.value!.longitude.toStringAsFixed(6)} ${currentLocation.value!.latitude.toStringAsFixed(6)})'
          : null;

      isWatching.value = true;
      watchSub.value = meetService
          .joinMeet(id, locationWkt: locationWkt)
          .listen(
            (event) {
              meet.value = event.meet;
              eventType.value = event.type;
              if (event.meet.isFinal) {
                isWatching.value = false;
                unawaited(stopAdvertising());
                unawaited(stopBroadcastingPin());
                ref.invalidate(meetHistoryProvider);
              }
            },
            onError: (err, _) {
              error.value = err;
              isWatching.value = false;
              unawaited(stopBroadcastingPin());
            },
          );

      await startBroadcastingPin(id);
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

    Future<void> deleteMeet() async {
      final current = meet.value;
      if (current == null) return;
      actionBusy.value = true;
      try {
        await meetService.deleteMeet(current.id);
        ref.invalidate(meetHistoryProvider);
        if (context.mounted) {
          await context.router.maybePop();
        }
      } catch (err) {
        showErrorAlert(err);
      } finally {
        actionBusy.value = false;
      }
    }

    Future<void> updateMeetVisibility(SnMeetVisibility visibility) async {
      final current = meet.value;
      if (current == null) return;
      actionBusy.value = true;
      try {
        final updated = await meetService.updateMeetVisibility(
          meetId: current.id,
          visibility: visibility,
        );
        meet.value = updated;
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
        isBroadcastingPin: isBroadcastingPin.value,
        myPin: myPin.value,
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
                  isScanShareReady: false,
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
                  if (current.status == SnMeetStatus.active) ...[
                    Text('meetVisibility').tr().fontSize(16).bold(),
                    const Gap(8),
                    SegmentedButton<SnMeetVisibility>(
                      segments: [
                        ButtonSegment(
                          value: SnMeetVisibility.public,
                          icon: const Icon(Symbols.public),
                          label: Text('meetVisibilityPublic'.tr()),
                        ),
                        ButtonSegment(
                          value: SnMeetVisibility.private,
                          icon: const Icon(Symbols.lock),
                          label: Text('meetVisibilityPrivate'.tr()),
                        ),
                        ButtonSegment(
                          value: SnMeetVisibility.unlisted,
                          icon: const Icon(Symbols.link_off),
                          label: Text('meetVisibilityUnlisted'.tr()),
                        ),
                      ],
                      selected: {current.visibility},
                      onSelectionChanged: actionBusy.value
                          ? null
                          : (value) => updateMeetVisibility(value.first),
                    ),
                    const Gap(16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: context.router.maybePop,
                          child: Text('close').tr(),
                        ),
                      ),
                      if (current.status == SnMeetStatus.active) ...[
                        const Gap(12),
                        Expanded(
                          child: FilledButton(
                            onPressed: actionBusy.value ? null : completeMeet,
                            child: Text('meetComplete').tr(),
                          ),
                        ),
                      ],
                      const Gap(12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: actionBusy.value
                              ? null
                              : () =>
                                    showConfirmAlert(
                                      'meetDeleteConfirm'.tr(),
                                      'meetDelete'.tr(),
                                    ).then((confirm) {
                                      if (confirm) deleteMeet();
                                    }),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                          ),
                          child: Text('delete'.tr()),
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

class _MeetActiveListeningPage extends HookConsumerWidget {
  final SnMeet meet;
  final MeetEntryMode entryMode;
  final List<_MeetPerson> participants;
  final bool isWatching;
  final bool isAdvertising;
  final bool isHost;
  final bool actionBusy;
  final bool isBroadcastingPin;
  final SnLocationPin? myPin;
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
    required this.isBroadcastingPin,
    required this.myPin,
    required this.onClose,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    final theme = Theme.of(context);
    final topic = meet.metadata['topic']?.toString();
    final currentUser = ref.watch(userInfoProvider).value;

    final meetPins = meet.pins ?? const [];
    final localPins = myPin != null ? [...meetPins, myPin!] : meetPins;
    final pins = localPins;
    final currentParticipants = _displayParticipants(meet, currentUser);
    final hasPins = pins.isNotEmpty || isBroadcastingPin;
    final canShowMap = hasPins;
    final showMap = useState(hasPins);

    useEffect(() {
      if (hasPins && !showMap.value) {
        showMap.value = true;
      }
      return null;
    }, [hasPins]);

    return AppScaffold(
      isNoBackground: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: theme.colorScheme.surface,
        child: SafeArea(
          bottom: false,
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
                    const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            meet.locationName?.isNotEmpty == true
                                ? meet.locationName!
                                : 'meetLiveTitle'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      onPressed: () => showMeetIdShareSheet(
                        context,
                        meet.id,
                        meetName: meet.locationName,
                      ),
                      icon: const Icon(Symbols.qr_code),
                    ),
                    if (canShowMap)
                      IconButton(
                        onPressed: () => showMap.value = !showMap.value,
                        icon: Icon(
                          showMap.value ? Symbols.map : Symbols.signpost,
                        ),
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
                      _InfoPill(
                        icon: Symbols.bluetooth_searching,
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: showMap.value && hasPins
                        ? _MeetPinsMapCard(
                            pins: pins,
                            participants: currentParticipants,
                            currentUser: currentUser,
                          ).clipRRect(all: 8)
                        : Stack(
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
                                  children: currentParticipants
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
                ),
                Text(
                  'meetParticipantsCount'.tr(
                    args: ['${currentParticipants.length}'],
                  ),
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
                          child: Text('meetComplete'.tr()),
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
                  Flexible(
                    child: Text(
                      meet.locationName?.isNotEmpty == true
                          ? meet.locationName!
                          : 'meetLiveTitle'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
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
    final participantCount = participants.length;
    final hasPins = meet.pins != null && meet.pins!.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_parseMeetPoint(meet.locationWkt) case final point?) ...[
              if (hasPins) ...[
                _MeetPinsMapCard(pins: meet.pins!, participants: participants),
              ] else ...[
                _MeetLocationMapCard(
                  point: point,
                  locationName: meet.locationName,
                  locationAddress: meet.locationAddress,
                ),
              ],
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
              'meetParticipantsCount'.tr(args: ['$participantCount']),
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
            Text('meetStartTitle').tr().fontSize(18).bold(),
            const Gap(8),
            Text('meetStartDescription').tr(),
            const Gap(16),
            SegmentedButton<SnMeetVisibility>(
              segments: [
                ButtonSegment(
                  value: SnMeetVisibility.private,
                  icon: const Icon(Symbols.lock),
                  label: Text('meetVisibilityPrivate'.tr()),
                ),
                ButtonSegment(
                  value: SnMeetVisibility.public,
                  icon: const Icon(Symbols.public),
                  label: Text('meetVisibilityPublic'.tr()),
                ),
                ButtonSegment(
                  value: SnMeetVisibility.unlisted,
                  icon: const Icon(Symbols.link_off),
                  label: Text('meetVisibilityUnlisted'.tr()),
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
                alignLabelWithHint: true,
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
      ),
    );
  }
}

class _MeetJoinCard extends StatelessWidget {
  final TextEditingController joinController;
  final bool busy;
  final VoidCallback onJoin;
  final VoidCallback onPaste;
  final VoidCallback onScanQr;

  const _MeetJoinCard({
    required this.joinController,
    required this.busy,
    required this.onJoin,
    required this.onPaste,
    required this.onScanQr,
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
            Text('meetJoinDescription'.tr()),
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
                    label: Text('meetJoinNow'.tr()),
                  ),
                ),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onScanQr,
                    icon: const Icon(Symbols.qr_code_scanner),
                    label: Text('meetQrScan'.tr()),
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

class _NearbyPresenceCard extends HookWidget {
  final bool busy;
  final bool scanning;
  final bool discoverable;
  final bool friendOnly;
  final bool advertiseSupported;
  final int observationCount;
  final bool isResolving;
  final VoidCallback onRefresh;
  final ValueChanged<bool> onToggleDiscoverable;
  final ValueChanged<bool> onToggleFriendOnly;
  final List<BluetoothHexDiscovery> discoveries;
  final List<NearbyPeer> peers;

  const _NearbyPresenceCard({
    required this.busy,
    required this.scanning,
    required this.discoverable,
    required this.friendOnly,
    required this.advertiseSupported,
    required this.observationCount,
    required this.isResolving,
    required this.onRefresh,
    required this.onToggleDiscoverable,
    required this.onToggleFriendOnly,
    required this.discoveries,
    required this.peers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animation = useAnimationController(
      duration: const Duration(milliseconds: 2600),
    );

    useEffect(() {
      if (scanning) {
        animation.repeat();
      } else {
        animation.stop();
        animation.reset();
      }
      return null;
    }, [scanning]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('nearbyTitle').tr().fontSize(18).bold(),
                      const Gap(4),
                      Text(
                        scanning
                            ? 'nearbyScanningLabel'.tr(
                                args: [discoveries.length.toString()],
                              )
                            : 'nearbyIdle'.tr(),
                        style: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isResolving)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'nearbyResolving'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Gap(16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (scanning)
                    _NearbyRippleField(
                      animation: animation,
                      color: theme.colorScheme.primary,
                    ),
                  if (discoveries.isEmpty)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            scanning
                                ? Symbols.bluetooth_searching
                                : Symbols.radar,
                            size: 40,
                            color: theme.colorScheme.secondary,
                          ),
                          const Gap(8),
                          Text(
                            scanning
                                ? 'nearbySearching'.tr()
                                : 'nearbyWaiting'.tr(),
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (peers.isNotEmpty || discoveries.isNotEmpty)
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: peers.isNotEmpty
                            ? _NearbyPeersRow(
                                key: ValueKey('peers-${peers.length}'),
                                peers: peers,
                              )
                            : _NearbyDevicesRow(
                                key: ValueKey('devices-${discoveries.length}'),
                                discoveries: discoveries,
                              ),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (scanning)
                  _InfoPill(icon: Symbols.radar, label: 'nearbyScanning'.tr()),
                if (!scanning)
                  _InfoPill(
                    icon: Symbols.sync_disabled,
                    label: 'nearbyIdle'.tr(),
                  ),
                _InfoPill(
                  icon: Symbols.network_intelligence,
                  label: observationCount > 0
                      ? 'nearbyObservationsReady'.tr(
                          args: [observationCount.toString()],
                        )
                      : 'nearbyObservationsCollecting'.tr(),
                ),
                if (peers.isNotEmpty)
                  _InfoPill(
                    icon: Symbols.group,
                    label: 'nearbyPeersFound'.tr(),
                  ),
              ],
            ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: advertiseSupported && discoverable,
                    onChanged: busy || !advertiseSupported
                        ? null
                        : onToggleDiscoverable,
                    title: Text('nearbyDiscoverable').tr(),
                    dense: true,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: friendOnly,
                    onChanged: busy ? null : onToggleFriendOnly,
                    title: Text('nearbyFriendOnly').tr(),
                    dense: true,
                  ),
                ),
              ],
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: busy ? null : onRefresh,
                icon: Icon(busy ? Symbols.progress_activity : Symbols.refresh),
                label: Text(busy ? 'loading'.tr() : 'nearbyRefresh'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearbyRippleField extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _NearbyRippleField({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final progress = (animation.value + index / 3) % 1.0;
            final size = 80 + (progress * 120);
            final opacity = (1 - progress).clamp(0.0, 1.0) * 0.2;
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

class _NearbyDeviceBubble extends StatelessWidget {
  final int rssi;
  final String? name;

  const _NearbyDeviceBubble({required this.rssi, this.name});

  IconData get _signalIcon {
    if (rssi >= -50) return Symbols.signal_cellular_4_bar;
    if (rssi >= -65) return Symbols.signal_cellular_3_bar;
    if (rssi >= -80) return Symbols.signal_cellular_2_bar;
    return Symbols.signal_cellular_1_bar;
  }

  Color _signalColor(ThemeData theme) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -65) return Colors.lightGreen;
    if (rssi >= -80) return Colors.orange;
    return theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primaryContainer,
          ),
          child: Icon(_signalIcon, color: _signalColor(theme), size: 24),
        ),
        const Gap(4),
        SizedBox(
          width: 60,
          child: Text(
            '${rssi}dBm',
            style: TextStyle(fontSize: 10, color: theme.colorScheme.secondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _NearbyPeerBubble extends StatelessWidget {
  final NearbyPeer peer;

  const _NearbyPeerBubble({required this.peer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => showAccountProfileCard(context, peer.userId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                ),
                child: peer.avatar != null
                    ? ClipOval(
                        child: ProfilePictureWidget(
                          file: peer.avatar,
                          radius: 30,
                        ),
                      )
                    : Center(
                        child: Text(
                          peer.displayName.isNotEmpty
                              ? peer.displayName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(6),
          SizedBox(
            width: 70,
            child: Text(
              peer.displayName,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NearbyPeersRow extends StatelessWidget {
  final List<NearbyPeer> peers;

  const _NearbyPeersRow({super.key, required this.peers});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: peers
          .take(8)
          .map(
            (p) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + peers.indexOf(p) * 50),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: _NearbyPeerBubble(peer: p),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}

class _NearbyDevicesRow extends StatelessWidget {
  final List<BluetoothHexDiscovery> discoveries;

  const _NearbyDevicesRow({super.key, required this.discoveries});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: discoveries
          .take(8)
          .map(
            (d) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(
                milliseconds: 200 + discoveries.indexOf(d) * 30,
              ),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: _NearbyDeviceBubble(rssi: d.rssi, name: d.name),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}

class _NearbyPeersCard extends StatelessWidget {
  final List<NearbyPeer> peers;
  final Object? error;
  final VoidCallback onRetry;

  const _NearbyPeersCard({
    required this.peers,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('nearbyPeersTitle').tr().fontSize(18).bold(),
            const Gap(8),
            Text(
              'nearbyPeersHint'.tr(),
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
            const Gap(16),
            if (error != null)
              ResponseErrorWidget(error: error, onRetry: onRetry)
            else if (peers.isEmpty)
              _MeetInfoCard(
                icon: Symbols.radar,
                title: 'nearbyPeersEmptyTitle'.tr(),
                description: 'nearbyPeersEmpty'.tr(),
              )
            else
              ...peers.map(
                (peer) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: peer.avatar != null
                      ? ProfilePictureWidget(file: peer.avatar, radius: 22)
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            peer.displayName.isNotEmpty
                                ? peer.displayName.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                  title: Text(peer.displayName),
                  subtitle: Text(
                    [
                      peer.isFriend
                          ? 'relationshipStatusFriend'.tr()
                          : _nearbyVisibilityLabel(peer.visibility, context),
                      if (peer.lastSeenAt != null)
                        'nearbyLastSeen'.tr(
                          args: [
                            DateFormat.Hm().format(peer.lastSeenAt!.toLocal()),
                          ],
                        ),
                    ].join(' · '),
                  ),
                  trailing: peer.canInvite
                      ? Badge(
                          label: Text('nearbyCanInvite').tr(),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          textColor: theme.colorScheme.onSecondaryContainer,
                        )
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeetDiscoverySection extends HookConsumerWidget {
  final ValueChanged<String> onOpenMeet;

  const _MeetDiscoverySection({required this.onOpenMeet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocation = useState<latlong.LatLng?>(null);
    final isLocating = useState(false);
    final selectedMeet = useState<SnMeet?>(null);
    final locationError = useState<Object?>(null);
    final mapController = useRef<MapController?>(null);

    Future<void> getCurrentLocation() async {
      isLocating.value = true;
      locationError.value = null;
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
            'Location permission is required to discover nearby meets.',
          );
        }

        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        currentLocation.value = latlong.LatLng(
          position.latitude,
          position.longitude,
        );
      } catch (error) {
        locationError.value = error;
        showErrorAlert(error);
      } finally {
        isLocating.value = false;
      }
    }

    useEffect(() {
      mapController.value = MapController();
      getCurrentLocation();
      return null;
    }, const []);

    final locationWkt = currentLocation.value != null
        ? 'POINT(${currentLocation.value!.longitude.toStringAsFixed(6)} ${currentLocation.value!.latitude.toStringAsFixed(6)})'
        : '';

    useEffect(() {
      if (locationWkt.isNotEmpty) {
        ref.invalidate(nearbyMeetsProvider(locationWkt));
      }
      return null;
    }, [locationWkt]);

    final nearbyMeets = ref.watch(nearbyMeetsProvider(locationWkt));

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              if (currentLocation.value != null)
                FlutterMap(
                  mapController: mapController.value,
                  options: MapOptions(
                    initialCenter: currentLocation.value!,
                    initialZoom: 14,
                    onTap: (p, l) => selectedMeet.value = null,
                  ),
                  children: [
                    TileLayer(
                      retinaMode: true,
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'Solian/1.0 (+https://solian.app, contact: lily@solsynth.dev)',
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright'),
                          ),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLocation.value!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Symbols.my_location,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                        ...nearbyMeets.maybeWhen(
                          data: (meets) => meets
                              .map((meet) => _parseMeetPoint(meet.locationWkt))
                              .whereType<latlong.LatLng>()
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final point = entry.value;
                                final meet = meets[index];
                                return Marker(
                                  point: point,
                                  width: 48,
                                  height: 48,
                                  child: GestureDetector(
                                    onTap: () => selectedMeet.value = meet,
                                    child: _MeetMapMarker(
                                      meet: meet,
                                      isSelected:
                                          selectedMeet.value?.id == meet.id,
                                    ),
                                  ),
                                );
                              }),
                          orElse: () => <Marker>[],
                        ),
                      ],
                    ),
                  ],
                )
              else if (isLocating.value)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const Gap(16),
                      Text(
                        'meetLocating'.tr(),
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    ],
                  ),
                )
              else if (locationError.value != null)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.location_off,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const Gap(16),
                      Text('meetLocationError'.tr()),
                      const Gap(16),
                      FilledButton.icon(
                        onPressed: getCurrentLocation,
                        icon: const Icon(Symbols.refresh),
                        label: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'discovery_zoom_in',
                      onPressed: () => mapController.value?.move(
                        mapController.value!.camera.center,
                        mapController.value!.camera.zoom + 1,
                      ),
                      child: const Icon(Symbols.add),
                    ),
                    const Gap(8),
                    FloatingActionButton.small(
                      heroTag: 'discovery_zoom_out',
                      onPressed: () => mapController.value?.move(
                        mapController.value!.camera.center,
                        mapController.value!.camera.zoom - 1,
                      ),
                      child: const Icon(Symbols.remove),
                    ),
                    const Gap(8),
                    FloatingActionButton.small(
                      heroTag: 'discovery_locate',
                      onPressed: () {
                        if (currentLocation.value != null) {
                          mapController.value?.move(
                            currentLocation.value!,
                            mapController.value!.camera.zoom,
                          );
                        }
                        getCurrentLocation();
                      },
                      child: Icon(
                        isLocating.value
                            ? Symbols.progress_activity
                            : Symbols.my_location,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: nearbyMeets.when(
                  data: (meets) {
                    if (meets.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Symbols.explore_off,
                              color: theme.colorScheme.secondary,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Text(
                                'meetDiscoveryEmpty'.tr(),
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.location_on,
                            color: theme.colorScheme.primary,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              'meetDiscoveryNearbyCount'.tr(
                                args: [meets.length.toString()],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const Gap(12),
                        Text('loading'.tr()),
                      ],
                    ),
                  ),
                  error: (error, _) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.error,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            'meetDiscoveryError'.tr(),
                            style: TextStyle(
                              color: theme.colorScheme.onErrorContainer,
                            ),
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
        if (selectedMeet.value != null)
          Container(
            margin: const EdgeInsets.all(16),
            child: _MeetDiscoveryCard(
              meet: selectedMeet.value!,
              onTap: () => onOpenMeet(selectedMeet.value!.id),
              onClose: () => selectedMeet.value = null,
            ),
          ),
      ],
    );
  }
}

class _MeetMapMarker extends StatelessWidget {
  final SnMeet meet;
  final bool isSelected;

  const _MeetMapMarker({required this.meet, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = meet.status == SnMeetStatus.active
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isSelected ? 44 : 36,
          height: isSelected ? 44 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 2 : 1,
              ),
            ],
          ),
          child: Icon(
            meet.visibility == SnMeetVisibility.public
                ? Symbols.public
                : Symbols.lock,
            color: Colors.white,
            size: isSelected ? 22 : 18,
          ),
        ),
        Container(width: 2, height: isSelected ? 16 : 12, color: color),
      ],
    );
  }
}

class _MeetDiscoveryCard extends StatelessWidget {
  final SnMeet meet;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _MeetDiscoveryCard({
    required this.meet,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topic = meet.metadata['topic']?.toString();
    final participants = _displayParticipants(meet, null);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (meet.image != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CloudImageWidget(file: meet.image, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        onPressed: onClose,
                        icon: const Icon(Symbols.close, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Wrap(
                        spacing: 6,
                        children: [
                          _HeroPill(
                            label: _visibilityLabel(meet.visibility, context),
                          ),
                          if (meet.status == SnMeetStatus.active)
                            _HeroPill(label: 'meetStatusActive'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 100,
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
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        onPressed: onClose,
                        icon: const Icon(Symbols.close, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Wrap(
                        spacing: 6,
                        children: [
                          _HeroPill(
                            label: _visibilityLabel(meet.visibility, context),
                          ),
                          if (meet.status == SnMeetStatus.active)
                            _HeroPill(label: 'meetStatusActive'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meet.locationName?.isNotEmpty == true
                              ? meet.locationName!
                              : (topic?.isNotEmpty == true
                                    ? topic!
                                    : 'meetDiscoveryTitle'.tr()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Symbols.chevron_right,
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  if (meet.notes?.isNotEmpty == true) ...[
                    const Gap(4),
                    Text(
                      meet.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        Symbols.group,
                        size: 14,
                        color: theme.colorScheme.secondary,
                      ),
                      const Gap(4),
                      Text(
                        'meetParticipantsCount'.tr(
                          args: ['${participants.length}'],
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      if (meet.host != null) ...[
                        ProfilePictureWidget(
                          file: meet.host!.profile.picture,
                          radius: 12,
                        ),
                        const Gap(4),
                        Text(
                          meet.host!.nick.isNotEmpty == true
                              ? meet.host!.nick
                              : '@${meet.host!.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ],
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
        : (topic?.isNotEmpty == true
              ? topic!
              : _statusLabel(meet.status, context));
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
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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
                          ...participants.take(5).toList().asMap().entries.map((
                            entry,
                          ) {
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
                                            .account!
                                            .profile
                                            .picture,
                                        radius: 16,
                                      )
                                    : CircleAvatar(
                                        radius: 16,
                                        backgroundColor:
                                            theme.colorScheme.primaryContainer,
                                        child: Icon(
                                          Symbols.person,
                                          size: 14,
                                          color: theme
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                              ),
                            );
                          }),
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
                  retinaMode: true,
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'Solian/1.0 (+https://solian.app, contact: lily@solsynth.dev)',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright'),
                      ),
                    ),
                  ],
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

class _MeetPinsMapCard extends StatelessWidget {
  final List<SnLocationPin> pins;
  final List<_MeetPerson> participants;
  final SnAccount? currentUser;

  const _MeetPinsMapCard({
    required this.pins,
    required this.participants,
    this.currentUser,
  });

  latlong.LatLng? _parsePoint(String? wkt) {
    if (wkt == null || wkt.isEmpty) return null;
    final match = RegExp(
      r'POINT\s*\(\s*([-\d.]+)\s+([-\d.]+)\s*\)',
    ).firstMatch(wkt.toUpperCase());
    if (match == null) return null;
    return latlong.LatLng(
      double.tryParse(match.group(2)!) ?? 0,
      double.tryParse(match.group(1)!) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final points = pins
        .map((p) => _parsePoint(p.locationWkt))
        .whereType<latlong.LatLng>()
        .toList();

    if (points.isEmpty) {
      return _MeetLocationMapCard(
        point: latlong.LatLng(0, 0),
        locationName: 'Location unavailable',
        locationAddress: null,
      );
    }

    final centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final centerLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    final center = latlong.LatLng(centerLat, centerLng);

    final participantMap = {for (final p in participants) p.id: p};

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 15.2,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
            ),
          ),
          children: [
            TileLayer(
              retinaMode: true,
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'Solian/1.0 (+https://solian.app, contact: lily@solsynth.dev)',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(
                    Uri.parse('https://openstreetmap.org/copyright'),
                  ),
                ),
              ],
            ),
            MarkerLayer(
              markers: pins
                  .map((pin) {
                    final point = _parsePoint(pin.locationWkt);
                    if (point == null) return null;
                    final participant = participantMap[pin.accountId];
                    final isCurrentUser = pin.accountId == currentUser?.id;
                    final color = isCurrentUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.secondary;
                    return Marker(
                      point: point,
                      width: 72,
                      height: 72,
                      child: _MeetParticipantPin(
                        name:
                            participant?.account?.nick ??
                            participant?.account?.name ??
                            participant?.fallbackName ??
                            pin.accountId.substring(0, 8),
                        color: color,
                        avatar: participant?.account?.profile.picture,
                        accountName: participant?.account?.name,
                      ),
                    );
                  })
                  .whereType<Marker>()
                  .toList(),
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
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Symbols.location_on,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'meetParticipantsLocation'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).fontSize(15).bold(),
                          Text(
                            '${pins.length} ${pins.length == 1 ? 'participant'.tr() : 'participants'.tr()}',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontSize: 13,
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
    );
  }
}

class _MeetParticipantPin extends StatelessWidget {
  final String name;
  final Color color;
  final IDisplayableCloudFile? avatar;
  final String? accountName;

  const _MeetParticipantPin({
    required this.name,
    required this.color,
    this.avatar,
    this.accountName,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = avatar != null
        ? ProfilePictureWidget(file: avatar, radius: 16)
        : Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 8,
                  spreadRadius: 4,
                ),
              ],
            ),
          );

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              name.length > 6 ? '${name.substring(0, 6)}...' : name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(2),
          accountName != null
              ? GestureDetector(
                  onTap: () => showAccountProfileCard(context, accountName!),
                  child: avatarWidget,
                )
              : avatarWidget,
        ],
      ),
    );
  }
}

class _MeetIdShareSheet extends StatelessWidget {
  final String meetId;
  final String? meetName;

  const _MeetIdShareSheet({required this.meetId, this.meetName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: meetName?.isNotEmpty == true
          ? 'meetQrShareTitle'.tr(args: [meetName!])
          : 'meetQrShareTitleDefault'.tr(),
      heightFactor: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: QrImageView(
                data: meetId,
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const Gap(20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      meetId,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(24),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: meetId));
                if (context.mounted) {
                  showSnackBar('copyToClipboard'.tr());
                }
              },
              icon: const Icon(Symbols.content_copy, size: 18),
              label: Text('copy'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrScannerSheet extends StatefulWidget {
  final ValueChanged<String> onMeetIdScanned;

  const _QrScannerSheet({required this.onMeetIdScanned});

  @override
  State<_QrScannerSheet> createState() => _QrScannerSheetState();
}

class _QrScannerSheetState extends State<_QrScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _hasScanned = true);
        widget.onMeetIdScanned(code);
        Navigator.of(context).pop();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SheetScaffold(
      titleText: 'meetQrScanTitle'.tr(),
      heightFactor: 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            child: Text(
              'meetQrScanHint'.tr(),
              style: TextStyle(color: theme.colorScheme.secondary),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(controller: _controller, onDetect: _onDetect),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: () => _controller.toggleTorch(),
                            icon: ValueListenableBuilder(
                              valueListenable: _controller,
                              builder: (context, state, child) {
                                return Icon(
                                  state.torchState == TorchState.on
                                      ? Symbols.flashlight_on
                                      : Symbols.flashlight_off,
                                );
                              },
                            ),
                          ),
                          const Gap(16),
                          IconButton.filled(
                            onPressed: () => _controller.switchCamera(),
                            icon: const Icon(Symbols.cameraswitch),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(24),
        ],
      ),
    );
  }
}

void showMeetIdShareSheet(
  BuildContext context,
  String meetId, {
  String? meetName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _MeetIdShareSheet(meetId: meetId, meetName: meetName),
  );
}

void showQrScannerSheet(
  BuildContext context,
  ValueChanged<String> onMeetIdScanned,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _QrScannerSheet(onMeetIdScanned: onMeetIdScanned),
  );
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
    SnMeetVisibility.unlisted => 'meetVisibilityUnlisted'.tr(),
    SnMeetVisibility.unknown => 'unknown'.tr(),
  };
}

String _nearbyVisibilityLabel(String visibility, BuildContext context) {
  return switch (visibility.trim().toLowerCase()) {
    'friend_only' => 'nearbyVisibleToFriends'.tr(),
    'public' => 'nearbyVisibleToEveryone'.tr(),
    _ => visibility,
  };
}

MeetEntryMode _entryModeOf(SnMeet? meet) {
  return MeetEntryMode.nearby;
}

String _entryModeLabel(MeetEntryMode mode, BuildContext context) {
  return switch (mode) {
    MeetEntryMode.nearby => 'meetNearbyTab'.tr(),
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
