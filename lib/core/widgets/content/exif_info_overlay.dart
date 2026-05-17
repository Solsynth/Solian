import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ExifInfoOverlay extends StatelessWidget {
  final IDisplayableCloudFile item;

  const ExifInfoOverlay({super.key, required this.item});

  static bool precheck(IDisplayableCloudFile item) {
    final exifVersion = item.fileMeta['exif_version'] as int? ?? 1;
    final exifData = item.fileMeta['exif'] as Map<String, dynamic>? ?? {};

    if (exifData.isEmpty) return false;

    if (exifVersion == 2) {
      final dateTime = exifData['DateTime'];
      final model = exifData['Model'];
      final iso = exifData['ISOSpeedRatings'];
      final fnumber = exifData['FNumber'];
      final exposureTime = exifData['ExposureTime'];
      final focalLength = exifData['FocalLength'];

      return (dateTime != null && dateTime.toString().isNotEmpty) ||
          (model != null && model.toString().isNotEmpty) ||
          iso != null ||
          fnumber != null ||
          exposureTime != null ||
          focalLength != null;
    } else {
      final dateTime = exifData['ifd0-DateTime'];
      final model = exifData['ifd0-Model'];
      final iso = exifData['ifd2-ISOSpeedRatings'];
      final fnumber = exifData['ifd2-FNumber'];
      final exposureTime = exifData['ifd2-ExposureTime'];
      final focalLength = exifData['ifd2-FocalLength'];

      return (dateTime != null && dateTime.isNotEmpty) ||
          (model != null && model.isNotEmpty) ||
          iso != null ||
          fnumber != null ||
          exposureTime != null ||
          focalLength != null;
    }
  }

  String? _getExifValue(Map<String, dynamic> exifData, int version, String key) {
    if (version == 2) {
      return exifData[key]?.toString();
    } else {
      final prefixMap = {
        'DateTime': 'ifd0',
        'Model': 'ifd0',
        'ISOSpeedRatings': 'ifd2',
        'FNumber': 'ifd2',
        'ExposureTime': 'ifd2',
        'FocalLength': 'ifd2',
      };
      final prefix = prefixMap[key];
      if (prefix == null) return null;
      return exifData['$prefix-$key']?.toString();
    }
  }

  String _stripQuotes(String value) {
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }

  double _parseFraction(String value) {
    final parts = value.split('/');
    if (parts.length == 2) {
      final numerator = double.tryParse(parts[0]);
      final denominator = double.tryParse(parts[1]);
      if (numerator != null && denominator != null && denominator != 0) {
        return numerator / denominator;
      }
    }
    return double.tryParse(value) ?? 0.0;
  }

  String _formatExifValueV2(String key, String value) {
    final cleanValue = _stripQuotes(value);

    switch (key) {
      case 'FNumber':
        final decimal = _parseFraction(cleanValue);
        return 'f/${decimal.toStringAsFixed(1)}';
      case 'ExposureTime':
        final decimal = _parseFraction(cleanValue);
        if (decimal >= 1) {
          return '${cleanValue}s (${decimal.toStringAsFixed(3)}s)';
        } else {
          return '$cleanValue (${decimal.toStringAsFixed(3)}s)';
        }
      case 'FocalLength':
        final decimal = _parseFraction(cleanValue);
        return '${decimal.toInt()}mm';
      case 'ISOSpeedRatings':
        return cleanValue;
      case 'DateTime':
      case 'Model':
        return cleanValue;
      default:
        return cleanValue;
    }
  }

  bool _isPreferredValue(String key, String value) {
    if ([
      'ExposureTime',
      'FNumber',
      'FocalLength',
      'ApertureValue',
      'DateTime',
    ].contains(key)) {
      return true;
    }

    return false;
  }

  String _formatExifValueV1(String key, String value) {
    final lastOpen = value.lastIndexOf('(');
    final lastClose = value.endsWith(')') ? value.length - 1 : -1;

    if (lastOpen == -1 || lastClose == -1 || lastOpen > lastClose) {
      return value;
    }

    final inside = value.substring(lastOpen + 1, lastClose);
    final commaIndex = inside.indexOf(',');

    if (commaIndex != -1) {
      final candidate = inside.substring(0, commaIndex).trim();

      if (_isPreferredValue(key, candidate)) {
        return candidate;
      }
    }

    if (lastOpen == -1) {
      return value;
    }

    return value.substring(0, lastOpen).trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final exifVersion = item.fileMeta['exif_version'] as int? ?? 1;
    final exifData = item.fileMeta['exif'] as Map<String, dynamic>? ?? {};

    if (exifData.isEmpty) return const SizedBox.shrink();

    final dateTime = _getExifValue(exifData, exifVersion, 'DateTime');
    final model = _getExifValue(exifData, exifVersion, 'Model');
    final iso = _getExifValue(exifData, exifVersion, 'ISOSpeedRatings');
    final fnumber = _getExifValue(exifData, exifVersion, 'FNumber');
    final exposureTime = _getExifValue(exifData, exifVersion, 'ExposureTime');
    final focalLength = _getExifValue(exifData, exifVersion, 'FocalLength');

    final items = <Widget>[];

    if (dateTime?.isNotEmpty ?? false) {
      items.add(_buildExifItem('DateTime', dateTime!, Symbols.calendar_check, exifVersion));
    }
    if (model?.isNotEmpty ?? false) {
      items.add(_buildExifItem('Model', model!, Symbols.camera_alt, exifVersion));
    }
    if (iso != null) {
      items.add(_buildExifItem('ISO', iso, Icons.iso, exifVersion));
    }
    if (fnumber != null) {
      items.add(_buildExifItem('FNumber', fnumber, Symbols.camera_enhance, exifVersion));
    }
    if (exposureTime != null) {
      items.add(
        _buildExifItem('ExposureTime', exposureTime, Icons.shutter_speed, exifVersion),
      );
    }
    if (focalLength != null) {
      items.add(
        _buildExifItem(
          'FocalLength',
          focalLength,
          Symbols.photo_size_select_large,
          exifVersion,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Wrap(
          alignment: WrapAlignment.end,
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: item,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildExifItem(String key, String value, IconData icon, int version) {
    final formattedValue = version == 2
        ? _formatExifValueV2(key, value)
        : _formatExifValueV1(key, value);
    final shadow = [
      Shadow(
        color: Colors.black54,
        blurRadius: 5.0,
        offset: const Offset(1.0, 1.0),
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white70, shadows: shadow),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            formattedValue,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: shadow,
            ),
          ),
        ),
      ],
    );
  }
}
