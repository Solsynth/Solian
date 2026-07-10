import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:open_meteo/open_meteo.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// Open-Meteo requires attribution next to displayed weather data (CC BY 4.0).
/// Recommended form: "Weather data by Open-Meteo.com" → https://open-meteo.com/
const _kOpenMeteoUrl = 'https://open-meteo.com/';
const _kOpenMeteoLicenceUrl = 'https://open-meteo.com/en/licence';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.precipitation,
    required this.pressure,
    required this.cloudCover,
    required this.weatherCode,
    required this.isDay,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  final double latitude;
  final double longitude;
  final String locationLabel;
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double windGusts;
  final double precipitation;
  final double pressure;
  final double cloudCover;
  final int weatherCode;
  final bool isDay;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.isDay,
  });

  final DateTime time;
  final double temperature;
  final int weatherCode;
  final double precipitationProbability;
  final bool isDay;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationProbability,
    required this.precipitationSum,
    required this.uvIndexMax,
    required this.windSpeedMax,
    this.sunrise,
    this.sunset,
  });

  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final double precipitationProbability;
  final double precipitationSum;
  final double uvIndexMax;
  final double windSpeedMax;
  final DateTime? sunrise;
  final DateTime? sunset;
}

// ---------------------------------------------------------------------------
// WMO weather code helpers (Open-Meteo)
// ---------------------------------------------------------------------------

class WeatherCodeInfo {
  const WeatherCodeInfo(
    this.icon,
    this.labelKey, {
    required this.colorLight,
    required this.colorDark,
  });

  final IconData icon;
  final String labelKey;
  final Color colorLight;
  final Color colorDark;

  Color colorFor(Brightness brightness) =>
      brightness == Brightness.dark ? colorDark : colorLight;

  /// Filled, condition-colored weather glyph.
  Widget buildIcon({
    required Brightness brightness,
    double size = 24,
    double fill = 1,
  }) {
    return Icon(icon, size: size, color: colorFor(brightness), fill: fill);
  }
}

// Semantic palette — vivid on light surfaces, slightly lifted on dark.
abstract final class _WeatherPalette {
  static const sun = Color(0xFFF59E0B);
  static const sunDark = Color(0xFFFBBF24);
  static const moon = Color(0xFF818CF8);
  static const moonDark = Color(0xFFA5B4FC);
  static const sky = Color(0xFF38BDF8);
  static const skyDark = Color(0xFF7DD3FC);
  static const cloud = Color(0xFF64748B);
  static const cloudDark = Color(0xFF94A3B8);
  static const fog = Color(0xFF9CA3AF);
  static const fogDark = Color(0xFFD1D5DB);
  static const drizzle = Color(0xFF0EA5E9);
  static const drizzleDark = Color(0xFF38BDF8);
  static const rain = Color(0xFF2563EB);
  static const rainDark = Color(0xFF60A5FA);
  static const snow = Color(0xFF22D3EE);
  static const snowDark = Color(0xFFA5F3FC);
  static const storm = Color(0xFF7C3AED);
  static const stormDark = Color(0xFFC4B5FD);
  static const unknown = Color(0xFF6B7280);
  static const unknownDark = Color(0xFF9CA3AF);
}

