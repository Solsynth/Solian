import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';

class AccountProfilePopupCard extends StatelessWidget {
  final Widget child;
  final Widget? header;

  const AccountProfilePopupCard({super.key, required this.child, this.header});

  @override
  Widget build(BuildContext context) {
    final width = math
        .min(MediaQuery.of(context).size.width - 80, 360)
        .toDouble();

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [if (header != null) header!, child],
        ),
      ),
    );
  }
}
