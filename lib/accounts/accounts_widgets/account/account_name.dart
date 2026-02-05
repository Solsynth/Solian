import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/wallet/wallet_models/wallet.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const Map<String, Color> kUsernamePlainColors = {
  'red': Colors.red,
  'blue': Colors.blue,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'purple': Colors.purple,
  'orange': Colors.orange,
  'pink': Colors.pink,
  'cyan': Colors.cyan,
  'lime': Colors.lime,
  'indigo': Colors.indigo,
  'teal': Colors.teal,
  'amber': Colors.amber,
  'brown': Colors.brown,
  'grey': Colors.grey,
  'black': Colors.black,
  'white': Colors.white,
};

const List<IconData> kVerificationMarkIcons = [
  Symbols.build_circle,
  Symbols.verified,
  Symbols.verified,
  Symbols.account_balance,
  Symbols.palette,
  Symbols.code,
  Symbols.masks,
];

const List<Color> kVerificationMarkColors = [
  Colors.teal,
  Colors.lightBlue,
  Colors.indigo,
  Colors.red,
  Colors.orange,
  Colors.blue,
  Colors.blueAccent,
];

class AccountName extends StatelessWidget {
  final SnAccount account;
  final TextStyle? style;
  final String? textOverride;
  final bool ignorePermissions;
  final bool hideVerificationMark;
  final bool hideOverlay;
  const AccountName({
    super.key,
    required this.account,
    this.style,
    this.textOverride,
    this.ignorePermissions = false,
    this.hideVerificationMark = false,
    this.hideOverlay = false,
  });

  Alignment _parseGradientDirection(String direction) {
    switch (direction) {
      case 'to right':
        return Alignment.centerLeft;
      case 'to left':
        return Alignment.centerRight;
      case 'to bottom':
        return Alignment.topCenter;
      case 'to top':
        return Alignment.bottomCenter;
      case 'to bottom right':
        return Alignment.topLeft;
      case 'to bottom left':
        return Alignment.topRight;
      case 'to top right':
        return Alignment.bottomLeft;
      case 'to top left':
        return Alignment.bottomRight;
      default:
        return Alignment.centerLeft;
    }
  }

