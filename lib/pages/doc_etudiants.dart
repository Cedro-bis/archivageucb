import 'package:flutter/material.dart';

class DocEtudiants extends StatelessWidget {
  const DocEtudiants({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Document des étudiants')),
      body: Center(child: Text('Documents Estudiantins')),
    );
  }
}
