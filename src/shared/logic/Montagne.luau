-- Logique pure : transforme la description d'une montagne en liste de plateformes,
-- puis vérifie qu'on peut la gravir. Aucune API Roblox ici.
--
-- Une montagne est une suite de sections, enchaînées à partir d'un curseur
-- qui avance dans la direction courante (le "cap", en degrés, 0 = vers +Z) :
--   plateau : une grande plateforme (zone de repos, c'est aussi un checkpoint)
--   marches : n plateformes qui montent (ou restent à plat) en ligne
--   spirale : n plateformes qui tournent autour d'un centre en montant
-- Une section peut commencer par un "virage" (en degrés) qui change le cap.
-- Un plateau est un checkpoint (sauf checkpoint = false) ; pour des marches ou une spirale,
-- checkpoint = true fait de leur dernière plateforme un checkpoint.

local Montagne = {}

local MATIERES = { herbe = true, pierre = true }

local function estNombre(valeur)
	return type(valeur) == "number"
		and valeur == valeur
		and valeur ~= math.huge
		and valeur ~= -math.huge
end

local function estPositif(valeur)
	return estNombre(valeur) and valeur > 0
end

-- Longueur d'une plateforme mesurée dans une direction qui fait l'angle delta
-- (en radians) avec son axe avant. Sert à calculer les écarts entre plateformes.
local function demiLongueur(largeur, profondeur, delta)
	return (profondeur / 2) * math.abs(math.cos(delta)) + (largeur / 2) * math.abs(math.sin(delta))
end

-- Renvoie un message si la section est invalide, sinon nil.
local function verifierSection(section, indice)
	local nom = "section " .. indice

	if type(section) ~= "table" then
		return nom .. " : une table est attendue"
	end

	if section.matiere ~= nil and not MATIERES[section.matiere] then
		return nom .. " : matière inconnue (" .. tostring(section.matiere) .. ")"
	end

	if section.virage ~= nil and not estNombre(section.virage) then
		return nom .. " : le virage doit être un nombre"
	end

	if section.checkpoint ~= nil and type(section.checkpoint) ~= "boolean" then
		return nom .. " : checkpoint doit valoir true ou false"
	end

	if section.type == "plateau" then
		if not estPositif(section.largeur) or not estPositif(section.profondeur) then
			return nom .. " : un plateau a besoin d'une largeur et d'une profondeur positives"
		end
		if section.ecart ~= nil and not (estNombre(section.ecart) and section.ecart >= 0) then
			return nom .. " : l'écart doit être un nombre positif ou nul"
		end
	elseif section.type == "marches" then
		if not (estNombre(section.n) and section.n >= 1 and section.n == math.floor(section.n)) then
			return nom .. " : n doit être un entier d'au moins 1"
		end
		if not estPositif(section.largeur) or not estPositif(section.profondeur) then
			return nom .. " : des marches ont besoin d'une largeur et d'une profondeur positives"
		end
		if not (estNombre(section.ecart) and section.ecart >= 0) then
			return nom .. " : l'écart doit être un nombre positif ou nul"
		end
		if not estNombre(section.hauteur) then
			return nom .. " : la hauteur doit être un nombre"
		end
	elseif section.type == "spirale" then
		if not (estNombre(section.n) and section.n >= 1 and section.n == math.floor(section.n)) then
			return nom .. " : n doit être un entier d'au moins 1"
		end
		if not estPositif(section.rayon) then
			return nom .. " : le rayon doit être positif"
		end
		if not (estNombre(section.pas) and section.pas > 0) then
			return nom .. " : le pas (en degrés) doit être positif"
		end
		if not estNombre(section.hauteur) then
			return nom .. " : la hauteur doit être un nombre"
		end
		if not estPositif(section.largeur) or not estPositif(section.profondeur) then
			return nom .. " : une spirale a besoin d'une largeur et d'une profondeur positives"
		end
		if section.sens ~= 1 and section.sens ~= -1 then
			return nom .. " : le sens doit valoir 1 ou -1"
		end
	else
		return nom .. " : type inconnu (" .. tostring(section.type) .. ")"
	end

	return nil
end

-- Renvoie la liste des plateformes : { x, y, z, largeur, profondeur, cap, matiere, section, sommet, checkpoint }.
-- (x, y, z) est le centre du dessus de la plateforme. cap est en radians.
-- La première plateforme est centrée sur (0, 0, 0).
function Montagne.plateformes(description)
	if
		type(description) ~= "table"
		or type(description.sections) ~= "table"
		or #description.sections == 0
	then
		error("Montagne.plateformes : une description avec une liste de sections est attendue", 2)
	end

	local cap = math.rad(description.cap or 0)
	local x, y, z = 0, 0, 0
	local liste = {}

	local function ajouter(largeur, profondeur, indice, section, checkpoint)
		table.insert(liste, {
			x = x,
			y = y,
			z = z,
			largeur = largeur,
			profondeur = profondeur,
			cap = cap,
			matiere = section.matiere or "herbe",
			section = indice,
			sommet = section.sommet == true,
			checkpoint = checkpoint,
		})
	end

	-- Avance le curseur d'une plateforme à la suivante, dans la direction du cap.
	local function avancer(largeur, profondeur, ecart, hauteur, indice, section, checkpoint)
		local derniere = liste[#liste]

		if derniere ~= nil then
			local avant = demiLongueur(derniere.largeur, derniere.profondeur, cap - derniere.cap)
			local distance = avant + ecart + profondeur / 2
			x += math.sin(cap) * distance
			z += math.cos(cap) * distance
		end

		y += hauteur
		ajouter(largeur, profondeur, indice, section, checkpoint)
	end

	for indice, section in description.sections do
		local erreur = verifierSection(section, indice)
		if erreur then
			error("Montagne.plateformes : " .. erreur, 2)
		end

		cap += math.rad(section.virage or 0)

		if section.type == "plateau" then
			avancer(
				section.largeur,
				section.profondeur,
				section.ecart or 4,
				0,
				indice,
				section,
				section.checkpoint ~= false
			)
		elseif section.type == "marches" then
			for k = 1, section.n do
				local dernier = k == section.n and section.checkpoint == true
				avancer(
					section.largeur,
					section.profondeur,
					section.ecart,
					section.hauteur,
					indice,
					section,
					dernier
				)
			end
		elseif section.type == "spirale" then
			local sens = section.sens
			local pas = math.rad(section.pas)
			local cap0 = cap
			-- centre du cercle : sur le côté vers lequel on tourne
			local cx = x + section.rayon * sens * math.cos(cap0)
			local cz = z - section.rayon * sens * math.sin(cap0)

			for k = 1, section.n do
				cap = cap0 + sens * pas * k
				x = cx - section.rayon * sens * math.cos(cap)
				z = cz + section.rayon * sens * math.sin(cap)
				y += section.hauteur
				ajouter(
					section.largeur,
					section.profondeur,
					indice,
					section,
					k == section.n and section.checkpoint == true
				)
			end
		end
	end

	return liste
end

-- Écart libre entre deux plateformes, mesuré le long de la ligne qui relie leurs centres.
local function ecartEntre(a, b)
	local dx = b.x - a.x
	local dz = b.z - a.z
	local distance = math.sqrt(dx * dx + dz * dz)

	if distance == 0 then
		return nil
	end

	local ux = dx / distance
	local uz = dz / distance

	local function demi(p)
		-- axes de la plateforme : avant = (sin cap, cos cap), côté = (cos cap, -sin cap)
		local surAvant = math.abs(ux * math.sin(p.cap) + uz * math.cos(p.cap))
		local surCote = math.abs(ux * math.cos(p.cap) - uz * math.sin(p.cap))
		return (p.profondeur / 2) * surAvant + (p.largeur / 2) * surCote
	end

	return distance - demi(a) - demi(b)
end

-- Vrai si les rectangles vus de dessus de deux plateformes se chevauchent.
local function seChevauchent(a, b)
	local dx = b.x - a.x
	local dz = b.z - a.z

	local axes = {
		{ math.sin(a.cap), math.cos(a.cap) },
		{ math.cos(a.cap), -math.sin(a.cap) },
		{ math.sin(b.cap), math.cos(b.cap) },
		{ math.cos(b.cap), -math.sin(b.cap) },
	}

	local function rayon(p, ax, az)
		local surAvant = math.abs(ax * math.sin(p.cap) + az * math.cos(p.cap))
		local surCote = math.abs(ax * math.cos(p.cap) - az * math.sin(p.cap))
		return (p.profondeur / 2) * surAvant + (p.largeur / 2) * surCote
	end

	for _, axe in axes do
		local projection = math.abs(dx * axe[1] + dz * axe[2])
		if projection >= rayon(a, axe[1], axe[2]) + rayon(b, axe[1], axe[2]) then
			return false -- un axe sépare les deux rectangles
		end
	end

	return true
end

-- Vérifie qu'on peut gravir la montagne et que rien ne s'entremêle.
-- regles : { ecartMax, hauteurMax, separationVerticale }
-- Renvoie la liste des problèmes (vide si tout est bon).
function Montagne.valider(plateformes, regles)
	if type(plateformes) ~= "table" or type(regles) ~= "table" then
		error("Montagne.valider : une liste de plateformes et des règles sont attendues", 2)
	end

	local problemes = {}

	for i = 1, #plateformes - 1 do
		local a = plateformes[i]
		local b = plateformes[i + 1]
		local ecart = ecartEntre(a, b)

		if ecart == nil then
			table.insert(problemes, `plateformes {i} et {i + 1} : superposées`)
		else
			if ecart > regles.ecartMax then
				table.insert(
					problemes,
					string.format(
						"plateformes %d et %d : écart de %.1f (maximum %.1f)",
						i,
						i + 1,
						ecart,
						regles.ecartMax
					)
				)
			end
			if b.y - a.y > regles.hauteurMax then
				table.insert(
					problemes,
					string.format(
						"plateformes %d et %d : marche de %.1f (maximum %.1f)",
						i,
						i + 1,
						b.y - a.y,
						regles.hauteurMax
					)
				)
			end
		end
	end

	for i = 1, #plateformes do
		for j = i + 2, #plateformes do
			local a = plateformes[i]
			local b = plateformes[j]
			if math.abs(a.y - b.y) < regles.separationVerticale and seChevauchent(a, b) then
				table.insert(problemes, `plateformes {i} et {j} : se chevauchent`)
			end
		end
	end

	return problemes
end

-- Chiffres utiles : nombre de plateformes, longueur du chemin, hauteur, durée estimée.
-- vitesse : vitesse moyenne réelle en studs par seconde (marche × efficacité).
function Montagne.statistiques(plateformes, vitesse)
	if type(plateformes) ~= "table" or #plateformes == 0 then
		error("Montagne.statistiques : une liste de plateformes non vide est attendue", 2)
	end
	if not estPositif(vitesse) then
		error("Montagne.statistiques : une vitesse positive est attendue", 2)
	end

	local longueur = 0
	local minY = plateformes[1].y
	local maxY = plateformes[1].y

	for i = 2, #plateformes do
		local a = plateformes[i - 1]
		local b = plateformes[i]
		longueur += math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + (b.z - a.z) ^ 2)
		minY = math.min(minY, b.y)
		maxY = math.max(maxY, b.y)
	end

	return {
		nombre = #plateformes,
		longueur = longueur,
		hauteur = maxY - minY,
		duree = longueur / vitesse,
	}
end

return Montagne
