import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class FunctionCallsSection extends HookWidget {
  const FunctionCallsSection({
    super.key,
    required this.isFinish,
    required this.isStreaming,
    required this.functionCallData,
  });

  final bool isFinish;
  final bool isStreaming;
  final String? functionCallData;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    var functionCallName =
        jsonDecode(functionCallData ?? '{}')?['name'] as String?;
    if (functionCallName?.isEmpty ?? true) functionCallName = 'unknown'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                child: Row(
                  children: [
                    Icon(
                      Symbols.code,
                      size: 14,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const Gap(4),
                    Expanded(
                      child: Text(
                        isFinish
                            ? 'thoughtFunctionCallFinish'.tr(args: [])
                            : 'thoughtFunctionCallBegin'.tr(args: []),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded.value
                          ? Symbols.expand_more
                          : Symbols.expand_less,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
              Visibility(visible: isExpanded.value, child: const Gap(4)),
              Visibility(
                visible: isExpanded.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        functionCallData!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
