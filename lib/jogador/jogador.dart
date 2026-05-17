import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/config/config_display.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/mundo/chao.dart';

/// Personagem: física, animação pela matriz e colisão com o chão.
class Jogador extends PositionComponent
    with KeyboardHandler, HasGameReference<FlameGame> {
  Jogador({
    required this.caminhoSkin,
    required this.chao,
    this.limiteMundoX,
    this.velocidadeAndar = 200,
    this.forcaPulo = 420,
    this.gravidade = 900,
  });

  final String caminhoSkin;
  final Chao chao;
  final double? limiteMundoX;
  final double velocidadeAndar;
  final double forcaPulo;
  final double gravidade;

  late ControladorAnimacao animacao;
  late ConfigSpritesheet _sheet;

  SpriteComponent? _sprite;
  bool _indoEsquerda = false;
  bool _indoDireita = false;
  bool _puloSolicitado = false;

  double velocidadeX = 0;
  double velocidadeY = 0;
  bool noChao = false;

  /// Pausa movimento durante desafio / diálogo.
  bool pausado = false;

  @override
  Future<void> onLoad() async {
    await _carregarSkin(caminhoSkin);
    position = Vector2(80, chao.topo - size.y);
  }

  Future<void> _carregarSkin(String caminho) async {
    _sprite?.removeFromParent();

    final image = await game.images.load(caminho);
    _sheet = ConfigSpritesheet.daImagem(image);
    animacao = ControladorAnimacao(config: _sheet);

    final tamanhoFrame = Vector2(_sheet.larguraFrame, _sheet.alturaFrame);
    size = tamanhoFrame * ConfigDisplay.escalaPersonagem;

    final origem = _sheet.origemDoFrame(animacao.indiceFrameAtual);
    _sprite = SpriteComponent(
      sprite: Sprite(
        image,
        srcPosition: Vector2(origem.x, origem.y),
        srcSize: tamanhoFrame,
      ),
      size: size,
    )..paint.filterQuality = FilterQuality.none;

    add(_sprite!);
  }

  void _atualizarSprite() {
    final spriteComp = _sprite;
    if (spriteComp == null) return;

    final origem = _sheet.origemDoFrame(animacao.indiceFrameAtual);
    final image = spriteComp.sprite!.image;
    spriteComp.sprite = Sprite(
      image,
      srcPosition: Vector2(origem.x, origem.y),
      srcSize: Vector2(_sheet.larguraFrame, _sheet.alturaFrame),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (pausado) return;

    velocidadeX = 0;
    if (_indoEsquerda) velocidadeX -= velocidadeAndar;
    if (_indoDireita) velocidadeX += velocidadeAndar;

    if (_puloSolicitado && noChao) {
      velocidadeY = -forcaPulo;
      noChao = false;
    }
    _puloSolicitado = false;

    velocidadeY += gravidade * dt;
    position.x += velocidadeX * dt;
    position.y += velocidadeY * dt;

    final peNoChao = chao.topo - size.y;
    if (position.y >= peNoChao) {
      position.y = peNoChao;
      velocidadeY = 0;
      noChao = true;
    } else {
      noChao = false;
    }

    final limiteX = limiteMundoX ?? game.size.x;
    position.x = position.x.clamp(0, limiteX - size.x);

    final seMovendo = velocidadeX.abs() > 1;
    if (seMovendo) {
      animacao.definirDirecao(velocidadeX > 0);
    }

    final estado = estadoAPartirDaFisica(
      noChao: noChao,
      velocidadeY: velocidadeY,
      seMovendoHorizontalmente: seMovendo,
    );
    animacao.atualizar(dt, estado);
    _atualizarSprite();

    final spriteComp = _sprite;
    if (spriteComp != null) {
      spriteComp.scale.x =
          animacao.direcao == DirecaoJogador.esquerda ? -1 : 1;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (pausado) return false;

    _indoEsquerda = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA);
    _indoDireita = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD);

    final pulou = event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.arrowUp ||
            event.logicalKey == LogicalKeyboardKey.keyW ||
            event.logicalKey == LogicalKeyboardKey.space);
    if (pulou) {
      _puloSolicitado = true;
    }

    return true;
  }
}