  Alignment _parseGradientEnd(String direction) {
    switch (direction) {
      case 'to right':
        return Alignment.centerRight;
      case 'to left':
        return Alignment.centerLeft;
      case 'to bottom':
        return Alignment.bottomCenter;
      case 'to top':
        return Alignment.topCenter;
      case 'to bottom right':
        return Alignment.bottomRight;
      case 'to bottom left':
        return Alignment.bottomLeft;
      case 'to top right':
        return Alignment.topRight;
      case 'to top left':
        return Alignment.topLeft;
      default:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    var nameStyle = (style ?? TextStyle());

    // Apply username color based on membership tier and custom settings
    if (account.profile.usernameColor != null) {
      final usernameColor = account.profile.usernameColor!;
      final tier = account.perkSubscription?.identifier;

      // Check tier restrictions
      final canUseCustomColor =
          ignorePermissions ||
          switch (tier) {
            'solian.stellar.primary' =>
              usernameColor.type == 'plain' &&
                  kUsernamePlainColors.containsKey(usernameColor.value),
            'solian.stellar.nova' => usernameColor.type == 'plain',
            'solian.stellar.supernova' => true,
            _ => false,
          };

      if (canUseCustomColor) {
        if (usernameColor.type == 'plain') {
          // Plain color
          Color? color;
          if (kUsernamePlainColors.containsKey(usernameColor.value)) {
            color = kUsernamePlainColors[usernameColor.value];
          } else if (usernameColor.value != null) {
            // Try to parse hex color
            try {
              color = Color(
                int.parse(
                      usernameColor.value!.replaceFirst('#', ''),
                      radix: 16,
                    ) +
                    0xFF000000,
              );
            } catch (_) {
              // Invalid hex, ignore
            }
          }
          if (color != null) {
            nameStyle = nameStyle.copyWith(color: color);
          }
        } else if (usernameColor.type == 'gradient' &&
            usernameColor.colors != null &&
            usernameColor.colors!.isNotEmpty) {
          // Gradient - use ShaderMask for text gradient
          final colors = <Color>[];
          for (final colorStr in usernameColor.colors!) {
            Color? color;
            if (kUsernamePlainColors.containsKey(colorStr)) {
              color = kUsernamePlainColors[colorStr];
            } else {
              // Try to parse hex color
              try {
                color = Color(
                  int.parse(colorStr.replaceFirst('#', ''), radix: 16) +
                      0xFF000000,
                );
              } catch (_) {
                // Invalid hex, skip
                continue;
              }
            }
            if (color != null) {
              colors.add(color);
            }
          }

          if (colors.isNotEmpty) {
            final gradient = LinearGradient(
              colors: colors,
              begin: _parseGradientDirection(
                usernameColor.direction ?? 'to right',
              ),
              end: _parseGradientEnd(usernameColor.direction ?? 'to right'),
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                Flexible(
                  child: ShaderMask(
                    shaderCallback: (bounds) => gradient.createShader(bounds),
                    child: Text(
                      textOverride ?? account.nick,
                      style: nameStyle.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (account.perkSubscription != null)
                  StellarMembershipMark(
                    membership: account.perkSubscription!,
                    hideOverlay: hideOverlay,
                  ),
                if (account.profile.verification != null &&
                    !hideVerificationMark)
                  VerificationMark(
                    mark: account.profile.verification!,
                    hideOverlay: hideOverlay,
                  ),
                if (account.automatedId != null)
                  hideOverlay
                      ? Icon(
                          Symbols.smart_toy,
                          size: 16,
                          color: nameStyle.color,
                          fill: 1,
                        )
                      : Tooltip(
                          message: 'accountAutomated'.tr(),
                          child: Icon(
                            Symbols.smart_toy,
                            size: 16,
                            color: nameStyle.color,
                            fill: 1,
                          ),
                        ),
              ],
            );
          }
        }
      }
    } else if (account.perkSubscription != null) {
      // Default membership colors if no custom color is set
      nameStyle = nameStyle.copyWith(
        color: (switch (account.perkSubscription!.identifier) {
          'solian.stellar.primary' => Colors.blueAccent,
          'solian.stellar.nova' => Color.fromRGBO(57, 197, 187, 1),
          'solian.stellar.supernova' => Colors.amberAccent,
          _ => null,
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Flexible(
          child: Text(
            textOverride ?? account.nick,
            style: nameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (account.perkSubscription != null)
          StellarMembershipMark(
            membership: account.perkSubscription!,
            hideOverlay: hideOverlay,
          ),
        if (account.profile.verification != null)
          VerificationMark(
            mark: account.profile.verification!,
            hideOverlay: hideOverlay,
          ),
        if (account.automatedId != null)
          hideOverlay
              ? Icon(
                  Symbols.smart_toy,
                  size: 16,
                  color: nameStyle.color,
                  fill: 1,
                )
              : Tooltip(
                  message: 'accountAutomated'.tr(),
                  child: Icon(
                    Symbols.smart_toy,
                    size: 16,
                    color: nameStyle.color,
                    fill: 1,
                  ),
                ),
      ],
    );
  }
}

class VerificationMark extends StatelessWidget {
  final SnVerificationMark mark;
  final bool hideOverlay;
  const VerificationMark({
    super.key,
    required this.mark,
    this.hideOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      (kVerificationMarkIcons.length > mark.type && mark.type >= 0)
          ? kVerificationMarkIcons[mark.type]
          : Symbols.verified,
      size: 16,
      color: (kVerificationMarkColors.length > mark.type && mark.type >= 0)
          ? kVerificationMarkColors[mark.type]
          : Colors.blue,
      fill: 1,
    );

    return hideOverlay
        ? icon
        : Tooltip(
            richMessage: TextSpan(
              text: mark.title ?? 'No title',
              children: [
                TextSpan(text: '\n'),
                TextSpan(
                  text: mark.description ?? 'descriptionNone'.tr(),
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            child: icon,
          );
  }
}

class StellarMembershipMark extends StatelessWidget {
  final SnWalletSubscriptionRef membership;
  final bool hideOverlay;
  const StellarMembershipMark({
    super.key,
    required this.membership,
    this.hideOverlay = false,
  });

  String _getMembershipTierName(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return 'membershipTierStellar'.tr();
      case 'solian.stellar.nova':
        return 'membershipTierNova'.tr();
      case 'solian.stellar.supernova':
        return 'membershipTierSupernova'.tr();
      default:
        return 'membershipTierUnknown'.tr();
    }
  }

  Color _getMembershipTierColor(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return Colors.blue;
      case 'solian.stellar.nova':
        return Color.fromRGBO(57, 197, 187, 1);
      case 'solian.stellar.supernova':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!membership.isActive) return const SizedBox.shrink();

    final tierName = _getMembershipTierName(membership.identifier);
    final tierColor = _getMembershipTierColor(membership.identifier);
    final tierIcon = Symbols.kid_star;

    final icon = Icon(tierIcon, size: 16, color: tierColor, fill: 1);

    return hideOverlay
        ? icon
        : Tooltip(
            richMessage: TextSpan(
              text: 'stellarMembership'.tr(),
              children: [
                TextSpan(text: '\n'),
                TextSpan(
                  text: 'currentMembershipMember'.tr(args: [tierName]),
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            child: icon,
          );
  }
}

class VerificationStatusCard extends StatelessWidget {
  final SnVerificationMark mark;
  const VerificationStatusCard({super.key, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          (kVerificationMarkIcons.length > mark.type && mark.type >= 0)
              ? kVerificationMarkIcons[mark.type]
              : Symbols.verified,
          size: 32,
          color: (kVerificationMarkColors.length > mark.type && mark.type >= 0)
              ? kVerificationMarkColors[mark.type]
              : Colors.blue,
          fill: 1,
        ).alignment(Alignment.centerLeft),
        const Gap(8),
        Text(mark.title ?? 'No title').bold(),
        Text(mark.description ?? 'descriptionNone'.tr()),
        const Gap(6),
        Text(
          'Verified by\n${mark.verifiedBy ?? 'No one verified it'}',
        ).fontSize(11).opacity(0.8),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}

class AccountUnactivatedCard extends HookConsumerWidget {
  const AccountUnactivatedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Symbols.warning_amber_rounded,
            size: 40,
            fill: 1,
            color: Colors.amber,
          ),
          const Gap(4),
          Text('accountActivationAlert').tr().fontSize(16).bold(),
          Text('accountActivationAlertHint').tr(),
          const Gap(4),
          Text('accountActivationResendHint').tr().opacity(0.8),
          const Gap(16),
          FilledButton.icon(
            icon: const Icon(Symbols.email),
            label: Text('accountActivationResend').tr(),
            onPressed: () async {
              final client = ref.watch(apiClientProvider);
              try {
                showLoadingModal(context);
                await client.post('/pass/spells/activation/resend');
                showSnackBar("Activation magic spell has been resend");
              } catch (err) {
                showErrorAlert(err);
              } finally {
                if (context.mounted) hideLoadingModal(context);
              }
            },
          ).width(double.infinity),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}
