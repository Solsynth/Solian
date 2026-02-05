import 'package:flutter/material.dart';
import 'package:island/developers/developers/edit_project.dart';

class NewProjectScreen extends StatelessWidget {
  final String publisherName;
  const NewProjectScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context) {
    return EditProjectScreen(publisherName: publisherName);
  }
}
