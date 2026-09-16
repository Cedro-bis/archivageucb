import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ArchiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<PlatformFile?> selectionnerDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  }

  Future<void> uploadArchive({
    required PlatformFile file,
    required String titre,
    required String description,
    required String faculte,
    required String anneeAcademique,
    required String categorie, // Nouveauté : Catégorie du document
    required String userId,
  }) async {
    // 1. Nettoyer le nom du fichier
    String cleanFileName = file.name.replaceAll(RegExp(r'[^\w\.-]'), '_');
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    // 2. Nettoyer le nom de la catégorie pour créer un sous-dossier propre sur Supabase
    String cleanFolder = categorie
        .replaceAll(RegExp(r'[^\w\.-]'), '_')
        .toLowerCase();
    String path = '$cleanFolder/$fileName';

    // 3. Upload vers Supabase Storage dans le dossier de la catégorie
    if (kIsWeb || file.bytes != null) {
      await _supabase.storage
          .from('arhivageubc')
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: _getContentType(file.extension),
            ),
          );
    } else {
      await _supabase.storage
          .from('arhivageubc')
          .upload(path, Uri.file(file.path!).toFilePath());
    }

    // 4. Récupération de l'URL publique
    final String downloadUrl = _supabase.storage
        .from('arhivageubc')
        .getPublicUrl(path);

    // 5. Enregistrement des métadonnées dans Firestore
    await _firestore.collection('archives').add({
      'titre': titre,
      'description': description,
      'faculte': faculte,
      'anneeAcademique': anneeAcademique,
      'categorie': categorie, // Sauvegarde de la catégorie exacte
      'fileUrl': downloadUrl,
      'fileName': file.name,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
