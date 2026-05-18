import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

/// Tipo de objeto decorativo/obstáculo no cenário.
enum TipoObjeto { mesa, buraco }

/// Mesa ou buraco posicionados no chão da fase.
///
/// - Mesa: bloqueia visualmente, não mata (só decoração/obstáculo)
/// - Buraco: mata ao tocar — detectado pelo [contemPonto]
///
/// Uso:
/// ```dart
/// final mesa   = ObjetoCenario.mesa(position: Vector2(x, topoChao));
/// final buraco = ObjetoCenario.buraco(position: Vector2(x, topoChao));
/// await add(mesa);
/// await add(buraco);
/// ```
class ObjetoCenario extends PositionComponent
    with HasGameReference<FlameGame> {
  ObjetoCenario._({
    required this.tipo,
    required Vector2 posicao,
  }) {
    anchor   = Anchor.bottomLeft;
    position = posicao;
  }

  /// Cria uma mesa posicionada com a base em [position].
  factory ObjetoCenario.mesa({required Vector2 position}) =>
      ObjetoCenario._(tipo: TipoObjeto.mesa, posicao: position);

  /// Cria um buraco posicionado com a base em [position].
  factory ObjetoCenario.buraco({required Vector2 position}) =>
      ObjetoCenario._(tipo: TipoObjeto.buraco, posicao: position);

  final TipoObjeto tipo;
  SpriteComponent? _sprite;

  // ─────────────────────────────────────────────
  // Tamanhos vindos de EscolaVisual
  // ─────────────────────────────────────────────

  double get _larguraAlvo => tipo == TipoObjeto.mesa
      ? EscolaVisual.larguraMesa
      : EscolaVisual.larguraBuraco;

  double get _alturaAlvo => tipo == TipoObjeto.mesa
      ? EscolaVisual.alturaMesa
      : EscolaVisual.alturaBuraco;

  String get _caminhoAsset => tipo == TipoObjeto.mesa
      ? EscolaVisual.mesa
      : EscolaVisual.buraco;

  int get _corFallback => tipo == TipoObjeto.mesa
      ? EscolaVisual.corMesaFallback
      : EscolaVisual.corBuracoFallback;

  // ─────────────────────────────────────────────
  // Carregamento
  // ─────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load(_caminhoAsset);

      // Mantém proporção original da imagem, limitando pela altura alvo
      final escala    = _alturaAlvo / image.height;
      final larguraFinal = image.width * escala;

      size = Vector2(larguraFinal, _alturaAlvo);

      _sprite = SpriteComponent(
        sprite: Sprite(image),
        size: size,
        anchor: Anchor.topLeft,
      )..paint.filterQuality = FilterQuality.none;

      await add(_sprite!);
    } catch (_) {
      // Sem imagem: usa tamanho fixo e desenha no render()
      size = Vector2(_larguraAlvo, _alturaAlvo);
    }
  }

  // ─────────────────────────────────────────────
  // Colisão — use o centro do jogador
  // ─────────────────────────────────────────────

  /// Retorna true se [ponto] (centro do jogador) está dentro deste objeto.
  /// Usa inflate para dar uma margem de detecção mais generosa.
  bool contemPonto(Vector2 ponto) {
    final margem = tipo == TipoObjeto.buraco ? 12.0 : 4.0;
    return toRect().inflate(margem).contains(ponto.toOffset());
  }

  // ─────────────────────────────────────────────
  // Render de fallback
  // ─────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    if (_sprite != null) return; // tem imagem, não precisa

    // Retângulo colorido de placeholder
    canvas.drawRect(
      size.toRect(),
      Paint()..color = Color(_corFallback),
    );

    // Label do tipo
    final tp = TextPainter(
      text: TextSpan(
        text: tipo == TipoObjeto.mesa ? '🪑 Mesa' : '🕳️ Buraco',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x);

    tp.paint(
      canvas,
      Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2),
    );

    // Borda vermelha no buraco para facilitar identificação
    if (tipo == TipoObjeto.buraco) {
      canvas.drawRect(
        size.toRect(),
        Paint()
          ..color = const Color(0xFFE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }
}
