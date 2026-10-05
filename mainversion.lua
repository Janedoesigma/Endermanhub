--=====================================================================
-- BLOX FRUITS FARM | LAZY LOAD | ANTI-CRASH
--=====================================================================
if _G.__BF_RUNNING then warn("Já rodando"); return end
_G.__BF_RUNNING = true

repeat task.wait() until game:IsLoaded()
task.wait(1)

local function notify(t, txt, d)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",
            {Title = t or "BF-Farm", Text = tostring(txt), Duration = d or 5})
    end)
end

--// SERVICES
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local CollectionService   = game:GetService("CollectionService")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local MainGui     = PlayerGui:WaitForChild("Main", 30)
if not MainGui then notify("BF", "Main GUI não carregou"); return end

local Remotes    = ReplicatedStorage:WaitForChild("Remotes", 20)
local CommF_     = Remotes and Remotes:WaitForChild("CommF_", 15)
local CommE      = Remotes and Remotes:FindFirstChild("CommE")
local Modules    = ReplicatedStorage:WaitForChild("Modules", 20)
local Net        = Modules and Modules:FindFirstChild("Net")
local Enemies    = workspace:FindFirstChild("Enemies") or Instance.new("Folder", workspace)
local Characters = workspace:FindFirstChild("Characters") or Instance.new("Folder", workspace)
local WorldOrigin= workspace:WaitForChild("_WorldOrigin", 20)
local Map        = workspace:WaitForChild("Map", 20)

local PlaceId = game.PlaceId
local Sea1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local Sea2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local Sea3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart", 10)
    Hum  = c:WaitForChild("Humanoid", 10)
end
if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindChar)

local Data     = LocalPlayer:WaitForChild("Data", 20)
local Level    = Data and Data:WaitForChild("Level")
local Beli     = Data and Data:WaitForChild("Beli")
local Frags    = Data and Data:WaitForChild("Fragments")
local RaceData = Data and Data:WaitForChild("Race")

local Quests, Guide = {}, {Data = {NPCList = {}}}
pcall(function() Quests = require(ReplicatedStorage.Quests) end)
pcall(function() Guide  = require(ReplicatedStorage.GuideModule) end)
Guide = Guide or {Data = {NPCList = {}}}

--// FLUENT -------------------------------------------------------------
notify("BF-Farm", "Baixando Fluent...", 3)

local Fluent, SaveManager, InterfaceManager
local function dl(url)
    local ok, src = pcall(game.HttpGet, game, url)
    if ok and src and #src > 200 then
        local o2, res = pcall(loadstring(src))
        if o2 and res then return res end
    end
    return nil
end

for _, u in ipairs({
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/ActualMasterOogway/Fluent/main/main.lua"
}) do
    Fluent = dl(u); if Fluent then break end
    task.wait(0.3)
end
if not Fluent then notify("Erro", "Fluent falhou"); return end

SaveManager = dl("https://github.com/dawid-scripts/Fluent/releases/latest/download/SaveManager.lua")
    or dl("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
    or {SetLibrary=function()end,IgnoreThemeSettings=function()end,
        SetIgnoreIndexes=function()end,SetFolder=function()end,
        BuildConfigSection=function()end,LoadAutoloadConfig=function()end}

InterfaceManager = dl("https://github.com/dawid-scripts/Fluent/releases/latest/download/InterfaceManager.lua")
    or dl("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
    or {SetLibrary=function()end,SetFolder=function()end,BuildInterfaceSection=function()end}

--// WINDOW -------------------------------------------------------------
notify("BF-Farm", "Criando Window...", 2)
task.wait(0.6)

local Window
local ok, err = pcall(function()
    Window = Fluent:CreateWindow({
        Title = "Blox Fruits Farm",
        SubTitle = "Fluent",
        TabWidth = 150,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = false,
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.LeftControl
    })
end)
if not ok or not Window then notify("Erro", "Window: "..tostring(err)); return end

local Options = Fluent.Options

--=====================================================================
-- CRIAÇÃO PROGRESSIVA DE TABS
--=====================================================================
local Tabs = {}
local tabList = {
    {"Info",        "Info",           ""},
    {"Main",        "Main",           "home"},
    {"Fishing",     "Fishing",        ""},
    {"QuestItem",   "Quest & Item",   ""},
    {"Volcano",     "Volcano Event",  ""},
    {"StatsESP",    "Stats & ESP",    "eye"},
    {"FruitRaid",   "Fruit & Raid",   ""},
    {"LocalPlayer", "Local Player",   "user"},
    {"Teleport",    "Teleport",       "map"},
    {"Shopping",    "Shopping",       ""},
    {"Misc",        "Misc",           "wrench"},
    {"Settings",    "Settings",       "settings"},
}

for i, t in ipairs(tabList) do
    notify("BF-Farm", "Tab "..i.."/"..#tabList..": "..t[2], 1)
    pcall(function()
        Tabs[t[1]] = Window:AddTab({ Title = t[2], Icon = t[3] })
    end)
    task.wait(0.5)  -- deixa renderer respirar ENTRE cada tab
end

notify("BF-Farm", "Tabs criadas. Populando...", 3)
task.wait(0.5)

--=====================================================================
-- HELPERS
--=====================================================================
local function optVal(name, default)
    local o = Options[name]
    if not o then return default end
    local ok, v = pcall(function() return o.Value end)
    return ok and v or default
end

local shouldTween = false

local tweenBlock = Instance.new("Part")
tweenBlock.Name = "FarmTweenBlock"
tweenBlock.Size = Vector3.new(1,1,1)
tweenBlock.Anchored = true
tweenBlock.CanCollide = false
tweenBlock.CanTouch = false
tweenBlock.Transparency = 1
tweenBlock.Parent = workspace

local currentTween
local function tp(cf)
    if not Root or not LocalPlayer.Character then return end
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    if typeof(cf) ~= "CFrame" then return end
    pcall(function()
        if currentTween then currentTween:Cancel() end
        local sp = math.max(1, tonumber(optVal("TweenSpeed","300")) or 300)
        local d = (cf.Position - tweenBlock.Position).Magnitude
        currentTween = TweenService:Create(tweenBlock,
            TweenInfo.new(d/sp, Enum.EasingStyle.Linear), {CFrame = cf})
        currentTween:Play()
    end)
end
_G.tp = tp

task.spawn(function()
    while task.wait() do
        pcall(function()
            if shouldTween and Root and tweenBlock then
                Root.CFrame = tweenBlock.CFrame
                if LocalPlayer.Character then
                    for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
                if not Root:FindFirstChild("BodyClip") then
                    local bv = Instance.new("BodyVelocity", Root)
                    bv.Name = "BodyClip"
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    bv.Velocity = Vector3.zero
                end
            elseif Root and Root:FindFirstChild("BodyClip") then
                Root.BodyClip:Destroy()
            end
        end)
    end
end)

local function isAlive(m)
    if not m then return false end
    local h = m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function getDist(pos)
    if not Root then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    if typeof(pos) ~= "Vector3" then return math.huge end
    return (Root.Position - pos).Magnitude
end

local function activateHaki()
    if LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
end

local function equipByTip(tip)
    if not tip or not LocalPlayer.Character then return end
    local bp = LocalPlayer.Backpack
    if not bp then return end
    for _, t in pairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then
            pcall(function()
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(t)
            end)
            return
        end
    end
end

local function equipSelected()
    equipByTip(optVal("WeaponTool_S", nil) or optVal("WeaponTool", nil) or "Melee")
end

local function sendKey(k, hold)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, k, false, game)
        task.wait(hold or 0.05)
        VirtualInputManager:SendKeyEvent(false, k, false, game)
    end)
end
_G.sendKey = sendKey

local function hasTool(name)
    return LocalPlayer.Character and
        ((LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(name))
        or LocalPlayer.Character:FindFirstChild(name)) ~= nil
end

local function findEnemy(names, maxD)
    if not Root then return nil end
    local mp = {}
    for _, n in ipairs(names) do mp[n] = true end
    local best, bd = nil, maxD or math.huge
    for _, e in pairs(Enemies:GetChildren()) do
        if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local sh = e.Name:match("^(.-)%s*%[") or e.Name
            if mp[e.Name] or mp[sh] then
                local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                if d < bd then bd = d; best = e end
            end
        end
    end
    return best
end

local function bringEnemy(target, centerCF)
    if not optVal("BringMob", true) or not target or not centerCF then return end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
        end
    end)
    local r = tonumber(optVal("BringRadius","300")) or 300
    local r2 = r*r
    local c = centerCF.Position
    for _, e in pairs(Enemies:GetChildren()) do
        if e.Name == target.Name and isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local rt, h = e.HumanoidRootPart, e:FindFirstChildOfClass("Humanoid")
            local d = (rt.Position - c).Magnitude
            if d*d <= r2 and h then
                rt.CanCollide = false
                h.WalkSpeed = 0; h.JumpPower = 0
                rt.CFrame = CFrame.new(c + Vector3.new(math.random(-3,3),3,math.random(-3,3)))
            end
        end
    end
