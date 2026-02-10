import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/game_models.dart';

class VolleyballCourt extends StatelessWidget {
  final Team teamA;
  final Team teamB;

  const VolleyballCourt({
    super.key,
    required this.teamA,
    required this.teamB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CustomPaint(
        painter: VolleyballCourtPainter(
          teamA: teamA,
          teamB: teamB,
        ),
        child: Container(
          // Espaço para o CustomPaint desenhar
        ),
      ),
    );
  }
}

class VolleyballCourtPainter extends CustomPainter {
  final Team teamA;
  final Team teamB;

  VolleyballCourtPainter({
    required this.teamA,
    required this.teamB,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Cores
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Desenhar linhas da quadra
    // Linha central horizontal
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Linhas verticais (laterais)
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), whitePaint);
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      whitePaint,
    );

    // Linhas horizontais (fundo)
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), whitePaint);
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      whitePaint,
    );

    // Linha de ataque (3m da rede)
    final attackLineDistance = size.height / 6;
    canvas.drawLine(
      Offset(0, size.height / 2 - attackLineDistance),
      Offset(size.width, size.height / 2 - attackLineDistance),
      Paint()
        ..color = Colors.white30
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      Offset(0, size.height / 2 + attackLineDistance),
      Offset(size.width, size.height / 2 + attackLineDistance),
      Paint()
        ..color = Colors.white30
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Desenhar jogadores do Time A (azul) - parte superior
    _drawTeamPlayers(
      canvas,
      size,
      teamA.players,
      Colors.blue[400]!,
      isTopHalf: true,
    );

    // Desenhar jogadores do Time B (vermelho) - parte inferior
    _drawTeamPlayers(
      canvas,
      size,
      teamB.players,
      Colors.red[400]!,
      isTopHalf: false,
    );
  }

  void _drawTeamPlayers(
    Canvas canvas,
    Size size,
    List<Player> players,
    Color teamColor,
    {required bool isTopHalf},
  ) {
    // Posições dos 4 jogadores em quadra (2x2)
    final positions = [
      Offset(size.width * 0.25, isTopHalf ? size.height * 0.15 : size.height * 0.85),
      Offset(size.width * 0.75, isTopHalf ? size.height * 0.15 : size.height * 0.85),
      Offset(size.width * 0.25, isTopHalf ? size.height * 0.35 : size.height * 0.65),
      Offset(size.width * 0.75, isTopHalf ? size.height * 0.35 : size.height * 0.65),
    ];

    for (int i = 0; i < players.length && i < positions.length; i++) {
      final player = players[i];
      final position = positions[i];

      // Desenhar círculo do jogador
      canvas.drawCircle(
        position,
        20,
        Paint()
          ..color = teamColor
          ..style = PaintingStyle.fill,
      );

      // Desenhar borda branca
      canvas.drawCircle(
        position,
        20,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );

      // Desenhar inicial do nome
      final textPainter = TextPainter(
        text: TextSpan(
          text: player.name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(VolleyballCourtPainter oldDelegate) {
    return oldDelegate.teamA != teamA || oldDelegate.teamB != teamB;
  }
}
