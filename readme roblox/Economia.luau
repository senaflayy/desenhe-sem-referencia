local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local armazem = DataStoreService:GetDataStore("DadosJogador_v1")

local Economia = {}
Economia.MOEDAS_POR_RODADA = 50


local dados = {}

local function chave(jogador)
	return "jogador_" .. jogador.UserId
end

local function carregar(jogador)
	if dados[jogador] then
		return
	end

	local d = {
		moedas = 0,
		itens = {},
		equipados = {},
		carregado = false
	}
	dados[jogador] = d

	local ok, resultado = pcall(function()
		return armazem:GetAsync(chave(jogador))
	end)

	if ok then
		if typeof(resultado) == "table" then
			d.moedas = resultado.moedas or 0
			d.itens = resultado.itens or {}
			d.equipados = resultado.equipados or {}
		end
		d.carregado = true
	else
		warn("Falha ao carregar dados de " .. jogador.Name .. ": " .. tostring(resultado))
	end

	if jogador.Parent ~= Players then
		return
	end

	local pasta = Instance.new("Folder")
	pasta.Name = "leaderstats"
	pasta.Parent = jogador

	local moedas = Instance.new("IntValue")
	moedas.Name = "Moedas"
	moedas.Value = d.moedas
	moedas.Parent = pasta
end

local function salvar(jogador)
	local d = dados[jogador]

	-- se o carregamento falhou, não salva, para não apagar o progresso antigo
	if not d or not d.carregado then
		return
	end

	local ok, erro = pcall(function()
		armazem:SetAsync(chave(jogador), {
			moedas = d.moedas,
			itens = d.itens,
			equipados = d.equipados
		})
	end)

	if not ok then
		warn("Falha ao salvar dados de " .. jogador.Name .. ": " .. tostring(erro))
	end
end

function Economia.obter(jogador)
	return dados[jogador]
end

function Economia.darMoedas(jogador, quantidade)
	local d = dados[jogador]
	if not d then
		return
	end

	d.moedas += quantidade

	local pasta = jogador:FindFirstChild("leaderstats")
	local valor = pasta and pasta:FindFirstChild("Moedas")
	if valor then
		valor.Value = d.moedas
	end
end

function Economia.gastarMoedas(jogador, quantidade)
	local d = dados[jogador]
	if not d or d.moedas < quantidade then
		return false
	end

	d.moedas -= quantidade

	local pasta = jogador:FindFirstChild("leaderstats")
	local valor = pasta and pasta:FindFirstChild("Moedas")
	if valor then
		valor.Value = d.moedas
	end

	return true
end

Players.PlayerAdded:Connect(carregar)

for _, jogador in ipairs(Players:GetPlayers()) do
	task.spawn(carregar, jogador)
end

Players.PlayerRemoving:Connect(function(jogador)
	salvar(jogador)
	dados[jogador] = nil
end)

game:BindToClose(function()
	for _, jogador in ipairs(Players:GetPlayers()) do
		salvar(jogador)
	end
end)

-- salvamento automático a cada 2 minutos
task.spawn(function()
	while true do
		task.wait(120)
		for _, jogador in ipairs(Players:GetPlayers()) do
			salvar(jogador)
		end
	end
end)

return Economia