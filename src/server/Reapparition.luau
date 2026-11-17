-- Réapparition provisoire (en attendant les checkpoints d'équipe, story 2.2) :
-- un joueur qui réapparaît est ramené au-dessus du coéquipier vivant le plus haut.
-- Sans cela, la corde le tirerait violemment depuis le point de départ.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Respawn = require(Shared:WaitForChild("logic"):WaitForChild("Respawn"))

local HAUTEUR_AU_DESSUS = 6

local Reapparition = {}

function Reapparition.ramener(joueur)
	local personnage = joueur.Character
	if not personnage then
		return
	end

	local candidats = {}
	for _, autre in Players:GetPlayers() do
		local persoAutre = autre.Character
		local racine = persoAutre and persoAutre:FindFirstChild("HumanoidRootPart")
		local humanoide = persoAutre and persoAutre:FindFirstChildOfClass("Humanoid")

		if racine and humanoide then
			table.insert(candidats, {
				id = autre.UserId,
				y = racine.Position.Y,
				vivant = humanoide.Health > 0,
			})
		end
	end

	local cible = Respawn.choisirCible(candidats, joueur.UserId)
	if not cible then
		return -- personne d'autre : on reste au point de départ
	end

	local joueurCible = Players:GetPlayerByUserId(cible)
	local racineCible = joueurCible
		and joueurCible.Character
		and joueurCible.Character:FindFirstChild("HumanoidRootPart")
	if racineCible then
		personnage:PivotTo(racineCible.CFrame + Vector3.new(0, HAUTEUR_AU_DESSUS, 0))
	end
end

return Reapparition
