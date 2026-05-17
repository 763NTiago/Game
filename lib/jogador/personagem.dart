/// Personagens disponíveis no menu.
enum Personagem {
  tais('skin/tais.png', 'Tais'),
  isis('skin/isis.png', 'Ísis');

  const Personagem(this.caminhoSkin, this.nomeExibicao);

  final String caminhoSkin;
  final String nomeExibicao;
}
