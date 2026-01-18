import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';

class DartMiniappDisplay extends StatelessWidget {
  final String package;
  final String sourceCode;

  const DartMiniappDisplay({
    super.key,
    required this.package,
    required this.sourceCode,
  });

  @override
  Widget build(BuildContext context) {
    return EvalWidget(
      packages: {
        package: {'main.dart': sourceCode},
      },
      library: 'package:$package/main.dart',
      function: 'buildEntry',
      args: [],
      assetPath: 'assets/$package/main.evc',
    );
  }
}
