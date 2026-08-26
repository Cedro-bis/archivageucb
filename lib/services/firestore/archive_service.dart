import 'dart:io';

import 'package:archivageucb/models/archive_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ArchiveService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<File?> selectionnerDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<void> chargerFichier({
    required File file,
    required String titre,
    required String description,
    required String faculte,
    required String anneeAcademique,
    required String userId,
  }) async {
    try {
      final nomFichier = file.path.split(Platform.pathSeparator).last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${nomFichier.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}';
      Reference ref = _storage.ref().child('document/$fileName');

      UploadTask chargerTache = ref.putFile(file);
      TaskSnapshot snp = await chargerTache;
      String telechargerUrl = await snp.ref.getDownloadURL();

      DocumentReference docRef = _firestore.collection('archives').doc();

      ArchiveModels nouvelArchive = ArchiveModels(
        id: docRef.id,
        titre: titre,
        description: description,
        faculte: faculte,
        fileUrl: telechargerUrl,
        anneeAcademique: anneeAcademique,
        chargePar: userId,
      );
      await docRef.set(nouvelArchive.toMap());
    } catch (e) {
      rethrow;
    }
  }
}
