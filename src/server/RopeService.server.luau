-- Cordes entre les joueurs (prototype, story 1.1).
-- Pour l'instant, tous les joueurs du serveur forment une seule équipe,
-- reliés en chaîne dans l'ordre d'arrivée, dans la limite de Config.MaxTeamSize.
-- Les vraies équipes viendront avec la story 1.2.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local RopeChain = require(Shared:WaitForChild("logic"):WaitForChild("RopeChain"))

local dossierCordes = Instance.new("Folder")
dossierCordes.Name = "Cordes"
dossierCordes.Parent = Workspace

local ordre = {} -- identifiants des joueurs, dans l'ordre d'arrivée
local cordes = {} -- liste de { a = id, b = id, corde = RopeConstraint }

local function attacheDe(joueur)
	local personnage = joueur.Character
	local racine = personnage and personnage:FindFirstChild("HumanoidRootPart")
	if not racine then
		return nil
	end

	local attache = racine:FindFirstChild("AttacheCorde")
	if not attache then
		attache = Instance.new("Attachment")
		attache.Name = "AttacheCorde"
		attache.Parent = racine
	end

	return attache
end

local function detruireToutes()
	for _, entree in cordes do
		entree.corde:Destroy()
	end
	table.clear(cordes)
end

local function detruireCordesDe(idJoueur)
	for i = #cordes, 1, -1 do
		local entree = cordes[i]
		if entree.a == idJoueur or entree.b == idJoueur then
			entree.corde:Destroy()
			table.remove(cordes, i)
		end
	end
end

local function reconstruire()
	detruireToutes()

	for _, lien in RopeChain.links(ordre, Config.MaxTeamSize) do
		local joueurA = Players:GetPlayerByUserId(lien[1])
		local joueurB = Players:GetPlayerByUserId(lien[2])
		local attacheA = joueurA and attacheDe(joueurA)
		local attacheB = joueurB and attacheDe(joueurB)

		if attacheA and attacheB then
			local corde = Instance.new("RopeConstraint")
			corde.Attachment0 = attacheA
			corde.Attachment1 = attacheB
			corde.Length = Config.RopeLength
			corde.Thickness = Config.RopeThickness
			corde.Visible = true
			corde.Parent = dossierCordes

			table.insert(cordes, { a = lien[1], b = lien[2], corde = corde })
		end
	end

	print(`Roped Up : {#cordes} corde(s) active(s)`)
end

local function surPersonnage(joueur)
	joueur.CharacterAdded:Connect(function(personnage)
		-- on attend que le personnage soit complet avant de relier
		personnage:WaitForChild("HumanoidRootPart")
		reconstruire()
	end)

	joueur.CharacterRemoving:Connect(function()
		detruireCordesDe(joueur.UserId)
	end)

	if joueur.Character then
		task.spawn(function()
			joueur.Character:WaitForChild("HumanoidRootPart")
			reconstruire()
		end)
	end
end

local function ajouter(joueur)
	if table.find(ordre, joueur.UserId) then
		return
	end

	table.insert(ordre, joueur.UserId)
	surPersonnage(joueur)
end

Players.PlayerAdded:Connect(ajouter)
for _, joueur in Players:GetPlayers() do
	ajouter(joueur)
end

Players.PlayerRemoving:Connect(function(joueur)
	local index = table.find(ordre, joueur.UserId)
	if index then
		table.remove(ordre, index)
	end

	detruireCordesDe(joueur.UserId)
	reconstruire()
end)
