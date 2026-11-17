-- Suit les joueurs : dès que l'un d'eux atteint un checkpoint plus haut, toute l'équipe le gagne.
-- Le serveur décide : un client ne peut pas se déclarer arrivé quelque part.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Checkpoints = require(Shared:WaitForChild("logic"):WaitForChild("Checkpoints"))
local Parcours = require(script.Parent:WaitForChild("Parcours"))

local INTERVALLE = 0.25
local HAUTEUR_PIEDS = 3 -- distance entre le centre du personnage et ses pieds
local COULEUR_ACTIF = Color3.fromRGB(80, 230, 120)

local annonce = Instance.new("RemoteEvent")
annonce.Name = "Annonce"
annonce.Parent = ReplicatedStorage

local dossier = Workspace:WaitForChild("Montagne")

local function allumer(rang)
	local toile = dossier:FindFirstChild("DrapeauToile" .. rang)
	if toile then
		toile.Color = COULEUR_ACTIF
	end
end

local total = #Parcours.checkpoints

while true do
	task.wait(INTERVALLE)

	for _, joueur in Players:GetPlayers() do
		local personnage = joueur.Character
		local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
		local humanoide = personnage and personnage:FindFirstChildOfClass("Humanoid")

		if racine and humanoide and humanoide.Health > 0 then
			local position = racine.Position
			local rang = Checkpoints.sous(
				Parcours.checkpoints,
				position.X,
				position.Y - HAUTEUR_PIEDS,
				position.Z,
				Config.CheckpointTolerance
			)

			if rang then
				local ancien = Parcours.enregistrer(rang)
				if ancien then
					for r = ancien + 1, rang do
						allumer(r)
					end

					local message = if rang == total
						then "Sommet atteint !"
						else "Checkpoint atteint !"
					annonce:FireAllClients(message)
					print(`Roped Up : checkpoint {rang}/{total} atteint par {joueur.Name}`)
				end
			end
		end
	end
end
