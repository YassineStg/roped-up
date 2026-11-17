local Montagne = require("../src/shared/logic/Montagne")
local Config = require("../src/shared/Config")
local Montagne1 = require("../src/shared/data/Montagne1")
local MontagneCourte = require("../src/shared/data/MontagneCourte")

local tests = {}

local REGLES = {
	ecartMax = Config.JumpMaxGap,
	hauteurMax = Config.JumpMaxRise,
	separationVerticale = Config.PillarDepth + Config.PlatformThickness + 4,
}

local function proche(valeur, attendu, tolerance)
	assert(math.abs(valeur - attendu) <= (tolerance or 1e-6), `attendu {attendu}, reçu {valeur}`)
end

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

local function contient(problemes, fragment)
	for _, probleme in problemes do
		if string.find(probleme, fragment, 1, true) then
			return true
		end
	end
	return false
end

local function description(sections, cap)
	return { cap = cap, sections = sections }
end

local PLATEAU = { type = "plateau", largeur = 20, profondeur = 20 }

-- ---------- Expansion des sections ----------

function tests.la_premiere_plateforme_est_a_l_origine()
	local liste = Montagne.plateformes(description({ PLATEAU }))
	assert(#liste == 1)
	proche(liste[1].x, 0)
	proche(liste[1].y, 0)
	proche(liste[1].z, 0)
	assert(liste[1].matiere == "herbe", "la matière par défaut est l'herbe")
end

function tests.marches_en_ligne_droite()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 4, hauteur = 2 },
	}))
	assert(#liste == 4)
	proche(liste[2].z, 18)
	proche(liste[2].y, 2)
	proche(liste[3].z, 30)
	proche(liste[3].y, 4)
	proche(liste[4].z, 42)
	proche(liste[4].y, 6)
	proche(liste[4].x, 0)
end

function tests.cap_de_depart_tourne_la_montagne()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 1, largeur = 10, profondeur = 8, ecart = 4, hauteur = 0 },
	}, 90))
	proche(liste[2].x, 18, 1e-9)
	proche(liste[2].z, 0, 1e-9)
end

function tests.virage_change_la_direction()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "marches",
			virage = 90,
			n = 1,
			largeur = 10,
			profondeur = 8,
			ecart = 4,
			hauteur = 0,
		},
	}))
	proche(liste[2].x, 18, 1e-9)
	proche(liste[2].z, 0, 1e-9)
	proche(liste[2].cap, math.pi / 2)
end

function tests.spirale_tourne_autour_d_un_centre()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "spirale",
			n = 4,
			rayon = 50,
			pas = 18,
			hauteur = 3,
			largeur = 14,
			profondeur = 9,
			sens = 1,
		},
	}))
	assert(#liste == 5)
	for k = 1, 4 do
		local p = liste[k + 1]
		local distance = math.sqrt((p.x - 50) ^ 2 + p.z ^ 2)
		proche(distance, 50, 1e-6)
		proche(p.y, 3 * k)
		proche(p.cap, math.rad(18) * k)
	end
end

function tests.spirale_dans_l_autre_sens()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "spirale",
			n = 3,
			rayon = 50,
			pas = 18,
			hauteur = 3,
			largeur = 14,
			profondeur = 9,
			sens = -1,
		},
	}))
	for k = 1, 3 do
		local p = liste[k + 1]
		local distance = math.sqrt((p.x + 50) ^ 2 + p.z ^ 2)
		proche(distance, 50, 1e-6)
		proche(p.cap, -math.rad(18) * k)
	end
end

function tests.sommet_et_matiere_sont_conserves()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "plateau", largeur = 30, profondeur = 30, matiere = "pierre", sommet = true },
	}))
	assert(liste[1].sommet == false)
	assert(liste[2].sommet == true)
	assert(liste[2].matiere == "pierre")
end

-- ---------- Checkpoints ----------

function tests.un_plateau_est_un_checkpoint_par_defaut()
	local liste = Montagne.plateformes(description({ PLATEAU }))
	assert(liste[1].checkpoint == true)
end

