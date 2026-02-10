import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/developers/screens/edit_bot.dart';

@RoutePage()
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
