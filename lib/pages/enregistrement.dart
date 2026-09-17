import 'package:archivageucb/export_pages.dart';
import 'package:archivageucb/pages/verify_email_screen.dart';

class Enregistrement extends StatefulWidget {
  const Enregistrement({super.key});

  @override
  State<Enregistrement> createState() => _EnregistrementState();
}

class _EnregistrementState extends State<Enregistrement> {
  Authentification _auth = Authentification();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmerController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmation = _confirmerController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmation.isEmpty) {
      _showSnakeBar('Veuillez remplir tous les champs');
      return;
    }
    if (password != confirmation) {
      _showSnakeBar("Les mots de passe ne correspondent pas");
      return;
    }
    if (password.length < 6) {
      _showSnakeBar("Le mot de passe doit contenir au moins 6 caractères !");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (builder) =>
              VerifyEmailScreen(email: _emailController.toString()),
        ),
      );
    }
    try {
      await _auth.creerUnCompte(email, password);
      await _auth.seDeconnecter();

      if (mounted) {
        _showSuccessDialogue(email);
      }
    } catch (e) {
      if (mounted) {
        _showSnakeBar('Erreur ${e.toString().split(']').last}');
      }
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  void _boiteDeDialoguePourValider() {
    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        title: Text('Vérification envoyée'),
        content: Text(
          'Un e-mail a été envoyé. Cliquer sur le lien pour activer votre accès',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _handleRegister();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (builder) => const LoginPage()),
              );
            },
            child: const Text('Se connecter'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialogue(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(
            'Votre compte a été créé avec succès. Veuillez vérifier votre email ($email) pour confirmer votre inscription.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retour à la page précédente
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnakeBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte"), elevation: 12),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('lib/images/logo.png', width: 150, height: 150),
              SizedBox(height: 16),
              const Text(
                "Bienvenus sur le site officiel des archives de l'UCB.Pour profiter de nos services, Veuillez créer un compte",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 24),
              MyTextFields(
                controller: _emailController,
                labelText: 'Email de l\'UCB',
                obcuredText: false,
              ),
              SizedBox(height: 14),
              MyTextFields(
                controller: _passwordController,
                labelText: 'Mot de passe',
                obcuredText: true,
              ),
              SizedBox(height: 14),

              MyTextFields(
                controller: _confirmerController,
                labelText: 'Confirmer le mot de passe',
                obcuredText: true,
              ),
              SizedBox(height: 14),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondary,
                        ),
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      onPressed: _boiteDeDialoguePourValider,
                      child: const Text("Créer un compte"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
