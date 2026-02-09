import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/data/message.dart';
import 'package:styled_widget/styled_widget.dart';

class MessageIndicators extends StatelessWidget {
  final DateTime? editedAt;
  final MessageStatus? status;
  final bool isCurrentUser;
  final Color textColor;
  final EdgeInsets padding;

  const MessageIndicators({
    super.key,
    this.editedAt,
    this.status,
    required this.isCurrentUser,
    required this.textColor,
    this.padding = const EdgeInsets.only(left: 6),
  });

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (editedAt != null) {
      children.add(
        Text(
          'edited'.tr().toLowerCase(),
          style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
        ),
      );
    }

    if (isCurrentUser && status != null && status != MessageStatus.sent) {
      children.add(
        _buildStatusIcon(
          context,
          status!,
          textColor.withOpacity(0.7),
        ).padding(bottom: 2),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    MessageStatus status,
    Color textColor,
  ) {
    switch (status) {
      case MessageStatus.pending:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            padding: EdgeInsets.zero,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(textColor),
          ),
        ).padding(bottom: 2);
      case MessageStatus.sent:
        // Sent status is hidden
        return const SizedBox.shrink();
      case MessageStatus.failed:
        return Consumer(
          builder:
              (context, ref, _) => GestureDetector(
                onTap: () {
                  // This would need to be passed in or accessed differently
                  // For now, just show the error icon
                },
                child: const Icon(
                  Icons.error_outline,
                  size: 12,
                  color: Colors.red,
                ),
              ),
        );
    }
  }
}
