-- ============================================================
-- DEFAULTS
-- ============================================================
local function GetDefaultConfig()
    return {
        Team = "Pirates", Language = "pt-BR", AutoExecute = false,
        MultiHitM1 = true, SuperFixLag = false,
        Configuration = { HopWhenIdle=false, AutoHop=false, AutoHopDelay=60, FpsBoost=false, blackscreen=false, LowGraphics=false },
        Items = { AutoFullyMelees=false, Saber=false, CursedDualKatana=false, SoulGuitar=false, RaceV2=false, AutoRaceV3=false, AutoRandomFruit=false },
        Sword = { ["Shark Saw"]=false, ["Wardens Sword"]=false, ["Pole (1st Form)"]=false, ["Gravity Blade"]=false, ["Longsword"]=false, ["Rengoku"]=false, ["Flail"]=false, ["Twin Hooks"]=false },
        BossWeapons = { ["Awakened Ice Admiral"]=false, ["Tide Keeper"]=false, ["Deandre"]=false, ["Urban"]=false, ["Diablo"]=false, ["Soul Reaper"]=false, ["Cake Prince"]=false, ["Core"]=false, ["Darkbeard"]=false, ["Katakuri"]=false, ["Beautiful Pirates"]=false },
        Melee = { AutoBuy=false, CheckMasteryAfterBuy=false, RaidAtV1Mastery=500, GodhumanAtV2Mastery=400 },
        AutoKen = false, BringMobs = false,
        PanicMode = { Enabled=false, LowHealthPercent=20, SafeHealthPercent=75, EscapeHeight=2000, CheckInterval=1 },
        Settings = { StayInSea2UntilHaveDarkFragments = false },
        AutoSea2 = false, AutoSea3 = false, AutoRaidIce_TargetFragments = 5000,
    }
end

Config = GetDefaultConfig()

-- ============================================================
-- SAVE / LOAD
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
                    for k2, v2 in pairs(v) do Config[k][k2] = v2 end
                else
                    Config[k] = v
                end
            end
        end
    end)
end

LoadConfig()

