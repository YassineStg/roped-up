local Checkpoints = require("../src/shared/logic/Checkpoints")
local Config = require("../src/shared/Config")
local Montagne = require("../src/shared/logic/Montagne")
local Montagne1 = require("../src/shared/data/Montagne1")
local MontagneCourte = require("../src/shared/data/MontagneCourte")

local tests = {}

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

local function plateforme(x, y, z, largeur, profondeur, cap, checkpoint, sommet)
	return {
		x = x,
		y = y,
		z = z,
		largeur = largeur,
		profondeur = profondeur,
		cap = cap or 0,
		checkpoint = checkpoint == true,
		sommet = sommet == true,
	}
end

-- ---------- Extraction ----------

function tests.extraire_garde_les_checkpoints_dans_l_ordre()
	local liste = Checkpoints.extraire({
		plateforme(0, 0, 0, 20, 20, 0, true),
		plateforme(0, 3, 20, 10, 8, 0, false),
		plateforme(0, 6, 40, 20, 20, 0, true),
		plateforme(0, 9, 60, 10, 8, 0, false),
		plateforme(0, 12, 80, 30, 30, 0, true, true),
	})
	assert(#liste == 3)
	assert(liste[1].indice == 1 and liste[2].indice == 3 and liste[3].indice == 5)
	assert(liste[1].sommet == false and liste[3].sommet == true)
	proche(liste[2].y, 6)
end

function tests.extraire_sans_checkpoint_leve_une_erreur()
	attendre_erreur(function()
		Checkpoints.extraire({ plateforme(0, 0, 0, 10, 10, 0, false) })
	end, "aucun checkpoint")
	attendre_erreur(function()
		Checkpoints.extraire("abc")
	end, "liste de plateformes")
end

-- ---------- État de l'équipe ----------

function tests.etat_initial_equipe_vide_est_au_depart()
	assert(Checkpoints.etatInitial().actif == 1)
end

function tests.atteindre_prend_le_plus_haut()
	local etat = Checkpoints.etatInitial()
	etat = Checkpoints.atteindre(etat, 3)
	assert(etat.actif == 3)
	etat = Checkpoints.atteindre(etat, 2)
	assert(etat.actif == 3, "on ne recule jamais")
	etat = Checkpoints.atteindre(etat, 3)
	assert(etat.actif == 3)
end

function tests.ordre_d_arrivee_different_meme_resultat()
	local function jouer(ordre)
		local etat = Checkpoints.etatInitial()
		for _, rang in ordre do
			etat = Checkpoints.atteindre(etat, rang)
		end
		return etat.actif
	end
	assert(jouer({ 2, 5, 3 }) == 5)
	assert(jouer({ 5, 2, 3 }) == 5)
	assert(jouer({ 3, 2, 5 }) == 5)
end

function tests.atteindre_ne_modifie_pas_l_etat_d_origine()
	local etat = Checkpoints.etatInitial()
	local nouveau = Checkpoints.atteindre(etat, 4)
	assert(etat.actif == 1 and nouveau.actif == 4)
end

function tests.atteindre_entrees_invalides()
	attendre_erreur(function()
		Checkpoints.atteindre(Checkpoints.etatInitial(), 0)
	end, "rang")
	attendre_erreur(function()
		Checkpoints.atteindre(Checkpoints.etatInitial(), 1.5)
	end, "rang")
	attendre_erreur(function()
		Checkpoints.atteindre(Checkpoints.etatInitial(), "x")
	end, "rang")
	attendre_erreur(function()
		Checkpoints.atteindre(nil, 2)
	end, "état")
end

-- ---------- Détection : sur quel checkpoint est le joueur ? ----------

local UN = { plateforme(0, 100, 0, 20, 20, 0, true) }

function tests.sous_au_centre_et_sur_les_bords()
	assert(Checkpoints.sous(UN, 0, 100, 0, 6) == 1)
	assert(Checkpoints.sous(UN, 9.9, 100, 9.9, 6) == 1)
	assert(Checkpoints.sous(UN, -9.9, 100, -9.9, 6) == 1)
end

function tests.sous_hors_de_la_plateforme()
	assert(Checkpoints.sous(UN, 10.1, 100, 0, 6) == nil)
	assert(Checkpoints.sous(UN, 0, 100, -10.1, 6) == nil)
end

function tests.sous_selon_la_hauteur()
	assert(Checkpoints.sous(UN, 0, 105, 0, 6) == 1, "en sautant juste au-dessus")
	assert(Checkpoints.sous(UN, 0, 107, 0, 6) == nil, "trop haut")
	assert(Checkpoints.sous(UN, 0, 99, 0, 6) == 1, "pieds légèrement enfoncés")
	assert(Checkpoints.sous(UN, 0, 98, 0, 6) == nil, "sous la plateforme")
end

function tests.sous_plateforme_tournee()
	-- cap = 90 degrés : la profondeur (10) est le long de X, la largeur (20) le long de Z
	local liste = { plateforme(0, 0, 0, 20, 10, math.rad(90), true) }
	assert(Checkpoints.sous(liste, 4, 0, 0, 6) == 1)
	assert(Checkpoints.sous(liste, 6, 0, 0, 6) == nil)
	assert(Checkpoints.sous(liste, 0, 0, 9, 6) == 1)
	assert(Checkpoints.sous(liste, 0, 0, 11, 6) == nil)
end

function tests.sous_garde_le_checkpoint_le_plus_avance()
	local liste = {
		plateforme(0, 100, 0, 20, 20, 0, true),
		plateforme(0, 104, 0, 20, 20, 0, true),
	}
	assert(Checkpoints.sous(liste, 0, 104, 0, 6) == 2)
	assert(Checkpoints.sous(liste, 0, 100, 0, 3) == 1)
end

function tests.sous_entrees_invalides()
	attendre_erreur(function()
		Checkpoints.sous("abc", 0, 0, 0, 6)
	end, "liste de checkpoints")
	attendre_erreur(function()
		Checkpoints.sous(UN, 0, 0, 0, -1)
	end, "tolérance")
end

-- ---------- Où replacer les joueurs ----------

function tests.position_un_joueur_au_centre()
	local p = Checkpoints.position(UN[1], 1, 1, 3)
	proche(p.x, 0)
	proche(p.y, 100)
	proche(p.z, 0)
end

function tests.position_joueurs_etales_et_symetriques()
	local trois = {}
	for rang = 1, 3 do
		trois[rang] = Checkpoints.position(UN[1], rang, 3, 3)
	end
	proche(trois[1].x, -3)
	proche(trois[2].x, 0)
	proche(trois[3].x, 3)

	local deux1 = Checkpoints.position(UN[1], 1, 2, 3)
	local deux2 = Checkpoints.position(UN[1], 2, 2, 3)
	proche(deux1.x, -1.5)
	proche(deux2.x, 1.5)
end

function tests.position_ne_sort_pas_d_une_petite_plateforme()
	local etroite = plateforme(0, 0, 0, 6, 6, 0, true)
	for rang = 1, 4 do
		local p = Checkpoints.position(etroite, rang, 4, 3)
		assert(math.abs(p.x) <= 2 + 1e-9, "joueur hors de la plateforme étroite")
		assert(Checkpoints.sous({ etroite }, p.x, p.y, p.z, 6) == 1)
	end
end

function tests.position_suit_la_rotation()
	local tournee = plateforme(10, 0, 20, 20, 10, math.rad(90), true)
	local a = Checkpoints.position(tournee, 1, 2, 4)
	local b = Checkpoints.position(tournee, 2, 2, 4)
	proche(a.x, 10, 1e-9)
	proche(b.x, 10, 1e-9)
	proche(math.abs(a.z - b.z), 4, 1e-9)
	assert(Checkpoints.sous({ tournee }, a.x, a.y, a.z, 6) == 1)
	assert(Checkpoints.sous({ tournee }, b.x, b.y, b.z, 6) == 1)
end

function tests.position_reste_dans_la_plateforme_pour_tous_les_angles()
	-- plateforme large mais peu profonde : un décalage dans la mauvaise direction la ferait sortir
	for degres = 0, 340, 20 do
		local large = plateforme(5, 10, -7, 40, 8, math.rad(degres), true)
		for rang = 1, 4 do
			local p = Checkpoints.position(large, rang, 4, 6)
			assert(
				Checkpoints.sous({ large }, p.x, p.y, p.z, 6) == 1,
				`joueur {rang} hors de la plateforme à {degres} degrés`
			)
		end
	end
end

function tests.position_entrees_invalides()
	attendre_erreur(function()
		Checkpoints.position(UN[1], 3, 2, 3)
	end, "rang et total")
	attendre_erreur(function()
		Checkpoints.position(UN[1], 1, 0, 3)
	end, "rang et total")
	attendre_erreur(function()
		Checkpoints.position(nil, 1, 1, 3)
	end, "checkpoint")
end

-- ---------- Les vraies montagnes ----------

local function verifier(data, minimum)
	local plateformes = Montagne.plateformes(data)
	local liste = Checkpoints.extraire(plateformes)

	assert(#liste >= minimum, "pas assez de checkpoints : " .. #liste)
	assert(liste[1].indice == 1, "le départ doit être le checkpoint 1")
	assert(liste[#liste].sommet, "le dernier checkpoint doit être le sommet")

	-- chaque checkpoint se retrouve en se tenant à son propre centre
	for rang, cp in liste do
		assert(
			Checkpoints.sous(liste, cp.x, cp.y, cp.z, Config.CheckpointTolerance) == rang,
			"checkpoint " .. rang .. " introuvable"
		)
	end

	-- deux checkpoints ne doivent pas être trop éloignés le long du chemin
	local pireDistance = 0
	for rang = 2, #liste do
		local distance = 0
		for i = liste[rang - 1].indice + 1, liste[rang].indice do
			local a = plateformes[i - 1]
			local b = plateformes[i]
			distance += math.sqrt((b.x - a.x) ^ 2 + (b.y - a.y) ^ 2 + (b.z - a.z) ^ 2)
		end
		pireDistance = math.max(pireDistance, distance)
	end
	assert(
		pireDistance <= 800,
		"deux checkpoints sont trop éloignés : " .. math.floor(pireDistance) .. " studs"
	)
end

function tests.montagne1_checkpoints_bien_repartis()
	verifier(Montagne1, 6)
end

function tests.montagne_courte_checkpoints()
	verifier(MontagneCourte, 3)
end

return tests
