import 'package:firebase_auth/firebase_auth.dart';
import 'package:archivageucb/export_pages.dart';

class Profil extends StatelessWidget {
  const Profil({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = Authentification().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              width: 100,
              height: 100,
              child: Center(
                child: Text(
                  '${user?.email![0]}',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Email : ${user?.email ?? 'Non connecté'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Authentification().seDeconnecter();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Se déconnecter"),
            ),
          ],
        ),
      ),
    );
  }
}
