import 'package:latlong2/latlong.dart';
import 'package:nominatim_flutter/nominatim_flutter.dart';
import 'package:nominatim_flutter/model/request/request.dart';

class LocationSearchResult {
  final String? name;
  final String? address;
  final LatLng location;
  final String? displayName;

  LocationSearchResult({
    this.name,
    this.address,
    required this.location,
    this.displayName,
  });
}

class LocationSearchService {
  static LocationSearchService? _instance;
  static LocationSearchService get instance => _instance ??= LocationSearchService._();

  LocationSearchService._();

  Future<void> initialize() async {
    NominatimFlutter.instance.configureNominatim(
      useCacheInterceptor: true,
      maxStale: const Duration(days: 7),
      userAgent: 'IslandApp/3.8.0',
    );
  }

  Future<List<LocationSearchResult>> search(String query, {int limit = 5}) async {
    if (query.trim().isEmpty) return [];

    try {
      final searchRequest = SearchRequest(
        query: query,
        limit: limit,
        addressDetails: true,
        nameDetails: true,
      );

      final results = await NominatimFlutter.instance.search(
        searchRequest: searchRequest,
        language: 'en-US,en;q=0.5,zh-CN;q=0.3',
      );

      return results.map((result) {
        final latStr = result.lat;
        final lonStr = result.lon;

        if (latStr == null || lonStr == null) return null;

        final lat = double.tryParse(latStr);
        final lon = double.tryParse(lonStr);

        if (lat == null || lon == null) return null;

        String? name;
        if (result.nameDetails != null) {
          name = result.nameDetails!['name'] ?? result.nameDetails!['Name'];
        }
        name ??= result.displayName?.split(',').first.trim();

        String? address;
        if (result.address != null) {
          final addr = result.address!;
          final parts = <String>[];
          if (addr['city'] != null) parts.add(addr['city'].toString());
          if (addr['state'] != null) parts.add(addr['state'].toString());
          if (addr['country'] != null) parts.add(addr['country'].toString());
          address = parts.join(', ');
        }

        return LocationSearchResult(
          name: name,
          address: address,
          location: LatLng(lat, lon),
          displayName: result.displayName,
        );
      }).whereType<LocationSearchResult>().toList();
    } catch (e) {
      return [];
    }
  }

  Future<LocationSearchResult?> reverseGeocode(LatLng location) async {
    try {
      final reverseRequest = ReverseRequest(
        lat: location.latitude,
        lon: location.longitude,
        addressDetails: true,
        nameDetails: true,
      );

      final result = await NominatimFlutter.instance.reverse(
        reverseRequest: reverseRequest,
        language: 'en-US,en;q=0.5,zh-CN;q=0.3',
      );

      String? name;
      if (result.nameDetails != null) {
        name = result.nameDetails!['name'] ?? result.nameDetails!['Name'];
      }
      name ??= result.displayName?.split(',').first.trim();

      String? address;
      if (result.address != null) {
        final addr = result.address!;
        final parts = <String>[];
        if (addr['city'] != null) parts.add(addr['city'].toString());
        if (addr['state'] != null) parts.add(addr['state'].toString());
        if (addr['country'] != null) parts.add(addr['country'].toString());
        address = parts.join(', ');
      }

      return LocationSearchResult(
        name: name,
        address: address,
        location: location,
        displayName: result.displayName,
      );
    } catch (e) {
      return null;
    }
  }
}
