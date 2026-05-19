import 'package:flame/experimental.dart'; // Rectangle
import 'package:flame/game.dart';
import 'package:meu_jogo/jogador/jogador.dart';

/// Helpers de câmera para a fase.
///
/// NÃO é mais um Component — opera diretamente sobre [game.camera].
/// Motivo: a câmera do Flame já vive no FlameGame; criar um Component
/// wrapper causava conflito de ciclo de vida com o World.
///
/// Uso:
/// ```dart
/// CameraJogador.configurar(game, jogador: _jogador, larguraMundo: 12000);
/// ```
class CameraJogador {
  CameraJogador._();

  /// Configura a câmera para seguir [jogador] dentro do mundo.
  static void configurar(
    FlameGame game, {
    required Jogador jogador,
    required double larguraMundo,
    double zoom = 1.0,
  }) {
    game.camera.viewfinder.zoom = zoom;
    game.camera.follow(jogador);
    game.camera.setBounds(Rectangle.fromLTWH(0, 0, larguraMundo, game.size.y));
  }

  /// Teleporta a câmera instantaneamente para cima do jogador.
  /// Útil após respawn ou teleporte.
  static void snap(FlameGame game, Jogador jogador) {
    game.camera.viewfinder.position = jogador.absoluteCenter;
  }

  /// Atualiza os limites do mundo dinamicamente (ex.: fase que expande).
  static void atualizarLimites(
    FlameGame game, {
    required double largura,
    required double altura,
  }) {
    game.camera.setBounds(Rectangle.fromLTWH(0, 0, largura, altura));
  }
}
