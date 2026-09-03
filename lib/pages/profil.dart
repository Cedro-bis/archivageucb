import 'package:firebase_auth/firebase_auth.dart';
import 'package:archivageucb/export_pages.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    final User? user = Authentification().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Email : ${user?.email ?? 'Non connecté'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Authentification().seDeconnecter();
                Navigator.pushReplacementNamed(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ).settings.name!,
                );
              },
              child: const Text("Se déconnecter"),
            ),
          ],
        ),
      ),
    );
  }
}
