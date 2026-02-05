import 'package:flutter/material.dart';
import 'package:island/developers/developers/edit_app.dart';

class NewCustomAppScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  final bool isModal;
  const NewCustomAppScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context) {
    return EditAppScreen(
      publisherName: publisherName,
      projectId: projectId,
      isModal: isModal,
    );
  }
}
