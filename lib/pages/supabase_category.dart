import 'package:archivageucb/components/my_button_action.dart';
import 'package:archivageucb/export_pages.dart';
import 'package:archivageucb/pages/file_viewer_sreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SupabaseCategory extends StatefulWidget {
  final String categoryName;
  const SupabaseCategory({super.key, required this.categoryName});

  @override
  State<SupabaseCategory> createState() => _SupabaseCategoryState();
}

class _SupabaseCategoryState extends State<SupabaseCategory> {
  final _supabase = Supabase.instance.client;
  static const String _bucketName = 'arhivageubc';

  late String _folderPath;
  List<FileObject> _allFiles = [];
  List<FileObject> _filteredFiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Nettoyage du nom du dossier pour qu'il corresponde au sous-dossier Supabase
    _folderPath = widget.categoryName
        .replaceAll(RegExp(r'[^\w\.-]'), '_')
        .toLowerCase();

    _loadFiles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode : Charger la liste des fichiers depuis Supabase Storage
  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<FileObject> files = await _supabase.storage
          .from(_bucketName)
          .list(path: _folderPath);

      final cleanFiles = files
          .where((file) => file.name != '.emptyFolderPlaceholder')
          .toList();

      setState(() {
        _allFiles = cleanFiles;
        _filteredFiles = cleanFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Méthode : Filtrer la liste des fichiers selon la saisie de recherche
  void _filterFiles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFiles = _allFiles;
      } else {
        _filteredFiles = _allFiles
            .where(
              (file) => file.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  //  Méthode pour télécharger
  Future<void> _downloadFile(String fileName) async {
    try {
      final String fullFilePath = '$_folderPath/$fileName';

      // 1. Récupération de l'URL publique de téléchargement
      final String publicUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fullFilePath);

      // Ajouter le paramètre download pour forcer le navigateur à télécharger le fichier
      final Uri downloadUri = Uri.parse('$publicUrl?download=$fileName');

      debugPrint("URL de téléchargement : $downloadUri");

      // 2. Lancement du téléchargement via le navigateur
      if (await canLaunchUrl(downloadUri)) {
        await launchUrl(downloadUri, mode: LaunchMode.externalApplication);
        _showSnackBar("Téléchargement lancé !");
      } else {
        _showSnackBar(
          "Impossible de lancer le lien de téléchargement.",
          isError: true,
        );
      }
    } catch (e) {
      debugPrint("Erreur Téléchargement : $e");
      _showSnackBar("Erreur : $e", isError: true);
    }
  }

  // Méthode : Visualiser le fichier directement dans l'application (Fix URL 404)
  void _viewFile(String fileName) {
    // 1. Récupération de l'URL publique
    final String publicUrl = _supabase.storage
        .from(_bucketName)
        .getPublicUrl('$_folderPath/$fileName');

    final String ext = fileName.split('.').last.toLowerCase();

    // 2. Traitement spécifique selon le type de fichier
    final String viewerUrl = (ext == 'doc' || ext == 'docx')
        ? 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(publicUrl)}'
        : publicUrl;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FileViewerScreen(fileName: fileName, fileUrl: viewerUrl),
      ),
    );
  }

  // Méthode pour Modifier un fichier sur Supabase Storage

  Future<void> _renameFile(String oldFileName) async {
    final TextEditingController nameController = TextEditingController(
      text: oldFileName,
    );

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer le fichier'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nouveau nom de fichier',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != oldFileName) {
      try {
        final cleanNewName = newName.replaceAll(RegExp(r'[^\w\.-]'), '_');
        final String fromPath = '$_folderPath/$oldFileName';
        final String toPath = '$_folderPath/$cleanNewName';

        await _supabase.storage.from(_bucketName).move(fromPath, toPath);
        _showSnackBar('Fichier renommé avec succès !');
        _loadFiles();
      } catch (e) {
        _showSnackBar('Erreur lors du renommage : $e', isError: true);
      }
    }
  }

  // methode pour partager
  Future<void> _shareFile(String fileName) async {
    try {
      _showSnackBar(
        "Préparation du fichier pour le partage...",
        isError: false,
      );
      final String fullFilePath = '$_folderPath/$fileName';

      // 1. Téléchargement temporaire du fichier
      final Uint8List fileBytes = await _supabase.storage
          .from(_bucketName)
          .download(fullFilePath);

      if (kIsWeb) {
        // Sur Web, on partage l'URL publique
        final String publicUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(fullFilePath);
        await Share.share(
          'Voici le document "$fileName" de l\'UCB : $publicUrl',
        );
      } else {
        // Sur Android/iOS, on crée un fichier local et on l'envoie à l'API de partage natif
        final Directory tempDir = await getTemporaryDirectory();
        final File tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(fileBytes);

        // Ouverture du menu de partage natif (proposera WhatsApp, Gmail, Drive, etc.)
        await Share.shareXFiles(
          [XFile(tempFile.path)],
          text:
              'Document partagé depuis l\'application d\'archivage UCB : $fileName',
        );
      }
    } catch (e) {
      _showSnackBar("Erreur lors du partage : $e", isError: true);
    }
  }

  // Méthode : Supprimer définitivement un fichier
  Future<void> _deleteFile(String fileName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: Text('Voulez-vous vraiment supprimer "$fileName" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.storage.from(_bucketName).remove([
          '$_folderPath/$fileName',
        ]);

        _showSnackBar('Fichier supprimé avec succès.');
        _loadFiles();
      } catch (e) {
        _showSnackBar('Erreur lors de la suppression : $e', isError: true);
      }
    }
  }

  // Méthode : Obtenir l'icône appropriée selon l'extension du fichier
  Widget _getFileIcon(String fileName) {
    final String ext = fileName.split('.').last.toLowerCase();

    switch (ext) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description, color: Colors.blue, size: 32);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.green, size: 32);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart, color: Colors.teal, size: 32);
      default:
        return const Icon(
          Icons.insert_drive_file,
          color: Color(0xFF0D47A1),
          size: 32,
        );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: Column(
        children: [
          // Champ de recherche dynamique
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFiles,
              decoration: InputDecoration(
                hintText: 'Rechercher un fichier par nom...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterFiles('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Liste des fichiers
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : _errorMessage != null
                ? Center(
                    child: Text(
                      'Erreur : $_errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _filteredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun fichier trouvé.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadFiles,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filteredFiles.length,
                      itemBuilder: (context, index) {
                        final file = _filteredFiles[index];
                        final sizeKb = (file.metadata?['size'] ?? 0) ~/ 1024;

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            onTap: () => _viewFile(file.name),
                            leading: _getFileIcon(file.name),
                            title: Text(
                              file.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('Taille : $sizeKb KB'),

                            // Menu à 3 points verticaux
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (String value) {
                                switch (value) {
                                  case 'view':
                                    _viewFile(file.name);
                                    break;
                                  case 'download':
                                    _downloadFile(file.name);
                                    break;
                                  case 'share':
                                    _shareFile(file.name);
                                    break;
                                  case 'edit':
                                    _renameFile(file.name);
                                    break;
                                  case 'delete':
                                    _deleteFile(file.name);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.visibility,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Lire / Voir'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'download',
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('Télécharger'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share, color: Colors.teal),
                                      SizedBox(width: 8),
                                      Text('Partager (WhatsApp/Gmail)'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Supprimer'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: MyButtonAction(
        icon: Icons.add,
        onPressed: () => context.go('/upload'),
      ),
    );
  }
}
