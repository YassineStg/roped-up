-- Construit la montagne dans le jeu à partir de sa description (src/shared/data).
-- Toute la logique (positions, validation) est dans src/shared/logic : ici, on ne fait
-- que transformer ces nombres en blocs Roblox.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Logique = Shared:WaitForChild("logic")
local Aleatoire = require(Logique:WaitForChild("Aleatoire"))
local Montagne = require(Logique:WaitForChild("Montagne"))
local Parcours = require(script.Parent:WaitForChild("Parcours"))
local Decor = require(Logique:WaitForChild("Decor"))
local Description = Parcours.description

-- Couleurs et matières : à régler ici si le rendu ne te plaît pas.
local COULEUR_HERBE = Color3.fromRGB(118, 186, 78)
local COULEUR_PIERRE = Color3.fromRGB(146, 138, 130)
local COULEUR_PILIER = Color3.fromRGB(170, 140, 118)
local MATIERE_PILIER = Enum.Material.Slate -- Rock est très sombre vu de dessous
local COULEUR_LAVE = Color3.fromRGB(255, 110, 30)
local MATIERE_LAVE = Enum.Material.CrackedLava -- essaie Enum.Material.Neon pour une lave unie et lumineuse
local COULEUR_MASSIF = Color3.fromRGB(150, 150, 182)
-- Voile orange translucide au-dessus de la lave : de loin, elle paraît incandescente.
-- Mets TRANSPARENCE_LUEUR à 1 pour le retirer, ou rapproche-la de 0 pour l'intensifier.
local COULEUR_LUEUR_LAVE = Color3.fromRGB(255, 80, 10)
local TRANSPARENCE_LUEUR = 0.75
local COULEUR_OR = Color3.fromRGB(255, 196, 40)
local COULEUR_DRAPEAU = Color3.fromRGB(150, 150, 160) -- un checkpoint pas encore atteint
local COULEUR_DRAPEAU_ATTEINT = Color3.fromRGB(80, 230, 120)
local COULEURS_CHAMPIGNONS = {
	Color3.fromRGB(80, 200, 255),
	Color3.fromRGB(230, 90, 255),
	Color3.fromRGB(90, 130, 255),
}

local dossier = Instance.new("Folder")
dossier.Name = "Montagne"
dossier.Parent = Workspace

local hasard = Aleatoire.nouveau(Description.graine or 1)

-- Éclaircit ou assombrit une couleur selon un nombre dans [0, 1).
local function varier(couleur, ton, amplitude)
	local decalage = (ton - 0.5) * amplitude
	return Color3.new(
		math.clamp(couleur.R + decalage, 0, 1),
		math.clamp(couleur.G + decalage, 0, 1),
		math.clamp(couleur.B + decalage, 0, 1)
	)
end

local function bloc(nom, taille, cframe, couleur, matiere, decor)
	local partie = Instance.new("Part")
	partie.Name = nom
	partie.Anchored = true
	partie.Size = taille
	partie.CFrame = cframe
	partie.Color = couleur
	partie.Material = matiere
	partie.TopSurface = Enum.SurfaceType.Smooth
	partie.BottomSurface = Enum.SurfaceType.Smooth

	if decor then
		-- un décor ne gêne pas les joueurs et ne coûte presque rien au jeu
		partie.CanCollide = false
		partie.CanTouch = false
		partie.CanQuery = false
		partie.CastShadow = false
	end

	partie.Parent = dossier
	return partie
end

-- Un cylindre debout : en Roblox, l'axe d'un cylindre est X, on le redresse.
local function cylindre(nom, hauteur, diametre, cframe, couleur, matiere, decor)
	local partie = bloc(
		nom,
		Vector3.new(hauteur, diametre, diametre),
		cframe * CFrame.Angles(0, 0, math.rad(90)),
		couleur,
		matiere,
		decor
	)
	partie.Shape = Enum.PartType.Cylinder
	return partie
end

local function boule(nom, diametre, cframe, couleur, matiere, decor)
	local partie =
		bloc(nom, Vector3.new(diametre, diametre, diametre), cframe, couleur, matiere, decor)
	partie.Shape = Enum.PartType.Ball
	return partie
end

-- ---------- Plateformes ----------

local plateformes = Parcours.plateformes

local problemes = Montagne.valider(plateformes, {
	ecartMax = Config.JumpMaxGap,
	hauteurMax = Config.JumpMaxRise,
	separationVerticale = Config.PillarDepth + Config.PlatformThickness + 4,
})
for _, probleme in problemes do
	warn("Roped Up : montagne : " .. probleme)
