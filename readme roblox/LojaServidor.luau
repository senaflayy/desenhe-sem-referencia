local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Economia = require(ServerScriptService:WaitForChild("Economia"))
local Catalogo = require(ReplicatedStorage:WaitForChild("CatalogoLoja"))

local comprarItem = ReplicatedStorage:WaitForChild("ComprarItem")
local equiparItem = ReplicatedStorage:WaitForChild("EquiparItem")
local dadosLoja = ReplicatedStorage:WaitForChild("DadosLoja")

local TIPOS = { moldura = true, fundo = true, musica = true }

dadosLoja.OnServerInvoke = function(jogador)
	local d = Economia.obter(jogador)
	if not d or not d.carregado then
		return nil
	end

	return {
		moedas = d.moedas,
		itens = d.itens,
		equipados = d.equipados
	}
end

comprarItem.OnServerInvoke = function(jogador, idItem)
	if typeof(idItem) ~= "string" then
		return false, "Item inválido."
	end

	local item = Catalogo.obter(idItem)
	if not item then
		return false, "Item não existe."
	end

	local d = Economia.obter(jogador)
	if not d or not d.carregado then
		return false, "Seus dados ainda estão carregando."
	end

	if d.itens[idItem] then
		return false, "Você já tem esse item."
	end

	if not item.moedas then
		return false, "Esse item só pode ser comprado com Robux."
	end

	if not Economia.gastarMoedas(jogador, item.moedas) then
		return false, "Moedas insuficientes."
	end

	d.itens[idItem] = true
	return true, "Comprado!"
end

-- idItem = nil desequipa aquele tipo
equiparItem.OnServerInvoke = function(jogador, tipo, idItem)
	if typeof(tipo) ~= "string" or not TIPOS[tipo] then
		return false
	end

	local d = Economia.obter(jogador)
	if not d or not d.carregado then
		return false
	end

	if idItem == nil then
		d.equipados[tipo] = nil
		return true
	end

	if typeof(idItem) ~= "string" then
		return false
	end

	local item = Catalogo.obter(idItem)
	if not item or item.tipo ~= tipo or not d.itens[idItem] then
		return false
	end

	d.equipados[tipo] = idItem
	return true
end

print("LojaServidor iniciado!")