-- Logique pure : positions du décor (montagnes au loin, champignons lumineux).
-- Le hasard est fourni par l'appelant (une fonction qui renvoie un nombre dans [0, 1),
-- comme celle de Aleatoire.nouveau) : une même graine donne donc toujours le même décor.
-- Aucune API Roblox ici.

local Decor = {}

-- Massifs lointains, faits de blocs empilés qui rétrécissent vers le haut.
-- centre : { x, z } autour duquel placer les massifs
-- options : { nombre, distanceMin, distanceMax, hauteurMax, niveauBas }
-- Renvoie une liste de blocs { x, y, z, largeur, hauteur, profondeur, ton, neige }.
-- (x, y, z) est le centre du bloc ; ton est un nombre dans [0, 1) pour varier la couleur.
function Decor.massifs(hasard, centre, options)
	if type(hasard) ~= "function" or type(centre) ~= "table" or type(options) ~= "table" then
		error("Decor.massifs : une fonction de hasard, un centre et des options sont attendus", 2)
	end
	if options.distanceMax < options.distanceMin then
		error("Decor.massifs : distanceMax doit dépasser distanceMin", 2)
	end

	local blocs = {}

	for _ = 1, options.nombre do
		local angle = hasard() * 2 * math.pi
		local distance = options.distanceMin
			+ hasard() * (options.distanceMax - options.distanceMin)
		local cx = centre.x + math.sin(angle) * distance
		local cz = centre.z + math.cos(angle) * distance

		local largeur = 90 + hasard() * 110
		local hauteurTotale = options.hauteurMax * (0.35 + hasard() * 0.65)
		local etages = 4 + math.floor(hasard() * 3)
		local hauteurEtage = hauteurTotale / etages
		local ton = hasard()

		for etage = 1, etages do
			local reduction = 1 - (etage - 1) / etages * 0.8
			table.insert(blocs, {
				x = cx + (hasard() - 0.5) * 12,
				y = options.niveauBas + hauteurEtage * (etage - 0.5),
				z = cz + (hasard() - 0.5) * 12,
				largeur = largeur * reduction,
				hauteur = hauteurEtage,
				profondeur = largeur * reduction * (0.8 + hasard() * 0.4),
				ton = ton,
				neige = etage == etages,
			})
		end
	end

	return blocs
end

-- Champignons lumineux posés sur les plateformes d'herbe (jamais sur le sommet).
-- plateformes : liste produite par Montagne.plateformes
-- probabilite : chance (0 à 1) qu'une plateforme d'herbe porte un champignon
-- Renvoie une liste de { x, y, z, couleur (1 à 3), hauteur }.
function Decor.champignons(hasard, plateformes, probabilite)
	if type(hasard) ~= "function" or type(plateformes) ~= "table" then
		error(
			"Decor.champignons : une fonction de hasard et une liste de plateformes sont attendues",
			2
		)
	end
	if type(probabilite) ~= "number" or probabilite < 0 or probabilite > 1 then
		error("Decor.champignons : la probabilité doit être entre 0 et 1", 2)
	end

	local champignons = {}

	for _, p in plateformes do
		-- on tire toujours les mêmes nombres, pour que le décor ne change pas si on ajuste la probabilité
		local tirage = hasard()
		local ox = (hasard() - 0.5) * (p.largeur - 4)
		local oz = (hasard() - 0.5) * (p.profondeur - 4)
		local couleur = 1 + math.floor(hasard() * 3)
		local hauteur = 1.5 + hasard() * 2

		if p.matiere == "herbe" and not p.sommet and tirage < probabilite then
			table.insert(champignons, {
				x = p.x + ox * math.cos(p.cap) + oz * math.sin(p.cap),
				y = p.y,
				z = p.z - ox * math.sin(p.cap) + oz * math.cos(p.cap),
				couleur = couleur,
				hauteur = hauteur,
			})
		end
	end

	return champignons
end

return Decor
