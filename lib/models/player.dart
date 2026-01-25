import 'package:uuid/uuid.dart';

enum PlayerStatus { playing, resting, waiting } // jogando, descansando, esperando
enum PlayerGender { male, female, chil } // Mulher, Homem, Criança
enum PlayerPosition { setter, spiker, libero, allRounder } // levantador, atacante, libero, versátil, (talvez: aprendiz)

class Player {
  final String id;
  String name;
  PlayerGender gender;
  List<PlayerPosition> positions;
  DateTime arrivalTime; // Fundamental para o peso do sorteio
  PlayerStatus status;

  Player({
    String? id,
    required this.name,
    required this.gender,
    required this.positions,
    DateTime? arrivalTime,
    this.status = PlayerStatus.waiting,
  })  : id = id ?? const Uuid().v4(),
        arrivalTime = arrivalTime ?? DateTime.now();

  // Método para calcular o peso (bilhetes na urna)
  // Retorna o número de minutos esperando
  int get ticketWeight {
    if (status != PlayerStatus.waiting) return 0;
    final minutes = DateTime.now().difference(arrivalTime).inMinutes;
    // Garante que tenha pelo menos 1 bilhete se acabou de chegar
    return minutes < 1 ? 1 : minutes;
  }
}