# Modules de logique pure

Ces modules n'utilisent aucune API Roblox. Ils sont testés avec Lune (`lune run tests/run`).

## Time (src/shared/logic/Time.luau)

`Time.format(secondes)` renvoie le temps au format `mm:ss.cc`.

- arrondi au centième le plus proche
- les minutes ne sont pas plafonnées : 3725.5 donne `62:05.50`
- une erreur claire est levée pour un temps négatif, non numérique, NaN ou infini

## RopeChain (src/shared/logic/RopeChain.luau)

`RopeChain.links(ids, maxJoueurs)` renvoie les paires de joueurs reliées par une corde.

- les joueurs forment une chaîne dans l'ordre de la liste : 1-2, 2-3, 3-4
- `maxJoueurs` (facultatif) limite aux premiers joueurs de la liste
- une erreur claire est levée pour une entrée qui n'est pas une liste, un identifiant en double ou une limite invalide