function tests.un_plateau_peut_refuser_d_etre_un_checkpoint()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "plateau", largeur = 20, profondeur = 20, checkpoint = false },
	}))
	assert(liste[1].checkpoint == true and liste[2].checkpoint == false)
end

function tests.des_marches_ne_sont_pas_des_checkpoints_sauf_demande()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 4, hauteur = 2 },
	}))
	assert(
		liste[2].checkpoint == false
			and liste[3].checkpoint == false
			and liste[4].checkpoint == false
	)
end

function tests.seule_la_derniere_marche_est_un_checkpoint()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "marches",
			n = 3,
			largeur = 10,
			profondeur = 8,
			ecart = 4,
			hauteur = 2,
			checkpoint = true,
		},
	}))
	assert(liste[2].checkpoint == false and liste[3].checkpoint == false)
	assert(liste[4].checkpoint == true)
end

function tests.seule_la_derniere_plateforme_d_une_spirale_est_un_checkpoint()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "spirale",
			n = 4,
			rayon = 50,
			pas = 18,
			hauteur = 3,
			largeur = 14,
			profondeur = 9,
			sens = 1,
			checkpoint = true,
		},
	}))
	assert(
		liste[2].checkpoint == false
			and liste[3].checkpoint == false
			and liste[4].checkpoint == false
	)
	assert(liste[5].checkpoint == true)
end

function tests.checkpoint_invalide_leve_une_erreur()
	attendre_erreur(function()
		Montagne.plateformes(description({
			{ type = "plateau", largeur = 20, profondeur = 20, checkpoint = "oui" },
		}))
	end, "checkpoint")
end

-- ---------- Descriptions invalides ----------

function tests.description_invalide_leve_une_erreur()
	attendre_erreur(function()
		Montagne.plateformes(nil)
	end, "liste de sections")
	attendre_erreur(function()
		Montagne.plateformes({ sections = {} })
	end, "liste de sections")
end

function tests.section_invalide_leve_une_erreur()
	local function essayer(section, fragment)
		attendre_erreur(function()
			Montagne.plateformes(description({ section }))
		end, fragment)
	end

	essayer({ type = "volcan" }, "type inconnu")
	essayer({ type = "plateau", largeur = 0, profondeur = 10 }, "largeur")
	essayer(
		{ type = "marches", n = 0, largeur = 5, profondeur = 5, ecart = 1, hauteur = 1 },
		"n doit"
	)
	essayer(
		{ type = "marches", n = 1.5, largeur = 5, profondeur = 5, ecart = 1, hauteur = 1 },
		"n doit"
	)
	essayer(
		{ type = "marches", n = 2, largeur = 5, profondeur = 5, ecart = -1, hauteur = 1 },
		"écart"
	)
	essayer({ type = "marches", n = 2, largeur = 5, profondeur = 5, ecart = 1 }, "hauteur")
	essayer({ type = "plateau", largeur = 5, profondeur = 5, matiere = "lave" }, "matière")
	essayer({ type = "plateau", largeur = 5, profondeur = 5, virage = "x" }, "virage")
	essayer({
		type = "spirale",
		n = 3,
		rayon = 10,
		pas = 0,
		hauteur = 1,
		largeur = 5,
		profondeur = 5,
		sens = 1,
	}, "pas")
	essayer({
		type = "spirale",
		n = 3,
		rayon = 10,
		pas = 10,
		hauteur = 1,
		largeur = 5,
		profondeur = 5,
		sens = 0,
	}, "sens")
	essayer({
		type = "spirale",
		n = 3,
		rayon = 0,
		pas = 10,
		hauteur = 1,
		largeur = 5,
		profondeur = 5,
		sens = 1,
	}, "rayon")
end

-- ---------- Validation (peut-on gravir la montagne ?) ----------

function tests.montagne_franchissable_sans_probleme()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 5, largeur = 10, profondeur = 8, ecart = 4, hauteur = 3 },
	}))
	assert(#Montagne.valider(liste, REGLES) == 0)
end

function tests.ecart_trop_grand_est_signale()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 8, hauteur = 1 },
	}))
	assert(contient(Montagne.valider(liste, REGLES), "écart"))
