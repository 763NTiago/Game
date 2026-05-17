import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogador/animacao.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/menu/menu_visual.dart';

class Menu extends Component with HasGameReference<FlameGame>, KeyboardHandler {
  Menu({required this.onSelecionado});

  final void Function(Personagem personagem) onSelecionado;

  int indiceSelecionado = 0;
  final List<SpriteComponent> previews = [];

  @override
  Future<void> onLoad() async {
    await _montarFundo();
    await _montarTitulo();
    await _montarPersonagens();
    await add(_MolduraSelecao(this));
    await _montarInstrucoes();
  }

  Future<void> _montarFundo() async {
    await add(
      RectangleComponent(
        size: game.size,
        paint: Paint()..color = MenuVisual.corFundo,
      ),
    );
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
        TextComponent(
          text: personagem.nomeExibicao,
          anchor: Anchor.topCenter,
          position: Vector2(
            preview.position.x,
            centroY +
                MenuVisual.alturaPreviewMenu / 2 +
                MenuVisual.nomeAbaixoPreview,
          ),
          textRenderer: TextPaint(style: MenuVisual.estiloNome),
        ),
      );
    }
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
    for (var i = 0; i < previews.length; i++) {
      previews[i].opacity = i == indiceSelecionado
          ? 1
          : MenuVisual.opacidadeNaoSelecionado;
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

/// Moldura amarela em volta da personagem selecionada.
class _MolduraSelecao extends Component {
  _MolduraSelecao(this.menu);

  final Menu menu;

  @override
  void render(Canvas canvas) {
    final preview = menu.previews[menu.indiceSelecionado];
    final r = Rect.fromCenter(
      center: Offset(preview.position.x, preview.position.y),
      width: preview.size.x + MenuVisual.paddingMoldura,
      height: preview.size.y + MenuVisual.paddingMoldura,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(MenuVisual.raioMoldura)),
      Paint()
        ..color = MenuVisual.corMolduraSelecao
        ..style = PaintingStyle.stroke
        ..strokeWidth = MenuVisual.espessuraMoldura,
    );
  }
}