WeatherCodeInfo weatherCodeInfo(int code, {bool isDay = true}) {
  switch (code) {
    case 0:
      return WeatherCodeInfo(
        isDay ? Symbols.sunny : Symbols.clear_night,
        'weatherClear',
        colorLight: isDay ? _WeatherPalette.sun : _WeatherPalette.moon,
        colorDark: isDay ? _WeatherPalette.sunDark : _WeatherPalette.moonDark,
      );
    case 1:
      return WeatherCodeInfo(
        isDay ? Symbols.partly_cloudy_day : Symbols.partly_cloudy_night,
        'weatherMainlyClear',
        colorLight: isDay ? _WeatherPalette.sun : _WeatherPalette.moon,
        colorDark: isDay ? _WeatherPalette.sunDark : _WeatherPalette.moonDark,
      );
    case 2:
      return WeatherCodeInfo(
        isDay ? Symbols.partly_cloudy_day : Symbols.partly_cloudy_night,
        'weatherPartlyCloudy',
        colorLight: _WeatherPalette.sky,
        colorDark: _WeatherPalette.skyDark,
      );
    case 3:
      return const WeatherCodeInfo(
        Symbols.cloud,
        'weatherOvercast',
        colorLight: _WeatherPalette.cloud,
        colorDark: _WeatherPalette.cloudDark,
      );
    case 45:
    case 48:
      return const WeatherCodeInfo(
        Symbols.foggy,
        'weatherFog',
        colorLight: _WeatherPalette.fog,
        colorDark: _WeatherPalette.fogDark,
      );
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return const WeatherCodeInfo(
        Symbols.grain,
        'weatherDrizzle',
        colorLight: _WeatherPalette.drizzle,
        colorDark: _WeatherPalette.drizzleDark,
      );
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
      return const WeatherCodeInfo(
        Symbols.rainy,
        'weatherRain',
        colorLight: _WeatherPalette.rain,
        colorDark: _WeatherPalette.rainDark,
      );
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherCodeInfo(
        Symbols.weather_snowy,
        'weatherSnow',
        colorLight: _WeatherPalette.snow,
        colorDark: _WeatherPalette.snowDark,
      );
    case 80:
    case 81:
    case 82:
      return const WeatherCodeInfo(
        Symbols.rainy,
        'weatherShowers',
        colorLight: _WeatherPalette.rain,
        colorDark: _WeatherPalette.rainDark,
      );
    case 85:
    case 86:
      return const WeatherCodeInfo(
        Symbols.weather_snowy,
        'weatherSnowShowers',
        colorLight: _WeatherPalette.snow,
        colorDark: _WeatherPalette.snowDark,
      );
    case 95:
      return const WeatherCodeInfo(
        Symbols.thunderstorm,
        'weatherThunderstorm',
        colorLight: _WeatherPalette.storm,
        colorDark: _WeatherPalette.stormDark,
      );
    case 96:
    case 99:
      return const WeatherCodeInfo(
        Symbols.thunderstorm,
        'weatherThunderstormHail',
        colorLight: _WeatherPalette.storm,
        colorDark: _WeatherPalette.stormDark,
      );
    default:
      return const WeatherCodeInfo(
        Symbols.thermostat,
        'weatherUnknown',
        colorLight: _WeatherPalette.unknown,
        colorDark: _WeatherPalette.unknownDark,
      );
  }
}

String windDirectionLabel(double degrees) {
  if (degrees.isNaN) return '—';
  const dirKeys = [
    'weatherDirN',
    'weatherDirNE',
    'weatherDirE',
    'weatherDirSE',
    'weatherDirS',
    'weatherDirSW',
    'weatherDirW',
    'weatherDirNW',
  ];
  final index = ((degrees % 360) / 45).round() % 8;
  return dirKeys[index].tr();
}

String _localeTag(BuildContext context) =>
    Localizations.localeOf(context).toString();

String formatWeatherWindSpeed(double kmh) =>
    'weatherUnitKmh'.tr(args: [kmh.toStringAsFixed(0)]);

String formatWeatherPrecipitation(double mm) =>
    'weatherUnitMm'.tr(args: [mm.toStringAsFixed(1)]);

String formatWeatherPressure(double hpa) =>
    'weatherUnitHpa'.tr(args: [hpa.round().toString()]);

// ---------------------------------------------------------------------------
// Location + Open-Meteo fetch
// ---------------------------------------------------------------------------

class WeatherLocationException implements Exception {
  WeatherLocationException(this.messageKey);
  final String messageKey;

  @override
  String toString() => messageKey;
}

Future<({double latitude, double longitude, String label})>
_resolveLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw WeatherLocationException('weatherLocationDisabled');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw WeatherLocationException('weatherLocationDenied');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
  );

  final label = await _resolvePlaceName(position.latitude, position.longitude);

  return (
    latitude: position.latitude,
    longitude: position.longitude,
    label: label,
  );
}

Future<String> _resolvePlaceName(double latitude, double longitude) async {
  final fallback =
      '${latitude.toStringAsFixed(2)}°, ${longitude.toStringAsFixed(2)}°';

  final canReverseGeocode =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  if (!canReverseGeocode) return fallback;

  try {
    final placemarks = await Geocoding().placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isEmpty) return fallback;
    final p = placemarks.first;
    final parts = [
      p.locality,
      p.subAdministrativeArea,
      p.administrativeArea,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return fallback;
    return parts.first;
  } catch (_) {
    return fallback;
  }
}

num? _seriesValue(Map<DateTime, num> series, DateTime key) => series[key];

