import 'package:notas_app/models/nota.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  // ── Notas ──────────────────────────────────────────
  Future<void> guardarNotas(List<Nota> notas) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = notas.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notas', lista);
  }

  Future<List<Nota>> recuperarNotas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('notas') ?? [];
    return lista.map((n) => Nota.fromJson(jsonDecode(n))).toList();
  }

  // ── Resultado ──────────────────────────────────────
  Future<void> guardarResultado(double resultado) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('resultado', resultado);
  }

  Future<double> recuperarResultado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('resultado') ?? 0.0;
  }

  // ── Umbral ─────────────────────────────────────────
  Future<void> guardarUmbral(double umbral) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('umbral', umbral);
  }

  Future<double> recuperarUmbral() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('umbral') ?? 3.0;
  }
}