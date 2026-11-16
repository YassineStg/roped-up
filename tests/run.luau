local process = require("@lune/process")

local suites = {
	require("./example.test"),
}

local passed = 0
local failed = 0

for _, suite in suites do
	for name, fn in suite do
		local ok, err = pcall(fn)
		if ok then
			passed += 1
			print("PASS", name)
		else
			failed += 1
			print("FAIL", name, err)
		end
	end
end

print(`{passed} réussis, {failed} échoués`)

if failed > 0 then
	process.exit(1)
end
