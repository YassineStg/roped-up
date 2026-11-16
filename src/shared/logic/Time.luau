-- Logique pure : mise en forme du temps d'une équipe.
-- Aucune API Roblox ici, pour pouvoir tester avec Lune.

local Time = {}

local CENTIEMES_PAR_SECONDE = 100
local CENTIEMES_PAR_MINUTE = 6000

-- Renvoie un temps en secondes au format "mm:ss.cc".
-- Les minutes ne sont pas plafonnées : 3725.5 donne "62:05.50".
-- Le temps est arrondi au centième le plus proche.
function Time.format(secondes)
	if type(secondes) ~= "number" or secondes ~= secondes then
		error("Time.format : un nombre est attendu, reçu " .. tostring(secondes), 2)
	end

	if secondes == math.huge or secondes == -math.huge then
		error("Time.format : le temps doit être fini", 2)
	end

	if secondes < 0 then
		error(
			"Time.format : le temps ne peut pas être négatif (reçu " .. tostring(secondes) .. ")",
			2
		)
	end

	local total = math.floor(secondes * CENTIEMES_PAR_SECONDE + 0.5)
	local minutes = math.floor(total / CENTIEMES_PAR_MINUTE)
	local reste = total % CENTIEMES_PAR_MINUTE
	local sec = math.floor(reste / CENTIEMES_PAR_SECONDE)
	local centiemes = reste % CENTIEMES_PAR_SECONDE

	return string.format("%02d:%02d.%02d", minutes, sec, centiemes)
end

return Time
