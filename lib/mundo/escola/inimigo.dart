import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/mundo/chao.dart';

/// Inimigo simples: anda de um lado ao outro, inverte ao bater na parede.
/// Colide com o jogador via [contemPonto].
class Inimigo extends PositionComponent with HasGameReference<FlameGame> {
  Inimigo({
    required this.chao,
    required Vector2 posicaoInicial,
    this.velocidade = 80,
    this.limiteEsquerda = 0,
    double? limiteDireita,
  }) : _limiteDireita = limiteDireita {
    position = posicaoInicial;
  }

  final Chao chao;
  final double velocidade;
  final double limiteEsquerda;
  final double? _limiteDireita;

  double _direcao = 1; // 1 = direita, -1 = esquerda
  SpriteComponent? _sprite;
  late Image _image;

  // Animação simples: alterna entre frame 0 e 1 enquanto anda
  int _frameAtual = 0;
  double _tempoFrame = 0;
  static const _duracaoFrame = 0.18;
  static const _totalFrames = 6;
  static const _larguraFrame = 64.0;
  static const _alturaFrame = 64.0;

  bool vivo = true;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.bottomLeft;
    size = Vector2(_larguraFrame, _alturaFrame);

    try {
      _image = await game.images.load('mundo/escola/inimigo.png');
      _sprite = SpriteComponent(sprite: _frameSprite(0), size: size)
        ..paint.filterQuality = FilterQuality.none;
      add(_sprite!);
    } catch (_) {
      // sem imagem: desenha retângulo vermelho no render()
    }
  }

  Sprite _frameSprite(int indice) {
    return Sprite(
      _image,
      srcPosition: Vector2(indice * _larguraFrame, 0),
      srcSize: Vector2(_larguraFrame, _alturaFrame),
    );
  }

  @override
  void update(double dt) {
    if (!vivo) return;

    // Movimento horizontal
    position.x += velocidade * _direcao * dt;

    // Inverte direção nos limites
    final limDir = _limiteDireita ?? game.size.x;
    if (position.x <= limiteEsquerda) {
      position.x = limiteEsquerda;
      _direcao = 1;
    } else if (position.x + size.x >= limDir) {
      position.x = limDir - size.x;
      _direcao = -1;
    }

    // Mantém no chão
    final peNoChao = chao.topo - size.y;
    position.y = peNoChao;

    // Animação: frames 0-3 para andar
    _tempoFrame += dt;
    if (_tempoFrame >= _duracaoFrame) {
      _tempoFrame = 0;
      _frameAtual = (_frameAtual + 1) % 4; // só os 4 primeiros = andar
      _sprite?.sprite = _frameSprite(_frameAtual);
    }

    // Espelha sprite conforme direção
    _sprite?.scale.x = _direcao;
    if (_direcao == -1) {
      _sprite?.position.x = size.x; // corrige offset do flip
    } else {
      _sprite?.position.x = 0;
    }
  }

  /// Toca no jogador? Use o centro do jogador.
  bool contemPonto(Vector2 ponto) {
    return toRect().inflate(8).contains(ponto.toOffset());
  }

  /// Chama quando o jogador pula em cima — mostra frame "derrotado".
  void derrotar() {
    vivo = false;
    _sprite?.sprite = _frameSprite(5); // frame 5 = derrotado
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null) return; // tem imagem, não precisa desenhar

    final cor = vivo ? const Color(0xFFE53935) : const Color(0xFF9E9E9E);
    canvas.drawRect(size.toRect(), Paint()..color = cor);

    final tp = TextPainter(
      text: TextSpan(
        text: vivo ? '>:(' : 'x_x',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, size.y * 0.3));
  }
}
