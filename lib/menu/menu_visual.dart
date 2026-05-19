import 'package:flutter/material.dart';

/// Constantes visuais do menu — tema "Quadro de Avisos de Cortiça".
///
/// Mude aqui para ajustar cores, tamanhos e textos sem tocar na lógica.
class MenuVisual {
  const MenuVisual._();

  // ─────────────────────────────────────────────
  // Cortiça
  // ─────────────────────────────────────────────

  /// Cor base da cortiça.
  static const corCorticaBase = Color(0xFFC4864A);

  // ─────────────────────────────────────────────
  // Moldura de madeira
  // ─────────────────────────────────────────────

  static const corMoldura = Color(0xFF6D4C41);
  static const corMolduraEscura = Color(0xFF4E342E);

  // ─────────────────────────────────────────────
  // Banner do título
  // ─────────────────────────────────────────────

  static const corBannerFundo = Color(0xFFE53935);

  /// Listras do banner (decoração tipo festa junina).
  static const coresBannerListras = [
    Color(0x22FFFFFF), // branco semitransparente
    Color(0x00000000), // transparente
    Color(0x22FFFFFF),
    Color(0x00000000),
    Color(0x22FFFFFF),
    Color(0x00000000),
  ];

  // ─────────────────────────────────────────────
  // Subtítulo
  // ─────────────────────────────────────────────

  static const corSubtituloBg = Color(0xFFFFF9C4);
  static const corSubtituloTexto = Color(0xFF5D4037);

  // ─────────────────────────────────────────────
  // Seleção
  // ─────────────────────────────────────────────

  /// Cor do contorno e do badge do Polaroid selecionado.
  static const corSelecao = Color(0xFFFFEB3B);

  // ─────────────────────────────────────────────
  // Alfinetes decorativos
  // ─────────────────────────────────────────────

  /// Pool de cores para os alfinetes espalhados pelo quadro.
  static const coresAlfinetes = [
    Color(0xFFE53935), // vermelho
    Color(0xFF1E88E5), // azul
    Color(0xFF43A047), // verde
    Color(0xFFFFB300), // âmbar
    Color(0xFF8E24AA), // roxo
    Color(0xFF00ACC1), // ciano
    Color(0xFFF4511E), // laranja
  ];

  // ─────────────────────────────────────────────
  // Textos / conteúdo
  // ─────────────────────────────────────────────

  static const textoInstrucoes =
      '← → ou A / D  —  escolher       Enter ou Espaço  —  jogar';
}
