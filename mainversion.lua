--=====================================================================
-- BLOX FRUITS FARM - FLUENT UI - COMPLETO
-- Base: Speed Hub X + OK Hub (mesclados)
--=====================================================================

--// Fluent UI com fallback
local Fluent
local urls = {
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua"
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
}
for _, url in ipairs(urls) do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and res then Fluent = res; break end
end
if not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro", Text = "Fluent nao carregou", Duration = 5
    })
    return
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Farm Full",
    SubTitle = "Speed Hub X + OK Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

--// Serviços
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local CollectionService   = game:GetService("CollectionService")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")
local StarterGui          = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

repeat task.wait() until game:IsLoaded()

local Cfg = {}

local Remotes    = ReplicatedStorage:WaitForChild("Remotes")
local CommF_     = Remotes:WaitForChild("CommF_")
local CommE      = Remotes:WaitForChild("CommE")
local Modules    = ReplicatedStorage:WaitForChild("Modules")
local Net        = Modules:WaitForChild("Net")
local Enemies    = workspace:WaitForChild("Enemies")
local Characters = workspace:WaitForChild("Characters")
local WorldOrigin= workspace:WaitForChild("_WorldOrigin")
local Map        = workspace:WaitForChild("Map")

local PlaceId = game.PlaceId
local Sea1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local Sea2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local Sea3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)
local World1, World2, World3 = Sea1, Sea2, Sea3

local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart")
    Hum  = c:WaitForChild("Humanoid")
end
if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindChar)

local Data       = LocalPlayer:WaitForChild("Data")
local Leaderstats= LocalPlayer:WaitForChild("leaderstats")
local Level      = Data:WaitForChild("Level")
local Beli       = Data:WaitForChild("Beli")
local Frags      = Data:WaitForChild("Fragments")
local RaceData   = Data:WaitForChild("Race")

--=====================================================================
-- TWEEN SYSTEM
--=====================================================================
local tweenBlock = Instance.new("Part")
tweenBlock.Name = "FarmTweenBlock"
tweenBlock.Size = Vector3.new(1,1,1)
tweenBlock.Anchored = true
tweenBlock.CanCollide = false
tweenBlock.CanTouch = false
tweenBlock.Transparency = 1
tweenBlock.Parent = workspace

local shouldTween = false
local currentTween

local function tp(CF)
    if not Root or not LocalPlayer.Character then return end
    if typeof(CF) == "Vector3" then CF = CFrame.new(CF) end
    if typeof(CF) ~= "CFrame" then return end
    pcall(function()
        if currentTween then currentTween:Cancel() end
        local dist = (CF.Position - tweenBlock.Position).Magnitude
        local speed = tonumber(Cfg["Tween Speed"]) or 300
        currentTween = TweenService:Create(tweenBlock, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = CF})
        currentTween:Play()
    end)
end

local function instantTP(CF)
    if not Root then return end
    if typeof(CF) == "Vector3" then CF = CFrame.new(CF) end
    Root.CFrame = CF
end
_g.tp = tp
_g.instantTP = instantTP

task.spawn(function()
    while task.wait() do
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
        else
            if Root and Root:FindFirstChild("BodyClip") then Root.BodyClip:Destroy() end
        end
    end
end)

--=====================================================================
-- AUXILIARES
--=====================================================================
local function isAlive(model)
    if not model then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end
_g.isAlive = isAlive

local function getDist(pos)
    if not Root then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    if typeof(pos) ~= "Vector3" then return math.huge end
    return (Root.Position - pos).Magnitude
end

local function activateHaki()
    if not LocalPlayer.Character then return end
    if not LocalPlayer.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
end

local function equipToolByName(name)
    local bp = LocalPlayer.Backpack
    if not bp or not LocalPlayer.Character then return end
    local t = bp:FindFirstChild(name)
    local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if t and h then h:EquipTool(t) end
end
_g.equipToolByName = equipToolByName

local function equipSelectedTool()
    if not LocalPlayer.Character then return end
    local tip = Cfg["Weapon Tool"] or "Melee"
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then equipToolByName(t.Name); return end
    end
end

local function equipByTip(tip)
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then equipToolByName(t.Name); return end
    end
end
_g.equipByTip = equipByTip

