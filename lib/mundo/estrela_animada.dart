import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

/// Estrela animada que aparece ao completar uma porta.
///
/// Flutua para cima, gira, pisca e some sozinha.
/// Não precisa ser removida manualmente — se auto-remove ao fim da animação.
///
/// Uso:
/// ```dart
/// await add(EstrelAnimada(posicaoInicial: porta.position));
/// ```
class EstrelAnimada extends PositionComponent with HasGameReference<FlameGame> {
  EstrelAnimada({
    required Vector2 posicaoInicial,
    this.duracao = 1.8,
    this.velocidadeSubida = 90.0,
    this.tamanho = EscolaVisual.tamanhoEstrela,
  }) {
    position = posicaoInicial.clone();
    anchor   = Anchor.center;
    size     = Vector2.all(tamanho);
  }

  /// Duração total da animação em segundos.
  final double duracao;

  /// Velocidade de subida em px/s.
  final double velocidadeSubida;

  /// Tamanho do sprite em px.
  final double tamanho;

  double _tempo    = 0;
  double _angulo   = 0;
  double _escala   = 0; // começa pequena e cresce
  bool   _removido = false;

  SpriteComponent? _sprite;

  // ─────────────────────────────────────────────
  // Carregamento
  // ─────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    try {
      final image = await game.images.load(EscolaVisual.estrela);
      _sprite = SpriteComponent(
        sprite: Sprite(image),
        size: Vector2.all(tamanho),
        anchor: Anchor.center,
      )..paint.filterQuality = FilterQuality.none;
      await add(_sprite!);
    } catch (_) {
      // Sem imagem: desenha estrela via Path no render()
    }
  }

  // ─────────────────────────────────────────────
  // Update — animação
  // ─────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (_removido) return;

    _tempo  += dt;
    _angulo += dt * 3.0; // rotação contínua

    final progresso = (_tempo / duracao).clamp(0.0, 1.0);

    // Sobe
    position.y -= velocidadeSubida * dt;

    // Oscila levemente para os lados (efeito flutuante)
    position.x += sin(_tempo * 5) * 0.8;

    // Escala: cresce rápido no início, encolhe no fim
    _escala = progresso < 0.2
        ? progresso / 0.2               // 0→1 nos primeiros 20%
        : 1.0 - ((progresso - 0.2) / 0.8); // 1→0 nos últimos 80%

    // Aplica escala e rotação
    final s = _escala.clamp(0.0, 1.0);
    scale   = Vector2.all(s);

    if (_sprite != null) {
      // Rotação aplicada ao sprite filho
      _sprite!.angle = _angulo;
      // Opacidade baseada no progresso
      _sprite!.opacity = s;
    }

    // Remove ao terminar
    if (_tempo >= duracao && !_removido) {
      _removido = true;
      removeFromParent();
    }
  }

  // ─────────────────────────────────────────────
  // Render de fallback (sem imagem)
  // ─────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    if (_sprite != null) return;

    final s = _escala.clamp(0.0, 1.0);
    if (s <= 0) return;

    canvas.save();
    canvas.translate(tamanho / 2, tamanho / 2);
    canvas.rotate(_angulo);

    // Sombra suave
    _desenharEstrela(
      canvas,
      raio: tamanho * 0.48,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.25 * s)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      offset: const Offset(2, 3),
    );

    // Estrela amarela
    _desenharEstrela(
      canvas,
      raio: tamanho * 0.48,
      paint: Paint()..color = Color.lerp(
        const Color(0xFFFFEB3B),
        const Color(0xFFFF9800),
        sin(_tempo * 6) * 0.5 + 0.5, // pulsa entre amarelo e laranja
      )!.withOpacity(s),
    );

    // Brilho central branco
    _desenharEstrela(
      canvas,
      raio: tamanho * 0.22,
      paint: Paint()..color = Colors.white.withOpacity(0.55 * s),
    );

    canvas.restore();
  }

  /// Desenha uma estrela de 5 pontas centralizada na origem do canvas.
  void _desenharEstrela(
    Canvas canvas, {
    required double raio,
    required Paint paint,
    Offset offset = Offset.zero,
  }) {
    const pontas  = 5;
    final interno = raio * 0.42;
    final path    = Path();

    for (var i = 0; i < pontas * 2; i++) {
      final r = i.isEven ? raio : interno;
      final a = (i * pi / pontas) - pi / 2;
      final x = offset.dx + r * cos(a);
      final y = offset.dy + r * sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Versão HUD — estrela menor que fica no placar e pulsa ao ganhar ponto
// ─────────────────────────────────────────────────────────────────────────────

/// Estrela pequena que pulsa uma vez ao atualizar o placar.
/// Usada dentro do [Hud] para dar feedback visual ao ganhar pontos.
class EstrelaPulso extends PositionComponent {
  EstrelaPulso({
    required Vector2 posicao,
    this.tamanho = EscolaVisual.tamanhoEstrelaHud,
  }) {
    position = posicao;
    anchor   = Anchor.center;
    size     = Vector2.all(tamanho);
  }

  final double tamanho;

  double _tempo  = 0;
  bool   _pulsando = false;
  double _escalaAtual = 1.0;

  /// Dispara o pulso (chame ao ganhar pontos).
  void pulsar() {
    _pulsando = true;
    _tempo    = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_pulsando) return;

    _tempo += dt;
    const duracaoPulso = 0.4;

    // Cresce e volta
    final t = (_tempo / duracaoPulso).clamp(0.0, 1.0);
    _escalaAtual = 1.0 + sin(t * pi) * 0.6;
    scale = Vector2.all(_escalaAtual);

    if (_tempo >= duracaoPulso) {
      _pulsando    = false;
      _escalaAtual = 1.0;
      scale        = Vector2.all(1.0);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(tamanho / 2, tamanho / 2);

    const pontas  = 5;
    final raio    = tamanho * 0.48;
    final interno = raio * 0.42;
    final path    = Path();

    for (var i = 0; i < pontas * 2; i++) {
      final r = i.isEven ? raio : interno;
      final a = (i * pi / pontas) - pi / 2;
      final x = r * cos(a);
      final y = r * sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFF9800)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }
}