end

local epaisseur = Config.PlatformThickness
local minX, maxX, minZ, maxZ = math.huge, -math.huge, math.huge, -math.huge

for indice, p in plateformes do
	local base = CFrame.new(p.x, p.y, p.z) * CFrame.Angles(0, p.cap, 0)
	local ton = hasard()
	local profondeurPilier = Config.PillarDepth * (0.55 + 0.45 * hasard())

	if p.matiere == "herbe" then
		bloc(
			"Herbe" .. indice,
			Vector3.new(p.largeur, 1, p.profondeur),
			base * CFrame.new(0, -0.5, 0),
			varier(COULEUR_HERBE, ton, 0.12),
			Enum.Material.Grass,
			false
		)
		bloc(
			"Terre" .. indice,
			Vector3.new(p.largeur, epaisseur - 1, p.profondeur),
			base * CFrame.new(0, -1 - (epaisseur - 1) / 2, 0),
			varier(COULEUR_PIERRE, ton, 0.1),
			Enum.Material.Slate,
			false
		)
	else
		bloc(
			"Pierre" .. indice,
			Vector3.new(p.largeur, epaisseur, p.profondeur),
			base * CFrame.new(0, -epaisseur / 2, 0),
			varier(COULEUR_PIERRE, ton, 0.16),
			Enum.Material.Slate,
			false
		)
	end

	bloc(
		"Pilier" .. indice,
		Vector3.new(p.largeur * 0.8, profondeurPilier, p.profondeur * 0.8),
		base * CFrame.new(0, -epaisseur - profondeurPilier / 2, 0),
		varier(COULEUR_PILIER, ton, 0.14),
		MATIERE_PILIER,
		false
	)

	minX = math.min(minX, p.x)
	maxX = math.max(maxX, p.x)
	minZ = math.min(minZ, p.z)
	maxZ = math.max(maxZ, p.z)
end

local centre = { x = (minX + maxX) / 2, z = (minZ + maxZ) / 2 }
local niveauLave = -Config.LavaDepth

-- ---------- Point de départ ----------

local premiere = plateformes[1]
local depart = Instance.new("SpawnLocation")
depart.Name = "Depart"
depart.Anchored = true
depart.Size = Vector3.new(10, 1, 10)
depart.Position = Vector3.new(premiere.x, premiere.y + 0.5, premiere.z)
depart.Transparency = 1
depart.CanCollide = false
depart.Neutral = true
depart.Duration = 0
depart.Parent = dossier

-- ---------- Lave ----------

local TAILLE_MAX = 2000
local marge = 900
local largeurLave = maxX - minX + 2 * marge
local profondeurLave = maxZ - minZ + 2 * marge
local colonnes = math.ceil(largeurLave / TAILLE_MAX)
local lignes = math.ceil(profondeurLave / TAILLE_MAX)
local tuileX = largeurLave / colonnes
local tuileZ = profondeurLave / lignes

for colonne = 1, colonnes do
	for ligne = 1, lignes do
		local lave = bloc(
			"Lave",
			Vector3.new(tuileX, 4, tuileZ),
			CFrame.new(
				minX - marge + tuileX * (colonne - 0.5),
				niveauLave - 2,
				minZ - marge + tuileZ * (ligne - 0.5)
			),
			COULEUR_LAVE,
			MATIERE_LAVE,
			false
		)

		local lueur = bloc(
			"LueurLave",
			Vector3.new(tuileX, 0.2, tuileZ),
			CFrame.new(
				minX - marge + tuileX * (colonne - 0.5),
				niveauLave + 0.3,
				minZ - marge + tuileZ * (ligne - 0.5)
			),
			COULEUR_LUEUR_LAVE,
			Enum.Material.Neon,
			true
		)
		lueur.Transparency = TRANSPARENCE_LUEUR

		lave.Touched:Connect(function(autre)
			local humanoide = autre.Parent and autre.Parent:FindFirstChildOfClass("Humanoid")
			if humanoide and humanoide.Health > 0 then
				humanoide.Health = 0
			end
		end)
	end
end

-- ---------- Trophée au sommet ----------

