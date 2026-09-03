import 'dart:io';

import 'package:archivageucb/export_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChargerFichier extends StatefulWidget {
  const ChargerFichier({super.key});

  @override
  State<ChargerFichier> createState() => _ChargerFichierState();
}

class _ChargerFichierState extends State<ChargerFichier> {
  final ArchiveService _archiveService = ArchiveService();
  final Authentification _auth = Authentification();
  final _titreFichier = TextEditingController();
  final _description = TextEditingController();
  final _faculte = TextEditingController();
  final _annee = TextEditingController();

  File? _selectionFichier;
  bool _isLoading = false;

  Future<void> _capturerFichier() async {
    File? file = await _archiveService.selectionnerDocument();
    if (file != null) {
      setState(() {
        _selectionFichier = file;
      });
    }
  }

  // Méthode pour séléctionner un fichier
  Future<void> _selectionnerFichier() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_selectionFichier == null ||
        _titreFichier.text.isEmpty ||
        user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: const Text(
            "Veuillez sélectionner un document et lui donner un titre",
          ),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      await _archiveService.chargerFichier(
        file: _selectionFichier!,
        titre: _titreFichier.text.trim(),
        description: _description.text.trim(),
        faculte: _faculte.text.trim(),
        anneeAcademique: _annee.text.trim(),
        userId: user.uid,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document archivé avec succès!!!'),
            backgroundColor: Colors.green,
          ),
        );
        _titreFichier.clear();
        _description.clear();
        _faculte.clear();
        _annee.clear();
        setState(() {
          _selectionFichier = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur survenu lors du chargement du fichier ${e}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archivage UCB"),
        elevation: 12,
        actions: [
          IconButton(
            onPressed: () async {
              await _auth.seDeconnecter();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (builder) => const LoginPage()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: const CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Archiver un document"),
                  SizedBox(height: 16),
                  TextField(
                    controller: _titreFichier,
                    decoration: InputDecoration(
                      labelText: "Titre dudocument",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: _description,
                    decoration: InputDecoration(
                      labelText: "Description du document",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: _faculte,
                    decoration: InputDecoration(
                      labelText: "Faculté concerné",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 14),
                  TextField(
                    controller: _titreFichier,
                    decoration: InputDecoration(
                      labelText: "Année académique (ex: 2024-2025)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _capturerFichier,
                    label: Text(
                      _selectionFichier == null
                          ? 'Choisir un fichier'
                          : 'Fichier séléctionné ${_selectionFichier!.path.split('/').last}',
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _selectionnerFichier,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.only(bottom: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Enregistrer et Archiver',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
