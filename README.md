# The Game

Projeto Roblox organizado com Rojo, Wally e Modux.

Este README e o mapa principal do projeto: ele explica como rodar o jogo no
Studio, onde cada tipo de codigo deve morar e como separar responsabilidade
entre `Service`, `Controller`, `Component`, `Mixin`, dados e rede.

Para detalhes internos do framework, leia tambem
[`src/shared/Modux/README.md`](src/shared/Modux/README.md).

## Stack

- `Rojo`: sincroniza `src/`, `Packages/` e `ServerPackages/` com o Roblox
  Studio.
- `Wally`: gerencia dependencias Roblox.
- `Modux`: carrega Services, Controllers, Components, Mixins, lifecycles,
  cleanup, signals, ticks e network.
- `Luau LSP` + `StyLua`: autocomplete, tipos e formatacao.

## Setup

Instale:

1. Roblox Studio.
2. Rojo plugin no Roblox Studio.
3. VS Code com as extensoes recomendadas em `.vscode/extensions.json`.
4. Uma toolchain Roblox: Rokit ou Aftman.
5. Wally.

Depois rode:

```powershell
wally install
rojo serve default.project.json
```

No Roblox Studio, conecte o plugin Rojo ao servidor local.

O projeto e mapeado assim:

```text
ReplicatedStorage
+-- Packages          <- Wally shared packages
`-- Shared            <- src/shared

ServerScriptService
+-- ServerPackages    <- Wally server packages
`-- Server            <- src/server

StarterPlayer
`-- StarterPlayerScripts
    `-- Client        <- src/client
```

## Estrutura

```text
src/
+-- client/
|   +-- Components/      <- componentes que rodam so no cliente
|   +-- Controllers/     <- input, UI, camera, render e feedback local
|   `-- init.client.luau <- Modux.Start() do cliente
+-- server/
|   +-- Components/      <- comportamento autoritativo por instancia/tag
|   +-- Services/        <- regras globais do servidor
|   `-- ModuxInit.server.luau
`-- shared/
    +-- Components/      <- mixins/componentes sem dependencia client/server
    +-- Datas/           <- tabelas de conteudo estatico
    +-- Enums/           <- tipos/nomes fechados
    +-- Modux/           <- framework e arquivos gerados
    +-- Settings/        <- balanceamento e configuracoes
    +-- Templates/       <- templates de dados
    `-- Utils/           <- funcoes puras e helpers pequenos
```

Nao edite manualmente `src/shared/Modux/Manifest.luau` e
`src/shared/Modux/Types.luau`; eles sao gerados pelo tooling do Modux.

## Regra Mental

Quando ficar em duvida sobre onde colocar uma feature, pergunte: "quem e o
dono natural desse comportamento?"

| Dono | Use | Exemplo no projeto |
| --- | --- | --- |
| Servidor inteiro | `Service` | `ProfileService`, `EnemyService`, `DayNightService` |
| Jogador local | `Controller` | `MovementController`, `VitalController`, `ScreenController` |
| Uma instancia com tag | `Component` | `VitalComponent`, `SpawnAreaComponent`, `OxygenZoneComponent` |
| Comportamento reutilizavel | `Mixin` | `PlayerZoneComponent`, `AlienBaseMixin` |
| Conteudo/configuracao | `Datas`, `Settings`, `Enums`, `Templates` | `EnemyTypes`, `DayCycle`, `Profile` |
| Helper sem estado de jogo | `Utils` | `FSM`, databases e helpers de thumbnail |

## Responsabilidades

### Service

Um `Service` e singleton e normalmente roda no servidor. Ele deve guardar regras
autoritativas, orquestrar sistemas e expor uma API para outros Services ou
Components.

Use Service para:

- Perfil, save/load, leaderstats e dados persistentes.
- Spawn, ondas, dia/noite, dificuldade e regras globais.
- Criar tags em Players, Characters ou instancias quando isso habilita
  Components.
- Registrar handlers de rede que validam pedidos do cliente.
- Coordenar varios Components sem depender de uma instancia especifica.

Evite em Service:

- Animar UI.
- Ler input diretamente.
- Guardar estado que pertence a uma unica instancia tagueada.
- Colocar dados de balanceamento hardcoded quando poderiam ficar em `Settings`
  ou `Datas`.

### Controller

Um `Controller` e singleton do cliente. Ele traduz input, UI e feedback visual
em intencoes para o servidor, ou renderiza dados recebidos da rede.

Use Controller para:

- Input do jogador local.
- HUD, menus, barras, notificacoes e animacoes de UI.
- Camera, audio local e renderizacao client-side.
- Enviar intents para o servidor via `Network.Packages`.
- Consumir pacotes do servidor e atualizar tela.

Evite em Controller:

