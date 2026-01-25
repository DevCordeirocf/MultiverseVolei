import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_controller.dart';
import '../models/player.dart';
import '../widgets/add_player_dialog.dart';

// Mudamos para StatefulWidget para controlar os Switches (Checkboxes)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Estado local para as regras da próxima partida
  bool _forceFemale = false;
  bool _forceSetter = false;

  @override
  Widget build(BuildContext context) {
    // No StatefulWidget, usamos context.watch dentro do build
    final gameController = context.watch<GameController>();
    final matchPlayers = gameController.currentMatchPlayers;

    // Separação dos times
    final teamA = matchPlayers.length >= 4 ? matchPlayers.sublist(0, 4) : <Player>[];
    final teamB = matchPlayers.length == 8 ? matchPlayers.sublist(4, 8) : <Player>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vôlei do Multiverso 🏐'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => gameController.finishMatch(),
            tooltip: "Limpar Quadra (Todos pro descanso)",
          )
        ],
      ),
      body: Column(
        children: [
          // --- ÁREA DA QUADRA ---
          Container(
            color: Colors.green.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "EM QUADRA",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTeamCard("Time A", teamA, Colors.blue.shade100)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("VS", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: _buildTeamCard("Time B", teamB, Colors.red.shade100)),
                  ],
                ),
              ],
            ),
          ),

          // --- PAINEL DE REGRAS (NOVO!) ---
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text("Regras:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                // Switch Menina
                FilterChip(
                  label: const Text("Menina 👩"),
                  selected: _forceFemale,
                  onSelected: (val) => setState(() => _forceFemale = val),
                  selectedColor: Colors.pinkAccent.shade100,
                ),
                const SizedBox(width: 8),
                // Switch Levantador
                FilterChip(
                  label: const Text("Levant. 👐"),
                  selected: _forceSetter,
                  onSelected: (val) => setState(() => _forceSetter = val),
                  selectedColor: Colors.orangeAccent.shade100,
                ),
              ],
            ),
          ),

          // --- BOTÃO DE SORTEIO ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.casino), // Ícone de dado/sorte
                onPressed: () {
                  // Passamos as variáveis de estado para o controller
                  String? error = gameController.startGame(
                    forceFemale: _forceFemale,
                    forceSetter: _forceSetter,
                  );

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                },
                label: const Text("GERAR NOVA PARTIDA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          const Divider(thickness: 1, height: 1),

          // --- CABEÇALHO DA LISTA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Na Barreira: ${gameController.waitingPlayers.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const AddPlayerDialog(),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Novo Jogador")
                )
              ],
            ),
          ),

          // --- LISTA DE ESPERA ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Espaço para não cobrir o último
              itemCount: gameController.waitingPlayers.length,
              itemBuilder: (ctx, index) {
                // Ordenação visual: Quem tem mais chance aparece em cima
                var sortedList = List<Player>.from(gameController.waitingPlayers);
                sortedList.sort((a, b) => b.ticketWeight.compareTo(a.ticketWeight));

                final player = sortedList[index];

                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: player.gender == PlayerGender.female
                            ? Colors.pinkAccent
                            : Colors.blueAccent,
                        child: Text(player.name.isNotEmpty ? player.name[0].toUpperCase() : "?",
                            style: const TextStyle(color: Colors.white)),
                      ),
                      // Bolinha indicando posição (se for levantador)
                      if (player.positions.contains(PlayerPosition.setter))
                        const Positioned(
                          right: 0, bottom: 0,
                          child: CircleAvatar(radius: 6, backgroundColor: Colors.orange),
                        )
                    ],
                  ),
                  title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Row(
                    children: [
                      Icon(Icons.confirmation_number, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${player.ticketWeight} bilhetes"),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text("${player.arrivalTime.hour}:${player.arrivalTime.minute.toString().padLeft(2, '0')}"),
                    ],
                  ),
                  trailing: _buildPositionIcon(player),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String title, List<Player> players, Color color) {
    return Card(
      color: color,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white54),
            if (players.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("-", style: TextStyle(color: Colors.grey)),
              )
            else
              ...players.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(p.gender == PlayerGender.female)
                      const Text("♀ ", style: TextStyle(color: Colors.pink, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    if (p.positions.contains(PlayerPosition.setter))
                      const Text(" (L)", style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget? _buildPositionIcon(Player p) {
    if (p.positions.contains(PlayerPosition.setter)) {
      return const Chip(
        label: Text("Levant.", style: TextStyle(fontSize: 10)),
        visualDensity: VisualDensity.compact,
        backgroundColor: Colors.orangeAccent,
      );
    }
    return null;
  }
}