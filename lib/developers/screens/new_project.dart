import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/developers/screens/edit_project.dart';

@RoutePage()
class DeveloperProjectNewScreen extends StatelessWidget {
  final String publisherName;
  const DeveloperProjectNewScreen({
    super.key,
    @PathParam("pubName") required this.publisherName,
  });

  @override
  Widget build(BuildContext context) {
    return DeveloperProjectEditScreen(pubName: publisherName);
  }
}
