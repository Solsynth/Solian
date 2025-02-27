import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/logger.dart';
import 'package:surface/widgets/dialog.dart';
import 'package:surface/widgets/navigation/app_scaffold.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_flutter/talker_flutter.dart';

final Map<LogLevel, IconData> kLogLevelIcons = {
  LogLevel.error: Symbols.error,
  LogLevel.critical: Symbols.error,
  LogLevel.warning: Symbols.warning,
  LogLevel.info: Symbols.info,
  LogLevel.debug: Symbols.info_i,
  LogLevel.verbose: Symbols.info_i,
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
    final talkerTheme = TalkerScreenTheme.fromTheme(Theme.of(context));

    return AppScaffold(
      appBar: AppBar(
        leading: const PageBackButton(),
        title: Text('debugLogging').tr(),
        actions: [
          IconButton(
            onPressed: () {
              logging.cleanHistory();
              Navigator.pop(context);
            },
            icon: const Icon(Symbols.delete),
          ),
        ],
      ),
      body: ListView.builder(
        reverse: true,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        itemCount: logging.history.length,
        itemBuilder: (context, index) {
          final log = logging.history[index];
          final color = log.getFlutterColor(talkerTheme);
          return ListTile(
            minTileHeight: 0,
            tileColor: color.withOpacity(0.2),
            leading: Icon(
              kLogLevelIcons[log.logLevel ?? LogLevel.debug] ?? Symbols.help,
              color: color,
              fill: (kLogLevelFilled[log.logLevel ?? LogLevel.debug] ?? false)
                  ? 1
                  : 0,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log is DioRequestLog)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.requestOptions.method} ${log.displayMessage}',
                        style: GoogleFonts.robotoMono(fontSize: 13),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text('Payload').fontSize(13),
                          minTileHeight: 0,
                          tilePadding: EdgeInsets.zero,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.requestOptions.data.toString(),
                              style: GoogleFonts.robotoMono(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (log is DioResponseLog)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.response.statusCode} ${log.displayMessage}',
                        style: GoogleFonts.robotoMono(fontSize: 13),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Text('Payload').fontSize(13),
                          minTileHeight: 0,
                          tilePadding: EdgeInsets.zero,
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.response.data.toString(),
                              style: GoogleFonts.robotoMono(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    log.displayMessage,
                    style: GoogleFonts.robotoMono(fontSize: 13),
                  ),
                if (log.exception != null)
                  Text(
                    log.displayException,
                    style: GoogleFonts.robotoMono(fontSize: 13),
                  ).bold(),
                if (log.error != null)
                  Text(
                    log.displayException,
                    style: GoogleFonts.robotoMono(fontSize: 13),
                  ).bold(),
                if (log.stackTrace != null)
                  Text(
                    log.displayStackTrace,
                    style: GoogleFonts.robotoMono(fontSize: 12),
                  ).padding(top: 4),
              ],
            ),
            subtitle: Text(
              '${(log.title?.replaceAll('-', ' ') ?? 'default').capitalizeEachWord()} · ${log.displayTime()}',
            ).fontSize(11),
            onTap: () {
              Clipboard.setData(
                ClipboardData(
                  text: ['[${log.time}]', log.message, log.error?.toString()]
                      .where((ele) => ele != null)
                      .join('\n'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
