
import 'package:flutter/material.dart';
import 'package:island/screens/developers/edit_bot.dart';

class NewBotScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  const NewBotScreen({super.key, required this.publisherName, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return EditBotScreen(publisherName: publisherName, projectId: projectId);
  }
}
