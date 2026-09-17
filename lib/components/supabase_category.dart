import 'dart:io';

import 'package:archivageucb/components/my_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupabaseCategory extends StatefulWidget {
  final String categoryName;
  const SupabaseCategory({super.key, required this.categoryName});

  @override
  State<SupabaseCategory> createState() => _SupabaseCategoryState();
}

class _SupabaseCategoryState extends State<SupabaseCategory> {
  final _supabase = Supabase.instance.client;
  late Future<List<FileObject>> _filesFuture;
  late String _folderPath;

  @override
  void initState() {
    super.initState();
    _folderPath = widget.categoryName.replaceAll(RegExp(r'[^\w\.-]'), '');
    _filesFuture = _fetchFiles();
  }

  Future<List<FileObject>> _fetchFiles() async {
    final List<FileObject> files = await _supabase.storage
        .from('archivageubc')
        .list(path: _folderPath);

    return files
        .where((file) => file.name != '.emptyFolderPlaceholder')
        .toList();
  }

  Future<void> _downloadFile(String fileName) async {
    final String publicUrl = _supabase.storage
        .from('archivageubc')
        .getPublicUrl('$_folderPath/$fileName');

    final Uri uri = Uri.parse(publicUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      MyAlertDialog(message: "Impossible d'ouvrir le fichier : $publicUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder<List<FileObject>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur supabase : ${snapshot.error}'));
          }
          final files = snapshot.data ?? [];

          if (files.isEmpty) {
            return Center(
              child: Text('Liste vide', style: TextStyle(fontSize: 18)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(
                    file.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Taille : ${(file.metadata?['size'] ?? 0) ~/ 1024} KB',
                  ),
                  trailing: IconButton(
                    onPressed: () => _downloadFile((file.name)),
                    icon: Icon(Icons.download),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
