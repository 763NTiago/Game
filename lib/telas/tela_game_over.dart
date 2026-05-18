import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tela de Game Over — aparece ao zerar as vidas.
///
/// Mostra pontuação final, animação de corações caindo e
/// dois botões: tentar de novo e voltar ao menu.
///
/// Uso no [jogo_casa.dart]:
/// ```dart
/// await add(TelaGameOver(
///   pontos: _pontos,
///   onReiniciar: () => iniciarJogo(personagem),
///   onMenu: () => mostrarMenu(),
/// ));
/// ```
class TelaGameOver extends PositionComponent
    with HasGameReference<FlameGame>, KeyboardHandler, TapCallbacks {
  TelaGameOver({
    required this.pontos,
    required this.onReiniciar,
    required this.onMenu,
  });

  final int pontos;
  final VoidCallback onReiniciar;
  final VoidCallback onMenu;

  // Animação
  double _tempo = 0;
  final List<_CoracaoParticula> _particulas = [];
  final _rng = Random();

  // Botões
  late Rect _retBtnReiniciar;
  late Rect _retBtnMenu;
  bool _btnReiniciarHover = false;
  bool _btnMenuHover      = false;

  // Entrada bloqueada por um instante para evitar clique acidental
  bool _entradaAtiva = false;

  @override
  Future<void> onLoad() async {
    priority = 999;
    size     = game.size;
    position = Vector2.zero();
    anchor   = Anchor.topLeft;

    // Libera entrada após 1 segundo
    Future.delayed(const Duration(seconds: 1), () => _entradaAtiva = true);

    _calcularBotoes();
    _gerarParticulas();
  }

  void _calcularBotoes() {
    final cx = size.x / 2;
    final cy = size.y / 2;

    const largBtn  = 240.0;
    const altBtn   =  52.0;
    const espacamento = 20.0;

    _retBtnReiniciar = Rect.fromCenter(
      center: Offset(cx, cy + 80),
      width: largBtn,
      height: altBtn,
    );
    _retBtnMenu = Rect.fromCenter(
      center: Offset(cx, cy + 80 + altBtn + espacamento),
      width: largBtn,
      height: altBtn,
    );
  }

  void _gerarParticulas() {
    for (var i = 0; i < 18; i++) {
      _particulas.add(
        _CoracaoParticula(
          x:       _rng.nextDouble() * size.x,
          y:       -20 - _rng.nextDouble() * 200,
          velY:    40 + _rng.nextDouble() * 60,
          velX:    (_rng.nextDouble() - 0.5) * 30,
          tamanho: 16 + _rng.nextDouble() * 20,
          delay:   _rng.nextDouble() * 2,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;

    for (final p in _particulas) {
      p.atualizar(dt, size.y);
    }
  }

  // ─────────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final cx = w / 2;
    final cy = h / 2;

    // Fundo escuro semitransparente
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xDD1A0000),
    );

    // Partículas de coração
    for (final p in _particulas) {
      p.desenhar(canvas);
    }

    // Painel central
    final painelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 420, height: 340),
      const Radius.circular(20),
    );
    canvas.drawRRect(painelRect, Paint()..color = const Color(0xFF1A0A0A));
    canvas.drawRRect(
      painelRect,
      Paint()
        ..color = const Color(0xFFE53935)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Título "Game Over"
    final escalaTitle = 1.0 + sin(_tempo * 2) * 0.03; // pulsa levemente
    canvas.save();
    canvas.translate(cx, cy - 110);
    canvas.scale(escalaTitle, escalaTitle);
    _desenharTexto(
      canvas,
      'Game Over! 😢',
      const TextStyle(
        color: Color(0xFFE53935),
        fontSize: 34,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 8)],
      ),
      anchor: Offset.zero,
      alinhamento: TextAlign.center,
      larguraMax: 360,
    );
    canvas.restore();

    // Pontuação
    _desenharTexto(
      canvas,
      'Você fez\n$pontos pontos! ⭐',
      const TextStyle(
        color: Color(0xFFFFEB3B),
        fontSize: 26,
        height: 1.4,
        shadows: [Shadow(color: Colors.black, blurRadius: 6)],
      ),
      anchor: Offset(cx, cy - 40),
      alinhamento: TextAlign.center,
      larguraMax: 340,
    );

    // Botão Tentar de novo
    _desenharBotao(
      canvas,
      rect: _retBtnReiniciar,
      texto: '🔄  Tentar de novo',
      hover: _btnReiniciarHover,
      corFundo: const Color(0xFF43A047),
      corHover: const Color(0xFF66BB6A),
    );

    // Botão Menu
    _desenharBotao(
      canvas,
      rect: _retBtnMenu,
      texto: '🏠  Voltar ao menu',
      hover: _btnMenuHover,
      corFundo: const Color(0xFF1565C0),
      corHover: const Color(0xFF1976D2),
    );

    // Dica de teclado
    _desenharTexto(
      canvas,
      'R — reiniciar   |   ESC — menu',
      const TextStyle(color: Colors.white38, fontSize: 13),
      anchor: Offset(cx, size.y - 28),
      alinhamento: TextAlign.center,
      larguraMax: 360,
    );
  }

  void _desenharBotao(
    Canvas canvas, {
    required Rect rect,
    required String texto,
    required bool hover,
    required Color corFundo,
    required Color corHover,
  }) {
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rr, Paint()..color = hover ? corHover : corFundo);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _desenharTexto(
      canvas,
      texto,
      const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      anchor: Offset(rect.center.dx, rect.center.dy - 10),
      alinhamento: TextAlign.center,
      larguraMax: rect.width - 16,
    );
  }

  void _desenharTexto(
    Canvas canvas,
    String texto,
    TextStyle estilo, {
    required Offset anchor,
    required TextAlign alinhamento,
    required double larguraMax,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: alinhamento,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: larguraMax);

    tp.paint(
      canvas,
      Offset(anchor.dx - tp.width / 2, anchor.dy),
    );
  }

  // ─────────────────────────────────────────────
  // Input — toque
  // ─────────────────────────────────────────────

  @override
  void onTapUp(TapUpEvent event) {
    if (!_entradaAtiva) return;
    final pos = event.localPosition.toOffset();

    if (_retBtnReiniciar.contains(pos)) {
      removeFromParent();
      onReiniciar();
      return;
    }
    if (_retBtnMenu.contains(pos)) {
      removeFromParent();
      onMenu();
    }
  }

  // ─────────────────────────────────────────────
  // Input — teclado
  // ─────────────────────────────────────────────

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!_entradaAtiva || event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      removeFromParent();
      onReiniciar();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      removeFromParent();
      onMenu();
      return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Partícula de coração que cai pela tela
