import 'package:talker/talker.dart';

final logging = Talker(
  settings: TalkerSettings(
    enabled: true,
    useHistory: true,
    maxHistoryItems: 1000,
    useConsoleLogs: true,
  ),
);
