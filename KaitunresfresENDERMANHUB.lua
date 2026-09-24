-- ============================================================
-- CONFIG PADRÃO
-- ============================================================
Config = {
    Team = "Pirates",
    Language = "pt-BR",
    AutoExecute = false,
    Configuration = {
        HopWhenIdle = true,
        AutoHop = true,
        AutoHopDelay = 60,
        FpsBoost = false,
        blackscreen = false,
        LowGraphics = true
    },
    Items = {
        AutoFullyMelees = true,
        Saber = true,
        CursedDualKatana = true,
        SoulGuitar = true,
        RaceV2 = true,
        AutoRaceV3 = true,
        AutoRandomFruit = false,
    },
    Sword = {
        ["Shark Saw"]        = true,
        ["Wardens Sword"]    = true,
        ["Pole (1st Form)"]  = true,
        ["Gravity Blade"]    = true,
        ["Longsword"]        = true,
        ["Rengoku"]          = true,
        ["Flail"]            = true,
        ["Twin Hooks"]       = true,
    },
    BossWeapons = {
        ["Awakened Ice Admiral"] = true,
        ["Tide Keeper"]          = true,
        ["Deandre"]              = true,
        ["Urban"]                = true,
        ["Diablo"]               = true,
        ["Soul Reaper"]          = true,
        ["Cake Prince"]          = true,
        ["Core"]                 = true,
        ["Darkbeard"]            = true,
        ["Katakuri"]             = true,
        ["Beautiful Pirates"]    = true,
    },
    Melee = {
        AutoBuy              = true,
        CheckMasteryAfterBuy = true,
        RaidAtV1Mastery      = 500,
        GodhumanAtV2Mastery  = 400,
    },
    AutoKen = true,
    BringMobs = true,
    PanicMode = {
        Enabled          = true,
        LowHealthPercent = 20,
        SafeHealthPercent = 75,
        EscapeHeight     = 2000,
        CheckInterval    = 1,
    },
    Settings = {
        StayInSea2UntilHaveDarkFragments = true
    },
    AutoSea2 = true,
    AutoSea3 = true,
    AutoRaidIce_TargetFragments = 5000,
}

-- ============================================================
-- SISTEMA DE SALVAR/CARREGAR CONFIG (por conta do Roblox)
-- ============================================================
local HttpService = game:GetService("HttpService")

local function GetConfigPath()
    return "EndermanHub_Config_" .. game.Players.LocalPlayer.Name .. ".json"
end

local function SaveConfig()
    pcall(function()
        writefile(GetConfigPath(), HttpService:JSONEncode(Config))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(GetConfigPath()) then
            local data = HttpService:JSONDecode(readfile(GetConfigPath()))
            for k, v in pairs(data) do
                if type(v) == "table" and type(Config[k]) == "table" then
                    for k2, v2 in pairs(v) do
                        Config[k][k2] = v2
                    end
                else
                    Config[k] = v
                end
            end
        end
    end)
end

LoadConfig()

