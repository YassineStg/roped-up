-- Toutes les valeurs de réglage du jeu sont ici.
return {
	-- Corde et équipe
	RopeLength = 12,
	RopeThickness = 0.3,
	MaxTeamSize = 4,
	RespawnTime = 3,

	-- Montagne
	MontagneActive = "Montagne1", -- nom du fichier dans src/shared/data (ou "MontagneCourte" pour tester vite)
	PlatformThickness = 4, -- épaisseur d'une plateforme
	PillarDepth = 40, -- profondeur maximale du pilier sous une plateforme
	LavaDepth = 120, -- la lave est sous le point de départ de cette hauteur

	-- Ce qu'un joueur peut franchir en sautant (avec une marge de sécurité)
	JumpMaxRise = 4,
	JumpMaxGap = 6,

	-- Estimation de la durée de montée
	WalkSpeed = 16,
	ClimbEfficiency = 0.4,
}