-- ============================================================
-- TRADUÇÕES COMPLETAS
-- ============================================================
local Translations = {
    ["en-US"] = {
        -- Tabs
        main="Main", items="Items", swords="Swords", bosses="Boss Weapons",
        melee="Melee & Ken", panic="Panic Mode", sea="Sea & Settings",
        opt="Optimization", uiconfig="UI Config", exec="Execution",
        -- Sections
        time="Team", genconfig="General Config", haki="Haki",
        extras="Extras", managecfg="Manage Config",
        -- Window
        window_title="EndermanHub Kaitun version",
        window_author="[BLOX FRUITS] by jane doe Sigma",
        -- Titles
        hopidle="Hop When Idle", autohop="Auto Hop", hopdelay="Auto Hop Delay",
        fps="FPS Boost", blackscreen="Blackscreen", lowgfx="Low Graphics",
        autobuy="Auto Buy Melee", checkmastery="Check Mastery After Buy",
        raidv1="Raid At V1 Mastery", godhumanv2="Godhuman At V2 Mastery",
        autoken="Auto Ken", bringmobs="Bring Mobs",
        panicenable="Enable Panic Mode", lowhp="Low Health Percent (%)",
        safehp="Safe Health Percent (%)", escapeh="Escape Height",
        checkint="Check Interval (s)",
        staysea2="Stay in Sea 2 until Dark Fragments",
        autosea2="Auto Sea 2", autosea3="Auto Sea 3",
        raidice="Auto Raid Ice - Fragments Target",
        superfix="Super Fix Lag", superfixdesc="Removes fog, hides players and parts to reduce lag",
        restore="Restore Normal", restoredesc="Reset all visual modifications to default",
        execKaitun="Execute Kaitun", autoexec="Auto Execute on Rejoin",
        multihit="Multi Hit M1 (Beta)", multihitdesc="Hits up to 2 nearby mobs per swing",
        redeem="Redeem All Codes", redeemdesc="Redeem every working Blox Fruits code",
        save="Save Config", savedesc="Manually save current config",
        reset="Reset Config", resetdesc="Delete saved config (rejoin to apply)",
        language="Language", theme="Theme", transparent="Transparent",
        togglekey="Toggle UI Key",
        -- Notif titles
        nt_kaitun="Kaitun", nt_codes="Codes", nt_autoexec="Auto Execute",
        nt_restore="Restore", nt_multihit="Multi Hit", nt_lang="Language",
        nt_save="Saved", nt_reset="Reset",
        -- Notif contents
        kaitunexec="Executing Kaitun...", rejoinmsg="Rejoining server...",
        rejoinfail="Rejoin failed. Searching for another server...",
        autoexec_on="Enabled! Kaitun will run alone on next inject.",
        autoexec_off="Disabled.",
        redeem_start="Redeeming codes...",
        redeem_done="Codes sent! Check chat for rewards.",
        save_done="Config saved successfully.",
        reset_done="Config deleted. Reinject the script.",
        restore_done="Everything restored to normal!",
        superfix_on="Super Fix Lag ENABLED",
        superfix_off="Super Fix Lag DISABLED",
        multihit_on="Enabled!", multihit_off="Disabled.",
        lang_notify="Language changed to %s. Reinject to apply.",
    },
    ["vi-VN"] = {
        main="Chính", items="Vật Phẩm", swords="Kiếm", bosses="Vũ Khí Boss",
        melee="Cận Chiến & Ken", panic="Chế Độ Hoảng Loạn", sea="Biển & Cài Đặt",
        opt="Tối Ưu Hóa", uiconfig="Cấu Hình UI", exec="Thực Thi",
        time="Phe", genconfig="Cấu Hình Chung", haki="Haki",
        extras="Bổ Sung", managecfg="Quản Lý Cấu Hình",
        window_title="EndermanHub Kaitun version",
        window_author="[BLOX FRUITS] bởi jane doe Sigma",
        hopidle="Hop Khi Rảnh", autohop="Tự Động Hop", hopdelay="Độ Trễ Hop",
        fps="Tăng FPS", blackscreen="Màn Hình Đen", lowgfx="Đồ Họa Thấp",
        autobuy="Tự Mua Cận Chiến", checkmastery="Kiểm Tra Mastery Sau Khi Mua",
        raidv1="Raid Khi V1 Mastery", godhumanv2="Godhuman Khi V2 Mastery",
        autoken="Tự Động Ken", bringmobs="Kéo Mobs",
        panicenable="Bật Chế Độ Hoảng Loạn", lowhp="Máu Thấp (%)",
        safehp="Máu An Toàn (%)", escapeh="Độ Cao Trốn",
        checkint="Khoảng Kiểm Tra (s)",
        staysea2="Ở Biển 2 Đến Khi Có Dark Fragments",
        autosea2="Tự Động Biển 2", autosea3="Tự Động Biển 3",
        raidice="Auto Raid Ice - Mục Tiêu Fragments",
        superfix="Siêu Fix Lag", superfixdesc="Xóa sương mù, ẩn người chơi và các bộ phận để giảm lag",
        restore="Khôi Phục Bình Thường", restoredesc="Đặt lại mọi thay đổi hình ảnh về mặc định",
        execKaitun="Chạy Kaitun", autoexec="Tự Chạy Khi Vào Lại",
        multihit="Multi Hit M1 (Beta)", multihitdesc="Đánh tối đa 2 mob gần đó mỗi lần chém",
        redeem="Nhập Tất Cả Code", redeemdesc="Nhập mọi code Blox Fruits còn hoạt động",
        save="Lưu Cấu Hình", savedesc="Lưu cấu hình hiện tại thủ công",
        reset="Đặt Lại Cấu Hình", resetdesc="Xóa cấu hình đã lưu (vào lại để áp dụng)",
        language="Ngôn Ngữ", theme="Chủ Đề", transparent="Trong Suốt",
        togglekey="Phím Mở UI",
        nt_kaitun="Kaitun", nt_codes="Code", nt_autoexec="Tự Chạy",
        nt_restore="Khôi Phục", nt_multihit="Multi Hit", nt_lang="Ngôn Ngữ",
        nt_save="Đã Lưu", nt_reset="Đặt Lại",
        kaitunexec="Đang chạy Kaitun...", rejoinmsg="Đang vào lại server...",
        rejoinfail="Vào lại thất bại. Đang tìm server khác...",
        autoexec_on="Đã bật! Kaitun sẽ tự chạy khi tiêm lại.",
        autoexec_off="Đã tắt.",
        redeem_start="Đang nhập code...",
        redeem_done="Đã gửi code! Kiểm tra chat.",
        save_done="Đã lưu cấu hình.",
        reset_done="Đã xóa cấu hình. Tiêm lại script.",
        restore_done="Đã khôi phục mọi thứ!",
        superfix_on="Siêu Fix Lag ĐÃ BẬT",
        superfix_off="Siêu Fix Lag ĐÃ TẮT",
        multihit_on="Đã bật!", multihit_off="Đã tắt.",
        lang_notify="Đã đổi ngôn ngữ sang %s. Tiêm lại để áp dụng.",
    },
    ["pt-BR"] = {
        main="Principal", items="Itens", swords="Espadas", bosses="Armas de Boss",
        melee="Melee & Ken", panic="Modo Pânico", sea="Sea & Ajustes",
        opt="Otimização", uiconfig="Config. da UI", exec="Execução",
        time="Time", genconfig="Config. Geral", haki="Haki",
        extras="Extras", managecfg="Gerenciar Config",
        window_title="EndermanHub Kaitun version",
        window_author="[BLOX FRUITS] por jane doe Sigma",
        hopidle="Hop Quando Ocioso", autohop="Auto Hop", hopdelay="Delay do Auto Hop",
        fps="FPS Boost", blackscreen="Tela Preta", lowgfx="Gráficos Baixos",
        autobuy="Auto Comprar Melee", checkmastery="Checar Mastery Após Compra",
        raidv1="Raid em V1 Mastery", godhumanv2="Godhuman em V2 Mastery",
        autoken="Auto Ken", bringmobs="Trazer Mobs",
        panicenable="Ativar Modo Pânico", lowhp="Vida Baixa (%)",
        safehp="Vida Segura (%)", escapeh="Altura de Fuga",
        checkint="Intervalo de Checagem (s)",
        staysea2="Ficar no Sea 2 até ter Dark Fragments",
        autosea2="Auto Sea 2", autosea3="Auto Sea 3",
        raidice="Auto Raid Ice - Meta de Fragments",
        superfix="Super Fix Lag", superfixdesc="Remove neblina, esconde players e partes pra reduzir lag",
        restore="Voltar Tudo ao Normal", restoredesc="Restaura todas as modificações visuais ao padrão",
        execKaitun="Executar Kaitun", autoexec="Auto Executar ao Reinjetar",
        multihit="Multi Hit M1 (Beta)", multihitdesc="Atinge até 2 mobs próximos por golpe",
        redeem="Pegar Todos os Códigos", redeemdesc="Resgata todos os códigos ativos do Blox Fruits",
        save="Salvar Config", savedesc="Salvar config atual manualmente",
        reset="Resetar Config", resetdesc="Apagar config salva (reentre para aplicar)",
        language="Idioma", theme="Tema", transparent="Transparente",
        togglekey="Tecla de Abrir UI",
        nt_kaitun="Kaitun", nt_codes="Códigos", nt_autoexec="Auto Executar",
        nt_restore="Restaurar", nt_multihit="Multi Hit", nt_lang="Idioma",
        nt_save="Salvo", nt_reset="Resetado",
        kaitunexec="Executando Kaitun...", rejoinmsg="Reentrando no servidor...",
        rejoinfail="Falha ao reentrar. Procurando outro servidor...",
        autoexec_on="Ativado! Kaitun vai rodar sozinho ao reinjetar.",
        autoexec_off="Desativado.",
        redeem_start="Resgatando códigos...",
        redeem_done="Códigos enviados! Veja o chat.",
        save_done="Config salva com sucesso.",
        reset_done="Config apagada. Reinjete o script.",
        restore_done="Tudo restaurado ao normal!",
        superfix_on="Super Fix Lag ATIVADO",
        superfix_off="Super Fix Lag DESATIVADO",
        multihit_on="Ativado!", multihit_off="Desativado.",
        lang_notify="Idioma alterado para %s. Reinjete para aplicar.",
    },
}