- Alterar dado persistente diretamente.
- Decidir dano, recompensa, spawn ou regra autoritativa.
- Acessar DataStore/ProfileStore.
- Confiar que um valor enviado pelo cliente e valido sem validacao no servidor.

### Component

Um `Component` representa comportamento preso a uma instancia com tag do
`CollectionService`. Ele nasce e morre junto da instancia.

Use Component para:

- Estado e comportamento por Player, BasePart, Model, zona ou objeto.
- Ler attributes/children da propria instancia.
- Expor metodos como `TakeDamage`, `CanSpawn`, `GetSpawnCFrame`.
- Registrar eventos/ticks que so fazem sentido enquanto aquela instancia
  existe.

O contrato de `self.Instance` deve refletir a instancia real que existe no
Roblox Studio. Evite deixar o componente como `Instance` generico quando ele
sempre nasce em um `Model`, `Part`, `Player` etc. Declare `:ClassName()` com a
classe real e use `:Children()` para filhos obrigatorios; assim o tooling do
Modux consegue gerar um tipo util, com acesso aos descendentes no autocomplete.

Exemplo real do painel solar:

```luau
local BasicSolarComponent = Modux.Component("BasicSolarComponent")
	:Tag("BasicSolar")
	:ClassName("Model")
	:Children({
		"Cube_Node",
		"Cube.001",
		"Panel",
	})
```

Com o snapshot do Studio atualizado, `self.Instance` deve representar o mesmo
modelo tagueado em `Workspace.SolarPanels.Basic`, incluindo filhos como
`Panel`.

Evite em Component:

- Controlar o jogo inteiro.
- Procurar todos os players ou todas as entidades sem necessidade.
- Ter dependencias circulares com Services.
- Resolver UI do jogador local quando o Component roda no servidor.

### Mixin

Um `Mixin` e uma composicao reutilizavel para Components. Ele nao deve ser uma
feature completa sozinho.

Use Mixin para:

- Compartilhar comportamento entre Components parecidos.
- Evitar copiar logica de zona, alien base, interacao, cooldown ou observacao.
- Definir helpers e lifecycles comuns.

Exemplos atuais:

- `PlayerZoneComponent`: comportamento compartilhado para zonas que observam
  players.
- `AlienBaseMixin`: base comum para aliens.

## Fluxos Atuais

### Player e Profile

`PlayerService` observa entrada, saida e character dos jogadores. Outros
Services dependem dele com `:Import("PlayerService")`.

`ProfileService` importa `PlayerService`, carrega o perfil no servidor e replica
dados para o cliente usando `Data` e `DataKey`.

### Vitals

`VitalService` adiciona tags nos Players:

- `VitalComponent`
- `OxygenComponent`
- `HungerComponent`

`VitalComponent` e dono dos valores por jogador: `Health`, `Hunger`, `Oxygen`,
`Armor` e `Stamina`. Ele replica alteracoes com `VitalKey`.

`VitalController` roda no cliente e so atualiza a HUD com os valores recebidos.

### Movement

`MovementController` le input local e envia uma intencao:

```text
Input -> MovementController -> ChangeMovement
```

`MovementComponent` recebe o pedido, valida/transiciona o estado com FSM e
responde com `ChangeWalkSpeed`.

```text
ChangeMovement -> MovementComponent -> ChangeWalkSpeed -> MovementController
```

### Enemies

`EnemyService` escolhe area, dificuldade, peso e tipo de alien.

`SpawnAreaComponent` descreve uma area marcada com tag `SpawnArea` e responde:

- se pode spawnar naquela dificuldade;
- quais pesos de aliens ela aceita;
- qual `CFrame` usar para spawn.

`EnemyRenderController` cuida apenas da renderizacao client-side dos proxies de
inimigos.

### UI

`ScreenController` registra janelas e botoes tagueados:

- `ModuxUI.Window`
- `ModuxUI.OpenButton`
- `ModuxUI.CloseButton`

`UIAnimationsController` centraliza animacoes reutilizaveis de UI.

Outros Controllers devem pedir para `ScreenController` abrir/fechar janelas em
vez de duplicar essa logica.

## Rede

Os pacotes ficam em:

```text
src/shared/Modux/src/Network/init.luau
```

Regras:

- Declare pacotes e queries em um unico lugar.
- Cliente envia intencao; servidor valida e executa.
- Servidor envia estado aprovado; cliente renderiza.
- Prefira `keyPacket` para replicar uma chave especifica sem reenviar uma
  tabela inteira.
- Nomeie pacotes pelo dominio da feature: `VitalKey`, `DataKey`,
  `ChangeMovement`, `TransitionCycle`.

Pacotes atuais importantes:

- `Data` e `DataKey`: perfil do jogador.
- `VitalKey` e `GetVitals`: status do jogador.
- `ChangeMovement` e `ChangeWalkSpeed`: movimento.
- `TransitionCycle`, `SecondsCycle`, `DayCycle`: ciclo de dia/noite.
- `ZoneNotification`: notificacoes de zona.

