# Roped Up

Jeu Roblox coopératif : une équipe attachée par une corde escalade une montagne absurde.

## Prérequis (Windows)
1. Roblox Studio installé.
2. Rokit installé (PowerShell) :
   `Invoke-RestMethod https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.ps1 | Invoke-Expression`
3. Dans le dossier du projet : `rokit install` (installe Rojo, StyLua, Selene, Lune).
4. Une seule fois : `rojo plugin install` (module Rojo pour Studio).

## Ouvrir le jeu dans Studio
1. `rojo build -o RopedUp.rbxl`
2. Ouvre `RopedUp.rbxl` dans Roblox Studio.
3. Lance `rojo serve` dans le terminal.
4. Dans Studio, ouvre le module Rojo et clique sur **Connect**.

Les fichiers de `src/` apparaissent alors dans le jeu et se mettent à jour en direct.

## Tests et qualité
- Tests de la logique pure : `lune run tests/run`
- Format : `stylua src tests`
- Lint : `selene generate-roblox-std` (une fois), puis `selene src`

## Structure
Voir `CLAUDE.md` et `docs/architecture.md`.
