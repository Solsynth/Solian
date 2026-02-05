import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final bool monospace;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.label,
    this.value,
    required this.icon,
    this.monospace = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? valueWidget =
        value == null
            ? null
            : Text(
              value!,
              style:
                  monospace
                      ? GoogleFonts.robotoMono(fontSize: 14)
                      : Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            );

    if (onTap != null) valueWidget = InkWell(onTap: onTap, child: valueWidget);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const Gap(12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style:
                valueWidget == null
                    ? null
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
        ),
        if (valueWidget != null) const Gap(12),
        if (valueWidget != null) Expanded(flex: 3, child: valueWidget),
      ],
    );
  }
}
