import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/menu/menu_visual.dart';

/// Menu principal — tema "Quadro de Avisos de Cortiça".
///
/// Layout:
///   • Fundo: textura de cortiça desenhada via Canvas (sem imagem externa).
///   • Título: banner de papel colado no quadro com alfinetes nas pontas.
///   • Personagens: "fotos Polaroid" afixadas com alfinete, balançam suavemente.
///   • Navegação: ←/→ (ou A/D) muda seleção; Enter/Espaço confirma.
///   • Card de fase: bilhete pautado no rodapé do quadro.
class Menu extends Component with HasGameReference<FlameGame>, KeyboardHandler {
  Menu({required this.onSelecionado});

  final void Function(Personagem personagem) onSelecionado;

  int indiceSelecionado = 0;

  // Sprites das personagens (Polaroid)
  final List<ui.Image?> _imgPersonagens = [null, null];

  // Sprite do fundo da fase (thumbnail no bilhete)
  ui.Image? _imgFundo;

  // Animação contínua
  double _tempo = 0;

  // Alfinetes decorativos
  final List<_Alfinete> _alfinetes = [];
  final _rng = Random(99);

  @override
  Future<void> onLoad() async {
    // Carrega imagens das skins para preview
    for (var i = 0; i < Personagem.values.length; i++) {
      try {
        _imgPersonagens[i] = await game.images.load(
          Personagem.values[i].caminhoSkin,
        );
      } catch (_) {}
    }

    // Thumbnail da fase
    try {
      _imgFundo = await game.images.load('mundo/escola/fundo.png');
    } catch (_) {}

    _gerarAlfinetesDecorativos();
  }

  void _gerarAlfinetesDecorativos() {
    // Alfinetes espalhados pelo quadro (decoração)
    for (var i = 0; i < 18; i++) {
      _alfinetes.add(
        _Alfinete(
          x: 60 + _rng.nextDouble() * (game.size.x - 120),
          y: 30 + _rng.nextDouble() * (game.size.y - 60),
          cor: MenuVisual
              .coresAlfinetes[_rng.nextInt(MenuVisual.coresAlfinetes.length)],
        ),
      );
    }
  }