local function T(key)
    local tbl = Translations[Config.Language] or Translations["pt-BR"]
    return tbl[key] or key
end

local function TF(key, ...) return string.format(T(key), ...) end

-- ============================================================
-- WIND UI
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = T("window_title"),
    Icon = "door-open",
    Author = T("window_author"),
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
    User = { Enabled = true, Anonymous = false, Callback = function() print(":3") end },
    KeySystem = {
        Key = { "rpNVYJDO4U7DCEQh", "2vkz0nkSUkb7sbJP", "25VctsNED7CwwP26" },
        Note = "Get the key from the Link Vertise.",
        Thumbnail = { Image = "rbxassetid://6003957600", Title = "EndermanHub Key (permanent key)" },
        URL = "https://discord.gg/SEU_DISCORD_AQUI",
        SaveKey = false,
    },
})

-- ============================================================
-- KAITUN
-- ============================================================
local function ExecuteKaitun()
    SaveConfig()
    WindUI:Notify({ Title = T("nt_kaitun"), Content = T("kaitunexec"), Duration = 4, Icon = "play" })
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Janedoesigma/Endermanhub/main/endermanhubkaitun.lua'))()
    end)
end

local function RejoinSameServer()
    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end)
end

local function ServerHop()
    local ok, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and result and result.data then
        for _, server in pairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                pcall(function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                end)
                return true
            end
        end
    end
    return false
