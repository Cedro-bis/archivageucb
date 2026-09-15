import 'package:flutter/material.dart';

class MyTextFields extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obcuredText;
  const MyTextFields({
    super.key,
    required this.controller,
    required this.labelText,
    required this.obcuredText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      obscureText: obcuredText,
    );
  }
}
