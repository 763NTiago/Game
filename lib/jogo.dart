import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:meu_jogo/jogador/personagem.dart';
import 'package:meu_jogo/menu/menu.dart';
import 'package:meu_jogo/mundo/escola/fase_escola.dart';
import 'package:meu_jogo/telas/tela_game_over.dart';
import 'package:meu_jogo/telas/tela_vitoria.dart';

class JogoCasa extends FlameGame with HasKeyboardHandlerComponents {
  Personagem? _personagem;
  FaseEscola? _fase;
  Menu? _menu;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _mostrarMenu();
  }

  void _mostrarMenu() {
    _limparTela();
    final menu = Menu(
      onSelecionado: (personagem) {
        _personagem = personagem;
        _iniciarFase();
      },
    );
    _menu = menu;
    add(menu);
  }

  void _iniciarFase() {
    _limparTela();
    final personagem = _personagem;
    if (personagem == null) {
      _mostrarMenu();
      return;
    }
    final fase = FaseEscola(
      personagem: personagem,
      onGameOver: _aoGameOver,
      onConcluida: _aoVencer,
      onMenu: _mostrarMenu,
    );
    _fase = fase;
    add(fase);
  }

  void _aoGameOver(int pontos) {
    add(
      TelaGameOver(
        pontos: pontos,
        onReiniciar: _iniciarFase,
        onMenu: _mostrarMenu,
      ),
    );
  }

  void _aoVencer(int pontos) {
    add(
      TelaVitoria(
        pontos: pontos,
        nomeJogador: _personagem?.nomeExibicao ?? 'Jogador',
        onJogarNovamente: _iniciarFase,
        onMenu: _mostrarMenu,
      ),
    );
  }

  void _limparTela() {
    _fase?.removeFromParent();
    _fase = null;
    _menu?.removeFromParent();
    _menu = null;
    children.whereType<TelaGameOver>().toList().forEach(
      (t) => t.removeFromParent(),
    );
    children.whereType<TelaVitoria>().toList().forEach(
      (t) => t.removeFromParent(),
    );
  }
}
