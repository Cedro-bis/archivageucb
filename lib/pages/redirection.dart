import 'package:archivageucb/pages/home_page.dart';
import 'package:archivageucb/pages/login_page.dart';
import 'package:archivageucb/services/firebase/authentification.dart';
import 'package:flutter/material.dart';

class Redirection extends StatefulWidget {
  const Redirection({super.key});

  @override
  State<Redirection> createState() => _RedirectionState();
}

class _RedirectionState extends State<Redirection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Authentification().authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
