import 'package:flutter/material.dart';

class MyButtonAction extends StatelessWidget {
  IconData icon;
  void Function()? onPressed;
  MyButtonAction({super.key, required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
    );
  }
}
