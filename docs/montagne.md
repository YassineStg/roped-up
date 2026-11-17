# La montagne

La montagne est décrite par des données (src/shared/data) et construite par le serveur
(src/server/MontagneService.server.luau). Toute la logique vit dans src/shared/logic/Montagne.luau.

## Choisir la montagne
Dans src/shared/Config.luau : `MontagneActive = "Montagne1"` (grande, environ 7 minutes estimées)
ou `"MontagneCourte"` (environ 1,5 minute, pour tester vite).

## Écrire une montagne
Une montagne est une liste de sections, enchaînées à partir de la précédente :

- `plateau` : une grande plateforme (largeur, profondeur, ecart facultatif)
- `marches` : n plateformes en ligne (largeur, profondeur, ecart, hauteur par marche)
- `spirale` : n plateformes autour d'un centre (rayon, pas en degrés, hauteur, largeur, profondeur, sens 1 ou -1)

Champs communs : `matiere` ("herbe" ou "pierre"), `virage` (degrés, change la direction avant la section),
`sommet = true` (la plateforme du trophée). La description a aussi un `nom`, une `graine` (décor) et un `cap`.

## Règles vérifiées automatiquement
- l'écart entre deux plateformes qui se suivent ne dépasse pas Config.JumpMaxGap
- une marche ne dépasse pas Config.JumpMaxRise
- deux plateformes qui ne se suivent pas ne se chevauchent pas, sauf si elles sont séparées d'assez de hauteur
  (profondeur d'un pilier + épaisseur + 4)

Le jeu affiche un avertissement dans la sortie du serveur pour chaque règle violée.

## Décor
- herbe, terre, pierre et piliers sous chaque plateforme
- lave sous la montagne : toucher la lave fait mourir
- champignons lumineux sur l'herbe, montagnes lointaines enneigées, trophée doré au sommet
- coucher de soleil, brume, nuages (src/server/Ambiance.server.luau)

## Réapparition provisoire
Un joueur qui réapparaît est ramené au-dessus du coéquipier vivant le plus haut
(src/server/Reapparition.luau). Si personne d'autre n'est vivant, il repart du point de départ.
Cette règle sera remplacée par les checkpoints d'équipe (story 2.2).

## Pas encore fait
Poule géante et obstacles (story 2.3), arrivée et chrono (story 2.4), feux d'artifice.
## Régler le rendu
Les couleurs et matières sont des constantes en tête de src/server/MontagneService.server.luau
(herbe, pierre, piliers, lave, montagnes lointaines). La lumière, la brume et la lueur sont réglées
en tête de src/server/Ambiance.server.luau. Pour une lave unie et lumineuse, remplace
MATIERE_LAVE par Enum.Material.Neon.
## Lave
La lave est faite de deux couches : une roche fissurée (relief visible de près) et, juste au-dessus,
un voile orange translucide qui la fait paraître incandescente de loin. Les deux sont réglées en tête de
src/server/MontagneService.server.luau (COULEUR_LUEUR_LAVE, TRANSPARENCE_LUEUR). Le voile ne gêne pas les joueurs.
