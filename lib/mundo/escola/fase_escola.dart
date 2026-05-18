import 'dart:math';

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
import 'package:meu_jogo/mundo/escola/inimigo.dart';
import 'package:meu_jogo/mundo/escola/objeto_cenario.dart';
import 'package:meu_jogo/mundo/escola/painel_desafio.dart';
import 'package:meu_jogo/mundo/escola/porta.dart';
import 'package:meu_jogo/mundo/hud.dart';
import 'package:meu_jogo/mundo/estrela_animada.dart';

/// Fase escola completa:
/// - 5 portas com desafios aleatórios para 4–6 anos
/// - Mesas, inimigos e buracos em posições aleatórias
/// - 5 vidas — perde ao tocar inimigo
/// - Estrelas animadas ao completar porta
/// - HUD com vidas e pontos
/// - Game over ao zerar vidas
class FaseEscola extends Component
    with HasGameReference<FlameGame>, KeyboardHandler {
  FaseEscola({
    required this.personagem,
    this.semente,
    this.onGameOver,
    this.onConcluida,
  });

  final Personagem personagem;
  final int? semente;
  final void Function(int pontos)? onGameOver;
  final void Function(int pontos)? onConcluida;

  // Componentes principais
  late Jogador _jogador;
  late PainelDesafio _painel;
  late Hud _hud;
  late double _topoChao;
  late Chao _chao;

  // Estado da fase
  final List<Porta> _portas = [];
  final List<Inimigo> _inimigos = [];
  final List<ObjetoCenario> _buracos = [];
  Porta? _portaAtiva;
  int _vidas = EscolaVisual.totalVidas;
  int _pontos = 0;
  bool _invencivel = false; // pisca após levar dano
  double _tempoInvencivel = 0;
  bool _encerrada = false;
  String? _feedbackMsg;
  double _tempoFeedback = 0;

  static const _duracaoInvencivel = 2.0; // segundos de piscar
  static const _duracaoFeedback = 2.5; // segundos mostrando mensagem
  static const _pontoPorPorta = 100;

  @override
  Future<void> onLoad() async {
    _topoChao = game.size.y - 48;
    final seed = semente ?? DateTime.now().millisecondsSinceEpoch;

    await _montarFundo();
    await _montarChao();
    await _montarPortas(seed);
    await _montarMesas(seed);
    await _montarBuracos(seed);
    await _montarInimigos(seed);
    await _montarJogador();
    await _montarHud();
    await _montarPainel();
    await _configurarCamera();
  }

  // ─────────────────────────────────────────────
  // Montagem da cena
  // ─────────────────────────────────────────────

  Future<void> _montarFundo() async {
    final h = game.size.y;
    try {
      final image = await game.images.load(EscolaVisual.fundo);
      final escala = h / image.height;
      final largImg = image.width * escala;

      // Repete o fundo quantas vezes precisar para cobrir o mundo
      var x = 0.0;
      while (x < EscolaVisual.larguraMundo) {
        await add(
          SpriteComponent(
            sprite: Sprite(image),
            size: Vector2(largImg, h),
            position: Vector2(x, 0),
            anchor: Anchor.topLeft,
          )..paint.filterQuality = FilterQuality.none,
        );
        x += largImg;
      }
    } catch (_) {
      // fallback colorido
      await add(
        RectangleComponent(
          size: Vector2(EscolaVisual.larguraMundo, h * 0.6),
          paint: Paint()..color = const Color(EscolaVisual.corFundoFallback),
        ),
      );
      await add(
        RectangleComponent(
          position: Vector2(0, h * 0.6),
          size: Vector2(EscolaVisual.larguraMundo, h * 0.4),
          paint: Paint()..color = const Color(EscolaVisual.corChaoFallback),
        ),
      );
    }
  }

  Future<void> _montarChao() async {
    _chao = Chao(
      altura: 48,
      largura: EscolaVisual.larguraMundo,
      topoY: _topoChao,
    );
    await add(_chao);
  }

  Future<void> _montarPortas(int seed) async {
    // Embaralha desafios e pega 5
    final pool = List.of(poolDesafiosEscola);
    pool.shuffle(Random(seed));
    final selecionados = pool.take(5).toList();

    for (var i = 0; i < EscolaVisual.portasPosicaoX.length; i++) {
      final porta = Porta(
        desafio: selecionados[i].copyWith(porta: i + 1),
        onInteragir: _abrirDesafio,
      )..position = Vector2(EscolaVisual.portasPosicaoX[i], _topoChao);
      _portas.add(porta);
      await add(porta);
    }
  }

  Future<void> _montarMesas(int seed) async {
    final posicoes = EscolaVisual.posicoesMesas(semente: seed);
    for (final x in posicoes) {
      await add(ObjetoCenario.mesa(position: Vector2(x, _topoChao)));
    }
  }

  Future<void> _montarBuracos(int seed) async {
    final posicoes = EscolaVisual.posicoesBuracos(semente: seed);
    for (final x in posicoes) {
      final buraco = ObjetoCenario.buraco(position: Vector2(x, _topoChao));
      _buracos.add(buraco as ObjetoCenario);
      await add(buraco);
    }
  }

  Future<void> _montarInimigos(int seed) async {
    final posicoes = EscolaVisual.posicoesInimigos(semente: seed);
    for (final x in posicoes) {
      final inimigo = Inimigo(
        chao: _chao,
        posicaoInicial: Vector2(x, _topoChao - EscolaVisual.alturaInimigo),
        velocidade: 60 + Random(seed + x.toInt()).nextInt(60).toDouble(),
        limiteEsquerda: (x - EscolaVisual.amplitudePatrulha).clamp(
          0,
          EscolaVisual.larguraMundo,
        ),
        limiteDireita: (x + EscolaVisual.amplitudePatrulha).clamp(
          0,
          EscolaVisual.larguraMundo,
        ),
      );
      _inimigos.add(inimigo);
      await add(inimigo);
    }
  }

  Future<void> _montarJogador() async {
    _jogador = Jogador(
      caminhoSkin: personagem.caminhoSkin,
      chao: _chao,
      limiteMundoX: EscolaVisual.larguraMundo,
    );
    await add(_jogador);
    _jogador.position = Vector2(
      EscolaVisual.inicioJogadorX,
      _topoChao - _jogador.size.y,
    );
  }

  Future<void> _montarHud() async {
    _hud = Hud(vidas: _vidas, pontos: _pontos);
    await add(_hud);
  }

  Future<void> _montarPainel() async {
    _painel = PainelDesafio(onResposta: _aoResponder);
    await add(_painel);
  }

  Future<void> _configurarCamera() async {
    game.camera.viewfinder.anchor = Anchor.center;
    game.camera.follow(_jogador);
  }

  // ─────────────────────────────────────────────
  // Lógica de desafio / porta
  // ─────────────────────────────────────────────

  void _abrirDesafio(Porta porta) {
    if (porta.concluida || _painel.aberto || _encerrada) return;
    _portaAtiva = porta;
    _painel.abrir(porta.desafio);
  }

  void _aoResponder(bool acertou) async {
    final porta = _portaAtiva;
    _portaAtiva = null;
    if (porta == null) return;

    if (acertou) {
      await porta.marcarConcluida();
      _adicionarPontos(_pontoPorPorta);
      _mostrarFeedback('Muito bem! +$_pontoPorPorta pontos ⭐');
      await _spawnarEstrela(porta.position);
      _verificarConclusao();
    } else {
      _mostrarFeedback('Ops! Tente outra vez 😊');
    }
  }

  void _verificarConclusao() {
    if (_portas.every((p) => p.concluida)) {
      _encerrada = true;
      onConcluida?.call(_pontos);
    }
  }

  // ─────────────────────────────────────────────
  // Vidas e dano
  // ─────────────────────────────────────────────

  void _levarDano() {
    if (_invencivel || _encerrada) return;

    _vidas--;
    _hud.atualizarVidas(_vidas);
    _mostrarFeedback('Ai! ❤️ $_vidas vidas restantes');

    if (_vidas <= 0) {
      _encerrada = true;
      _mostrarFeedback('Game Over! 😢');
      Future.delayed(const Duration(seconds: 2), () {
        onGameOver?.call(_pontos);
      });
      return;
    }

    // Período de invencibilidade para não perder duas vidas de uma vez
    _invencivel = true;
    _tempoInvencivel = 0;
  }

  // ─────────────────────────────────────────────
  // Pontos e estrela animada
  // ─────────────────────────────────────────────

  void _adicionarPontos(int valor) {
    _pontos += valor;
    _hud.atualizarPontos(_pontos);
  }

  Future<void> _spawnarEstrela(Vector2 posicaoPorta) async {
    final estrela = EstrelAnimada(
      posicaoInicial: Vector2(
        posicaoPorta.x,
        posicaoPorta.y - EscolaVisual.alturaPorta - 20,
      ),
    );
    await add(estrela);
  }

  // ─────────────────────────────────────────────
  // Feedback visual
  // ─────────────────────────────────────────────

  void _mostrarFeedback(String msg) {
    _feedbackMsg = msg;
    _tempoFeedback = 0;
  }

  // ─────────────────────────────────────────────
  // Update — colisões e timers
  // ─────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (_encerrada && _vidas > 0) return;

    _jogador.pausado = _painel.aberto;

    // Timer de invencibilidade — pisca o jogador
    if (_invencivel) {
      _tempoInvencivel += dt;
      _jogador.opacity = (_tempoInvencivel * 8).floor().isEven ? 1.0 : 0.3;
      if (_tempoInvencivel >= _duracaoInvencivel) {
        _invencivel = false;
        _jogador.opacity = 1.0;
      }
    }

    // Timer do feedback
    if (_feedbackMsg != null) {
      _tempoFeedback += dt;
      if (_tempoFeedback >= _duracaoFeedback) _feedbackMsg = null;
    }

    if (_painel.aberto) return;

    final centroJogador = _jogador.position + _jogador.size / 2;

    // Colisão com inimigos
    for (final inimigo in _inimigos) {
      if (!inimigo.vivo) continue;
      if (inimigo.contemPonto(centroJogador)) {
        // Pula em cima — derrota o inimigo
        final caindoEmCima =
            _jogador.velocidadeY > 0 &&
            _jogador.position.y + _jogador.size.y <
                inimigo.position.y + inimigo.size.y * 0.5;
        if (caindoEmCima) {
          inimigo.derrotar();
          _adicionarPontos(50);
          _mostrarFeedback('+50 pontos! 🎉');
          // Pequeno pulo ao derrotar
          _jogador.velocidadeY = -300;
        } else {
          _levarDano();
        }
      }
    }

    // Colisão com buracos — perde uma vida e volta ao início
    for (final buraco in _buracos) {
      if (buraco.contemPonto(centroJogador)) {
        _levarDano();
        if (_vidas > 0) {
          _jogador.position = Vector2(
            EscolaVisual.inicioJogadorX,
            _topoChao - _jogador.size.y,
          );
        }
      }
    }

    // Interação automática ao chegar perto da porta (sem precisar apertar E)
    final portaProxima = _portaProxima();
    if (portaProxima != null && !_painel.aberto) {
      _abrirDesafio(portaProxima);
    }
  }

  Porta? _portaProxima() {
    final centro = _jogador.position + _jogador.size / 2;
    for (final porta in _portas) {
      if (!porta.concluida && porta.contemJogador(centro)) return porta;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // Render — feedback flutuante
  // ─────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final msg = _feedbackMsg;
    if (msg == null) return;

    final tp = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 6)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: game.size.x - 48);

    tp.paint(canvas, Offset((game.size.x - tp.width) / 2, game.size.y * 0.15));
  }

  // ─────────────────────────────────────────────
  // Teclado — tecla E abre porta (alternativo ao automático)
  // ─────────────────────────────────────────────

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
