local Config = require("../src/shared/Config")

local tests = {}

function tests.rope_length_est_un_nombre_positif()
	assert(type(Config.RopeLength) == "number", "RopeLength doit être un nombre")
	assert(Config.RopeLength > 0, "RopeLength doit être positif")
end

function tests.equipe_maximum_de_quatre()
	assert(Config.MaxTeamSize == 4, "MaxTeamSize doit valoir 4")
end

return tests
