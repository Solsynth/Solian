import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/auth/login_modal.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

class ResponseErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback onRetry;

  const ResponseErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Symbols.error_outline, size: 48),
        const Gap(4),
        if (error is DioException && error.response?.statusCode == 401)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              children: [
                Text(
                  'unauthorized'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF757575)),
                ).bold(),
                Text(
                  'unauthorizedHint'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF757575)),
                ),
              ],
            ),
          ).center()
        else if (error is DioException && error.response != null)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              error.response.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
          ).center()
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF757575)),
            ),
          ).center(),
        const Gap(8),
        TextButton(onPressed: onRetry, child: const Text('retry').tr()),
      ],
    );
  }
}

class ResponseLoadingWidget extends StatelessWidget {
  const ResponseLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ResponseUnauthorizedWidget extends StatelessWidget {
  const ResponseUnauthorizedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Symbols.error_outline, size: 48),
        const Gap(4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              Text(
                'unauthorized'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757575)),
              ).bold(),
              Text(
                'unauthorizedHint'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
              const Gap(8),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    builder: (context) => const LoginModal(),
                  );
                },
                icon: const Icon(Symbols.login),
                label: Text('login').tr(),
              ),
            ],
          ),
        ).center(),
      ],
    );
  }
}
