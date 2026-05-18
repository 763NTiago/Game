import 'dart:math';

/// Referência visual e de layout da fase escola.
///
/// Caminhos dos assets (coloque em assets/images/):
///   mundo/escola/fundo.png      ← fundo1.png renomeado/movido
///   mundo/escola/porta.png      ← porta.png movido
///   mundo/escola/porta_ok.png   ← porta_ok.png movido
///   mundo/escola/inimigo.png    ← inimigo1.png ou inimigo2.png movido
///   mundo/escola/mesa.png       ← mesa.png movido
///   mundo/escola/buraco.png     ← buraco.png movido
///   estrela.png                 ← nova imagem de estrela
class EscolaVisual {
  const EscolaVisual._();

  // ─────────────────────────────────────────────
  // Tamanho do mundo
  // ─────────────────────────────────────────────

  /// Largura total do nível — 5 portas com espaço folgado entre elas.
  static const double larguraMundo = 5000;

  /// Altura padrão da tela (referência para calcular chão etc.).
  static const double alturaTela = 720;

  // ─────────────────────────────────────────────
  // Caminhos dos assets
  // ─────────────────────────────────────────────

  static const String fundo = 'mundo/escola/fundo.png';
  static const String porta = 'mundo/escola/porta.png';
  static const String portaOk = 'mundo/escola/porta_ok.png';
  static const String inimigo = 'mundo/escola/inimigo.png';
  static const String mesa = 'mundo/escola/mesa.png';
  static const String buraco = 'mundo/escola/buraco.png';
  static const String estrela = 'estrela.png';

  /// Mantido por compatibilidade com porta.dart existente.
  static const String portaConcluida = portaOk;

  // ─────────────────────────────────────────────
  // Portas — 5 posições fixas, bem espaçadas
  // ─────────────────────────────────────────────

  /// X do centro de cada porta no mundo.
  /// Espaçamento: ~800 px entre cada uma, início em 600 px.
  static const List<double> portasPosicaoX = [600, 1400, 2200, 3000, 3800];

  /// Altura alvo da porta desenhada na tela (em px).
  static const double alturaPorta = 160.0;

  // ─────────────────────────────────────────────
  // Jogador
  // ─────────────────────────────────────────────

  /// Onde o jogador aparece ao iniciar a fase.
  static const double inicioJogadorX = 120;

  // ─────────────────────────────────────────────
  // Objetos aleatórios — geração procedural
  // ─────────────────────────────────────────────

  /// Gera posições X aleatórias para [quantidade] mesas,
  /// evitando as regiões próximas às portas e ao início.
  static List<double> posicoesMesas({int quantidade = 6, int semente = 0}) {
    return _posicoesSemConflito(
      quantidade: quantidade,
      semente: semente + 1,
      larguraObjeto: 120,
    );
  }

  /// Gera posições X aleatórias para [quantidade] inimigos.
  static List<double> posicoesInimigos({int quantidade = 4, int semente = 0}) {
    return _posicoesSemConflito(
      quantidade: quantidade,
      semente: semente + 2,
      larguraObjeto: 80,
    );
  }

  /// Gera posições X aleatórias para [quantidade] buracos.
  static List<double> posicoesBuracos({int quantidade = 3, int semente = 0}) {
    return _posicoesSemConflito(
      quantidade: quantidade,
      semente: semente + 3,
      larguraObjeto: 150,
    );
  }

  // ─────────────────────────────────────────────
  // Parâmetros dos objetos na tela
  // ─────────────────────────────────────────────

  /// Tamanho alvo da mesa (largura × altura) em px.
  static const double larguraMesa = 120.0;
  static const double alturaMesa = 60.0;

  /// Tamanho alvo do inimigo em px.
  static const double larguraInimigo = 80.0;
  static const double alturaInimigo = 80.0;

  /// Tamanho alvo do buraco em px.
  static const double larguraBuraco = 150.0;
  static const double alturaBuraco = 60.0;

  /// Tamanho da estrela de ponto em px.
  static const double tamanhoEstrela = 48.0;

  // ─────────────────────────────────────────────
  // HUD
  // ─────────────────────────────────────────────

  static const int totalVidas = 5;

  /// Tamanho do ícone de coração no HUD.
  static const double tamanhoCoracao = 36.0;

  /// Tamanho da estrela no HUD.
  static const double tamanhoEstrelaHud = 32.0;

  // ─────────────────────────────────────────────
  // Cores de fallback (quando imagem não carrega)
  // ─────────────────────────────────────────────

  static const int corFundoFallback = 0xFFB3E5FC; // azul claro
  static const int corChaoFallback = 0xFFFFF9C4; // amarelo claro
  static const int corPortaFallback = 0xFF5D4037; // marrom
  static const int corPortaOkFallback = 0xFF43A047; // verde
  static const int corMesaFallback = 0xFF8D6E63; // marrom claro
  static const int corInimigoFallback = 0xFFE53935; // vermelho
  static const int corBuracoFallback = 0xFF212121; // preto

  // ─────────────────────────────────────────────
  // Limites de patrulha dos inimigos
  // ─────────────────────────────────────────────

  /// Inimigo patrulha [amplitudePatrulha] px para cada lado.
  static const double amplitudePatrulha = 200.0;

  // ─────────────────────────────────────────────
  // Interno — geração sem conflito
  // ─────────────────────────────────────────────

  /// Retorna [quantidade] posições X distribuídas no mundo,
  /// sem sobrepor as portas nem o início.
  static List<double> _posicoesSemConflito({
    required int quantidade,
    required int semente,
    required double larguraObjeto,
  }) {
    final rng = Random(semente);
    final resultado = <double>[];

    // Zonas proibidas: início + entorno de cada porta
    const margemPorta = 220.0; // px livres ao redor de cada porta
    const margemInicio = 300.0; // px livres no começo

    bool conflita(double x) {
      if (x < margemInicio) return true;
      if (x + larguraObjeto > larguraMundo - 100) return true;
      for (final px in portasPosicaoX) {
        if ((x - px).abs() < margemPorta) return true;
      }
      // Evita sobrepor outros objetos já escolhidos
      for (final outro in resultado) {
        if ((x - outro).abs() < larguraObjeto + 40) return true;
      }
      return false;
    }

    int tentativas = 0;
    while (resultado.length < quantidade && tentativas < 500) {
      tentativas++;
      final x = rng.nextDouble() * (larguraMundo - 400) + 200;
      if (!conflita(x)) resultado.add(x);
    }

    return resultado;
  }
}
