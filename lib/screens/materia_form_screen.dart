import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notas_app/services/materia_service.dart';
import 'package:notas_app/validators/form_validators.dart';
import 'package:notas_app/models/materia.dart';

class MateriaFormScreen extends StatefulWidget {
  final MateriaService service;
  final Materia? materia;

  const MateriaFormScreen({
    super.key,
    required this.service,
    this.materia, // ← null = crear, con valor = editar
  });

  @override
  State<MateriaFormScreen> createState() => _MateriaFormScreenState();
}

class _MateriaFormScreenState extends State<MateriaFormScreen> {
  // ── Llave global del formulario ────────────
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ────────────────────────────
  final _nombreCtrl = TextEditingController();
  final _semestreCtrl = TextEditingController();
  final _creditosCtrl = TextEditingController();

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.materia != null) {
      _nombreCtrl.text = widget.materia!.nombre;
      _semestreCtrl.text = widget.materia!.semestre;
      _creditosCtrl.text = widget.materia!.creditos.toString();
    }
  }

  // ── Guardar ────────────────────────────────
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    if (widget.materia == null) {
      // ── Modo crear ──
      await widget.service.agregarMateria(
        nombre: _nombreCtrl.text.trim(),
        semestre: _semestreCtrl.text.trim(),
        creditos: int.parse(_creditosCtrl.text.trim()),
      );
    } else {
      // ── Modo editar ──
      await widget.service.editarMateria(
        id: widget.materia!.id,
        nombre: _nombreCtrl.text.trim(),
        semestre: _semestreCtrl.text.trim(),
        creditos: int.parse(_creditosCtrl.text.trim()),
      );
    }

    setState(() => _guardando = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.materia == null
                ? 'Materia guardada ✓'
                : 'Materia actualizada ✓',
          ),
          backgroundColor: const Color(0xFF2ECC9A),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _semestreCtrl.dispose();
    _creditosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 198, 198, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 119, 225),
        elevation: 0,
        title: Text(
          widget.materia == null ? 'Nueva Materia ✏️' : 'Editar Materia ✏️',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey, // ← llave asignada al Form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATOS DE LA MATERIA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B83B0),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Campo nombre (obligatorio) ──
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _inputDecoration(
                    'Nombre',
                    'ej: Cálculo Diferencial',
                  ),
                  validator: FormValidators.nombreValido,
                ),
                const SizedBox(height: 16),

                // ── Campo semestre (longitud mínima) ──
                TextFormField(
                  controller: _semestreCtrl,
                  decoration: _inputDecoration('Semestre', 'ej: 2025-1'),
                  validator: FormValidators.semestreValido,
                ),
                const SizedBox(height: 16),

                // ── Campo créditos (expresión regular) ──
                TextFormField(
                  controller: _creditosCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Créditos', 'ej: 3'),
                  validator: FormValidators.creditosValido,
                ),
                const SizedBox(height: 28),

                // ── Botón guardar ──
                SizedBox(
                  width: double.infinity,
                  child: _guardando
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton(
                          onPressed: _guardar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF6C4EF6),
                            side: const BorderSide(
                              color: Color(0xFF6C4EF6),
                              width: 3,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: const Text(
                            'Guardar Materia',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Decoración reutilizable para los inputs ──
  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F6FF),
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C4EF6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
