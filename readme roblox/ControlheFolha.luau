
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jogador = Players.LocalPlayer
local playerGui = jogador:WaitForChild("PlayerGui")

local interface = playerGui:WaitForChild("InterfaceDesenho")
local folha = interface:WaitForChild("FolhaDesenho")
local abrirFolha = ReplicatedStorage:WaitForChild("AbrirFolha")

-- Começa com a interface fechada
interface.Enabled = false

abrirFolha.OnClientEvent:Connect(function(abrir, nomePar)
	if abrir then
		interface.Enabled = true
		folha.Visible = true

		print("Folha aberta no par: " .. nomePar)
	else
		interface.Enabled = false

		print("Folha fechada")
	end
end)