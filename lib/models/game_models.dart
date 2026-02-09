import 'player.dart';

enum TeamType { teamA, teamB } // TimeA (azul), TimeB (vermelho)
enum TeamStatus { active, finished }

class Team {
  final String id;
  final TeamType type;
  final List<Player> players; // Sempre 4 jogadores
  int consecutiveWins;
  TeamStatus status;

  Team({
    required this.id,
    required this.type,
    required this.players,
    this.consecutiveWins = 0,
    this.status = TeamStatus.active,
  });
}

class Match {
  final String id;
  final Team teamA;
  final Team teamB;
  Team? winner;
  final DateTime timestamp;
  Duration? duration;

  Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.winner,
    required this.timestamp,
    this.duration,
  });
}

class GameConfiguration {
  // Filtros de Balanceamento
  bool requireFemale;      // exigirMulher
  bool requireSetter;      // exigirLevantador
  bool requireSpiker;      // exigirPonteiro
  
  // Regras de Rotação
  int? winLimit;           // limiteVitorias (null = sem limite, padrão: 3)
  int restMatches;         // partidasDescanso (0-5, padrão: 1)

  GameConfiguration({
    this.requireFemale = true,
    this.requireSetter = true,
    this.requireSpiker = false,
    this.winLimit = 3,
    this.restMatches = 1,
  });

  // Configuração padrão
  factory GameConfiguration.defaultConfig() {
    return GameConfiguration(
      requireFemale: true,
      requireSetter: true,
      winLimit: 3,
      restMatches: 1,
    );
  }
}
