import 'package:archivageucb/pages/charger_fichier.dart';
import 'package:archivageucb/pages/enregistrement.dart';
import 'package:archivageucb/services/firebase/authentification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Authentification _auth = Authentification();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;

  Future<void> _traiterLentree() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      User? user = await _auth.seConnecter(
        _email.text.trim(),
        _password.text.trim(),
      );
      if (user != null && !user.emailVerified) {
        await _auth.seDeconnecter();
        if (mounted) {
          _showSnackBar('Votre adresse email n\'est pas encore vérifié');
        }
        return;
      }
      if (mounted && user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChargerFichier()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur : ${e.toString().split(']').last}');
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Se connecter'), elevation: 12),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                const Icon(Icons.account_balance, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Archive UCB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                _textField(_email, 'Email UCB', false),
                SizedBox(height: 16),
                _textField(_password, 'Mot de passe', true),
                SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _traiterLentree,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Se connecter'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => const Enregistrement(),
                      ),
                    );
                  },
                  child: const Text('Nouveau à l\'UCB ? Créez un compte ici'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String labelText,
    bool obcuredText,
  ) {
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
