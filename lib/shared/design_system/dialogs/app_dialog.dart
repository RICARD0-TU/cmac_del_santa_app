import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({required this.title, required this.content, super.key});

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
