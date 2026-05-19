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

  // ── Dead zone ──────────────────────────────────────────────────────────────
  // A câmera só se move quando o jogador sai dos 50% centrais da tela.
  // Cada borda da dead zone fica a 25% da largura da viewport.
  //
  //   |←── 25% ──|←────── 50% dead zone ──────→|── 25% ──→|
  //              ↑                               ↑
  //         _deadLeft                       _deadRight  (em coords do mundo)
  //
  // _cameraX é a borda esquerda do que a câmera mostra no mundo.
  double _cameraX = 0;

  World get _world => game.world;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    await _montarFundo();
    await _montarChao();
    await _montarJogador();
    _configurarCamera();
  }

  // ── Fundo ──────────────────────────────────────────────────────────────────
  Future<void> _montarFundo() async {
    final screenW = game.size.x;
    final screenH = game.size.y;

    try {
      final image = await game.images.load(EscolaVisual.fundo);

      // Escala pela ALTURA para preencher verticalmente sem deixar barra preta.
      final escala = screenH / image.height;
      final largImg = image.width * escala;

      // Garante que ao menos uma tile ocupe a largura inteira da tela.
      // Se a imagem escalada for mais estreita que a tela, aumenta a escala.
      final escalaFinal = largImg < screenW
          ? screenW /
                image
                    .width // estica para cobrir a largura mínima
          : escala;

      final largFinal = image.width * escalaFinal;
      final altFinal = image.height * escalaFinal;

      // Tileamos horizontalmente pelo mundo todo. Começa em Y=0 (topo da tela).
      var x = 0.0;
      while (x < EscolaVisual.larguraMundo) {
        await _world.add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(largFinal, altFinal),
            position: Vector2(x, 0),
            anchor: Anchor.topLeft,
          )..paint.filterQuality = FilterQuality.none,
        );
        x += largFinal;
      }
    } catch (_) {
      // Fallback: retângulo colorido cobrindo mundo inteiro.
      await _world.add(
        RectangleComponent(
          size: Vector2(EscolaVisual.larguraMundo, screenH),
          paint: Paint()..color = const Color(EscolaVisual.corFundoFallback),
        ),
      );
    }
  }

  // ── Chão ───────────────────────────────────────────────────────────────────
  Future<void> _montarChao() async {
    // 0.98 → pé do jogador exatamente na linha limite inferior do visual.
    final topoChao = game.size.y * 0.98;
    final alturaChao = game.size.y - topoChao;

    _chao = Chao(
      altura: alturaChao,
      largura: EscolaVisual.larguraMundo,
      topoY: topoChao,
    );
    await _world.add(_chao);
  }

  // ── Jogador ────────────────────────────────────────────────────────────────
  Future<void> _montarJogador() async {
    _jogador = Jogador(
      caminhoSkin: personagem.caminhoSkin,
      chao: _chao,
      limiteMundoX: EscolaVisual.larguraMundo,
    );
    await _world.add(_jogador);

    // Inicia no canto esquerdo, em cima do chão.
    _jogador.position = Vector2(10.0, _chao.topo - _jogador.size.y);
  }

  // ── Câmera (configuração inicial) ─────────────────────────────────────────
  void _configurarCamera() {
    // Âncora no CENTRO da viewport — padrão correto do Flame.
    // Não usamos viewfinder.anchor deslocado, pois isso causava o canto preto
    // da esquerda ao mostrar espaço "antes" do X=0 do mundo.
    game.camera.viewfinder.zoom = 1.0;
    game.camera.viewfinder.anchor = Anchor.center;

    // Posicionamos a câmera manualmente para que o jogador apareça no lado
    // esquerdo da dead zone logo no início (sem revelar espaço negativo).
    _cameraX = 0; // começa colada na borda esquerda do mundo
    _aplicarCamera();

    // Limites rígidos: câmera não pode mostrar fora do mundo.
    game.camera.setBounds(
      Rectangle.fromLTWH(0, 0, EscolaVisual.larguraMundo, game.size.y),
    );

    // Desliga o follow automático — vamos controlar manualmente no update().
    game.camera.stop();
  }

  // ── Dead zone — atualiza câmera a cada frame ───────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    final screenW = game.size.x;

    // Limites da dead zone em coordenadas de TELA (relativo a _cameraX).
    // 25% da esquerda → começa a mover a câmera para a esquerda
    // 25% da direita  → começa a mover a câmera para a direita
    final deadLeft = _cameraX + screenW * 0.25;
    final deadRight = _cameraX + screenW * 0.75;

    // Centro do jogador no eixo X (dentro do mundo).
    final jogadorCX = _jogador.position.x + _jogador.size.x / 2;

    if (jogadorCX < deadLeft) {
      // Jogador cruzou a borda esquerda da dead zone → puxa câmera para esquerda.
      _cameraX = jogadorCX - screenW * 0.25;
    } else if (jogadorCX > deadRight) {
      // Jogador cruzou a borda direita da dead zone → empurra câmera para direita.
      _cameraX = jogadorCX - screenW * 0.75;
    }

    // Clamp: não deixa mostrar além das bordas do mundo.
    _cameraX = _cameraX.clamp(0, EscolaVisual.larguraMundo - screenW);

    _aplicarCamera();
  }

  /// Aplica _cameraX ao viewfinder (sem usar follow/snap do Flame).
  void _aplicarCamera() {
    final screenW = game.size.x;
    final screenH = game.size.y;

    // O viewfinder.position é o ponto do MUNDO que aparece no centro da tela
    // (porque viewfinder.anchor = Anchor.center).
    game.camera.viewfinder.position = Vector2(
      _cameraX + screenW / 2,
      screenH / 2,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
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
