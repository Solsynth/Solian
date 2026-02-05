import 'package:flutter/material.dart';
import 'package:island/developers/developers/edit_bot.dart';

class NewBotScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  final bool isModal;
  const NewBotScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context) {
    return EditBotScreen(
      publisherName: publisherName,
      projectId: projectId,
      isModal: isModal,
    );
  }
}
