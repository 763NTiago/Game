/// Referência visual da fase escola (estilo Mario — vista lateral, andando →).
///
/// ## fundo.png
/// Corredor da escola visto de LADO, bem largo (personagem anda na horizontal).
/// - Tamanho sugerido: **3200 × 360** px (ou altura 480 / 720).
/// - A linha do chão fica nos **últimos ~48 px** da imagem (onde os pés encostam).
/// - Pode desenhar portas no fundo só como decoração OU deixar parede lisa
///   e usar porta.png separada (recomendado).
/// - Fundo transparente só no topo (céu); chão pode ir até a borda inferior.
///
/// ## porta.png
/// Uma porta só, vista lateral, fundo transparente.
/// - Tamanho sugerido: **96 × 128** ou **128 × 160** px.
/// - Pé da porta alinhado embaixo (o código usa anchor na base).
///
/// ## porta_ok.png (opcional)
/// Mesma porta aberta / concluída (verde, estrela, etc.).
/// - Mesmo tamanho que porta.png.
///
/// Coloque em: assets/images/mundo/escola/
class EscolaVisual {
  const EscolaVisual._();

  /// Largura total do nível (maior que a tela — estilo Mario).
  static const double larguraMundo = 3200;

  /// Posição X de cada porta no mundo (5 portas).
  static const List<double> portasPosicaoX = [
    400,
    1000,
    1600,
    2200,
    2800,
  ];

  static const String fundo = 'mundo/escola/fundo.png';
  static const String porta = 'mundo/escola/porta.png';
  static const String portaConcluida = 'mundo/escola/porta_ok.png';

  /// Onde o jogador começa (canto esquerdo do corredor).
  static const double inicioJogadorX = 120;
}
