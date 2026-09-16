import 'package:firebase_auth/firebase_auth.dart';

class Authentification {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<User?> seConnecter(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> creerUnCompte(String email, String password) async {
    try {
      UserCredential resultat = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await resultat.user!.sendEmailVerification();
      return resultat.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> seDeconnecter() async {
    await _auth.signOut();
  }
}
