-- Logique pure : checkpoints d'équipe. Aucune API Roblox ici.
--
-- Un checkpoint est une plateforme de la montagne marquée checkpoint (voir Montagne.luau).
-- L'équipe garde en mémoire le checkpoint le plus haut atteint par l'un de ses joueurs.
-- Les checkpoints sont numérotés (rang 1, 2, 3...) dans l'ordre du parcours.

local Checkpoints = {}

-- Extrait la liste ordonnée des checkpoints d'une liste de plateformes.
-- Renvoie des éléments { indice, x, y, z, largeur, profondeur, cap, sommet }.
function Checkpoints.extraire(plateformes)
	if type(plateformes) ~= "table" then
		error("Checkpoints.extraire : une liste de plateformes est attendue", 2)
	end

	local liste = {}

	for indice, p in plateformes do
		if p.checkpoint then
			table.insert(liste, {
				indice = indice,
				x = p.x,
				y = p.y,
				z = p.z,
				largeur = p.largeur,
				profondeur = p.profondeur,
				cap = p.cap,
				sommet = p.sommet == true,
			})
		end
	end

	if #liste == 0 then
		error(
			"Checkpoints.extraire : la montagne n'a aucun checkpoint (commence par un plateau)",
			2
		)
	end

	return liste
end

-- État de départ : l'équipe est au checkpoint 1 (le départ).
function Checkpoints.etatInitial()
	return { actif = 1 }
end

-- Renvoie un nouvel état où le checkpoint actif est le plus haut atteint. On ne recule jamais.
function Checkpoints.atteindre(etat, rang)
	if type(etat) ~= "table" or type(etat.actif) ~= "number" then
		error("Checkpoints.atteindre : un état valide est attendu", 2)
	end
	if type(rang) ~= "number" or rang < 1 or rang ~= math.floor(rang) then
		error("Checkpoints.atteindre : le rang doit être un entier d'au moins 1", 2)
	end

	return { actif = math.max(etat.actif, rang) }
end

-- Rang du checkpoint sur lequel se trouve un joueur, ou nil.
-- (x, yPieds, z) : position des pieds. tolerance : hauteur max au-dessus de la plateforme.
-- Si plusieurs checkpoints conviennent, le plus avancé gagne.
function Checkpoints.sous(checkpoints, x, yPieds, z, tolerance)
	if type(checkpoints) ~= "table" then
		error("Checkpoints.sous : une liste de checkpoints est attendue", 2)
	end
	if type(tolerance) ~= "number" or tolerance < 0 then
		error("Checkpoints.sous : la tolérance doit être un nombre positif ou nul", 2)
	end

	local trouve = nil

	for rang, cp in checkpoints do
		local dx = x - cp.x
		local dz = z - cp.z
		local avant = dx * math.sin(cp.cap) + dz * math.cos(cp.cap)
		local cote = dx * math.cos(cp.cap) - dz * math.sin(cp.cap)
		local dedans = math.abs(avant) <= cp.profondeur / 2 and math.abs(cote) <= cp.largeur / 2
		local hauteur = yPieds - cp.y

		if dedans and hauteur >= -1.5 and hauteur <= tolerance then
			trouve = rang
		end
	end

	return trouve
end

-- Où replacer le joueur numéro `rang` (sur `total`) qui reprend à ce checkpoint.
-- Les joueurs sont étalés sur la largeur de la plateforme, sans en sortir.
-- Renvoie { x, y, z } : le centre du dessus de la plateforme, décalé sur le côté.
function Checkpoints.position(checkpoint, rang, total, ecart)
	if type(checkpoint) ~= "table" then
		error("Checkpoints.position : un checkpoint est attendu", 2)
	end
	if
		type(total) ~= "number"
		or total < 1
		or type(rang) ~= "number"
		or rang < 1
		or rang > total
	then
		error("Checkpoints.position : rang et total invalides", 2)
	end

	local limite = math.max(0, checkpoint.largeur / 2 - 1)
	local decalage = math.clamp((rang - (total + 1) / 2) * ecart, -limite, limite)

	return {
		x = checkpoint.x + decalage * math.cos(checkpoint.cap),
		y = checkpoint.y,
		z = checkpoint.z - decalage * math.sin(checkpoint.cap),
	}
end

return Checkpoints
