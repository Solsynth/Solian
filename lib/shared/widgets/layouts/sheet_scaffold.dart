import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class SheetScaffold extends StatelessWidget {
  final Widget? title;
  final String? titleText;
  final List<Widget> actions;
  final Widget child;
  final double heightFactor;
  final double? height;
  final VoidCallback? onClose;
  const SheetScaffold({
    super.key,
    this.title,
    this.titleText,
    required this.child,
    this.actions = const [],
    this.heightFactor = 0.8,
    this.height,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    assert(title != null || titleText != null);

    var titleWidget =
        title ??
        Text(
          titleText!,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      constraints: BoxConstraints(
        maxHeight: height ?? MediaQuery.of(context).size.height * heightFactor,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
            child: Row(
              children: [
                Expanded(child: titleWidget),
                const Spacer(),
                ...actions,
                IconButton(
                  icon: Icon(
                    Symbols.close,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: () => onClose != null
                      ? onClose?.call()
                      : Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
