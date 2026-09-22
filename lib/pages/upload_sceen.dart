import 'package:archivageucb/export_pages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ArchiveService _archiveService = ArchiveService();
  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  final _faculteController = TextEditingController();
  final _anneeController = TextEditingController();

  // Liste des catégories exactes
  final List<String> _categories = [
    'Document administratif',
    'Documents académiques',
    'Documents financiers',
    'Livres universitaires',
    'Travaux et projets',
    'Document estudiantins',
  ];
  final List<String> _faculties = [
    'sciences agronomiques et environnement',
    'Sciences sociales',
    'Sciences et technologies',
    'Medecine',
    'Architecture et urbanisme',
    'Droit',
    'Economie et gestion',
    'Université',
  ];

  String? _selectedCategorie;
  String? _selectedFaculty;
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      PlatformFile? file = await _archiveService.selectionnerDocument();
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection : $e')),
        );
      }
    }
  }

  Future<void> _submitArchive() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_selectedFile == null ||
        _titreController.text.trim().isEmpty ||
        _selectedCategorie == null ||
        user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner un fichier, indiquer un titre et choisir une catégorie.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _archiveService.uploadArchive(
        file: _selectedFile!,
        titre: _titreController.text.trim(),
        description: _descController.text.trim(),
        faculte: _selectedFaculty!,
        anneeAcademique: _anneeController.text.trim(),
        categorie: _selectedCategorie!,
        userId: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document archivé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _titreController.clear();
        _descController.clear();
        _selectedFaculty = null;
        _anneeController.clear();
        setState(() {
          _selectedFile = null;
          _selectedCategorie = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'envoi : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivage de Documents UCB'),
        actions: [
          IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: 'Titre du document',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Liste déroulante des catégories
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategorie,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie du document',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((String cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategorie = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Résumé',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField(
                    initialValue: _selectedFaculty,
                    decoration: InputDecoration(
                      labelText: 'Faculté concernée',
                      border: OutlineInputBorder(),
                    ),
                    items: _faculties.map((String cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFaculty = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _anneeController,
                    decoration: const InputDecoration(
                      labelText: 'Année Académique (ex: 2025-2026)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: Icon(
                      _selectedFile == null
                          ? Icons.cloud_upload
                          : Icons.check_circle,
                      color: _selectedFile == null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      _selectedFile == null
                          ? 'Choisir le fichier'
                          : 'Fichier : ${_selectedFile!.name}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _selectedFile == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: _selectedFile == null
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: _selectedFile == null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _submitArchive,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
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
