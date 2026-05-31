import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notas_app/services/storage_services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _notaMinimaController = TextEditingController();
  final TextEditingController _notaMaximaController = TextEditingController();
  double _notaMinima = 3.0;
  double _notaMaxima = 5.0;
  bool _notaMinimaError = false;
  bool _notaMaximaError = false;
  String _notaMinimaErrorMsg = '';
  String _notaMaximaErrorMsg = '';

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notaMinima = prefs.getDouble('notaMinima') ?? 3.0;
      _notaMaxima = prefs.getDouble('notaMaxima') ?? 5.0;
      _notaMinimaController.text = _notaMinima.toString();
      _notaMaximaController.text = _notaMaxima.toString();
    });
  }

  Future<void> _guardarNotaMinima(String value) async {
    final numero = double.tryParse(value);
    if (numero == null || numero <= 0) return;

    if (numero >= _notaMaxima) {
      setState(() {
        _notaMinimaError = true;
        _notaMinimaErrorMsg =
            '*Debe ser menor que la nota máxima ($_notaMaxima)';
      });
      return;
    }

    setState(() => _notaMinimaError = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('notaMinima', numero);
    final storage = StorageService();
    await storage.guardarUmbral(numero);
    setState(() => _notaMinima = numero);
  }

  Future<void> _guardarNotaMaxima(String value) async {
    final numero = double.tryParse(value);
    if (numero == null || numero <= 0) return;

    if (numero <= _notaMinima) {
      setState(() {
        _notaMaximaError = true;
        _notaMaximaErrorMsg =
            '*Debe ser mayor que la nota mínima ($_notaMinima)';
      });
      return;
    }

    setState(() => _notaMaximaError = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('notaMaxima', numero);
    setState(() => _notaMaxima = numero);
  }

  // ── InputFormatter reutilizable ────────────
  List<TextInputFormatter> get _inputFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          if (text.isEmpty) return newValue;
          // Solo un punto decimal
          if (text.indexOf('.') != text.lastIndexOf('.')) return oldValue;
          // Solo un decimal
          if (text.contains('.')) {
            final partes = text.split('.');
            if (partes[1].length > 1) return oldValue;
          }
          // No mayor a 100
          final numero = double.tryParse(text);
          if (numero != null && numero > 100) return oldValue;
          return newValue;
        }),
      ];

  @override
  void dispose() {
    _notaMinimaController.dispose();
    _notaMaximaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 198, 198, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 119, 225),
        elevation: 10,
        title: const Text(
          'Configuración ⚙️🪛',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Nota mínima ────────────────────────────
              const Text(
                'NOTA MÍNIMA PARA APROBAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B83B0),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notaMinimaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _inputFormatters,
                onChanged: _guardarNotaMinima,
                decoration: InputDecoration(
                  errorText: _notaMinimaError ? _notaMinimaErrorMsg : null,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F6FF),
                  labelText: 'Nota Mínima',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffix: const Text(
                    'PUNTOS',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6C4EF6)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C4EF6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF6C4EF6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Valor actual: $_notaMinima PUNTOS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C4EF6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Nota máxima ────────────────────────────
              const Text(
                'NOTA MÁXIMA ALCANZABLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF8B83B0),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notaMaximaController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: _inputFormatters,
                onChanged: _guardarNotaMaxima,
                decoration: InputDecoration(
                  errorText: _notaMaximaError ? _notaMaximaErrorMsg : null,
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F6FF),
                  labelText: 'Nota Máxima',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffix: const Text(
                    'PUNTOS',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6C4EF6)),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C4EF6),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF6C4EF6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Valor actual: $_notaMaxima PUNTOS',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C4EF6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}