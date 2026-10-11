-- ============================================================
-- SERVICES
-- ============================================================
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ============================================================
-- KEY SYSTEM - DATA
-- ============================================================
local KEY_FILE     = "EndermanHub_KeyData.json"
local KEY_PARTIAL  = "%120KEYcbcfbabc8934678"  -- aceita se CONTIVER isso
local KEY_DURATION = 24 * 60 * 60

local KeyData = { activeSeconds = 0, keyValue = "", burned = false }

local function LoadKeyData()
    pcall(function()
        if isfile(KEY_FILE) then
            local raw = readfile(KEY_FILE)
            if raw and raw ~= "" then
                local d = HttpService:JSONDecode(raw)
                if type(d) == "table" then
                    KeyData.activeSeconds = tonumber(d.activeSeconds) or 0
                    KeyData.keyValue = tostring(d.keyValue or "")
                    KeyData.burned = d.burned == true
                end
            end
        end
    end)
end

local function SaveKeyData()
    pcall(function()
        writefile(KEY_FILE, HttpService:JSONEncode(KeyData))
    end)
end

-- Aceita se CONTIVER "%120KEYcbcfbabc8934678" em qualquer lugar
local function ValidateKey(input)
    if not input or input == "" then return false end
    return string.find(input, KEY_PARTIAL, 1, true) ~= nil
end

local function PurgeWindUIKeySave()
    pcall(function()
        local paths = {
            "EndermanHub/KeySystem.json", "EndermanHub/keys.json",
            "EndermanHub/savekey.json", "EndermanHub/key.json",
            "EndermanHub/SavedKey.json",
        }
        for _, path in ipairs(paths) do
            if isfile(path) then delfile(path) end
        end
    end)
end

LoadKeyData()
if KeyData.burned then PurgeWindUIKeySave() end

-- ============================================================
-- CONFIG
-- ============================================================
local function GetDefaultConfig()
    return {
        Team = "Pirates", Language = "pt-BR", AutoExecute = false,
        MultiHitM1 = true, SuperFixLag = false,
        GirarFrutaV2 = false, RemoveNotifications = false,
        Configuration = { HopWhenIdle=false, AutoHop=false, AutoHopDelay=60, FpsBoost=false, blackscreen=false, LowGraphics=false },
        Items = { AutoFullyMelees=false, Saber=false, CursedDualKatana=false, SoulGuitar=false, RaceV2=false, AutoRaceV3=false, AutoRandomFruit=false },
        Sword = { ["Shark Saw"]=false, ["Wardens Sword"]=false, ["Pole (1st Form)"]=false, ["Gravity Blade"]=false, ["Longsword"]=false, ["Rengoku"]=false, ["Flail"]=false, ["Twin Hooks"]=false },
        BossWeapons = { ["Awakened Ice Admiral"]=false, ["Tide Keeper"]=false, ["Deandre"]=false, ["Urban"]=false, ["Diablo"]=false, ["Soul Reaper"]=false, ["Cake Prince"]=false, ["Core"]=false, ["Darkbeard"]=false, ["Katakuri"]=false, ["Beautiful Pirates"]=false },
        Melee = { AutoBuy=false, CheckMasteryAfterBuy=false, RaidAtV1Mastery=400, GodhumanAtV2Mastery=400 },
        AutoKen = false, BringMobs = false,
        PanicMode = { Enabled=false, LowHealthPercent=20, SafeHealthPercent=75, EscapeHeight=2000, CheckInterval=1 },
        Settings = { StayInSea2UntilHaveDarkFragments = false },
        AutoSea2 = false, AutoSea3 = false, AutoRaidIce_TargetFragments = 5000,
    }
end

