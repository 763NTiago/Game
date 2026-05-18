import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Entrada do ranking — nome e pontuação.
class EntradaRanking {
  const EntradaRanking({required this.nome, required this.pontos});

  final String nome;
  final int pontos;
}

// ─────────────────────────────────────────────────────────────────────────────
// Repositório — armazena em memória durante a sessão
// ─────────────────────────────────────────────────────────────────────────────

/// Gerencia o top 3 da sessão atual (memória — dados somem ao fechar o app).
/// Para persistência real: adicione shared_preferences no pubspec.yaml.
class RepositorioRanking {
  RepositorioRanking._();

  static const int maxEntradas = 3;
  static final List<EntradaRanking> _entradas = [];

  static Future<List<EntradaRanking>> carregar() async {
    final copia = List<EntradaRanking>.from(_entradas);
    copia.sort((a, b) => b.pontos.compareTo(a.pontos));
    return copia.take(maxEntradas).toList();
  }

  static Future<List<EntradaRanking>> salvar(String nome, int pontos) async {
    _entradas.add(EntradaRanking(nome: nome, pontos: pontos));
    _entradas.sort((a, b) => b.pontos.compareTo(a.pontos));
    while (_entradas.length > maxEntradas) {
      _entradas.removeLast();
    }
    return List.from(_entradas);
  }

  static Future<void> limpar() async => _entradas.clear();
}

// ─────────────────────────────────────────────────────────────────────────────
// Componente visual
// ─────────────────────────────────────────────────────────────────────────────

class PainelRanking extends PositionComponent with HasGameReference<FlameGame> {
  PainelRanking({required Vector2 posicao}) {
    position = posicao;
    anchor = Anchor.bottomCenter;
  }

  List<EntradaRanking> _entradas = [];
  double _tempo = 0;

  static const _medalhas = ['🥇', '🥈', '🥉'];
  static const _cores = [
    Color(0xFFFFD700),
    Color(0xFFC0C0C0),
    Color(0xFFCD7F32),
  ];

  @override
  Future<void> onLoad() async {
    _entradas = await RepositorioRanking.carregar();
    size = Vector2(340, 140);
  }

  Future<void> recarregar() async {
    _entradas = await RepositorioRanking.carregar();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tempo += dt;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;

    final painelRR = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, size.y),
      const Radius.circular(14),
    );
    canvas.drawRRect(painelRR, Paint()..color = const Color(0xBB000020));
    canvas.drawRRect(
      painelRR,
      Paint()
        ..color = const Color(0xFF3949AB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final escTitulo = 1.0 + sin(_tempo * 2.5) * 0.04;
    canvas.save();
    canvas.translate(w / 2, 18);
    canvas.scale(escTitulo, escTitulo);
    _texto(canvas, '⭐ Top 3 ⭐',
        const TextStyle(
            color: Color(0xFFFFEB3B),
            fontSize: 16,
            fontWeight: FontWeight.bold),
        offsetY: -8,
        larguraMax: w - 16);
    canvas.restore();

    if (_entradas.isEmpty) {
      _texto(
          canvas,
          'Nenhuma pontuação ainda!\nJogue para aparecer aqui 😊',
          const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          offsetY: 44,
          offsetX: w / 2,
          larguraMax: w - 24);
      return;
    }

    for (var i = 0; i < _entradas.length; i++) {
      final e = _entradas[i];
      final cor = _cores[i];
      final y = 42.0 + i * 30.0;
      _texto(canvas, _medalhas[i], TextStyle(fontSize: 16, color: cor),
          offsetX: 20, offsetY: y, alinhamento: TextAlign.left, larguraMax: 28);
      _texto(canvas, e.nome,
          TextStyle(color: cor, fontSize: 15, fontWeight: FontWeight.bold),
          offsetX: 52, offsetY: y, alinhamento: TextAlign.left, larguraMax: 180);
      _texto(canvas, '${e.pontos} pts',
          TextStyle(color: cor.withOpacity(0.9), fontSize: 15),
          offsetX: w - 12, offsetY: y, alinhamento: TextAlign.right, larguraMax: 100);
    }
  }

  void _texto(Canvas canvas, String texto, TextStyle estilo,
      {double offsetX = 0,
      double offsetY = 0,
      TextAlign alinhamento = TextAlign.center,
      required double larguraMax}) {
    final tp = TextPainter(
        text: TextSpan(text: texto, style: estilo),
        textAlign: alinhamento,
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: larguraMax);
    final dx = alinhamento == TextAlign.center
        ? offsetX - tp.width / 2
        : alinhamento == TextAlign.right
            ? offsetX - tp.width
            : offsetX;
    tp.paint(canvas, Offset(dx, offsetY));
  }
}
