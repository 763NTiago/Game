import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/mundo/escola/desafio_config.dart';

/// Painel com pergunta e respostas (teclas 1–5 ou clique).
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
    // Remove qualquer elemento antigo antes de desenhar o novo painel
    removeAll(children);
    _caixasOpcao.clear();

    final d = _desafio;
    if (d == null) return;

    // Fundo escuro semitransparente para dar destaque ao painel
    add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = const Color(0xCC000000),
      ),
    );

    final centroX = game.size.x / 2;
    double y = 50;

    // 1. TÍTULO DO DESAFIO (Corrigido para usar a lógica dinâmica do d.labelTipo)
    add(
      TextComponent(
        text: d
            .labelTipo, // Exibe automaticamente "Desafio de matemática 🔢", "Complete...", etc.
        anchor: Anchor.center,
        position: Vector2(centroX, y),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    y += 45;

    // 2. PERGUNTA DO DESAFIO
    add(
      TextComponent(
        text: d.pergunta,
        anchor: Anchor.center,
        position: Vector2(centroX, y),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
    y += 55;

    // 3. MONTAGEM DAS ALTERNATIVAS (1 a 5)
    for (int i = 0; i < d.opcoes.length; i++) {
      // Define a posição de cada caixa de resposta
      final posicaoCaixa = Vector2(centroX, y);

      final caixa = RectangleComponent(
        position: posicaoCaixa,
        size: Vector2(400, 40),
        anchor: Anchor.center,
        paint: Paint()
          ..color = (i == _opcaoFocada) ? Colors.blue : Colors.grey.shade800,
      );

      // Texto interno da alternativa
      caixa.add(
        TextComponent(
          text: '${i + 1}. ${d.opcoes[i]}',
          anchor: Anchor.center,
          position: Vector2(200, 20), // Centro interno da caixa (400/2 e 40/2)
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );

      _caixasOpcao.add(caixa);
      add(caixa);
      y += 50;
    }

    // 4. INSTRUÇÕES DO RODAPÉ
    add(
      TextComponent(
        text: 'Teclas 1–5 ou ↑↓ + Enter  |  ESC cancelar',
        anchor: Anchor.bottomCenter,
        position: Vector2(centroX, game.size.y - 24),
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );

    _atualizarFoco();
  }

  void _atualizarFoco() {
    // Sincronizado com as novas cores (Colors.blue e Colors.grey.shade800)
    for (var i = 0; i < _caixasOpcao.length; i++) {
      _caixasOpcao[i].paint.color = i == _opcaoFocada
          ? Colors.blue
          : Colors.grey.shade800;
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

    final limiteOpcoes = (_desafio?.opcoes.length ?? 5) - 1;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _opcaoFocada = (_opcaoFocada - 1).clamp(0, limiteOpcoes);
      _atualizarFoco();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _opcaoFocada = (_opcaoFocada + 1).clamp(0, limiteOpcoes);
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
    if (idx >= 0 && idx <= limiteOpcoes) {
      _opcaoFocada = idx;
      _confirmar();
      return true;
    }

    return false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!aberto) return;

    // Ajustado para usar containsPoint, que lida corretamente com componentes usando Anchor.center
    for (var i = 0; i < _caixasOpcao.length; i++) {
      if (_caixasOpcao[i].containsPoint(event.localPosition)) {
        _opcaoFocada = i;
        _confirmar();
        return;
      }
    }
  }
}