Config = GetDefaultConfig()

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
-- TRADUÇÕES
-- ============================================================
local Translations = {
    ["en-US"] = {
        main="Main", items="Items", swords="Swords", bosses="Boss Weapons",
        melee="Melee & Ken", panic="Panic Mode", sea="Sea & Settings",
        opt="Optimization", uiconfig="UI Config", exec="Execution", update_tab="Update",
        time="Team", genconfig="General Config", haki="Haki",
        extras="Extras", managecfg="Manage Config",
        window_title="EndermanHub Kaitun version",
        window_author="[BLOX FRUITS] by jane doe Sigma",
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
        execKaitun_desc="Click only once. Recommend enabling Auto Execute after clicking.",
        multihit="Multi Hit M1 (Beta)",
        girar="Spin Fruit V2", girar_desc="Highly recommended over the other one",
        rmnotif="Remove Notifications", rmnotif_desc="Recommended for videos",
        redeem="Redeem All Codes", redeemdesc="Redeem every working Blox Fruits code",
        save="Save Config", savedesc="Manually save current config",
        reset="Reset Config", resetdesc="Delete saved config (rejoin to apply)",
        language="Language", theme="Theme", transparent="Transparent",
        togglekey="Toggle UI Key",
        nt_kaitun="Kaitun", nt_codes="Codes", nt_autoexec="Auto Execute",
        nt_restore="Restore", nt_multihit="Multi Hit", nt_lang="Language",
        nt_save="Saved", nt_reset="Reset", nt_girar="Spin Fruit", nt_rmnotif="Notifications",
        nt_key="Key System",
        kaitunexec="Executing Kaitun...", rejoinmsg="Rejoining server...",
        rejoinfail="Rejoin failed. Searching for another server...",
        autoexec_on="Enabled! Kaitun will run alone on next inject.",
        autoexec_off="Disabled.",
        redeem_start="Redeeming codes...", redeem_done="Codes sent! Check chat for rewards.",
        save_done="Config saved successfully.", reset_done="Config deleted. Reinject the script.",
        restore_done="Everything restored to normal!",
        superfix_on="Super Fix Lag ENABLED", superfix_off="Super Fix Lag DISABLED",
        multihit_on="Enabled!", multihit_off="Disabled.",
        girar_on="Spin Fruit V2 ENABLED", girar_off="Spin Fruit V2 DISABLED",
        rmnotif_on="Notifications hidden!", rmnotif_off="Notifications restored.",
        lang_notify="Language changed to %s. Reinject to apply.",
        key_note="Enter your key to continue.",
        key_placeholder="Paste your key here...",
        key_verify="Verify Key",
        key_valid_title="Key System",
        key_valid_msg="Key looks valid, enjoy!",
        key_invalid_title="Key System",
        key_invalid_msg="Invalid key, get another one!",
        key_expired_title="Key System",
        key_expired_msg="Your key expired (24h). Get a new one!",
    },
    ["vi-VN"] = {
        main="Chính", items="Vật Phẩm", swords="Kiếm", bosses="Vũ Khí Boss",
        melee="Cận Chiến & Ken", panic="Chế Độ Hoảng Loạn", sea="Biển & Cài Đặt",
        opt="Tối Ưu Hóa", uiconfig="Cấu Hình UI", exec="Thực Thi", update_tab="Cập Nhật",
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
        execKaitun_desc="Chỉ nhấn một lần. Khuyến nghị bật Tự Chạy sau khi nhấn.",
        multihit="Multi Hit M1 (Beta)",
        girar="Quay Trái V2", girar_desc="Rất khuyến nghị thay vì cái kia",
        rmnotif="Xóa Thông Báo", rmnotif_desc="Khuyến nghị cho video",
        redeem="Nhập Tất Cả Code", redeemdesc="Nhập mọi code Blox Fruits còn hoạt động",
        save="Lưu Cấu Hình", savedesc="Lưu cấu hình hiện tại thủ công",
        reset="Đặt Lại Cấu Hình", resetdesc="Xóa cấu hình đã lưu (vào lại để áp dụng)",
        language="Ngôn Ngữ", theme="Chủ Đề", transparent="Trong Suốt",
        togglekey="Phím Mở UI",
        nt_kaitun="Kaitun", nt_codes="Code", nt_autoexec="Tự Chạy",
        nt_restore="Khôi Phục", nt_multihit="Multi Hit", nt_lang="Ngôn Ngữ",
        nt_save="Đã Lưu", nt_reset="Đặt Lại", nt_girar="Quay Trái", nt_rmnotif="Thông Báo",
        nt_key="Hệ Thống Key",
        kaitunexec="Đang chạy Kaitun...", rejoinmsg="Đang vào lại server...",
        rejoinfail="Vào lại thất bại. Đang tìm server khác...",
        autoexec_on="Đã bật! Kaitun sẽ tự chạy khi tiêm lại.",
        autoexec_off="Đã tắt.",
        redeem_start="Đang nhập code...", redeem_done="Đã gửi code! Kiểm tra chat.",
        save_done="Đã lưu cấu hình.", reset_done="Đã xóa cấu hình. Tiêm lại script.",
        restore_done="Đã khôi phục mọi thứ!",
        superfix_on="Siêu Fix Lag ĐÃ BẬT", superfix_off="Siêu Fix Lag ĐÃ TẮT",
        multihit_on="Đã bật!", multihit_off="Đã tắt.",
        girar_on="Quay Trái V2 ĐÃ BẬT", girar_off="Quay Trái V2 ĐÃ TẮT",
        rmnotif_on="Đã ẩn thông báo!", rmnotif_off="Đã khôi phục thông báo.",
        lang_notify="Đã đổi ngôn ngữ sang %s. Tiêm lại để áp dụng.",
        key_note="Nhập chìa khóa của bạn để tiếp tục.",
        key_placeholder="Dán chìa khóa vào đây...",
        key_verify="Xác Minh",
        key_valid_title="Hệ Thống Key",
        key_valid_msg="Chìa khóa có vẻ hợp lệ, tận hưởng!",
        key_invalid_title="Hệ Thống Key",
        key_invalid_msg="Chìa khóa không hợp lệ, lấy cái khác!",
        key_expired_title="Hệ Thống Key",
        key_expired_msg="Chìa khóa hết hạn (24h). Lấy cái mới!",
    },
    ["pt-BR"] = {
        main="Principal", items="Itens", swords="Espadas", bosses="Armas de Boss",
        melee="Melee & Ken", panic="Modo Pânico", sea="Sea & Ajustes",
        opt="Otimização", uiconfig="Config. da UI", exec="Execução", update_tab="Update",
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
        execKaitun_desc="Aperte só uma vez. Recomendo ligar Auto Executar depois de clicar.",
        multihit="Multi Hit M1 (Beta)",
        girar="Girar Fruta V2", girar_desc="Recomendo muito em vez do outro",
        rmnotif="Remover Notificações", rmnotif_desc="Recomendo para vídeos",
        redeem="Pegar Todos os Códigos", redeemdesc="Resgata todos os códigos ativos do Blox Fruits",
        save="Salvar Config", savedesc="Salvar config atual manualmente",
        reset="Resetar Config", resetdesc="Apagar config salva (reentre para aplicar)",
        language="Idioma", theme="Tema", transparent="Transparente",
        togglekey="Tecla de Abrir UI",
        nt_kaitun="Kaitun", nt_codes="Códigos", nt_autoexec="Auto Executar",
        nt_restore="Restaurar", nt_multihit="Multi Hit", nt_lang="Idioma",
        nt_save="Salvo", nt_reset="Resetado", nt_girar="Girar Fruta", nt_rmnotif="Notificações",
        nt_key="Sistema de Key",
        kaitunexec="Executando Kaitun...", rejoinmsg="Reentrando no servidor...",
        rejoinfail="Falha ao reentrar. Procurando outro servidor...",
        autoexec_on="Ativado! Kaitun vai rodar sozinho ao reinjetar.",
        autoexec_off="Desativado.",
        redeem_start="Resgatando códigos...", redeem_done="Códigos enviados! Veja o chat.",
        save_done="Config salva com sucesso.", reset_done="Config apagada. Reinjete o script.",
        restore_done="Tudo restaurado ao normal!",
        superfix_on="Super Fix Lag ATIVADO", superfix_off="Super Fix Lag DESATIVADO",
        multihit_on="Ativado!", multihit_off="Desativado.",
        girar_on="Girar Fruta V2 ATIVADO", girar_off="Girar Fruta V2 DESATIVADO",
        rmnotif_on="Notificações escondidas!", rmnotif_off="Notificações restauradas.",
        lang_notify="Idioma alterado para %s. Reinjete para aplicar.",
        key_note="Digite sua key para continuar.",
        key_placeholder="Cole sua key aqui...",
        key_verify="Verificar Key",
        key_valid_title="Sistema de Key",
        key_valid_msg="Chave parece válida, aproveite!",
        key_invalid_title="Sistema de Key",
        key_invalid_msg="Chave inválida, pegue outra!",
        key_expired_title="Sistema de Key",
        key_expired_msg="Sua key expirou (24h atingidas). Pegue uma nova!",
    },
}

