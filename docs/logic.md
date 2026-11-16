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
## Aleatoire (src/shared/logic/Aleatoire.luau)

`Aleatoire.nouveau(graine)` renvoie un générateur de nombres dans [0, 1). Une même graine donne la même suite
sur tous les serveurs : tous les joueurs voient le même décor.

## Montagne (src/shared/logic/Montagne.luau)

- `Montagne.plateformes(description)` : transforme les sections en liste de plateformes
- `Montagne.valider(plateformes, regles)` : liste les écarts trop grands, marches trop hautes et chevauchements
- `Montagne.statistiques(plateformes, vitesse)` : nombre, longueur du chemin, hauteur, durée estimée

Voir docs/montagne.md.

## Decor (src/shared/logic/Decor.luau)

- `Decor.massifs(hasard, centre, options)` : montagnes lointaines faites de blocs empilés
- `Decor.champignons(hasard, plateformes, probabilite)` : champignons lumineux sur l'herbe

## Respawn (src/shared/logic/Respawn.luau)

`Respawn.choisirCible(joueurs, idExclu)` : le coéquipier vivant le plus haut, ou nil.
