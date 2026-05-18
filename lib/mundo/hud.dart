import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

/// HUD fixo no topo da tela — corações (vidas) à esquerda, pontos à direita.
///
/// Chame [atualizarVidas] e [atualizarPontos] sempre que os valores mudarem.
///
/// O HUD usa [HudMarginComponent] internamente para ficar fixo mesmo com
/// a câmera seguindo o jogador.
class Hud extends Component with HasGameReference<FlameGame> {
  Hud({required int vidas, required int pontos})
    : _vidas = vidas,
      _pontos = pontos;

  int _vidas;
  int _pontos;

  // Componentes internos
  final List<_Coracao> _coracoes = [];
  late _PlacarPontos _placar;

  // ─────────────────────────────────────────────
  // Carregamento
  // ─────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    priority = 200; // acima de tudo

    await _montarFundoHud();
    await _montarCoracoes();
    await _montarPlacar();
  }

  Future<void> _montarFundoHud() async {
    // Faixa semitransparente no topo
    await add(
      _HudFixo(
        child: RectangleComponent(
          size: Vector2(game.size.x, 52),
          paint: Paint()..color = const Color(0xCC000000),
        ),
      ),
    );
  }

  Future<void> _montarCoracoes() async {
    const tamanho = EscolaVisual.tamanhoCoracao;
    const margem = 12.0;
    const espacamento = tamanho + 6;

    for (var i = 0; i < EscolaVisual.totalVidas; i++) {
      final coracao = _Coracao(
        indice: i,
        posicao: Vector2(margem + i * espacamento, 8),
        tamanho: tamanho,
        cheio: i < _vidas,
      );
      _coracoes.add(coracao);
      await add(coracao);
    }
  }

  Future<void> _montarPlacar() async {
    _placar = _PlacarPontos(
      pontos: _pontos,
      posicao: Vector2(game.size.x - 16, 8),
    );
    await add(_placar);
  }

  // ─────────────────────────────────────────────
  // API pública
  // ─────────────────────────────────────────────

  /// Atualiza os corações na tela.
  void atualizarVidas(int novasVidas) {
    _vidas = novasVidas.clamp(0, EscolaVisual.totalVidas);
    for (var i = 0; i < _coracoes.length; i++) {
      _coracoes[i].definirCheio(i < _vidas);
    }
  }

  /// Atualiza o placar de pontos na tela.
  void atualizarPontos(int novosPontos) {
    _pontos = novosPontos;
    _placar.atualizarPontos(novosPontos);
  }

  int get pontos => _pontos;
  int get vidas => _vidas;
}

// ─────────────────────────────────────────────────────────────────────────────
// Componente interno: coração individual
// ─────────────────────────────────────────────────────────────────────────────

class _Coracao extends _HudFixo {
  _Coracao({
    required this.indice,
    required Vector2 posicao,
    required this.tamanho,
    required bool cheio,
  }) : _cheio = cheio,
       super(child: null) {
    position = posicao;
  }

  final int indice;
  final double tamanho;
  bool _cheio;

  void definirCheio(bool valor) => _cheio = valor;

  @override
  void render(Canvas canvas) {
    final cor = _cheio
        ? const Color(0xFFE53935) // vermelho cheio
        : const Color(0x44E53935); // vermelho apagado

    // Coração desenhado com Path
    final paint = Paint()..color = cor;
    final path = _caminhoCoracao(tamanho);
    canvas.drawPath(path, paint);

    // Contorno branco
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white30
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  /// Gera o path de um coração dentro de uma caixa [t]×[t].
  static Path _caminhoCoracao(double t) {
    final p = Path();
    final cx = t / 2;
    final cy = t * 0.55;

    p.moveTo(cx, cy + t * 0.28);

    // Metade esquerda
    p.cubicTo(
      cx - t * 0.05,
      cy + t * 0.15,
      cx - t * 0.48,
      cy - t * 0.05,
      cx - t * 0.48,
      cy - t * 0.22,
    );
    p.arcToPoint(
      Offset(cx, cy - t * 0.08),
      radius: Radius.circular(t * 0.28),
      clockwise: false,
    );

    // Metade direita
    p.arcToPoint(
      Offset(cx + t * 0.48, cy - t * 0.22),
      radius: Radius.circular(t * 0.28),
      clockwise: false,
    );
    p.cubicTo(
      cx + t * 0.48,
      cy - t * 0.05,
      cx + t * 0.05,
      cy + t * 0.15,
      cx,
      cy + t * 0.28,
    );

    p.close();
    return p;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Componente interno: placar de pontos
// ─────────────────────────────────────────────────────────────────────────────

class _PlacarPontos extends _HudFixo {
  _PlacarPontos({required int pontos, required Vector2 posicao})
    : _pontos = pontos,
      super(child: null) {
    position = posicao;
    anchor = Anchor.topRight;
  }

  int _pontos;

  void atualizarPontos(int valor) => _pontos = valor;

  @override
  void render(Canvas canvas) {
    // Estrela
    final starPaint = Paint()..color = const Color(0xFFFFEB3B);
    _desenharEstrela(canvas, const Offset(16, 18), 14, starPaint);

    // Texto de pontos
    final tp = TextPainter(
      text: TextSpan(
        text: '  $_pontos pts',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    )..layout();

    // Desenha à esquerda do anchor (topRight)
    tp.paint(canvas, Offset(-tp.width, 8));
  }

  void _desenharEstrela(
    Canvas canvas,
    Offset centro,
    double raio,
    Paint paint,
  ) {
    const pontas = 5;
    final path = Path();
    for (var i = 0; i < pontas * 2; i++) {
      final r = i.isEven ? raio : raio * 0.45;
      final angulo = (i * 3.14159265 / pontas) - 3.14159265 / 2;
      final x = centro.dx + r * _cos(angulo);
      final y = centro.dy + r * _sin(angulo);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double a) => _mathCos(a);
  double _sin(double a) => _mathSin(a);
}

double _mathCos(double a) {
  // Evita importar dart:math no topo — inline simples
  // ignore: avoid_returning_null_for_void
  return (a == 0) ? 1.0 : _taylorCos(a);
}

double _mathSin(double a) => _taylorSin(a);

// Aproximação suficiente para desenho de estrela
double _taylorCos(double x) {
  x = x % (2 * 3.14159265358979);
  return 1 - x * x / 2 + x * x * x * x / 24 - x * x * x * x * x * x / 720;
}

double _taylorSin(double x) {
  x = x % (2 * 3.14159265358979);
  return x -
      x * x * x / 6 +
      x * x * x * x * x / 120 -
      x * x * x * x * x * x * x / 5040;
}

// ─────────────────────────────────────────────────────────────────────────────
// Base: componente fixo na tela (ignora câmera)
// ─────────────────────────────────────────────────────────────────────────────

/// Componente que fica fixo na tela mesmo com câmera se movendo.
/// Usa o sistema de coordenadas da viewport, não do mundo.
class _HudFixo extends PositionComponent with HasGameReference<FlameGame> {
  _HudFixo({required Component? child}) : _child = child;

  final Component? _child;

  @override
  Future<void> onLoad() async {
    if (_child != null) await add(_child!);
  }

  @override
  bool get isHud => true; // faz o Flame renderizar no espaço da câmera
}