local function T(key)
    local tbl = Translations[Config.Language] or Translations["pt-BR"]
    return tbl[key] or key
end
local function TF(key, ...) return string.format(T(key), ...) end

-- ============================================================
-- CUSTOM KEY PROMPT
-- ============================================================
local function BuildKeyPrompt(onSuccess)
    local sg = Instance.new("ScreenGui")
    sg.Name = "EndermanHubKeyPrompt"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.45
    bg.BorderSizePixel = 0
    bg.Parent = sg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 230)
    frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(138, 43, 226)
    stroke.Thickness = 2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 32)
    title.Position = UDim2.new(0, 10, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "EndermanHub - " .. T("nt_key")
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 20)
    desc.Position = UDim2.new(0, 10, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Text = T("key_note")
    desc.TextColor3 = Color3.fromRGB(180, 180, 180)
    desc.TextSize = 13
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 42)
    box.Position = UDim2.new(0, 10, 0, 78)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    box.BorderSizePixel = 0
    box.Text = KeyData.keyValue ~= "" and KeyData.keyValue or ""
    box.PlaceholderText = T("key_placeholder")
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.TextSize = 13
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, 130)
    btn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    btn.BorderSizePixel = 0
    btn.Text = T("key_verify")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 22)
    status.Position = UDim2.new(0, 10, 0, 180)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    status.TextSize = 12
    status.Font = Enum.Font.Gotham
    status.Parent = frame

    btn.MouseButton1Click:Connect(function()
        local input = box.Text
        if ValidateKey(input) then
            KeyData.keyValue = input
            KeyData.activeSeconds = 0
            KeyData.burned = false
            SaveKeyData()
            status.TextColor3 = Color3.fromRGB(80, 220, 100)
            status.Text = "✔ " .. T("key_valid_msg")
            task.wait(1)
            sg:Destroy()
            if onSuccess then onSuccess() end
        else
            status.TextColor3 = Color3.fromRGB(255, 80, 80)
            status.Text = "✘ " .. T("key_invalid_msg")
        end
    end)

    return sg
