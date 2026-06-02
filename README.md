# The Game

Este projeto usa [Azul](https://azul-docs.vercel.app/) para sincronizar scripts
entre Roblox Studio e VS Code. O Studio e a fonte de verdade; a pasta `sync/`
e o espelho local versionado no Git.

Cada desenvolvedor roda seu proprio daemon Azul e abre sua propria copia do
place no Studio. O compartilhamento entre computadores acontece pelo GitHub.

## Primeira instalacao

Instale no seu computador:

1. [Node.js](https://nodejs.org/)
2. [VS Code](https://code.visualstudio.com/)
3. [Azul Companion Plugin](https://create.roblox.com/store/asset/79510309341601/Azul-Companion-Plugin)
4. As extensoes recomendadas pelo VS Code ao abrir este projeto

Depois rode:

```powershell
npm install -g azul-sync
azul --version
```

No Roblox Studio, habilite `Home > Game Settings > Security > Allow HTTP
Requests`. Se o plugin nao aparecer depois da instalacao, reinicie o Studio.

Para editar o mesmo experience em tempo real, abra o place no Studio, clique
em `Collaborate`, adicione o outro desenvolvedor e conceda permissao `Edit`.

## Publicando no GitHub

Quem criar o repositorio no GitHub roda uma vez:

```powershell
git add .
git commit -m "Setup Azul collaboration"
git remote add origin https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
git push -u origin main
```

O outro desenvolvedor clona o repositorio:

```powershell
git clone https://github.com/SEU-USUARIO/SEU-REPOSITORIO.git
cd SEU-REPOSITORIO
npm install -g azul-sync
wally install
```

Se os dois usam o mesmo place compartilhado no Roblox, o segundo desenvolvedor
abre esse place, roda `azul` e conecta o plugin normalmente. Se ele precisar
criar uma copia nova do place a partir dos arquivos locais, deve usar
`azul build` em um place vazio antes de iniciar o sync ao vivo.

## Trabalhando no dia a dia

Antes de editar:

```powershell
git pull
azul
```

Abra o place no Roblox Studio e clique em `Connect` no plugin Azul. O daemon
usa `./sync` e gera `./sourcemap.json`, que habilita autocomplete no Luau LSP.

Edite os arquivos dentro de `sync/`. Ao terminar:

```powershell
git status
git add sync .vscode README.md wally.toml wally.lock
git commit -m "descreva sua alteracao"
git push
```

Para evitar conflitos, nao editem o mesmo script ao mesmo tempo. Antes de
comecar uma tarefa, combinem quem vai mexer em cada arquivo.

## Dependencias Wally

As pastas `Packages/` e `ServerPackages/` sao geradas e nao entram no Git.
Quando `wally.toml` mudar, rode:

```powershell
wally install
azul push -s Packages -d ReplicatedStorage.Packages --destructive --rojo
```

## Arquivos legados

O checkout local ainda pode conter `src/` e `default.project.json` do fluxo
anterior com Rojo. Eles sao ignorados pelo Git. Para o fluxo Azul, trabalhe em
`sync/`.
