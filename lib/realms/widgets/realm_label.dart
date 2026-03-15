import 'package:flutter/material.dart';
import 'package:island/core/utils/text.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class RealmLabel extends StatelessWidget {
  final SnRealmLabel label;
  const RealmLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: label.color.parseHexColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.name,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9),
      ),
    );
  }
}
