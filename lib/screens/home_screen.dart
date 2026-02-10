import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_controller.dart';
import '../models/player.dart';
import '../models/game_models.dart';
import '../widgets/slider_vencedor.dart';
import '../widgets/volleyball_court.dart';
import '../screens/jogadores_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VÔLEI DO MULTIVERSO'),
        backgroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JogadoresScreen()),
              );
            },
            tooltip: 'Cadastro de Jogadores',
          ),
        ],
      ),
      body: Consumer<GameController>(
        builder: (context, gameController, _) {
          final currentMatch = gameController.currentMatch;
          final waitingPlayers = gameController.waitingPlayers;

          if (currentMatch == null) {
            return _buildNoMatchScreen(context, gameController);
          }

          return _buildMatchScreen(context, gameController, currentMatch, waitingPlayers);
        },
      ),
    );
  }

  Widget _buildNoMatchScreen(BuildContext context, GameController gameController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nenhuma partida em andamento',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final result = gameController.startInitialMatch();
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'ADICIONAR NA FILA',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchScreen(
    BuildContext context,
    GameController gameController,
    Match currentMatch,
    List<Player> waitingPlayers,
  ) {
    final teamA = currentMatch.teamA.players;
    final teamB = currentMatch.teamB.players;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Título da quadra
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'EM QUADRA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // Quadra de vôlei visual
                AspectRatio(
                  aspectRatio: 1.0,
                  child: VolleyballCourt(
                    teamA: currentMatch.teamA,
                    teamB: currentMatch.teamB,
                  ),
                ),
              ],
            ),
          ),
                const SizedBox(height: 16),
                // Slider de Vencedor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const Text(
                  'VENCEDOR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                SliderVencedor(
                  onTeamSelected: (team) {
                    final result = gameController.finishMatchAndDrawChallenger(team);
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    }
                  },
                  teamA: currentMatch.teamA,
                  teamB: currentMatch.teamB,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Lista de Espera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FILA DE ESPERA (${waitingPlayers.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JogadoresScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('ADICIONAR JOGADOR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (waitingPlayers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Nenhum jogador aguardando',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: waitingPlayers.length,
                    itemBuilder: (context, index) {
                      final player = waitingPlayers[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: player.gender == PlayerGender.female
                                    ? Colors.pink[300]
                                    : Colors.blue[300],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  player.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    player.positions.map((p) => p.name).join(', '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (player.tickets > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${player.tickets} bilhetes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
