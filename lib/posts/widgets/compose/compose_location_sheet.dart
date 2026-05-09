import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ComposeLocationSheet extends StatefulWidget {
  const ComposeLocationSheet({super.key});

  @override
  State<ComposeLocationSheet> createState() => _ComposeLocationSheetState();
}

class _ComposeLocationSheetState extends State<ComposeLocationSheet> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? _selectedPoint;
  LatLng? _currentLocation;
  bool _isLocating = false;
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      _selectedPoint = point;
      _currentLocation = point;
      _mapController?.move(point, 15);
    } catch (_) {}
    setState(() => _isLocating = false);
  }

  String _pointToWkt(LatLng point) {
    return 'POINT (${point.longitude} ${point.latitude})';
  }

  void _confirm() {
    final result = <String, String?>{
      'name': _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : null,
      'address': _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      'wkt': _selectedPoint != null ? _pointToWkt(_selectedPoint!) : null,
    };
    if (result.values.any((v) => v != null)) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SheetScaffold(
      titleText: 'addLocation'.tr(),
      heightFactor: 0.85,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'locationNameHint'.tr(),
                prefixIcon: const Icon(Symbols.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'locationAddressHint'.tr(),
                prefixIcon: const Icon(Symbols.map),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'pickOnMap'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (_selectedPoint != null)
                  Text(
                    '${_selectedPoint!.latitude.toStringAsFixed(4)}, ${_selectedPoint!.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const Gap(4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation ??
                          const LatLng(25.0330, 121.5654),
                      initialZoom: 5,
                      onTap: (tapPosition, point) {
                        setState(() => _selectedPoint = point);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.island.app',
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'locate',
                          onPressed: _isLocating ? null : _getCurrentLocation,
                          backgroundColor: colorScheme.surfaceContainer,
                          child: _isLocating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  Symbols.my_location,
                                  color: colorScheme.primary,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).padding(horizontal: 16),
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedPoint != null ||
                        _nameController.text.trim().isNotEmpty ||
                        _addressController.text.trim().isNotEmpty
                    ? _confirm
                    : null,
                icon: const Icon(Symbols.check),
                label: Text('confirmLocation'.tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
