import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/mundo/escola/desafio_config.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

/// Porta com sprite (porta.png) ou desenho provisório.
class Porta extends PositionComponent with HasGameReference<FlameGame> {
  Porta({required this.desafio, required this.onInteragir});

  final DesafioConfig desafio;
  final void Function(Porta porta) onInteragir;

  bool concluida = false;
  SpriteComponent? _sprite;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomCenter;
    await _montarSprite();
  }

  Future<void> _montarSprite() async {
    _sprite?.removeFromParent();
    final caminho = concluida
        ? EscolaVisual.portaConcluida
        : EscolaVisual.porta;

    try {
      final image = await game.images.load(caminho);
      final alturaAlvo = 320.0;
      final escala = alturaAlvo / image.height;
      size = Vector2(image.width * escala, alturaAlvo);

      _sprite = SpriteComponent(
        sprite: Sprite(image),
        size: size,
        anchor: Anchor.bottomCenter,
        position: Vector2(size.x / 2, size.y),
      )..paint.filterQuality = FilterQuality.none;
      add(_sprite!);
    } catch (_) {
      size = Vector2(80, 120);
      _sprite = null;
    }
  }

  Future<void> marcarConcluida() async {
    concluida = true;
    await _montarSprite();
  }

  bool contemJogador(Vector2 centroJogador) {
    return toRect().inflate(28).contains(centroJogador.toOffset());
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) return;

    final corPorta = concluida
        ? const Color(0xFF43A047)
        : const Color(0xFF5D4037);
    canvas.drawRect(size.toRect(), Paint()..color = corPorta);
    final tp = TextPainter(
      text: TextSpan(
        text: concluida ? 'OK' : '${desafio.porta}',
        style: const TextStyle(color: Colors.white, fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, size.y * 0.3));
  }
}
