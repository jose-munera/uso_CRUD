import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notas_app/firebase_options.dart';
import 'package:notas_app/screens/home_screen.dart';
import 'package:notas_app/screens/materia_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Notometro());
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