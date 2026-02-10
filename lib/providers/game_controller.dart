import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/game_models.dart';
import '../services/persistence_service.dart';

class GameController extends ChangeNotifier {
  final List<Player> _registeredPlayers = []; 
  List<Player> _playersInQueue = []; 
  Match? _currentMatch; 
  GameConfiguration _config = GameConfiguration.defaultConfig();
  final PersistenceService _persistence = PersistenceService();

  GameController() {
    _init();
  }

  // Inicializar carregando dados salvos
  Future<void> _init() async {
    final savedPlayers = await _persistence.loadPlayers();
    _registeredPlayers.addAll(savedPlayers);
    // Inicialmente, todos os jogadores carregados vão para a fila se não houver partida ativa
    _playersInQueue = List.from(_registeredPlayers);
    notifyListeners();
  }

  List<Player> get registeredPlayers => _registeredPlayers;
  List<Player> get playersInQueue => _playersInQueue;
  Match? get currentMatch => _currentMatch;
  GameConfiguration get config => _config;

  List<Player> get playersOnCourt {
    if (_currentMatch == null) return [];
    return [..._currentMatch!.teamA.players, ..._currentMatch!.teamB.players];
  }

  List<Player> get currentMatchPlayers {
    if (_currentMatch == null) return [];
    return [..._currentMatch!.teamA.players, ..._currentMatch!.teamB.players];
  }

  List<Player> get waitingPlayers {
    return _playersInQueue.where((p) => p.status == PlayerStatus.waiting).toList();
  }

  // Métodos de Persistência
  void _save() {
    _persistence.savePlayers(_registeredPlayers);
  }

  void addPlayer(String name, PlayerGender gender, List<PlayerPosition> positions) {
    final newPlayer = Player(
      name: name,
      gender: gender,
      positions: positions,
      status: PlayerStatus.waiting,
      arrivalTime: DateTime.now(),
    );
    _registeredPlayers.add(newPlayer);
    _playersInQueue.add(newPlayer);
    _save();
    notifyListeners();
  }

  void clearAllPlayers() {
    _registeredPlayers.clear();
    _playersInQueue.clear();
    _currentMatch = null;
    _save();
    notifyListeners();
  }

  void startGame() {
    startInitialMatch();
  }

  void finishMatch() {
    _currentMatch = null;
    for (var p in _registeredPlayers) {
      p.status = PlayerStatus.waiting;
      p.restCounter = 0;
      p.tickets = 0;
    }
    _playersInQueue = List.from(_registeredPlayers);
    _save();
    notifyListeners();
  }

  // Import/Export
  String exportData() {
    return _persistence.exportToJson(_registeredPlayers);
  }

