import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/developers/screens/edit_app.dart';

@RoutePage()
class DeveloperAppNewScreen extends StatelessWidget {
  final String publisherName;
  final String projectId;
  final bool isModal;
  const DeveloperAppNewScreen({
    super.key,
    required this.publisherName,
    required this.projectId,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context) {
    return DeveloperAppEditScreen(
      pubName: publisherName,
      projectId: projectId,
      isModal: isModal,
    );
  }
}
