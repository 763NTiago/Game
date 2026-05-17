/// Ajustes só do personagem na tela (não mexe no menu nem na janela).
class ConfigDisplay {
  const ConfigDisplay._();

  /// Multiplicador em cima do tamanho de cada frame na PNG.
  ///
  /// Suas skins: 2544×416 → 6 frames de ~424×416 px.
  /// Com arte já grande, use 1.0 (sem ampliar) ou menos para diminuir:
  ///   0.5 ≈ 212×208 px na tela | 0.75 ≈ 318×312 px
  /// Não use 4.0 com PNG grande — estica de novo e fica borrado.
  static const double escalaPersonagem = 0.5;
}
