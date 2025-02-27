import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/logger.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:talker/talker.dart';

final Map<LogLevel, IconData> kLogLevelIcons = {
  LogLevel.error: Symbols.error,
  LogLevel.critical: Symbols.error,
  LogLevel.warning: Symbols.warning,
  LogLevel.info: Symbols.info,
  LogLevel.debug: Symbols.info_i,
  LogLevel.verbose: Symbols.info_i,
};

final Map<LogLevel, Color> kLogLevelColors = {
  LogLevel.error: Colors.red,
  LogLevel.critical: Colors.red,
  LogLevel.warning: Colors.orange,
  LogLevel.info: Colors.blue,
  LogLevel.debug: Colors.green,
  LogLevel.verbose: Colors.green,
};

final Map<LogLevel, bool> kLogLevelFilled = {
  LogLevel.error: false,
  LogLevel.critical: true,
  LogLevel.warning: true,
  LogLevel.info: true,
  LogLevel.debug: false,
  LogLevel.verbose: false,
};

class DebugLoggingScreen extends StatelessWidget {
  const DebugLoggingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('debugLogging').tr(),
      ),
      body: SelectionArea(
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: logging.history.length,
          itemBuilder: (context, index) {
            final log = logging.history[index];
            return ListTile(
              leading: Icon(
                kLogLevelIcons[log.logLevel ?? LogLevel.debug] ?? Symbols.help,
                color: kLogLevelColors[log.logLevel ?? LogLevel.debug],
                fill: (kLogLevelFilled[log.logLevel ?? LogLevel.debug] ?? false)
                    ? 1
                    : 0,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.message ?? 'unknown'.tr(),
                    style: GoogleFonts.robotoMono(fontSize: 13),
                  ),
                  if (log.error != null)
                    Text(
                      log.error!.toString(),
                      style: GoogleFonts.robotoMono(fontSize: 13),
                    ).bold(),
                ],
              ),
              subtitle: Text(log.time.toString()).fontSize(11),
            );
          },
        ),
      ),
    );
  }
}
