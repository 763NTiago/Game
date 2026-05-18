import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/mundo/ranking.dart';

/// Tela de Vitória — aparece quando o jogador conclui todas as 5 portas.
///
/// Mostra estrelas caindo, pontuação final, nome do jogador e botões para
/// jogar de novo ou voltar ao menu. Também salva a pontuação no ranking.
///
/// Uso em [JogoCasa]:
/// ```dart
/// await add(TelaVitoria(
///   pontos: _pontos,
///   nomeJogador: personagem.nomeExibicao,
///   onJogarNovamente: () => reiniciarJogo(),
///   onMenu: () => mostrarMenu(),
/// ));
/// ```
class TelaVitoria extends PositionComponent
    with HasGameReference<FlameGame>, KeyboardHandler, TapCallbacks {
  TelaVitoria({
    required this.pontos,
    required this.nomeJogador,
    required this.onJogarNovamente,
    required this.onMenu,
  });

  final int pontos;
  final String nomeJogador;
  final VoidCallback onJogarNovamente;
  final VoidCallback onMenu;

  // Animação
  double _tempo = 0;
  final List<_EstrelaPart> _estrelas = [];
  final _rng = Random();

  // Botões
  late Rect _retBtnNovamente;
  late Rect _retBtnMenu;
  bool _btnNovamenteHover = false;
  bool _btnMenuHover = false;

  // Entrada bloqueada por 1 s para evitar clique acidental
  bool _entradaAtiva = false;

  // Ranking salvo
  List<EntradaRanking> _ranking = [];
  bool _rankingSalvo = false;

  @override
  Future<void> onLoad() async {
    priority = 999;
    size = game.size;
    position = Vector2.zero();
    anchor = Anchor.topLeft;

    // Salva ranking e libera entrada após 1 s
    await _salvarRanking();
    Future.delayed(const Duration(seconds: 1), () => _entradaAtiva = true);

    _calcularBotoes();
    _gerarEstrelas();
  }

  Future<void> _salvarRanking() async {
    _ranking = await RepositorioRanking.salvar(nomeJogador, pontos);
    _rankingSalvo = true;
  }

  void _calcularBotoes() {
    final cx = size.x / 2;
    final cy = size.y / 2;

    const largBtn = 240.0;
    const altBtn = 52.0;
    const espacamento = 20.0;

    _retBtnNovamente = Rect.fromCenter(
      center: Offset(cx, cy + 110),
      width: largBtn,
      height: altBtn,
    );
    _retBtnMenu = Rect.fromCenter(
      center: Offset(cx, cy + 110 + altBtn + espacamento),
      width: largBtn,
      height: altBtn,
    );
  }

  void _gerarEstrelas() {
    for (var i = 0; i < 24; i++) {
      _estrelas.add(
        _EstrelaPart(
          x: _rng.nextDouble() * size.x,
          y: -20 - _rng.nextDouble() * 300,
          velY: 50 + _rng.nextDouble() * 80,
          velX: (_rng.nextDouble() - 0.5) * 40,
          tamanho: 14 + _rng.nextDouble() * 22,
          delay: _rng.nextDouble() * 2.5,
          cor: _cores[_rng.nextInt(_cores.length)],
        ),
      );
    }
  }

  static const _cores = [
    Color(0xFFFFEB3B), // amarelo
    Color(0xFFFFD700), // ouro
    Color(0xFFFF9800), // laranja
    Color(0xFFFFFFFF), // branco
    Color(0xFF80DEEA), // ciano claro
  ];

  // ─────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;
    for (final e in _estrelas) {
      e.atualizar(dt, size.y);
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

    // Fundo escuro azulado semitransparente
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xDD000033),
    );

    // Estrelas caindo
    for (final e in _estrelas) {
      e.desenhar(canvas);
    }

    // Painel central
    final painelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy - 10), width: 460, height: 420),
      const Radius.circular(24),
    );
    canvas.drawRRect(painelRect, Paint()..color = const Color(0xFF0A0A2A));
    canvas.drawRRect(
      painelRect,
      Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Título pulsante "Você Venceu!"
    final escTitle = 1.0 + sin(_tempo * 2.5) * 0.04;
    canvas.save();
    canvas.translate(cx, cy - 170);
    canvas.scale(escTitle, escTitle);
    _texto(
      canvas,
      '🏆 Você Venceu! 🏆',
      const TextStyle(
        color: Color(0xFFFFD700),
        fontSize: 36,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 10)],
      ),
      larguraMax: 420,
    );
    canvas.restore();

    // Subtítulo
    _texto(
      canvas,
      'Parabéns, $nomeJogador!\nVocê completou todas as fases! ⭐',
      const TextStyle(
        color: Colors.white,
        fontSize: 20,
        height: 1.5,
        shadows: [Shadow(color: Colors.black, blurRadius: 6)],
      ),
      anchor: Offset(cx, cy - 110),
      larguraMax: 380,
    );

    // Pontuação
    _texto(
      canvas,
      '$pontos pontos',
      TextStyle(
        color: const Color(0xFFFFEB3B),
        fontSize: 44,
        fontWeight: FontWeight.bold,
        shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
      ),
      anchor: Offset(cx, cy - 35),
      larguraMax: 380,
    );

    // Ranking (se já carregou)
    if (_rankingSalvo && _ranking.isNotEmpty) {
      _desenharMiniRanking(canvas, cx, cy + 30);
    }

    // Botão Jogar de novo
    _desenharBotao(
      canvas,
      rect: _retBtnNovamente,
      texto: '🔄  Jogar de novo',
      hover: _btnNovamenteHover,
      corFundo: const Color(0xFF1B5E20),
      corHover: const Color(0xFF43A047),
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
    _texto(
      canvas,
      'R — jogar de novo   |   ESC — menu',
      const TextStyle(color: Colors.white38, fontSize: 13),
      anchor: Offset(cx, size.y - 28),
      larguraMax: 400,
    );
  }

  void _desenharMiniRanking(Canvas canvas, double cx, double topoY) {
    const medalhas = ['🥇', '🥈', '🥉'];
    const coresMedalha = [
      Color(0xFFFFD700),
      Color(0xFFC0C0C0),
      Color(0xFFCD7F32),
    ];

    _texto(
      canvas,
      '— Top 3 —',
      const TextStyle(
        color: Color(0xFFFFEB3B),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      anchor: Offset(cx, topoY),
      larguraMax: 300,
    );

    for (var i = 0; i < _ranking.length && i < 3; i++) {
      final e = _ranking[i];
      final cor = coresMedalha[i];
      final y = topoY + 22 + i * 22.0;

      _texto(
        canvas,
        '${medalhas[i]} ${e.nome}  •  ${e.pontos} pts',
        TextStyle(color: cor, fontSize: 14),
        anchor: Offset(cx, y),
        larguraMax: 300,
      );
    }
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
    _texto(
      canvas,
      texto,
      const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      anchor: Offset(rect.center.dx, rect.center.dy - 10),
      larguraMax: rect.width - 16,
    );
  }

  void _texto(
    Canvas canvas,
    String texto,
    TextStyle estilo, {
    Offset? anchor,
    required double larguraMax,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: larguraMax);

    final off = anchor ?? Offset.zero;
    tp.paint(canvas, Offset(off.dx - tp.width / 2, off.dy));
  }

  // ─────────────────────────────────────────────
  // Input — toque
  // ─────────────────────────────────────────────

  @override
  void onTapUp(TapUpEvent event) {
    if (!_entradaAtiva) return;
    final pos = event.localPosition.toOffset();

    if (_retBtnNovamente.contains(pos)) {
      removeFromParent();
      onJogarNovamente();
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
      onJogarNovamente();
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
// Partícula de estrela que cai pela tela
// ─────────────────────────────────────────────────────────────────────────────

class _EstrelaPart {
  _EstrelaPart({
    required this.x,
    required this.y,
    required this.velY,
    required this.velX,
    required this.tamanho,
    required this.delay,
    required this.cor,
  });

  double x;
  double y;
  final double velY;
  final double velX;
  final double tamanho;
  final double delay;
  final Color cor;

  double _tempo = 0;

  void atualizar(double dt, double alturaMax) {
    _tempo += dt;
    if (_tempo < delay) return;

    y += velY * dt;
    x += velX * dt;

    if (y > alturaMax + 20) {
      y = -20;
    }
  }

  void desenhar(Canvas canvas) {
    if (_tempo < delay) return;

    final opacidade = (sin(_tempo * 3) * 0.3 + 0.7).clamp(0.0, 1.0);
    final paint = Paint()..color = cor.withOpacity(opacidade);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(_tempo * 1.5);
    canvas.drawPath(_estrela5pontas(tamanho), paint);
    canvas.restore();
  }

  static Path _estrela5pontas(double raio) {
    final path = Path();
    final r1 = raio / 2;
    final r2 = r1 * 0.4;
    const pontos = 5;

    for (var i = 0; i < pontos * 2; i++) {
      final angulo = (i * pi / pontos) - pi / 2;
      final r = i.isEven ? r1 : r2;
      final px = cos(angulo) * r;
      final py = sin(angulo) * r;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }
}
