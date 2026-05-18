import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/menu/menu_visual.dart';
import 'package:meu_jogo/mundo/escola/escola_visual.dart';

class Menu extends Component with HasGameReference<FlameGame>, KeyboardHandler {
  Menu({required this.onSelecionado});

  final void Function(Personagem personagem) onSelecionado;

  int indiceSelecionado = 0;
  final List<SpriteComponent> previews = [];

  double _tempo = 0;
  final List<_Estrela> _estrelas = [];
  final _rng = Random(42);

  @override
  Future<void> onLoad() async {
    _gerarEstrelas();
    await _montarFundo();
    await _montarTitulo();
    await _montarPersonagens();
    await _montarCardFase();
    await add(_MolduraSelecao(this));
    await _montarInstrucoes();
  }

  void _gerarEstrelas() {
    for (var i = 0; i < 55; i++) {
      _estrelas.add(
        _Estrela(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          tamanho: 1.0 + _rng.nextDouble() * 2.5,
          velocidade: 0.15 + _rng.nextDouble() * 0.4,
          fase: _rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  Future<void> _montarFundo() async {
    await add(_FundoAnimado(estrelas: _estrelas));
  }

  Future<void> _montarTitulo() async {
    await add(
      TextComponent(
        text: MenuVisual.titulo,
        anchor: Anchor.topCenter,
        position: Vector2(game.size.x / 2, MenuVisual.tituloY),
        textRenderer: TextPaint(style: MenuVisual.estiloTitulo),
      ),
    );
    await add(
      TextComponent(
        text: MenuVisual.subtitulo,
        anchor: Anchor.topCenter,
        position: Vector2(game.size.x / 2, MenuVisual.subtituloY),
        textRenderer: TextPaint(style: MenuVisual.estiloSubtitulo),
      ),
    );
  }

  Future<void> _montarPersonagens() async {
    final centroY = game.size.y * MenuVisual.previewCentroY;
    final offsetX = game.size.x * MenuVisual.previewOffsetX;

    for (var i = 0; i < Personagem.values.length; i++) {
      final personagem = Personagem.values[i];
      final image = await game.images.load(personagem.caminhoSkin);
      final frameW = image.width / colunasSpritesheet;
      final frameH = image.height.toDouble();
      final escala = MenuVisual.alturaPreviewMenu / frameH;
      final tamanhoPreview = Vector2(frameW, frameH) * escala;

      final preview = SpriteComponent(
        sprite: Sprite(image, srcSize: Vector2(frameW, frameH)),
        size: tamanhoPreview,
        anchor: Anchor.center,
        position: Vector2(
          game.size.x / 2 + (i == 0 ? -offsetX : offsetX),
          centroY,
        ),
      )..paint.filterQuality = FilterQuality.none;
      previews.add(preview);
      await add(preview);

      await add(
        _BadgeNome(
          nome: personagem.nomeExibicao,
          posicao: Vector2(
            preview.position.x,
            centroY +
                MenuVisual.alturaPreviewMenu / 2 +
                MenuVisual.nomeAbaixoPreview,
          ),
        ),
      );
    }
  }

  Future<void> _montarCardFase() async {
    final cardY = game.size.y * 0.72;
    final cardX = game.size.x / 2;

    await add(
      _CardFase(
        posicao: Vector2(cardX, cardY),
        caminhoThumb: EscolaVisual.fundo,
      ),
    );
  }

  Future<void> _montarInstrucoes() async {
    await add(
      TextComponent(
        text: MenuVisual.instrucoes,
        anchor: Anchor.bottomCenter,
        position: Vector2(
          game.size.x / 2,
          game.size.y - MenuVisual.instrucoesY,
        ),
        textRenderer: TextPaint(style: MenuVisual.estiloInstrucoes),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;

    for (var i = 0; i < previews.length; i++) {
      if (i == indiceSelecionado) {
        previews[i].opacity = 1.0;
        final pulso = 1.0 + sin(_tempo * 3.0) * 0.04;
        previews[i].scale = Vector2.all(pulso);
      } else {
        previews[i].opacity = MenuVisual.opacidadeNaoSelecionado;
        previews[i].scale = Vector2.all(1.0);
      }
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.keyA:
        indiceSelecionado = 0;
        return true;
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.keyD:
        indiceSelecionado = 1;
        return true;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        onSelecionado(Personagem.values[indiceSelecionado]);
        return true;
      default:
        return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fundo animado com gradiente + estrelas piscantes
// ─────────────────────────────────────────────────────────────────────────────

class _FundoAnimado extends PositionComponent with HasGameReference<FlameGame> {
  _FundoAnimado({required this.estrelas});
  final List<_Estrela> estrelas;
  double _tempo = 0;

  @override
  Future<void> onLoad() async {
    size = game.size;
  }

  @override
  void update(double dt) {
    _tempo += dt;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Gradiente de fundo via dart:ui (funciona dentro do Canvas do Flame)
    final paintFundo = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(w, h),
        const [Color(0xFF0D1B2A), Color(0xFF1A1240), Color(0xFF0D2137)],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paintFundo);

    // Faixa de brilho suave no topo
    final paintBrilho = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w / 2, 0),
        Offset(w / 2, h * 0.4),
        const [Color(0x223D5AFE), Color(0x00000000)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.4), paintBrilho);

    // Estrelas piscantes
    for (final e in estrelas) {
      final opacidade = (sin(_tempo * e.velocidade + e.fase) * 0.4 + 0.6).clamp(
        0.0,
        1.0,
      );
      canvas.drawCircle(
        Offset(e.x * w, e.y * h),
        e.tamanho,
        Paint()..color = Color.fromRGBO(255, 255, 255, opacidade),
      );
    }

    // Linha decorativa abaixo do título
    final paintLinha = Paint()
      ..shader = ui.Gradient.linear(
        Offset(w * 0.1, 108),
        Offset(w * 0.9, 108),
        const [Color(0x003D5AFE), Color(0xFF3D5AFE), Color(0x003D5AFE)],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(w * 0.1, 108, w * 0.8, 1.5), paintLinha);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Moldura com glow ao redor do personagem selecionado
// ─────────────────────────────────────────────────────────────────────────────

class _MolduraSelecao extends Component with HasGameReference<FlameGame> {
  _MolduraSelecao(this.menu);
  final Menu menu;
  double _tempo = 0;

  @override
  void update(double dt) => _tempo += dt;

  @override
  void render(Canvas canvas) {
    final preview = menu.previews[menu.indiceSelecionado];
    final r = Rect.fromCenter(
      center: Offset(preview.position.x, preview.position.y),
      width: preview.size.x + MenuVisual.paddingMoldura,
      height: preview.size.y + MenuVisual.paddingMoldura,
    );
    final rr = RRect.fromRectAndRadius(
      r,
      Radius.circular(MenuVisual.raioMoldura),
    );

    // Glow pulsante
    final intensidade = (sin(_tempo * 3.5) * 0.3 + 0.7).clamp(0.0, 1.0);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = Color.fromRGBO(255, 235, 59, intensidade * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Borda sólida
    canvas.drawRRect(
      rr,
      Paint()
        ..color = MenuVisual.corMolduraSelecao
        ..style = PaintingStyle.stroke
        ..strokeWidth = MenuVisual.espessuraMoldura,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge com nome do personagem
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeNome extends PositionComponent with HasGameReference<FlameGame> {
  _BadgeNome({required this.nome, required Vector2 posicao}) {
    position = posicao;
    anchor = Anchor.topCenter;
  }

  final String nome;

  @override
  void render(Canvas canvas) {
    final tp = TextPainter(
      text: TextSpan(text: nome, style: MenuVisual.estiloNome),
      textDirection: TextDirection.ltr,
    )..layout();

    const padH = 12.0;
    const padV = 6.0;
    final w = tp.width + padH * 2;
    final h = tp.height + padV * 2;

    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, h / 2), width: w, height: h),
      const Radius.circular(10),
    );

    canvas.drawRRect(rr, Paint()..color = const Color(0x993D5AFE));
    canvas.drawRRect(
      rr,
      Paint()
        ..color = const Color(0xFF3D5AFE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    tp.paint(canvas, Offset(-tp.width / 2, padV));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de preview da fase
// ─────────────────────────────────────────────────────────────────────────────

class _CardFase extends PositionComponent with HasGameReference<FlameGame> {
  _CardFase({required Vector2 posicao, required this.caminhoThumb}) {
    position = posicao;
    anchor = Anchor.topCenter;
  }

  final String caminhoThumb;
  SpriteComponent? _thumb;
  bool _carregado = false;

  @override
  Future<void> onLoad() async {
    size = Vector2(MenuVisual.larguraCardFase, MenuVisual.alturaCardFase);

    try {
      final image = await game.images.load(caminhoThumb);
      final thumbH = MenuVisual.alturaCardFase - 16;
      final escala = thumbH / image.height;
      final thumbW = (image.width * escala).clamp(
        0.0,
        MenuVisual.larguraCardFase * 0.38,
      );

      _thumb = SpriteComponent(
        sprite: Sprite(image),
        size: Vector2(thumbW, thumbH),
        position: Vector2(10, 8),
        anchor: Anchor.topLeft,
      )..paint.filterQuality = FilterQuality.none;
      add(_thumb!);
    } catch (_) {
      // fallback: emoji desenhado no render()
    }
    _carregado = true;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(14),
    );
    canvas.drawRRect(rr, Paint()..color = MenuVisual.corCardFundo);
    canvas.drawRRect(
      rr,
      Paint()
        ..color = MenuVisual.corCardBorda
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    if (!_carregado) return;

    final sepX = MenuVisual.larguraCardFase * 0.42;

    canvas.drawRect(
      Rect.fromLTWH(sepX, 12, 1, h - 24),
      Paint()..color = const Color(0x553D5AFE),
    );

    final tpTitulo = TextPainter(
      text: const TextSpan(
        text: '🏫  Fase 1  —  Escola',
        style: MenuVisual.estiloTituloFase,
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - sepX - 16);
    tpTitulo.paint(canvas, Offset(sepX + 12, 16));

    final tpDesc = TextPainter(
      text: const TextSpan(
        text:
            '5 portas com desafios\n'
            '🔢 Matemática  📝 Palavras  🔤 Letras\n'
            '⭐ Até 500 pontos',
        style: MenuVisual.estiloDescFase,
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - sepX - 16);
    tpDesc.paint(canvas, Offset(sepX + 12, 42));

    if (_thumb == null) {
      final tp = TextPainter(
        text: const TextSpan(text: '🏫', style: TextStyle(fontSize: 44)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(10 + (sepX - 10) / 2 - tp.width / 2, h / 2 - tp.height / 2),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dados de estrela de fundo
// ─────────────────────────────────────────────────────────────────────────────

class _Estrela {
  const _Estrela({
    required this.x,
    required this.y,
    required this.tamanho,
    required this.velocidade,
    required this.fase,
  });

  final double x;
  final double y;
  final double tamanho;
  final double velocidade;
  final double fase;
}
