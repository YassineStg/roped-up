local Aleatoire = require("../src/shared/logic/Aleatoire")

local tests = {}

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

function tests.meme_graine_meme_suite()
	local a = Aleatoire.nouveau(42)
	local b = Aleatoire.nouveau(42)
	for _ = 1, 20 do
		assert(a() == b(), "deux générateurs de même graine doivent donner la même suite")
	end
end

function tests.graines_differentes_suites_differentes()
	local a = Aleatoire.nouveau(1)
	local b = Aleatoire.nouveau(2)
	local identiques = 0
	for _ = 1, 20 do
		if a() == b() then
			identiques += 1
		end
	end
	assert(identiques < 20, "deux graines différentes ne doivent pas donner la même suite")
end

function tests.valeurs_dans_zero_un()
	local hasard = Aleatoire.nouveau(7)
	for _ = 1, 1000 do
		local v = hasard()
		assert(v >= 0 and v < 1, "valeur hors de [0, 1) : " .. tostring(v))
	end
end

function tests.repartition_a_peu_pres_uniforme()
	local hasard = Aleatoire.nouveau(123)
	local somme = 0
	for _ = 1, 2000 do
		somme += hasard()
	end
	local moyenne = somme / 2000
	assert(moyenne > 0.45 and moyenne < 0.55, "moyenne inattendue : " .. tostring(moyenne))
end

function tests.graine_negative_ou_decimale_acceptee()
	local a = Aleatoire.nouveau(-5)
	local b = Aleatoire.nouveau(3.7)
	assert(a() >= 0 and b() >= 0)
end

function tests.graine_invalide_leve_une_erreur()
	attendre_erreur(function()
		Aleatoire.nouveau("abc")
	end, "graine numérique")
	attendre_erreur(function()
		Aleatoire.nouveau(0 / 0)
	end, "graine numérique")
	attendre_erreur(function()
		Aleatoire.nouveau(math.huge)
	end, "graine numérique")
end

return tests
