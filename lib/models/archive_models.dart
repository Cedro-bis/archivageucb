import 'package:cloud_firestore/cloud_firestore.dart';

class ArchiveModels {
  final String id;
  final String titre;
  final String description;
  final String faculte;
  final String anneeAcademique;
  final String fileUrl;
  final DateTime? chargeLe;
  final String chargePar;

  ArchiveModels({
    required this.id,
    required this.titre,
    required this.description,
    required this.faculte,
    required this.fileUrl,
    required this.anneeAcademique,
    this.chargeLe,
    required this.chargePar,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'faculte': faculte,
      'fileUrl': fileUrl,
      'anneeAcademique': anneeAcademique,
      'chargeLe': chargeLe != null
          ? Timestamp.fromDate(chargeLe!)
          : FieldValue.serverTimestamp(),
      'chargePar': chargePar,
    };
  }
}
