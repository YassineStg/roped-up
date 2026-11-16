# Architecture

- `src/server/` : scripts serveur (autorité : scores, récompenses, sauvegardes)
- `src/client/` : scripts client (entrées, interface, effets)
- `src/shared/` : code partagé, dont `Config.luau` (valeurs de réglage)
- `src/shared/logic/` : logique pure, sans API Roblox, testée avec Lune
- `tests/` : tests de la logique pure (`lune run tests/run`)
- `default.project.json` : correspondance entre ces dossiers et le jeu (Rojo)
