import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notas_app/models/materia.dart';

class MateriaService {
  final _col = FirebaseFirestore.instance.collection('materias');

  // ── Listar ────────────────────────────────
  Stream<List<Materia>> getMaterias() {
    return _col.snapshots().map(
      (snap) => snap.docs.map((doc) => Materia.fromDoc(doc)).toList(),
    );
  }

  // ── Agregar ───────────────────────────────
  Future<void> agregarMateria({
    required String nombre,
    required String semestre,
    required int creditos,
    double? notaFinal,
  }) async {
    final data = {
      'nombre': nombre,
      'semestre': semestre,
      'creditos': creditos,
    };
    if (notaFinal != null) {
      data['notaFinal'] = notaFinal;
    }
    await _col.add(data);
  }

  // ── Editar ────────────────────────────────
  Future<void> editarMateria({
    required String id,
    required String nombre,
    required String semestre,
    required int creditos,
    double? notaFinal,
  }) async {
    final data = {
      'nombre': nombre,
      'semestre': semestre,
      'creditos': creditos,
    };
    if (notaFinal != null) {
      data['notaFinal'] = notaFinal;
    }
    await _col.doc(id).update(data);
  }

  // ── Eliminar ──────────────────────────────
  Future<void> eliminarMateria(String id) async {
    await _col.doc(id).delete();
  }

  // ── Guardar nota final ────────────────────
  Future<void> guardarNotaFinal(String id, double nota) async {
    await _col.doc(id).update({'notaFinal': nota});
  }
}