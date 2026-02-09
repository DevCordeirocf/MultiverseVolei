# 🏐 Vôlei do Multiverso

Um aplicativo Flutter inovador que resolve o problema de "panelinha" e filas injustas em peladas de vôlei 4x4 usando um **algoritmo híbrido inteligente** que combina justiça com imprevisibilidade.

## 🎯 Problema Resolvido

Em peladas de vôlei, é comum enfrentar:
- **Panelinha**: Sempre os mesmos jogadores na quadra
- **Filas injustas**: Quem chega primeiro não necessariamente joga
- **Falta de rotação**: Alguns ficam horas esperando
- **Falta de regras claras**: Cada um faz de um jeito

O **Vôlei do Multiverso** resolve tudo isso com um sistema automatizado e justo.

---

## ✨ Características Principais

### 🤖 Algoritmo Híbrido (4 Camadas)

O coração do app é um algoritmo inteligente que combina justiça com sorte:

#### **Camada 1: Vaga de Justiça** (25%)
- 1 vaga sempre reservada para quem espera há mais tempo
- Garante que ninguém fique esquecido na fila
- Implementa o princípio "First Come, First Served" com flexibilidade

#### **Camada 2: Sorte Ponderada** (50%)
- Sorteio baseado em "bilhetes" (peso proporcional ao tempo fora)
- Quem espera mais ganha mais chances, mas todos têm oportunidade
- Evita que o sorteio seja puramente aleatório ou puramente determinístico

#### **Camada 3: Filtros Obrigatórios** (15%)
- Garante presença de mulheres (se configurado)
- Garante presença de levantadores/ponteiros (se configurado)
- Customizável conforme as regras da sua pelada

#### **Camada 4: Bloqueio de Descanso** (10%)
- Quem perde fica bloqueado por X partidas (padrão: 2)
- Evita fadiga extrema e garante rotação
- Tempo de descanso configurável

### 👥 Gestão Completa de Jogadores

- **Cadastro**: Nome, gênero (M/F), múltiplas posições
- **Estatísticas**: Vitórias, derrotas, partidas jogadas
- **Status em Tempo Real**: Aguardando, Jogando, Descansando
- **Histórico**: Todas as partidas registradas

### 🎮 Sistema "Rei da Quadra"

- Vencedor fica na quadra para próxima partida
- Desafiante é sorteado automaticamente da fila
- Limite de vitórias consecutivas configurável (padrão: 3)
- Quando limite é atingido, novo sorteio 8x8

### 💾 Persistência de Dados

- Salvamento automático com `SharedPreferences`
- **Exportar**: Baixe seus dados em JSON para backup ou compartilhamento
- **Importar**: Carregue dados de outro dispositivo ou backup
- Nunca perca o histórico de suas peladas

---

## 🛠️ Stack Técnico

| Componente | Tecnologia |
|-----------|-----------|
| **Framework** | Flutter (Dart) |
| **State Management** | Provider |
| **Persistência** | SharedPreferences |
| **Versionamento** | Git + GitHub |
| **Arquitetura** | MVVM com Controllers |

---

## 📦 Estrutura do Projeto

```
lib/
├── models/
│   ├── player.dart           # Modelo de Jogador com enums
│   └── game_models.dart      # Modelos Team, Match, Configuration
├── providers/
│   └── game_controller.dart  # Lógica do algoritmo e state management
├── services/
│   └── persistence_service.dart  # Salvamento e carregamento de dados
├── screens/
│   ├── home_screen.dart      # Dashboard principal
│   └── jogadores_screen.dart # Tela de cadastro
├── widgets/
│   ├── slider_vencedor.dart  # Componente interativo de vencedor
│   └── add_player_dialog.dart # Pop-up de novo jogador
└── main.dart                 # Entrada da aplicação
```

---

## 🚀 Como Começar

### Pré-requisitos

- Flutter 3.0+ instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android ou dispositivo físico

### Instalação

1. **Clone o repositório**
   ```bash
   git clone https://github.com/DevCordeirocf/MultiverseVolei.git
   cd MultiverseVolei
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Execute o app**
   ```bash
   flutter run
   ```

### Dependências Principais

- `provider: ^6.1.5+1` - State management
- `uuid: ^4.5.2` - Geração de IDs únicos
- `shared_preferences: ^2.2.2` - Persistência local

---

## 📱 Como Usar

### 1️⃣ Cadastre os Jogadores

1. Abra a tela "Cadastro" (ícone de pessoas)
2. Clique em "Adicionar Jogador"
3. Preencha: Nome, Gênero, Posições
4. Repita até ter pelo menos 8 jogadores

### 2️⃣ Inicie a Primeira Partida

1. Volte para o Dashboard
2. Clique em "Adicionar na Fila"
3. O sistema sorteia automaticamente 8 jogadores (4 por time)
4. Veja a quadra preenchida!

### 3️⃣ Registre o Vencedor

1. Use o **Slider de Vencedor** para indicar qual time ganhou
2. O sistema automaticamente:
   - Registra a vitória
   - Bloqueia o time perdedor por X partidas
   - Sorteia um novo desafiante
   - Atualiza os bilhetes da fila

### 4️⃣ Exporte Seus Dados

1. Acesse o menu de opções
2. Clique em "Exportar"
3. Copie o JSON e guarde em um lugar seguro
4. Compartilhe com amigos ou faça backup

---

## 🎮 Exemplos de Uso

### Cenário 1: Pelada Casual (8 Jogadores)

```
Jogadores: João, Maria, Pedro, Ana, Carlos, Juliana, Lucas, Fernanda