## Exemplo: Solar Panel / Generator

Para a feature de energia, uma separacao saudavel seria:

```text
src/shared/Datas/SolarPanels.luau
ou
src/shared/Utils/SolarPanelDatabase.luau
    Dados estaticos de cada painel: producao, custo, tier, modelo.

src/server/Components/SolarPanelComponent.luau
    Estado por painel colocado no mapa.
    Ex.: producao atual, conexao, dono, status ligado/desligado.
    Deve declarar a classe/filhos reais do modelo no Studio para que
    self.Instance tenha o tipo correto.

src/server/Services/GeneratorService.luau
    Regras globais da rede de energia.
    Ex.: registrar paineis, somar producao, alimentar bases/maquinas.

src/client/Controllers/GeneratorController.luau
    Somente UI/feedback local caso exista tela de energia.
```

Regra pratica:

- Se a informacao pertence a um painel especifico, fica no
  `SolarPanelComponent`.
- Se a informacao depende de varios paineis ou da base inteira, fica no
  `GeneratorService`.
- Se e apenas configuracao, fica em `Datas`, `Settings` ou database.
- Se e visual/UI do jogador local, fica em um Controller.

Exemplo de fluxo:

```text
SolarPanelComponent inicia
-> le configuracao pelo nome/tier
-> registra no GeneratorService
-> GeneratorService recalcula energia total
-> opcionalmente replica resumo para UI
```

## Checklist Para Nova Feature

1. Defina o dominio: vitals, movement, enemy, generator, zone, profile etc.
2. Coloque configuracao estatica em `shared/Datas` ou `shared/Settings`.
3. Crie um `Service` se a regra for global/autoritativa.
4. Crie um `Component` se a regra pertencer a uma instancia com tag.
5. Crie um `Controller` se houver input, UI ou render local.
6. Declare pacotes em `Network/init.luau` se client e server precisarem
   conversar.
7. Use `:Import("OutroService")` para dependencia entre singletons.
8. Use `self:Cleanup(connection)` para toda connection criada em lifecycle.
9. Gere/atualize tipos do Modux se adicionar novos objetos ou contratos.

## Padroes Modux

### Service

```luau
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local ExampleService = Modux.Service("ExampleService"):Import("PlayerService")

function ExampleService:DoSomething(player: Player)
	-- regra autoritativa
end

ExampleService:OnStart(function(self)
	self.PlayerService:OnPlayerAdded(function(player)
		self:DoSomething(player)
	end)
end)

return ExampleService
```

### Controller

```luau
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local ExampleController = Modux.Controller("ExampleController"):Import("InputController")

ExampleController:OnStart(function(self)
	local handler = self.InputController:BindAction("Action", Enum.KeyCode.E, true, 10)
	handler.OnPress(function()
		self.Network.Packages.SomeIntent:send({ Action = "Use" })
	end)
end)

return ExampleController
```

### Component

```luau
local Modux = require(game.ReplicatedStorage.Shared.Modux)

local ExampleComponent = Modux.Component("ExampleComponent")
	:Tag("Example")
	:ClassName("BasePart")
	:Children({
		"Prompt",
	})

ExampleComponent:OnInit(function(self)
	self.Enabled = true
end)

function ExampleComponent:Use()
	if not self.Enabled then
		return false
	end

	return true
end

return ExampleComponent
```

## Convencoes

- Nome do arquivo e ID Modux devem bater: `VitalService.luau` usa
  `Modux.Service("VitalService")`.
- Services ficam em `server/Services`.
- Controllers ficam em `client/Controllers`.
- Components autoritativos ficam em `server/Components`.
- Components visuais/client-only ficam em `client/Components`.
- Mixins reutilizaveis sem dependencia de contexto podem ficar em
  `shared/Components`.
- Components devem declarar `:ClassName()` com a classe real observada no
  Studio; use `:Children()` para todo filho direto que o codigo acessa.
- Nao use `ClassName("Instance")` quando o componente depende de um tipo mais
  especifico.
- Tags devem ser constantes do dominio e documentadas perto do Component ou
  Service que as cria.
- Toda connection criada em lifecycle deve passar por `self:Cleanup`.
- Use `OnInit` para preparar estado e handlers essenciais.
- Use `OnStart` para conectar comportamento depois que dependencias ja
  existem.
- Use `OnTick` apenas para comportamento periodico que realmente precisa rodar
  em intervalo.

## Git

Antes de mexer:

```powershell
git pull
```

Depois:

```powershell
git status
git add README.md src wally.toml wally.lock default.project.json
git commit -m "descreva sua alteracao"
git push
```

Evite editar o mesmo script ao mesmo tempo que outra pessoa para reduzir
conflitos.
