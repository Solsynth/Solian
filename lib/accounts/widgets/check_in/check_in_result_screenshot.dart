import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/screens/check_in.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

const _kCompactScreenshotArtHeight = 280.0;

class CheckInResultScreenshot extends StatelessWidget {
  final SnAccount user;
  final SnCheckInResult result;

  const CheckInResultScreenshot({
    super.key,
    required this.user,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final report = result.fortuneReport;
    final backgroundAsset = isDark
        ? 'assets/images/michan/check-in-bg-dark.jpg'
        : 'assets/images/michan/check-in-bg-light.jpg';

    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface.withValues(
                  alpha: isDark ? 0.76 : 0.64,
                ),
                theme.colorScheme.surface.withValues(
                  alpha: isDark ? 0.9 : 0.84,
                ),
                theme.colorScheme.surface.withValues(
                  alpha: isDark ? 0.98 : 0.94,
                ),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FortuneCard(
                      level: result.level,
                      poem: report?.poem,
                      artHeight: _kCompactScreenshotArtHeight,
                      showSealHeader: false,
                    ),
                    const Gap(16),
                    _CheckInScreenshotOracleCard(result: result),
                    if (report == null) ...[const Gap(16), FallbackMessage()],
                    const Gap(18),
                    _CheckInScreenshotUserHeader(user: user, result: result),
                    const Gap(12),
                  ],
                ),
              ),
              _CheckInScreenshotFooter(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInScreenshotOracleCard extends StatelessWidget {
  final SnCheckInResult result;

  const _CheckInScreenshotOracleCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final report = result.fortuneReport;
    final theme = Theme.of(context);

    final bodyText = report?.summary.isNotEmpty == true
        ? report!.summary
        : report?.poem ?? 'checkInResultLevel${result.level}'.tr();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Symbols.temple_buddhist,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'checkInTodayOracle'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                DateFormat('yyyy/MM/dd').format(result.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ).padding(horizontal: 16, vertical: 12),
          Text(
            'checkInResultLevel${result.level}'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ).padding(horizontal: 16),
          const SizedBox(height: 8),
          Text(
            bodyText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).padding(horizontal: 16),
          if (report != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OracleMetaChip(icon: Symbols.palette, text: report.luckyColor),
                _OracleMetaChip(icon: Symbols.schedule, text: report.luckyTime),
                _OracleMetaChip(
                  icon: Symbols.explore,
                  text: report.luckyDirection,
                ),
              ],
            ).padding(horizontal: 12),
            const SizedBox(height: 12),
            _OracleActionRow(
              icon: Symbols.task_alt,
              text: report.luckyAction,
              color: theme.colorScheme.primary,
            ).padding(horizontal: 16),
            const SizedBox(height: 8),
            _OracleActionRow(
              icon: Symbols.block,
              text: report.avoidAction,
              color: theme.colorScheme.error,
            ).padding(horizontal: 16),
            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _OracleMetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _OracleMetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _OracleActionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _OracleActionRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _CheckInScreenshotUserHeader extends StatelessWidget {
  final SnAccount user;
  final SnCheckInResult result;

  const _CheckInScreenshotUserHeader({
    required this.user,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          ProfilePictureWidget(file: user.profile.picture, radius: 22),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AccountName(
                        account: user,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        hideOverlay: true,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      DateFormat.yMMMd().format(result.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    HandleChip(
                      handle: user.name,
                      allowCopy: false,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                    ),
                    _buildMetaPill(
                      context,
                      icon: Symbols.local_fire_department,
                      label: 'checkInResultLevel${result.level}'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onPrimaryContainer),
          const Gap(4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInScreenshotFooter extends StatelessWidget {
  final SnAccount user;

  const _CheckInScreenshotFooter({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Image.asset(
              'assets/icons/icon${isDark ? '-dark' : ''}.png',
              width: 40,
              height: 40,
            ),
          ).padding(right: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solar Network',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'sharePostSlogan',
                  style: TextStyle(fontSize: 12),
                ).tr().opacity(0.9),
              ],
            ),
          ),
          QrImageView(
            data: 'https://solian.app/accounts/${user.name}',
            version: QrVersions.auto,
            size: 60,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            backgroundColor: Colors.transparent,
            foregroundColor: theme.colorScheme.onSurface,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
