import 'package:flutter/material.dart';
import 'package:notas_app/models/materia.dart';
import 'package:notas_app/services/materia_service.dart';
import 'package:notas_app/screens/materia_form_screen.dart';

class MateriaListScreen extends StatefulWidget {
  const MateriaListScreen({super.key});

  @override
  State<MateriaListScreen> createState() => _MateriaListScreenState();
}

class _MateriaListScreenState extends State<MateriaListScreen> {
  // ── Atributos ──────────────────────────────
  final MateriaService _service = MateriaService();
  List<Materia> _materias = [];
  List<Materia> _materiasFiltradas = [];
  final TextEditingController _buscarCtrl = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMaterias();
  }

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  // ── Cargar materias ────────────────────────
  Future<void> _cargarMaterias() async {
    setState(() => _cargando = true);
    final lista = await _service.getMaterias();
    setState(() {
      _materias = lista;
      _materiasFiltradas = lista;
      _cargando = false;
    });
  }

  // ── Eliminar materia ───────────────────────
  Future<void> _eliminarMateria(String id) async {
    setState(() => _cargando = true);
    await _service.eliminarMateria(id);
    await _cargarMaterias();
  }

  // ── Filtrar materias ───────────────────────
  void _filtrar(String query) {
    setState(() {
      _materiasFiltradas = _materias
          .where(
            (m) =>
                m.nombre.toLowerCase().contains(query.toLowerCase()) ||
                m.semestre.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 198, 198, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 119, 225),
        elevation: 0,
        title: const Text(
          'Mis Materias 📚',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C4EF6),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MateriaFormScreen(service: _service),
            ),
          );
          _cargarMaterias();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Buscador ──
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _buscarCtrl,
                    onChanged: _filtrar,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Buscar materia o semestre...',
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6C4EF6),
                      ),
                      suffixIcon: _buscarCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _buscarCtrl.clear();
                                _filtrar('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(99),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ── Lista ──
                Expanded(
                  child: _materiasFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🔍', style: TextStyle(fontSize: 50)),
                              const SizedBox(height: 12),
                              Text(
                                _materias.isEmpty
                                    ? 'No tienes materias aún'
                                    : 'Sin resultados para "${_buscarCtrl.text}"',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_materias.isEmpty)
                                const Text(
                                  'Toca el botón + para agregar una',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _materiasFiltradas.length,
                          itemBuilder: (context, index) {
                            final materia = _materiasFiltradas[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFF6C4EF6),
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  materia.nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${materia.semestre} · ${materia.creditos} créditos',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      'ID: ${materia.id}',
                                      style: const TextStyle(
                                        color: Colors.black38,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ── Botón editar ──
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF6C4EF6),
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MateriaFormScreen(
                                              service: _service,
                                              materia:
                                                  materia, // ← pasa la materia a editar
                                            ),
                                          ),
                                        );
                                        _cargarMaterias();
                                      },
                                    ),
                                    // ── Botón eliminar ──
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () async {
                                        final confirmar = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text(
                                              '¿Eliminar materia?',
                                            ),
                                            content: Text(
                                              '¿Estás seguro de eliminar "${materia.nombre}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text(
                                                  'Eliminar',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmar == true) {
                                          await _eliminarMateria(materia.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Materia eliminada ✓',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
