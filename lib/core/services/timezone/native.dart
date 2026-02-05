import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdb;

Future<void> initializeTzdb() async {
  tzdb.initializeTimeZones();
}

(Duration offset, DateTime now) getTzInfo(String name) {
  final location = tz.getLocation(name);
  final now = tz.TZDateTime.now(location);
  final offset = now.timeZoneOffset;
  return (offset, now);
}

Future<String> getMachineTz() async {
  return (await FlutterTimezone.getLocalTimezone()).identifier;
}

List<String> getAvailableTz() {
  return tz.timeZoneDatabase.locations.keys.toList();
}