end

-- ============================================================
-- WIND UI
-- ============================================================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = T("window_title"),
    Icon = "pickaxe",
    Author = T("window_author"),
    Folder = "EndermanHub", Size = UDim2.fromOffset(520, 480),
    MinSize = Vector2.new(480, 350), MaxSize = Vector2.new(850, 560),
    Transparent = true, Theme = "Dark", Resizable = true, SideBarWidth = 200,
    HideSearchBar = false, ScrollBarEnabled = false,
    Background = "rbxassetid://8176158130", BackgroundImageTransparency = 0.5,
    User = { Enabled = true, Anonymous = false, Callback = function() print(":3") end },
})

-- ============================================================
-- KEY SYSTEM FLOW
-- ============================================================
local KeyTimerStarted = false

local function StartKeyTimer()
    if KeyTimerStarted then return end
    KeyTimerStarted = true

    task.spawn(function()
        local lastSave = os.time()
        while task.wait(1) do
            if KeyData.burned then return end
            KeyData.activeSeconds = KeyData.activeSeconds + 1

            if KeyData.activeSeconds >= KEY_DURATION then
                KeyData.burned = true
                SaveKeyData()
                PurgeWindUIKeySave()
                WindUI:Notify({
                    Title = T("key_expired_title"),
                    Content = T("key_expired_msg"),
                    Duration = 10,
                    Icon = "x-circle",
                })
                return
            end

            if os.time() - lastSave >= 30 then
                SaveKeyData()
                lastSave = os.time()
            end
        end
    end)
end

local function ShowExpiredAndReprompt()
    WindUI:Notify({
        Title = T("key_invalid_title"),
        Content = T("key_invalid_msg"),
        Duration = 8,
        Icon = "x-circle",
    })
    BuildKeyPrompt(function()
        KeyData.burned = false
        SaveKeyData()
        StartKeyTimer()
        WindUI:Notify({
            Title = T("key_valid_title"),
            Content = T("key_valid_msg"),
            Duration = 5,
            Icon = "check-circle",
        })
    end)
end

if KeyData.burned then
    task.spawn(ShowExpiredAndReprompt)
