import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

/// Chão com colisão. Em fases largas, passe [largura] = largura do mundo.
class Chao extends PositionComponent with HasGameReference<FlameGame> {
  Chao({
    this.altura = 72,
    double? largura,
    double? topoY,
  })  : _larguraFixa = largura,
        _topoYFixo = topoY;

  final double altura;
  final double? _larguraFixa;
  final double? _topoYFixo;

  double get topo => position.y;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    _atualizarTamanho();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_larguraFixa == null && _topoYFixo == null) {
      _atualizarTamanho();
    }
  }

  void _atualizarTamanho() {
    size = Vector2(_larguraFixa ?? game.size.x, altura);
    position = Vector2(0, _topoYFixo ?? game.size.y - altura);
  }

  @override
  void render(Canvas canvas) {
    if (_larguraFixa != null) return;

    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF6B4F2A));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 12),
      Paint()..color = const Color(0xFF7CB342),
    );
  }
}