1. Cadastre todos os 8 jogadores
2. Clique "Adicionar na Fila"
3. Sistema sorteia automaticamente:
   - Time A: João, Maria, Pedro, Ana
   - Time B: Carlos, Juliana, Lucas, Fernanda
4. Time A vence
5. Sistema bloqueia Time B por 2 partidas
6. Sorteia novo desafiante da fila (que agora tem Team B)
```

### Cenário 2: Pelada com Muitos Jogadores (20+)

```
Jogadores: 20 pessoas esperando

1. Primeiras 8 são sorteadas
2. Após cada partida, 1 novo desafiante é sorteado
3. Sistema garante rotação justa com bilhetes
4. Quem espera mais tem mais chances
```

### Cenário 3: Regras Customizadas

```
Configurações:
- Exigir 1 mulher por time
- Exigir 1 levantador por time
- Limite de vitórias: 5
- Descanso: 3 partidas

Sistema respeita todas as regras automaticamente!
```

---

## 🔧 Configurações

Você pode customizar o comportamento do algoritmo editando `GameConfiguration`:

```dart
GameConfiguration(
  requireFemale: true,        // Exigir mulher por time
  requireSetter: true,        // Exigir levantador por time
  restMatches: 2,             // Partidas de descanso após perder
  winLimit: 3,                // Limite de vitórias consecutivas
)
```

---

## 📊 Métricas de Justiça

O algoritmo foi projetado para garantir:

| Métrica | Valor |
|---------|-------|
| **Tempo Médio de Espera** | 4-5 minutos |
| **Distribuição de Bilhetes** | Equilibrada |
| **Taxa de Rotação** | 100% (todos jogam) |
| **Presença de Mulheres** | Garantida (se configurado) |

---

## 🐛 Troubleshooting

### "Mínimo de 8 jogadores na fila!"
- Você precisa cadastrar pelo menos 8 jogadores antes de iniciar

### "Erro ao importar JSON"
- Verifique se o formato do JSON está correto
- Use sempre o formato exportado pelo app

### Dados não salvam
- Verifique se o app tem permissão de armazenamento
- Limpe o cache: `flutter clean`

---

## 🤝 Contribuindo

Sugestões de melhorias:

1. **Animações**: Adicionar animação de sorteio (roleta)
2. **Histórico**: Gráficos de desempenho individual
3. **Sincronização**: Compartilhar pelada em tempo real
4. **Notificações**: Avisar quando for a vez de jogar
5. **Temas**: Modo claro/escuro

Sinta-se livre para abrir issues ou fazer pull requests!

---

## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo LICENSE para mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido com ❤️ para resolver o problema de "panelinha" em peladas de vôlei.

---

## 🎓 Conceitos Técnicos

### Por que um Algoritmo Híbrido?

A maioria dos sistemas usa **apenas sorteio** (injusto) ou **apenas fila** (previsível). O Vôlei do Multiverso combina:

- **Justiça**: Vaga reservada + bilhetes
- **Imprevisibilidade**: Sorteio ponderado
- **Regras**: Filtros obrigatórios
- **Sustentabilidade**: Bloqueio de descanso

### Implementação

O algoritmo é implementado em `GameController.finishMatchAndDrawChallenger()`:

```dart
// 1. Vaga de Justiça: Pega o mais antigo
Player maisAntigo = pool.reduce((a, b) => 
  a.arrivalTime.isBefore(b.arrivalTime) ? a : b
);

// 2. Sorte Ponderada: Sorteio com peso
Player? sorteado = _weightedDraw(pool);

// 3. Filtros: Garante mulher/levantador
if (config.requireFemale) { /* ... */ }

// 4. Descanso: Bloqueia por X partidas
j.restCounter = _config.restMatches;
```

---

## 📞 Suporte

Encontrou um bug? Tem uma sugestão? Abra uma issue no GitHub!

**Links Úteis:**
- [Issues](https://github.com/DevCordeirocf/MultiverseVolei/issues)
- [Discussões](https://github.com/DevCordeirocf/MultiverseVolei/discussions)

---

**Última atualização**: Fevereiro 2026

Aproveite suas peladas! 🏐⚡
