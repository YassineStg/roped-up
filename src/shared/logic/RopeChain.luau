-- Logique pure : quelles paires de joueurs sont reliées par une corde.
-- Les joueurs forment une chaîne dans l'ordre de la liste : 1-2, 2-3, 3-4...
-- Aucune API Roblox ici, pour pouvoir tester avec Lune.

local RopeChain = {}

-- ids : liste d'identifiants de joueurs, dans l'ordre d'arrivée.
-- maxJoueurs (facultatif) : seuls les premiers joueurs de la liste sont reliés.
-- Renvoie une liste de paires { idA, idB }.
function RopeChain.links(ids, maxJoueurs)
	if type(ids) ~= "table" then
		error("RopeChain.links : une liste d'identifiants est attendue", 2)
	end

	local limite = #ids

	if maxJoueurs ~= nil then
		if
			type(maxJoueurs) ~= "number"
			or maxJoueurs < 0
			or maxJoueurs ~= math.floor(maxJoueurs)
		then
			error("RopeChain.links : maxJoueurs doit être un entier positif ou nul", 2)
		end
		limite = math.min(limite, maxJoueurs)
	end

	local vus = {}
	for i = 1, limite do
		local id = ids[i]
		if vus[id] then
			error("RopeChain.links : identifiant en double (" .. tostring(id) .. ")", 2)
		end
		vus[id] = true
	end

	local liens = {}
	for i = 1, limite - 1 do
		table.insert(liens, { ids[i], ids[i + 1] })
	end

	return liens
end

return RopeChain
