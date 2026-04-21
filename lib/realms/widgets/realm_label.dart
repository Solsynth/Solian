import 'package:flutter/material.dart';
import 'package:island/core/utils/text.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class RealmLabelWidget extends StatelessWidget {
  final SnRealmLabel label;
  final double? fontSize;
  const RealmLabelWidget({super.key, required this.label, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: label.color?.parseHexColor() ?? Colors.indigo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontSize: fontSize ?? 9,
        ),
      ),
    );
  }
}
