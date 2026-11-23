
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local duplaDesfeita = ReplicatedStorage:WaitForChild("DuplaDesfeita")
local pasta = workspace:WaitForChild("PardeCadeiras")
local abrirFolha = ReplicatedStorage:WaitForChild("AbrirFolha")
local temaDupla = ReplicatedStorage:WaitForChild("TemaDupla")

local temas = {
	"Bob Esponja", "Patrick Estrela", "Stitch",
	"Hello Kitty", "Kuromi", "Pikachu", "Eevee",
	"Scooby-Doo", "Tom e Jerry", "Shrek", "Pica-Pau",
	"Peppa Pig", "Homer Simpson", "Finn e Jake",
	"Banguela", "Po de Kung Fu Panda",
	"Relâmpago McQueen", "Minion", "Elsa", "Olaf",
	"Mickey Mouse", "Sonic", "Mario", "Kirby",
	"Naruto", "Totoro", "Gato", "Cachorro",
	"Dragão", "Flor", "Robô", "Fantasma"
}

local temasPorPar = {}
local paresAtivos = {}

local function atualizarPar(par)
	local assentos = {}

	for _, objeto in ipairs(par:GetDescendants()) do
		if objeto:IsA("Seat") then
			table.insert(assentos, objeto)
		end
	end

	local jogadores = {}

	for _, assento in ipairs(assentos) do
		local ocupante = assento.Occupant

		if ocupante then
			local jogador = Players:GetPlayerFromCharacter(
				ocupante.Parent
			)

			if jogador then
				table.insert(jogadores, jogador)
			end
		end
	end

	local anterior = paresAtivos[par] or {}
	local novo = {}

	if #jogadores == 2 and jogadores[1] ~= jogadores[2] then
		novo[jogadores[1]] = true
		novo[jogadores[2]] = true

		if not temasPorPar[par] then
			temasPorPar[par] = temas[math.random(1, #temas)]
		end

		local tema = temasPorPar[par]

		par:SetAttribute("TemaAtual", tema)

		for _, jogador in ipairs(jogadores) do
			if not anterior[jogador] then
				abrirFolha:FireClient(jogador, true, par.Name)
			end
		end

		task.delay(0.5, function()
			for _, jogador in ipairs(jogadores) do
				if jogador.Parent == Players then
					temaDupla:FireClient(jogador, tema)
				end
			end
		end)
	end

	for jogador in pairs(anterior) do
		if not novo[jogador] then
			abrirFolha:FireClient(jogador, false, par.Name)
			if jogador.Parent == Players then
				duplaDesfeita:FireClient(jogador)
			end
		end
	end

	-- dupla desfeita: descarta o tema para a próxima rodada sortear outro
	if #jogadores < 2 then
		temasPorPar[par] = nil
		par:SetAttribute("TemaAtual", nil)
	end

	paresAtivos[par] = novo
end

for _, par in ipairs(pasta:GetChildren()) do
	if par:IsA("Model") then
		for _, objeto in ipairs(par:GetDescendants()) do
			if objeto:IsA("Seat") then
				objeto:GetPropertyChangedSignal("Occupant"):Connect(
					function()
						atualizarPar(par)
					end
				)
			end
		end
	end
end

print("Sistema de assentos iniciado!")

