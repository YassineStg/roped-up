local RopeChain = require("../src/shared/logic/RopeChain")

local tests = {}

local function attendre_liens(liens, attendu)
	assert(#liens == #attendu, `attendu {#attendu} lien(s), reçu {#liens}`)
	for i, paire in attendu do
		assert(liens[i][1] == paire[1] and liens[i][2] == paire[2], `lien {i} inattendu`)
	end
end

local function attendre_erreur(fn, fragment)
	local ok, err = pcall(fn)
	assert(not ok, "une erreur était attendue")
	assert(
		string.find(tostring(err), fragment, 1, true),
		"message d'erreur inattendu : " .. tostring(err)
	)
end

function tests.liste_vide()
	attendre_liens(RopeChain.links({}), {})
end

function tests.un_seul_joueur_pas_de_corde()
	attendre_liens(RopeChain.links({ 7 }), {})
end

function tests.deux_joueurs_une_corde()
	attendre_liens(RopeChain.links({ 1, 2 }), { { 1, 2 } })
end

function tests.trois_joueurs_en_chaine()
	attendre_liens(RopeChain.links({ 1, 2, 3 }), { { 1, 2 }, { 2, 3 } })
end

function tests.quatre_joueurs_en_chaine()
	attendre_liens(RopeChain.links({ 1, 2, 3, 4 }), { { 1, 2 }, { 2, 3 }, { 3, 4 } })
end

function tests.l_ordre_de_la_liste_est_conserve()
	attendre_liens(RopeChain.links({ 30, 10, 20 }), { { 30, 10 }, { 10, 20 } })
end

function tests.limite_de_joueurs()
	attendre_liens(RopeChain.links({ 1, 2, 3, 4, 5 }, 4), { { 1, 2 }, { 2, 3 }, { 3, 4 } })
end

function tests.limite_zero()
	attendre_liens(RopeChain.links({ 1, 2, 3 }, 0), {})
end

function tests.limite_superieure_au_nombre_de_joueurs()
	attendre_liens(RopeChain.links({ 1, 2 }, 10), { { 1, 2 } })
end

function tests.doublon_leve_une_erreur()
	attendre_erreur(function()
		RopeChain.links({ 1, 2, 1 })
	end, "double")
end

function tests.doublon_au_dela_de_la_limite_est_ignore()
	attendre_liens(RopeChain.links({ 1, 2, 3, 2 }, 3), { { 1, 2 }, { 2, 3 } })
end

function tests.entree_non_table_leve_une_erreur()
	attendre_erreur(function()
		RopeChain.links("abc")
	end, "liste")
end

function tests.limite_invalide_leve_une_erreur()
	attendre_erreur(function()
		RopeChain.links({ 1, 2 }, -1)
	end, "maxJoueurs")
	attendre_erreur(function()
		RopeChain.links({ 1, 2 }, 2.5)
	end, "maxJoueurs")
	attendre_erreur(function()
		RopeChain.links({ 1, 2 }, "x")
	end, "maxJoueurs")
end

function tests.la_liste_d_entree_n_est_pas_modifiee()
	local ids = { 1, 2, 3 }
	RopeChain.links(ids, 2)
	assert(#ids == 3 and ids[3] == 3, "la liste d'entrée a été modifiée")
end

return tests
