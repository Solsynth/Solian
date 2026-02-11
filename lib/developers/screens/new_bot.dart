import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/developers/screens/edit_bot.dart';

@RoutePage()
class DeveloperBotNewScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  final bool isModal;
  const DeveloperBotNewScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context) {
    return DeveloperBotEditScreen(
      pubName: publisherName,
      projectId: projectId,
      isModal: isModal,
    );
  }
}
