local Lighting = game:GetService("Lighting")

Lighting.ClockTime = 15
Lighting.Brightness = 2.5
Lighting.Ambient = Color3.fromRGB(120, 120, 140)
Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 170)
Lighting.ColorShift_Top = Color3.fromRGB(255, 240, 220)

local function criar(classe, props)
	local existente = Lighting:FindFirstChildOfClass(classe)
	if existente then
		existente:Destroy()
	end

	local inst = Instance.new(classe)
	for nome, valor in pairs(props) do
		inst[nome] = valor
	end
	inst.Parent = Lighting
end

criar("Atmosphere", {
	Density = 0.25,
	Offset = 0.25,
	Color = Color3.fromRGB(199, 215, 255),
	Decay = Color3.fromRGB(255, 214, 230),
	Glare = 0.2,
	Haze = 1
})

criar("BloomEffect", {Intensity = 0.4, Size = 24, Threshold = 1.2})

criar("ColorCorrectionEffect", {
	Saturation = 0.25,
	Contrast = 0.1,
	TintColor = Color3.fromRGB(255, 245, 250)
})

criar("SunRaysEffect", {Intensity = 0.08, Spread = 0.6})