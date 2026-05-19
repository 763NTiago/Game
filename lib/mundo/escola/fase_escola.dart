import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/jogador.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/mundo/chao.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

class FaseEscola extends Component
    with HasGameReference<FlameGame>, KeyboardHandler {
  FaseEscola({required this.personagem, this.onGameOver, this.onConcluida});

  final Personagem personagem;
  final void Function(int pontos)? onGameOver;
  final void Function(int pontos)? onConcluida;

  late Jogador _jogador;
  late Chao _chao;

  World get _world => game.world;

  @override
  Future<void> onLoad() async {
    await _montarFundo();
    await _montarChao();
    await _montarJogador();
    _configurarCamera();
  }

  Future<void> _montarFundo() async {
    final screenH = game.size.y;

    try {
      final image = await game.images.load(EscolaVisual.fundo);

      // Escala estritamente pela altura para sumir com o fundo preto inferior
      final escala = screenH / image.height;
      final largImg = image.width * escala;
      final altImg = screenH;

      var x = 0.0;
      while (x < EscolaVisual.larguraMundo) {
        await _world.add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(largImg, altImg),
            position: Vector2(x, 0), // Perfeitamente colado no topo e base
            anchor: Anchor.topLeft,
          )..paint.filterQuality = FilterQuality.none,
        );
        x += largImg;
      }
    } catch (_) {
      await _world.add(
        RectangleComponent(
          size: Vector2(EscolaVisual.larguraMundo, screenH),
          paint: Paint()..color = const Color(EscolaVisual.corFundoFallback),
        ),
      );
    }
  }

  Future<void> _montarChao() async {
    // 0.98 faz o pé do jogador ficar exatamente na linha limite inferior do visual da imagem
    final topoChao = game.size.y * 0.98;
    final alturaChao = game.size.y - topoChao;

    _chao = Chao(
      altura: alturaChao,
      largura: EscolaVisual.larguraMundo,
      topoY: topoChao,
    );
    await _world.add(_chao);
  }

  Future<void> _montarJogador() async {
    _jogador = Jogador(
      caminhoSkin: personagem.caminhoSkin,
      chao: _chao,
      limiteMundoX: EscolaVisual.larguraMundo,
    );
    await _world.add(_jogador);

    // Inicia bem no canto esquerdo da tela (X = 10) e em cima do chão inferior
    _jogador.position = Vector2(10.0, _chao.topo - _jogador.size.y);
  }

  void _configurarCamera() {
    game.camera.viewfinder.zoom = 1.0;

    // Alinha o ponto focal da câmera no lado esquerdo da sua própria lente
    // Isso impede que a câmera tente centralizar o jogador logo no começo da fase
    game.camera.viewfinder.anchor = const Anchor(0.25, 0.5);

    // Segue o jogador
    game.camera.follow(_jogador);

    // Prende os limites rígidos da câmera nas extremidades do mundo
    game.camera.setBounds(
      Rectangle.fromLTWH(0, 0, EscolaVisual.larguraMundo, game.size.y),
    );
  }

  @override
  void onRemove() {
    super.onRemove();
    game.camera.stop();
    _world.removeAll(_world.children.toList());
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return false;
  }
}