DateTime? _seriesDateTime(Map<DateTime, num> series, DateTime key) {
  final value = series[key];
  if (value == null) return null;
  // Open-Meteo encodes sunrise/sunset as unix timestamps in FlatBuffers.
  if (value > 1e9) {
    return DateTime.fromMillisecondsSinceEpoch(
      (value * 1000).round(),
      isUtc: true,
    ).toLocal();
  }
  return null;
}

Future<WeatherSnapshot> fetchWeatherSnapshot() async {
  final location = await _resolveLocation();

  final weather = WeatherApi(
    userAgent: 'Solian/Island (https://solsynth.dev)',
    temperatureUnit: TemperatureUnit.celsius,
    windspeedUnit: WindspeedUnit.kmh,
  );

  final response = await weather.request(
    locations: {
      OpenMeteoLocation(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    },
    current: {
      WeatherCurrent.temperature_2m,
      WeatherCurrent.apparent_temperature,
      WeatherCurrent.relative_humidity_2m,
      WeatherCurrent.wind_speed_10m,
      WeatherCurrent.wind_direction_10m,
      WeatherCurrent.wind_gusts_10m,
      WeatherCurrent.precipitation,
      WeatherCurrent.pressure_msl,
      WeatherCurrent.cloud_cover,
      WeatherCurrent.weather_code,
      WeatherCurrent.is_day,
    },
    hourly: {
      WeatherHourly.temperature_2m,
      WeatherHourly.weather_code,
      WeatherHourly.precipitation_probability,
      WeatherHourly.is_day,
    },
    daily: {
      WeatherDaily.weather_code,
      WeatherDaily.temperature_2m_max,
      WeatherDaily.temperature_2m_min,
      WeatherDaily.precipitation_probability_max,
      WeatherDaily.precipitation_sum,
      WeatherDaily.uv_index_max,
      WeatherDaily.wind_speed_10m_max,
      WeatherDaily.sunrise,
      WeatherDaily.sunset,
    },
    forecastDays: 7,
    forecastHours: 24,
  );

  if (response.segments.isEmpty) {
    throw StateError('weatherEmptyResponse');
  }

  final segment = response.segments.first;
  final current = segment.currentData;

  double currentValue(WeatherCurrent key) => current[key]?.value ?? double.nan;

  final temperature = currentValue(WeatherCurrent.temperature_2m);
  final apparent = currentValue(WeatherCurrent.apparent_temperature);
  final humidity = currentValue(WeatherCurrent.relative_humidity_2m);
  final wind = currentValue(WeatherCurrent.wind_speed_10m);
  final windDir = currentValue(WeatherCurrent.wind_direction_10m);
  final windGusts = currentValue(WeatherCurrent.wind_gusts_10m);
  final precipitation = currentValue(WeatherCurrent.precipitation);
  final pressure = currentValue(WeatherCurrent.pressure_msl);
  final cloudCover = currentValue(WeatherCurrent.cloud_cover);
  final code = currentValue(WeatherCurrent.weather_code).round();
  final isDay = currentValue(WeatherCurrent.is_day).round() == 1;

  // Hourly — next 24 entries from now (API already scoped by forecastHours).
  final hourlyTemp =
      segment.hourlyData[WeatherHourly.temperature_2m]?.values ??
      const <DateTime, num>{};
  final hourlyCode =
      segment.hourlyData[WeatherHourly.weather_code]?.values ??
      const <DateTime, num>{};
  final hourlyPrecip =
      segment.hourlyData[WeatherHourly.precipitation_probability]?.values ??
      const <DateTime, num>{};
  final hourlyIsDay =
      segment.hourlyData[WeatherHourly.is_day]?.values ??
      const <DateTime, num>{};

  final now = DateTime.now();
  final hourlyTimes = hourlyTemp.keys.toList()..sort();
  final hourly = <HourlyForecast>[];
  for (final time in hourlyTimes) {
    if (time.isBefore(now.subtract(const Duration(hours: 1)))) continue;
    hourly.add(
      HourlyForecast(
        time: time,
        temperature: (_seriesValue(hourlyTemp, time) ?? 0).toDouble(),
        weatherCode: (_seriesValue(hourlyCode, time) ?? 0).round(),
        precipitationProbability: (_seriesValue(hourlyPrecip, time) ?? 0)
            .toDouble(),
        isDay: (_seriesValue(hourlyIsDay, time) ?? 1).round() == 1,
      ),
    );
    if (hourly.length >= 24) break;
  }

  // Daily
  final maxSeries =
      segment.dailyData[WeatherDaily.temperature_2m_max]?.values ??
      const <DateTime, num>{};
  final minSeries =
      segment.dailyData[WeatherDaily.temperature_2m_min]?.values ??
      const <DateTime, num>{};
  final codeSeries =
      segment.dailyData[WeatherDaily.weather_code]?.values ??
      const <DateTime, num>{};
  final precipProbSeries =
      segment.dailyData[WeatherDaily.precipitation_probability_max]?.values ??
      const <DateTime, num>{};
  final precipSumSeries =
      segment.dailyData[WeatherDaily.precipitation_sum]?.values ??
      const <DateTime, num>{};
  final uvSeries =
      segment.dailyData[WeatherDaily.uv_index_max]?.values ??
      const <DateTime, num>{};
  final windMaxSeries =
      segment.dailyData[WeatherDaily.wind_speed_10m_max]?.values ??
      const <DateTime, num>{};
  final sunriseSeries =
      segment.dailyData[WeatherDaily.sunrise]?.values ??
      const <DateTime, num>{};
  final sunsetSeries =
      segment.dailyData[WeatherDaily.sunset]?.values ?? const <DateTime, num>{};

  final dates = maxSeries.keys.toList()..sort();
  final daily = <DailyForecast>[];
  for (final date in dates.take(7)) {
    daily.add(
      DailyForecast(
        date: date,
        weatherCode: (_seriesValue(codeSeries, date) ?? 0).round(),
        tempMax: (_seriesValue(maxSeries, date) ?? 0).toDouble(),
        tempMin: (_seriesValue(minSeries, date) ?? 0).toDouble(),
        precipitationProbability: (_seriesValue(precipProbSeries, date) ?? 0)
            .toDouble(),
        precipitationSum: (_seriesValue(precipSumSeries, date) ?? 0).toDouble(),
        uvIndexMax: (_seriesValue(uvSeries, date) ?? 0).toDouble(),
        windSpeedMax: (_seriesValue(windMaxSeries, date) ?? 0).toDouble(),
        sunrise: _seriesDateTime(sunriseSeries, date),
        sunset: _seriesDateTime(sunsetSeries, date),
      ),
    );
  }

  return WeatherSnapshot(
    latitude: location.latitude,
    longitude: location.longitude,
    locationLabel: location.label,
    temperature: temperature,
    apparentTemperature: apparent,
    humidity: humidity,
    windSpeed: wind,
    windDirection: windDir,
    windGusts: windGusts,
    precipitation: precipitation,
    pressure: pressure,
    cloudCover: cloudCover,
    weatherCode: code,
    isDay: isDay,
    hourly: hourly,
    daily: daily,
    fetchedAt: DateTime.now(),
  );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Auto-dispose so we don't keep polling when the dashboard card is hidden.
final weatherSnapshotProvider = FutureProvider.autoDispose<WeatherSnapshot>((
  ref,
) async {
  return fetchWeatherSnapshot();
});

// ---------------------------------------------------------------------------
// Detail sheet
// ---------------------------------------------------------------------------

Future<void> showWeatherDetailSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => const WeatherDetailSheet(),
  );
}

