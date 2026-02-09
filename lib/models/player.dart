import 'package:uuid/uuid.dart';

enum PlayerStatus { 
  playingWinner,    // Jogando_Vencedor
  playingChallenger, // Jogando_Desafiante
  resting,           // Descansando
  waiting            // Na_Barreira
}

enum PlayerGender { 
  male,   // Masculino
  female  // Feminino
}

enum PlayerPosition { 
  setter,   // Levantador
  spiker,   // Ponteiro
  opposite, // Oposto
  libero    // Libero
}

class Player {
  final String id;
  String name;
  PlayerGender gender;
  List<PlayerPosition> positions;
  
  // Controle de Fila
  DateTime arrivalTime;    // timestampChegada: Para vaga de justiça
  int tickets;             // bilhetes: Para sorteio ponderado
  int restCounter;         // contadorDescanso: Partidas restantes de descanso
  
  // Estado Atual
  PlayerStatus status;
  
  // Estatísticas
  int wins;
  int losses;
  int matchesPlayed;

  Player({
    String? id,
    required this.name,
    required this.gender,
    required this.positions,
    DateTime? arrivalTime,
    this.tickets = 0,
    this.restCounter = 0,
    this.status = PlayerStatus.waiting,
    this.wins = 0,
    this.losses = 0,
    this.matchesPlayed = 0,
  })  : id = id ?? const Uuid().v4(),
        arrivalTime = arrivalTime ?? DateTime.now();

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender.index,
      'positions': positions.map((p) => p.index).toList(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'tickets': tickets,
      'restCounter': restCounter,
      'status': status.index,
      'wins': wins,
      'losses': losses,
      'matchesPlayed': matchesPlayed,
    };
  }

  // Método para criar de JSON
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      gender: PlayerGender.values[json['gender']],
      positions: (json['positions'] as List).map((p) => PlayerPosition.values[p]).toList(),
      arrivalTime: DateTime.parse(json['arrivalTime']),
      tickets: json['tickets'],
      restCounter: json['restCounter'],
      status: PlayerStatus.values[json['status']],
      wins: json['wins'],
      losses: json['losses'],
      matchesPlayed: json['matchesPlayed'],
    );
  }
}
