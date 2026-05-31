import 'package:cloud_firestore/cloud_firestore.dart';

class Materia {
  final String id;
  final String nombre;
  final String semestre;
  final int creditos;
  final double? notaFinal;

  const Materia({
    required this.id,
    required this.nombre,
    required this.semestre,
    required this.creditos,
    this.notaFinal,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'semestre': semestre,
      'creditos': creditos,
      if (notaFinal != null) 'notaFinal': notaFinal,
    };
  }

  factory Materia.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Materia(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      semestre: data['semestre'] ?? '',
      creditos: data['creditos'] ?? 0,
      notaFinal: data['notaFinal']?.toDouble(),
    );
  }
}