local sommet = plateformes[#plateformes]
for _, p in plateformes do
	if p.sommet then
		sommet = p
	end
end

do
	local base = CFrame.new(sommet.x, sommet.y, sommet.z) * CFrame.Angles(0, sommet.cap, 0)

	bloc(
		"TropheeSocle",
		Vector3.new(10, 3, 10),
		base * CFrame.new(0, 1.5, 0),
		Color3.fromRGB(60, 58, 56),
		Enum.Material.Slate,
		false
	)
	cylindre("TropheePied", 4, 2, base * CFrame.new(0, 5, 0), COULEUR_OR, Enum.Material.Metal, true)
	local coupe = cylindre(
		"TropheeCoupe",
		6,
		7,
		base * CFrame.new(0, 10, 0),
		COULEUR_OR,
		Enum.Material.Metal,
		true
	)
	boule(
		"TropheeAnseGauche",
		3,
		base * CFrame.new(-4, 10, 0),
		COULEUR_OR,
		Enum.Material.Metal,
		true
	)
	boule(
		"TropheeAnseDroite",
		3,
		base * CFrame.new(4, 10, 0),
		COULEUR_OR,
		Enum.Material.Metal,
		true
	)

	for i, decalage in { -2.5, 0, 2.5 } do
		local hauteur = if i == 2 then 17.5 else 16
		boule(
			"TropheeEtoile" .. i,
			1.8,
			base * CFrame.new(decalage, hauteur, 0),
			Color3.fromRGB(255, 240, 120),
			Enum.Material.Neon,
			true
		)
	end

	local lumiere = Instance.new("PointLight")
	lumiere.Color = COULEUR_OR
	lumiere.Brightness = 3
	lumiere.Range = 45
	lumiere.Parent = coupe

	local etincelles = Instance.new("Sparkles")
	etincelles.SparkleColor = COULEUR_OR
	etincelles.Parent = coupe
end

-- ---------- Drapeaux de checkpoint ----------

for rang, checkpoint in Parcours.checkpoints do
	local base = CFrame.new(checkpoint.x, checkpoint.y, checkpoint.z)
		* CFrame.Angles(0, checkpoint.cap, 0)
	local pied = base * CFrame.new(math.min(checkpoint.largeur / 2 - 2, 6), 0, 0)
	local atteint = rang <= Parcours.etat.actif

	cylindre(
		"DrapeauMat" .. rang,
		10,
		0.5,
		pied * CFrame.new(0, 5, 0),
		Color3.fromRGB(210, 210, 215),
		Enum.Material.Metal,
		true
	)
	bloc(
		"DrapeauToile" .. rang,
		Vector3.new(0.3, 3, 5),
		pied * CFrame.new(0, 8.5, 2.7),
		if atteint then COULEUR_DRAPEAU_ATTEINT else COULEUR_DRAPEAU,
		Enum.Material.Neon,
		true
	)
end

-- ---------- Champignons lumineux ----------

local champignons = Decor.champignons(hasard, plateformes, 0.35)
for indice, c in champignons do
	local couleur = COULEURS_CHAMPIGNONS[c.couleur]
	cylindre(
		"ChampignonTige" .. indice,
		c.hauteur,
		0.6,
		CFrame.new(c.x, c.y + c.hauteur / 2, c.z),
		Color3.fromRGB(235, 225, 200),
		Enum.Material.SmoothPlastic,
		true
	)
	boule(
		"ChampignonChapeau" .. indice,
		2.4,
		CFrame.new(c.x, c.y + c.hauteur, c.z),
		couleur,
		Enum.Material.Neon,
		true
	)
end

-- ---------- Montagnes lointaines ----------

local massifs = Decor.massifs(hasard, centre, {
	nombre = 14,
	distanceMin = 520,
	distanceMax = 1300,
	hauteurMax = 560,
	niveauBas = niveauLave - 30,
})

for indice, m in massifs do
	local couleur
	local matiere
	if m.neige then
		couleur = Color3.fromRGB(240, 244, 250)
		matiere = Enum.Material.Snow
	else
		couleur = varier(COULEUR_MASSIF, m.ton, 0.2)
		matiere = Enum.Material.Slate
	end

	bloc(
		"Massif" .. indice,
		Vector3.new(m.largeur, m.hauteur, m.profondeur),
		CFrame.new(m.x, m.y, m.z),
		couleur,
		matiere,
		true
	)
end

-- ---------- Résumé ----------

local stats = Montagne.statistiques(plateformes, Config.WalkSpeed * Config.ClimbEfficiency)
print(
	string.format(
		"Roped Up : %s : %d plateformes, chemin de %d studs, %d de haut, durée estimée %.1f min",
		Description.nom,
		stats.nombre,
		math.floor(stats.longueur),
		math.floor(stats.hauteur),
		stats.duree / 60
	)
)
