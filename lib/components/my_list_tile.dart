import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyListTile extends StatelessWidget {
  final String title;
  IconData icon;
  void Function()? onTap;
  MyListTile({super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(title: Text(title), leading: Icon(icon)),
    );
  }
}
