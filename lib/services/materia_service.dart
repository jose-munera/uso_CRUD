import 'package:uuid/uuid.dart';
import 'package:notas_app/models/materia.dart';

class MateriaService {
  final _uuid = const Uuid();

  // ── Lista con datos de ejemplo ──────────────
  final List<Materia> _materias = [
    Materia(
      id: '550e8400-e29b-41d4-a716-446655440001',
      nombre: 'Calculo Diferencial',
      semestre: '2025-1',
      creditos: 4,
    ),
    Materia(
      id: '550e8400-e29b-41d4-a716-446655440002',
      nombre: 'Programacion Movil',
      semestre: '2025-1',
      creditos: 3,
    ),
    Materia(
      id: '550e8400-e29b-41d4-a716-446655440003',
      nombre: 'Ingenieria de Software II',
      semestre: '2025-1',
      creditos: 3,
    ),
  ];

  // ── Listar ────────────────────────────────
  Future<List<Materia>> getMaterias() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_materias);
  }

  // ── Guardar ───────────────────────────────
  Future<void> agregarMateria({
    required String nombre,
    required String semestre,
    required int creditos,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final materia = Materia(
      id: _uuid.v4(),
      nombre: nombre,
      semestre: semestre,
      creditos: creditos,
    );
    _materias.add(materia);
  }

  // ── Eliminar ──────────────────────────────
  Future<void> eliminarMateria(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _materias.removeWhere((m) => m.id == id);
  }

  Future<void> editarMateria({
    required String id,
    required String nombre,
    required String semestre,
    required int creditos,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _materias.indexWhere((m) => m.id == id);
    if (index != -1) {
      _materias[index] = Materia(
        id: id,
        nombre: nombre,
        semestre: semestre,
        creditos: creditos,
      );
    }
  }
}
