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

Lighting.ClockTime = 17.4
Lighting.Brightness = 2.6
Lighting.GlobalShadows = true
Lighting.Ambient = Color3.fromRGB(70, 60, 90)
Lighting.OutdoorAmbient = Color3.fromRGB(110, 95, 130)

remplacer(Lighting, "Atmosphere", "AtmosphereMontagne", {
	Density = 0.32,
	Offset = 0.25,
	Color = Color3.fromRGB(199, 170, 190),
	Decay = Color3.fromRGB(106, 112, 125),
	Glare = 0.2,
	Haze = 1.6,
})

remplacer(Lighting, "BloomEffect", "LueurMontagne", {
	Intensity = 0.7,
	Size = 28,
	Threshold = 0.9,
})

remplacer(Lighting, "ColorCorrectionEffect", "CouleursMontagne", {
	Saturation = 0.18,
	Contrast = 0.08,
	TintColor = Color3.fromRGB(255, 244, 235),
})

remplacer(Lighting, "SunRaysEffect", "RayonsMontagne", {
	Intensity = 0.12,
	Spread = 0.8,
})

remplacer(Workspace.Terrain, "Clouds", "NuagesMontagne", {
	Cover = 0.55,
	Density = 0.6,
	Color = Color3.fromRGB(255, 232, 232),
})