  // ───────────────────────────────────────
  // Update
  // ───────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;
  }

  // ───────────────────────────────────────
  // Render principal
  // ───────────────────────────────────────

  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    _desenharCortica(canvas, w, h);
    _desenharAlfinetes(canvas);
    _desenharBanner(canvas, w);
    _desenharSubtitulo(canvas, w);
    _desenharPersonagens(canvas, w, h);
    _desenharBilheteFase(canvas, w, h);
    _desenharInstrucoes(canvas, w, h);
  }

  // ── Textura de cortiça ──────────────────────────────────────────────────────

  void _desenharCortica(Canvas canvas, double w, double h) {
    // Base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = MenuVisual.corCorticaBase,
    );

    // Grade de "células" de cortiça
    const cellW = 22.0;
    const cellH = 18.0;
    final cols = (w / cellW).ceil() + 1;
    final rows = (h / cellH).ceil() + 1;

    final paintCell = Paint()..style = PaintingStyle.fill;
    final paintBorda = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0x22000000);

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        // Varia a cor levemente para textura orgânica
        final seed = r * 37 + c * 13;
        final variacao = ((seed % 7) - 3) * 6;
        final base = MenuVisual.corCorticaBase;
        paintCell.color = Color.fromARGB(
          255,
          (base.red + variacao).clamp(150, 210),
          (base.green + variacao - 8).clamp(100, 160),
          (base.blue + variacao - 20).clamp(50, 100),
        );

        final ox = (r % 2 == 0) ? 0.0 : cellW * 0.5;
        final rx = c * cellW + ox;
        final ry = r * cellH;

        final rrect = RRect.fromRectAndRadius(
          Rect.fromLTWH(rx + 1, ry + 1, cellW - 2, cellH - 2),
          const Radius.circular(3),
        );
        canvas.drawRRect(rrect, paintCell);
        canvas.drawRRect(rrect, paintBorda);

        // Marca de "poro" pequena
        if (seed % 5 == 0) {
          canvas.drawCircle(
            Offset(rx + cellW * 0.6, ry + cellH * 0.4),
            1.2,
            Paint()..color = const Color(0x33000000),
          );
        }
      }
    }

    // Moldura de madeira ao redor do quadro
    _desenharMoldura(canvas, w, h);
  }

  void _desenharMoldura(Canvas canvas, double w, double h) {
    const e = 14.0; // espessura
    final paintMadeira = Paint()..color = MenuVisual.corMoldura;
    // Topo, baixo, esquerda, direita
    canvas.drawRect(Rect.fromLTWH(0, 0, w, e), paintMadeira);
    canvas.drawRect(Rect.fromLTWH(0, h - e, w, e), paintMadeira);
    canvas.drawRect(Rect.fromLTWH(0, 0, e, h), paintMadeira);
    canvas.drawRect(Rect.fromLTWH(w - e, 0, e, h), paintMadeira);
    // Cantos arredondados de madeira
    final paintEscuro = Paint()..color = MenuVisual.corMolduraEscura;
    for (final c in [
      Offset(0, 0),
      Offset(w - 28, 0),
      Offset(0, h - 28),
      Offset(w - 28, h - 28),
    ]) {
      canvas.drawRect(Rect.fromLTWH(c.dx, c.dy, 28, 28), paintEscuro);
      // Parafuso decorativo
      canvas.drawCircle(
        Offset(c.dx + 14, c.dy + 14),
        6,
        Paint()..color = const Color(0xFF9E9E9E),
      );
      canvas.drawCircle(
        Offset(c.dx + 14, c.dy + 14),
        4,
        Paint()..color = const Color(0xFF757575),
      );
      // Fenda do parafuso
      canvas.drawLine(
        Offset(c.dx + 11, c.dy + 14),
        Offset(c.dx + 17, c.dy + 14),
        Paint()
          ..color = const Color(0xFF424242)
          ..strokeWidth = 1.5,
      );
    }
  }

  // ── Alfinetes decorativos ───────────────────────────────────────────────────

  void _desenharAlfinetes(Canvas canvas) {
    for (final a in _alfinetes) {
      _desenharAlfinete(canvas, a.x, a.y, a.cor);
    }
  }

  void _desenharAlfinete(Canvas canvas, double x, double y, Color cor) {
    // Haste
    canvas.drawLine(
      Offset(x, y),
      Offset(x, y + 8),
      Paint()
        ..color = const Color(0xFF9E9E9E)
        ..strokeWidth = 1.2,
    );
    // Cabeça
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = cor);
    canvas.drawCircle(
      Offset(x - 1, y - 1),
      1.5,
      Paint()..color = Colors.white.withOpacity(0.5),
    );
  }

  // ── Banner do título ────────────────────────────────────────────────────────

  void _desenharBanner(Canvas canvas, double w) {
    final cx = w / 2;
    const bannerW = 520.0;
    const bannerH = 58.0;
    const bannerY = 28.0;

    canvas.save();
    canvas.translate(cx, bannerY + bannerH / 2);
    final swing = sin(_tempo * 0.6) * 0.006;
    canvas.rotate(swing);
    canvas.translate(-cx, -(bannerY + bannerH / 2));

    // Sombra do papel
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 3, bannerY + bannerH / 2 + 4),
          width: bannerW,
          height: bannerH,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0x33000000),
    );

    // Papel do banner
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, bannerY + bannerH / 2),
          width: bannerW,
          height: bannerH,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = MenuVisual.corBannerFundo,
    );

    // Listras decorativas no banner
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          cx - bannerW / 2 + i * (bannerW / 6),
          bannerY,
          bannerW / 6,
          bannerH,
        ),
        Paint()
          ..color = MenuVisual
              .coresBannerListras[i % MenuVisual.coresBannerListras.length],
      );
    }

    // Texto do título
    final pb =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          )
          ..pushStyle(
            ui.TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Color(0x88000000),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          )
          ..addText('🏫  Aventura na Escola');
    final para = pb.build()..layout(ui.ParagraphConstraints(width: bannerW));
    canvas.drawParagraph(para, Offset(cx - bannerW / 2, bannerY + 14));

    canvas.restore();

    // Alfinetes nas pontas do banner
    _desenharAlfinete(
      canvas,
      cx - bannerW / 2 + 20,
      bannerY + 4,
      const Color(0xFFE53935),
    );
    _desenharAlfinete(
      canvas,
      cx + bannerW / 2 - 20,
      bannerY + 4,
      const Color(0xFFE53935),
    );
  }

  // ── Subtítulo (bilhete pequeno) ─────────────────────────────────────────────

  void _desenharSubtitulo(Canvas canvas, double w) {
    final cx = w / 2;
    const subW = 260.0;
    const subH = 28.0;
    const subY = 94.0;

    canvas.save();
    canvas.translate(cx, subY + subH / 2);
    canvas.rotate(sin(_tempo * 0.8 + 1) * 0.008);
    canvas.translate(-cx, -(subY + subH / 2));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, subY + subH / 2),
          width: subW,
          height: subH,
        ),
        const Radius.circular(3),
      ),
      Paint()..color = MenuVisual.corSubtituloBg,
    );

    final pb =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(
            ui.TextStyle(color: MenuVisual.corSubtituloTexto, fontSize: 14),
          )
          ..addText('Escolha sua personagem');
    final para = pb.build()..layout(ui.ParagraphConstraints(width: subW));
    canvas.drawParagraph(para, Offset(cx - subW / 2, subY + 6));

    canvas.restore();
    _desenharAlfinete(canvas, cx, subY + 2, const Color(0xFF1E88E5));
  }

  // ── Polaroids das personagens ───────────────────────────────────────────────

  void _desenharPersonagens(Canvas canvas, double w, double h) {
    final centroY = h * 0.47;
    final offsetX = w * 0.22;

    for (var i = 0; i < Personagem.values.length; i++) {
      final personagem = Personagem.values[i];
      final isSelected = i == indiceSelecionado;
      final px = w / 2 + (i == 0 ? -offsetX : offsetX);
      final angulo = i == 0 ? -0.04 : 0.04;
      final swing = sin(_tempo * (0.7 + i * 0.3) + i * 1.5) * 0.012;

      canvas.save();
      canvas.translate(px, centroY - 80); // pivô no alfinete (topo)
      canvas.rotate(angulo + swing);
      canvas.translate(-px, -(centroY - 80));

      _desenharPolaroid(
        canvas,
        cx: px,
        cy: centroY,
        img: _imgPersonagens[i],
        nome: personagem.nomeExibicao,
        selecionado: isSelected,
        tempo: _tempo,
        indice: i,
      );

      canvas.restore();

      // Alfinete no topo do Polaroid
      _desenharAlfinete(
        canvas,
        px,
        centroY - 80,
        isSelected ? const Color(0xFFFFEB3B) : const Color(0xFF9E9E9E),
      );
    }
  }

  void _desenharPolaroid(
    Canvas canvas, {
    required double cx,
    required double cy,
    required ui.Image? img,
    required String nome,
    required bool selecionado,
    required double tempo,
    required int indice,
  }) {
    const pW = 160.0; // largura do Polaroid
    const pH = 190.0; // altura total
    const fotoH = 130.0; // área da foto
    const rodapeH = pH - fotoH; // área branca inferior

    final left = cx - pW / 2;
    final top = cy - pH / 2;

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 5, top + 6, pW, pH),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0x44000000),
    );

    // Corpo branco do Polaroid
    canvas.drawRect(
      Rect.fromLTWH(left, top, pW, pH),
      Paint()..color = Colors.white,
    );

    // Área da foto
    final fotoRect = Rect.fromLTWH(left + 8, top + 8, pW - 16, fotoH);

    if (img != null) {
      // Renderiza frame 0 do spritesheet na área da foto
      final frameW = img.width / colunasSpritesheet;
      final frameH = img.height.toDouble();
      final src = Rect.fromLTWH(0, 0, frameW, frameH);

      canvas.save();
      canvas.clipRect(fotoRect);
      // Preenche a área de foto mantendo proporção e centralizando
      final escX = fotoRect.width / frameW;
      final escY = fotoRect.height / frameH;
      final esc = escX < escY ? escX : escY;
      final dW = frameW * esc;
      final dH = frameH * esc;
      final dst = Rect.fromLTWH(
        fotoRect.left + (fotoRect.width - dW) / 2,
        fotoRect.top + (fotoRect.height - dH) / 2,
        dW,
        dH,
      );
      canvas.drawImageRect(
        img,
        src,
        dst,
        Paint()..filterQuality = FilterQuality.none,
      );
      canvas.restore();
    } else {
      // Placeholder colorido
      canvas.drawRect(
        fotoRect,
        Paint()
          ..color = indice == 0
              ? const Color(0xFFE3F2FD)
              : const Color(0xFFFCE4EC),
      );
      final pb =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(ui.TextStyle(fontSize: 40))
            ..addText(indice == 0 ? '👩' : '👧');
      final para = pb.build()
        ..layout(ui.ParagraphConstraints(width: fotoRect.width));
      canvas.drawParagraph(para, Offset(fotoRect.left, fotoRect.top + 30));
    }

    // Borda interna da foto (estilo Polaroid)
    canvas.drawRect(
      fotoRect,
      Paint()
        ..color = Colors.white.withOpacity(0.0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Rodapé branco com nome escrito à mão (fonte monospace simula caligrafia)
    final nomeBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(
            ui.TextStyle(
              color: const Color(0xFF37474F),
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
          )
          ..addText(nome);
    final nomePara = nomeBuilder.build()
      ..layout(ui.ParagraphConstraints(width: pW - 16));
    canvas.drawParagraph(nomePara, Offset(left + 8, top + fotoH + 12));

    // Linha decorativa abaixo do nome (estilo papel)
    canvas.drawLine(
      Offset(left + 20, top + fotoH + rodapeH - 14),
      Offset(left + pW - 20, top + fotoH + rodapeH - 14),
      Paint()
        ..color = const Color(0xFFB0BEC5)
        ..strokeWidth = 0.8,
    );

    // Borda externa do Polaroid
    canvas.drawRect(
      Rect.fromLTWH(left, top, pW, pH),
      Paint()
        ..color = selecionado ? MenuVisual.corSelecao : const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = selecionado ? 3.5 : 1.5,
    );

    // Brilho de seleção (glow amarelo pulsante)
    if (selecionado) {
      final intensidade = (sin(tempo * 3.5) * 0.3 + 0.7).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(left - 4, top - 4, pW + 8, pH + 8),
        Paint()
          ..color = MenuVisual.corSelecao.withOpacity(intensidade * 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Badge "SELECIONADO"
      final badgeLeft = cx - 52.0;
      final badgeTop = top + pH + 10;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(badgeLeft, badgeTop, 104, 22),
          const Radius.circular(11),
        ),
        Paint()..color = MenuVisual.corSelecao,
      );
      final badgePb =
          ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(
              ui.TextStyle(
                color: const Color(0xFF212121),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
            ..addText('★ SELECIONADO');
      final badgePara = badgePb.build()
        ..layout(ui.ParagraphConstraints(width: 104));
      canvas.drawParagraph(badgePara, Offset(badgeLeft, badgeTop + 4));
    }
  }

  // ── Bilhete da fase (rodapé) ────────────────────────────────────────────────

  void _desenharBilheteFase(Canvas canvas, double w, double h) {
    final cx = w / 2;
    const bW = 480.0;
    const bH = 100.0;
    final bY = h * 0.76;

    canvas.save();
    canvas.translate(cx, bY + bH / 2);
    canvas.rotate(sin(_tempo * 0.5 + 2) * 0.005);
    canvas.translate(-cx, -(bY + bH / 2));

    // Sombra
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx + 3, bY + bH / 2 + 4),
          width: bW,
          height: bH,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0x33000000),
    );

    // Papel pautado
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, bY + bH / 2), width: bW, height: bH),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFF5F5F5),
    );

    // Linhas do papel pautado
    final left = cx - bW / 2;
    for (var l = 0; l < 4; l++) {
      canvas.drawLine(
        Offset(left + 60, bY + 22 + l * 18),
        Offset(left + bW - 12, bY + 22 + l * 18),
        Paint()
          ..color = const Color(0xFFBBDEFB)
          ..strokeWidth = 0.8,
      );
    }

    // Margem vertical vermelha
    canvas.drawLine(
      Offset(left + 52, bY + 8),
      Offset(left + 52, bY + bH - 8),
      Paint()
        ..color = const Color(0xFFEF9A9A)
        ..strokeWidth = 1.2,
    );

    // Furos do papel (espiral)
    for (var f = 0; f < 3; f++) {
      canvas.drawCircle(
        Offset(left + 20, bY + 22 + f * 28),
        5,
        Paint()..color = const Color(0xFFEEEEEE),
      );
      canvas.drawCircle(
        Offset(left + 20, bY + 22 + f * 28),
        5,
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Thumbnail do fundo (se carregou)
    if (_imgFundo != null) {
      final thumbRect = Rect.fromLTWH(left + 58, bY + 8, 80, bH - 16);
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(thumbRect, const Radius.circular(3)),
      );
      canvas.drawImageRect(
        _imgFundo!,
        Rect.fromLTWH(
          0,
          0,
          _imgFundo!.width.toDouble(),
          _imgFundo!.height.toDouble(),
        ),
        thumbRect,
        Paint()..filterQuality = FilterQuality.low,
      );
      canvas.restore();
    } else {
      // Emoji da escola como placeholder
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(ui.TextStyle(fontSize: 42))
        ..addText('🏫');
      final para = pb.build()..layout(ui.ParagraphConstraints(width: 60));
      canvas.drawParagraph(para, Offset(left + 58, bY + 24));
    }

    // Linha separadora
    canvas.drawLine(
      Offset(left + 144, bY + 10),
      Offset(left + 144, bY + bH - 10),
      Paint()
        ..color = const Color(0xFFBBDEFB)
        ..strokeWidth = 0.8,
    );

    // Texto do bilhete
    void _linha(String s, double dy, {bool bold = false, Color? cor}) {
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(
          ui.TextStyle(
            color: cor ?? const Color(0xFF37474F),
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        )
        ..addText(s);
      final para = pb.build()..layout(ui.ParagraphConstraints(width: bW - 160));
      canvas.drawParagraph(para, Offset(left + 152, bY + dy));
    }

    _linha('🏫  Fase 1 — Escola', 14, bold: true, cor: const Color(0xFF1565C0));
    _linha('5 portas com desafios educativos', 34);
    _linha('🔢 Matemática  📝 Palavras  🔤 Letras', 52);
    _linha('⭐ Até 500 pontos por partida', 70, cor: const Color(0xFFE65100));

    canvas.restore();

    // Alfinetes do bilhete
    _desenharAlfinete(
      canvas,
      cx - bW / 2 + 20,
      bY + 4,
      const Color(0xFF43A047),
    );
    _desenharAlfinete(
      canvas,
      cx + bW / 2 - 20,
      bY + 4,
      const Color(0xFF43A047),
    );
  }

  // ── Instrucões ──────────────────────────────────────────────────────────────

  void _desenharInstrucoes(Canvas canvas, double w, double h) {
    final cx = w / 2;
    const iH = 28.0;
    final iY = h - 42.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, iY + iH / 2),
          width: 520,
          height: iH,
        ),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xBB000000),
    );

    final pb =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(ui.TextStyle(color: Colors.white70, fontSize: 13))
          ..addText(
            '← → ou A / D  —  escolher       Enter ou Espaço  —  jogar',
          );
    final para = pb.build()..layout(ui.ParagraphConstraints(width: 520));
    canvas.drawParagraph(para, Offset(cx - 260, iY + 6));
  }

  // ───────────────────────────────────────
  // Teclado
  // ───────────────────────────────────────

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
// Dados de alfinete decorativo
// ─────────────────────────────────────────────────────────────────────────────

class _Alfinete {
  const _Alfinete({required this.x, required this.y, required this.cor});
  final double x;
  final double y;
  final Color cor;
}
