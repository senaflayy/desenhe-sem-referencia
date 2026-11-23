
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Economia = require(game:GetService("ServerScriptService"):WaitForChild("Economia"))
local finalizarDesenho = ReplicatedStorage:WaitForChild("FinalizarDesenho")
local revelarDesenhos = ReplicatedStorage:WaitForChild("RevelarDesenhos")

local pastaPares = workspace:WaitForChild("PardeCadeiras")
local estados = {}
local function reiniciarPar(par)
	estados[par] = nil
end

for _, par in ipairs(pastaPares:GetChildren()) do
	if par:IsA("Model") then
		for _, objeto in ipairs(par:GetDescendants()) do
			if objeto:IsA("Seat") then
				objeto:GetPropertyChangedSignal("Occupant"):Connect(function()
					reiniciarPar(par)
				end)
			end
		end
	end
end

local function obterParticipantes(par)
	local participantes = {}

	for _, objeto in ipairs(par:GetDescendants()) do
		if objeto:IsA("Seat") and objeto.Occupant then
			local jogador = Players:GetPlayerFromCharacter(
				objeto.Occupant.Parent
			)

			if jogador then
				table.insert(participantes, jogador)
			end
		end
	end

	return participantes
end


local function obterParDoJogador(jogador)
	local personagem = jogador.Character
	if not personagem then
		warn("Personagem não encontrado: " .. jogador.Name)
		return nil
	end

	local humanoide = personagem:FindFirstChildOfClass("Humanoid")
	if not humanoide then
		warn("Humanoide não encontrado: " .. jogador.Name)
		return nil
	end

	local assento = humanoide.SeatPart
	if not assento then
		warn(jogador.Name .. " não está sentado.")
		return nil
	end

	print("Assento encontrado:", assento:GetFullName())

	-- Sobe pela hierarquia até encontrar o par
	local atual = assento

	while atual and atual.Parent ~= pastaPares do
		atual = atual.Parent
	end

	if atual and atual:IsA("Model") and atual.Parent == pastaPares then
		print("Par encontrado:", atual.Name)
		return atual
	end

	warn("Não consegui encontrar o par de " .. jogador.Name)
	return nil
end


local function mesmoParDeJogadores(estado, participantes)
	if not estado then
		return false
	end

	if #participantes ~= 2 then
		return false
	end

	return estado.participantes[participantes[1]]
		and estado.participantes[participantes[2]]
		and estado.participantes[participantes[1]]
		== estado.participantes[participantes[2]]
end

finalizarDesenho.OnServerEvent:Connect(function(jogador, desenho)
	if typeof(desenho) ~= "table" then
		return
	end
	-- Limita a quantidade de traços recebidos
	if #desenho > 3000 then
		warn("Desenho com traços demais: " .. jogador.Name)
		return
	end

	-- Recusa folhas vazias ou quase vazias
	if #desenho < 15 then
		return
	end

	local par = obterParDoJogador(jogador)
	if not par then
		warn(jogador.Name .. " não está sentado em um par válido.")
		return
	end

	local participantes = obterParticipantes(par)
	
	print("Par:", par.Name)
	print("Quantidade de participantes:", #participantes)
	for _, participante in ipairs(participantes) do
		print("Participante:", participante.Name)
	end
	
	if #participantes ~= 2 then
		warn("A dupla precisa ocupar as duas cadeiras.")
		return
	end

	if participantes[1] == participantes[2] then
		return
	end

	local estado = estados[par]

	if not mesmoParDeJogadores(estado, participantes) then
		estado = {
			participantes = {
				[participantes[1]] = true,
				[participantes[2]] = true
			},
			desenhos = {},
			revelado = false
		}

		estados[par] = estado
	end

	if estado.revelado or estado.desenhos[jogador] then
		return
	end

	-- Guarda o desenho sem enviá-lo ao outro jogador
	estado.desenhos[jogador] = desenho
	print("Desenho recebido de:", jogador.Name)
	print(jogador.Name .. " terminou de desenhar no " .. par.Name)

	local primeiro = participantes[1]
	local segundo = participantes[2]

	if estado.desenhos[primeiro] and estado.desenhos[segundo] then
		estado.revelado = true
		print("Os dois desenhos foram recebidos! Criando revelação...")

		local resultados = {
			{
				nome = primeiro.DisplayName,
				desenho = estado.desenhos[primeiro]
			},
			{
				nome = segundo.DisplayName,
				desenho = estado.desenhos[segundo]
			}
		}

		-- Envia os dois desenhos somente aos integrantes da dupla
		for _, participante in ipairs(participantes) do
			revelarDesenhos:FireClient(participante, resultados)
		end

		-- Dá as moedas da rodada
		for _, participante in ipairs(participantes) do
			Economia.darMoedas(participante, Economia.MOEDAS_POR_RODADA)
		end

		estados[par] = nil

		print("Os dois desenhos foram liberados no " .. par.Name)
	end
end)

Players.PlayerRemoving:Connect(function(jogador)
	for par, estado in pairs(estados) do
		if estado.participantes[jogador] then
			estados[par] = nil
		end
	end
end)

print("SistemaDesafio iniciado!")