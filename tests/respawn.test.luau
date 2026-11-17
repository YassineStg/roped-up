local Respawn = require("../src/shared/logic/Respawn")

local tests = {}

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

function tests.choisit_le_coequipier_le_plus_haut()
	local joueurs = {
		{ id = 1, y = 10, vivant = true },
		{ id = 2, y = 50, vivant = true },
		{ id = 3, y = 30, vivant = true },
	}
	assert(Respawn.choisirCible(joueurs, 1) == 2)
end

function tests.ignore_le_joueur_qui_reapparait()
	local joueurs = {
		{ id = 1, y = 100, vivant = true },
		{ id = 2, y = 50, vivant = true },
	}
	assert(Respawn.choisirCible(joueurs, 1) == 2)
end

function tests.ignore_les_joueurs_morts()
	local joueurs = {
		{ id = 1, y = 5, vivant = true },
		{ id = 2, y = 90, vivant = false },
		{ id = 3, y = 40, vivant = true },
	}
	assert(Respawn.choisirCible(joueurs, 1) == 3)
end

function tests.personne_d_autre_renvoie_nil()
	assert(Respawn.choisirCible({}, 1) == nil)
	assert(Respawn.choisirCible({ { id = 1, y = 0, vivant = true } }, 1) == nil)
	assert(Respawn.choisirCible({ { id = 2, y = 0, vivant = false } }, 1) == nil)
end

function tests.egalite_garde_le_premier()
	local joueurs = {
		{ id = 2, y = 20, vivant = true },
		{ id = 3, y = 20, vivant = true },
	}
	assert(Respawn.choisirCible(joueurs, 1) == 2)
end

function tests.hauteurs_negatives()
	local joueurs = {
		{ id = 2, y = -10, vivant = true },
		{ id = 3, y = -5, vivant = true },
	}
	assert(Respawn.choisirCible(joueurs, 1) == 3)
end

function tests.entree_invalide_leve_une_erreur()
	attendre_erreur(function()
		Respawn.choisirCible("abc", 1)
	end, "liste de joueurs")
end

return tests
