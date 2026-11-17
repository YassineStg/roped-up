# Checkpoints d'équipe

Les checkpoints sont des plateformes de la montagne marquées dans sa description (src/shared/data).

## Où sont-ils ?
- chaque `plateau` est un checkpoint, sauf si `checkpoint = false`
- pour des `marches` ou une `spirale`, `checkpoint = true` fait de leur dernière plateforme un checkpoint
- un drapeau gris les marque sur la montagne ; il devient vert quand l'équipe l'a atteint

## Comment ça marche
- le serveur regarde où sont les joueurs (src/server/CheckpointService.server.luau)
- dès que l'un d'eux se tient sur un checkpoint plus haut, toute l'équipe le gagne, et un message s'affiche
- l'équipe ne recule jamais
- la logique est dans src/shared/logic/Checkpoints.luau (testée) ; l'état de l'équipe est dans src/server/Parcours.luau

## Réapparition (src/server/Reapparition.luau)
1. S'il reste un coéquipier vivant : le joueur réapparaît au-dessus du plus haut. La corde l'exige : un joueur
   replacé loin de ses coéquipiers serait tiré violemment par la corde.
2. Sinon (tout le monde est tombé, ou joueur seul) : au checkpoint de l'équipe, les joueurs étalés sur la plateforme.

`Config.RespawnNearTeammates = false` force le retour au checkpoint dans tous les cas, au risque d'une corde tendue.

## Réglages (src/shared/Config.luau)
- `CheckpointTolerance` : hauteur maximale au-dessus de la plateforme qui compte comme "dessus"
- `CheckpointSpacing` : écart entre deux joueurs replacés au même checkpoint
- `RespawnNearTeammates` : voir ci-dessus
