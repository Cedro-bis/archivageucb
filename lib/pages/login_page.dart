import 'package:archivageucb/export_pages.dart';
import 'package:archivageucb/pages/upload_sceen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
      if (user != null) {
        await user.reload();
        user = FirebaseAuth.instance.currentUser;
      }
      // if (!user!.emailVerified) {
      //   await _auth.seDeconnecter();
      //   if (mounted) {
      //     _showSnackBar('Votre adresse email n\'est pas encore vérifié');
      //   }
      //   return;
      // }
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        messageDerreurPourMail();
      }
      if (e.code == 'wrong-password') {
        erreurDeMotDePasse();
      }
      if (mounted) {
        _showSnackBar(
          'Echec de la connection : ${e.toString().split(']').last}',
        );
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void messageDerreurPourMail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text('Email incorrect')),
    );
  }

  void erreurDeMotDePasse() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text("Mot de pass incorrect")),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Se connecter'),
        elevation: 12,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: Provider.of<ThemeProvider>(context).changerLeTheme,
              icon: Icon(Icons.sunny),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Image.asset('lib/images/logo.png', height: 150, width: 150),
                const SizedBox(height: 16),
                Text(
                  'Archive UCB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 20),
                MyTextFields(
                  controller: _email,
                  labelText: 'E-mail',
                  obcuredText: false,
                ),
                SizedBox(height: 16),
                MyTextFields(
                  controller: _password,
                  labelText: 'Mot de passe',
                  obcuredText: true,
                ),
                SizedBox(height: 16),
                _isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.secondary,
                            ),
                            foregroundColor: WidgetStatePropertyAll(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: _traiterLentree,

                          child: const Text('Se connecter'),
                        ),
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
                  child: Text(
                    'Nouveau à l\'UCB ? Créez un compte ici',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