elseif ValidateKey(KeyData.keyValue) then
    task.spawn(function()
        task.wait(2)
        WindUI:Notify({
            Title = T("key_valid_title"),
            Content = T("key_valid_msg"),
            Duration = 5,
            Icon = "check-circle",
        })
    end)
    StartKeyTimer()
else
    BuildKeyPrompt(function()
        StartKeyTimer()
        WindUI:Notify({
            Title = T("key_valid_title"),
            Content = T("key_valid_msg"),
            Duration = 5,
            Icon = "check-circle",
        })
    end)
end

-- ============================================================
-- KAITUN - COM PROTEÇÃO ANTI-DUPLO
-- ============================================================
local KAITUN_URL = "https://raw.githubusercontent.com/Janedoesigma/Endermanhub/main/endermanhubkaitun.lua"

local function GetSessionFlag()
    return "EH_KaitunRan_" .. tostring(game.JobId)
end

local function ExecuteKaitun()
    SaveConfig()
    WindUI:Notify({ Title = T("nt_kaitun"), Content = T("kaitunexec"), Duration = 4, Icon = "play" })
    pcall(function()
        loadstring(game:HttpGet(KAITUN_URL))()
    end)
end

local function RunKaitunOnce()
    local flag = GetSessionFlag()
    if getgenv()[flag] then
        return false
    end
    getgenv()[flag] = true
    ExecuteKaitun()
    return true
end

local function QueueKaitunForNextTeleport()
    pcall(function()
        if type(queue_on_teleport) == "function" then
            queue_on_teleport([[
                task.wait(3)
                local flag = "EH_KaitunRan_" .. tostring(game.JobId)
                if not getgenv()[flag] then
                    getgenv()[flag] = true
                    pcall(function()
                        loadstring(game:HttpGet("]] .. KAITUN_URL .. [["))()
                    end)
                end
            ]])
        end
    end)
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
local MultiHitRunning, MultiHitThread = false, nil

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
    if MultiHitThread then pcall(function() task.cancel(MultiHitThread) end); MultiHitThread = nil end
end

-- ============================================================
-- GIRAR FRUTA V2
-- ============================================================
local GachaRunning, GachaThread = false, nil

local function StartGacha()
    if GachaRunning then return end
    GachaRunning = true

    task.spawn(function()
        local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local function getTextLabel(gui)
            if gui:IsA("TextLabel") then return gui end
            return gui:FindFirstChildOfClass("TextLabel")
        end
        local function aplicarBloqueio(notificationGui)
            local label = getTextLabel(notificationGui)
            if not label then return end
            local function update()
                notificationGui.Enabled = (label.Text ~= "Try again soon")
            end
            update()
            label:GetPropertyChangedSignal("Text"):Connect(update)
        end
        pg.ChildAdded:Connect(function(child)
            if child.Name == "Notifications" then task.defer(function() aplicarBloqueio(child) end) end
        end)
        local existente = pg:FindFirstChild("Notifications")
        if existente then aplicarBloqueio(existente) end
    end)

    GachaThread = task.spawn(function()
        while GachaRunning do
            task.wait(0.2)
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Modules.Net["RF/GachaNetworkRF"]
                Event:InvokeServer({ Context = "Purchase", BoxName = "ZiolesGacha" })
            end)
        end
    end)
end

local function StopGacha()
    GachaRunning = false
    if GachaThread then pcall(function() task.cancel(GachaThread) end); GachaThread = nil end
end

-- ============================================================
-- REMOVER NOTIFICAÇÕES
-- ============================================================
local NotifRemoverRunning, NotifRemoverThread = false, nil

local function StartNotifRemover()
    if NotifRemoverRunning then return end
    NotifRemoverRunning = true
    NotifRemoverThread = task.spawn(function()
        local lp = game:GetService("Players").LocalPlayer
        while NotifRemoverRunning do
            task.wait()
            pcall(function() lp.PlayerGui.Notifications.Enabled = false end)
        end
    end)
end

local function StopNotifRemover()
    NotifRemoverRunning = false
    if NotifRemoverThread then pcall(function() task.cancel(NotifRemoverThread) end); NotifRemoverThread = nil end
    pcall(function() game:GetService("Players").LocalPlayer.PlayerGui.Notifications.Enabled = true end)
end

