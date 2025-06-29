import 'package:flutter/material.dart';
import 'package:island/screens/developers/edit_app.dart';

class NewCustomAppScreen extends StatelessWidget {
  final String publisherName;
  const NewCustomAppScreen({super.key, required this.publisherName});

  @override
  Widget build(BuildContext context) {
    return EditAppScreen(publisherName: publisherName);
  }
}
