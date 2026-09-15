import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ArchiveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Selection de fichier
  Future<PlatformFile?> selectionnerDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'xls'],
      withData: true, // Requis pour le Web
    );

    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  }

  // Upload vers Supabase Storage + Sauvegarde métadonnées dans Firestore
  Future<void> uploadArchive({
    required PlatformFile file,
    required String titre,
    required String description,
    required String faculte,
    required String anneeAcademique,
    required String userId,
  }) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    String path = 'documents/$fileName';

    // 1. Upload vers Supabase Storage (Compatible Web & Mobile)
    if (kIsWeb || file.bytes != null) {
      await _supabase.storage
          .from('archivageubc')
          .uploadBinary(
            path,
            file.bytes!,
            fileOptions: FileOptions(
              contentType: _getContentType(file.extension),
            ),
          );
    } else {
      await _supabase.storage
          .from('archives')
          .upload(path, Uri.file(file.path!).toFilePath());
    }

    // 2. Récupération de l'URL Publique du fichier stocké sur Supabase
    final String downloadUrl = _supabase.storage
        .from('archives')
        .getPublicUrl(path);

    // 3. Sauvegarde de la référence dans Cloud Firestore (Firebase)
    await _firestore.collection('archives').add({
      'titre': titre,
      'description': description,
      'faculte': faculte,
      'anneeAcademique': anneeAcademique,
      'fileUrl': downloadUrl,
      'fileName': file.name,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Helper pour le type de fichier
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
