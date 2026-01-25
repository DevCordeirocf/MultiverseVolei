import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';

class GameController extends ChangeNotifier {
  final List<Player> _players = [];

  // Getters para a UI saber quem é quem
  List<Player> get waitingPlayers =>
      _players.where((p) => p.status == PlayerStatus.waiting).toList();

  List<Player> get currentMatchPlayers =>
      _players.where((p) => p.status == PlayerStatus.playing).toList();

  // --- O ALGORITMO (A Mágica) ---

  // Sorteia um único jogador da lista baseado no peso (tempo de espera)
  Player? _weightedDraw(List<Player> pool) {
    if (pool.isEmpty) return null;

    // 1. Soma total de bilhetes (minutos de espera)
    int totalTickets = pool.fold(0, (sum, player) => sum + player.ticketWeight);

    // Se ninguém tem tempo acumulado (acabaram de chegar), sorteia aleatório simples
    if (totalTickets == 0) {
      return pool[Random().nextInt(pool.length)];
    }

    // 2. Escolhe o bilhete premiado
    int winningTicket = Random().nextInt(totalTickets);

    // 3. Encontra o dono do bilhete
    int currentSum = 0;
    for (var player in pool) {
      currentSum += player.ticketWeight;
      if (winningTicket < currentSum) {
        return player;
      }
    }
    // Caso de segurança (não deve acontecer)
    return pool.last;
  }

  // Função Principal: GERAR TIMES
  // Retorna uma String de erro se algo der errado, ou null se der certo.
  String? startGame({bool forceFemale = false, bool forceSetter = false}) {
    // Regra Básica: Precisa de pelo menos 8 pessoas na fila (ou fila + quem estava jogando se quiser rodar direto, mas vamos focar na fila)
    if (waitingPlayers.length < 8) {
      return "Precisamos de pelo menos 8 jogadores na fila!";
    }

    // 1. Quem estava jogando vai para o DESCANSO (Fim da fila)
    // Eles saem do status 'playing' e voltam para 'waiting' com o horário de AGORA (zerando o peso)
    for (var p in currentMatchPlayers) {
      p.status = PlayerStatus.waiting;
      p.arrivalTime = DateTime.now(); // Zera o tempo de espera
    }

    List<Player> selectedPlayers = [];

    // Cria uma cópia da fila para podermos remover quem for sendo sorteado sem quebrar a lista original
    List<Player> pool = List.from(waitingPlayers);

    // --- FILTROS OBRIGATÓRIOS ---

    // Filtro 1: Vaga Feminina Obrigatória (pelo menos 1 por time = 2 total)
    if (forceFemale) {
      var females = pool.where((p) => p.gender == PlayerGender.female).toList();
      // Precisamos de 2 mulheres. Sorteamos 2 usando o peso entre elas.
      for (int i = 0; i < 2; i++) {
        if (females.isNotEmpty) {
          Player? chosen = _weightedDraw(females);
          if (chosen != null) {
            selectedPlayers.add(chosen);
            pool.remove(chosen); // Tira da urna geral
            females.remove(chosen); // Tira da urna feminina
          }
        }
      }
    }

    // Filtro 2: Levantador Obrigatório (pelo menos 1 por time = 2 total)
    if (forceSetter) {
      // Procura quem é Setter OU AllRounder
      var setters = pool.where((p) =>
      p.positions.contains(PlayerPosition.setter) ||
          p.positions.contains(PlayerPosition.allRounder)
      ).toList();

      // Precisamos preencher até ter 2 levantadores no total (contando com quem já foi sorteado antes, ex: uma menina levantadora)
      int currentSetters = selectedPlayers.where((p) =>
      p.positions.contains(PlayerPosition.setter) ||
          p.positions.contains(PlayerPosition.allRounder)
      ).length;

      int needed = 2 - currentSetters;

      for (int i = 0; i < needed; i++) {
        if (setters.isNotEmpty) {
          Player? chosen = _weightedDraw(setters);
          if (chosen != null) {
            selectedPlayers.add(chosen);
            pool.remove(chosen);
            setters.remove(chosen);
          }
        }
      }
    }

    // --- PREENCHIMENTO FINAL ---
    // Preenche as vagas restantes até dar 8 jogadores
    while (selectedPlayers.length < 8) {
      if (pool.isEmpty) break; // Não deve acontecer devido à checagem inicial

      Player? chosen = _weightedDraw(pool);
      if (chosen != null) {
        selectedPlayers.add(chosen);
        pool.remove(chosen);
      }
    }

    // --- ATUALIZAÇÃO DE STATUS ---
    // Marca os 8 escolhidos como 'playing'
    for (var p in selectedPlayers) {
      // Precisamos achar o objeto original na lista principal e atualizar
      int index = _players.indexOf(p);
      if (index != -1) {
        _players[index].status = PlayerStatus.playing;
      }
    }

    notifyListeners(); // Atualiza a tela!
    return null; // Sucesso
  }

  // Função para FINALIZAR PARTIDA manualmente (opcional, pois o "Gerar Times" já faz o ciclo)
  void finishMatch() {
    for (var p in currentMatchPlayers) {
      p.status = PlayerStatus.waiting;
      p.arrivalTime = DateTime.now();
    }
    notifyListeners();
  }

  // Cadastro (mantido igual)
  void addPlayer(String name, PlayerGender gender, List<PlayerPosition> pos) {
    final positions = pos.isEmpty ? [PlayerPosition.allRounder] : pos;
    _players.add(
      Player(
        name: name,
        gender: gender,
        positions: positions,
        status: PlayerStatus.waiting,
        arrivalTime: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}