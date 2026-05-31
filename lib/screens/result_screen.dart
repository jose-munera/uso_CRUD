import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:notas_app/widgets/humo_widget.dart';
import 'package:notas_app/widgets/lagrimas_widget.dart';
import 'package:notas_app/services/storage_services.dart';
import 'package:notas_app/models/nota.dart';

class ResultScreen extends StatefulWidget {
  final List<Map<String, dynamic>> filas;
  final double notaMinima;

  const ResultScreen({
    super.key,
    required this.filas,
    required this.notaMinima,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ConfettiController _confettiController;
  late AnimationController _coheteController;
  late Animation<Offset> _coheteAnimation;
  late AnimationController _casiController;
  late Animation<double> _casiAnimation;

  @override
  void initState() {
    super.initState();

    // ── Controller principal ──
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    // ── Controller del casi (shake) ──
    _casiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _casiAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _casiController, curve: Curves.elasticIn),
    );

    // ── Controller del cohete (espiral) ──
    _coheteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _coheteAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(1.5, -1.5)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(1.5, -1.5),
          end: const Offset(-1.5, -0.5),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-1.5, -0.5),
          end: const Offset(-0.5, 1.5),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.5, 1.5), end: Offset.zero),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(parent: _coheteController, curve: Curves.easeInOut),
    );

    // ── Confeti ──
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // ── Lanzar animaciones según resultado ──
    final tipo = _tipoResultado();

    if (tipo == 'Aprobado') {
      _controller.forward();
      _confettiController.play();
    } else if (tipo == 'Casi') {
      _controller.forward();
      _casiController.repeat(reverse: true);
    } else {
      _controller.forward();
      _coheteController.forward();
    }

    // ── Guardar estado al mostrar resultado ──
    _guardarEstado();
  }
  
  bool aprueba() {
  return _calcularPromedio() >= widget.notaMinima;
}

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _coheteController.dispose();
    _casiController.dispose();
    super.dispose();
  }

  Future<void> _guardarEstado() async {
    final storage = StorageService();

    final notas = widget.filas.map((fila) {
      final valor =
          double.tryParse((fila['nota'] as TextEditingController).text) ?? 0.0;
      final porcentaje =
          double.tryParse((fila['pct'] as TextEditingController).text) ?? 0.0;
      return Nota(valor: valor, porcentaje: porcentaje);
    }).toList();

    await storage.guardarNotas(notas);
    await storage.guardarResultado(_calcularPromedio());
    await storage.guardarUmbral(widget.notaMinima);
  }

  Path _drawStar(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    path.moveTo(w * 0.5, 0);
    path.lineTo(w * 0.61, h * 0.35);
    path.lineTo(w, h * 0.35);
    path.lineTo(w * 0.69, h * 0.57);
    path.lineTo(w * 0.79, h * 0.91);
    path.lineTo(w * 0.5, h * 0.70);
    path.lineTo(w * 0.21, h * 0.91);
    path.lineTo(w * 0.31, h * 0.57);
    path.lineTo(0, h * 0.35);
    path.lineTo(w * 0.39, h * 0.35);
    path.close();
    return path;
  }

  double _calcularPromedio() {
    double suma = 0;
    int totalPct = 0;
    for (var fila in widget.filas) {
      final nota =
          double.tryParse((fila['nota'] as TextEditingController).text) ?? 0;
      final pct =
          int.tryParse((fila['pct'] as TextEditingController).text) ?? 0;
      suma += nota * pct;
      totalPct += pct;
    }
    if (totalPct == 0) return 0;
    return suma / totalPct;
  }

  double _sumaConocida() {
    double suma = 0;
    for (var fila in widget.filas) {
      final nota = double.tryParse(
        (fila['nota'] as TextEditingController).text,
      );
      final pct =
          int.tryParse((fila['pct'] as TextEditingController).text) ?? 0;
      if (nota != null) {
        suma += nota * pct;
      }
    }
    return suma;
  }

  int _porcentajeFaltante() {
    int total = 0;
    for (var fila in widget.filas) {
      final nota = (fila['nota'] as TextEditingController).text;
      final pct =
          int.tryParse((fila['pct'] as TextEditingController).text) ?? 0;
      if (nota.isEmpty) {
        total += pct;
      }
    }
    return total;
  }

  double _calcularNotaMinimaNecesaria() {
    final pctFaltante = _porcentajeFaltante();
    if (pctFaltante == 0) return 0;
    final necesita = (widget.notaMinima * 100) - _sumaConocida();
    return necesita / pctFaltante;
  }

  bool _esImposible() {
    return _calcularNotaMinimaNecesaria() > 100;
  }

  String _tipoResultado() {
    final promedio = _calcularPromedio();
    final casiLimite = widget.notaMinima - (widget.notaMinima * 0.10);
    if (promedio >= widget.notaMinima) {
      return 'Aprobado';
    } else if (promedio >= casiLimite) {
      return 'Casi';
    } else {
      return 'Reprobado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = _tipoResultado();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 151, 119, 225),
        elevation: 0,
        title: const Text(
          '\tRESULTADOS 🥵 📊',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 198, 198, 247),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          margin: const EdgeInsets.only(
            top: 70,
            left: 24,
            right: 24,
            bottom: 80,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 24, 22, 62),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // ── Lágrimas (solo Casi) ──
                if (tipo == 'Casi')
                  const Positioned.fill(child: LagrimasWidget()),

                // ── Humo (solo Reprobado) ──
                if (tipo == 'Reprobado')
                  const Positioned.fill(child: HumoWidget()),

                // ── Confeti estrellas (solo Aprobado) ──
                if (tipo == 'Aprobado')
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.1,
                      numberOfParticles: 100,
                      gravity: 0.3,
                      createParticlePath: _drawStar,
                      colors: const [
                        Color(0xFF6C4EF6),
                        Color(0xFF2ECC9A),
                        Colors.amber,
                        Colors.white,
                      ],
                    ),
                  ),

                // ── Contenido con scroll ──
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: 24,
                    right: 24,
                    bottom: 80,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ── Emoji con animaciones ──
                      SlideTransition(
                        position: tipo == 'Reprobado'
                            ? _coheteAnimation
                            : const AlwaysStoppedAnimation(Offset.zero),
                        child: RotationTransition(
                          turns: tipo == 'Reprobado'
                              ? _coheteController
                              : tipo == 'Casi'
                              ? _casiAnimation
                              : const AlwaysStoppedAnimation(0),
                          child: ScaleTransition(
                            scale: _animation,
                            child: Text(
                              tipo == 'Aprobado'
                                  ? '🌟'
                                  : tipo == 'Casi'
                                  ? '😭'
                                  : '🚀',
                              style: const TextStyle(fontSize: 70),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        tipo == 'Aprobado'
                            ? 'Lo Lograste'
                            : tipo == 'Casi'
                            ? '¡Tan Cerca y Tan Lejos!'
                            : 'Houston, Tenemos un Problema',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: tipo == 'Aprobado'
                              ? const Color(0xFF2ECC9A)
                              : tipo == 'Casi'
                              ? const Color(0xFFFFB347)
                              : Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        tipo == 'Aprobado'
                            ? 'Tus Padres Pueden Estar Orgullosos 🏆'
                            : tipo == 'Casi'
                            ? 'Casi no es Suficiente... Pero Estuvo Cerca 😬'
                            : 'No Fue Hoy... Pero Mañana Sí 💪',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 253, 237),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _calcularPromedio().toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C4EF6),
                          ),
                        ),
                      ),

                      // ── Notas faltantes ──
                      if (_porcentajeFaltante() > 0 && !aprueba())
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _esImposible()
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : const Color(0xFFF0EDFF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _esImposible()
                                      ? '😔 Reprobado definitivamente'
                                      : '🎯 Para aprobar necesitas:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _esImposible()
                                        ? Colors.redAccent
                                        : const Color(0xFF6C4EF6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!_esImposible())
                                  Text(
                                    'Mínimo ${_calcularNotaMinimaNecesaria().toStringAsFixed(1)} pts en tus evaluaciones faltantes',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (_esImposible())
                                  const Text(
                                    'Aunque saques 100 en las evaluaciones faltantes, no es suficiente para pasar.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Botón volver ──
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6C4EF6),
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.replay_rounded,
                          color: Color(0xFF6C4EF6),
                          size: 25,
                        ),
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
}