end

local function TryRejoin()
    WindUI:Notify({ Title = T("nt_kaitun"), Content = T("rejoinmsg"), Duration = 3, Icon = "refresh-cw" })
    local teleportFailed = false
    local conn = game:GetService("TeleportService").TeleportInitFailed:Connect(function() teleportFailed = true end)
    RejoinSameServer()
    task.wait(5)
    pcall(function() conn:Disconnect() end)
    if teleportFailed or game.Players.LocalPlayer.Parent then
        WindUI:Notify({ Title = T("nt_kaitun"), Content = T("rejoinfail"), Duration = 4, Icon = "alert-triangle" })
        task.wait(2)
        local t = 0
        while not ServerHop() and t < 10 do t = t + 1; task.wait(3) end
    end
end

-- ============================================================
-- REDEEM
-- ============================================================
local function RedeemAllCodes()
    WindUI:Notify({ Title = T("nt_codes"), Content = T("redeem_start"), Duration = 3, Icon = "gift" })
    task.spawn(function()
        local Redeem = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Redeem")
        local codes = {
            "EASTEREXP","LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","kittgaming",
            "DRAGONABUSE","Sub2CaptainMaui","CODE_SERVICIO","DEVSCOOKING","Sub2Fer999",
            "Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy",
            "SUB2GAMERROBOT_EXP1","THEGREATACE","Axiore","TantaiGaming","STRAWHATMAINE",
            "SUB2NOOBMASTER123","Sub2Daigrock","Sub2OfficialNoobie","KITT_RESET","SUB2GAMERROBOT_RESET1",
            "SUB2UNCLEKIZARU","FUDD10","FUDD10_V2","CHANDLER","BIGNEWS"
        }
        for _, code in ipairs(codes) do
            pcall(function() Redeem:InvokeServer(code) end)
            task.wait(0.25)
        end
        WindUI:Notify({ Title = T("nt_codes"), Content = T("redeem_done"), Duration = 4, Icon = "check" })
    end)