end

local Attack = {}
Attack.Kill = function(model, on)
    if not model or not on then return end
    local hrp, hum = model:FindFirstChild("HumanoidRootPart"),
                      model:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    equipSelected(); activateHaki()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local cf = (tool and tool.ToolTip == "Blox Fruit")
        and hrp.CFrame * CFrame.new(0,20,2)
        or  hrp.CFrame * CFrame.new(0,30,2)
    tp(cf); bringEnemy(model, hrp.CFrame)
    for _, k in ipairs({"Z","X","C","Y","F"}) do
        local o = Options["Skill"..k]
        if o and o.Value then sendKey(k) end
    end
end
_G.Attack = Attack

--=====================================================================
-- POPULAÇÃO DE CADA TAB EM COROUTINE (com yield a cada widget)
--=====================================================================
notify("BF-Farm", "Populando tabs...", 3)

-- Função que adiciona widget com yield automático
local function Y() task.wait(0.03) end

-- materialList/bossList/etc globais para os loops
local materialList, bossList, islandList, quickBtns

--=====================================================================
-- TAB INFO
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Info:AddSection("Server Status"); Y()
        local TimeP = Tabs.Info:AddParagraph({Title="Local Time", Content="..."}); Y()
        local GameP = Tabs.Info:AddParagraph({Title="Game Time", Content="..."}); Y()
        local RaceP = Tabs.Info:AddParagraph({Title="Race", Content="..."}); Y()
        local StatP = Tabs.Info:AddParagraph({Title="Player Stats", Content="..."}); Y()
        local MoonP = Tabs.Info:AddParagraph({Title="Moon", Content="..."}); Y()
        local MirP  = Tabs.Info:AddParagraph({Title="Mirage", Content="..."}); Y()
        local KitP  = Tabs.Info:AddParagraph({Title="Kitsune", Content="..."}); Y()
        local PreP  = Tabs.Info:AddParagraph({Title="Prehistoric", Content="..."}); Y()
        local FroP  = Tabs.Info:AddParagraph({Title="Frozen Dim", Content="..."}); Y()
        local CakeP = Tabs.Info:AddParagraph({Title="Cake Prince", Content="..."}); Y()
        local RipP  = Tabs.Info:AddParagraph({Title="Rip Indra", Content="..."}); Y()
        local DoughP= Tabs.Info:AddParagraph({Title="Dough King", Content="..."}); Y()
        local SwdP  = Tabs.Info:AddParagraph({Title="Leg. Swords", Content="..."}); Y()
        local BoneP = Tabs.Info:AddParagraph({Title="Bones", Content="0"}); Y()

        task.spawn(function()
            while task.wait(1.5) do
                pcall(function()
                    TimeP:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
                    local gt = math.floor(workspace.DistributedGameTime)
                    GameP:SetDesc(string.format("%dh %dm %ds",
                        math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
                    local race = RaceData and tostring(RaceData.Value) or "?"
                    pcall(function()
                        if CommF_:InvokeServer("Wenlocktoad","1") == -2 then race=race.." V3"
                        elseif CommF_:InvokeServer("Alchemist","1") == -2 then race=race.." V2"
                        else race=race.." V1" end
                    end)
                    RaceP:SetDesc(race)
                    StatP:SetDesc(string.format("Lv %d | Beli %s | Frags %s",
                        Level and Level.Value or 0,
                        tostring(Beli and Beli.Value or 0),
                        tostring(Frags and Frags.Value or 0)))
                    local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
                    for k,v in pairs({
                        ["9709149431"]="Full Moon",["9709149052"]="4/5",
                        ["9709143733"]="3/5",["9709150401"]="2/5",["9709149680"]="1/5"
                    }) do if moon:find(k) then MoonP:SetDesc(v); break end end
                    if WorldOrigin:FindFirstChild("Locations") then
                        MirP:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "✅" or "❌")
                        FroP:SetDesc(WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "✅" or "❌")
                    end
                    KitP:SetDesc(Map:FindFirstChild("KitsuneIsland") and "✅" or "❌")
                    PreP:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "✅" or "❌")
                    local cp = CommF_:InvokeServer("CakePrinceSpawner")
                    if cp and tostring(cp):find("%d") then
                        local kk = tostring(cp):match("%d+")
                        CakeP:SetDesc("Killed: "..(500-tonumber(kk or 0)))
                    else
                        CakeP:SetDesc(Enemies:FindFirstChild("Cake Prince") and "✅" or "❌")
                    end
                    RipP:SetDesc(Enemies:FindFirstChild("rip_indra") and "✅" or "❌")
                    DoughP:SetDesc(Enemies:FindFirstChild("Dough King") and "✅" or "❌")
                    local sw = {}
                    if CommF_:InvokeServer("LegendarySwordDealer","1") then table.insert(sw,"Shisui") end
                    if CommF_:InvokeServer("LegendarySwordDealer","2") then table.insert(sw,"Wando") end
                    if CommF_:InvokeServer("LegendarySwordDealer","3") then table.insert(sw,"Saddi") end
                    SwdP:SetDesc(#sw>0 and table.concat(sw,", ") or "None")
                    local b = CommF_:InvokeServer("Bones","Check")
                    if b then BoneP:SetDesc(tostring(b)) end
                end)
            end
        end)
    end)
end)
task.wait(1)

