local ok, Fluent = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"))()
end)

if not ok or not Fluent then
    print("Fluent NAO carregou:", Fluent)
    return
end

print("Fluent OK, versao:", Fluent.Version)

local W = Fluent:CreateWindow({
    Title = "Teste",
    SubTitle = "",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local T = W:AddTab({ Title = "Teste", Icon = "home" })
T:AddToggle("T1", { Title = "Toggle 1", Default = false })
T:AddToggle("T2", { Title = "Toggle 2", Default = true })
T:AddButton({ Title = "Botao", Callback = function() print("clicou") end })
W:SelectTab(1)
