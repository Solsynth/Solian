import 'package:flutter/material.dart';

/// A simple loading indicator widget that can be used throughout the app
class LoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator
  final double size;

  /// The color of the loading indicator
  final Color? color;

  /// Creates a loading indicator
  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: color != null
            ? AlwaysStoppedAnimation<Color>(
                color!,
              )
            : null,
      ),
    );
  }
}