end

-- ============================================================
-- MULTI HIT
-- ============================================================
local MultiHitRunning = false
local MultiHitThread = nil

local function StartMultiHit()
    if MultiHitRunning then return end
    MultiHitRunning = true
    MultiHitThread = task.spawn(function()
        local player = game.Players.LocalPlayer
        local enemies = workspace:WaitForChild("Enemies")
        while MultiHitRunning do
            task.wait()
            pcall(function()
                local character = player.Character
                if not character then return end
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then return end
                local targets = {}
                for _, mob in pairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local d = (root.Position - hrp.Position).Magnitude
                        if d <= 60 then table.insert(targets, { part = hrp, distance = d }) end
                    end
                end
                table.sort(targets, function(a,b) return a.distance < b.distance end)
                if #targets > 0 then
                    local attackId = tostring(math.random(100000, 999999))
                    local Net = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net")
                    Net:WaitForChild("RE/RegisterAttack"):FireServer(0.1)
                    Net:WaitForChild("RE/RegisterHit"):FireServer(targets[1].part, {}, nil, attackId)
                    if targets[2] then
                        Net:WaitForChild("RE/RegisterHit"):FireServer(targets[2].part, {}, nil, attackId)
                    end
                end
            end)
        end
    end)
end

local function StopMultiHit()
    MultiHitRunning = false
    if MultiHitThread then
        pcall(function() task.cancel(MultiHitThread) end)
        MultiHitThread = nil
    end
end

-- ============================================================
-- SUPER FIX LAG
-- ============================================================
local SuperFixRunning = false
local OriginalFogStart, OriginalFogEnd = nil, nil
local SuperFixThread = nil

local function StartSuperFixLag()
    if SuperFixRunning then return end
    SuperFixRunning = true
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    if OriginalFogStart == nil then OriginalFogStart = Lighting.FogStart end
    if OriginalFogEnd == nil then OriginalFogEnd = Lighting.FogEnd end
    Lighting.FogStart = 0
    Lighting.FogEnd = 1000000
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then pcall(function() obj.LocalTransparencyModifier = 1 end) end
    end
    SuperFixThread = task.spawn(function()
        while SuperFixRunning do
            task.wait(1)
            pcall(function()
                Lighting.FogStart = 0
                Lighting.FogEnd = 1000000
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then obj.LocalTransparencyModifier = 1 end
                end
            end)
        end
    end)
end

local function StopSuperFixLag()
    SuperFixRunning = false
    if SuperFixThread then
        pcall(function() task.cancel(SuperFixThread) end)
        SuperFixThread = nil
    end
    local Lighting = game:GetService("Lighting")
    Lighting.FogStart = OriginalFogStart or 0
    Lighting.FogEnd = OriginalFogEnd or 100000
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("BasePart") then pcall(function() obj.LocalTransparencyModifier = 0 end) end
    end
end

local function RestoreEverything()
    StopMultiHit()
    StopSuperFixLag()
    local Lighting = game:GetService("Lighting")
    Lighting.FogStart = OriginalFogStart or 0
    Lighting.FogEnd = OriginalFogEnd or 100000
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("BasePart") then pcall(function() obj.LocalTransparencyModifier = 0 end) end
    end
    WindUI:Notify({ Title = T("nt_restore"), Content = T("restore_done"), Duration = 4, Icon = "check-circle" })
end

