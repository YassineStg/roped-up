# Roped Up : contexte du projet

Jeu Roblox coopératif. 2 à 4 amis, reliés par une corde, escaladent une montagne
absurde. Quand l'un tombe, il entraîne les autres. On peut le rattraper en
coordonnant ses mouvements. Une nouvelle montagne chaque semaine.

Public : tout public. Jeu gratuit, zéro euro de coût pour les joueurs et le créateur.

## Stack
- Roblox Studio (jeu), langage Luau
- Rojo : synchronise ce dépôt avec Studio
- StyLua (format), Selene (lint)
- Lune (exécuteur Luau hors Studio) pour tester la logique pure
- GitHub : dépôt, Issues (stories), Projects (tableau), Actions (CI)

## Structure
- default.project.json : mapping Rojo
- src/server/   : scripts serveur (autorité : scores, récompenses, sauvegardes)
- src/client/   : scripts client (entrées, interface, effets)
- src/shared/   : code partagé
- src/shared/logic/ : LOGIQUE PURE (aucune API Roblox) : équipes, scores,
  chrono, rotation hebdomadaire, règles de chute. Testable avec Lune.
- src/shared/Config.luau : toutes les valeurs de réglage (longueur de corde, etc.)
- tests/        : tests de la logique pure
- docs/         : documentation

## Règle d'or
Toute règle de jeu (calcul, décision, état) va dans src/shared/logic/ SANS
appel à l'API Roblox, et est testée dans tests/. Le code qui touche à Roblox
(physique, cordes, interface) reste mince et appelle cette logique.

## Protocole pour chaque issue
1. Lire l'issue et ses critères d'acceptation. Si un critère est ambigu, poser la
   question dans l'issue au lieu de deviner.
2. Créer la branche feature/issue-<numéro>.
3. Écrire les tests de la logique pure d'abord, puis le code, et les lancer
   jusqu'au vert.
4. Formater (StyLua) et linter (Selene) sans erreur.
5. Mettre à jour docs/ si le comportement change.
6. Ouvrir une Pull Request contenant "Closes #<numéro>".
7. Dans la PR, ajouter une CHECKLIST DE TEST MANUEL (voir plus bas).
8. Commenter l'issue : ce qui est fait, résultat des tests, limites connues.

Une seule issue à la fois. Ne jamais fusionner une PR.

## Test manuel obligatoire
L'agent ne peut pas lancer Roblox Studio. Toute issue qui touche au gameplay,
à la physique ou à l'interface doit donc se terminer par une checklist
précise (étapes à faire dans Studio, résultat attendu) que le propriétaire
exécute. Ne jamais déclarer qu'un comportement physique "fonctionne" sans test
manuel : écrire "à vérifier en Studio".

## Règles de sécurité et de contenu
- Le serveur fait autorité : le client ne décide jamais des scores, pièces,
  récompenses ou classements.
- Toute écriture DataStore passe par pcall avec gestion d'erreur et nouvelle tentative.
- Aucun secret ni clé dans le dépôt.
- Contenu tout public. Aucun lien avec l'alcool ou le tabac.
- Pas de coffres payants à contenu aléatoire. Monétisation : cosmétiques
  à contenu connu uniquement. Aucun avantage payant sur la difficulté.
- Pas d'assets externes non maîtrisés : formes de base de Roblox.
  Ne jamais copier les noms, visuels ou personnages d'un autre jeu.

## Zones sensibles (signaler pour relecture humaine attentive)
- Sauvegarde DataStore et classements
- Achats Robux
- Tout ce qui valide un score ou une récompense côté serveur

## Définition de "terminé"
Critères d'acceptation remplis, tests verts, format et lint propres, doc à jour,
checklist de test manuel fournie, PR ouverte.
