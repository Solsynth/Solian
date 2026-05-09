import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:island/shared/services/location_search_service.dart';
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
  final _searchController = TextEditingController();
  LatLng? _selectedPoint;
  LatLng? _currentLocation;
  bool _isLocating = false;
  bool _isSearching = false;
  MapController? _mapController;
  List<LocationSearchResult> _searchResults = [];
  bool _showSearchResults = false;

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
    _searchController.dispose();
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

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await LocationSearchService.instance.search(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = results.isNotEmpty;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
    }
    setState(() => _isSearching = false);
  }

  void _selectSearchResult(LocationSearchResult result) {
    setState(() {
      _selectedPoint = result.location;
      _showSearchResults = false;
      _searchController.clear();

      if (result.name != null && _nameController.text.isEmpty) {
        _nameController.text = result.name!;
      }
      if (result.address != null && _addressController.text.isEmpty) {
        _addressController.text = result.address!;
      }
    });
    _mapController?.move(result.location, 16);
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
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'searchLocation'.tr(),
                    prefixIcon: const Icon(Symbols.search),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length >= 3) {
                      _searchLocation(value);
                    } else {
                      setState(() {
                        _searchResults = [];
                        _showSearchResults = false;
                      });
                    }
                  },
                ),
                if (_showSearchResults) ...[
                  const Gap(4),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Symbols.location_on,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          title: Text(
                            result.name ?? 'Unknown',
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: result.address != null
                              ? Text(
                                  result.address!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
