import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/mundo/escola/desafio_config.dart';

/// Painel com pergunta e 5 respostas (teclas 1–5 ou clique).
class PainelDesafio extends PositionComponent
    with HasGameReference<FlameGame>, KeyboardHandler, TapCallbacks {
  PainelDesafio({required this.onResposta});

  final void Function(bool acertou) onResposta;

  DesafioConfig? _desafio;
  int _opcaoFocada = 0;
  final List<RectangleComponent> _caixasOpcao = [];

  bool get aberto => _desafio != null;

  @override
  Future<void> onLoad() async {
    priority = 100;
    size = game.size;
    position = Vector2.zero();
  }

  void abrir(DesafioConfig desafio) {
    _desafio = desafio;
    _opcaoFocada = 0;
    _montarUi();
  }

  void fechar() {
    _desafio = null;
    removeAll(children);
    _caixasOpcao.clear();
  }

  void _montarUi() {
    removeAll(children);
    _caixasOpcao.clear();

    final d = _desafio!;

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xCC000000),
      ),
    );

    final centroX = size.x / 2;
  var y = size.y * 0.22;

    add(
      TextComponent(
        text: d.tipo == TipoDesafio.matematica ? 'Desafio de matemática' : 'Complete a palavra',
        anchor: Anchor.center,
        position: Vector2(centroX, y),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.amber, fontSize: 20),
        ),
      ),
    );
    y += 36;

    add(
      TextComponent(
        text: d.pergunta,
        anchor: Anchor.center,
        position: Vector2(centroX, y),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 26, height: 1.3),
        ),
      ),
    );
    y += 56;

    for (var i = 0; i < d.opcoes.length; i++) {
      final caixa = RectangleComponent(
        position: Vector2(centroX - 180, y + i * 44),
        size: Vector2(360, 36),
        paint: Paint()..color = const Color(0xFF37474F),
      );
      _caixasOpcao.add(caixa);
      add(caixa);

      add(
        TextComponent(
          text: '${i + 1}. ${d.opcoes[i]}',
          position: Vector2(centroX - 168, y + i * 44 + 8),
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    add(
      TextComponent(
        text: 'Teclas 1–5 ou ↑↓ + Enter  |  ESC cancelar',
        anchor: Anchor.bottomCenter,
        position: Vector2(centroX, size.y - 24),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
    _atualizarFoco();
  }

  void _atualizarFoco() {
    for (var i = 0; i < _caixasOpcao.length; i++) {
      _caixasOpcao[i].paint.color =
          i == _opcaoFocada ? const Color(0xFF1565C0) : const Color(0xFF37474F);
    }
  }

  void _confirmar() {
    final d = _desafio;
    if (d == null) return;
    final acertou = _opcaoFocada == d.indiceCorreto;
    fechar();
    onResposta(acertou);
  }

  @override
  void renderTree(Canvas canvas) {
    if (!aberto) return;
    super.renderTree(canvas);
  }

  @override
  void update(double dt) {
    if (!aberto) return;
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!aberto || event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      fechar();
      return true;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _opcaoFocada = (_opcaoFocada - 1).clamp(0, 4);
      _atualizarFoco();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _opcaoFocada = (_opcaoFocada + 1).clamp(0, 4);
      _atualizarFoco();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      _confirmar();
      return true;
    }

    const teclas = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
    ];
    final idx = teclas.indexOf(event.logicalKey);
    if (idx >= 0) {
      _opcaoFocada = idx;
      _confirmar();
      return true;
    }

    return false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!aberto) return;
    for (var i = 0; i < _caixasOpcao.length; i++) {
      if (_caixasOpcao[i].toRect().contains(event.localPosition.toOffset())) {
        _opcaoFocada = i;
        _confirmar();
        return;
      }
    }
  }
}
