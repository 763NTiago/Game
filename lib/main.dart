import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/jogo/jogo_casa.dart';

void main() {
  runApp(
    GameWidget(
      game: JogoCasa(),
    ),
  );
}
