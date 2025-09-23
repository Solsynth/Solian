import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/database/message.dart';
import 'package:styled_widget/styled_widget.dart';

class MessageIndicators extends StatelessWidget {
  final DateTime? editedAt;
  final MessageStatus? status;
  final bool isCurrentUser;
  final Color textColor;

  const MessageIndicators({
    super.key,
    this.editedAt,
    this.status,
    required this.isCurrentUser,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (editedAt != null)
          Text(
            'edited'.tr().toLowerCase(),
            style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
          ),
        if (isCurrentUser && status != null)
          _buildStatusIcon(
            context,
            status!,
            textColor.withOpacity(0.7),
          ).padding(bottom: 3),
      ],
    );
  }

  Widget _buildStatusIcon(
    BuildContext context,
    MessageStatus status,
    Color textColor,
  ) {
    switch (status) {
      case MessageStatus.pending:
        return Icon(Icons.access_time, size: 12, color: textColor);
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: textColor);
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
