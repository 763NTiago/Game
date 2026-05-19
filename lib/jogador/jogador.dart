import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/config/config_display.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/mundo/chao.dart';

/// Personagem jogavel.
/// Usa HardwareKeyboard.instance para polling de teclas — funciona mesmo
/// quando o componente vive dentro de game.world (nao precisa de KeyboardHandler).
class Jogador extends PositionComponent with HasGameReference<FlameGame> {
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

  // Fisica
  double velocidadeX = 0;
  double velocidadeY = 0;
  bool noChao = false;

  // Controle externo
  bool pausado = false;
  double opacidade = 1.0;

  // Estado interno de pulo — evita pulo continuo ao segurar a tecla
  bool _puloAtivo = false;

  @override
  Future<void> onLoad() async {
    anchor = Anchor.topLeft;
    await _carregarSkin(caminhoSkin);
  }

  Future<void> _carregarSkin(String caminho) async {
    _sprite?.removeFromParent();
    _sprite = null;

    final image = await game.images.load(caminho);
    _sheet = ConfigSpritesheet.daImagem(image);
    animacao = ControladorAnimacao(config: _sheet);

    final tamanhoFrame = Vector2(_sheet.larguraFrame, _sheet.alturaFrame);
    size = tamanhoFrame * ConfigDisplay.escalaPersonagem;

    final origem = _sheet.origemDoFrame(animacao.indiceFrameAtual);
    final sprite = SpriteComponent(
      sprite: Sprite(
        image,
        srcPosition: Vector2(origem.x, origem.y),
        srcSize: tamanhoFrame,
      ),
      size: size,
      anchor: Anchor.topLeft,
    )..paint.filterQuality = FilterQuality.none;

    _sprite = sprite;
    add(sprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (pausado) return;

    // ── Polling de teclado via HardwareKeyboard ──
    final hw = HardwareKeyboard.instance;

    final esquerda =
        hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowLeft) ||
        hw.isLogicalKeyPressed(LogicalKeyboardKey.keyA);
    final direita =
        hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowRight) ||
        hw.isLogicalKeyPressed(LogicalKeyboardKey.keyD);
    final querPular =
        hw.isLogicalKeyPressed(LogicalKeyboardKey.arrowUp) ||
        hw.isLogicalKeyPressed(LogicalKeyboardKey.keyW) ||
        hw.isLogicalKeyPressed(LogicalKeyboardKey.space);

    // ── Velocidade horizontal ──
    velocidadeX = 0;
    if (esquerda) velocidadeX -= velocidadeAndar;
    if (direita) velocidadeX += velocidadeAndar;

    // ── Pulo — so dispara na borda de subida da tecla ──
    if (querPular && noChao && !_puloAtivo) {
      velocidadeY = -forcaPulo;
      noChao = false;
      _puloAtivo = true;
    }
    if (!querPular) _puloAtivo = false;

    // ── Gravidade + movimento ──
    velocidadeY += gravidade * dt;
    position.x += velocidadeX * dt;
    position.y += velocidadeY * dt;

    // ── Colisao com o chao ──
    final peNoChao = chao.topo - size.y;
    if (position.y >= peNoChao) {
      position.y = peNoChao;
      velocidadeY = 0;
      noChao = true;
    } else {
      noChao = false;
    }

    // ── Limites horizontais ──
    final limX = limiteMundoX ?? game.size.x;
    position.x = position.x.clamp(0, limX - size.x);

    // ── Direcao ──
    final seMovendo = velocidadeX.abs() > 1;
    if (seMovendo) animacao.definirDirecao(velocidadeX > 0);

    // ── Estado de animacao ──
    final estado = estadoAPartirDaFisica(
      noChao: noChao,
      velocidadeY: velocidadeY,
      seMovendoHorizontalmente: seMovendo,
    );
    animacao.atualizar(dt, estado);

    _atualizarSprite();
  }

  void _atualizarSprite() {
    final s = _sprite;
    if (s == null) return;

    final origem = _sheet.origemDoFrame(animacao.indiceFrameAtual);
    s.sprite = Sprite(
      s.sprite!.image,
      srcPosition: Vector2(origem.x, origem.y),
      srcSize: Vector2(_sheet.larguraFrame, _sheet.alturaFrame),
    );

    s.paint.color = Color.fromRGBO(255, 255, 255, opacidade.clamp(0.0, 1.0));

    // Flip horizontal correto
    if (animacao.direcao == DirecaoJogador.esquerda) {
      s.scale.x = -1;
      s.position.x = size.x;
    } else {
      s.scale.x = 1;
      s.position.x = 0;
    }
    s.position.y = 0;
  }
}
