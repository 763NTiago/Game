import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meu_jogo/jogo.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatefulWidget {
  const MeuApp({super.key});

  @override
  State<MeuApp> createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  final _jogo = JogoCasa();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Garante foco assim que o app sobe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: KeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (event) {
            // Repassa eventos de teclado diretamente ao jogo
            if (event is KeyDownEvent || event is KeyRepeatEvent) {
              _jogo.onKeyEvent(
                event,
                HardwareKeyboard.instance.logicalKeysPressed,
              );
            } else if (event is KeyUpEvent) {
              _jogo.onKeyEvent(
                event,
                HardwareKeyboard.instance.logicalKeysPressed,
              );
            }
          },
          child: GameWidget(game: _jogo),
        ),
      ),
    );
  }
}