-- ============================================================
-- SISTEMA DE TRADUÇÃO
-- ============================================================
local Translations = {
    ["en-US"] = {
        main = "Main", items = "Items", swords = "Swords", bosses = "Boss Weapons",
        melee = "Melee & Ken", panic = "Panic Mode", sea = "Sea & Settings",
        uiconfig = "UI Config", exec = "Execution", time = "Team",
        genconfig = "General Config", hopidle = "Hop When Idle", autohop = "Auto Hop",
        hopdelay = "Auto Hop Delay", fps = "FPS Boost", blackscreen = "Blackscreen",
        lowgfx = "Low Graphics", theme = "Theme", transparent = "Transparent",
        togglekey = "Toggle UI Key", language = "Language",
        execKaitun = "Execute Kaitun", autoexec = "Auto Execute on Rejoin",
        save = "Save Config", load = "Load Config", reset = "Reset Config"
    },
    ["vi-VN"] = {
        main = "Chính", items = "Vật Phẩm", swords = "Kiếm", bosses = "Vũ Khí Boss",
        melee = "Cận Chiến & Ken", panic = "Chế Độ Hoảng Loạn", sea = "Biển & Cài Đặt",
        uiconfig = "Cấu Hình UI", exec = "Thực Thi", time = "Phe",
        genconfig = "Cấu Hình Chung", hopidle = "Hop Khi Rảnh", autohop = "Tự Động Hop",
        hopdelay = "Độ Trễ Hop", fps = "Tăng FPS", blackscreen = "Màn Hình Đen",
        lowgfx = "Đồ Họa Thấp", theme = "Chủ Đề", transparent = "Trong Suốt",
        togglekey = "Phím Mở UI", language = "Ngôn Ngữ",
        execKaitun = "Chạy Kaitun", autoexec = "Tự Chạy Khi Vào Lại",
        save = "Lưu Cấu Hình", load = "Tải Cấu Hình", reset = "Đặt Lại"
    },
    ["pt-BR"] = {
        main = "Principal", items = "Itens", swords = "Espadas", bosses = "Armas de Boss",
        melee = "Melee & Ken", panic = "Modo Pânico", sea = "Sea & Ajustes",
        uiconfig = "Config. da UI", exec = "Execução", time = "Time",
        genconfig = "Config. Geral", hopidle = "Hop Quando Ocioso", autohop = "Auto Hop",
        hopdelay = "Delay do Auto Hop", fps = "FPS Boost", blackscreen = "Tela Preta",
        lowgfx = "Gráficos Baixos", theme = "Tema", transparent = "Transparente",
        togglekey = "Tecla de Abrir UI", language = "Idioma",
        execKaitun = "Executar Kaitun", autoexec = "Auto Executar ao Reinjetar",
        save = "Salvar Config", load = "Carregar Config", reset = "Resetar Config"
    },
}

local function T(key)
    local lang = Config.Language or "pt-BR"
    local tbl = Translations[lang] or Translations["pt-BR"]
    return tbl[key] or key
end

-- ============================================================
-- WIND UI
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "EndermanHub Kaitun version",
    Icon = "door-open",
    Author = "[BLOX FRUITS] by jane doe Sigma",
    Folder = "EndermanHub",
    Size = UDim2.fromOffset(520, 480),
    MinSize = Vector2.new(480, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = false,
    ScrollBarEnabled = false,

    Background = "rbxassetid://8176158130",
    BackgroundImageTransparency = 0.5,

    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() print(":3") end,
    },

    KeySystem = {
        Key = { "rpNVYJDO4U7DCEQh", "2vkz0nkSUkb7sbJP", "25VctsNED7CwwP26" },
        Note = "Get the key from the Link Vertise.",
        Thumbnail = {
            Image = "rbxassetid://6003957600",
            Title = "EndermanHub Key (permanent key)",
        },
        URL = "https://discord.gg/SEU_DISCORD_AQUI",
        SaveKey = false,
    },
})

-- ============================================================
-- FUNÇÃO QUE EXECUTA O KAITUN
-- ============================================================
local function ExecuteKaitun()
    SaveConfig()
    WindUI:Notify({
        Title = "Kaitun",
        Content = "Executando Kaitun...",
        Duration = 4,
        Icon = "play",
    })
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Janedoesigma/Endermanhub/main/endermanhubkaitun.lua'))()
    end)
end

-- ============================================================
-- REJOIN / SERVER HOP
-- ============================================================
local function RejoinSameServer()
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end)
end

local function ServerHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId

    local ok, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)

    if ok and result and result.data then
        for _, server in pairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, game.Players.LocalPlayer)
                end)
                return true
            end
        end
    end
    return false
end