  void importData(String jsonString) {
    try {
      final imported = _persistence.importFromJson(jsonString);
      _registeredPlayers.clear();
      _registeredPlayers.addAll(imported);
      _playersInQueue = List.from(_registeredPlayers);
      _save();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // --- ALGORITMO HÍBRIDO DE SORTEIO ---

  Player? _weightedDraw(List<Player> pool) {
    if (pool.isEmpty) return null;
    int totalTickets = pool.fold(0, (sum, player) => sum + player.tickets);
    if (totalTickets == 0) return pool[Random().nextInt(pool.length)];
    int winningTicket = Random().nextInt(totalTickets);
    int currentSum = 0;
    for (var player in pool) {
      currentSum += player.tickets;
      if (winningTicket < currentSum) return player;
    }
    return pool.last;
  }

  List<Player> _sortearDesafiante(List<Player> disponiveis, GameConfiguration config) {
    List<Player> selecionados = [];
    List<Player> pool = List.from(disponiveis.where((j) => j.restCounter == 0));

    if (pool.isNotEmpty) {
      Player maisAntigo = pool.reduce((a, b) => a.arrivalTime.isBefore(b.arrivalTime) ? a : b);
      selecionados.add(maisAntigo);
      pool.remove(maisAntigo);
    }

    if (config.requireFemale) {
      List<Player> mulheres = pool.where((j) => j.gender == PlayerGender.female).toList();
      if (mulheres.isNotEmpty) {
        Player? mulher = _weightedDraw(mulheres);
        if (mulher != null) {
          selecionados.add(mulher);
          pool.remove(mulher);
        }
      }
    }

    if (config.requireSetter) {
      List<Player> levantadores = pool.where((j) => j.positions.contains(PlayerPosition.setter)).toList();
      if (levantadores.isNotEmpty) {
        Player? levantador = _weightedDraw(levantadores);
        if (levantador != null) {
          selecionados.add(levantador);
          pool.remove(levantador);
        }
      }
    }

    int vagasRestantes = 4 - selecionados.length;
    for (int i = 0; i < vagasRestantes; i++) {
      if (pool.isEmpty) break;
      Player? sorteado = _weightedDraw(pool);
      if (sorteado != null) {
        selecionados.add(sorteado);
        pool.remove(sorteado);
      }
    }
    return selecionados;
  }

  String? startInitialMatch() {
    List<Player> availablePlayers = _playersInQueue.where((p) => p.status == PlayerStatus.waiting).toList();
    if (availablePlayers.length < 8) return "Mínimo de 8 jogadores na fila!";

    List<Player> teamAPlayers = _sortearDesafiante(availablePlayers, _config);
    availablePlayers.removeWhere((p) => teamAPlayers.contains(p));
    List<Player> teamBPlayers = _sortearDesafiante(availablePlayers, _config);
    availablePlayers.removeWhere((p) => teamBPlayers.contains(p));

    for (var p in teamAPlayers) { p.status = PlayerStatus.playingWinner; p.tickets = 0; _playersInQueue.remove(p); }
    for (var p in teamBPlayers) { p.status = PlayerStatus.playingChallenger; p.tickets = 0; _playersInQueue.remove(p); }

    _currentMatch = Match(
      id: const Uuid().v4(),
      teamA: Team(id: const Uuid().v4(), type: TeamType.teamA, players: teamAPlayers),
      teamB: Team(id: const Uuid().v4(), type: TeamType.teamB, players: teamBPlayers),
      timestamp: DateTime.now()
    );

    for (var p in _playersInQueue) { p.tickets++; }
    _save();
    notifyListeners();
    return null;
  }

  String? finishMatchAndDrawChallenger(Team winnerTeam) {
    if (_currentMatch == null) return "Sem partida ativa.";
    Team loserTeam = (winnerTeam.id == _currentMatch!.teamA.id) ? _currentMatch!.teamB : _currentMatch!.teamA;

    for (Player j in winnerTeam.players) {
      j.status = PlayerStatus.playingWinner;
      j.wins++;
      j.matchesPlayed++;
      j.tickets = 0;
    }
    winnerTeam.consecutiveWins++;

    for (Player j in loserTeam.players) {
      j.status = PlayerStatus.resting;
      j.restCounter = _config.restMatches;
      j.tickets++;
      j.losses++;
      j.matchesPlayed++;
    }

    for (Player j in _playersInQueue) { j.tickets++; }

    for (Player j in _registeredPlayers.where((p) => p.status == PlayerStatus.resting)) {
      j.restCounter = max(0, j.restCounter - 1);
      if (j.restCounter == 0) {
        j.status = PlayerStatus.waiting;
        if (!_playersInQueue.contains(j)) _playersInQueue.add(j);
      }
    }

    if (_config.winLimit != null && winnerTeam.consecutiveWins >= _config.winLimit!) {
      for (Player p in playersOnCourt) {
        p.status = PlayerStatus.waiting;
        p.tickets = 0;
        if (!_playersInQueue.contains(p)) _playersInQueue.add(p);
      }
      _currentMatch = null;
      _save();
      notifyListeners();
      return "Limite de vitórias atingido!";
    }

    List<Player> challengerPlayers = _sortearDesafiante(_playersInQueue, _config);
    for (var p in challengerPlayers) {
      p.status = PlayerStatus.playingChallenger;
      p.tickets = 0;
      _playersInQueue.remove(p);
    }

    _currentMatch = Match(
      id: const Uuid().v4(),
      teamA: winnerTeam,
      teamB: Team(id: const Uuid().v4(), type: loserTeam.type, players: challengerPlayers),
      timestamp: DateTime.now()
    );

    _save();
    notifyListeners();
    return null;
  }
}
