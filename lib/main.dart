import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_controller.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Aqui injetamos a lógica do jogo para o app todo acessar
        ChangeNotifierProvider(create: (_) => GameController()),
      ],
      child: const VoleiApp(),
    ),
  );
}

class VoleiApp extends StatelessWidget {
  const VoleiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vôlei do Multiverso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EA),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Essa será a primeira tela que o usuário vê
      home: const HomeScreen(),
    );
  }
}