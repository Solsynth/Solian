import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/developers/screens/edit_project.dart';

@RoutePage()
class NewProjectScreen extends StatelessWidget {
  final String publisherName;
  const NewProjectScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context) {
    return EditProjectScreen(publisherName: publisherName);
  }
}
