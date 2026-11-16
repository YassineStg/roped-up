# Cordes entre les joueurs

Prototype de la story 1.1 : src/server/RopeService.server.luau.

- tous les joueurs du serveur forment une seule équipe, reliés en chaîne dans l'ordre d'arrivée
- au plus Config.MaxTeamSize joueurs sont reliés
- chaque personnage reçoit une attache (AttacheCorde) sur son HumanoidRootPart
- une RopeConstraint relie deux joueurs voisins, rangée dans le dossier Workspace/Cordes
- les cordes sont reconstruites quand un joueur arrive, réapparaît ou part

## Limites connues
- les vraies équipes arrivent avec la story 1.2
- chaque événement reconstruit toutes les cordes
- la physique n'est pas testée automatiquement : test manuel dans Studio obligatoire
- le réseau peut provoquer des saccades, car chaque joueur simule son propre personnage
