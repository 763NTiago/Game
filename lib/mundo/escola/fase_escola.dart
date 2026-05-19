import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/jogador.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/mundo/chao.dart';
import 'package:meu_jogo/mundo/escola/desafio_config.dart';
import 'package:meu_jogo/mundo/escola/desafios_escola.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';
import 'package:meu_jogo/mundo/escola/painel_desafio.dart';
import 'package:meu_jogo/mundo/escola/porta.dart';

/// Fase principal da escola.
///
/// Estrutura do mundo (por seção 0‥4):
///   8 tiles do fundoN.png  →  porta com desafio (porta 5 = vitória direta)
///
/// Câmera: dead zone 30 % borda esquerda / 40 % borda direita da viewport.
class FaseEscola extends Component
    with HasGameReference<FlameGame>, KeyboardHandler {
  FaseEscola({
    required this.personagem,
    this.onGameOver,
    this.onConcluida,
    this.onMenu,
  });

  final Personagem personagem;
  final void Function(int pontos)? onGameOver;
  final void Function(int pontos)? onConcluida;
  final void Function()? onMenu;

  late Jogador _jogador;
  late Chao _chao;
  late PainelDesafio _painel;

  double _larguraTile = EscolaVisual.larguraTileRef;

  final List<Porta> _portas = [];
  int _portasResolvidas = 0;

  late List<DesafioConfig> _desafiosSorteados;

  double _cameraX = 0;
  int _pontos = 0;
  int _vidas = EscolaVisual.totalVidas;
  bool _desafioAberto = false;

  World get _world => game.world;

  // ─────────────────────────────────────────────────────────────────────────
  // Carregamento
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    _sortearDesafios();
    await _montarFundo();
    await _montarChao();
    await _montarPortas();
    await _montarJogador();
    await _montarPainel();
    _configurarCamera();
  }

  void _sortearDesafios() {
    final pool = List<DesafioConfig>.from(poolDesafiosEscola)..shuffle();
    _desafiosSorteados = pool
        .take(EscolaVisual.totalPortas)
        .toList()
        .asMap()
        .entries
        .map((e) => e.value.copyWith(porta: e.key + 1))
        .toList();
  }

  // ── Fundo ─────────────────────────────────────────────────────────────────
  // Para cada seção coloca 8 tiles do fundoN + 1 tile cobrindo o espaço da porta.
  // A largura real do tile é calculada da primeira imagem carregada.

  Future<void> _montarFundo() async {
    final screenH = game.size.y;
    final screenW = game.size.x;
    final Map<String, ui.Image> cache = {};

    for (var secao = 0; secao < EscolaVisual.totalPortas; secao++) {
      final caminho = EscolaVisual.fundoDaSecao(secao);

      ui.Image? img;
      try {
        img = cache[caminho] ?? await game.images.load(caminho);
        cache[caminho] = img!;
      } catch (_) {}

      // Calcula escala e tamanho do tile
      double largTile;
      double altTile;
      Sprite? sprite;

      if (img != null) {
        final escalaH = screenH / img.height;
        largTile = img.width * escalaH;
        if (largTile < screenW) largTile = screenW.toDouble();
        altTile = screenH;
        sprite = Sprite(img);
      } else {
        largTile = screenW;
        altTile = screenH;
      }

      if (secao == 0) _larguraTile = largTile;

      final xSecaoInicio =
          secao *
          (EscolaVisual.tilesPorSecao * _larguraTile +
              EscolaVisual.espacoPorta);

      // 8 tiles de fundo
      for (var t = 0; t < EscolaVisual.tilesPorSecao; t++) {
        final xTile = xSecaoInicio + t * _larguraTile;
        if (sprite != null) {
          await _world.add(
            SpriteComponent(
              sprite: sprite,
              size: Vector2(_larguraTile, altTile),
              position: Vector2(xTile, 0),
              anchor: Anchor.topLeft,
            )..paint.filterQuality = FilterQuality.none,
          );
        } else {
          await _world.add(
            RectangleComponent(
              position: Vector2(xTile, 0),
              size: Vector2(_larguraTile, altTile),
              paint: Paint()
                ..color = const Color(EscolaVisual.corFundoFallback),
            ),
          );
        }
      }

      // Tile cobrindo o espaço da porta (repete o fundo)
      final xPortaArea =
          xSecaoInicio + EscolaVisual.tilesPorSecao * _larguraTile;
      if (sprite != null) {
        await _world.add(
          SpriteComponent(
            sprite: sprite,
            size: Vector2(EscolaVisual.espacoPorta, altTile),
            position: Vector2(xPortaArea, 0),
            anchor: Anchor.topLeft,
          )..paint.filterQuality = FilterQuality.none,
        );
      } else {
        await _world.add(
          RectangleComponent(
            position: Vector2(xPortaArea, 0),
            size: Vector2(EscolaVisual.espacoPorta, altTile),
            paint: Paint()..color = const Color(EscolaVisual.corFundoFallback),
          ),
        );
      }
    }
  }

  // ── Chão ──────────────────────────────────────────────────────────────────

  Future<void> _montarChao() async {
    final topoChao = game.size.y * 0.88;
    final alturaChao = game.size.y - topoChao;

    _chao = Chao(
      altura: alturaChao,
      largura: EscolaVisual.larguraMundo(larguraTile: _larguraTile),
      topoY: topoChao,
    );
    await _world.add(_chao);
  }

  // ── Portas ────────────────────────────────────────────────────────────────

  Future<void> _montarPortas() async {
    for (var i = 0; i < EscolaVisual.totalPortas; i++) {
      final xCentro = EscolaVisual.xPorta(i, larguraTile: _larguraTile);
      final desafio = _desafiosSorteados[i];

      final porta = Porta(desafio: desafio, onInteragir: _aoInteragirComPorta);
      porta.position = Vector2(xCentro, _chao.topo);
      _portas.add(porta);
      await _world.add(porta);
    }
  }

  // ── Jogador ───────────────────────────────────────────────────────────────

  Future<void> _montarJogador() async {
    _jogador = Jogador(
      caminhoSkin: personagem.caminhoSkin,
      chao: _chao,
      limiteMundoX: EscolaVisual.larguraMundo(larguraTile: _larguraTile),
    );
    await _world.add(_jogador);
    _jogador.position = Vector2(
      EscolaVisual.inicioJogadorX,
      _chao.topo - _jogador.size.y,
    );
  }

  // ── Painel ────────────────────────────────────────────────────────────────

  Future<void> _montarPainel() async {
    _painel = PainelDesafio(onResposta: _aoResponder);
    await game.add(_painel);
  }

  // ── Câmera ────────────────────────────────────────────────────────────────

  void _configurarCamera() {
    game.camera.viewfinder.zoom = 1.0;
    game.camera.viewfinder.anchor = Anchor.center;
    _cameraX = 0;
    _aplicarCamera();
    game.camera.setBounds(
      Rectangle.fromLTWH(
        0,
        0,
        EscolaVisual.larguraMundo(larguraTile: _larguraTile),
        game.size.y,
      ),
    );
    game.camera.stop();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Update
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _jogador.pausado = _desafioAberto;
    if (_desafioAberto) return;
    _verificarColisaoPortas();
    _atualizarCamera();
  }

  // ── Colisão com portas ────────────────────────────────────────────────────

  void _verificarColisaoPortas() {
    final centro = _jogador.absoluteCenter;
    for (final porta in _portas) {
      if (!porta.concluida && porta.contemJogador(centro)) {
        _aoInteragirComPorta(porta);
        break;
      }
    }
  }

  void _aoInteragirComPorta(Porta porta) {
    if (_desafioAberto || porta.concluida) return;
    final indice = _portas.indexOf(porta);

    // Última porta → vitória direta
    if (indice == EscolaVisual.totalPortas - 1) {
      porta.marcarConcluida();
      _portasResolvidas++;
      _pontos += 100;
      Future.delayed(const Duration(milliseconds: 600), () {
        onConcluida?.call(_pontos);
      });
      return;
    }

    _desafioAberto = true;
    _painel.abrir(_desafiosSorteados[indice]);
  }

  // ── Resposta do desafio ───────────────────────────────────────────────────

  void _aoResponder(bool acertou) {
    _desafioAberto = false;

    // Porta mais próxima não-concluída
    final centro = _jogador.absoluteCenter;
    Porta? alvo;
    double menor = double.infinity;
    for (final p in _portas) {
      if (p.concluida) continue;
      final d = (p.absoluteCenter.x - centro.x).abs();
      if (d < menor) {
        menor = d;
        alvo = p;
      }
    }

    if (acertou) {
      alvo?.marcarConcluida();
      _portasResolvidas++;
      _pontos += 100;

      if (_portasResolvidas >= EscolaVisual.totalPortas) {
        Future.delayed(const Duration(milliseconds: 800), () {
          onConcluida?.call(_pontos);
        });
      }
    } else {
      _vidas--;
      if (_vidas <= 0) {
        Future.delayed(const Duration(milliseconds: 400), () {
          onGameOver?.call(_pontos);
        });
      }
    }
  }

  // ── Dead zone 30 % / 40 % ────────────────────────────────────────────────

  void _atualizarCamera() {
    final screenW = game.size.x;
    final mundo = EscolaVisual.larguraMundo(larguraTile: _larguraTile);

    final deadLeft = _cameraX + screenW * EscolaVisual.deadZoneEsquerda;
    final deadRight = _cameraX + screenW * (1.0 - EscolaVisual.deadZoneDireita);
    final jogX = _jogador.position.x + _jogador.size.x / 2;

    if (jogX < deadLeft) {
      _cameraX = jogX - screenW * EscolaVisual.deadZoneEsquerda;
    } else if (jogX > deadRight) {
      _cameraX = jogX - screenW * (1.0 - EscolaVisual.deadZoneDireita);
    }

    _cameraX = _cameraX.clamp(0.0, mundo - screenW);
    _aplicarCamera();
  }

  void _aplicarCamera() {
    game.camera.viewfinder.position = Vector2(
      _cameraX + game.size.x / 2,
      game.size.y / 2,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Limpeza
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onRemove() {
    super.onRemove();
    _painel.removeFromParent();
    game.camera.stop();
    _world.removeAll(_world.children.toList());
  }

  // ── ESC ───────────────────────────────────────────────────────────────────

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_desafioAberto) {
        _painel.fechar();
        _desafioAberto = false;
        return true;
      }
      onMenu?.call();
      return true;
    }
    return false;
  }
}
