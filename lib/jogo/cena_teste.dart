import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/jogador/jogador.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/mundo/chao.dart';

/// Área de teste sem mapa: chão + personagem escolhido.
class CenaTeste extends Component with HasGameReference<FlameGame> {
  CenaTeste({required this.personagem});

  final Personagem personagem;

  @override
  Future<void> onLoad() async {
    final chao = Chao();
    await add(chao);

    await add(
      Jogador(
        caminhoSkin: personagem.caminhoSkin,
        chao: chao,
      ),
    );

    await add(
      TextComponent(
        text: 'ESC — voltar ao menu',
        position: Vector2(16, 16),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ),
    );
  }
}
