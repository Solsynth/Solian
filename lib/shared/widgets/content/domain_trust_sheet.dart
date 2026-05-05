import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

enum DomainTrustAction { openLink, loadImage }

enum DomainTrustDecision { open, cancelled }

Future<DomainTrustDecision> showDomainTrustSheet(
  BuildContext context, {
  required Uri uri,
  required DomainTrustResult result,
  required DomainTrustAction action,
}) async {
  final decision = await showModalBottomSheet<DomainTrustDecision>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) =>
        DomainTrustSheet(uri: uri, result: result, action: action),
  );
  return decision ?? DomainTrustDecision.cancelled;
}

class DomainTrustSheet extends StatelessWidget {
  final Uri uri;
  final DomainTrustResult result;
  final DomainTrustAction action;

  const DomainTrustSheet({
    super.key,
    required this.uri,
    required this.result,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = !result.isAllowed;

    return SheetScaffold(
      showHeader: false,
      heightFactor: 0.5,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isBlocked ? Symbols.warning : Symbols.shield,
                    color: isBlocked
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "羊国反诈中心提醒您",
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Text(
                      'domainUntrustOpenLinkDescription'.tr(),
                      // action == DomainTrustAction.openLink
                      //     ? 'domainTrustOpenLinkDescription'.tr()
                      //     : 'domainTrustLoadImageDescription'.tr(),
                      style: GoogleFonts.notoSerifSc(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 280),
                ],
              ),
              const SizedBox(height: 24),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        uri.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: Image.asset(
                      'assets/images/michan/link-hint.png',
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              if (isBlocked) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Symbols.privacy_tip,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'domainTrustPrivacyLeakWarning'.tr(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (result.blockReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${'domainTrustReason'.tr()}: ${result.blockReason}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: uri.toString()));
                        showSnackBar('copyToClipboard'.tr());
                      },
                      icon: const Icon(Symbols.content_copy),
                      label: Text('domainTrustCopyLink'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context, DomainTrustDecision.open);
                      },
                      icon: const Icon(Symbols.open_in_new),
                      label: Text('domainTrustOpenAnyway'.tr()),
                      style: isBlocked
                          ? FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onError,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
