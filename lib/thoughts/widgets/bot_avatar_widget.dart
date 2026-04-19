import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A widget that displays a bot's avatar by fetching the user info
/// using the bot's username (botName).
class BotAvatarWidget extends ConsumerWidget {
  final String botName;
  final double radius;
  final bool showFallbackIcon;

  const BotAvatarWidget({
    super.key,
    required this.botName,
    this.radius = 16,
    this.showFallbackIcon = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountInfoProvider(botName));

    return accountAsync.when(
      data: (account) {
        if (account?.profile.picture != null) {
          return ProfilePictureWidget(
            file: account!.profile.picture,
            radius: radius,
            fallbackIcon: Symbols.smart_toy,
          );
        }
        // Account exists but no profile picture
        if (showFallbackIcon) {
          return _buildFallbackAvatar(context);
        }
        return const SizedBox.shrink();
      },
      loading: () => _buildLoadingAvatar(context),
      error: (error, stackTrace) {
        if (showFallbackIcon) {
          return _buildFallbackAvatar(context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Symbols.smart_toy,
        size: radius,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  Widget _buildLoadingAvatar(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(
        width: radius,
        height: radius,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// A widget that displays a bot's display name (nick) by fetching the user info.
/// Falls back to the botName if the account is not found.
class BotNameWidget extends ConsumerWidget {
  final String botName;
  final TextStyle? style;
  final String? fallbackTranslationKey;

  const BotNameWidget({
    super.key,
    required this.botName,
    this.style,
    this.fallbackTranslationKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(accountInfoProvider(botName));

    return accountAsync.when(
      data: (account) {
        final displayName =
            account?.nick ??
            (fallbackTranslationKey != null
                ? fallbackTranslationKey!.tr(
                    args: [botName.capitalizeEachWord()],
                  )
                : botName);
        return Text(displayName, style: style, overflow: TextOverflow.ellipsis);
      },
      loading: () => Text(
        fallbackTranslationKey != null
            ? fallbackTranslationKey!.tr(args: [botName.capitalizeEachWord()])
            : botName,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
      error: (err, stack) => Text(
        fallbackTranslationKey != null
            ? fallbackTranslationKey!.tr(args: [botName.capitalizeEachWord()])
            : botName,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