local function TryRejoin()
    WindUI:Notify({
        Title = "Kaitun",
        Content = "Reentrando no servidor...",
        Duration = 3,
        Icon = "refresh-cw",
    })

    local teleportFailed = false
    local conn = game:GetService("TeleportService").TeleportInitFailed:Connect(function()
        teleportFailed = true
    end)

    RejoinSameServer()
    task.wait(5)
    pcall(function() conn:Disconnect() end)

    if teleportFailed or game.Players.LocalPlayer.Parent then
        WindUI:Notify({
            Title = "Kaitun",
            Content = "Falha ao reentrar. Procurando outro servidor...",
            Duration = 4,
            Icon = "alert-triangle",
        })
        task.wait(2)
        local tentativas = 0
        while not ServerHop() and tentativas < 10 do
            tentativas = tentativas + 1
            task.wait(3)
        end
    end
end

-- ============================================================
-- ABA: PRINCIPAL
-- ============================================================
local MainTab = Window:Tab({ Title = T("main"), Icon = "home" })

MainTab:Section({ Title = T("time") })
MainTab:Dropdown({
    Title = T("time"),
    Values = { "Pirates", "Marines" },
    Value = Config.Team,
    Callback = function(opt)
        Config.Team = opt
        SaveConfig()
    end
})

MainTab:Section({ Title = T("genconfig") })
MainTab:Toggle({ Title = T("hopidle"), Value = Config.Configuration.HopWhenIdle, Callback = function(v) Config.Configuration.HopWhenIdle = v; SaveConfig() end })
MainTab:Toggle({ Title = T("autohop"), Value = Config.Configuration.AutoHop, Callback = function(v) Config.Configuration.AutoHop = v; SaveConfig() end })
MainTab:Slider({
    Title = T("hopdelay"),
    Value = { Min = 1, Max = 150, Default = Config.Configuration.AutoHopDelay },
    Callback = function(v) Config.Configuration.AutoHopDelay = v; SaveConfig() end
})
MainTab:Toggle({ Title = T("fps"), Value = Config.Configuration.FpsBoost, Callback = function(v) Config.Configuration.FpsBoost = v; SaveConfig() end })
MainTab:Toggle({ Title = T("blackscreen"), Value = Config.Configuration.blackscreen, Callback = function(v) Config.Configuration.blackscreen = v; SaveConfig() end })
MainTab:Toggle({ Title = T("lowgfx"), Value = Config.Configuration.LowGraphics, Callback = function(v) Config.Configuration.LowGraphics = v; SaveConfig() end })

-- ============================================================
-- ABA: ITENS
-- ============================================================
local ItemsTab = Window:Tab({ Title = T("items"), Icon = "package" })

