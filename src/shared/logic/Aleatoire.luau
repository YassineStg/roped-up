-- Logique pure : générateur pseudo-aléatoire déterministe.
-- Une même graine donne toujours la même suite, sur tous les serveurs :
-- tous les joueurs voient donc exactement la même montagne.

local Aleatoire = {}

local MODULO = 4294967296

-- Renvoie une fonction qui donne un nombre dans [0, 1) à chaque appel.
function Aleatoire.nouveau(graine)
	if
		type(graine) ~= "number"
		or graine ~= graine
		or graine == math.huge
		or graine == -math.huge
	then
		error("Aleatoire.nouveau : une graine numérique est attendue", 2)
	end

	local etat = math.floor(graine) % MODULO

	return function()
		etat = (etat * 1664525 + 1013904223) % MODULO
		return etat / MODULO
	end
end

return Aleatoire
