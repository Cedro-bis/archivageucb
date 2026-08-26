import 'dart:io';
import 'package:archivageucb/pages/login_page.dart';
import 'package:archivageucb/services/firestore/archive_service.dart';
import 'package:flutter/material.dart';
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

  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    File? file = await _archiveService.selectionnerDocument();
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  Future<void> _submitArchive() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_selectedFile == null ||
        _titreController.text.isEmpty ||
        user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez joindre un document et remplir au moins le titre.',
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
        file: _selectedFile!,
        titre: _titreController.text.trim(),
        description: _descController.text.trim(),
        faculte: _faculteController.text.trim(),
        anneeAcademique: _anneeController.text.trim(),
        userId: user.uid, // Utilise l'ID Firebase réel de la session
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
        _faculteController.clear();
        _anneeController.clear();
        setState(() {
          _selectedFile = null;
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
        title: const Text('Archivage de Documents UCB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Résumé',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _faculteController,
                    decoration: const InputDecoration(
                      labelText: 'Faculté concernée',
                      border: OutlineInputBorder(),
                    ),
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
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(
                      _selectedFile == null
                          ? 'Choisir le fichier'
                          : 'Fichier sélectionné : ${_selectedFile!.path.split('/').last}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _submitArchive,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
