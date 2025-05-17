import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_symbols_icons/symbols.dart';

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
        Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF757575)),
        ),
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