local function sendKey(key, hold)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(hold or 0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end
_g.sendKey = sendKey

local function hasTool(name)
    if not LocalPlayer.Character then return false end
    return LocalPlayer.Backpack:FindFirstChild(name) ~= nil or LocalPlayer.Character:FindFirstChild(name) ~= nil
end
_g.hasTool = hasTool

local function getMaterial(name)
    for _, item in pairs(CommF_:InvokeServer("getInventory")) do
        if type(item) == "table" and item.Type == "Material" and item.Name == name then
            return item.Count
        end
    end
    return 0
end
_g.getMaterial = getMaterial

local function findEnemy(names, maxDist)
    if not Root then return nil end
    local map = {}
    for _, n in ipairs(names) do map[n] = true end
    local nearest, dist = nil, maxDist or math.huge
    for _, e in pairs(Enemies:GetChildren()) do
        if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local short = e.Name:match("^(.-)%s*%[") or e.Name
            if map[e.Name] or map[short] then
                local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                if d < dist then dist = d; nearest = e end
            end
        end
    end
    return nearest
end
_g.findEnemy = findEnemy

local function getRaceInfo()
    local race = tostring(RaceData.Value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("RaceTransformed") then return race.." V4" end
    pcall(function()
        if CommF_:InvokeServer("Wenlocktoad","1") == -2 then race = race.." V3" end
        if CommF_:InvokeServer("Alchemist","1") == -2 then race = race.." V2" end
    end)
    if not race:find("V") then race = race.." V1" end
    return race
end

--=====================================================================
-- BRING MOB
--=====================================================================
local function bringEnemy(target, centerCF)
    if not Cfg["Bring Mob"] or not target or not centerCF then return end
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)
    local radius = tonumber(Cfg["Bring Radius"]) or 300
    local r2 = radius * radius
    local center = centerCF.Position
    for _, e in pairs(Enemies:GetChildren()) do
        if e.Name == target.Name and isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local rt = e.HumanoidRootPart
            local h = e:FindFirstChildOfClass("Humanoid")
            local d = (rt.Position - center).Magnitude
            if d*d <= r2 and h then
                rt.CanCollide = false
                h.WalkSpeed = 0
                h.JumpPower = 0
                rt.CFrame = CFrame.new(center + Vector3.new(math.random(-3,3), 3, math.random(-3,3)))
            end
        end
    end
end
_g.bringEnemy = bringEnemy

--=====================================================================
-- ATTACK SYSTEM
--=====================================================================
local Attack = {}
Attack.Kill = function(model, enabled)
    if not model or not enabled then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    equipSelectedTool()
    activateHaki()
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local cf
    if tool and tool.ToolTip == "Blox Fruit" then
        cf = hrp.CFrame * CFrame.new(0, 20, 2)
    else
        cf = hrp.CFrame * CFrame.new(0, 30, 2)
    end
    tp(cf)
    bringEnemy(model, hrp.CFrame)
    for _, k in ipairs({"Z","X","C","V","F"}) do
        if Cfg["Auto Skill "..k] then sendKey(k) end
    end
end
_g.Attack = Attack

Attack.KillSea = function(model, enabled)
    if not model or not enabled then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local waterPlane = Map:FindFirstChild("WaterBase-Plane")
    if not waterPlane then return end
    tp(CFrame.new(hrp.Position.X, waterPlane.Position.Y + 200, hrp.Position.Z))
    equipSelectedTool()
    activateHaki()
    for _, k in ipairs({"Z","X","C","V","F"}) do
        if Cfg["Auto Skill "..k] then sendKey(k) end
    end
end

-- Fast Attack loop
task.spawn(function()
    while task.wait() do
        if Cfg["Fast Attack"] and LocalPlayer.Character and Root then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool.ToolTip and tool.ToolTip ~= "Gun" and tool.ToolTip ~= "Blox Fruit" then
                local hits = {}
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d <= 60 then
                            local head = e:FindFirstChild("Head") or e.HumanoidRootPart
                            table.insert(hits, {e, head})
                        end
                    end
                end
                if #hits > 0 then
                    pcall(function()
                        Net["RE/RegisterAttack"]:FireServer(0)
                        Net["RE/RegisterHit"]:FireServer(hits[1][2], hits)
                    end)
                end
            end
        end
    end
end)

--=====================================================================
-- QUEST INFO
--=====================================================================
local Quests = require(ReplicatedStorage.Quests)
local Guide  = require(ReplicatedStorage.GuideModule)

local function getQuestInfo()
    local lvl = Level.Value
    local team = tostring(LocalPlayer.Team)
    local qname, mob, npcCF, id, mobSpawn
    if lvl >= 1 and lvl <= 9 then
        if team == "Marines" then
            mob = "Trainee"; qname = "MarineQuest"; id = 1; npcCF = CFrame.new(-2709, 24, 2104); mobSpawn = "Trainee"
        else
            mob = "Bandit"; qname = "BanditQuest1"; id = 1; npcCF = CFrame.new(1059, 16, 1549); mobSpawn = "Bandit"
        end
        return {mob, npcCF, mobSpawn, qname, id, 1}
    end
    local curLvl = 0
    for k, v in pairs(Guide.Data.NPCList) do
        for i, lv in ipairs(v.Levels) do
            if lvl >= lv and lv > curLvl then
                curLvl = lv
                npcCF = k.CFrame
            end
        end
    end
    for k, quest in pairs(Quests) do
        for k2, v in pairs(quest) do
            if v.LevelReq == curLvl then
                qname = k; id = k2
                for k3 in pairs(v.Task) do
                    mob = k3
                    mobSpawn = string.split(k3, " [Lv. "..v.LevelReq.."]")[1]
                end
            end
        end
    end
    return {mob, npcCF, mobSpawn, qname, id, curLvl}
end

--=====================================================================
-- UI TABS
--=====================================================================
local Tabs = {
    Info     = Window:AddTab({ Title = "Info & Status", Icon = "info" }),
    Main     = Window:AddTab({ Title = "Main", Icon = "sword" }),
    Fish     = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Quest    = Window:AddTab({ Title = "Quest & Item", Icon = "scroll" }),
    Volcano  = Window:AddTab({ Title = "Volcano Event", Icon = "flame" }),
    Esp      = Window:AddTab({ Title = "Stats & ESP", Icon = "eye" }),
    Raid     = Window:AddTab({ Title = "Fruit & Raid", Icon = "apple" }),
    LocalP   = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    Travel   = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Shop     = Window:AddTab({ Title = "Shopping", Icon = "cart" }),
    Misc     = Window:AddTab({ Title = "Misc", Icon = "settings-2" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

--=====================================================================
-- TAB INFO & STATUS
--=====================================================================
Tabs.Info:AddSection("Status do Servidor")

local timePara   = Tabs.Info:AddParagraph({Title = "Horario", Content = "..."})
local gameTimeP  = Tabs.Info:AddParagraph({Title = "Game Time", Content = "..."})
local playerP    = Tabs.Info:AddParagraph({Title = "Jogadores", Content = "0/12"})
local mirageP    = Tabs.Info:AddParagraph({Title = "Mirage Island", Content = "..."})
local kitsuneP   = Tabs.Info:AddParagraph({Title = "Kitsune Island", Content = "..."})
local prehisP    = Tabs.Info:AddParagraph({Title = "Prehistoric Island", Content = "..."})
local frozenP    = Tabs.Info:AddParagraph({Title = "Frozen Dimension", Content = "..."})
local moonP      = Tabs.Info:AddParagraph({Title = "Moon", Content = "0/5"})
local bonesP     = Tabs.Info:AddParagraph({Title = "Bones", Content = "0"})
local eliteP     = Tabs.Info:AddParagraph({Title = "Elite Progress", Content = "0/30"})
local raceP      = Tabs.Info:AddParagraph({Title = "Race", Content = "..."})
local statusP    = Tabs.Info:AddParagraph({Title = "Status", Content = "..."})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            timePara:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
            local gt = math.floor(workspace.DistributedGameTime)
            gameTimeP:SetDesc(string.format("%dh %dm %ds", math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
            playerP:SetDesc(#Players:GetPlayers().."/12")
            mirageP:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "Spawned" or "Not Spawned")
            kitsuneP:SetDesc(Map:FindFirstChild("KitsuneIsland") and "Spawned" or "Not Spawned")
            prehisP:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "Spawned" or "Not Spawned")
            frozenP:SetDesc(WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "Spawned" or "Not Spawned")
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            local moonMap = {
                ["9709149431"] = "5/5 Full Moon",
                ["9709149052"] = "4/5",
                ["9709143733"] = "3/5",
                ["9709150401"] = "2/5",
                ["9709149680"] = "1/5 New Moon"
            }
            for k, v in pairs(moonMap) do
                if moon:find(k) then moonP:SetDesc(v); break end
            end
            local b = CommF_:InvokeServer("Bones", "Check")
            if b then bonesP:SetDesc(tostring(b)) end
            local ep = CommF_:InvokeServer("EliteHunter", "Progress")
            if ep then eliteP:SetDesc(tostring(ep).."/30") end
            raceP:SetDesc(getRaceInfo())
            statusP:SetDesc(string.format("Lv %d | Beli %s | Frags %s", Level.Value, tostring(Beli.Value), tostring(Frags.Value)))
        end)
    end
end)

--=====================================================================
-- TAB MAIN
--=====================================================================
Tabs.Main:AddSection("Farm Principal")

Tabs.Main:AddDropdown("WeaponTool", {
    Title = "Weapon Tool",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
}):OnChanged(function(v) Cfg["Weapon Tool"] = v end)

Tabs.Main:AddToggle("AutoFarmLevel", {Title = "Auto Farm Level", Default = false}):OnChanged(function(v)
    Cfg["Auto Farm Level"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoFarmNearest", {Title = "Auto Farm Nearest", Default = false}):OnChanged(function(v)
    Cfg["Auto Farm Nearest"] = v
    shouldTween = v
end)

Tabs.Main:AddDropdown("NearestRange", {
    Title = "Search Range",
    Values = {"1000","2000","3000","Infinite"},
    Default = "Infinite"
}):OnChanged(function(v) Cfg["Nearest Range"] = v end)

Tabs.Main:AddToggle("AutoFactory", {Title = "Auto Factory Raid", Default = false}):OnChanged(function(v)
    Cfg["Auto Factory"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoEctoplasm", {Title = "Auto Farm Ectoplasm", Default = false}):OnChanged(function(v)
    Cfg["Auto Ectoplasm"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Coleta")

Tabs.Main:AddToggle("AutoCollectChest", {Title = "Auto Collect Chest", Default = false}):OnChanged(function(v)
    Cfg["Auto Collect Chest"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoHopNoChest", {Title = "Auto Hop If No Chest", Default = false}):OnChanged(function(v)
    Cfg["Auto Hop No Chest"] = v
end)

Tabs.Main:AddToggle("StopRareItems", {Title = "Stop on Rare Items", Default = true}):OnChanged(function(v)
    Cfg["Stop on Rare Items"] = v
end)

Tabs.Main:AddToggle("AutoCollectBerry", {Title = "Auto Collect Berry", Default = false}):OnChanged(function(v)
    Cfg["Auto Collect Berry"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Farm Mastery")

Tabs.Main:AddDropdown("MasteryMode", {
    Title = "Modo Mastery",
    Values = {"Level","Bone","Cake Prince","Nearest"},
    Default = "Level"
}):OnChanged(function(v) Cfg["Mastery Mode"] = v end)

Tabs.Main:AddDropdown("MasteryWeapon", {
    Title = "Arma Mastery",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
}):OnChanged(function(v) Cfg["Mastery Weapon"] = v end)

Tabs.Main:AddDropdown("MasterySkills", {
    Title = "Skills",
    Values = {"Z","X","C","V","F"},
    Default = {"Z","X","C","V"},
    Multi = true
}):OnChanged(function(v) Cfg["Mastery Skills"] = v end)

Tabs.Main:AddToggle("AutoMastery", {Title = "Auto Farm Mastery", Default = false}):OnChanged(function(v)
    Cfg["Auto Farm Mastery"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Farm Material")

local materialList = Sea1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or Sea2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang","Ectoplasm"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale","Demonic Wisp"}

Tabs.Main:AddDropdown("MaterialSel", {
    Title = "Escolher Material",
    Values = materialList,
    Default = materialList[1]
}):OnChanged(function(v) Cfg["Material"] = v end)

Tabs.Main:AddToggle("AutoMaterial", {Title = "Auto Farm Material", Default = false}):OnChanged(function(v)
    Cfg["Auto Farm Material"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Farm Boss")

local bossList = Sea1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"}
    or Sea2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}

Tabs.Main:AddDropdown("BossSel", {
    Title = "Escolher Boss",
    Values = bossList,
    Default = bossList[1]
}):OnChanged(function(v) Cfg["Boss"] = v end)

Tabs.Main:AddToggle("AutoBoss", {Title = "Auto Attack Boss", Default = false}):OnChanged(function(v)
    Cfg["Auto Attack Boss"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoAllBoss", {Title = "Auto Attack All Boss", Default = false}):OnChanged(function(v)
    Cfg["Auto Attack All Boss"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Cake Prince / Dough King")

Tabs.Main:AddToggle("AutoCakePrince", {Title = "Auto Cake Prince", Default = false}):OnChanged(function(v)
    Cfg["Auto Cake Prince"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoSummonCake", {Title = "Auto Summon Cake Prince", Default = false}):OnChanged(function(v)
    Cfg["Auto Summon Cake"] = v
end)

Tabs.Main:AddToggle("AutoDoughKing", {Title = "Auto Dough King", Default = false}):OnChanged(function(v)
    Cfg["Auto Dough King"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Bones / Soul Reaper")

Tabs.Main:AddToggle("AutoBone", {Title = "Auto Farm Bone", Default = false}):OnChanged(function(v)
    Cfg["Auto Farm Bone"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoSoulReaper", {Title = "Auto Soul Reaper", Default = false}):OnChanged(function(v)
    Cfg["Auto Soul Reaper"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoRandomBone", {Title = "Auto Random Bones", Default = false}):OnChanged(function(v)
    Cfg["Auto Random Bone"] = v
end)

Tabs.Main:AddToggle("AutoTryLuck", {Title = "Auto Try Luck", Default = false}):OnChanged(function(v)
    Cfg["Auto Try Luck"] = v
end)

Tabs.Main:AddToggle("AutoPray", {Title = "Auto Pray Gravestone", Default = false}):OnChanged(function(v)
    Cfg["Auto Pray"] = v
end)

Tabs.Main:AddSection("Elite Hunter")

Tabs.Main:AddToggle("AutoElite", {Title = "Auto Elite Hunter", Default = false}):OnChanged(function(v)
    Cfg["Auto Elite Hunter"] = v
    shouldTween = v
end)

Tabs.Main:AddSection("Outros Farms")

Tabs.Main:AddToggle("AutoPiratesSea", {Title = "Auto Pirates Sea", Default = false}):OnChanged(function(v)
    Cfg["Auto Pirates Sea"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoRipIndra", {Title = "Auto Attack Rip Indra", Default = false}):OnChanged(function(v)
    Cfg["Auto Rip Indra"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoRainbowHaki", {Title = "Auto Rainbow Haki", Default = false}):OnChanged(function(v)
    Cfg["Auto Rainbow Haki"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoTyrant", {Title = "Auto Kill Tyrant of the Skies", Default = false}):OnChanged(function(v)
    Cfg["Auto Tyrant"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoCitizen", {Title = "Auto Citizen Quest", Default = false}):OnChanged(function(v)
    Cfg["Auto Citizen"] = v
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoDragonHunter", {Title = "Auto Dragon Hunter Quest", Default = false}):OnChanged(function(v)
    Cfg["Auto Dragon Hunter"] = v
    shouldTween = v
end)

--=====================================================================
-- LOOP PRINCIPAL DE FARM
--=====================================================================
task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if not LocalPlayer.Character or not Root then return end

            if Cfg["Auto Farm Level"] then
                local q = getQuestInfo()
                if q and q[1] then
                    local quest = PlayerGui.Main:FindFirstChild("Quest")
                    local titleOK = quest and quest.Visible and string.find(quest.Container.QuestTitle.Title.Text, q[1])
                    if not titleOK then
                        if q[2] then
                            tp(q[2])
                            if getDist(q[2]) < 10 then
                                CommF_:InvokeServer("StartQuest", q[4], q[5])
                            end
                        end
                    else
                        local enemy = findEnemy({q[1], q[3]})
                        if enemy then
                            repeat Attack.Kill(enemy, Cfg["Auto Farm Level"])
                                task.wait()
                            until not Cfg["Auto Farm Level"] or not isAlive(enemy)
                        else
                            for _, s in pairs(WorldOrigin.EnemySpawns:GetChildren()) do
                                if string.find(s.Name, q[3]) then tp(s.CFrame * CFrame.new(0,20,0)); break end
                            end
                        end
                    end
                end
            end

            if Cfg["Auto Farm Nearest"] then
                local maxR = Cfg["Nearest Range"] == "Infinite" and math.huge or tonumber(Cfg["Nearest Range"])
                local nearest, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d <= maxR then nd = d; nearest = e end
                    end
                end
                if nearest then Attack.Kill(nearest, true) end
            end

            if Cfg["Auto Factory"] then
                local core = findEnemy({"Core"})
                if core then Attack.Kill(core, true)
                else tp(CFrame.new(502, 143, -379)) end
            end

            if Cfg["Auto Ectoplasm"] then
                local e = findEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
                if e then Attack.Kill(e, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(923, 126, 32852)) end
            end

            if Cfg["Auto Collect Chest"] then
                local chests = CollectionService:GetTagged("_ChestTagged")
                local nearest, nd = nil, math.huge
                for _, c in ipairs(chests) do
                    if not c:GetAttribute("IsDisabled") then
                        local d = (c:GetPivot().Position - Root.Position).Magnitude
                        if d < nd then nd = d; nearest = c end
                    end
                end
                if nearest then tp(nearest:GetPivot())
                elseif Cfg["Auto Hop No Chest"] then
                    pcall(function()
                        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                        for _, s in pairs(data.data) do
                            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
                            end
                        end
                    end)
                end
            end

            if Cfg["Auto Collect Berry"] then
                for _, b in pairs(Map:GetDescendants()) do
                    if b.Name == "Berries" then
                        for i = 1, 8 do
                            if b:GetAttribute("_BerryCFrame"..i) then
                                tp(b.Parent.WorldPivot)
                                for _, child in pairs(b:GetChildren()) do
                                    if getDist(child.WorldPivot) > 5 then tp(child.WorldPivot)
                                    else
                                        for _, d in pairs(child:GetDescendants()) do
                                            if d:IsA("ProximityPrompt") then fireproximityprompt(d) end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if Cfg["Auto Farm Mastery"] then
                local mode = Cfg["Mastery Mode"] or "Level"
                equipByTip(Cfg["Mastery Weapon"] or "Melee")
                local enemy
                if mode == "Level" then
                    local q = getQuestInfo()
                    if q and q[1] then enemy = findEnemy({q[1]}) end
                elseif mode == "Bone" then
                    enemy = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                elseif mode == "Cake Prince" then
                    enemy = findEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
                elseif mode == "Nearest" then
                    local nd = math.huge
                    for _, e in pairs(Enemies:GetChildren()) do
                        if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                            local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                            if d < nd and d < 3500 then nd = d; enemy = e end
                        end
                    end
                end
                if enemy then
                    for _, k in ipairs(Cfg["Mastery Skills"] or {"Z","X","C","V"}) do sendKey(k) end
                    Attack.Kill(enemy, true)
                end
            end

            if Cfg["Auto Farm Material"] and Cfg["Material"] then
                local matData = {
                    ["Angel Wings"] = {"Royal Soldier","Royal Squad"},
                    ["Leather + Scrap Metal"] = {"Pirate","Brute","Marine Captain","Jungle Pirate","Forest Pirate"},
                    ["Magma Ore"] = {"Military Soldier","Military Spy","Magma Ninja","Lava Pirate"},
                    ["Fish Tail"] = {"Fishman Warrior","Fishman Commando","Fishman Captain","Fishman Raider"},
                    ["Mystic Droplet"] = {"Water Fighter"},
                    ["Radioactive Material"] = {"Factory Staff"},
                    ["Vampire Fang"] = {"Vampire"},
                    ["Ectoplasm"] = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"},
                    ["Gunpowder"] = {"Pistol Billionaire"},
                    ["Mini Tusk"] = {"Mythological Pirate"},
                    ["Conjured Cocoa"] = {"Chocolate Bar Battler","Cocoa Warrior"},
                    ["Dragon Scale"] = {"Dragon Crew Archer","Dragon Crew Warrior"},
                    ["Demonic Wisp"] = {"Demonic Soul"}
                }
                local mons = matData[Cfg["Material"]]
                if mons then
                    local e = findEnemy(mons)
                    if e then Attack.Kill(e, true) end
                end
            end

            if Cfg["Auto Attack Boss"] and Cfg["Boss"] then
                local b = findEnemy({Cfg["Boss"]})
                if b then Attack.Kill(b, true) end
            end
            if Cfg["Auto Attack All Boss"] then
                local b = findEnemy(bossList)
                if b then Attack.Kill(b, true) end
            end

            if Cfg["Auto Cake Prince"] then
                local cm = findEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then Attack.Kill(cm, true) end
                local cp = findEnemy({"Cake Prince","Dough King"})
                if cp then Attack.Kill(cp, true) end
            end

            if Cfg["Auto Summon Cake"] then
                pcall(function()
                    local resp = CommF_:InvokeServer("CakePrinceSpawner", true)
                    if resp and string.find(resp, "open the portal now") then
                        CommF_:InvokeServer("CakePrinceSpawner")
                    end
                end)
            end

            if Cfg["Auto Dough King"] then
                local dk = findEnemy({"Dough King"})
                if dk then Attack.Kill(dk, true) end
                if hasTool("God's Chalice") then
                    pcall(function()
                        local resp = CommF_:InvokeServer("SweetChaliceNpc")
                        if resp and string.find(resp, "Where") then
                            local m = findEnemy({"Chocolate Bar Battler","Cocoa Warrior"})
                            if m then Attack.Kill(m, true) end
                        else CommF_:InvokeServer("SweetChaliceNpc") end
                    end)
                end
            end

            if Cfg["Auto Farm Bone"] then
                local b = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-9516, 142, 5536)) end
            end

            if Cfg["Auto Soul Reaper"] then
                local sr = findEnemy({"Soul Reaper"})
                if sr then Attack.Kill(sr, true)
                else
                    if not hasTool("Hallow Essence") then
                        CommF_:InvokeServer("Bones", "Buy", 1, 1)
                    else
                        tp(CFrame.new(-8932, 146, 6062))
                        task.wait(0.5)
                        equipToolByName("Hallow Essence")
                    end
                end
            end

            if Cfg["Auto Random Bone"] then
                CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end

            if Cfg["Auto Try Luck"] then
                local pos = CFrame.new(-8761, 164, 6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 1) end
            end

            if Cfg["Auto Pray"] then
                local pos = CFrame.new(-8761, 164, 6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 2) end
            end

            if Cfg["Auto Elite Hunter"] then
                local elite = findEnemy({"Diablo","Deandre","Urban"})
                if elite then
                    Attack.Kill(elite, true)
                else
                    pcall(function()
                        local resp = CommF_:InvokeServer("EliteHunter")
                        if not resp or string.find(tostring(resp), "Cooldown") then task.wait(5) end
                    end)
                end
            end

            if Cfg["Auto Pirates Sea"] then
                local b = findEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-5556, 314, -2988)) end
            end

            if Cfg["Auto Rip Indra"] then
                local ri = findEnemy({"rip_indra"})
                if ri then Attack.Kill(ri, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097, 316, -3142)) end
            end

            if Cfg["Auto Rainbow Haki"] then
                local quest = PlayerGui.Main.Quest
                if not quest.Visible then
                    tp(CFrame.new(-11892, 930, -8760))
                    if getDist(CFrame.new(-11892, 930, -8760)) < 10 then
                        CommF_:InvokeServer("HornedMan", "Bet")
                    end
                else
                    local mobs = {"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"}
                    local e = findEnemy(mobs)
                    if e then Attack.Kill(e, true) end
                end
            end

            if Cfg["Auto Tyrant"] then
                local t = findEnemy({"Tyrant of the Skies"})
                if t then Attack.Kill(t, true)
                else tp(CFrame.new(-16557, 202, 508)) end
            end

            if Cfg["Auto Citizen"] then
                local quest = PlayerGui.Main.Quest
                if not quest.Visible then
                    tp(CFrame.new(-11893.7, 929.66, -8760.59))
                    if getDist(CFrame.new(-11893.7, 929.66, -8760.59)) < 8 then
                        CommF_:InvokeServer("HornedMan", "Bet")
                    end
                else
                    local m = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if m then Attack.Kill(m, true) end
                end
            end

            if Cfg["Auto Dragon Hunter"] then
                pcall(function()
                    local resp = Net:FindFirstChild("RF/DragonHunter"):InvokeServer({Context = "Check"})
                    if not resp or not resp.Text then
                        Net:FindFirstChild("RF/DragonHunter"):InvokeServer({Context = "RequestQuest"})
                    end
                end)
                local m = findEnemy({"Hydra Enforcer","Venomous Assailant"})
                if m then Attack.Kill(m, true) end
            end
        end)
    end
end)

--=====================================================================
-- TAB FISHING
--=====================================================================
Tabs.Fish:AddSection("Fishing")

Tabs.Fish:AddDropdown("FishingRod", {
    Title = "Escolher Vara",
    Values = {"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default = "Fishing Rod"
}):OnChanged(function(v) Cfg["Fishing Rod"] = v end)

Tabs.Fish:AddToggle("AutoEquipRod", {Title = "Auto Equip Rod", Default = false}):OnChanged(function(v)
    Cfg["Auto Equip Rod"] = v
end)

Tabs.Fish:AddToggle("AutoFishing", {Title = "Auto Fishing", Default = false}):OnChanged(function(v)
    Cfg["Auto Fishing"] = v
end)

Tabs.Fish:AddToggle("AutoSellFish", {Title = "Auto Sell Fish", Default = false}):OnChanged(function(v)
    Cfg["Auto Sell Fish"] = v
end)

Tabs.Fish:AddToggle("AutoSellCorrupt", {Title = "Auto Sell Corrupted Fish", Default = false}):OnChanged(function(v)
    Cfg["Auto Sell Corrupt"] = v
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")

            if Cfg["Auto Equip Rod"] and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        LocalPlayer.Character.Humanoid:EquipTool(t); break
                    end
                end
            end

            if Cfg["Auto Fishing"] and tool and tool:GetAttribute("InventoryCategory") == "Rod" then
                if tool:GetAttribute("SkillChargeAlpha") and tool:GetAttribute("SkillChargeAlpha") >= 1 then
                    pcall(function()
                        Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true)
                    end)
                end
                local state = tool:GetAttribute("State")
                if state == "ReeledIn" then
                    pcall(function()
                        ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("StartCasting")
                        task.wait(0.7)
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        local ray = Ray.new(LocalPlayer.Character.Head.Position, hrp.CFrame.LookVector * 100)
                        local _, hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Characters, Enemies})
                        if hit then
                            ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("CastLineAtLocation", hit, 100, true)
                        end
                    end)
                elseif state == "Biting" then
                    pcall(function()
                        ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("Catching", true)
                        task.wait(0.25)
                        ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("Catch", 1)
                    end)
                end
            end

            if Cfg["Auto Sell Fish"] then
                pcall(function()
                    Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellFish")
                end)
            end
            if Cfg["Auto Sell Corrupt"] then
                pcall(function()
                    Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellCorruptedFish")
                end)
            end
        end)
    end
end)

--=====================================================================
-- TAB QUEST & ITEM
--=====================================================================
Tabs.Quest:AddSection("Farming Quest")

Tabs.Quest:AddDropdown("SwordSel", {
    Title = "Escolher Espada",
    Values = {"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default = "Twin Hooks"
}):OnChanged(function(v) Cfg["Sword"] = v end)

Tabs.Quest:AddToggle("AutoGetSword", {Title = "Auto Get Sword", Default = false}):OnChanged(function(v)
    Cfg["Auto Get Sword"] = v
    shouldTween = v
end)

Tabs.Quest:AddToggle("AutoGetSerpent", {Title = "Auto Get Serpent Bow", Default = false}):OnChanged(function(v)
    Cfg["Auto Get Serpent Bow"] = v
    shouldTween = v
end)

Tabs.Quest:AddToggle("AutoTushita", {Title = "Auto Tushita Sword", Default = false}):OnChanged(function(v)
    Cfg["Auto Tushita"] = v
    shouldTween = v
end)

Tabs.Quest:AddToggle("AutoYama", {Title = "Auto Yama Sword", Default = false}):OnChanged(function(v)
    Cfg["Auto Yama"] = v
    shouldTween = v
end)

Tabs.Quest:AddSection("Fighting Styles")

local styles = {
    {"Auto Superhuman","Auto_SuperHuman"},
    {"Auto Death Step","Auto_DeathStep"},
    {"Auto Sharkman Karate","Auto_Sharkman"},
    {"Auto Electric Claw","Auto_Electric_Claw"},
    {"Auto Dragon Talon","Auto_DragonTalon"},
    {"Auto Godhuman","Auto_GodHuman"},
    {"Auto Sanguine Art","Auto_Sanguine"}
}
for _, s in ipairs(styles) do
    Tabs.Quest:AddToggle("Style_"..s[2], {Title = s[1], Default = false}):OnChanged(function(v)
        Cfg[s[2]] = v
    end)
end

Tabs.Quest:AddSection("Races Upgrade")

Tabs.Quest:AddToggle("AutoV2", {Title = "Auto Race V2", Default = false}):OnChanged(function(v)
    Cfg["Auto V2"] = v
end)

Tabs.Quest:AddToggle("AutoV3", {Title = "Auto Race V3", Default = false}):OnChanged(function(v)
    Cfg["Auto V3"] = v
end)

Tabs.Quest:AddSection("Trial V4")

Tabs.Quest:AddButton("TeleportTemple", {Title = "Teleport Temple of Time", Callback = function()
    if Root then Root.CFrame = CFrame.new(28286, 14895, 102) end
    pcall(function()
        local stash = ReplicatedStorage:FindFirstChild("MapStash")
        if stash and stash:FindFirstChild("Temple of Time") and not Map:FindFirstChild("Temple of Time") then
            stash["Temple of Time"].Parent = Map
        end
    end)
end})

Tabs.Quest:AddButton("PullLeverBtn", {Title = "Pull Lever", Callback = function()
    pcall(function()
        for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
            if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
        end
    end)
end})

Tabs.Quest:AddToggle("AutoTrial", {Title = "Auto Complete Trial", Default = false}):OnChanged(function(v)
    Cfg["Auto Trial"] = v
end)

Tabs.Quest:AddToggle("AutoKillTrial", {Title = "Auto Kill Players After Trial", Default = false}):OnChanged(function(v)
    Cfg["Auto Kill Trial"] = v
end)

Tabs.Quest:AddSection("Compras Rapidas")

local shopBtns = {
    {"Buy Buso", {"BuyHaki","Buso"}},
    {"Buy Geppo", {"BuyHaki","Geppo"}},
    {"Buy Soru", {"BuyHaki","Soru"}},
    {"Buy Ken", {"KenTalk","Buy"}},
    {"Buy Black Leg", {"BuyBlackLeg"}},
    {"Buy Electro", {"BuyElectro"}},
    {"Buy Fishman Karate", {"BuyFishmanKarate"}},
    {"Buy Dragon Claw", {"BlackbeardReward","DragonClaw","2"}},
    {"Buy Superhuman", {"BuySuperhuman"}},
    {"Buy Death Step", {"BuyDeathStep"}},
    {"Buy Sharkman Karate", {"BuySharkmanKarate"}},
    {"Buy Electric Claw", {"BuyElectricClaw"}},
    {"Buy Dragon Talon", {"BuyDragonTalon"}},
    {"Buy Godhuman", {"BuyGodhuman"}},
    {"Buy Sanguine Art", {"BuySanguineArt"}},
    {"Buy Katana", {"BuyItem","Katana"}},
    {"Buy Cutlass", {"BuyItem","Cutlass"}},
    {"Buy Dual Katana", {"BuyItem","Dual Katana"}},
    {"Buy Iron Mace", {"BuyItem","Iron Mace"}},
    {"Buy Triple Katana", {"BuyItem","Triple Katana"}},
    {"Buy Pipe", {"BuyItem","Pipe"}},
    {"Buy Dual-Headed Blade", {"BuyItem","Dual-Headed Blade"}},
    {"Buy Soul Cane", {"BuyItem","Soul Cane"}},
    {"Buy Bisento", {"BuyItem","Bisento"}},
    {"Buy Musket", {"BuyItem","Musket"}},
    {"Buy Slingshot", {"BuyItem","Slingshot"}},
    {"Buy Flintlock", {"BuyItem","Flintlock"}},
    {"Buy Refined Slingshot", {"BuyItem","Refined Slingshot"}},
    {"Buy Refined Flintlock", {"BuyItem","Refined Flintlock"}},
    {"Buy Cannon", {"BuyItem","Cannon"}},
    {"Buy Kabucha", {"BlackbeardReward","Slingshot","2"}},
    {"Buy Black Cape", {"BuyItem","Black Cape"}},
    {"Buy Swordsman Hat", {"BuyItem","Swordsman Hat"}},
    {"Buy Tomoe Ring", {"BuyItem","Tomoe Ring"}},
}
for _, b in ipairs(shopBtns) do
    local args = b[2]
    Tabs.Quest:AddButton("btn_"..b[1], {Title = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end

            if Cfg["Auto Get Sword"] and Cfg["Sword"] then
                local map = {
                    ["Twin Hooks"] = {"Captain Elephant"},
                    ["Buddy Sword"] = {"Cake Queen"},
                    ["Canvander"] = {"Beautiful Pirate"},
                    ["Dark Dagger"] = {"rip_indra True Form"},
                    ["Spikey Trident"] = {"Dough King"},
                    ["Hallow Scythe"] = {"Soul Reaper"}
                }
                local mons = map[Cfg["Sword"]] or {}
                local e = findEnemy(mons)
                if e then Attack.Kill(e, true) end
            end

            if Cfg["Auto Get Serpent Bow"] then
                local e = findEnemy({"Island Empress"})
                if e then Attack.Kill(e, true)
                else tp(CFrame.new(5659, 602, 244)) end
            end

            if Cfg["Auto Tyrant"] then
                local t = findEnemy({"Tyrant of the Skies"})
                if t then Attack.Kill(t, true) end
            end

            if Cfg["Auto Trial"] and LocalPlayer.Character then
                local race = tostring(RaceData.Value)
                if race == "Mink" and Map:FindFirstChild("MinkTrial") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = Map.MinkTrial.Ceiling.CFrame * CFrame.new(0, -20, 0)
                elseif race == "Cyborg" and Map:FindFirstChild("CyborgTrial") then
                    tp(Map.CyborgTrial.Floor.CFrame * CFrame.new(0, 500, 0))
                elseif race == "Skypiea" and Map:FindFirstChild("SkyTrial") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = Map.SkyTrial.Model.FinishPart.CFrame
                elseif race == "Human" or race == "Ghoul" then
                    local e = findEnemy({"Ancient Vampire", "Ancient Zombie"})
                    if e then Attack.Kill(e, true) end
                elseif race == "Fishman" then
                    if workspace.SeaBeasts:FindFirstChild("SeaBeast1") then
                        Attack.KillSea(workspace.SeaBeasts.SeaBeast1, true)
                    end
                end
            end

            if Cfg["Auto Kill Trial"] and PlayerGui.Main.Timer.Visible then
                for _, c in pairs(Characters:GetChildren()) do
                    if c.Name ~= LocalPlayer.Name and isAlive(c) and c:FindFirstChild("HumanoidRootPart") then
                        if getDist(c.HumanoidRootPart.Position) <= 250 then
                            Attack.Kill(c, true)
                        end
                    end
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB VOLCANO EVENT
--=====================================================================
Tabs.Volcano:AddSection("Prehistoric Island")

Tabs.Volcano:AddToggle("AutoSummonPrehis", {Title = "Auto Summon Prehistoric Island", Default = false}):OnChanged(function(v)
    Cfg["Auto Summon Prehis"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("TweenPrehis", {Title = "Tween to Prehistoric Island", Default = false}):OnChanged(function(v)
    Cfg["Tween Prehis"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("AutoFindPrehis", {Title = "Auto Find Prehistoric Island", Default = false}):OnChanged(function(v)
    Cfg["Auto Find Prehis"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("AutoStartPrehis", {Title = "Auto Start Prehistoric Event", Default = false}):OnChanged(function(v)
    Cfg["Auto Start Prehis"] = v
end)

Tabs.Volcano:AddToggle("AutoPatchPrehis", {Title = "Auto Patch Prehistoric", Default = false}):OnChanged(function(v)
    Cfg["Auto Patch Prehis"] = v
end)

Tabs.Volcano:AddToggle("CollectDinoBones", {Title = "Auto Collect Dino Bones", Default = false}):OnChanged(function(v)
    Cfg["Auto Dino Bones"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("CollectDragonEggs", {Title = "Auto Collect Dragon Eggs", Default = false}):OnChanged(function(v)
    Cfg["Auto Dragon Eggs"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("KillAura", {Title = "Kill Aura (Volcano)", Default = false}):OnChanged(function(v)
    Cfg["Kill Aura"] = v
end)

Tabs.Volcano:AddSection("Dragon Trial")

Tabs.Volcano:AddButton("TeleportDojo", {Title = "Teleport Dragon Dojo", Callback = function()
    pcall(function()
        CommF_:InvokeServer("requestEntrance", Vector3.new(5661, 1013, -334))
        tp(CFrame.new(5814, 1208, 884))
    end)
end})

Tabs.Volcano:AddToggle("AutoDojo", {Title = "Auto Dojo Trainer", Default = false}):OnChanged(function(v)
    Cfg["Auto Dojo"] = v
end)

Tabs.Volcano:AddToggle("AutoDragoV1", {Title = "Auto Draco V1", Default = false}):OnChanged(function(v)
    Cfg["Auto Draco V1"] = v
    shouldTween = v
end)

Tabs.Volcano:AddToggle("AutoDragoV2", {Title = "Auto Draco V2 (Fire Flowers)", Default = false}):OnChanged(function(v)
    Cfg["Auto Draco V2"] = v
end)

Tabs.Volcano:AddToggle("AutoDragoV3", {Title = "Auto Draco V3 (Sea)", Default = false}):OnChanged(function(v)
    Cfg["Auto Draco V3"] = v
end)

Tabs.Volcano:AddSection("Crafting")

for _, item in ipairs({
    {"Dragonheart","CraftItem","Craft","Dragonheart"},
    {"Dragonstorm","CraftItem","Craft","Dragonstorm"},
    {"DinoHood","CraftItem","Craft","DinoHood"},
    {"TRexSkull","CraftItem","Craft","TRexSkull"},
}) do
    local title = item[1]
    local args = {table.unpack(item, 2)}
    Tabs.Volcano:AddButton("craft_"..title, {Title = "Craft "..title, Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not LocalPlayer.Character then return end

            if Cfg["Auto Summon Prehis"] and not Map:FindFirstChild("PrehistoricIsland") then
                local boat = nil
                for _, b in pairs(workspace.Boats:GetChildren()) do
                    if b:FindFirstChild("Owner") and tostring(b.Owner.Value) == LocalPlayer.Name then
                        boat = b; break
                    end
                end
                if not boat then
                    local shop = CFrame.new(-13.48, 10.31, 2927.69)
                    tp(shop)
                    if getDist(shop) < 10 then CommF_:InvokeServer("BuyBoat", "PirateBrigade") end
                elseif boat and boat:FindFirstChild("VehicleSeat") then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Sit then
                        pcall(function()
                            local bv = boat.PrimaryPart:FindFirstChild("Speed_Hub_X_Boat_BodyVelocity")
                            if not bv then
                                bv = Instance.new("BodyVelocity")
                                bv.Name = "Speed_Hub_X_Boat_BodyVelocity"
                                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                                bv.Velocity = Vector3.zero
                                bv.Parent = boat.PrimaryPart
                            end
                            TweenService:Create(boat.PrimaryPart, TweenInfo.new(200, Enum.EasingStyle.Linear), {CFrame = boat.PrimaryPart.CFrame * CFrame.new(0,5,-50000)}):Play()
                        end)
                    else tp(boat.VehicleSeat.CFrame) end
                end
            end

            if Cfg["Tween Prehis"] then
                local p = Map:FindFirstChild("PrehistoricIsland")
                if p then tp(p:GetPivot() * CFrame.new(2, 20, 2)) end
            end

            if Cfg["Auto Dino Bones"] then
                for _, d in pairs(workspace:GetChildren()) do
                    if d.Name == "DinoBone" then tp(d.CFrame) end
                end
            end

            if Cfg["Auto Dragon Eggs"] then
                if Map:FindFirstChild("PrehistoricIsland") then
                    local core = Map.PrehistoricIsland:FindFirstChild("Core")
                    if core and core:FindFirstChild("SpawnedDragonEggs") then
                        local egg = core.SpawnedDragonEggs:FindFirstChild("DragonEgg")
                        if egg and egg:FindFirstChild("Molten") then
                            tp(egg.Molten.CFrame)
                            pcall(function() fireproximityprompt(egg.Molten.ProximityPrompt, 30) end)
                        end
                    end
                end
            end

            if Cfg["Auto Start Prehis"] then
                if Map:FindFirstChild("PrehistoricIsland") then
                    local core = Map.PrehistoricIsland:FindFirstChild("Core")
                    if core then
                        local prompt = core:FindFirstChild("ActivationPrompt", true)
                        if prompt and prompt:FindFirstChild("ProximityPrompt") then
                            tp(prompt.CFrame)
                            if getDist(prompt.CFrame.Position) <= 150 then
                                pcall(function() fireproximityprompt(prompt.ProximityPrompt, math.huge) end)
                                sendKey("E", 1.5)
                            end
                        end
                    end
                end
            end

            if Cfg["Auto Patch Prehis"] then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    for _, o in pairs(isl:GetDescendants()) do
                        if (o:IsA("BasePart") or o:IsA("MeshPart")) and o.Name:lower():find("lava") then
                            o:Destroy()
                        end
                    end
                end
            end

            if Cfg["Kill Aura"] then
                pcall(function() sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end)
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        if getDist(e.HumanoidRootPart.Position) <= 500 then
                            pcall(function()
                                e.Humanoid.Health = 0
                                e:BreakJoints()
                            end)
                        end
                    end
                end
            end

            if Cfg["Auto Draco V2"] then
                for _, d in pairs(workspace:GetChildren()) do
                    if d.Name == "FireFlowers" then
                        for _, f in pairs(d:GetChildren()) do
                            if f.PrimaryPart then
                                local pos = f.PrimaryPart.Position
                                tp(CFrame.new(pos))
                                if getDist(pos) <= 100 then sendKey("E", 1.5) end
                            end
                        end
                    end
                end
            end

            if Cfg["Auto Dojo"] then
                pcall(function()
                    local resp = Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer({NPC = "Dojo Trainer", Command = "RequestQuest"})
                    if not resp or not resp.Quest or not resp.Quest.BeltName then
                        tp(CFrame.new(5865, 1208, 871))
                    end
                end)
            end
        end)
    end
end)

--=====================================================================
-- TAB STATS & ESP
--=====================================================================
Tabs.Esp:AddSection("Stats Upgrade")

Tabs.Esp:AddSlider("StatsVal", {
    Title = "Valor dos Pontos",
    Default = 10, Min = 1, Max = 100, Rounding = 0
}):OnChanged(function(v) Cfg["Stats Value"] = v end)

for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
    Tabs.Esp:AddToggle("autoStat_"..stat, {Title = "Auto "..stat, Default = false}):OnChanged(function(v)
        Cfg["Auto Stat "..stat] = v
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                if Cfg["Auto Stat "..stat] then
                    if Data.Points.Value > 0 then
                        CommF_:InvokeServer("AddPoint", stat == "Blox Fruit" and "Demon Fruit" or stat, tonumber(Cfg["Stats Value"]) or 10)
                    end
                end
            end
        end)
    end
end)

Tabs.Esp:AddSection("ESP")

local ESPNum = math.random(100000, 999999)

local function createESP(part, color, label)
    if not part or part:FindFirstChild("FarmESP"..ESPNum) then return end
    local bg = Instance.new("BillboardGui")
    bg.Name = "FarmESP"..ESPNum
    bg.Size = UDim2.new(0, 120, 0, 50)
    bg.StudsOffset = Vector3.new(0, 2, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = part
    bg.Parent = part
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = color or Color3.fromRGB(255,255,255)
    tl.TextStrokeTransparency = 0.3
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.Text = label or (part.Parent and part.Parent.Name) or part.Name
end

Tabs.Esp:AddToggle("EspPlayer", {Title = "ESP Player", Default = false}):OnChanged(function(v)
    Cfg["ESP Player"] = v
end)

Tabs.Esp:AddToggle("EspChest", {Title = "ESP Chest", Default = false}):OnChanged(function(v)
    Cfg["ESP Chest"] = v
end)

Tabs.Esp:AddToggle("EspFruit", {Title = "ESP Devil Fruit", Default = false}):OnChanged(function(v)
    Cfg["ESP Fruit"] = v
end)

Tabs.Esp:AddToggle("EspBerry", {Title = "ESP Berry", Default = false}):OnChanged(function(v)
    Cfg["ESP Berry"] = v
end)

Tabs.Esp:AddToggle("EspFlower", {Title = "ESP Flower", Default = false}):OnChanged(function(v)
    Cfg["ESP Flower"] = v
end)

Tabs.Esp:AddToggle("EspIsland", {Title = "ESP Island", Default = false}):OnChanged(function(v)
    Cfg["ESP Island"] = v
end)

Tabs.Esp:AddToggle("EspEventIsland", {Title = "ESP Event Islands", Default = false}):OnChanged(function(v)
    Cfg["ESP Event"] = v
end)

Tabs.Esp:AddButton("clearESP", {Title = "Clear All ESP", Callback = function()
    for _, d in pairs(workspace:GetDescendants()) do
        if d.Name == "FarmESP"..ESPNum then d:Destroy() end
    end
end})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Cfg["ESP Player"] then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local d = getDist(p.Character.Head.Position)
                        createESP(p.Character.Head, Color3.fromRGB(0,255,0), string.format("%s [%d]", p.Name, math.floor(d/3)))
                    end
                end
            end
            if Cfg["ESP Chest"] then
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not c:GetAttribute("IsDisabled") then
                        local part = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local d = getDist(part.Position)
                            createESP(part, Color3.fromRGB(255,255,0), "Chest ["..math.floor(d/3).."]")
                        end
                    end
                end
            end
            if Cfg["ESP Fruit"] then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name, "Fruit") and f:FindFirstChild("Handle") then
                        createESP(f.Handle, Color3.fromRGB(255,100,100), f.Name)
                    end
                end
            end
            if Cfg["ESP Event"] then
                for _, i in pairs(WorldOrigin.Locations:GetChildren()) do
                    if (i.Name == "Mirage Island" or i.Name == "Prehistoric Island" or i.Name == "Kitsune Island" or i.Name == "Frozen Dimension") and i:IsA("BasePart") then
                        createESP(i, Color3.fromRGB(150,255,150), i.Name)
                    end
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB FRUIT & RAID
--=====================================================================
Tabs.Raid:AddSection("Fruit Management")

Tabs.Raid:AddToggle("AutoRandomFruit", {Title = "Auto Random Fruit", Default = false}):OnChanged(function(v)
    Cfg["Auto Random Fruit"] = v
end)

Tabs.Raid:AddToggle("AutoStoreFruit", {Title = "Auto Store Fruit", Default = false}):OnChanged(function(v)
    Cfg["Auto Store Fruit"] = v
end)

Tabs.Raid:AddToggle("AutoDropFruit", {Title = "Auto Drop Fruit", Default = false}):OnChanged(function(v)
    Cfg["Auto Drop Fruit"] = v
end)

Tabs.Raid:AddToggle("AutoFindFruit", {Title = "Auto Find Fruit", Default = false}):OnChanged(function(v)
    Cfg["Auto Find Fruit"] = v
    shouldTween = v
end)

Tabs.Raid:AddSection("Raid / Dungeon")

Tabs.Raid:AddDropdown("RaidChip", {
    Title = "Escolher Chip",
    Values = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default = "Flame"
}):OnChanged(function(v) Cfg["Raid Chip"] = v end)

Tabs.Raid:AddToggle("AutoBuyChip", {Title = "Auto Buy Chip", Default = false}):OnChanged(function(v)
    Cfg["Auto Buy Chip"] = v
end)

Tabs.Raid:AddToggle("AutoRaid", {Title = "Auto Raid", Default = false}):OnChanged(function(v)
    Cfg["Auto Raid"] = v
    shouldTween = v
end)

Tabs.Raid:AddToggle("AutoAwake", {Title = "Auto Awakening", Default = false}):OnChanged(function(v)
    Cfg["Auto Awake"] = v
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Cfg["Auto Random Fruit"] then CommF_:InvokeServer("Cousin", "Buy") end
            if Cfg["Auto Store Fruit"] then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote") then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if Cfg["Auto Drop Fruit"] then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name, "Fruit") and t:FindFirstChild("EatRemote") then
                        t.EatRemote:InvokeServer("Drop")
                    end
                end
            end
            if Cfg["Auto Find Fruit"] and Root then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name, "Fruit") and f:FindFirstChild("Handle") then
                        tp(f.Handle.CFrame); break
                    end
                end
            end
            if Cfg["Auto Buy Chip"] and Cfg["Raid Chip"] then
                if not hasTool("Special Microchip") then
                    if Cfg["Raid Chip"] == "Rumble" then
                        CommF_:InvokeServer("ThunderGodTalk")
                    else
                        CommF_:InvokeServer("RaidsNpc", "Select", Cfg["Raid Chip"])
                    end
                end
            end
            if Cfg["Auto Awake"] then
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end
        end)
    end
end)

--=====================================================================
-- TAB LOCAL PLAYER
--=====================================================================
Tabs.LocalP:AddSection("Aimbot")

local plrNames = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end

Tabs.LocalP:AddDropdown("AimPlayer", {
    Title = "Escolher Player",
    Values = plrNames,
    Default = plrNames[1] or ""
}):OnChanged(function(v) Cfg["Aim Player"] = v end)

Tabs.LocalP:AddDropdown("AimMethod", {
    Title = "Metodo",
    Values = {"Aim Player","Nearest Aim"},
    Default = "Aim Player"
}):OnChanged(function(v) Cfg["Aim Method"] = v end)

Tabs.LocalP:AddToggle("AimbotSkills", {Title = "Aimbot Skills", Default = false}):OnChanged(function(v)
    Cfg["Aimbot"] = v
    _g.AimbotEnabled = v
end)

Tabs.LocalP:AddToggle("TPPlayer", {Title = "Teleport To Player", Default = false}):OnChanged(function(v)
    Cfg["TP Player"] = v
    shouldTween = v
end)

Tabs.LocalP:AddToggle("AutoPvP", {Title = "Auto Enable PvP", Default = false}):OnChanged(function(v)
    Cfg["Auto PvP"] = v
end)

Tabs.LocalP:AddToggle("NoClip", {Title = "No Clip", Default = false}):OnChanged(function(v)
    Cfg["NoClip"] = v
end)

task.spawn(function()
    RunService.Stepped:Connect(function()
        if Cfg["NoClip"] and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

-- Aimbot hook
task.spawn(function()
    pcall(function()
        local meta = getrawmetatable(game)
        local old = meta.__namecall
        setreadonly(meta, false)
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if _g.AimbotEnabled and method == "FireServer" and tostring(self) == "RemoteEvent" then
                if typeof(args[2]) == "Vector3" then
                    local target
                    if Cfg["Aim Method"] == "Aim Player" then
                        target = Players:FindFirstChild(Cfg["Aim Player"])
                    elseif Cfg["Aim Method"] == "Nearest Aim" then
                        local nd, tp2 = math.huge, nil
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= LocalPlayer.Team then
                                local d = getDist(p.Character.HumanoidRootPart.Position)
                                if d < nd then nd = d; tp2 = p end
                            end
                        end
                        target = tp2
                    end
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        args[2] = target.Character.HumanoidRootPart.Position
                        return old(self, unpack(args))
                    end
                end
            end
            return old(self, ...)
        end)
        setreadonly(meta, true)
    end)
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Cfg["Auto PvP"] then
                local pvp = PlayerGui.Main:FindFirstChild("PvpDisabled")
                if pvp and pvp.Visible then CommF_:InvokeServer("EnablePvp") end
            end
            if Cfg["TP Player"] and Cfg["Aim Player"] then
                local p = Players:FindFirstChild(Cfg["Aim Player"])
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    tp(p.Character.HumanoidRootPart.CFrame)
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB TELEPORT
--=====================================================================
Tabs.Travel:AddSection("Mundos")

Tabs.Travel:AddButton("Travel1", {Title = "Ir para Sea 1", Callback = function() CommF_:InvokeServer("TravelMain") end})
Tabs.Travel:AddButton("Travel2", {Title = "Ir para Sea 2", Callback = function() CommF_:InvokeServer("TravelDressrosa") end})
Tabs.Travel:AddButton("Travel3", {Title = "Ir para Sea 3", Callback = function() CommF_:InvokeServer("TravelZou") end})

Tabs.Travel:AddSection("Ilhas")

local islandNames = {}
for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandNames, l.Name) end

Tabs.Travel:AddDropdown("IslandSel", {
    Title = "Escolher Ilha",
    Values = islandNames,
    Default = islandNames[1] or ""
}):OnChanged(function(v) Cfg["Ilha"] = v end)

Tabs.Travel:AddToggle("TweenIsland", {Title = "Auto Travel Ilha", Default = false}):OnChanged(function(v)
    Cfg["Travel Ilha"] = v
    shouldTween = v
end)

Tabs.Travel:AddSection("Portais")

local portals = {
    {"Sky (Sea1)", {"requestEntrance", Vector3.new(-7894, 5547, -380)}},
    {"UnderWater (Sea1)", {"requestEntrance", Vector3.new(61163, 11, 1819)}},
    {"Swan Room (Sea2)", {"requestEntrance", Vector3.new(2285, 15, 905)}},
    {"Cursed Ship (Sea2)", {"requestEntrance", Vector3.new(923, 126, 32852)}},
    {"Castle On The Sea (Sea3)", {"requestEntrance", Vector3.new(-5097, 316, -3142)}},
    {"Mansion (Sea3)", {"requestEntrance", Vector3.new(-12471, 374, -7551)}},
    {"Hydra (Sea3)", {"requestEntrance", Vector3.new(5643, 1013, -340)}}
}
for _, p in ipairs(portals) do
    local args = p[2]
    Tabs.Travel:AddButton("port_"..p[1], {Title = p[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if Cfg["Travel Ilha"] and Cfg["Ilha"] then
                for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
                    if l.Name == Cfg["Ilha"] then tp(l.CFrame * CFrame.new(0, 30, 0)) end
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB SHOPPING
--=====================================================================
Tabs.Shop:AddSection("Haki / Estilos")

local shopItems = {
    {"Buy Buso","BuyHaki","Buso"},
    {"Buy Geppo","BuyHaki","Geppo"},
    {"Buy Soru","BuyHaki","Soru"},
    {"Buy Ken","KenTalk","Buy"},
    {"Buy Black Leg","BuyBlackLeg"},
    {"Buy Electro","BuyElectro"},
    {"Buy Fishman Karate","BuyFishmanKarate"},
    {"Buy Dragon Claw","BlackbeardReward","DragonClaw","2"},
    {"Buy Superhuman","BuySuperhuman"},
    {"Buy Death Step","BuyDeathStep"},
    {"Buy Sharkman Karate","BuySharkmanKarate"},
    {"Buy Electric Claw","BuyElectricClaw"},
    {"Buy Dragon Talon","BuyDragonTalon"},
    {"Buy Godhuman","BuyGodhuman"},
    {"Buy Sanguine Art","BuySanguineArt"}
}
for _, it in ipairs(shopItems) do
    local title = it[1]
    local args = {table.unpack(it, 2)}
    Tabs.Shop:AddButton("shop_"..title, {Title = title, Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

Tabs.Shop:AddSection("Espadas / Armas")

local weapons = {"Katana","Cutlass","Dual Katana","Iron Mace","Triple Katana","Pipe","Dual-Headed Blade","Soul Cane","Bisento","Musket","Slingshot","Flintlock","Refined Slingshot","Refined Flintlock","Cannon"}
for _, w in ipairs(weapons) do
    Tabs.Shop:AddButton("wep_"..w, {Title = "Comprar "..w, Callback = function()
        pcall(function() CommF_:InvokeServer("BuyItem", w) end)
    end})
end

Tabs.Shop:AddSection("Acessorios")

for _, item in ipairs({"Tomoe Ring","Black Cape","Swordsman Hat"}) do
    Tabs.Shop:AddButton("acc_"..item, {Title = "Comprar "..item, Callback = function()
        pcall(function() CommF_:InvokeServer("BuyItem", item) end)
    end})
end

Tabs.Shop:AddSection("Fragments / Outros")

Tabs.Shop:AddButton("reroll", {Title = "Reroll Race (Frags)", Callback = function()
    CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
end})

Tabs.Shop:AddButton("refund", {Title = "Refund Stats (Frags)", Callback = function()
    CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
end})

Tabs.Shop:AddButton("legendary", {Title = "Buy Legendary Swords", Callback = function()
    CommF_:InvokeServer("LegendarySwordDealer", "1")
    CommF_:InvokeServer("LegendarySwordDealer", "2")
    CommF_:InvokeServer("LegendarySwordDealer", "3")
end})

Tabs.Shop:AddButton("ttk", {Title = "Buy True Triple Katana", Callback = function()
    CommF_:InvokeServer("MysteriousMan", "2")
end})

Tabs.Shop:AddButton("ghoul", {Title = "Buy Ghoul Race", Callback = function()
    CommF_:InvokeServer("Ectoplasm", "Change", 4)
end})

Tabs.Shop:AddButton("cyborg", {Title = "Buy Cyborg Race", Callback = function()
    CommF_:InvokeServer("CyborgTrainer", "Buy")
end})

--=====================================================================
-- TAB MISC
--=====================================================================
Tabs.Misc:AddSection("Servidor")

Tabs.Misc:AddButton("hop", {Title = "Hop Server", Callback = function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end})

Tabs.Misc:AddButton("rejoin", {Title = "Rejoin Server", Callback = function()
    TeleportService:Teleport(PlaceId, LocalPlayer)
end})

Tabs.Misc:AddButton("copyjobid", {Title = "Copiar Job ID", Callback = function()
    setclipboard(tostring(game.JobId))
end})

Tabs.Misc:AddSection("Teams")

Tabs.Misc:AddButton("pirate", {Title = "Entrar Pirates", Callback = function() CommF_:InvokeServer("SetTeam", "Pirates") end})
Tabs.Misc:AddButton("marine", {Title = "Entrar Marines", Callback = function() CommF_:InvokeServer("SetTeam", "Marines") end})

Tabs.Misc:AddSection("UI / Visual")

Tabs.Misc:AddToggle("RemoveDamage", {Title = "Remover Numeros de Dano", Default = false}):OnChanged(function(v)
    Cfg["Remove Damage"] = v
end)

Tabs.Misc:AddToggle("RemoveNotify", {Title = "Remover Notificacoes", Default = false}):OnChanged(function(v)
    Cfg["Remove Notify"] = v
end)

Tabs.Misc:AddToggle("WalkWater", {Title = "Walk on Water", Default = false}):OnChanged(function(v)
    Cfg["Walk Water"] = v
    local w = Map:FindFirstChild("WaterBase-Plane")
    if w then w.Size = v and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000) end
end)

Tabs.Misc:AddToggle("FullBright", {Title = "Full Bright", Default = false}):OnChanged(function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

Tabs.Misc:AddButton("removeLight", {Title = "Remove Lighting Effects", Callback = function()
    if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
    if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
end})

Tabs.Misc:AddSection("Redeem / Menu")

Tabs.Misc:AddButton("redeem", {Title = "Redeem All Codes", Callback = function()
    local codes = {
        "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
        "BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
        "SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
        "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
        "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
        "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123",
        "Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
        "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN",
        "ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle","NOEXPLOIT",
        "NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares"
    }
    local RedeemRemote = Remotes:FindFirstChild("Redeem")
    if not RedeemRemote then return end
    for _, code in ipairs(codes) do
        pcall(function()
            if RedeemRemote.InvokeServer then RedeemRemote:InvokeServer(code)
            else RedeemRemote:FireServer(code) end
        end)
        task.wait(0.05)
    end
end})

Tabs.Misc:AddButton("titles", {Title = "Open Titles", Callback = function()
    CommF_:InvokeServer("getTitles", true)
    PlayerGui.Main.Titles.Visible = true
end})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Cfg["Remove Damage"] then
                local dmg = ReplicatedStorage.Assets and ReplicatedStorage.Assets.GUI and ReplicatedStorage.Assets.GUI.DamageCounter
                if dmg then dmg.Enabled = false end
            end
            if Cfg["Remove Notify"] then PlayerGui.Notifications.Enabled = false
            else PlayerGui.Notifications.Enabled = true end
        end)
    end
end)

--=====================================================================
-- TAB SETTINGS
--=====================================================================
Tabs.Settings:AddSection("Configuracao Principal")

Tabs.Settings:AddDropdown("WeaponToolS", {
    Title = "Weapon Tool",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
}):OnChanged(function(v) Cfg["Weapon Tool"] = v end)

Tabs.Settings:AddDropdown("TweenSpeedS", {
    Title = "Tween Speed",
    Values = {"100","200","300","400","500","800","1000"},
    Default = "300"
}):OnChanged(function(v) Cfg["Tween Speed"] = v end)

Tabs.Settings:AddToggle("BringMobT", {Title = "Bring Mob", Default = true}):OnChanged(function(v)
    Cfg["Bring Mob"] = v
end)

Tabs.Settings:AddDropdown("BringRadiusD", {
    Title = "Bring Radius",
    Values = {"100","200","300","400","500","1000"},
    Default = "300"
}):OnChanged(function(v) Cfg["Bring Radius"] = v end)

Tabs.Settings:AddToggle("FastAttackT", {Title = "Fast Attack", Default = false}):OnChanged(function(v)
    Cfg["Fast Attack"] = v
end)

Tabs.Settings:AddDropdown("SkillMulti", {
    Title = "Skills (Multi)",
    Values = {"Z","X","C","V","F"},
    Default = {"Z","X","C","V"},
    Multi = true
}):OnChanged(function(v)
    for _, k in ipairs({"Z","X","C","V","F"}) do
        Cfg["Auto Skill "..k] = false
    end
    for _, k in ipairs(v) do
        Cfg["Auto Skill "..k] = true
    end
end)

Tabs.Settings:AddSection("Race / Haki Auto")

Tabs.Settings:AddToggle("AutoRaceV3", {Title = "Auto Turn Race V3", Default = false}):OnChanged(function(v)
    Cfg["Auto Race V3"] = v
end)

Tabs.Settings:AddToggle("AutoRaceV4", {Title = "Auto Turn Race V4", Default = false}):OnChanged(function(v)
    Cfg["Auto Race V4"] = v
end)

Tabs.Settings:AddToggle("AutoBuso", {Title = "Auto Turn Buso", Default = false}):OnChanged(function(v)
    Cfg["Auto Buso"] = v
end)

Tabs.Settings:AddToggle("AutoKen", {Title = "Auto Turn Ken", Default = false}):OnChanged(function(v)
    Cfg["Auto Ken"] = v
end)

Tabs.Settings:AddSection("Anti / Seguranca")

Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti AFK", Default = true}):OnChanged(function(v)
    Cfg["Anti AFK"] = v
    if v then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

Tabs.Settings:AddToggle("AntiAdmin", {Title = "Anti Admin Join", Default = false}):OnChanged(function(v)
    Cfg["Anti Admin"] = v
end)

Tabs.Settings:AddToggle("DisableNotifyS", {Title = "Disable Notify", Default = false}):OnChanged(function(v)
    Cfg["Disable Notify"] = v
end)

Tabs.Settings:AddSlider("HopInterval", {Title = "Auto Hop Interval (min)", Min = 5, Max = 120, Default = 30}):OnChanged(function(v)
    Cfg["Hop Interval"] = v
end)

Tabs.Settings:AddToggle("AutoHopTime", {Title = "Auto Hop by Time", Default = false}):OnChanged(function(v)
    Cfg["Auto Hop"] = v
end)

--=====================================================================
-- LOOPS DAS SETTINGS
--=====================================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            if Cfg["Auto Buso"] and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function() CommF_:InvokeServer("Buso") end)
            end
            if Cfg["Auto Ken"] then
                pcall(function() CommE:FireServer("Ken", true) end)
            end
            if Cfg["Auto Race V3"] then
                pcall(function() CommE:FireServer("ActivateAbility") end)
            end
            if Cfg["Auto Race V4"] and LocalPlayer.Character:FindFirstChild("RaceEnergy") then
                if LocalPlayer.Character.RaceEnergy.Value == 1 then
                    sendKey("Y")
                end
            end
            if Cfg["Disable Notify"] then
                PlayerGui.Notifications.Enabled = false
            end
        end)
    end
end)

-- Loop Auto Admin
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if Cfg["Anti Admin"] then
                local blacklist = {
                    "red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock",
                    "oofficialnoobie","Uzoth","Azarth","arlthmetic","Death_King","Lunoven",
                    "TheGreateAced","rip_fud","drip_mama"
                }
                for _, p in pairs(Players:GetPlayers()) do
                    if table.find(blacklist, p.Name) then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                        break
                    end
                end
            end
        end)
    end
end)

-- Loop Auto Hop by Time
task.spawn(function()
    local timer = tick()
    while task.wait(1) do
        if Cfg["Auto Hop"] then
            local interval = (tonumber(Cfg["Hop Interval"]) or 30) * 60
            if tick() - timer >= interval then
                timer = tick()
                pcall(function()
                    local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                    for _, s in pairs(data.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer)
                            break
                        end
                    end
                end)
            end
        else
            timer = tick()
        end
    end
end)

--=====================================================================
-- SAVE MANAGER / INTERFACE MANAGER
--=====================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloxFruitsFarm")
SaveManager:SetFolder("BloxFruitsFarm/BloxFruits")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(2)

Fluent:Notify({
    Title = "Blox Fruits Farm",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

pcall(function()
    SaveManager:LoadAutoloadConfig()
end)

-- FIM DO SCRIPT