-- ============================================================
-- ABA PRINCIPAL
-- ============================================================
local MainTab = Window:Tab({ Title = T("main"), Icon = "home" })
MainTab:Section({ Title = T("time") })
MainTab:Dropdown({ Title = T("time"), Values = { "Pirates", "Marines" }, Value = Config.Team,
    Callback = function(opt) Config.Team = opt; SaveConfig() end })
MainTab:Section({ Title = T("genconfig") })
MainTab:Toggle({ Title = T("hopidle"), Value = Config.Configuration.HopWhenIdle, Callback = function(v) Config.Configuration.HopWhenIdle = v; SaveConfig() end })
MainTab:Toggle({ Title = T("autohop"), Value = Config.Configuration.AutoHop, Callback = function(v) Config.Configuration.AutoHop = v; SaveConfig() end })
MainTab:Slider({ Title = T("hopdelay"), Value = { Min = 1, Max = 150, Default = Config.Configuration.AutoHopDelay }, Callback = function(v) Config.Configuration.AutoHopDelay = v; SaveConfig() end })
MainTab:Toggle({ Title = T("fps"), Value = Config.Configuration.FpsBoost, Callback = function(v) Config.Configuration.FpsBoost = v; SaveConfig() end })
MainTab:Toggle({ Title = T("blackscreen"), Value = Config.Configuration.blackscreen, Callback = function(v) Config.Configuration.blackscreen = v; SaveConfig() end })
MainTab:Toggle({ Title = T("lowgfx"), Value = Config.Configuration.LowGraphics, Callback = function(v) Config.Configuration.LowGraphics = v; SaveConfig() end })

-- ============================================================
-- ABA ITENS
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
-- ABA ESPADAS
-- ============================================================
local SwordTab = Window:Tab({ Title = T("swords"), Icon = "sword" })
for name, value in pairs(Config.Sword) do
    SwordTab:Toggle({ Title = name, Value = value, Callback = function(v) Config.Sword[name] = v; SaveConfig() end })
end

-- ============================================================
-- ABA BOSS WEAPONS
-- ============================================================
local BossTab = Window:Tab({ Title = T("bosses"), Icon = "skull" })
for name, value in pairs(Config.BossWeapons) do
    BossTab:Toggle({ Title = name, Value = value, Callback = function(v) Config.BossWeapons[name] = v; SaveConfig() end })
end

-- ============================================================
-- ABA MELEE & KEN
-- ============================================================
local MeleeTab = Window:Tab({ Title = T("melee"), Icon = "hand" })
MeleeTab:Toggle({ Title = T("autobuy"), Value = Config.Melee.AutoBuy, Callback = function(v) Config.Melee.AutoBuy = v; SaveConfig() end })
MeleeTab:Toggle({ Title = T("checkmastery"), Value = Config.Melee.CheckMasteryAfterBuy, Callback = function(v) Config.Melee.CheckMasteryAfterBuy = v; SaveConfig() end })
MeleeTab:Slider({ Title = T("raidv1"), Value = { Min = 0, Max = 600, Default = Config.Melee.RaidAtV1Mastery }, Callback = function(v) Config.Melee.RaidAtV1Mastery = v; SaveConfig() end })
MeleeTab:Slider({ Title = T("godhumanv2"), Value = { Min = 0, Max = 600, Default = Config.Melee.GodhumanAtV2Mastery }, Callback = function(v) Config.Melee.GodhumanAtV2Mastery = v; SaveConfig() end })
MeleeTab:Section({ Title = T("haki") })
MeleeTab:Toggle({ Title = T("autoken"), Value = Config.AutoKen, Callback = function(v) Config.AutoKen = v; SaveConfig() end })
MeleeTab:Toggle({ Title = T("bringmobs"), Value = Config.BringMobs, Callback = function(v) Config.BringMobs = v; SaveConfig() end })

