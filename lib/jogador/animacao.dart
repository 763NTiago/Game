import 'dart:ui';

// Matriz de movimento + mapa de skin do jogador.
// Cada personagem usa um PNG com 6 frames na mesma grade.

/// O que o personagem está fazendo agora.
enum EstadoJogador {
  parado,
  andando,
  pulando,
  caindo,
}

/// Para qual lado o personagem olha.
enum DirecaoJogador {
  esquerda,
  direita,
}

/// Configuração do spritesheet (grade de animação).
/// Tamanho do frame vem da PNG — não use 32 fixo.
class ConfigSpritesheet {
  const ConfigSpritesheet({
    required this.larguraFrame,
    required this.alturaFrame,
    this.colunas = colunasSpritesheet,
    this.linhas = 1,
  });

  /// Lê largura/altura de cada frame direto da imagem que a IA gerou.
  factory ConfigSpritesheet.daImagem(
    Image image, {
    int colunas = colunasSpritesheet,
  }) {
    return ConfigSpritesheet(
      colunas: colunas,
      larguraFrame: image.width / colunas,
      alturaFrame: image.height.toDouble(),
    );
  }

  final int colunas;
  final int linhas;
  final double larguraFrame;
  final double alturaFrame;

  /// Posição (x, y) do frame dentro da textura, em pixels.
  ({double x, double y}) origemDoFrame(int indice) {
    final col = indice % colunas;
    final lin = indice ~/ colunas;
    return (
      x: col * larguraFrame,
      y: lin * alturaFrame,
    );
  }
}

/// Matriz de movimento: cada estado aponta para índices de frame no spritesheet.
///
/// Exemplo: `andar: [1, 2, 3]` → frames 1, 2 e 3 em sequência.
class MatrizMovimento {
  const MatrizMovimento._();

  static const Map<EstadoJogador, List<int>> frames = {
    EstadoJogador.parado: [0, 0, 0],
    EstadoJogador.andando: [1, 2, 3],
    EstadoJogador.pulando: [4],
    EstadoJogador.caindo: [5],
  };

  static List<int> framesDe(EstadoJogador estado) =>
      frames[estado] ?? frames[EstadoJogador.parado]!;
}

/// Retângulo de uma parte do corpo na textura (estilo skin map / Minecraft).
class RegiaoSkin {
  const RegiaoSkin({
    required this.x,
    required this.y,
    required this.largura,
    required this.altura,
  });

  final double x;
  final double y;
  final double largura;
  final double altura;
}

/// Onde cada parte fica na PNG — troque a imagem, mantenha as coordenadas.
class MapaSkin {
  const MapaSkin();

  static const Map<String, RegiaoSkin> partes = {
    'cabeca': RegiaoSkin(x: 0, y: 0, largura: 8, altura: 8),
    'corpo': RegiaoSkin(x: 8, y: 8, largura: 8, altura: 12),
    'braco_esquerdo': RegiaoSkin(x: 0, y: 8, largura: 4, altura: 12),
    'braco_direito': RegiaoSkin(x: 20, y: 8, largura: 4, altura: 12),
    'perna_esquerda': RegiaoSkin(x: 4, y: 20, largura: 4, altura: 12),
    'perna_direita': RegiaoSkin(x: 12, y: 20, largura: 4, altura: 12),
  };
}

/// Quantidade de frames no spritesheet (linha horizontal).
const int colunasSpritesheet = 6;

/// Decide qual frame mostrar com base no estado e no tempo.
class ControladorAnimacao {
  ControladorAnimacao({
    required this.config,
    this.duracaoFrame = 0.12,
  });

  final double duracaoFrame;
  final ConfigSpritesheet config;

  EstadoJogador estado = EstadoJogador.parado;
  DirecaoJogador direcao = DirecaoJogador.direita;

  int _indiceNaLista = 0;
  double _tempo = 0;

  /// Índice atual no spritesheet (coluna/linha via [ConfigSpritesheet]).
  int get indiceFrameAtual {
    final lista = MatrizMovimento.framesDe(estado);
    return lista[_indiceNaLista % lista.length];
  }

  /// Avança animação; chame todo frame com o [estadoAtual] da física/input.
  void atualizar(double dt, EstadoJogador estadoAtual) {
    if (estadoAtual != estado) {
      estado = estadoAtual;
      _indiceNaLista = 0;
      _tempo = 0;
    }

    final lista = MatrizMovimento.framesDe(estado);
    if (lista.length <= 1) {
      _indiceNaLista = 0;
      return;
    }

    _tempo += dt;
    if (_tempo >= duracaoFrame) {
      _tempo = 0;
      _indiceNaLista = (_indiceNaLista + 1) % lista.length;
    }
  }

  void definirDirecao(bool indoParaDireita) {
    direcao = indoParaDireita ? DirecaoJogador.direita : DirecaoJogador.esquerda;
  }
}

/// Calcula o estado visual a partir da velocidade e se está no chão.
EstadoJogador estadoAPartirDaFisica({
  required bool noChao,
  required double velocidadeY,
  required bool seMovendoHorizontalmente,
}) {
  if (!noChao) {
    return velocidadeY < 0 ? EstadoJogador.pulando : EstadoJogador.caindo;
  }
  if (seMovendoHorizontalmente) {
    return EstadoJogador.andando;
  }
  return EstadoJogador.parado;
}
