import 'dart:math';

/// Referência visual e de layout da fase escola.
///
/// Layout do mundo — baseado em SEÇÕES:
///   Seção 0 : 8 tiles de fundo1  → Porta 1 (desafio)
///   Seção 1 : 8 tiles de fundo2  → Porta 2 (desafio)
///   Seção 2 : 8 tiles de fundo3  → Porta 3 (desafio)
///   Seção 3 : 8 tiles de fundo4  → Porta 4 (desafio)
///   Seção 4 : 8 tiles de fundo4  → Porta 5 (VITÓRIA)
///
/// O tile tem a largura calculada em tempo de execução a partir da imagem,
/// mas usamos [larguraTileRef] como referência estática para posicionar portas.
class EscolaVisual {
  const EscolaVisual._();

  // ─────────────────────────────────────────────
  // Estrutura de seções
  // ─────────────────────────────────────────────

  /// Quantos tiles de fundo por seção antes de cada porta.
  static const int tilesPorSecao = 5;

  /// Total de portas / seções.
  static const int totalPortas = 5;

  /// Largura de referência de cada tile de fundo (px).
  /// Valor provisório — [FaseEscola] recalcula com a imagem real.
  static const double larguraTileRef = 960.0;

  /// Largura de uma seção completa (tiles + espaço da porta).
  static const double larguraSecao =
      tilesPorSecao * larguraTileRef + espacoPorta;

  /// Espaço reservado para a porta dentro de cada seção.
  static const double espacoPorta = 400.0;

  /// Largura total do mundo.
  static double larguraMundo({double larguraTile = larguraTileRef}) =>
      totalPortas * (tilesPorSecao * larguraTile + espacoPorta);

  // ─────────────────────────────────────────────
  // Posições das portas
  // ─────────────────────────────────────────────

  /// Retorna o X do centro de cada porta dado o [larguraTile] real.
  static double xPorta(int indice, {double larguraTile = larguraTileRef}) {
    final inicioSecao = indice * (tilesPorSecao * larguraTile + espacoPorta);
    final fimTiles = inicioSecao + tilesPorSecao * larguraTile;
    // Porta fica no meio do espaço reservado
    return fimTiles + espacoPorta / 2;
  }

  // ─────────────────────────────────────────────
  // Assets — fundos por seção
  // ─────────────────────────────────────────────

  /// Retorna o caminho do fundo para a seção [indiceSecao] (0‥4).
  /// Seções 0‥3 usam fundo1‥fundo4; seção 4 repete fundo4.
  static String fundoDaSecao(int indiceSecao) {
    final n = (indiceSecao + 1).clamp(1, 4);
    return 'mundo/escola/fundo$n.png';
  }

  // ─────────────────────────────────────────────
  // Outros assets
  // ─────────────────────────────────────────────

  static const String porta = 'mundo/escola/porta.png';
  static const String portaOk = 'mundo/escola/porta_ok.png';
  static const String portaFinal =
      'mundo/escola/porta_ok.png'; // trocar por troféu se tiver
  static const String inimigo = 'mundo/escola/inimigo.png';
  static const String mesa = 'mundo/escola/mesa.png';
  static const String buraco = 'mundo/escola/buraco.png';
  static const String estrela = 'estrela.png';

  /// Mantido por compatibilidade.
  static const String portaConcluida = portaOk;

  // ─────────────────────────────────────────────
  // Porta
  // ─────────────────────────────────────────────

  static const double alturaPorta = 320.0;

  // ─────────────────────────────────────────────
  // Jogador
  // ─────────────────────────────────────────────

  static const double inicioJogadorX = 150.0;

  // ─────────────────────────────────────────────
  // Câmera — dead zone
  // ─────────────────────────────────────────────

  /// Borda esquerda da dead zone (30% da tela).
  /// Câmera começa a mover quando jogador sair daqui.
  static const double deadZoneEsquerda = 0.30;

  /// Borda direita da dead zone (40% da tela).
  static const double deadZoneDireita = 0.40;

  // ─────────────────────────────────────────────
  // Objetos de cenário
  // ─────────────────────────────────────────────

  static const double larguraMesa = 120.0;
  static const double alturaMesa = 60.0;
  static const double larguraInimigo = 80.0;
  static const double alturaInimigo = 80.0;
  static const double larguraBuraco = 150.0;
  static const double alturaBuraco = 60.0;
  static const double tamanhoEstrela = 48.0;

  // ─────────────────────────────────────────────
  // HUD
  // ─────────────────────────────────────────────

  static const int totalVidas = 5;
  static const double tamanhoCoracao = 36.0;
  static const double tamanhoEstrelaHud = 32.0;

  // ─────────────────────────────────────────────
  // Cores de fallback
  // ─────────────────────────────────────────────

  static const int corFundoFallback = 0xFFB3E5FC;
  static const int corChaoFallback = 0xFFFFF9C4;
  static const int corPortaFallback = 0xFF5D4037;
  static const int corPortaOkFallback = 0xFF43A047;
  static const int corMesaFallback = 0xFF8D6E63;
  static const int corInimigoFallback = 0xFFE53935;
  static const int corBuracoFallback = 0xFF212121;

  // ─────────────────────────────────────────────
  // Inimigos
  // ─────────────────────────────────────────────

  static const double amplitudePatrulha = 200.0;

  // ─────────────────────────────────────────────
  // Geração procedural de objetos (evita portas)
  // ─────────────────────────────────────────────

  static List<double> posicoesMesas({
    int quantidade = 12,
    int semente = 0,
    double larguraTile = larguraTileRef,
  }) => _posicoesSemConflito(
    quantidade: quantidade,
    semente: semente + 1,
    larguraObjeto: 120,
    larguraTile: larguraTile,
  );

  static List<double> posicoesInimigos({
    int quantidade = 10,
    int semente = 0,
    double larguraTile = larguraTileRef,
  }) => _posicoesSemConflito(
    quantidade: quantidade,
    semente: semente + 2,
    larguraObjeto: 80,
    larguraTile: larguraTile,
  );

  static List<double> posicoesBuracos({
    int quantidade = 7,
    int semente = 0,
    double larguraTile = larguraTileRef,
  }) => _posicoesSemConflito(
    quantidade: quantidade,
    semente: semente + 3,
    larguraObjeto: 150,
    larguraTile: larguraTile,
  );

  static List<double> _posicoesSemConflito({
    required int quantidade,
    required int semente,
    required double larguraObjeto,
    required double larguraTile,
  }) {
    final rng = Random(semente);
    final resultado = <double>[];
    final mundo = larguraMundo(larguraTile: larguraTile);
    const margemPorta = 350.0;
    const margemInicio = 400.0;

    // Posições X das portas com o tile real
    final xsPortas = List.generate(
      totalPortas,
      (i) => xPorta(i, larguraTile: larguraTile),
    );

    bool conflita(double x) {
      if (x < margemInicio) return true;
      if (x + larguraObjeto > mundo - 100) return true;
      for (final px in xsPortas) {
        if ((x - px).abs() < margemPorta) return true;
      }
      for (final outro in resultado) {
        if ((x - outro).abs() < larguraObjeto + 40) return true;
      }
      return false;
    }

    int tentativas = 0;
    while (resultado.length < quantidade && tentativas < 500) {
      tentativas++;
      final x = rng.nextDouble() * (mundo - 400) + 200;
      if (!conflita(x)) resultado.add(x);
    }
    return resultado;
  }
}
