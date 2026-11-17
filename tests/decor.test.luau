local Aleatoire = require("../src/shared/logic/Aleatoire")
local Decor = require("../src/shared/logic/Decor")
local Montagne = require("../src/shared/logic/Montagne")
local Montagne1 = require("../src/shared/data/Montagne1")

local tests = {}

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

local OPTIONS = {
	nombre = 6,
	distanceMin = 400,
	distanceMax = 900,
	hauteurMax = 450,
	niveauBas = -140,
}

local CENTRE = { x = 25, z = 300 }

-- ---------- Massifs lointains ----------

function tests.massifs_nombre_de_blocs()
	local blocs = Decor.massifs(Aleatoire.nouveau(1), CENTRE, OPTIONS)
	assert(#blocs >= 6 * 4 and #blocs <= 6 * 6, "nombre de blocs inattendu : " .. #blocs)
end

function tests.massifs_une_cime_enneigee_par_massif()
	local blocs = Decor.massifs(Aleatoire.nouveau(1), CENTRE, OPTIONS)
	local neige = 0
	for _, bloc in blocs do
		if bloc.neige then
			neige += 1
		end
	end
	assert(neige == 6, "une cime enneigée par massif attendue, reçu " .. neige)
end

function tests.massifs_restent_loin_et_au_dessus_du_niveau_bas()
	local blocs = Decor.massifs(Aleatoire.nouveau(5), CENTRE, OPTIONS)
	for _, bloc in blocs do
		local distance = math.sqrt((bloc.x - CENTRE.x) ^ 2 + (bloc.z - CENTRE.z) ^ 2)
		assert(
			distance >= OPTIONS.distanceMin - 7 and distance <= OPTIONS.distanceMax + 7,
			"bloc trop près ou trop loin"
		)
		assert(bloc.y - bloc.hauteur / 2 >= OPTIONS.niveauBas - 1e-9, "bloc sous le niveau bas")
		assert(bloc.largeur > 0 and bloc.hauteur > 0 and bloc.profondeur > 0)
		assert(bloc.ton >= 0 and bloc.ton < 1)
	end
end

function tests.massifs_ne_depassent_pas_la_hauteur_max()
	local blocs = Decor.massifs(Aleatoire.nouveau(9), CENTRE, OPTIONS)
	for _, bloc in blocs do
		assert(
			bloc.y + bloc.hauteur / 2 <= OPTIONS.niveauBas + OPTIONS.hauteurMax + 1e-6,
			"massif trop haut"
		)
	end
end

function tests.massifs_toujours_identiques_avec_la_meme_graine()
	local a = Decor.massifs(Aleatoire.nouveau(77), CENTRE, OPTIONS)
	local b = Decor.massifs(Aleatoire.nouveau(77), CENTRE, OPTIONS)
	assert(#a == #b)
	for i = 1, #a do
		assert(a[i].x == b[i].x and a[i].y == b[i].y and a[i].z == b[i].z)
	end
end

function tests.massifs_entrees_invalides()
	attendre_erreur(function()
		Decor.massifs("abc", CENTRE, OPTIONS)
	end, "fonction de hasard")
	attendre_erreur(function()
		Decor.massifs(Aleatoire.nouveau(1), CENTRE, {
			nombre = 3,
			distanceMin = 900,
			distanceMax = 400,
			hauteurMax = 100,
			niveauBas = 0,
		})
	end, "distanceMax")
end

-- ---------- Champignons ----------

local function plateformes_de_test()
	return Montagne.plateformes(Montagne1)
end

function tests.champignons_probabilite_zero_et_un()
	local liste = plateformes_de_test()
	assert(#Decor.champignons(Aleatoire.nouveau(1), liste, 0) == 0)

	local attendu = 0
	for _, p in liste do
		if p.matiere == "herbe" and not p.sommet then
			attendu += 1
		end
	end
	-- avec une probabilité de 1, tirage < 1 est toujours vrai
	assert(#Decor.champignons(Aleatoire.nouveau(1), liste, 1) == attendu)
end

function tests.champignons_seulement_sur_l_herbe()
	local liste = plateformes_de_test()
	local champignons = Decor.champignons(Aleatoire.nouveau(3), liste, 1)
	for _, c in champignons do
		local sur_herbe = false
		for _, p in liste do
			local proche = math.abs(p.x - c.x) < p.largeur
				and math.abs(p.z - c.z) < p.largeur
				and math.abs(p.y - c.y) < 1e-9
			if proche and p.matiere == "herbe" and not p.sommet then
				sur_herbe = true
				break
			end
		end
		assert(sur_herbe, "un champignon n'est pas posé sur une plateforme d'herbe")
		assert(c.couleur >= 1 and c.couleur <= 3 and c.hauteur > 0)
	end
end

function tests.champignons_jamais_sur_le_sommet_meme_en_herbe()
	local liste = {
		{
			x = 0,
			y = 0,
			z = 0,
			largeur = 30,
			profondeur = 30,
			cap = 0,
			matiere = "herbe",
			sommet = true,
		},
	}
	assert(#Decor.champignons(Aleatoire.nouveau(1), liste, 1) == 0)
end

function tests.champignons_restent_dans_la_plateforme()
	local liste = {
		{
			x = 100,
			y = 20,
			z = 200,
			largeur = 14,
			profondeur = 9,
			cap = 0.7,
			matiere = "herbe",
			sommet = false,
		},
	}
	for graine = 1, 50 do
		local champignons = Decor.champignons(Aleatoire.nouveau(graine), liste, 1)
		assert(#champignons == 1)
		local c = champignons[1]
		-- coordonnées dans le repère de la plateforme
		local dx = c.x - 100
		local dz = c.z - 200
		local local_x = dx * math.cos(0.7) - dz * math.sin(0.7)
		local local_z = dx * math.sin(0.7) + dz * math.cos(0.7)
		assert(math.abs(local_x) <= 14 / 2 - 2 + 1e-6, "champignon hors de la plateforme (largeur)")
		assert(
			math.abs(local_z) <= 9 / 2 - 2 + 1e-6,
			"champignon hors de la plateforme (profondeur)"
		)
	end
end

function tests.champignons_decor_stable_quand_la_probabilite_change()
	local liste = plateformes_de_test()
	local peu = Decor.champignons(Aleatoire.nouveau(8), liste, 0.3)
	local beaucoup = Decor.champignons(Aleatoire.nouveau(8), liste, 0.6)
	assert(#peu <= #beaucoup)
	for _, c in peu do
		local retrouve = false
		for _, d in beaucoup do
			if d.x == c.x and d.z == c.z then
				retrouve = true
				break
			end
		end
		assert(retrouve, "un champignon a changé de place quand la probabilité a changé")
	end
end

function tests.champignons_entrees_invalides()
	attendre_erreur(function()
		Decor.champignons(Aleatoire.nouveau(1), "abc", 0.5)
	end, "liste de plateformes")
	attendre_erreur(function()
		Decor.champignons(Aleatoire.nouveau(1), {}, 1.5)
	end, "probabilité")
end

return tests
