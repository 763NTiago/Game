import 'package:flutter/material.dart';

/// Ajuste cores, textos e posições do menu aqui.
class MenuVisual {
  const MenuVisual._();

  static const corFundo = Color(0xFF1A237E);
  static const corMolduraSelecao = Color(0xFFFFEB3B);
  static const corTitulo = Colors.white;
  static const corNomePersonagem = Colors.white;
  static const corInstrucoes = Colors.white70;

  static const titulo = 'Escolha sua personagem';
  static const instrucoes =
      '← → ou A / D — escolher\nEnter ou Espaço — jogar';

  /// Altura do personagem no menu (fixa — não muda se a PNG for 2544×416).
  /// Antes: frame ~32 px × 2.5 ≈ 80 px.
  static const alturaPreviewMenu = 80.0;
  static const espessuraMoldura = 4.0;
  static const paddingMoldura = 24.0;
  static const raioMoldura = 12.0;

  static const tituloY = 48.0;
  static const previewCentroY = 0.42;
  static const previewOffsetX = 0.28;
  static const nomeAbaixoPreview = 20.0;
  static const instrucoesY = 40.0;

  static const opacidadeNaoSelecionado = 0.45;

  static const estiloTitulo = TextStyle(
    color: corTitulo,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const estiloNome = TextStyle(
    color: corNomePersonagem,
    fontSize: 22,
  );

  static const estiloInstrucoes = TextStyle(
    color: corInstrucoes,
    fontSize: 18,
    height: 1.4,
  );
}
