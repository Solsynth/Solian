import 'package:flutter/material.dart';

Widget buildEntry() {
  return const MinimalTextWidget();
}

class MinimalTextWidget extends StatefulWidget {
  const MinimalTextWidget({super.key});

  @override
  State<MinimalTextWidget> createState() => _MinimalTextWidgetState();
}

class _MinimalTextWidgetState extends State<MinimalTextWidget> {
  int _tapCount = 0;

  final List<String> _messages = ['Tap me!', 'Hello!', 'Thanks for tapping!'];

  String get _currentMessage => _messages[_tapCount % _messages.length];

  void _handleTap() {
    setState(() {
      _tapCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Text(
            _currentMessage,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