class WeatherDetailSheet extends ConsumerWidget {
  const WeatherDetailSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherSnapshotProvider);

    return SheetScaffold(
      titleText: 'weatherDetails'.tr(),
      heightFactor: 0.92,
      actions: [
        IconButton(
          tooltip: 'weatherRefresh'.tr(),
          onPressed: () => ref.invalidate(weatherSnapshotProvider),
          icon: const Icon(Symbols.refresh),
        ),
      ],
      child: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _WeatherDetailError(
          error: error,
          onRetry: () => ref.invalidate(weatherSnapshotProvider),
        ),
        data: (weather) => _WeatherDetailBody(weather: weather),
      ),
    );
  }
}

class _WeatherDetailBody extends StatelessWidget {
  const _WeatherDetailBody({required this.weather});

  final WeatherSnapshot weather;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final info = weatherCodeInfo(weather.weatherCode, isDay: weather.isDay);
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        // Hero current conditions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            info.buildIcon(brightness: theme.brightness, size: 64),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    info.labelKey.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Symbols.location_on,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          weather.locationLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (today != null)
                    Text(
                      'weatherHighLow'.tr(
                        args: [
                          '${today.tempMax.round()}',
                          '${today.tempMin.round()}',
                        ],
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ).padding(top: 2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'weatherUpdatedAt'.tr(
            args: [
              DateFormat.Hm(_localeTag(context)).format(weather.fetchedAt),
            ],
          ),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 20),

        // Current metrics grid
        _SectionTitle(title: 'weatherNow'.tr()),
        const SizedBox(height: 8),
        _MetricGrid(
          items: [
            _MetricItem(
              icon: Symbols.thermostat,
              label: 'weatherFeelsLike'.tr(),
              value: '${weather.apparentTemperature.round()}°',
            ),
            _MetricItem(
              icon: Symbols.humidity_percentage,
              label: 'weatherHumidity'.tr(),
              value: '${weather.humidity.round()}%',
            ),
            _MetricItem(
              icon: Symbols.air,
              label: 'weatherWind'.tr(),
              value: weather.windSpeed.isNaN
                  ? '—'
                  : 'weatherWindWithDirection'.tr(
                      args: [
                        formatWeatherWindSpeed(weather.windSpeed),
                        windDirectionLabel(weather.windDirection),
                      ],
                    ),
            ),
            _MetricItem(
              icon: Symbols.storm,
              label: 'weatherWindGusts'.tr(),
              value: weather.windGusts.isNaN
                  ? '—'
                  : formatWeatherWindSpeed(weather.windGusts),
            ),
            _MetricItem(
              icon: Symbols.water_drop,
              label: 'weatherPrecipitation'.tr(),
              value: weather.precipitation.isNaN
                  ? '—'
                  : formatWeatherPrecipitation(weather.precipitation),
            ),
            _MetricItem(
              icon: Symbols.compress,
              label: 'weatherPressure'.tr(),
              value: weather.pressure.isNaN
                  ? '—'
                  : formatWeatherPressure(weather.pressure),
            ),
            _MetricItem(
              icon: Symbols.cloud,
              label: 'weatherCloudCover'.tr(),
              value: weather.cloudCover.isNaN
                  ? '—'
                  : '${weather.cloudCover.round()}%',
            ),
            if (today != null)
              _MetricItem(
                icon: Symbols.wb_sunny,
                label: 'weatherUvIndex'.tr(),
                value: today.uvIndexMax.toStringAsFixed(1),
              ),
          ],
        ),

        if (today?.sunrise != null || today?.sunset != null) ...[
          const SizedBox(height: 16),
          _SectionTitle(title: 'weatherSun'.tr()),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SunTile(
                  icon: Symbols.wb_twilight,
                  label: 'weatherSunrise'.tr(),
                  time: today?.sunrise,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SunTile(
                  icon: Symbols.wb_twilight,
                  label: 'weatherSunset'.tr(),
                  time: today?.sunset,
                  evening: true,
                ),
              ),
            ],
          ),
        ],

        // Hourly
        if (weather.hourly.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionTitle(title: 'weatherHourly'.tr()),
          const SizedBox(height: 10),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weather.hourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final hour = weather.hourly[index];
                final hourInfo = weatherCodeInfo(
                  hour.weatherCode,
                  isDay: hour.isDay,
                );
                final isNow = index == 0;
                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isNow
                        ? colorScheme.primaryContainer.withValues(alpha: 0.55)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                    borderRadius: BorderRadius.circular(14),
                    border: isNow
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNow
                            ? 'weatherNow'.tr()
                            : DateFormat.Hm(
                                _localeTag(context),
                              ).format(hour.time),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                          color: isNow
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      hourInfo.buildIcon(
                        brightness: theme.brightness,
                        size: 24,
                      ),
                      Text(
                        '${hour.temperature.round()}°',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.water_drop,
                            size: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          Text(
                            '${hour.precipitationProbability.round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        // Daily
        if (weather.daily.isNotEmpty) ...[
          const SizedBox(height: 24),
          _SectionTitle(title: 'weatherDailyForecast'.tr()),
          const SizedBox(height: 8),
          ...weather.daily.map((day) {
            final dayInfo = weatherCodeInfo(day.weatherCode);
            final isToday = DateUtils.isSameDay(day.date, DateTime.now());
            final locale = _localeTag(context);
            final weekday = isToday
                ? 'weatherToday'.tr()
                : DateFormat.E(locale).format(day.date);
            final dateLabel = DateFormat.Md(locale).format(day.date);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekday,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isToday ? colorScheme.primary : null,
                          ),
                        ),
                        Text(
                          dateLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  dayInfo.buildIcon(brightness: theme.brightness, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dayInfo.labelKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Row(
                      children: [
                        Icon(
                          Symbols.water_drop,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        Flexible(
                          child: Text(
                            '${day.precipitationProbability.round()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '${day.tempMax.round()}° / ${day.tempMin.round()}°',
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 20),
        const _OpenMeteoAttribution(detailed: true),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});

  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 420 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SunTile extends StatelessWidget {
  const _SunTile({
    required this.icon,
    required this.label,
    required this.time,
    this.evening = false,
  });

  final IconData icon;
  final String label;
  final DateTime? time;
  final bool evening;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: evening ? colorScheme.tertiary : colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time != null
                      ? DateFormat.Hm(_localeTag(context)).format(time!)
                      : '—',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetailError extends StatelessWidget {
  const _WeatherDetailError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final message = switch (error) {
      WeatherLocationException(:final messageKey) => messageKey.tr(),
      _ => 'weatherLoadFailed'.tr(),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.cloud_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Symbols.refresh, size: 18),
              label: Text('weatherRetry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard card
// ---------------------------------------------------------------------------

class WeatherCard extends ConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherSnapshotProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title stays real (never skeletonized).
          _WeatherCardHeader(
            onRefresh: () => ref.invalidate(weatherSnapshotProvider),
            showChevron: weatherAsync.hasValue,
          ),
          weatherAsync.when(
            loading: () => const _WeatherCardSkeletonBody(),
            error: (error, _) => _WeatherCardErrorBody(
              error: error,
              onRetry: () => ref.invalidate(weatherSnapshotProvider),
            ),
            data: (weather) {
              final info = weatherCodeInfo(
                weather.weatherCode,
                isDay: weather.isDay,
              );
              final today = weather.daily.isNotEmpty
                  ? weather.daily.first
                  : null;

              return InkWell(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                onTap: () => showWeatherDetailSheet(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          info.buildIcon(
                            brightness: theme.brightness,
                            size: 36,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${weather.temperature.round()}°',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info.labelKey.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  weather.locationLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (today != null)
                            Text(
                              '${today.tempMax.round()}°/${today.tempMin.round()}°',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Compact metric chips in one line
                      Text(
                        'weatherCardSummary'.tr(
                          args: [
                            '${weather.apparentTemperature.round()}',
                            '${weather.humidity.round()}',
                            weather.windSpeed.isNaN
                                ? '—'
                                : formatWeatherWindSpeed(weather.windSpeed),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeatherCardHeader extends StatelessWidget {
  const _WeatherCardHeader({required this.onRefresh, this.showChevron = false});

  final VoidCallback onRefresh;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Symbols.partly_cloudy_day, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'weather'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showChevron)
          Icon(
            Symbols.chevron_right,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'weatherRefresh'.tr(),
          onPressed: onRefresh,
          icon: Icon(
            Symbols.refresh,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ).padding(horizontal: 16, top: 10, bottom: 4);
  }
}

/// Attribution for Open-Meteo (CC BY 4.0), shown in the detail sheet.
///
/// See https://open-meteo.com/en/licence
class _OpenMeteoAttribution extends StatelessWidget {
  const _OpenMeteoAttribution({this.detailed = true});

  final bool detailed;

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.labelSmall?.copyWith(
      color: colorScheme.outline,
      height: 1.35,
    );
    final linkStyle = baseStyle?.copyWith(
      color: colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary.withValues(alpha: 0.5),
    );

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('${'weatherDataBy'.tr()} ', style: baseStyle),
            GestureDetector(
              onTap: () => _open(_kOpenMeteoUrl),
              child: Text('Open-Meteo.com', style: linkStyle),
            ),
          ],
        ),
        if (detailed) ...[
          const SizedBox(height: 2),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${'weatherLicencePrefix'.tr()} ', style: baseStyle),
              GestureDetector(
                onTap: () => _open(_kOpenMeteoLicenceUrl),
                child: Text('CC BY 4.0', style: linkStyle),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Skeleton body only — header title stays outside Skeletonizer.
class _WeatherCardSkeletonBody extends StatelessWidget {
  const _WeatherCardSkeletonBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Symbols.sunny, size: 36),
                const SizedBox(width: 12),
                Text('22°', style: theme.textTheme.headlineSmall),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clear sky placeholder',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        'Location placeholder',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text('25°/18°', style: theme.textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Feels like · Humidity · Wind',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCardErrorBody extends StatelessWidget {
  const _WeatherCardErrorBody({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final message = switch (error) {
      WeatherLocationException(:final messageKey) => messageKey.tr(),
      _ => 'weatherLoadFailed'.tr(),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Icon(
            Symbols.cloud_off,
            size: 28,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text('weatherRetry'.tr())),
        ],
      ),
    );
  }
}