end

function tests.marche_trop_haute_est_signalee()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 4, hauteur = 5 },
	}))
	assert(contient(Montagne.valider(liste, REGLES), "marche de"))
end

function tests.descente_n_est_pas_un_probleme()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 4, hauteur = -6 },
	}))
	assert(#Montagne.valider(liste, REGLES) == 0)
end

function tests.spirale_trop_serree_verticalement_est_signalee()
	-- un tour complet ne monte que de 20 : les tours se chevauchent
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{
			type = "spirale",
			n = 20,
			rayon = 40,
			pas = 18,
			hauteur = 1,
			largeur = 14,
			profondeur = 9,
			sens = 1,
		},
	}))
	assert(contient(Montagne.valider(liste, REGLES), "chevauchent"))
end

function tests.plateformes_superposees_sont_signalees()
	local a = { x = 0, y = 0, z = 0, largeur = 10, profondeur = 10, cap = 0 }
	local b = { x = 0, y = 1, z = 0, largeur = 10, profondeur = 10, cap = 0 }
	assert(contient(Montagne.valider({ a, b }, REGLES), "superposées"))
end

function tests.validation_entree_invalide()
	attendre_erreur(function()
		Montagne.valider("abc", REGLES)
	end, "plateformes")
end

-- ---------- Statistiques ----------

function tests.statistiques_d_un_petit_chemin()
	local liste = Montagne.plateformes(description({
		PLATEAU,
		{ type = "marches", n = 3, largeur = 10, profondeur = 8, ecart = 4, hauteur = 2 },
	}))
	local stats = Montagne.statistiques(liste, 10)
	assert(stats.nombre == 4)
	proche(stats.hauteur, 6)
	proche(stats.longueur, math.sqrt(18 ^ 2 + 2 ^ 2) + 2 * math.sqrt(12 ^ 2 + 2 ^ 2), 1e-6)
	proche(stats.duree, stats.longueur / 10, 1e-9)
end

function tests.statistiques_entree_invalide()
	attendre_erreur(function()
		Montagne.statistiques({}, 5)
	end, "non vide")
	attendre_erreur(function()
		Montagne.statistiques({ { x = 0, y = 0, z = 0 } }, 0)
	end, "vitesse")
end

-- ---------- Les vraies montagnes du jeu ----------

local function verifier_montagne(data)
	local liste = Montagne.plateformes(data)
	local problemes = Montagne.valider(liste, REGLES)
	assert(#problemes == 0, "problèmes : " .. table.concat(problemes, " ; "))

	proche(liste[1].x, 0)
	proche(liste[1].z, 0)

	local sommets = 0
	for i, p in liste do
		if p.sommet then
			sommets += 1
			assert(i == #liste, "le sommet doit être la dernière plateforme")
		end
	end
	assert(sommets == 1, "il doit y avoir exactement un sommet")

	return liste
end

function tests.montagne1_est_franchissable()
	local liste = verifier_montagne(Montagne1)
	local stats = Montagne.statistiques(liste, Config.WalkSpeed * Config.ClimbEfficiency)
	assert(stats.nombre >= 150, "la montagne 1 doit être grande")
	assert(stats.hauteur >= 400, "la montagne 1 doit être haute")
	assert(stats.duree >= 240, "la montagne 1 doit durer au moins 4 minutes")
end

function tests.montagne_courte_est_franchissable()
	local liste = verifier_montagne(MontagneCourte)
	local stats = Montagne.statistiques(liste, Config.WalkSpeed * Config.ClimbEfficiency)
	assert(stats.duree < 180, "la montagne courte doit rester courte")
end

function tests.montagnes_toujours_identiques()
	local a = Montagne.plateformes(Montagne1)
	local b = Montagne.plateformes(Montagne1)
	assert(#a == #b)
	for i = 1, #a do
		assert(a[i].x == b[i].x and a[i].y == b[i].y and a[i].z == b[i].z)
	end
end

return tests
