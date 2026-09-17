import 'package:flutter/material.dart';

class MyAlertDialog extends StatelessWidget {
  final String message;
  const MyAlertDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(content: Text(message));
  }
}
