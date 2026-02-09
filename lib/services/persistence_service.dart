import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class PersistenceService {
  static const String _playersKey = 'jogadores_cadastrados';

  // Salvar lista de jogadores
  Future<void> savePlayers(List<Player> players) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      players.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_playersKey, encodedData);
  }

  // Carregar lista de jogadores
  Future<List<Player>> loadPlayers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_playersKey);
    
    if (encodedData == null) return [];

    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Player.fromJson(item)).toList();
  }

  // Exportar para string JSON (para o usuário copiar/compartilhar)
  String exportToJson(List<Player> players) {
    return jsonEncode({
      "jogadores_cadastrados": players.map((p) => p.toJson()).toList(),
    });
  }

  // Importar de string JSON
  List<Player> importFromJson(String jsonString) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final List<dynamic> list = decoded['jogadores_cadastrados'];
      return list.map((item) => Player.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Erro ao importar JSON: Formato inválido");
    }
  }
}