-- ============================================================
-- ABA PANIC
-- ============================================================
local PanicTab = Window:Tab({ Title = T("panic"), Icon = "alert-triangle" })
PanicTab:Toggle({ Title = T("panicenable"), Value = Config.PanicMode.Enabled, Callback = function(v) Config.PanicMode.Enabled = v; SaveConfig() end })
PanicTab:Slider({ Title = T("lowhp"), Value = { Min = 1, Max = 100, Default = Config.PanicMode.LowHealthPercent }, Callback = function(v) Config.PanicMode.LowHealthPercent = v; SaveConfig() end })
PanicTab:Slider({ Title = T("safehp"), Value = { Min = 1, Max = 100, Default = Config.PanicMode.SafeHealthPercent }, Callback = function(v) Config.PanicMode.SafeHealthPercent = v; SaveConfig() end })
PanicTab:Slider({ Title = T("escapeh"), Value = { Min = 100, Max = 6000, Default = Config.PanicMode.EscapeHeight }, Callback = function(v) Config.PanicMode.EscapeHeight = v; SaveConfig() end })
PanicTab:Slider({ Title = T("checkint"), Value = { Min = 1, Max = 6, Default = Config.PanicMode.CheckInterval }, Callback = function(v) Config.PanicMode.CheckInterval = v; SaveConfig() end })

-- ============================================================
-- ABA SEA
-- ============================================================
local SeaTab = Window:Tab({ Title = T("sea"), Icon = "waves" })
SeaTab:Toggle({ Title = T("staysea2"), Value = Config.Settings.StayInSea2UntilHaveDarkFragments, Callback = function(v) Config.Settings.StayInSea2UntilHaveDarkFragments = v; SaveConfig() end })
SeaTab:Toggle({ Title = T("autosea2"), Value = Config.AutoSea2, Callback = function(v) Config.AutoSea2 = v; SaveConfig() end })
SeaTab:Toggle({ Title = T("autosea3"), Value = Config.AutoSea3, Callback = function(v) Config.AutoSea3 = v; SaveConfig() end })
SeaTab:Slider({ Title = T("raidice"), Value = { Min = 0, Max = 20000, Default = Config.AutoRaidIce_TargetFragments }, Callback = function(v) Config.AutoRaidIce_TargetFragments = v; SaveConfig() end })

-- ============================================================
-- ABA OTIMIZAÇÃO
-- ============================================================
local OptTab = Window:Tab({ Title = T("opt"), Icon = "zap" })
OptTab:Toggle({ Title = T("superfix"), Desc = T("superfixdesc"), Value = Config.SuperFixLag,
    Callback = function(state)
        Config.SuperFixLag = state
        SaveConfig()
        if state then
            StartSuperFixLag()
            WindUI:Notify({ Title = T("opt"), Content = T("superfix_on"), Duration = 3, Icon = "zap" })
        else
            StopSuperFixLag()
            WindUI:Notify({ Title = T("opt"), Content = T("superfix_off"), Duration = 3, Icon = "zap-off" })
        end
    end
})
OptTab:Button({ Title = T("restore"), Desc = T("restoredesc"), Callback = function() RestoreEverything() end })

-- ============================================================
-- ABA UI CONFIG
-- ============================================================
local UIConfigTab = Window:Tab({ Title = T("uiconfig"), Icon = "palette" })
UIConfigTab:Section({ Title = T("language") })
UIConfigTab:Dropdown({
    Title = T("language"), Values = { "pt-BR", "en-US", "vi-VN" }, Value = Config.Language,
    Callback = function(opt)
        Config.Language = opt
        SaveConfig()
        WindUI:Notify({ Title = T("nt_lang"), Content = TF("lang_notify", opt), Duration = 5, Icon = "languages" })
    end
})
UIConfigTab:Section({ Title = T("theme") })
UIConfigTab:Dropdown({
    Title = T("theme"),
    Values = (function()
        local n = {}
        for name in pairs(WindUI:GetThemes()) do table.insert(n, name) end
        table.sort(n)
        return n
    end)(),
    Callback = function(s) WindUI:SetTheme(s) end
})
UIConfigTab:Toggle({ Title = T("transparent"), Value = false, Callback = function(s) Window:ToggleTransparency(s) end })
UIConfigTab:Keybind({ Title = T("togglekey"), Value = "RightShift", Callback = function(v) Window:SetToggleKey(Enum.KeyCode[v]) end })

