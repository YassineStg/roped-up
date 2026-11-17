-- Le parcours de la montagne et l'état de l'équipe : calculés une seule fois,
-- puis partagés entre le constructeur, le suivi des checkpoints et la réapparition.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Logique = Shared:WaitForChild("logic")
local Montagne = require(Logique:WaitForChild("Montagne"))
local Checkpoints = require(Logique:WaitForChild("Checkpoints"))
local description = require(Shared:WaitForChild("data"):WaitForChild(Config.MontagneActive))

local plateformes = Montagne.plateformes(description)

local Parcours = {
	description = description,
	plateformes = plateformes,
	checkpoints = Checkpoints.extraire(plateformes),
	etat = Checkpoints.etatInitial(),
}

-- Enregistre qu'un joueur a atteint le checkpoint de ce rang.
-- Renvoie le rang précédent si l'équipe a progressé, sinon nil.
function Parcours.enregistrer(rang)
	local ancien = Parcours.etat.actif
	Parcours.etat = Checkpoints.atteindre(Parcours.etat, rang)

	if Parcours.etat.actif > ancien then
		return ancien
	end

	return nil
end

-- Le checkpoint où l'équipe reprend.
function Parcours.checkpointActif()
	return Parcours.checkpoints[Parcours.etat.actif]
end

return Parcours
