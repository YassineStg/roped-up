-- Ambiance : coucher de soleil, brume, nuages et lueur, comme dans l'esprit "aventure".
-- Ne contient aucune règle de jeu : on peut régler les couleurs sans rien casser.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local function remplacer(parent, classe, nom, proprietes)
	local ancien = parent:FindFirstChild(nom)
	if ancien then
		ancien:Destroy()
	end

	local instance = Instance.new(classe)
	instance.Name = nom
	for cle, valeur in proprietes do
		(instance :: any)[cle] = valeur
	end
	instance.Parent = parent
	return instance
end

-- Lumière : plus c'est haut, plus c'est clair. À régler ici si le rendu ne te plaît pas.
Lighting.ClockTime = 17.2
Lighting.Brightness = 3.2
Lighting.GlobalShadows = true
Lighting.ExposureCompensation = 0.3
Lighting.Ambient = Color3.fromRGB(120, 110, 140)
Lighting.OutdoorAmbient = Color3.fromRGB(150, 140, 170)

remplacer(Lighting, "Atmosphere", "AtmosphereMontagne", {
	Density = 0.34,
	Offset = 0.25,
	Color = Color3.fromRGB(255, 200, 170),
	Decay = Color3.fromRGB(106, 112, 125),
	Glare = 0.2,
	Haze = 2.0,
})

remplacer(Lighting, "BloomEffect", "LueurMontagne", {
	Intensity = 0.4,
	Size = 24,
	Threshold = 1.1,
})

remplacer(Lighting, "ColorCorrectionEffect", "CouleursMontagne", {
	Saturation = 0.18,
	Contrast = 0.08,
	TintColor = Color3.fromRGB(255, 236, 220),
})

remplacer(Lighting, "SunRaysEffect", "RayonsMontagne", {
	Intensity = 0.15,
	Spread = 0.8,
})

remplacer(Workspace.Terrain, "Clouds", "NuagesMontagne", {
	Cover = 0.55,
	Density = 0.6,
	Color = Color3.fromRGB(255, 232, 232),
})