// ─────────────────────────────────────────────────────────────────────────────

class _CoracaoParticula {
  _CoracaoParticula({
    required this.x,
    required this.y,
    required this.velY,
    required this.velX,
    required this.tamanho,
    required this.delay,
  });

  double x;
  double y;
  final double velY;
  final double velX;
  final double tamanho;
  final double delay;

  double _tempo = 0;

  void atualizar(double dt, double alturaMax) {
    _tempo += dt;
    if (_tempo < delay) return;

    y += velY * dt;
    x += velX * dt;

    // Reinicia ao sair da tela
    if (y > alturaMax + 20) {
      y = -20;
    }
  }

  void desenhar(Canvas canvas) {
    if (_tempo < delay) return;

    final opacidade = (sin(_tempo * 2) * 0.3 + 0.7).clamp(0.0, 1.0);
    final paint     = Paint()..color = const Color(0xFFE53935).withOpacity(opacidade);

    canvas.save();
    canvas.translate(x, y);
    canvas.drawPath(_caminhoCoracao(tamanho), paint);
    canvas.restore();
  }

  static Path _caminhoCoracao(double t) {
    final p  = Path();
    final cx = t / 2;
    final cy = t * 0.55;

    p.moveTo(cx, cy + t * 0.28);
    p.cubicTo(
      cx - t * 0.05, cy + t * 0.15,
      cx - t * 0.48, cy - t * 0.05,
      cx - t * 0.48, cy - t * 0.22,
    );
    p.arcToPoint(
      Offset(cx, cy - t * 0.08),
      radius: Radius.circular(t * 0.28),
      clockwise: false,
    );
    p.arcToPoint(
      Offset(cx + t * 0.48, cy - t * 0.22),
      radius: Radius.circular(t * 0.28),
      clockwise: false,
    );
    p.cubicTo(
      cx + t * 0.48, cy - t * 0.05,
      cx + t * 0.05, cy + t * 0.15,
      cx, cy + t * 0.28,
    );
    p.close();
    return p;
  }
}
