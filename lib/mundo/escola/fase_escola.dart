import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/jogador.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/mundo/chao.dart';
import 'package:meu_jogo/mundo/escola/dados/desafios_escola.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';
import 'package:meu_jogo/mundo/escola/painel_desafio.dart';
import 'package:meu_jogo/mundo/escola/porta.dart';

/// Fase escola: vista lateral, anda →, câmera segue o jogador (estilo Mario).
class FaseEscola extends Component
    with HasGameReference<FlameGame>, KeyboardHandler {
  FaseEscola({required this.personagem});

  final Personagem personagem;

  late Jogador _jogador;
  late PainelDesafio _painel;
  late double _topoChao;
  final List<Porta> _portas = [];
  Porta? _portaAtiva;
  String? _feedback;

  @override
  Future<void> onLoad() async {
    _topoChao = game.size.y - 48;

    await _montarFundo();

    final chao = Chao(
      altura: 48,
      largura: EscolaVisual.larguraMundo,
      topoY: _topoChao,
    );
    await add(chao);

    _jogador = Jogador(
      caminhoSkin: personagem.caminhoSkin,
      chao: chao,
      limiteMundoX: EscolaVisual.larguraMundo,
    );
    await add(_jogador);
    _jogador.position = Vector2(EscolaVisual.inicioJogadorX, _topoChao - _jogador.size.y);

    _painel = PainelDesafio(onResposta: _aoResponder);
    await add(_painel);

    await _montarPortas();

    game.camera.viewfinder.anchor = Anchor.center;
    game.camera.follow(_jogador);
  }

  Future<void> _montarFundo() async {
    final alturaTela = game.size.y;

    try {
      final image = await game.images.load(EscolaVisual.fundo);
      final escala = alturaTela / image.height;
      final larguraDesenho = image.width * escala;

      await add(
        SpriteComponent(
          sprite: Sprite(image),
          size: Vector2(larguraDesenho, alturaTela),
          position: Vector2(0, 0),
          anchor: Anchor.topLeft,
        )..paint.filterQuality = FilterQuality.none,
      );

      if (larguraDesenho < EscolaVisual.larguraMundo) {
        await add(
          RectangleComponent(
            position: Vector2(larguraDesenho, alturaTela * 0.55),
            size: Vector2(
              EscolaVisual.larguraMundo - larguraDesenho,
              alturaTela * 0.45,
            ),
            paint: Paint()..color = const Color(0xFFFFF9C4),
          ),
        );
      }
    } catch (_) {
      await add(
        RectangleComponent(
          size: Vector2(EscolaVisual.larguraMundo, alturaTela),
          paint: Paint()..color = const Color(0xFFB3E5FC),
        ),
      );
      await add(
        RectangleComponent(
          position: Vector2(0, alturaTela * 0.55),
          size: Vector2(EscolaVisual.larguraMundo, alturaTela * 0.45),
          paint: Paint()..color = const Color(0xFFFFF9C4),
        ),
      );
    }
  }

  Future<void> _montarPortas() async {
    for (var i = 0; i < desafiosPortasEscola.length; i++) {
      final desafio = desafiosPortasEscola[i];
      final porta = Porta(
        desafio: desafio,
        onInteragir: _abrirDesafio,
      )..position = Vector2(EscolaVisual.portasPosicaoX[i], _topoChao);
      _portas.add(porta);
      await add(porta);
    }
  }

  void _abrirDesafio(Porta porta) {
    if (porta.concluida || _painel.aberto) return;
    _portaAtiva = porta;
    _feedback = null;
    _painel.abrir(porta.desafio);
  }

  void _aoResponder(bool acertou) async {
    final porta = _portaAtiva;
    _portaAtiva = null;
    if (porta == null) return;

    if (acertou) {
      await porta.marcarConcluida();
      _feedback = 'Porta ${porta.desafio.porta} concluída!';
    } else {
      _feedback = 'Resposta errada — tente de novo!';
    }
  }

  Porta? _portaProxima() {
    final centro = _jogador.position + _jogador.size / 2;
    for (final porta in _portas) {
      if (!porta.concluida && porta.contemJogador(centro)) {
        return porta;
      }
    }
    return null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _jogador.pausado = _painel.aberto;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final msg = _feedback;
    if (msg == null) return;

    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: game.size.x - 48);
    tp.paint(canvas, const Offset(24, 48));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_painel.aberto) return false;
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyE) {
      final porta = _portaProxima();
      if (porta != null) {
        _abrirDesafio(porta);
        return true;
      }
    }
    return false;
  }
}
