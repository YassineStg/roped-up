-- Affiche à l'écran les annonces envoyées par le serveur ("Checkpoint atteint !").

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local joueur = Players.LocalPlayer
local annonce = ReplicatedStorage:WaitForChild("Annonce")

local ecran = Instance.new("ScreenGui")
ecran.Name = "Annonces"
ecran.ResetOnSpawn = false
ecran.Parent = joueur:WaitForChild("PlayerGui")

local texte = Instance.new("TextLabel")
texte.Name = "Texte"
texte.AnchorPoint = Vector2.new(0.5, 0)
texte.Position = UDim2.fromScale(0.5, 0.12)
texte.Size = UDim2.fromOffset(520, 56)
texte.BackgroundTransparency = 1
texte.Font = Enum.Font.GothamBlack
texte.TextScaled = true
texte.TextColor3 = Color3.fromRGB(255, 220, 90)
texte.TextStrokeTransparency = 0
texte.Visible = false
texte.Parent = ecran

local numero = 0

annonce.OnClientEvent:Connect(function(message)
	numero += 1
	local moi = numero

	texte.Text = tostring(message)
	texte.Visible = true

	task.delay(2.5, function()
		-- une annonce plus récente garde le texte affiché
		if moi == numero then
			texte.Visible = false
		end
	end)
end)
