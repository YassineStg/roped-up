local Time = require("../src/shared/logic/Time")

local tests = {}

local function attendre(valeur, attendu)
	assert(valeur == attendu, `attendu "{attendu}", reçu "{valeur}"`)
end

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

function tests.zero()
	attendre(Time.format(0), "00:00.00")
end

function tests.moins_d_une_seconde()
	attendre(Time.format(0.5), "00:00.50")
	attendre(Time.format(0.07), "00:00.07")
end

function tests.arrondi_au_centieme()
	attendre(Time.format(0.004), "00:00.00")
	attendre(Time.format(0.006), "00:00.01")
	attendre(Time.format(0.999), "00:01.00")
end

function tests.erreur_de_virgule_flottante()
	attendre(Time.format(1.15), "00:01.15")
	attendre(Time.format(2.3), "00:02.30")
end

function tests.juste_avant_une_minute()
	attendre(Time.format(59.99), "00:59.99")
end

function tests.une_minute_pile()
	attendre(Time.format(60), "01:00.00")
end

function tests.minutes_et_secondes()
	attendre(Time.format(61.25), "01:01.25")
	attendre(Time.format(185.5), "03:05.50")
end

function tests.plus_de_soixante_minutes()
	attendre(Time.format(3600), "60:00.00")
	attendre(Time.format(3725.5), "62:05.50")
end

function tests.valeur_negative_leve_une_erreur()
	attendre_erreur(function()
		Time.format(-1)
	end, "négatif")
end

function tests.valeur_non_numerique_leve_une_erreur()
	attendre_erreur(function()
		Time.format("abc")
	end, "nombre est attendu")
	attendre_erreur(function()
		Time.format(nil)
	end, "nombre est attendu")
end

function tests.nan_et_infini_levent_une_erreur()
	attendre_erreur(function()
		Time.format(0 / 0)
	end, "nombre est attendu")
	attendre_erreur(function()
		Time.format(math.huge)
	end, "fini")
end

return tests
