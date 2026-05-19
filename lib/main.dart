import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/jogo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        // Força o GameWidget a se expandir por toda a tela disponível
        body: SizedBox.expand(child: GameWidget(game: JogoCasa())),
      ),
    ),
  );
}