-- ============================================================
-- SUPER FIX LAG
-- ============================================================
local SuperFixRunning, SuperFixThread = false, nil
local OriginalFogStart, OriginalFogEnd = nil, nil

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
    if SuperFixThread then pcall(function() task.cancel(SuperFixThread) end); SuperFixThread = nil end
    local Lighting = game:GetService("Lighting")
    Lighting.FogStart = OriginalFogStart or 0
    Lighting.FogEnd = OriginalFogEnd or 100000
    for _, obj in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("BasePart") then pcall(function() obj.LocalTransparencyModifier = 0 end) end
    end
end

local function RestoreEverything()
    StopMultiHit(); StopGacha(); StopNotifRemover(); StopSuperFixLag()
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
local MainTab = Window:Tab({ Title = T("main"), Icon = "pin" })
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
-- ABA BOSS
-- ============================================================
local BossTab = Window:Tab({ Title = T("bosses"), Icon = "skull" })
for name, value in pairs(Config.BossWeapons) do
    BossTab:Toggle({ Title = name, Value = value, Callback = function(v) Config.BossWeapons[name] = v; SaveConfig() end })
end

-- ============================================================
-- ABA MELEE
-- ============================================================
local MeleeTab = Window:Tab({ Title = T("melee"), Icon = "hand" })
MeleeTab:Toggle({ Title = T("autobuy"), Value = Config.Melee.AutoBuy, Callback = function(v) Config.Melee.AutoBuy = v; SaveConfig() end })
MeleeTab:Toggle({ Title = T("checkmastery"), Value = Config.Melee.CheckMasteryAfterBuy, Callback = function(v) Config.Melee.CheckMasteryAfterBuy = v; SaveConfig() end })
MeleeTab:Slider({ Title = T("raidv1"), Value = { Min = 0, Max = 400, Default = Config.Melee.RaidAtV1Mastery }, Callback = function(v) Config.Melee.RaidAtV1Mastery = v; SaveConfig() end })
MeleeTab:Slider({ Title = T("godhumanv2"), Value = { Min = 0, Max = 400, Default = Config.Melee.GodhumanAtV2Mastery }, Callback = function(v) Config.Melee.GodhumanAtV2Mastery = v; SaveConfig() end })
MeleeTab:Section({ Title = T("haki") })
MeleeTab:Toggle({ Title = T("autoken"), Value = Config.AutoKen, Callback = function(v) Config.AutoKen = v; SaveConfig() end })
MeleeTab:Toggle({ Title = T("bringmobs"), Value = Config.BringMobs, Callback = function(v) Config.BringMobs = v; SaveConfig() end })

-- ============================================================
-- ABA PANIC
-- ============================================================
local PanicTab = Window:Tab({ Title = T("panic"), Icon = "heart-plus" })
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
        Config.SuperFixLag = state; SaveConfig()
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
        Config.Language = opt; SaveConfig()
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

local ExecuteButton = ExecTab:Button({
    Title = T("execKaitun"),
    Desc = T("execKaitun_desc"),
    Callback = function()
        RunKaitunOnce()
        pcall(function() ExecuteButton:Lock() end)
    end
})

local AutoExecToggle = ExecTab:Toggle({
    Title = T("autoexec"), Value = Config.AutoExecute,
    Callback = function(state)
        Config.AutoExecute = state; SaveConfig()
        if state then
            QueueKaitunForNextTeleport()
            WindUI:Notify({ Title = T("nt_autoexec"), Content = T("autoexec_on"), Duration = 5, Icon = "zap" })
        else
            WindUI:Notify({ Title = T("nt_autoexec"), Content = T("autoexec_off"), Duration = 3, Icon = "zap" })
        end
    end
})

ExecTab:Section({ Title = T("extras") })
ExecTab:Button({ Title = T("redeem"), Desc = T("redeemdesc"), Callback = function() RedeemAllCodes() end })

ExecTab:Toggle({
    Title = T("multihit"), Value = Config.MultiHitM1,
    Callback = function(state)
        Config.MultiHitM1 = state; SaveConfig()
        if state then
            StartMultiHit()
            WindUI:Notify({ Title = T("nt_multihit"), Content = T("multihit_on"), Duration = 3, Icon = "sword" })
        else
            StopMultiHit()
            WindUI:Notify({ Title = T("nt_multihit"), Content = T("multihit_off"), Duration = 3, Icon = "sword" })
        end
    end
})

