# Vôlei do Multiverso

Um aplicativo Flutter para gerenciamento justo e automatizado de peladas de vôlei 4x4. Implementa um algoritmo híbrido que combina princípios de justiça distributiva com sorteio ponderado, eliminando problemas comuns como panelinha e filas injustas.

## Problema

Peladas de vôlei recreativas enfrentam desafios estruturais:

- **Seleção enviesada**: Sempre os mesmos jogadores na quadra
- **Filas não-determinísticas**: Ordem de chegada não garante oportunidade de jogo
- **Falta de rotação**: Alguns jogadores ficam longos períodos sem jogar
- **Ausência de regras claras**: Cada pelada implementa critérios diferentes, causando conflitos

Estes problemas reduzem a satisfação dos participantes e afetam a sustentabilidade de grupos de vôlei recreativo.

## Solução

O Vôlei do Multiverso implementa um **algoritmo híbrido de 4 camadas** que equilibra justiça com imprevisibilidade:

### Camada 1: Vaga de Justiça (25%)
Uma vaga em cada sorteio é reservada para o jogador com maior tempo de espera. Implementa o princípio "First Come, First Served" com flexibilidade, garantindo que ninguém seja sistematicamente excluído.

### Camada 2: Sorte Ponderada (50%)
O sorteio utiliza um sistema de "bilhetes" onde o peso de cada jogador é proporcional ao tempo fora da quadra. Jogadores que esperam mais ganham mais chances, mas todos mantêm oportunidade de seleção. Evita determinismo puro ou aleatoriedade total.

### Camada 3: Filtros Obrigatórios (15%)
Garante presença de posições específicas (levantador, ponteiro) e gêneros (mulheres) conforme configurado. Customizável para respeitar regras locais de cada grupo.

### Camada 4: Bloqueio de Descanso (10%)
Jogadores que perdem são bloqueados por X partidas (padrão: 2), evitando fadiga extrema e garantindo rotação natural. Tempo configurável.

## Características

### Gestão de Jogadores
- Cadastro com nome, gênero e múltiplas posições
- Rastreamento de estatísticas (vitórias, derrotas, partidas)
- Status em tempo real (aguardando, jogando, descansando)
- Histórico completo de partidas

### Sistema de Partidas
- Sorteio automático de times (4v4)
- Modelo "Rei da Quadra" (vencedor permanece)
- Limite de vitórias consecutivas configurável
- Sorteio de novo desafiante após cada partida

### Persistência de Dados
- Salvamento automático com SharedPreferences
- Exportação em JSON para backup e compartilhamento
- Importação de dados de outro dispositivo
- Histórico preservado entre sessões

## Stack Técnico

| Componente | Tecnologia |
|-----------|-----------|
| Framework | Flutter 3.0+ |
| Linguagem | Dart |
| State Management | Provider 6.1+ |
| Persistência | SharedPreferences 2.2+ |
| Identificadores | UUID 4.5+ |
| Controle de Versão | Git |

## Arquitetura

```
lib/
├── models/
│   ├── player.dart              # Modelo Player com enums de status, gênero, posição
│   └── game_models.dart         # Modelos Team, Match, GameConfiguration
├── providers/
│   └── game_controller.dart     # Lógica de negócio e state management
├── services/
│   └── persistence_service.dart # Serialização e persistência de dados
├── screens/
│   ├── home_screen.dart         # Dashboard principal
│   └── jogadores_screen.dart    # Tela de cadastro de jogadores
├── widgets/
│   ├── slider_vencedor.dart     # Componente de seleção de vencedor
│   └── add_player_dialog.dart   # Dialog de cadastro de jogador
└── main.dart                    # Ponto de entrada
```

## Instalação

### Pré-requisitos
- Flutter 3.0 ou superior
- Dart 3.0 ou superior
- Android SDK 21+ (para Android)

### Passos

1. Clone o repositório:
```bash
git clone https://github.com/DevCordeirocf/MultiverseVolei.git
cd MultiverseVolei
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute em um emulador ou dispositivo:
```bash
flutter run
```

## Uso

### Fluxo Básico

1. **Cadastro de Jogadores**
   - Acesse a tela de cadastro
   - Adicione jogadores com nome, gênero e posições
   - Mínimo de 8 jogadores para iniciar

2. **Sorteio Inicial**
   - Clique em "Adicionar na Fila"
   - O sistema sorteia automaticamente 8 jogadores (4 por time)

3. **Registro de Resultado**
   - Use o slider para indicar o time vencedor
   - Sistema registra vitória e bloqueia time perdedor
   - Novo desafiante é sorteado automaticamente

4. **Exportação de Dados**
   - Acesse menu de opções
   - Exporte dados em JSON para backup ou compartilhamento

### Configuração

O comportamento do algoritmo pode ser customizado via `GameConfiguration`:

```dart
GameConfiguration(
  requireFemale: true,        // Exigir mulher por time
  requireSetter: true,        // Exigir levantador por time
  restMatches: 2,             // Partidas de descanso após derrota
  winLimit: 3,                // Limite de vitórias consecutivas
)
```

## Métricas de Desempenho

O algoritmo foi projetado para otimizar:

| Métrica | Alvo |
|---------|------|
| Tempo médio de espera | 4-5 minutos |
| Desvio padrão de oportunidades | < 15% |
| Taxa de rotação | 100% |
| Conformidade com filtros | 100% |

## Detalhes Técnicos

### Algoritmo de Sorteio

O sorteio é implementado em `GameController._sortearDesafiante()`:

```dart
// 1. Justiça: Seleciona o mais antigo na fila
Player maisAntigo = pool.reduce((a, b) => 
  a.arrivalTime.isBefore(b.arrivalTime) ? a : b
);
selecionados.add(maisAntigo);

// 2. Sorte Ponderada: Sorteio com peso baseado em bilhetes
Player? sorteado = _weightedDraw(pool);

// 3. Filtros: Garante presença de posições/gêneros
if (config.requireFemale) {
  List<Player> mulheres = pool.where((j) => j.gender == PlayerGender.female).toList();
  Player? mulher = _weightedDraw(mulheres);
  if (mulher != null) selecionados.add(mulher);
}

// 4. Descanso: Bloqueia jogadores em período de recuperação
for (Player j in _registeredPlayers.where((p) => p.status == PlayerStatus.resting)) {
  j.restCounter = max(0, j.restCounter - 1);
  if (j.restCounter == 0) {
    j.status = PlayerStatus.waiting;
  }
}
```

### Persistência

Dados são persistidos automaticamente após cada alteração usando `SharedPreferences`. Suporta export/import em JSON para portabilidade.

## Troubleshooting

### "Mínimo de 8 jogadores na fila"
Cadastre pelo menos 8 jogadores antes de iniciar o sorteio.

### "Erro ao importar JSON"
Verifique se o arquivo JSON foi exportado pelo aplicativo. Formatos externos podem não ser compatíveis.

### Dados não persistem
- Verifique permissões de armazenamento do aplicativo
- Execute `flutter clean` para limpar cache
- Reinstale o aplicativo

## Contribuindo

Contribuições são bem-vindas. Para mudanças significativas, abra uma issue primeiro para discutir as alterações propostas.

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Roadmap

- [ ] Animações de sorteio
- [ ] Dashboard de estatísticas individual
- [ ] Sincronização em tempo real entre dispositivos
- [ ] Notificações push
- [ ] Modo escuro/claro
- [ ] Suporte a múltiplas peladas simultâneas

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.

## Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

**Última atualização**: Fevereiro 2026
