import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notas_app/screens/result_screen.dart';
import 'package:notas_app/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notas_app/services/storage_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _filas = [];
  double _notaMinima = 3.0;

  Future<void> _cargarNotaMinima() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notaMinima = prefs.getDouble('notaMinima') ?? 3.0;
    });
  }

  Future<void> _cargarEstadoAnterior() async {
    final storage = StorageService();
    final notas = await storage.recuperarNotas();

    if (notas.isEmpty) {
      _agregarFila();
      return;
    }

    setState(() {
      _filas.clear();
      for (var nota in notas) {
        _filas.add({
          'nota': TextEditingController(text: nota.valor.toString()),
          'pct': TextEditingController(
            text: nota.porcentaje.toInt().toString(),
          ),
          'focus': FocusNode(),
          'notaError': false,
          'pctError': false,
          'filaError': false,
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarNotaMinima();
    _cargarEstadoAnterior();
  }

  void _agregarFila() {
    final focusNode = FocusNode();
    if (_filas.isNotEmpty) {
      setState(() {
        _filas[_filas.length - 1]['filaError'] = false;
        _filas[_filas.length - 1]['notaError'] = false;
        _filas[_filas.length - 1]['pctError'] = false;
      });
    }

    setState(() {
      _filas.add({
        'nota': TextEditingController(),
        'pct': TextEditingController(),
        'focus': focusNode,
        'notaError': false,
        'pctError': false,
        'filaError': false,
      });
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });
  }

  void _eliminarFila(int index) {
    setState(() => _filas.removeAt(index));
  }

  void _resetear() {
    setState(() {
      _filas.clear();
    });
    _agregarFila();
  }

  int _totalPorcentaje() {
    int total = 0;
    for (var fila in _filas) {
      total += int.tryParse((fila['pct'] as TextEditingController).text) ?? 0;
    }
    return total;
  }

  @override
  void dispose() {
    for (var fila in _filas) {
      (fila['nota'] as TextEditingController).dispose();
      (fila['pct'] as TextEditingController).dispose();
      (fila['focus'] as FocusNode).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 198, 198, 247),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 119, 225),
        elevation: 0,
        title: const Text(
          "NOTA ⚠️ : 'No Llorar' 🚫🥹💧",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          // ← botón de materias
          IconButton(
            icon: const Icon(Icons.menu_book_rounded, color: Colors.black),
            tooltip: 'Mis Materias',
            onPressed: () {
              Navigator.pushNamed(context, '/materias');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
              _cargarNotaMinima();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 239, 228, 247),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    SizedBox(
                      height: 120,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -10,
                            left: -15,
                            child: Image.asset(
                              'assets/images/logo_app.png',
                              width: 160,
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 155,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "NOTÓMETRO🌡️",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Sin miedo al Éxito ❗",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Porcentaje Acumulado',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_totalPorcentaje()}%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _totalPorcentaje() == 100
                                    ? const Color(0xFF2ECC9A)
                                    : _totalPorcentaje() > 100
                                    ? Colors.redAccent
                                    : const Color.fromARGB(255, 133, 9, 178),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: _totalPorcentaje() / 100,
                            minHeight: 20,
                            backgroundColor: const Color(0xFFF0EDFF),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _totalPorcentaje() == 100
                                  ? const Color(0xFF2ECC9A)
                                  : _totalPorcentaje() > 100
                                  ? Colors.redAccent
                                  : const Color(0xFF6C4EF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ── Filas dinámicas ──
                    ..._filas.asMap().entries.map((entry) {
                      int i = entry.key;
                      bool esUltima = i == _filas.length - 1;

                      final notaController =
                          entry.value['nota'] as TextEditingController;
                      final pctController =
                          entry.value['pct'] as TextEditingController;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Campo Nota
                                Expanded(
                                  child: TextFormField(
                                    controller: notaController,
                                    focusNode:
                                        entry.value['focus'] as FocusNode,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                      TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                      ) {
                                        final text = newValue.text;
                                        if (text.isEmpty) return newValue;
                                        if (text.indexOf('.') !=
                                            text.lastIndexOf('.')) {
                                          return oldValue;
                                        }
                                        if (text.contains('.')) {
                                          final partes = text.split('.');
                                          if (partes[1].length > 1) {
                                            return oldValue;
                                          }
                                        }
                                        final numero = double.tryParse(text);
                                        if (numero != null && numero > 100) {
                                          setState(
                                            () => _filas[i]['notaError'] = true,
                                          );
                                          return oldValue;
                                        }
                                        setState(() {
                                          _filas[i]['notaError'] = false;
                                        });
                                        return newValue;
                                      }),
                                    ],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF8F6FF),
                                      labelText: 'Nota',
                                      errorText:
                                          (_filas[i]['notaError'] as bool)
                                          ? '*máximo 100'
                                          : null,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      suffix: const Text(
                                        'puntos',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6C4EF6),
                                        ),
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
                                ),

                                const SizedBox(width: 8),

                                // Campo Porcentaje
                                Expanded(
                                  child: TextFormField(
                                    controller: pctController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        setState(() {});
                                      }
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[\d.]'),
                                      ),
                                      TextInputFormatter.withFunction((
                                        oldValue,
                                        newValue,
                                      ) {
                                        final text = newValue.text;
                                        if (text.isEmpty) return newValue;
                                        final numero = int.tryParse(text);
                                        if (numero != null && numero > 100) {
                                          setState(
                                            () => _filas[i]['pctError'] = true,
                                          );
                                          return oldValue;
                                        }
                                        if (text.contains('.')) {
                                          final partes = text.split('.');
                                          if (partes[1].length > 1) {
                                            return oldValue;
                                          }
                                        }
                                        setState(
                                          () => _filas[i]['pctError'] = false,
                                        );
                                        setState(() {});
                                        return newValue;
                                      }),
                                    ],
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: const Color(0xFFF8F6FF),
                                      labelText: 'Porcentaje',
                                      helperText:
                                          (_filas[i]['pctError'] as bool)
                                          ? '*máximo 100%'
                                          : (_filas[i]['filaError'] as bool)
                                          ? '*campos vacíos'
                                          : null,
                                      helperStyle: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                      suffix: const Text(
                                        '%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6C4EF6),
                                        ),
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
                                ),

                                const SizedBox(width: 4),

                                // Botón + o -
                                esUltima
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color:
                                              _totalPorcentaje() >= 100 ||
                                                  notaController.text.isEmpty ||
                                                  pctController.text.isEmpty
                                              ? Colors.grey
                                              : const Color.fromARGB(
                                                  255,
                                                  17,
                                                  221,
                                                  27,
                                                ),
                                          size: 28,
                                        ),
                                        onPressed: _totalPorcentaje() >= 100
                                            ? null
                                            : () {
                                                final nota =
                                                    notaController.text;
                                                final pct = pctController.text;
                                                if (nota.isEmpty ||
                                                    pct.isEmpty) {
                                                  setState(
                                                    () =>
                                                        _filas[i]['filaError'] =
                                                            true,
                                                  );
                                                } else {
                                                  setState(
                                                    () =>
                                                        _filas[i]['filaError'] =
                                                            false,
                                                  );
                                                  _agregarFila();
                                                }
                                              },
                                      )
                                    : IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.redAccent,
                                          size: 28,
                                        ),
                                        onPressed: () => _eliminarFila(i),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            if (_totalPorcentaje() > 100)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 10),
                child: Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'El total de porcentajes supera el 100%',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ],
                ),
              ),

            Center(
              child: GestureDetector(
                onTap: _resetear,
                child: Container(
                  width: 40,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 50, 12, 221),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Color.fromARGB(255, 36, 13, 208),
                    size: 35,
                  ),
                ),
              ),
            ),

            if (_totalPorcentaje() == 100)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            filas: _filas,
                            notaMinima: _notaMinima,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C4EF6),
                      side: const BorderSide(
                        color: Color(0xFF6C4EF6),
                        width: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: const Text(
                      'Calcular →',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
