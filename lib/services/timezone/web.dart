import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/browser.dart' as tz;

Future<void> initializeTzdb() async {
  await tz.initializeTimeZone();
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