-- ============================================================
-- ABA EXECUTION
-- ============================================================
local ExecTab = Window:Tab({ Title = T("exec"), Icon = "play" })
local KaitunExecuted = false
local ExecuteToggle, AutoExecToggle

ExecuteToggle = ExecTab:Toggle({
    Title = T("execKaitun"), Value = false,
    Callback = function(state)
        if not state then return end
        if Config.AutoExecute then
            Config.AutoExecute = false
            SaveConfig()
            if AutoExecToggle then pcall(function() AutoExecToggle:Set(false) end) end
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
    Title = T("autoexec"), Value = Config.AutoExecute,
    Callback = function(state)
        Config.AutoExecute = state
        SaveConfig()
        if state then
            if ExecuteToggle then pcall(function() ExecuteToggle:Set(false) end) end
            WindUI:Notify({ Title = T("nt_autoexec"), Content = T("autoexec_on"), Duration = 5, Icon = "zap" })
        else
            WindUI:Notify({ Title = T("nt_autoexec"), Content = T("autoexec_off"), Duration = 3, Icon = "zap" })
        end
    end
})

ExecTab:Section({ Title = T("extras") })
ExecTab:Button({ Title = T("redeem"), Desc = T("redeemdesc"), Callback = function() RedeemAllCodes() end })
ExecTab:Toggle({
    Title = T("multihit"), Desc = T("multihitdesc"), Value = Config.MultiHitM1,
    Callback = function(state)
        Config.MultiHitM1 = state
        SaveConfig()
        if state then
            StartMultiHit()
            WindUI:Notify({ Title = T("nt_multihit"), Content = T("multihit_on"), Duration = 3, Icon = "sword" })
        else
            StopMultiHit()
            WindUI:Notify({ Title = T("nt_multihit"), Content = T("multihit_off"), Duration = 3, Icon = "sword" })
        end
    end
})

ExecTab:Section({ Title = T("managecfg") })
ExecTab:Button({
    Title = T("save"), Desc = T("savedesc"),
    Callback = function()
        SaveConfig()
        WindUI:Notify({ Title = T("nt_save"), Content = T("save_done"), Duration = 3, Icon = "save" })
    end
})
ExecTab:Button({
    Title = T("reset"), Desc = T("resetdesc"),
    Callback = function()
        pcall(function()
            if isfile(GetConfigPath()) then delfile(GetConfigPath()) end
        end)
        WindUI:Notify({ Title = T("nt_reset"), Content = T("reset_done"), Duration = 5, Icon = "trash" })
    end
})

-- ============================================================
-- RESTAURA ESTADOS SALVOS
-- ============================================================
if Config.MultiHitM1 then StartMultiHit() end
if Config.SuperFixLag then StartSuperFixLag() end

-- ============================================================
-- AUTO EXECUTE
-- ============================================================
if Config.AutoExecute then
    task.spawn(function()
        task.wait(2)
        ExecuteKaitun()
    end)
end

-- ============================================================
-- BONUS MOMENTS AUTO (PlaceId 994732206)
-- ============================================================
if game.PlaceId == 994732206 then
    task.spawn(function()
        while task.wait(0.2) do
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Remotes.BonusMomentsRemoteFunction
                Event:InvokeServer("Escape from Alcatraz", "Provoke", "Puncher")
                Event:InvokeServer("Escape from Alcatraz", "Provoke", "Raft")
                Event:InvokeServer("Escape from Alcatraz", "Provoke", "Digger")
            end)
        end
    end)
end
