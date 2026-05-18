import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/jogo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GameWidget(game: JogoCasa()));
}
