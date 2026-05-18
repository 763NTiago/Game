import 'package:flutter/material.dart';

/// Ajuste cores, textos e posições do menu aqui.
class MenuVisual {
  const MenuVisual._();

  // ─────────────────────────────────────────────
  // Cores gerais
  // ─────────────────────────────────────────────

  static const corFundo = Color(0xFF0D1B2A); // azul-marinho escuro
  static const corFundoGradienteBase = Color(0xFF1B2838);
  static const corMolduraSelecao = Color(0xFFFFEB3B);
  static const corTitulo = Colors.white;
  static const corNomePersonagem = Colors.white;
  static const corInstrucoes = Colors.white70;

  // ─────────────────────────────────────────────
  // Textos
  // ─────────────────────────────────────────────

  static const titulo = '🏫  Aventura na Escola';
  static const subtitulo = 'Escolha sua personagem';
  static const instrucoes =
      '← → ou A / D  —  escolher       Enter ou Espaço  —  jogar';

  // ─────────────────────────────────────────────
  // Preview dos personagens
  // ─────────────────────────────────────────────

  /// Altura do personagem no menu.
  static const alturaPreviewMenu = 100.0;
  static const espessuraMoldura = 4.0;
  static const paddingMoldura = 28.0;
  static const raioMoldura = 16.0;

  static const tituloY = 36.0;
  static const subtituloY = 82.0;
  static const previewCentroY = 0.42;
  static const previewOffsetX = 0.22;
  static const nomeAbaixoPreview = 18.0;
  static const instrucoesY = 32.0;

  static const opacidadeNaoSelecionado = 0.35;

  // ─────────────────────────────────────────────
  // Card de fase (preview da fase no rodapé do menu)
  // ─────────────────────────────────────────────

  /// Altura do thumbnail do fundo da fase dentro do card.
  static const alturaThumbFase = 90.0;

  /// Largura total do card de fase.
  static const larguraCardFase = 500.0;

  /// Altura total do card de fase.
  static const alturaCardFase = 110.0;

  /// Cor de fundo do card.
  static const corCardFundo = Color(0xFF1A2744);

  /// Cor da borda do card.
  static const corCardBorda = Color(0xFF3D5AFE);

  /// Cor do título da fase.
  static const corTituloFase = Color(0xFFFFEB3B);

  /// Cor da descrição da fase.
  static const corDescFase = Colors.white70;

  // ─────────────────────────────────────────────
  // Estilos de texto
  // ─────────────────────────────────────────────

  static const estiloTitulo = TextStyle(
    color: corTitulo,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    shadows: [Shadow(color: Color(0xFF3D5AFE), blurRadius: 18)],
  );

  static const estiloSubtitulo = TextStyle(
    color: Color(0xFFB0BEC5),
    fontSize: 17,
    letterSpacing: 0.5,
  );

  static const estiloNome = TextStyle(
    color: corNomePersonagem,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const estiloInstrucoes = TextStyle(
    color: corInstrucoes,
    fontSize: 15,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const estiloTituloFase = TextStyle(
    color: corTituloFase,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const estiloDescFase = TextStyle(
    color: corDescFase,
    fontSize: 13,
    height: 1.4,
  );
}