--=====================================================================
-- TAB MAIN
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Main:AddSection("Farming"); Y()
        Tabs.Main:AddDropdown("WeaponTool", {
            Title="Weapon Tool", Values={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee"
        }):OnChanged(function(v)
            local o = Options.WeaponTool_S
            if o then pcall(function() o:SetValue(v) end) end
        end); Y()

        Tabs.Main:AddToggle("AutoFarmLevel",{Title="Auto Farm Level",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Main:AddToggle("AutoFarmNearest",{Title="Auto Farm Nearest",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Main:AddDropdown("NearestRange",{Title="Nearest Range",
            Values={"500","1000","2000","3000","Infinite"},Default="Infinite"}); Y()
        Tabs.Main:AddToggle("AutoFactory",{Title="Auto Factory Raid",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Main:AddToggle("AutoEctoplasm",{Title="Auto Farm Ectoplasm",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.Main:AddSection("Chest"); Y()
        Tabs.Main:AddToggle("AutoCollectChest",{Title="Auto Collect Chest",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Main:AddToggle("StopRareItems",{Title="Stop on Rare Items",Default=true}); Y()
        Tabs.Main:AddToggle("AutoHopNoChest",{Title="Auto Hop If No Chest",Default=false}); Y()
        Tabs.Main:AddToggle("AutoCollectBerry",{Title="Auto Collect Berry",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.Main:AddSection("Mastery"); Y()
        Tabs.Main:AddDropdown("MasteryMode",{Title="Mastery Mode",
            Values={"Level","Bone","Cake Prince","Nearest"},Default="Level"}); Y()
        Tabs.Main:AddDropdown("MasteryWeapon",{Title="Mastery Weapon",
            Values={"Melee","Sword","Blox Fruit","Gun"},Default="Melee"}); Y()
        Tabs.Main:AddToggle("AutoMastery",{Title="Auto Farm Mastery",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.Main:AddSection("Material"); Y()
        materialList = Sea1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
            or Sea2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
            or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
        Tabs.Main:AddDropdown("MaterialSel",{Title="Material",Values=materialList,Default=materialList[1]}); Y()
        Tabs.Main:AddToggle("AutoMaterial",{Title="Auto Farm Material",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.Main:AddSection("Boss"); Y()
        bossList = Sea1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
            or Sea2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
            or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
        Tabs.Main:AddDropdown("BossSel",{Title="Boss",Values=bossList,Default=bossList[1]}); Y()
        Tabs.Main:AddToggle("AutoBoss",{Title="Auto Attack Boss",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Main:AddToggle("AutoAllBoss",{Title="Auto Attack All Boss",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.Main:AddSection("Special"); Y()
        for _, t in ipairs({
            {"AutoCakePrince","Auto Cake Prince"},{"AutoDoughKing","Auto Dough King"},
            {"AutoBone","Auto Farm Bones"},{"AutoSoulReaper","Auto Soul Reaper"},
            {"AutoElite","Auto Elite Hunter"},{"AutoPiratesSea","Auto Pirates Sea"},
            {"AutoRipIndra","Auto Rip Indra"},{"AutoRainbowHaki","Auto Rainbow Haki"},
            {"AutoCitizen","Auto Citizen"}
        }) do
            Tabs.Main:AddToggle(t[1],{Title=t[2],Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        end
        Tabs.Main:AddToggle("AutoTryLuck",{Title="Auto Try Luck",Default=false}); Y()
        Tabs.Main:AddToggle("AutoPray",{Title="Auto Pray",Default=false}); Y()
    end)
end)
task.wait(1)

--=====================================================================
-- TAB FISHING
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Fishing:AddSection("Fishing"); Y()
        Tabs.Fishing:AddDropdown("FishingRod",{Title="Fishing Rod",
            Values={"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},Default="Fishing Rod"}); Y()
        Tabs.Fishing:AddDropdown("FishingBait",{Title="Bait",
            Values={"Basic Bait","Kelp Bait","Good Bait","Abyssal Bait","Frozen Bait","Epic Bait","Carnivore Bait"},
            Default="Basic Bait"}); Y()
        for _, t in ipairs({
            {"AutoBuyBait","Auto Buy Bait"},{"AutoEquipRod","Auto Equip Rod"},
            {"AutoFishing","Auto Fishing"},{"AutoFishingQuest","Auto Fishing Quest"},
            {"AutoFishComplete","Auto Complete Quest"},{"AutoSellFish","Auto Sell Fish"},
            {"AutoSellCorrupt","Auto Sell Corrupted Fish"},{"SpamSkillZ","Auto Spam Skill Z"}
        }) do
            Tabs.Fishing:AddToggle(t[1],{Title=t[2],Default=false}); Y()
        end
    end)
end)
task.wait(1)

--=====================================================================
-- TAB QUEST ITEM
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.QuestItem:AddSection("Swords"); Y()
        Tabs.QuestItem:AddDropdown("SwordSel",{Title="Sword",
            Values={"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
            Default="Twin Hooks"}); Y()
        Tabs.QuestItem:AddToggle("AutoGetSword",{Title="Auto Get Sword",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.QuestItem:AddToggle("AutoGetSerpent",{Title="Auto Get Serpent Bow",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.QuestItem:AddToggle("AutoTushita",{Title="Auto Tushita",Default=false}); Y()
        Tabs.QuestItem:AddToggle("AutoYama",{Title="Auto Yama",Default=false}); Y()

        Tabs.QuestItem:AddSection("Fighting Styles"); Y()
        for _, t in ipairs({
            {"AutoSuperhuman","Auto Superhuman"},{"AutoDeathStep","Auto Death Step"},
            {"AutoSharkman","Auto Sharkman"},{"AutoElectricClaw","Auto Electric Claw"},
            {"AutoDragonTalon","Auto Dragon Talon"},{"AutoGodHuman","Auto Godhuman"},
            {"AutoSanguine","Auto Sanguine Art"}
        }) do
            Tabs.QuestItem:AddToggle(t[1],{Title=t[2],Default=false}); Y()
        end

        Tabs.QuestItem:AddSection("Race V2/V3"); Y()
        Tabs.QuestItem:AddToggle("AutoV2",{Title="Auto Race V2",Default=false}); Y()
        Tabs.QuestItem:AddToggle("AutoV3",{Title="Auto Race V3",Default=false}); Y()

        Tabs.QuestItem:AddSection("V4 Trial"); Y()
        Tabs.QuestItem:AddButton({Title="TP Temple of Time", Callback=function()
            pcall(function()
                if Root then Root.CFrame = CFrame.new(28286,14895,102) end
                local s = ReplicatedStorage:FindFirstChild("MapStash")
                if s and s:FindFirstChild("Temple of Time") and not Map:FindFirstChild("Temple of Time") then
                    s["Temple of Time"].Parent = Map
                end
            end)
        end}); Y()
        Tabs.QuestItem:AddButton({Title="Pull Lever", Callback=function()
            pcall(function()
                if Map:FindFirstChild("Temple of Time") then
                    for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
                        if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
                    end
                end
            end)
        end}); Y()
        Tabs.QuestItem:AddToggle("AutoTrial",{Title="Auto Complete Trial",Default=false}); Y()
        Tabs.QuestItem:AddToggle("AutoKillTrial",{Title="Auto Kill Players After Trial",Default=false}); Y()

        Tabs.QuestItem:AddSection("Quick Buy"); Y()
        quickBtns = {
            {"Buy Buso",{"BuyHaki","Buso"}},{"Buy Geppo",{"BuyHaki","Geppo"}},
            {"Buy Soru",{"BuyHaki","Soru"}},{"Buy Ken",{"KenTalk","Buy"}},
            {"Buy Black Leg",{"BuyBlackLeg"}},{"Buy Electro",{"BuyElectro"}},
            {"Buy Fishman",{"BuyFishmanKarate"}},{"Buy Superhuman",{"BuySuperhuman"}},
            {"Buy Death Step",{"BuyDeathStep"}},{"Buy Sharkman",{"BuySharkmanKarate"}},
            {"Buy Elec Claw",{"BuyElectricClaw"}},{"Buy Drag Talon",{"BuyDragonTalon"}},
            {"Buy Godhuman",{"BuyGodhuman"}},{"Buy Sanguine",{"BuySanguineArt"}},
            {"Buy Katana",{"BuyItem","Katana"}},{"Buy Cutlass",{"BuyItem","Cutlass"}},
            {"Buy Dual Katana",{"BuyItem","Dual Katana"}},{"Buy Iron Mace",{"BuyItem","Iron Mace"}},
            {"Buy Triple Katana",{"BuyItem","Triple Katana"}},{"Buy Pipe",{"BuyItem","Pipe"}},
            {"Buy Soul Cane",{"BuyItem","Soul Cane"}},{"Buy Bisento",{"BuyItem","Bisento"}}
        }
        for _, b in ipairs(quickBtns) do
            local a = b[2]
            Tabs.QuestItem:AddButton({Title=b[1], Callback=function()
                pcall(function() CommF_:InvokeServer(unpack(a)) end)
            end}); Y()
        end
    end)
end)
task.wait(1)

--=====================================================================
-- TAB VOLCANO
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Volcano:AddSection("Prehistoric"); Y()
        Tabs.Volcano:AddToggle("AutoSummonPrehis",{Title="Auto Summon Prehis",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Volcano:AddToggle("TweenPrehis",{Title="Tween to Prehis",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Volcano:AddToggle("AutoStartPrehis",{Title="Auto Start Event",Default=false}); Y()
        Tabs.Volcano:AddToggle("AutoPatchPrehis",{Title="Auto Patch Event",Default=false}); Y()
        Tabs.Volcano:AddToggle("CollectDinoBones",{Title="Auto Collect Dino Bones",Default=false}):OnChanged(function(v) shouldTween=v end); Y()
        Tabs.Volcano:AddToggle("CollectDragonEggs",{Title="Auto Collect Dragon Eggs",Default=false}); Y()

        Tabs.Volcano:AddSection("Dragon Trial"); Y()
        Tabs.Volcano:AddButton({Title="TP Dragon Dojo", Callback=function()
            pcall(function()
                CommF_:InvokeServer("requestEntrance", Vector3.new(5661,1013,-334))
                tp(CFrame.new(5814,1208,884))
            end)
        end}); Y()
        Tabs.Volcano:AddToggle("AutoDojo",{Title="Auto Dojo Trainer",Default=false}); Y()
        Tabs.Volcano:AddToggle("AutoDracoV1",{Title="Auto Draco V1",Default=false}); Y()
        Tabs.Volcano:AddToggle("AutoDracoV2",{Title="Auto Draco V2",Default=false}); Y()
        Tabs.Volcano:AddToggle("AutoDracoV3",{Title="Auto Draco V3",Default=false}); Y()

        Tabs.Volcano:AddSection("Crafting"); Y()
        for _, item in ipairs({"Dragonheart","Dragonstorm","DinoHood","TRexSkull"}) do
            Tabs.Volcano:AddButton({Title="Craft "..item, Callback=function()
                pcall(function() CommF_:InvokeServer("CraftItem","Craft",item) end)
            end}); Y()
        end
    end)
end)
task.wait(1)

--=====================================================================
-- TAB STATS ESP
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.StatsESP:AddSection("Stats"); Y()
        Tabs.StatsESP:AddSlider("StatsVal",{Title="Points Per Stat",Default=10,Min=1,Max=100,Rounding=0}); Y()
        for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
            Tabs.StatsESP:AddToggle("autoStat_"..s,{Title="Auto "..s,Default=false}); Y()
        end
        Tabs.StatsESP:AddSection("ESP"); Y()
        for _, t in ipairs({
            {"EspPlayer","ESP Player"},{"EspChest","ESP Chest"},
            {"EspFruit","ESP Devil Fruit"},{"EspBerry","ESP Berry"},
            {"EspEvent","ESP Event Islands"}
        }) do
            Tabs.StatsESP:AddToggle(t[1],{Title=t[2],Default=false}); Y()
        end
    end)
end)
task.wait(1)

--=====================================================================
-- TAB FRUIT RAID
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.FruitRaid:AddSection("Fruit Mgmt"); Y()
        Tabs.FruitRaid:AddToggle("AutoRandomFruit",{Title="Auto Random Fruit",Default=false}); Y()
        Tabs.FruitRaid:AddToggle("AutoStoreFruit",{Title="Auto Store Fruit",Default=false}); Y()
        Tabs.FruitRaid:AddToggle("AutoDropFruit",{Title="Auto Drop Fruit",Default=false}); Y()
        Tabs.FruitRaid:AddToggle("AutoFindFruit",{Title="Auto Find Fruit",Default=false}):OnChanged(function(v) shouldTween=v end); Y()

        Tabs.FruitRaid:AddSection("Raids"); Y()
        Tabs.FruitRaid:AddDropdown("RaidChip",{Title="Raid Chip",
            Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
            Default="Flame"}); Y()
        Tabs.FruitRaid:AddToggle("AutoBuyChip",{Title="Auto Buy Chip",Default=false}); Y()
        Tabs.FruitRaid:AddToggle("AutoAwake",{Title="Auto Awakening",Default=false}); Y()
    end)
end)
task.wait(1)

--=====================================================================
-- TAB LOCAL PLAYER
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.LocalPlayer:AddSection("Aimbot"); Y()
        local plrNames = {}
        for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end
        if #plrNames == 0 then plrNames = {""} end
        Tabs.LocalPlayer:AddDropdown("AimPlayer",{Title="Target Player",
            Values=plrNames,Default=plrNames[1]}); Y()
        Tabs.LocalPlayer:AddDropdown("AimMethod",{Title="Aim Method",
            Values={"Aim Player","Nearest Aim"},Default="Aim Player"}); Y()
        Tabs.LocalPlayer:AddToggle("Aimbot",{Title="Aimbot Skills",Default=false}):OnChanged(function(v)
            _G.AimbotEnabled = v
        end); Y()
        Tabs.LocalPlayer:AddToggle("NoClip",{Title="No Clip",Default=false}); Y()

        Tabs.LocalPlayer:AddSection("Player Hunter"); Y()
        Tabs.LocalPlayer:AddButton({Title="Get Player Quest", Callback=function()
            pcall(function() CommF_:InvokeServer("PlayerHunter") end)
        end}); Y()
        Tabs.LocalPlayer:AddToggle("AutoGetPlayerQuest",{Title="Auto Get Player Quest",Default=false}); Y()
        Tabs.LocalPlayer:AddToggle("AutoKillPlayerQuest",{Title="Auto Kill Player Quest",Default=false}); Y()
        Tabs.LocalPlayer:AddToggle("AutoPvP",{Title="Auto Enable PvP",Default=false}); Y()
    end)
end)
task.wait(1)

--=====================================================================
-- TAB TELEPORT
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Teleport:AddSection("Worlds"); Y()
        Tabs.Teleport:AddButton({Title="Sea 1", Callback=function()
            pcall(function() CommF_:InvokeServer("TravelMain") end)
        end}); Y()
        Tabs.Teleport:AddButton({Title="Sea 2", Callback=function()
            pcall(function() CommF_:InvokeServer("TravelDressrosa") end)
        end}); Y()
        Tabs.Teleport:AddButton({Title="Sea 3", Callback=function()
            pcall(function() CommF_:InvokeServer("TravelZou") end)
        end}); Y()

        Tabs.Teleport:AddSection("Islands"); Y()
        islandList = {}
        if WorldOrigin:FindFirstChild("Locations") then
            for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandList, l.Name) end
        end
        if #islandList == 0 then islandList = {""} end
        Tabs.Teleport:AddDropdown("IslandSel",{Title="Island",
            Values=islandList,Default=islandList[1]}); Y()
        Tabs.Teleport:AddToggle("TweenIsland",{Title="Auto Travel Island",Default=false}):OnChanged(function(v)
            shouldTween=v
        end); Y()

        Tabs.Teleport:AddSection("Portals"); Y()
        for _, p in ipairs({
            {"Sky (S1)",{"requestEntrance",Vector3.new(-7894,5547,-380)}},
            {"Underwater (S1)",{"requestEntrance",Vector3.new(61163,11,1819)}},
            {"Swan (S2)",{"requestEntrance",Vector3.new(2285,15,905)}},
            {"Cursed Ship (S2)",{"requestEntrance",Vector3.new(923,126,32852)}},
            {"Castle (S3)",{"requestEntrance",Vector3.new(-5097,316,-3142)}},
            {"Mansion (S3)",{"requestEntrance",Vector3.new(-12471,374,-7551)}},
            {"Hydra (S3)",{"requestEntrance",Vector3.new(5643,1013,-340)}}
        }) do
            local a = p[2]
            Tabs.Teleport:AddButton({Title=p[1], Callback=function()
                pcall(function() CommF_:InvokeServer(unpack(a)) end)
            end}); Y()
        end
    end)
end)
task.wait(1)

--=====================================================================
-- TAB SHOPPING
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Shopping:AddSection("Shop"); Y()
        for _, b in ipairs(quickBtns or {}) do
            local a = b[2]
            Tabs.Shopping:AddButton({Title=b[1], Callback=function()
                pcall(function() CommF_:InvokeServer(unpack(a)) end)
            end}); Y()
        end
        Tabs.Shopping:AddSection("Fragments"); Y()
        Tabs.Shopping:AddButton({Title="Reroll Race", Callback=function()
            pcall(function() CommF_:InvokeServer("BlackbeardReward","Reroll","2") end)
        end}); Y()
        Tabs.Shopping:AddButton({Title="Refund Stats", Callback=function()
            pcall(function() CommF_:InvokeServer("BlackbeardReward","Refund","2") end)
        end}); Y()
        Tabs.Shopping:AddButton({Title="Legendary Swords", Callback=function()
            pcall(function()
                CommF_:InvokeServer("LegendarySwordDealer","1")
                CommF_:InvokeServer("LegendarySwordDealer","2")
                CommF_:InvokeServer("LegendarySwordDealer","3")
            end)
        end}); Y()
        Tabs.Shopping:AddButton({Title="True Triple Katana", Callback=function()
            pcall(function() CommF_:InvokeServer("MysteriousMan","2") end)
        end}); Y()
        Tabs.Shopping:AddButton({Title="Ghoul Race", Callback=function()
            pcall(function() CommF_:InvokeServer("Ectoplasm","Change",4) end)
        end}); Y()
        Tabs.Shopping:AddButton({Title="Cyborg Race", Callback=function()
            pcall(function() CommF_:InvokeServer("CyborgTrainer","Buy") end)
        end}); Y()
    end)
end)
task.wait(1)

--=====================================================================
-- TAB MISC
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Misc:AddSection("Server"); Y()
        Tabs.Misc:AddButton({Title="Hop Server", Callback=function()
            pcall(function()
                local d = HttpService:JSONDecode(game:HttpGet(
                    "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, s in pairs(d.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
                    end
                end
            end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Rejoin Server", Callback=function()
            pcall(function() TeleportService:Teleport(PlaceId, LocalPlayer) end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Copy Job ID", Callback=function()
            pcall(function() setclipboard(tostring(game.JobId)) end)
        end}); Y()

        Tabs.Misc:AddSection("Teams"); Y()
        Tabs.Misc:AddButton({Title="Join Pirates", Callback=function()
            pcall(function() CommF_:InvokeServer("SetTeam","Pirates") end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Join Marines", Callback=function()
            pcall(function() CommF_:InvokeServer("SetTeam","Marines") end)
        end}); Y()

        Tabs.Misc:AddSection("Visual"); Y()
        Tabs.Misc:AddToggle("RemoveDamage",{Title="Remove Damage Numbers",Default=false}); Y()
        Tabs.Misc:AddToggle("RemoveNotify",{Title="Remove Notifications",Default=false}); Y()
        Tabs.Misc:AddToggle("WalkWater",{Title="Walk on Water",Default=false}):OnChanged(function(v)
            local w = Map:FindFirstChild("WaterBase-Plane")
            if w then w.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
        end); Y()
        Tabs.Misc:AddToggle("FullBright",{Title="Full Bright",Default=false}):OnChanged(function(v)
            Lighting.Ambient = v and Color3.fromRGB(255,255,255) or Color3.fromRGB(70,70,70)
            Lighting.Brightness = v and 2 or 1
            Lighting.GlobalShadows = not v
        end); Y()
        Tabs.Misc:AddToggle("LowCPU",{Title="Low CPU Mode",Default=false}); Y()

        Tabs.Misc:AddSection("Redeem & Menu"); Y()
        Tabs.Misc:AddButton({Title="Redeem All Codes", Callback=function()
            pcall(function()
                local codes = {"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS",
                    "NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
                    "SUB2GAMEROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
                    "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
                    "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
                    "Starcodeheo","Bluxxy","SUB2GAMEROBOT_EXP1","Sub2NoobMaster123",
                    "Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
                    "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN"}
                local RR = Remotes:FindFirstChild("Redeem")
                if not RR then return end
                for _, c in ipairs(codes) do
                    pcall(function()
                        if RR.InvokeServer then RR:InvokeServer(c) else RR:FireServer(c) end
                    end)
                    task.wait(0.1)
                end
            end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Open Titles", Callback=function()
            pcall(function() CommF_:InvokeServer("getTitles", true); MainGui.Titles.Visible = true end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Open Haki Colors", Callback=function()
            pcall(function() MainGui.Colors.Visible = true end)
        end}); Y()
        Tabs.Misc:AddButton({Title="Open Awakening", Callback=function()
            pcall(function() MainGui.AwakeningToggler.Visible = true end)
        end}); Y()
    end)
end)
task.wait(1)

--=====================================================================
-- TAB SETTINGS
--=====================================================================
task.spawn(function()
    pcall(function()
        Tabs.Settings:AddSection("Combat"); Y()
        Tabs.Settings:AddToggle("KillAura",{Title="Kill Aura",Default=false}); Y()
        Tabs.Settings:AddDropdown("WeaponTool_S",{Title="Weapon Tool",
            Values={"Melee","Sword","Blox Fruit","Gun"},Default="Melee"}):OnChanged(function(v)
            local o = Options.WeaponTool
            if o then pcall(function() o:SetValue(v) end) end
        end); Y()
        Tabs.Settings:AddDropdown("TweenSpeed",{Title="Tween Speed",
            Values={"100","200","300","400","500","800","1000"},Default="300"}); Y()
        Tabs.Settings:AddToggle("BringMob",{Title="Bring Mob",Default=true}); Y()
        Tabs.Settings:AddDropdown("BringRadius",{Title="Bring Radius",
            Values={"100","200","300","400","500","1000"},Default="300"}); Y()
        Tabs.Settings:AddToggle("FastAttack",{Title="Fast Attack",Default=false}); Y()

        Tabs.Settings:AddSection("Abilities"); Y()
        Tabs.Settings:AddToggle("AutoTurnV3",{Title="Auto Turn V3",Default=false}); Y()
        Tabs.Settings:AddToggle("AutoTurnV4",{Title="Auto Turn V4",Default=false}); Y()
        Tabs.Settings:AddToggle("AutoBuso",{Title="Auto Turn on Buso",Default=false}); Y()
        Tabs.Settings:AddToggle("AutoKen",{Title="Auto Haki Observation",Default=false}); Y()

        Tabs.Settings:AddSection("Anti/Notif"); Y()
        Tabs.Settings:AddToggle("AntiAFK",{Title="Anti AFK",Default=true}):OnChanged(function(v)
            if v then
                LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait(1)
                        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end)
                end)
            end
        end); Y()
        Tabs.Settings:AddToggle("AntiAdmin",{Title="Auto Anti-Admin",Default=false}); Y()
        Tabs.Settings:AddToggle("DisableNotify",{Title="Disable Notify",Default=false}); Y()
    end)
end)

--=====================================================================
-- AGUARDA TODAS AS TABS TEREM SIDO POPULADAS
--=====================================================================
task.wait(3)
notify("BF-Farm", "✅ UI pronta. Iniciando loops...", 4)

--=====================================================================
-- LOOPS (só depois de UI pronta)
--=====================================================================

task.spawn(function()
    while task.wait(0.25) do
        pcall(function()
            if not LocalPlayer.Character or not Root then return end

            if optVal("AutoFarmLevel",false) then
                local lvl = Level and Level.Value or 0
                local team = tostring(LocalPlayer.Team)
                local q
                if lvl >= 1 and lvl <= 9 then
                    if team == "Marines" then
                        q = {"Trainee",CFrame.new(-2709,24,2104),"Trainee","MarineQuest",1,1}
                    else
                        q = {"Bandit",CFrame.new(1059,16,1549),"Bandit","BanditQuest1",1,1}
                    end
                else
                    local cl, cf = 0, nil
                    for k, v in pairs(Guide.Data.NPCList) do
                        for _, lv in ipairs(v.Levels or {}) do
                            if lvl >= lv and lv > cl then
                                cl = lv
                                if k and k.CFrame then cf = k.CFrame end
                            end
                        end
                    end
                    local qn, qid, mob, sp
                    for k, quest in pairs(Quests) do
                        for k2, v in pairs(quest) do
                            if v.LevelReq == cl then
                                qn, qid = k, k2
                                for k3 in pairs(v.Task) do
                                    mob = k3
                                    sp = string.split(k3, " [Lv. "..v.LevelReq.."]")[1]
                                end
                            end
                        end
                    end
                    q = {mob, cf, sp, qn, qid, cl}
                end
                if q and q[1] then
                    local quest = MainGui:FindFirstChild("Quest")
                    local visible = quest and quest.Visible and quest.Container
                        and quest.Container.QuestTitle and quest.Container.QuestTitle.Title
                    local tOK = visible and string.find(quest.Container.QuestTitle.Title.Text, q[1])
                    if not tOK then
                        if q[2] then
                            tp(q[2])
                            if getDist(q[2]) < 10 then
                                CommF_:InvokeServer("StartQuest", q[4], q[5])
                            end
                        end
                    else
                        local e = findEnemy({q[1], q[3]})
                        if e then
                            repeat Attack.Kill(e,true); task.wait()
                            until not optVal("AutoFarmLevel",false) or not isAlive(e)
                        else
                            local sp = WorldOrigin:FindFirstChild("EnemySpawns")
                            if sp then
                                for _, s in pairs(sp:GetChildren()) do
                                    if string.find(s.Name, q[3]) then
                                        tp(s.CFrame*CFrame.new(0,20,0)); break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if optVal("AutoFarmNearest",false) then
                local mr = optVal("NearestRange","Infinite") == "Infinite" and math.huge
                    or tonumber(optVal("NearestRange","Infinite"))
                local n, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d <= mr then nd=d; n=e end
                    end
                end
                if n then Attack.Kill(n, true) end
            end

            if optVal("AutoFactory",false) then
                local c = findEnemy({"Core"})
                if c then Attack.Kill(c,true) else tp(CFrame.new(502,143,-379)) end
            end

            if optVal("AutoEctoplasm",false) then
                local e = findEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
                if e then Attack.Kill(e,true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(923,126,32852)) end
            end

            if optVal("AutoCollectChest",false) then
                if optVal("StopRareItems",true) and
                    (hasTool("God's Chalice") or hasTool("Fist of Darkness") or hasTool("Sweet Chalice")) then
                    if Options.AutoCollectChest then Options.AutoCollectChest:SetValue(false) end
                else
                    local n, nd = nil, math.huge
                    for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                        if not c:GetAttribute("IsDisabled") then
                            local ok2, pv = pcall(function() return c:GetPivot() end)
                            if ok2 and pv then
                                local d = (pv.Position - Root.Position).Magnitude
                                if d < nd then nd=d; n=c end
                            end
                        end
                    end
                    if n then tp(n:GetPivot())
                    elseif optVal("AutoHopNoChest",false) then
                        pcall(function()
                            local d = HttpService:JSONDecode(game:HttpGet(
                                "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                            for _, s in pairs(d.data) do
                                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                    TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
                                end
                            end
                        end)
                    end
                end
            end

            if optVal("AutoCollectBerry",false) then
                for _, b in pairs(Map:GetDescendants()) do
                    if b.Name == "Berries" then
                        for i = 1, 8 do
                            if b:GetAttribute("_BerryCFrame"..i) then tp(b.Parent.WorldPivot) end
                        end
                    end
                end
            end

            if optVal("AutoMastery",false) then
                local m = optVal("MasteryMode","Level")
                equipByTip(optVal("MasteryWeapon","Melee"))
                local e
                if m == "Bone" then
                    e = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                elseif m == "Cake Prince" then
                    e = findEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
                elseif m == "Nearest" then
                    local nd = math.huge
                    for _, mm in pairs(Enemies:GetChildren()) do
                        if isAlive(mm) and mm:FindFirstChild("HumanoidRootPart") then
                            local d = (mm.HumanoidRootPart.Position - Root.Position).Magnitude
                            if d < nd and d < 3500 then nd=d; e=mm end
                        end
                    end
                end
                if e then Attack.Kill(e,true) end
            end

            if optVal("AutoMaterial",false) and materialList then
                local md = {
                    ["Angel Wings"]={"Royal Soldier","Royal Squad"},
                    ["Leather + Scrap Metal"]={"Pirate","Brute","Marine Captain","Jungle Pirate","Forest Pirate"},
                    ["Magma Ore"]={"Military Soldier","Military Spy","Magma Ninja","Lava Pirate"},
                    ["Fish Tail"]={"Fishman Warrior","Fishman Commando","Fishman Captain","Fishman Raider"},
                    ["Mystic Droplet"]={"Water Fighter"},
                    ["Radioactive Material"]={"Factory Staff"},
                    ["Vampire Fang"]={"Vampire"},
                    ["Gunpowder"]={"Pistol Billionaire"},
                    ["Mini Tusk"]={"Mythological Pirate"},
                    ["Conjured Cocoa"]={"Chocolate Bar Battler","Cocoa Warrior"},
                    ["Dragon Scale"]={"Dragon Crew Archer","Dragon Crew Warrior"}
                }
                local mons = md[optVal("MaterialSel", materialList[1])]
                if mons then local e = findEnemy(mons); if e then Attack.Kill(e,true) end end
            end

            if optVal("AutoBoss",false) and bossList then
                local b = findEnemy({optVal("BossSel", bossList[1])})
                if b then Attack.Kill(b,true) end
            end
            if optVal("AutoAllBoss",false) and bossList then
                local b = findEnemy(bossList); if b then Attack.Kill(b,true) end
            end
            if optVal("AutoCakePrince",false) then
                local cm = findEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then Attack.Kill(cm,true) end
                local cp = findEnemy({"Cake Prince","Dough King"})
                if cp then Attack.Kill(cp,true) end
            end
            if optVal("AutoDoughKing",false) then
                local dk = findEnemy({"Dough King"}); if dk then Attack.Kill(dk,true) end
            end
            if optVal("AutoBone",false) then
                local b = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then Attack.Kill(b,true) else tp(CFrame.new(-9516,142,5536)) end
            end
            if optVal("AutoSoulReaper",false) then
                local sr = findEnemy({"Soul Reaper"})
                if sr then Attack.Kill(sr,true)
                elseif not hasTool("Hallow Essence") then
                    CommF_:InvokeServer("Bones","Buy",1,1)
                else
                    tp(CFrame.new(-8932,146,6062)); task.wait(0.5)
                    equipByTip("Melee")
                end
            end
            if optVal("AutoElite",false) then
                local el = findEnemy({"Diablo","Deandre","Urban"})
                if el then Attack.Kill(el,true)
                else pcall(function() CommF_:InvokeServer("EliteHunter") end) end
            end
            if optVal("AutoPiratesSea",false) then
                local b = findEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then Attack.Kill(b,true) else tp(CFrame.new(-5556,314,-2988)) end
            end
            if optVal("AutoRipIndra",false) then
                local ri = findEnemy({"rip_indra"})
                if ri then Attack.Kill(ri,true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097,316,-3142)) end
            end
            if optVal("AutoRainbowHaki",false) then
                local q = MainGui:FindFirstChild("Quest")
                if q and not q.Visible then
                    tp(CFrame.new(-11892,930,-8760))
                    if getDist(CFrame.new(-11892,930,-8760)) < 10 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local e = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if e then Attack.Kill(e,true) end
                end
            end
            if optVal("AutoCitizen",false) then
                local q = MainGui:FindFirstChild("Quest")
                if q and not q.Visible then
                    tp(CFrame.new(-11893.7,929.66,-8760.59))
                    if getDist(CFrame.new(-11893.7,929.66,-8760.59)) < 8 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local m = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if m then Attack.Kill(m,true) end
                end
            end
            if optVal("AutoTryLuck",false) then
                local p = CFrame.new(-8761,164,6161); tp(p)
                if getDist(p) < 5 then CommF_:InvokeServer("gravestoneEvent",1) end
            end
            if optVal("AutoPray",false) then
                local p = CFrame.new(-8761,164,6161); tp(p)
                if getDist(p) < 5 then CommF_:InvokeServer("gravestoneEvent",2) end
            end
        end)
    end
end)

--// FAST ATTACK
task.spawn(function()
    while task.wait() do
        pcall(function()
            if not optVal("FastAttack",false) or not Net then return end
            if not LocalPlayer.Character or not Root then return end
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool or not tool.ToolTip or tool.ToolTip == "Gun" or tool.ToolTip == "Blox Fruit" then return end
            local ra = Net:FindFirstChild("RE/RegisterAttack")
            local rh = Net:FindFirstChild("RE/RegisterHit")
            if not ra or not rh then return end
            local hits = {}
            for _, e in pairs(Enemies:GetChildren()) do
                if isAlive(e) and e:FindFirstChild("HumanoidRootPart")
                    and (e.HumanoidRootPart.Position - Root.Position).Magnitude <= 60 then
                    table.insert(hits, {e, e:FindFirstChild("Head") or e.HumanoidRootPart})
                end
            end
            if #hits > 0 then
                pcall(function() ra:FireServer(0); rh:FireServer(hits[1][2], hits) end)
            end
        end)
    end
end)

--// KILL AURA
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not optVal("KillAura",false) or not Root then return end
            pcall(function()
                if sethiddenproperty then sethiddenproperty(LocalPlayer,"SimulationRadius",math.huge) end
            end)
            for _, e in pairs(Enemies:GetChildren()) do
                if isAlive(e) and e:FindFirstChild("HumanoidRootPart")
                    and getDist(e.HumanoidRootPart.Position) <= 500 then
                    pcall(function()
                        if e:FindFirstChild("Humanoid") then e.Humanoid.Health = 0 end
                        e:BreakJoints()
                    end)
                end
            end
        end)
    end
end)

--// FISHING
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if optVal("AutoEquipRod",false) and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        LocalPlayer.Character.Humanoid:EquipTool(t); break
                    end
                end
            end
            if optVal("AutoBuyBait",false) and Net then
                pcall(function()
                    local RF = Net:FindFirstChild("RF/Craft")
                    if RF then RF:InvokeServer("Craft", optVal("FishingBait","Basic Bait"), {}) end
                end)
            end
            if optVal("AutoFishing",false) and tool
                and tool:GetAttribute("InventoryCategory") == "Rod" then
                if tool:GetAttribute("SkillChargeAlpha")
                    and tool:GetAttribute("SkillChargeAlpha") >= 1 and Net then
                    pcall(function() Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true) end)
                end
                local st = tool:GetAttribute("State")
                local FR = ReplicatedStorage:FindFirstChild("FishReplicated")
                FR = FR and FR:FindFirstChild("FishingRequest")
                if FR then
                    if st == "ReeledIn" then
                        pcall(function()
                            FR:InvokeServer("StartCasting"); task.wait(0.7)
                            local hrp = LocalPlayer.Character.HumanoidRootPart
                            local ray = Ray.new(LocalPlayer.Character.Head.Position, hrp.CFrame.LookVector * 100)
                            local _, hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Characters, Enemies})
                            if hit then FR:InvokeServer("CastLineAtLocation", hit, 100, true) end
                        end)
                    elseif st == "Biting" then
                        pcall(function()
                            FR:InvokeServer("Catching", true); task.wait(0.25); FR:InvokeServer("Catch", 1)
                        end)
                    end
                end
            end
            if Net then
                if optVal("AutoFishingQuest",false) then
                    pcall(function()
                        local RF = Net:FindFirstChild("RF/JobsRemoteFunction")
                        if RF then
                            local g = PlayerGui:FindFirstChild("Quest") or PlayerGui:FindFirstChild("QuestGui")
                            if not g or not g.Visible then RF:InvokeServer("FishingNPC","Angler","AskQuest") end
                        end
                    end)
                end
                if optVal("AutoFishComplete",false) then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","FinishQuest") end)
                end
                if optVal("AutoSellFish",false) then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellFish") end)
                end
                if optVal("AutoSellCorrupt",false) then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellCorruptedFish") end)
                end
                if optVal("SpamSkillZ",false) then
                    pcall(function() Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true) end)
                end
            end
        end)
    end
end)

--// STATS
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Data and Data:FindFirstChild("Points") then
                for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                    if optVal("autoStat_"..s,false) and Data.Points.Value > 0 then
                        CommF_:InvokeServer("AddPoint",
                            s == "Blox Fruit" and "Demon Fruit" or s,
                            tonumber(optVal("StatsVal",10)) or 10)
                    end
                end
            end
        end)
    end
end)

--// ESP
task.spawn(function()
    local ESPNum = math.random(100000,999999)
    local function cESP(part, color, label)
        if not part or part:FindFirstChild("FarmESP"..ESPNum) then return end
        local bg = Instance.new("BillboardGui")
        bg.Name = "FarmESP"..ESPNum
        bg.Size = UDim2.new(0,120,0,50)
        bg.StudsOffset = Vector3.new(0,2,0)
        bg.AlwaysOnTop = true
        bg.Adornee = part
        bg.Parent = part
        local tl = Instance.new("TextLabel", bg)
        tl.Size = UDim2.new(1,0,1,0)
        tl.BackgroundTransparency = 1
        tl.TextColor3 = color or Color3.fromRGB(255,255,255)
        tl.TextStrokeTransparency = 0.3
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.Text = label
    end
    while task.wait(1.5) do
        pcall(function()
            if optVal("EspPlayer",false) then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        cESP(p.Character.Head, Color3.fromRGB(0,255,0),
                            string.format("%s [%d]", p.Name, math.floor(getDist(p.Character.Head.Position)/3)))
                    end
                end
            end
            if optVal("EspChest",false) then
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not c:GetAttribute("IsDisabled") then
                        local p = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
                        if p then cESP(p, Color3.fromRGB(255,255,0),
                            "Chest ["..math.floor(getDist(p.Position)/3).."]") end
                    end
                end
            end
            if optVal("EspFruit",false) then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        cESP(f.Handle, Color3.fromRGB(255,100,100), f.Name)
                    end
                end
            end
            if optVal("EspEvent",false) and WorldOrigin:FindFirstChild("Locations") then
                for _, i in pairs(WorldOrigin.Locations:GetChildren()) do
                    if (i.Name=="Mirage Island" or i.Name=="Prehistoric Island"
                        or i.Name=="Kitsune Island" or i.Name=="Frozen Dimension")
                        and i:IsA("BasePart") then
                        cESP(i, Color3.fromRGB(150,255,150), i.Name)
                    end
                end
            end
        end)
    end
end)

--// FRUITS
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if optVal("AutoRandomFruit",false) then CommF_:InvokeServer("Cousin","Buy") end
            if optVal("AutoStoreFruit",false) then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote") then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if optVal("AutoDropFruit",false) then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name,"Fruit") and t:FindFirstChild("EatRemote") then
                        t.EatRemote:InvokeServer("Drop")
                    end
                end
            end
            if optVal("AutoFindFruit",false) and Root then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        tp(f.Handle.CFrame); break
                    end
                end
            end
        end)
    end
end)

--// ABILITIES
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            if optVal("AutoBuso",false) and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                CommF_:InvokeServer("Buso")
            end
            if optVal("AutoKen",false) and CommE then CommE:FireServer("Ken", true) end
            if optVal("AutoTurnV3",false) and CommE then CommE:FireServer("ActivateAbility") end
            if optVal("AutoTurnV4",false) and LocalPlayer.Character:FindFirstChild("RaceEnergy")
                and LocalPlayer.Character.RaceEnergy.Value == 1 then
                sendKey("Y")
            end
            if optVal("DisableNotify",false) and PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = false
            end
        end)
    end
end)

--// CHIPS
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if optVal("AutoBuyChip",false) then
                if not hasTool("Special Microchip") then
                    if optVal("RaidChip","Flame") == "Rumble" then
                        CommF_:InvokeServer("ThunderGodTalk")
                    else
                        CommF_:InvokeServer("RaidsNpc","Select", optVal("RaidChip","Flame"))
                    end
                end
            end
            if optVal("AutoAwake",false) then
                CommF_:InvokeServer("Awakener","Check")
                CommF_:InvokeServer("Awakener","Awaken")
            end
        end)
    end
end)

--// PLAYER HUNTER
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if optVal("AutoGetPlayerQuest",false) then CommF_:InvokeServer("PlayerHunter") end
            if optVal("AutoKillPlayerQuest",false) then
                local q = MainGui:FindFirstChild("Quest")
                if q and q.Visible then
                    for _, c in pairs(Characters:GetChildren()) do
                        if c.Name ~= LocalPlayer.Name and isAlive(c) then
                            local txt = q.Container and q.Container.QuestTitle
                                and q.Container.QuestTitle.Title
                                and q.Container.QuestTitle.Title.Text or ""
                            if string.find(txt, c.Name) then Attack.Kill(c, true) end
                        end
                    end
                else
                    CommF_:InvokeServer("PlayerHunter")
                end
            end
            if optVal("AutoPvP",false) then
                local pvp = MainGui:FindFirstChild("PvpDisabled")
                if pvp and pvp.Visible then CommF_:InvokeServer("EnablePvp") end
            end
        end)
    end
end)

--// TELEPORT ISLAND
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if optVal("TweenIsland",false) and optVal("IslandSel",false)
                and WorldOrigin:FindFirstChild("Locations") then
                for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
                    if l.Name == optVal("IslandSel","") then
                        tp(l.CFrame * CFrame.new(0,30,0))
                    end
                end
            end
        end)
    end
end)

