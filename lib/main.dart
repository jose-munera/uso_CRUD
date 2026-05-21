import 'package:flutter/material.dart';
import 'package:notas_app/screens/home_screen.dart';
import 'package:notas_app/screens/materia_list_screen.dart';

void main() {
  runApp(Notometro());
}

class Notometro extends StatelessWidget {
  const Notometro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/materias': (context) => const MateriaListScreen(),
      },
    );
  }
}