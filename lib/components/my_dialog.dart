import 'package:flutter/material.dart';

class MyDialog extends StatelessWidget {
  final String title;
  final String fileName;
  final int description;
  final String year;
  const MyDialog({
    super.key,
    required this.title,
    required this.fileName,
    required this.description,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      child: AlertDialog(
        title: Text(title),
        content: ListTile(
          title: Text(fileName),
          subtitle: Column(
            spacing: 4,
            children: [Text('$description'), Text(year)],
          ),
        ),
      ),
    );
  }
}
