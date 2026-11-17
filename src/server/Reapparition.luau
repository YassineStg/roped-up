-- Réapparition d'un joueur.
-- 1. S'il reste un coéquipier vivant : au-dessus du plus haut. La corde l'exige : sinon elle
--    le tirerait violemment depuis un point lointain. (Config.RespawnNearTeammates)
-- 2. Sinon : au checkpoint de l'équipe, les joueurs étalés sur la plateforme.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Logique = Shared:WaitForChild("logic")
local Respawn = require(Logique:WaitForChild("Respawn"))
local Checkpoints = require(Logique:WaitForChild("Checkpoints"))
local Parcours = require(script.Parent:WaitForChild("Parcours"))

local HAUTEUR_AU_DESSUS = 6
local HAUTEUR_RACINE = 4 -- le centre du personnage est à peu près à cette hauteur au-dessus du sol

local Reapparition = {}

local function versUnCoequipier(joueur, personnage)
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
		return false
	end

	local joueurCible = Players:GetPlayerByUserId(cible)
	local racineCible = joueurCible
		and joueurCible.Character
		and joueurCible.Character:FindFirstChild("HumanoidRootPart")
	if not racineCible then
		return false
	end

	personnage:PivotTo(racineCible.CFrame + Vector3.new(0, HAUTEUR_AU_DESSUS, 0))
	return true
end

local function versLeCheckpoint(joueur, personnage)
	local checkpoint = Parcours.checkpointActif()
	local joueurs = Players:GetPlayers()
	local total = math.clamp(#joueurs, 1, Config.MaxTeamSize)
	local rang = math.clamp(table.find(joueurs, joueur) or 1, 1, total)
	local position = Checkpoints.position(checkpoint, rang, total, Config.CheckpointSpacing)

	-- le personnage regarde dans le sens du parcours (le "devant" d'un personnage est -Z)
	personnage:PivotTo(
		CFrame.new(position.x, position.y + HAUTEUR_RACINE, position.z)
			* CFrame.Angles(0, checkpoint.cap + math.pi, 0)
	)
end

function Reapparition.ramener(joueur)
	local personnage = joueur.Character
	if not personnage then
		return
	end

	if Config.RespawnNearTeammates and versUnCoequipier(joueur, personnage) then
		return
	end

	versLeCheckpoint(joueur, personnage)
end

return Reapparition
