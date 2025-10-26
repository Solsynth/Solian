import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:island/models/thought.dart';

class FunctionCallsSection extends StatelessWidget {
  const FunctionCallsSection({
    super.key,
    required this.isStreaming,
    required this.streamingFunctionCalls,
    this.thought,
  });

  final bool isStreaming;
  final List<String> streamingFunctionCalls;
  final SnThinkingThought? thought;

  bool get _hasFunctionCalls {
    if (isStreaming) {
      return streamingFunctionCalls.isNotEmpty;
    } else {
      return thought!.chunks.isNotEmpty &&
          thought!.chunks.any(
            (chunk) => chunk.type == ThinkingChunkType.functionCall,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasFunctionCalls) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.code,
                    size: 14,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const Gap(4),
                  Text(
                    'functionCalls'.tr(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              const Gap(4),
              if (isStreaming) ...[
                ...streamingFunctionCalls.map(
                  (call) => Container(
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
                      call,
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                ...thought!.chunks
                    .where(
                      (chunk) => chunk.type == ThinkingChunkType.functionCall,
                    )
                    .map(
                      (chunk) => Container(
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
                          JsonEncoder.withIndent('  ').convert(chunk.data),
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
