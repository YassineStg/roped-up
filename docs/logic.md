# Modules de logique pure

Ces modules n'utilisent aucune API Roblox. Ils sont testés avec Lune (`lune run tests/run`).

## Time (src/shared/logic/Time.luau)

`Time.format(secondes)` renvoie le temps au format `mm:ss.cc`.

- arrondi au centième le plus proche
- les minutes ne sont pas plafonnées : 3725.5 donne `62:05.50`
- une erreur claire est levée pour un temps négatif, non numérique, NaN ou infini