--// VISUAL
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if optVal("RemoveDamage",false) then
                local dmg = ReplicatedStorage.Assets and ReplicatedStorage.Assets.GUI
                    and ReplicatedStorage.Assets.GUI.DamageCounter
                if dmg then dmg.Enabled = false end
            end
            if PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = not optVal("RemoveNotify", false)
            end
        end)
    end
end)

--// ANTI ADMIN
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if not optVal("AntiAdmin",false) then return end
            if #Players:GetPlayers() <= 1 then return end
            local bl = {"red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock",
                "oofficialnoobie","Uzoth","Azarth","arlthmetic","Death_King","Lunoven",
                "TheGreateAced","rip_fud","drip_mama"}
            for _, p in pairs(Players:GetPlayers()) do
                if table.find(bl, p.Name) then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer); break
                end
            end
        end)
    end
end)

--// NO CLIP
task.spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            if optVal("NoClip",false) and LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end)

--// Aimbot hook
task.spawn(function()
    pcall(function()
        if not getrawmetatable or not setreadonly then return end
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local m = getnamecallmethod()
            local a = {...}
            if _G.AimbotEnabled and m == "FireServer"
                and tostring(self) == "RemoteEvent"
                and typeof(a[2]) == "Vector3" then
                local tgt
                if optVal("AimMethod","Aim Player") == "Aim Player" then
                    tgt = Players:FindFirstChild(optVal("AimPlayer",""))
                elseif optVal("AimMethod","Aim Player") == "Nearest Aim" then
                    local nd, best = math.huge, nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character
                            and p.Character:FindFirstChild("HumanoidRootPart")
                            and p.Team ~= LocalPlayer.Team then
                            local d = getDist(p.Character.HumanoidRootPart.Position)
                            if d < nd then nd=d; best=p end
                        end
                    end
                    tgt = best
                end
                if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
                    a[2] = tgt.Character.HumanoidRootPart.Position
                    return old(self, unpack(a))
                end
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end)

--// SAVE MANAGER
task.wait(0.5)
pcall(function() SaveManager:SetLibrary(Fluent) end)
pcall(function() InterfaceManager:SetLibrary(Fluent) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() InterfaceManager:SetFolder("BloxFruitsFarm") end)
pcall(function() SaveManager:SetFolder("BloxFruitsFarm/BloxFruits") end)
pcall(function() InterfaceManager:BuildInterfaceSection(Tabs.Settings) end)
pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)
pcall(function() Window:SelectTab(1) end)
pcall(function() SaveManager:LoadAutoloadConfig() end)

notify("BF-Farm", "✅ Tudo pronto!", 6)
warn("[BF-Farm] Carregado.")