ExecTab:Toggle({
    Title = T("girar"), Desc = T("girar_desc"), Value = Config.GirarFrutaV2,
    Callback = function(state)
        Config.GirarFrutaV2 = state; SaveConfig()
        if state then
            StartGacha()
            WindUI:Notify({ Title = T("nt_girar"), Content = T("girar_on"), Duration = 3, Icon = "rotate-cw" })
        else
            StopGacha()
            WindUI:Notify({ Title = T("nt_girar"), Content = T("girar_off"), Duration = 3, Icon = "rotate-cw" })
        end
    end
})

ExecTab:Toggle({
    Title = T("rmnotif"), Desc = T("rmnotif_desc"), Value = Config.RemoveNotifications,
    Callback = function(state)
        Config.RemoveNotifications = state; SaveConfig()
        if state then
            StartNotifRemover()
            WindUI:Notify({ Title = T("nt_rmnotif"), Content = T("rmnotif_on"), Duration = 3, Icon = "bell-off" })
        else
            StopNotifRemover()
            WindUI:Notify({ Title = T("nt_rmnotif"), Content = T("rmnotif_off"), Duration = 3, Icon = "bell" })
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
-- ABA UPDATE
-- ============================================================
local UpdateTab = Window:Tab({ Title = T("update_tab"), Icon = "file-text" })

UpdateTab:Section({ Title = "Update 0.85 (Public Launch)" })
UpdateTab:Paragraph({ Title = "Changelog", Desc = "+ Fixed Auto Execute duplicate (session flag per JobId)" })
UpdateTab:Paragraph({ Title = "", Desc = "+ Full 24h Key System with custom prompt" })
UpdateTab:Paragraph({ Title = "", Desc = "+ Key accepts any input containing the secret" })
UpdateTab:Paragraph({ Title = "", Desc = "+ Fixed BonusMoments loop (locked)" })
UpdateTab:Paragraph({ Title = "", Desc = "+ More translations everywhere" })

UpdateTab:Section({ Title = "Update 0.76.3" })
UpdateTab:Paragraph({ Title = "Changelog", Desc = "- Window icon: door-open -> pickaxe" })
UpdateTab:Paragraph({ Title = "", Desc = "- Main tab icon: home -> pin" })
UpdateTab:Paragraph({ Title = "", Desc = "- Panic tab icon: alert-triangle -> heart-plus" })

UpdateTab:Section({ Title = "Update 0.75.3" })
UpdateTab:Paragraph({ Title = "Changelog", Desc = "- Sliders max 600 -> 400" })

UpdateTab:Section({ Title = "Update 0.75" })
UpdateTab:Paragraph({ Title = "Changelog", Desc = "+ Girar Fruta V2, Remove Notifications" })
UpdateTab:Paragraph({ Title = "", Desc = "+ Update tab, button locking, translations" })

-- ============================================================
-- RESTAURA ESTADOS SALVOS
-- ============================================================
if Config.MultiHitM1 then StartMultiHit() end
if Config.SuperFixLag then StartSuperFixLag() end
if Config.GirarFrutaV2 then StartGacha() end
if Config.RemoveNotifications then StartNotifRemover() end

-- ============================================================
-- AUTO EXECUTE ON LOAD
-- ============================================================
if Config.AutoExecute then
    task.spawn(function()
        task.wait(2)
        RunKaitunOnce()
        QueueKaitunForNextTeleport()
    end)
end

-- ============================================================
-- BONUS MOMENTS AUTO (PlaceId 994732206) — LÓGICA EXATA, INTOCADA
-- ============================================================
if game.PlaceId == 994732206 then
    task.spawn(function()
        while true do
            local Event = game:GetService("ReplicatedStorage").Remotes.BonusMomentsRemoteFunction
            Event:InvokeServer(
            "Escape from Alcatraz",
            "Provoke",
            "Puncher"
            )

            task.wait(0.2)

            local Event = game:GetService("ReplicatedStorage").Remotes.BonusMomentsRemoteFunction
            Event:InvokeServer(
            "Escape from Alcatraz",
            "Provoke",
            "Digger"
            )

            task.wait(0.2)

            local Event = game:GetService("ReplicatedStorage").Remotes.BonusMomentsRemoteFunction
            Event:InvokeServer(
            "Escape from Alcatraz",
            "Provoke",
            "Raft"
            )

            task.wait(0.2)
        end
    end)
end
