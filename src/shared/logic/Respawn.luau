-- Logique pure : où ramener un joueur qui vient de réapparaître.
-- Règle provisoire (avant les checkpoints d'équipe) : au-dessus du coéquipier vivant le plus haut.

local Respawn = {}

-- joueurs : liste de { id, y, vivant }
-- Renvoie l'identifiant du coéquipier vivant le plus haut, sans compter idExclu.
-- Renvoie nil s'il n'y en a aucun.
function Respawn.choisirCible(joueurs, idExclu)
	if type(joueurs) ~= "table" then
		error("Respawn.choisirCible : une liste de joueurs est attendue", 2)
	end

	local meilleur = nil

	for _, joueur in joueurs do
		if joueur.id ~= idExclu and joueur.vivant then
			if meilleur == nil or joueur.y > meilleur.y then
				meilleur = joueur
			end
		end
	end

	if meilleur == nil then
		return nil
	end

	return meilleur.id
end

return Respawn