ItemsTab:Toggle({ Title = "Auto Fully Melees", Value = Config.Items.AutoFullyMelees, Callback = function(v) Config.Items.AutoFullyMelees = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Saber", Value = Config.Items.Saber, Callback = function(v) Config.Items.Saber = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Cursed Dual Katana", Value = Config.Items.CursedDualKatana, Callback = function(v) Config.Items.CursedDualKatana = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Soul Guitar", Value = Config.Items.SoulGuitar, Callback = function(v) Config.Items.SoulGuitar = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Race V2", Value = Config.Items.RaceV2, Callback = function(v) Config.Items.RaceV2 = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Auto Race V3", Value = Config.Items.AutoRaceV3, Callback = function(v) Config.Items.AutoRaceV3 = v; SaveConfig() end })
ItemsTab:Toggle({ Title = "Auto Random Fruit", Value = Config.Items.AutoRandomFruit, Callback = function(v) Config.Items.AutoRandomFruit = v; SaveConfig() end })

-- ============================================================
-- ABA: ESPADAS
-- ============================================================
local SwordTab = Window:Tab({ Title = T("swords"), Icon = "sword" })
for name, value in pairs(Config.Sword) do
    SwordTab:Toggle({
        Title = name,
        Value = value,
        Callback = function(v) Config.Sword[name] = v; SaveConfig() end
    })
end

-- ============================================================
-- ABA: BOSS WEAPONS
-- ============================================================
local BossTab = Window:Tab({ Title = T("bosses"), Icon = "skull" })
for name, value in pairs(Config.BossWeapons) do
    BossTab:Toggle({
        Title = name,
        Value = value,
        Callback = function(v) Config.BossWeapons[name] = v; SaveConfig() end
    })
end

-- ============================================================
-- ABA: MELEE & KEN
-- ============================================================
local MeleeTab = Window:Tab({ Title = T("melee"), Icon = "hand" })

MeleeTab:Toggle({ Title = "Auto Buy Melee", Value = Config.Melee.AutoBuy, Callback = function(v) Config.Melee.AutoBuy = v; SaveConfig() end })
MeleeTab:Toggle({ Title = "Check Mastery After Buy", Value = Config.Melee.CheckMasteryAfterBuy, Callback = function(v) Config.Melee.CheckMasteryAfterBuy = v; SaveConfig() end })
MeleeTab:Slider({
    Title = "Raid At V1 Mastery",
    Value = { Min = 0, Max = 600, Default = Config.Melee.RaidAtV1Mastery },
    Callback = function(v) Config.Melee.RaidAtV1Mastery = v; SaveConfig() end
})
MeleeTab:Slider({
    Title = "Godhuman At V2 Mastery",
    Value = { Min = 0, Max = 600, Default = Config.Melee.GodhumanAtV2Mastery },
    Callback = function(v) Config.Melee.GodhumanAtV2Mastery = v; SaveConfig() end
})

MeleeTab:Section({ Title = "Haki" })
MeleeTab:Toggle({ Title = "Auto Ken", Value = Config.AutoKen, Callback = function(v) Config.AutoKen = v; SaveConfig() end })
MeleeTab:Toggle({ Title = "Bring Mobs", Value = Config.BringMobs, Callback = function(v) Config.BringMobs = v; SaveConfig() end })

-- ============================================================
-- ABA: PANIC MODE
-- ============================================================
local PanicTab = Window:Tab({ Title = T("panic"), Icon = "alert-triangle" })

PanicTab:Toggle({ Title = "Ativar Panic Mode", Value = Config.PanicMode.Enabled, Callback = function(v) Config.PanicMode.Enabled = v; SaveConfig() end })
PanicTab:Slider({
    Title = "Low Health Percent (%)",
    Value = { Min = 1, Max = 100, Default = Config.PanicMode.LowHealthPercent },
    Callback = function(v) Config.PanicMode.LowHealthPercent = v; SaveConfig() end
})
PanicTab:Slider({
    Title = "Safe Health Percent (%)",
    Value = { Min = 1, Max = 100, Default = Config.PanicMode.SafeHealthPercent },
    Callback = function(v) Config.PanicMode.SafeHealthPercent = v; SaveConfig() end
})
PanicTab:Slider({
    Title = "Escape Height",
    Value = { Min = 100, Max = 6000, Default = Config.PanicMode.EscapeHeight },
    Callback = function(v) Config.PanicMode.EscapeHeight = v; SaveConfig() end
})
PanicTab:Slider({
    Title = "Check Interval (s)",
    Value = { Min = 1, Max = 6, Default = Config.PanicMode.CheckInterval },
    Callback = function(v) Config.PanicMode.CheckInterval = v; SaveConfig() end
})

-- ============================================================
-- ABA: SEA & SETTINGS
-- ============================================================
local SeaTab = Window:Tab({ Title = T("sea"), Icon = "waves" })

SeaTab:Toggle({
    Title = "Ficar no Sea 2 até ter Dark Fragments",
    Value = Config.Settings.StayInSea2UntilHaveDarkFragments,
    Callback = function(v) Config.Settings.StayInSea2UntilHaveDarkFragments = v; SaveConfig() end
})
SeaTab:Toggle({ Title = "Auto Sea 2", Value = Config.AutoSea2, Callback = function(v) Config.AutoSea2 = v; SaveConfig() end })
SeaTab:Toggle({ Title = "Auto Sea 3", Value = Config.AutoSea3, Callback = function(v) Config.AutoSea3 = v; SaveConfig() end })
SeaTab:Slider({
    Title = "Auto Raid Ice - Meta de Fragments",
    Value = { Min = 0, Max = 20000, Default = Config.AutoRaidIce_TargetFragments },
    Callback = function(v) Config.AutoRaidIce_TargetFragments = v; SaveConfig() end
})

-- ============================================================
-- ABA: UI CONFIG
-- ============================================================
local UIConfigTab = Window:Tab({ Title = T("uiconfig"), Icon = "palette" })

UIConfigTab:Section({ Title = T("language") })
UIConfigTab:Dropdown({
    Title = T("language"),
    Values = { "pt-BR", "en-US", "vi-VN" },
    Value = Config.Language,
    Callback = function(opt)
        Config.Language = opt
        SaveConfig()
        WindUI:Notify({
            Title = "Idioma",
            Content = "Idioma alterado para " .. opt .. ". Reinjete o script para aplicar.",
            Duration = 5,
            Icon = "languages",
        })
    end
})

UIConfigTab:Section({ Title = T("theme") })
UIConfigTab:Dropdown({
    Title = T("theme"),
    Values = (function()
        local names = {}
        for name in pairs(WindUI:GetThemes()) do
            table.insert(names, name)
        end
        table.sort(names)
        return names
    end)(),
    Callback = function(selected)
        WindUI:SetTheme(selected)
    end
})

UIConfigTab:Toggle({
    Title = T("transparent"),
    Value = false,
    Callback = function(state)
        Window:ToggleTransparency(state)
    end
})

UIConfigTab:Keybind({
    Title = T("togglekey"),
    Value = "RightShift",
    Callback = function(v)
        Window:SetToggleKey(Enum.KeyCode[v])
    end
})

-- ============================================================
-- ABA: EXECUTION (Executar Kaitun / Auto Executar)
-- ============================================================
local ExecTab = Window:Tab({ Title = T("exec"), Icon = "play" })

local KaitunExecuted = false
local ExecuteToggle
local AutoExecToggle

ExecuteToggle = ExecTab:Toggle({
    Title = T("execKaitun"),
    Value = false,
    Callback = function(state)
        if not state then return end

        -- Desativa Auto Executar (mutuamente exclusivos)
        if Config.AutoExecute then
            Config.AutoExecute = false
            SaveConfig()
            if AutoExecToggle then
                pcall(function() AutoExecToggle:Set(false) end)
            end
        end

        if not KaitunExecuted then
            KaitunExecuted = true
            ExecuteKaitun()
        else
            TryRejoin()
        end
    end
})

AutoExecToggle = ExecTab:Toggle({
    Title = T("autoexec"),
    Value = Config.AutoExecute,
    Callback = function(state)
        Config.AutoExecute = state
        SaveConfig()

        if state then
            -- Desativa Execute Kaitun (mutuamente exclusivos)
            if ExecuteToggle then
                pcall(function() ExecuteToggle:Set(false) end)
            end
            WindUI:Notify({
                Title = "Auto Execute",
                Content = "Ativado! Na próxima reinjeção o Kaitun vai rodar sozinho.",
                Duration = 5,
                Icon = "zap",
            })
        else
            WindUI:Notify({
                Title = "Auto Execute",
                Content = "Desativado.",
                Duration = 3,
                Icon = "zap",
            })
        end
    end
})

ExecTab:Section({ Title = "Gerenciar Config" })
ExecTab:Button({
    Title = T("save"),
    Desc = "Salvar config atual manualmente",
    Callback = function()
        SaveConfig()
        WindUI:Notify({ Title = "Salvo!", Content = "Config salva com sucesso.", Duration = 3, Icon = "save" })
    end
})
ExecTab:Button({
    Title = T("reset"),
    Desc = "Apagar config salva (volta ao padrão)",
    Callback = function()
        pcall(function()
            if isfile(GetConfigPath()) then
                delfile(GetConfigPath())
            end
        end)
        WindUI:Notify({ Title = "Resetado!", Content = "Config apagada. Reinjete o script.", Duration = 4, Icon = "trash" })
    end
})

-- ============================================================
-- AUTO EXECUTE NO INÍCIO
-- ============================================================
if Config.AutoExecute then
    task.spawn(function()
        task.wait(2)
        ExecuteKaitun()
    end)
end
