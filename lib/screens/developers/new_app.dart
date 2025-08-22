import 'package:flutter/material.dart';
import 'package:island/screens/developers/edit_app.dart';

class NewCustomAppScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  const NewCustomAppScreen({super.key, required this.publisherName, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return EditAppScreen(publisherName: publisherName, projectId: projectId);
  }
}
