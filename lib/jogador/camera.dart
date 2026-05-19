import 'package:flame/components.dart';
import 'package:flame/experimental.dart'; // Rectangle (Shape) para setBounds
import 'package:flame/game.dart';
import 'package:meu_jogo/jogador/jogador.dart';

/// Câmera que segue o jogador dentro dos limites do mundo.
///
/// Usa a API moderna do Flame 1.x (CameraComponent):
///   - zoom       → game.camera.viewfinder.zoom
///   - seguir     → game.camera.follow(jogador)
///   - limites    → game.camera.setBounds(Rectangle.fromLTWH(...))
///
/// Uso dentro do onLoad de qualquer fase:
/// ```dart
/// final cam = CameraJogador(
///   jogador: _jogador,
///   larguraMundo: EscolaVisual.larguraMundo,
///   alturaTela: game.size.y,
/// );
/// await game.add(cam);
/// ```
class CameraJogador extends Component with HasGameReference<FlameGame> {
  CameraJogador({
    required this.jogador,
    required this.larguraMundo,
    required this.alturaTela,
    this.zoom = 1.0,
  });

  final Jogador jogador;
  final double larguraMundo;
  final double alturaTela;

  /// Zoom da câmera (1.0 = sem zoom, 2.0 = duas vezes mais próximo).
  final double zoom;

  @override
  Future<void> onLoad() async {
    // Zoom fica no viewfinder, não na CameraComponent diretamente
    game.camera.viewfinder.zoom = zoom;

    // Limita a câmera ao retângulo do mundo
    // Rectangle vem de package:flame/experimental.dart
    game.camera.setBounds(Rectangle.fromLTWH(0, 0, larguraMundo, alturaTela));

    // Segue o jogador automaticamente
    game.camera.follow(jogador);
  }

  /// Reposiciona a câmera imediatamente — útil após teleporte do jogador.
  void snapParaJogador() {
    game.camera.viewfinder.position = jogador.absoluteCenter;
  }

  /// Atualiza os limites do mundo dinamicamente (ex: fase que expande).
  void atualizarLimites({required double largura, required double altura}) {
    game.camera.setBounds(Rectangle.fromLTWH(0, 0, largura, altura));
  }
}
