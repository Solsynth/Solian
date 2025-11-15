import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:styled_widget/styled_widget.dart';

class FunctionCallsSection extends HookWidget {
  const FunctionCallsSection({
    super.key,
    required this.isFinish,
    required this.isStreaming,
    this.callData,
    this.resultData,
  });

  final bool isFinish;
  final bool isStreaming;
  final String? callData;
  final String? resultData;

  @override
  Widget build(BuildContext context) {
    String functionCallName;
    if (callData != null) {
      final parsed = jsonDecode(callData!) as Map;
      functionCallName = (parsed['name'] as String?) ?? 'unknown'.tr();
    } else {
      functionCallName = 'unknown'.tr();
    }
    if (functionCallName.isEmpty) functionCallName = 'unknown'.tr();

    final showSpinner = isStreaming && !isFinish;

    final isExpanded = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 8),
          minTileHeight: 24,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          collapsedBackgroundColor:
              Theme.of(context).colorScheme.tertiaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          trailing: SizedBox(
            width: 30, // Specify desired width
            height: 30, // Specify desired height
            child: Icon(
              isExpanded.value
                  ? Icons.keyboard_arrow_down
                  : Icons.keyboard_arrow_up,
              size: 16,
              color:
                  isExpanded.value
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.tertiaryFixedDim,
            ),
          ),
          showTrailingIcon: !showSpinner,
          title: Row(
            spacing: 8,
            children: [
              Icon(
                Symbols.hardware,
                size: 16,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              Expanded(
                child: Text(
                  'thoughtFunctionCall'.tr(args: [functionCallName]),
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
              if (showSpinner) ...[
                AnimateWidgetExtensions(
                      Text(
                        'Calling',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                    .animate(
                      autoPlay: true,
                      onPlay: (c) => c.repeat(reverse: true),
                    )
                    .fade(duration: 1000.ms, begin: 0, end: 1),
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    padding: EdgeInsets.all(3),
                  ),
                ).padding(right: 8),
              ],
            ],
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          children: [
            if (callData != null)
              _buildBlock(context, false, functionCallName, callData!),
            if (resultData != null) ...[
              if (callData != null && resultData != null) const Gap(8),
              _buildBlock(context, true, functionCallName, resultData!),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildBlock(
    BuildContext context,
    bool isResult,
    String name,
    String data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(
              isResult ? Symbols.check : Symbols.play_arrow_rounded,
              size: 16,
              fill: 1,
            ),
            Text(
              isResult
                  ? "thoughtFunctionCallFinish".tr(args: [name])
                  : "thoughtFunctionCallBegin".tr(args: [name]),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const Gap(4),
        if (isResult)
          Opacity(
            opacity: 0.8,
            child: Row(
              spacing: 8,
              children: [
                Icon(Symbols.update, size: 16),
                Expanded(
                  child: Text(
                    'Generated ${utf8.encode(data).length} bytes',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                  child: IconButton(
                    iconSize: 16,
                    icon: const Icon(Symbols.content_copy),
                    onPressed:
                        () => Clipboard.setData(ClipboardData(text: data)),
                    tooltip: 'Copy response',
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SelectableText(
              data,
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
