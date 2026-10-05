--=====================================================================
-- BLOX FRUITS FARM | FLUENT UI | SAFE VERSION
--=====================================================================
repeat task.wait() until game:IsLoaded()

--// ---- GLOBAL ERROR GUARD ---------------------------------------------
local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title, Text = text, Duration = 10
        })
    end)
end

local function safe(func, ...)
    local ok, err = pcall(func, ...)
    if not ok then warn("[BF-Farm] " .. tostring(err)) end
    return ok
end

--// ---- SERVICES --------------------------------------------------------
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

--// Aguarda o Main UI existir antes de continuar (evita crash imediato)
local MainGui = PlayerGui:WaitForChild("Main", 30)
if not MainGui then
    notify("BF Farm", "PlayerGui.Main não carregou. Rejoin.")
    return
end

--// ---- REPLICATED ------------------------------------------------------
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not Remotes then notify("BF Farm", "Remotes ausente"); return end

local CommF_ = Remotes:WaitForChild("CommF_", 15)
local CommE  = Remotes:FindFirstChild("CommE")
local Modules = ReplicatedStorage:WaitForChild("Modules", 30)
local Net = Modules and Modules:FindFirstChild("Net")

local Enemies    = workspace:FindFirstChild("Enemies") or Instance.new("Folder", workspace)
local Characters = workspace:FindFirstChild("Characters") or Instance.new("Folder", workspace)
local WorldOrigin= workspace:WaitForChild("_WorldOrigin", 30)
local Map        = workspace:WaitForChild("Map", 30)

--// ---- SEAS ------------------------------------------------------------
local PlaceId = game.PlaceId
local Sea1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local Sea2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local Sea3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

--// ---- CHARACTER -------------------------------------------------------
local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart", 10)
    Hum  = c:WaitForChild("Humanoid", 10)
end
if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindChar)

local Data     = LocalPlayer:WaitForChild("Data", 30)
local Level    = Data and Data:WaitForChild("Level")
local Beli     = Data and Data:WaitForChild("Beli")
local Frags    = Data and Data:WaitForChild("Fragments")
local RaceData = Data and Data:WaitForChild("Race")

--// ---- SAFE REQUIRES ---------------------------------------------------
local Quests, Guide
safe(function() Quests = require(ReplicatedStorage.Quests) end)
safe(function() Guide  = require(ReplicatedStorage.GuideModule) end)
Quests = Quests or {}
Guide  = Guide or {Data = {NPCList = {}}}

--// ---- FLUENT LOADER ---------------------------------------------------
local Fluent, SaveManager, InterfaceManager
local function tryLoad(url)
    local ok, res = pcall(function()
        local src = game:HttpGet(url)
        if not src or #src < 200 then error("Empty") end
        return loadstring(src)()
    end)
    return ok and res or nil
end

for _, u in ipairs({
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/ActualMasterOogway/Fluent/main/main.lua",
    "https://raw.githubusercontent.com/Chocomilk999/Fluent-UI-Chocomilk/main/main.lua"
}) do
    Fluent = tryLoad(u)
    if Fluent then break end
end

if not Fluent then
    notify("Erro", "Fluent falhou ao carregar")
    return
end

SaveManager     = tryLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/SaveManager.lua")
InterfaceManager= tryLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/InterfaceManager.lua")

SaveManager = SaveManager or {
    SetLibrary=function()end, IgnoreThemeSettings=function()end,
    SetIgnoreIndexes=function()end, SetFolder=function()end,
    BuildConfigSection=function()end, LoadAutoloadConfig=function()end
}
InterfaceManager = InterfaceManager or {
    SetLibrary=function()end, SetFolder=function()end, BuildInterfaceSection=function()end
}

--// ---- WINDOW ----------------------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Farm",
    SubTitle = "Fluent UI",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Info        = Window:AddTab({ Title = "Info",           Icon = "info" }),
    Main        = Window:AddTab({ Title = "Main",           Icon = "home" }),
    Fishing     = Window:AddTab({ Title = "Fishing",        Icon = "fish" }),
    QuestItem   = Window:AddTab({ Title = "Quest & Item",   Icon = "scroll" }),
    Volcano     = Window:AddTab({ Title = "Volcano Event",  Icon = "flame" }),
    StatsESP    = Window:AddTab({ Title = "Stats & ESP",    Icon = "eye" }),
    FruitRaid   = Window:AddTab({ Title = "Fruit & Raid",   Icon = "apple" }),
    LocalPlayer = Window:AddTab({ Title = "Local Player",   Icon = "user" }),
    Teleport    = Window:AddTab({ Title = "Teleport",       Icon = "map" }),
    Shopping    = Window:AddTab({ Title = "Shopping",       Icon = "shopping-cart" }),
    Misc        = Window:AddTab({ Title = "Misc",           Icon = "wrench" }),
    Settings    = Window:AddTab({ Title = "Settings",       Icon = "settings" })
}

local Options = Fluent.Options

--// ---- CORE ------------------------------------------------------------
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

local function optVal(name, default)
    local o = Options[name]
    if not o then return default end
    local ok, v = pcall(function() return o.Value end)
    return ok and v or default
end

local function getTweenSpeed()
    return tonumber(optVal("TweenSpeed", "300")) or 300
end

local function tp(cf)
    if not Root or not LocalPlayer.Character then return end
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    if typeof(cf) ~= "CFrame" then return end
    pcall(function()
        if currentTween then currentTween:Cancel() end
        local dist = (cf.Position - tweenBlock.Position).Magnitude
        local speed = math.max(1, getTweenSpeed())
        currentTween = TweenService:Create(tweenBlock,
            TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cf})
        currentTween:Play()
    end)
end
_G.tp = tp

task.spawn(function()
    while task.wait() do
        safe(function()
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
                if Root and Root:FindFirstChild("BodyClip") then
                    Root.BodyClip:Destroy()
                end
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

local function equipByTip(tip)
    if not LocalPlayer.Character or not tip then return end
    local bp = LocalPlayer.Backpack
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == tip then
                equipToolByName(t.Name); return
            end
        end
    end
end

local function equipSelected()
    local tip = optVal("WeaponTool_S", nil)
        or optVal("WeaponTool", nil)
        or "Melee"
    equipByTip(tip)
end

local function sendKey(key, hold)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(hold or 0.05)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end
_G.sendKey = sendKey

local function hasTool(name)
    if not LocalPlayer.Character then return false end
    return (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(name) ~= nil)
        or (LocalPlayer.Character:FindFirstChild(name) ~= nil)
end

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
_G.findEnemy = findEnemy

local function bringEnemy(target, centerCF)
    if not optVal("BringMob", true) then return end
    if not target or not centerCF then return end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
        end
    end)
    local radius = tonumber(optVal("BringRadius", "300")) or 300
    local r2 = radius * radius
    local center = centerCF.Position
    for _, e in pairs(Enemies:GetChildren()) do
        if e.Name == target.Name and isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local rt, h = e.HumanoidRootPart, e:FindFirstChildOfClass("Humanoid")
            local d = (rt.Position - center).Magnitude
            if d*d <= r2 and h then
                rt.CanCollide = false
                h.WalkSpeed = 0
                h.JumpPower = 0
                rt.CFrame = CFrame.new(
                    center + Vector3.new(math.random(-3,3), 3, math.random(-3,3))
                )
            end
        end
    end
end

local Attack = {}
Attack.Kill = function(model, enabled)
    if not model or not enabled then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    equipSelected()
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
        local opt = Options["Skill"..k]
        if opt and opt.Value then sendKey(k) end
    end
end
_G.Attack = Attack

--// Fast Attack
task.spawn(function()
    while task.wait() do
        safe(function()
            if not optVal("FastAttack", false) then return end
            if not LocalPlayer.Character or not Root then return end
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool or not tool.ToolTip then return end
            if tool.ToolTip == "Gun" or tool.ToolTip == "Blox Fruit" then return end
            if not Net then return end
            local ra = Net:FindFirstChild("RE/RegisterAttack")
            local rh = Net:FindFirstChild("RE/RegisterHit")
            if not ra or not rh then return end
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
                    ra:FireServer(0)
                    rh:FireServer(hits[1][2], hits)
                end)
            end
        end)
    end
end)

--// Quest helper
local function getQuestInfo()
    local lvl = Level and Level.Value or 0
    local team = tostring(LocalPlayer.Team)
    local qname, mob, npcCF, id, mobSpawn
    if lvl >= 1 and lvl <= 9 then
        if team == "Marines" then
            mob = "Trainee"; qname = "MarineQuest"; id = 1
            npcCF = CFrame.new(-2709, 24, 2104); mobSpawn = "Trainee"
        else
            mob = "Bandit"; qname = "BanditQuest1"; id = 1
            npcCF = CFrame.new(1059, 16, 1549); mobSpawn = "Bandit"
        end
        return {mob, npcCF, mobSpawn, qname, id, 1}
    end
    local curLvl = 0
    if Guide and Guide.Data and Guide.Data.NPCList then
        for k, v in pairs(Guide.Data.NPCList) do
            for _, lv in ipairs(v.Levels or {}) do
                if lvl >= lv and lv > curLvl then
                    curLvl = lv
                    if k and k.CFrame then npcCF = k.CFrame end
                end
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

local function getRaceInfo()
    local race = RaceData and tostring(RaceData.Value) or "Unknown"
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
-- TAB 1: INFO
--=====================================================================
Tabs.Info:AddSection("Server Status")
local TimeP    = Tabs.Info:AddParagraph({Title="Local Time", Content="..."})
local GameTimeP= Tabs.Info:AddParagraph({Title="Game Time", Content="..."})
local RaceP    = Tabs.Info:AddParagraph({Title="Race", Content="..."})
local StatusP  = Tabs.Info:AddParagraph({Title="Player Stats", Content="..."})
local MoonP    = Tabs.Info:AddParagraph({Title="Moon Phase", Content="..."})
local MirageP  = Tabs.Info:AddParagraph({Title="Mirage Island", Content="..."})
local KitsuneP = Tabs.Info:AddParagraph({Title="Kitsune Island", Content="..."})
local PrehisP  = Tabs.Info:AddParagraph({Title="Prehistoric Island", Content="..."})
local FrozenP  = Tabs.Info:AddParagraph({Title="Frozen Dimension", Content="..."})
local CakeP    = Tabs.Info:AddParagraph({Title="Cake Prince", Content="..."})
local RipP     = Tabs.Info:AddParagraph({Title="Rip Indra", Content="..."})
local DoughP   = Tabs.Info:AddParagraph({Title="Dough King", Content="..."})
local SwordP   = Tabs.Info:AddParagraph({Title="Legendary Swords", Content="..."})
local BoneP    = Tabs.Info:AddParagraph({Title="Bones", Content="0"})

task.spawn(function()
    while task.wait(1) do
        safe(function()
            TimeP:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
            local gt = math.floor(workspace.DistributedGameTime)
            GameTimeP:SetDesc(string.format("%dh %dm %ds",
                math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
            RaceP:SetDesc(getRaceInfo())
            StatusP:SetDesc(string.format("Level: %d | Beli: %s | Frags: %s",
                Level and Level.Value or 0,
                tostring(Beli and Beli.Value or 0),
                tostring(Frags and Frags.Value or 0)))
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            for k, v in pairs({
                ["9709149431"]="Full Moon (5/5)", ["9709149052"]="4/5",
                ["9709143733"]="3/5", ["9709150401"]="2/5", ["9709149680"]="1/5"
            }) do
                if moon:find(k) then MoonP:SetDesc(v); break end
            end
            if WorldOrigin.Locations then
                MirageP:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "Spawned" or "Not")
                FrozenP:SetDesc(WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "Spawned" or "Not")
            end
            KitsuneP:SetDesc(Map:FindFirstChild("KitsuneIsland") and "Spawned" or "Not")
            PrehisP:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "Spawned" or "Not")
            local cp = CommF_:InvokeServer("CakePrinceSpawner")
            if cp and tostring(cp):find("%d") then
                local killed = tostring(cp):match("%d+")
                CakeP:SetDesc("Progress: "..tostring(500-tonumber(killed or 0)).."/500")
            else
                CakeP:SetDesc(Enemies:FindFirstChild("Cake Prince") and "Spawned" or "Not")
            end
            RipP:SetDesc(Enemies:FindFirstChild("rip_indra") and "Spawned" or "Not")
            DoughP:SetDesc(Enemies:FindFirstChild("Dough King") and "Spawned" or "Not")
            local swords = {}
            if CommF_:InvokeServer("LegendarySwordDealer","1") then table.insert(swords,"Shisui") end
            if CommF_:InvokeServer("LegendarySwordDealer","2") then table.insert(swords,"Wando") end
            if CommF_:InvokeServer("LegendarySwordDealer","3") then table.insert(swords,"Saddi") end
            SwordP:SetDesc(#swords>0 and table.concat(swords,", ") or "None")
            local b = CommF_:InvokeServer("Bones","Check")
            if b then BoneP:SetDesc(tostring(b)) end
        end)
    end
end)

--=====================================================================
-- TAB 2: MAIN
--=====================================================================
Tabs.Main:AddSection("Farming")

Tabs.Main:AddDropdown("WeaponTool", {
    Title="Weapon Tool", Values={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee"
}):OnChanged(function(v)
    local o = Options.WeaponTool_S
    if o then pcall(function() o:SetValue(v) end) end
end)

Tabs.Main:AddToggle("AutoFarmLevel", {Title="Auto Farm Level", Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Main:AddToggle("AutoFarmNearest",{Title="Auto Farm Nearest",Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Main:AddDropdown("NearestRange", {
    Title="Nearest Range", Values={"500","1000","2000","3000","Infinite"}, Default="Infinite"
})
Tabs.Main:AddToggle("AutoFactory",    {Title="Auto Factory Raid",    Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Main:AddToggle("AutoEctoplasm",  {Title="Auto Farm Ectoplasm",  Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Main:AddSection("Chest Collection")
Tabs.Main:AddToggle("AutoCollectChest",{Title="Auto Collect Chest",   Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Main:AddToggle("StopRareItems",   {Title="Stop on Rare Items",   Default=true})
Tabs.Main:AddToggle("AutoHopNoChest",  {Title="Auto Hop If No Chest", Default=false})
Tabs.Main:AddToggle("AutoCollectBerry",{Title="Auto Collect Berry",   Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Main:AddSection("Mastery")
Tabs.Main:AddDropdown("MasteryMode", {
    Title="Mastery Mode", Values={"Level","Bone","Cake Prince","Nearest"}, Default="Level"
})
Tabs.Main:AddDropdown("MasteryWeapon", {
    Title="Mastery Weapon", Values={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee"
})
Tabs.Main:AddToggle("AutoMastery", {Title="Auto Farm Mastery", Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Main:AddSection("Material")
local materialList = Sea1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or Sea2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
Tabs.Main:AddDropdown("MaterialSel", {
    Title="Material", Values=materialList, Default=materialList[1]
})
Tabs.Main:AddToggle("AutoMaterial", {Title="Auto Farm Material", Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Main:AddSection("Boss")
local bossList = Sea1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
    or Sea2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
Tabs.Main:AddDropdown("BossSel", {Title="Boss", Values=bossList, Default=bossList[1]})
Tabs.Main:AddToggle("AutoBoss",   {Title="Auto Attack Boss",     Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Main:AddToggle("AutoAllBoss",{Title="Auto Attack All Boss", Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Main:AddSection("Special Farms")
for _, t in ipairs({
    {"AutoCakePrince","Auto Cake Prince"},{"AutoDoughKing","Auto Dough King"},
    {"AutoBone","Auto Farm Bones"},{"AutoSoulReaper","Auto Soul Reaper"},
    {"AutoElite","Auto Elite Hunter"},{"AutoPiratesSea","Auto Pirates Sea"},
    {"AutoRipIndra","Auto Attack Rip Indra"},{"AutoRainbowHaki","Auto Rainbow Haki"},
    {"AutoCitizen","Auto Citizen Quest"}
}) do
    Tabs.Main:AddToggle(t[1], {Title=t[2], Default=false}):OnChanged(function(v) shouldTween=v end)
end
Tabs.Main:AddToggle("AutoTryLuck", {Title="Auto Try Luck Gravestone", Default=false})
Tabs.Main:AddToggle("AutoPray",    {Title="Auto Pray Gravestone",     Default=false})

--// MAIN LOOP -----------------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        safe(function()
            if not LocalPlayer.Character or not Root then return end

            if optVal("AutoFarmLevel", false) then
                local q = getQuestInfo()
                if q and q[1] then
                    local quest = MainGui:FindFirstChild("Quest")
                    local titleOK = quest and quest.Visible and quest.Container
                        and quest.Container.QuestTitle and quest.Container.QuestTitle.Title
                        and string.find(quest.Container.QuestTitle.Title.Text, q[1])
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
                            repeat
                                Attack.Kill(enemy, true)
                                task.wait()
                            until not optVal("AutoFarmLevel", false) or not isAlive(enemy)
                        else
                            local spawns = WorldOrigin:FindFirstChild("EnemySpawns")
                            if spawns then
                                for _, s in pairs(spawns:GetChildren()) do
                                    if string.find(s.Name, q[3]) then
                                        tp(s.CFrame * CFrame.new(0,20,0)); break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if optVal("AutoFarmNearest", false) then
                local maxR = optVal("NearestRange","Infinite") == "Infinite"
                    and math.huge or tonumber(optVal("NearestRange","Infinite"))
                local nearest, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d <= maxR then nd=d; nearest=e end
                    end
                end
                if nearest then Attack.Kill(nearest, true) end
            end

            if optVal("AutoFactory", false) then
                local core = findEnemy({"Core"})
                if core then Attack.Kill(core, true)
                else tp(CFrame.new(502, 143, -379)) end
            end

            if optVal("AutoEctoplasm", false) then
                local e = findEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
                if e then Attack.Kill(e, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(923,126,32852)) end
            end

            if optVal("AutoCollectChest", false) then
                if optVal("StopRareItems", true) and
                    (hasTool("God's Chalice") or hasTool("Fist of Darkness") or hasTool("Sweet Chalice")) then
                    if Options.AutoCollectChest then Options.AutoCollectChest:SetValue(false) end
                else
                    local chests = CollectionService:GetTagged("_ChestTagged")
                    local nearest, nd = nil, math.huge
                    for _, c in ipairs(chests) do
                        if not c:GetAttribute("IsDisabled") then
                            local ok, pv = pcall(function() return c:GetPivot() end)
                            if ok and pv then
                                local d = (pv.Position - Root.Position).Magnitude
                                if d < nd then nd=d; nearest=c end
                            end
                        end
                    end
                    if nearest then tp(nearest:GetPivot())
                    elseif optVal("AutoHopNoChest", false) then
                        pcall(function()
                            local data = HttpService:JSONDecode(game:HttpGet(
                                "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                            ))
                            for _, s in pairs(data.data) do
                                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                    TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
                                end
                            end
                        end)
                    end
                end
            end

            if optVal("AutoCollectBerry", false) then
                for _, b in pairs(Map:GetDescendants()) do
                    if b.Name == "Berries" then
                        for i = 1, 8 do
                            if b:GetAttribute("_BerryCFrame"..i) then
                                tp(b.Parent.WorldPivot)
                            end
                        end
                    end
                end
            end

            if optVal("AutoMastery", false) then
                local mode = optVal("MasteryMode","Level")
                equipByTip(optVal("MasteryWeapon","Melee"))
                local enemy
                if mode == "Level" then
                    local q = getQuestInfo()
                    if q then enemy = findEnemy({q[1]}) end
                elseif mode == "Bone" then
                    enemy = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                elseif mode == "Cake Prince" then
                    enemy = findEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
                elseif mode == "Nearest" then
                    local nd = math.huge
                    for _, e in pairs(Enemies:GetChildren()) do
                        if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                            local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                            if d < nd and d < 3500 then nd=d; enemy=e end
                        end
                    end
                end
                if enemy then Attack.Kill(enemy, true) end
            end

            if optVal("AutoMaterial", false) then
                local matData = {
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
                local mons = matData[optVal("MaterialSel", materialList[1])]
                if mons then
                    local e = findEnemy(mons)
                    if e then Attack.Kill(e, true) end
                end
            end

            if optVal("AutoBoss", false) then
                local b = findEnemy({optVal("BossSel", bossList[1])})
                if b then Attack.Kill(b, true) end
            end
            if optVal("AutoAllBoss", false) then
                local b = findEnemy(bossList)
                if b then Attack.Kill(b, true) end
            end
            if optVal("AutoCakePrince", false) then
                local cm = findEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then Attack.Kill(cm, true) end
                local cp = findEnemy({"Cake Prince","Dough King"})
                if cp then Attack.Kill(cp, true) end
            end
            if optVal("AutoDoughKing", false) then
                local dk = findEnemy({"Dough King"})
                if dk then Attack.Kill(dk, true) end
            end
            if optVal("AutoBone", false) then
                local b = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-9516,142,5536)) end
            end
            if optVal("AutoSoulReaper", false) then
                local sr = findEnemy({"Soul Reaper"})
                if sr then Attack.Kill(sr, true)
                elseif not hasTool("Hallow Essence") then
                    CommF_:InvokeServer("Bones","Buy",1,1)
                else
                    tp(CFrame.new(-8932,146,6062)); task.wait(0.5)
                    equipToolByName("Hallow Essence")
                end
            end
            if optVal("AutoElite", false) then
                local elite = findEnemy({"Diablo","Deandre","Urban"})
                if elite then Attack.Kill(elite, true)
                else pcall(function() CommF_:InvokeServer("EliteHunter") end) end
            end
            if optVal("AutoPiratesSea", false) then
                local b = findEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-5556,314,-2988)) end
            end
            if optVal("AutoRipIndra", false) then
                local ri = findEnemy({"rip_indra"})
                if ri then Attack.Kill(ri, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097,316,-3142)) end
            end
            if optVal("AutoRainbowHaki", false) then
                local quest = MainGui:FindFirstChild("Quest")
                if quest and not quest.Visible then
                    tp(CFrame.new(-11892,930,-8760))
                    if getDist(CFrame.new(-11892,930,-8760)) < 10 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local e = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if e then Attack.Kill(e, true) end
                end
            end
            if optVal("AutoCitizen", false) then
                local quest = MainGui:FindFirstChild("Quest")
                if quest and not quest.Visible then
                    tp(CFrame.new(-11893.7,929.66,-8760.59))
                    if getDist(CFrame.new(-11893.7,929.66,-8760.59)) < 8 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local m = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if m then Attack.Kill(m, true) end
                end
            end
            if optVal("AutoTryLuck", false) then
                local pos = CFrame.new(-8761,164,6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 1) end
            end
            if optVal("AutoPray", false) then
                local pos = CFrame.new(-8761,164,6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 2) end
            end
        end)
    end
end)

--=====================================================================
-- TAB 3: FISHING
--=====================================================================
Tabs.Fishing:AddSection("Fishing")
Tabs.Fishing:AddDropdown("FishingRod", {
    Title="Fishing Rod",
    Values={"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default="Fishing Rod"
})
Tabs.Fishing:AddDropdown("FishingBait", {
    Title="Bait",
    Values={"Basic Bait","Kelp Bait","Good Bait","Abyssal Bait","Frozen Bait","Epic Bait","Carnivore Bait"},
    Default="Basic Bait"
})
Tabs.Fishing:AddToggle("AutoBuyBait",    {Title="Auto Buy Bait",    Default=false})
Tabs.Fishing:AddToggle("AutoEquipRod",   {Title="Auto Equip Rod",   Default=false})
Tabs.Fishing:AddToggle("AutoFishing",    {Title="Auto Fishing",     Default=false})
Tabs.Fishing:AddToggle("AutoFishingQuest",{Title="Auto Fishing Quest",Default=false})
Tabs.Fishing:AddToggle("AutoFishComplete",{Title="Auto Complete Quest",Default=false})
Tabs.Fishing:AddToggle("AutoSellFish",   {Title="Auto Sell Fish",    Default=false})
Tabs.Fishing:AddToggle("AutoSellCorrupt",{Title="Auto Sell Corrupted Fish",Default=false})
Tabs.Fishing:AddToggle("SpamSkillZ",     {Title="Auto Spam Skill Z", Default=false})

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if not LocalPlayer.Character then return end
            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if optVal("AutoEquipRod",false) and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        LocalPlayer.Character.Humanoid:EquipTool(t); break
                    end
                end
            end
            if optVal("AutoBuyBait",false) and optVal("FishingBait",false) and Net then
                pcall(function()
                    local RF = Net:FindFirstChild("RF/Craft")
                    if RF then RF:InvokeServer("Craft", optVal("FishingBait","Basic Bait"), {}) end
                end)
            end
            if optVal("AutoFishing",false) and tool
                and tool:GetAttribute("InventoryCategory") == "Rod" then
                if tool:GetAttribute("SkillChargeAlpha") and tool:GetAttribute("SkillChargeAlpha") >= 1 then
                    pcall(function()
                        Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true)
                    end)
                end
                local state = tool:GetAttribute("State")
                local Fish = ReplicatedStorage:FindFirstChild("FishReplicated")
                local FR = Fish and Fish:FindFirstChild("FishingRequest")
                if FR then
                    if state == "ReeledIn" then
                        pcall(function()
                            FR:InvokeServer("StartCasting")
                            task.wait(0.7)
                            local hrp = LocalPlayer.Character.HumanoidRootPart
                            local ray = Ray.new(LocalPlayer.Character.Head.Position,
                                hrp.CFrame.LookVector * 100)
                            local _, hit = workspace:FindPartOnRayWithIgnoreList(
                                ray, {LocalPlayer.Character, Characters, Enemies})
                            if hit then
                                FR:InvokeServer("CastLineAtLocation", hit, 100, true)
                            end
                        end)
                    elseif state == "Biting" then
                        pcall(function()
                            FR:InvokeServer("Catching", true)
                            task.wait(0.25)
                            FR:InvokeServer("Catch", 1)
                        end)
                    end
                end
            end
            if optVal("AutoFishingQuest",false) and Net then
                pcall(function()
                    local RF = Net:FindFirstChild("RF/JobsRemoteFunction")
                    if RF then
                        local gui = PlayerGui:FindFirstChild("Quest") or PlayerGui:FindFirstChild("QuestGui")
                        if not gui or not gui.Visible then
                            RF:InvokeServer("FishingNPC","Angler","AskQuest")
                        end
                    end
                end)
            end
            if optVal("AutoFishComplete",false) and Net then
                pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","FinishQuest") end)
            end
            if optVal("AutoSellFish",false) and Net then
                pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellFish") end)
            end
            if optVal("AutoSellCorrupt",false) and Net then
                pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellCorruptedFish") end)
            end
            if optVal("SpamSkillZ",false) and Net then
                pcall(function() Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true) end)
            end
        end)
    end
end)

--=====================================================================
-- TAB 4: QUEST & ITEM
--=====================================================================
Tabs.QuestItem:AddSection("Swords")
Tabs.QuestItem:AddDropdown("SwordSel", {
    Title="Sword",
    Values={"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default="Twin Hooks"
})
Tabs.QuestItem:AddToggle("AutoGetSword",   {Title="Auto Get Sword",       Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.QuestItem:AddToggle("AutoGetSerpent", {Title="Auto Get Serpent Bow", Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.QuestItem:AddToggle("AutoTushita",    {Title="Auto Tushita Sword",   Default=false})
Tabs.QuestItem:AddToggle("AutoYama",       {Title="Auto Yama Sword",      Default=false})

Tabs.QuestItem:AddSection("Fighting Styles")
for _, t in ipairs({
    {"AutoSuperhuman","Auto Superhuman"},{"AutoDeathStep","Auto Death Step"},
    {"AutoSharkman","Auto Sharkman Karate"},{"AutoElectricClaw","Auto Electric Claw"},
    {"AutoDragonTalon","Auto Dragon Talon"},{"AutoGodHuman","Auto Godhuman"},
    {"AutoSanguine","Auto Sanguine Art"}
}) do
    Tabs.QuestItem:AddToggle(t[1], {Title=t[2], Default=false})
end

Tabs.QuestItem:AddSection("Race V2 / V3")
Tabs.QuestItem:AddToggle("AutoV2", {Title="Auto Race V2", Default=false})
Tabs.QuestItem:AddToggle("AutoV3", {Title="Auto Race V3", Default=false})

Tabs.QuestItem:AddSection("V4 Trial")
Tabs.QuestItem:AddButton({Title="Teleport Temple of Time", Callback=function()
    safe(function()
        if Root then Root.CFrame = CFrame.new(28286,14895,102) end
        local stash = ReplicatedStorage:FindFirstChild("MapStash")
        if stash and stash:FindFirstChild("Temple of Time")
            and not Map:FindFirstChild("Temple of Time") then
            stash["Temple of Time"].Parent = Map
        end
    end)
end})
Tabs.QuestItem:AddButton({Title="Pull Lever", Callback=function()
    safe(function()
        if Map:FindFirstChild("Temple of Time") then
            for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
                if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
            end
        end
    end)
end})
Tabs.QuestItem:AddToggle("AutoTrial",     {Title="Auto Complete Trial", Default=false})
Tabs.QuestItem:AddToggle("AutoKillTrial", {Title="Auto Kill Players After Trial", Default=false})

Tabs.QuestItem:AddSection("Quick Purchase")
local quickBtns = {
    {"Buy Buso",{"BuyHaki","Buso"}}, {"Buy Geppo",{"BuyHaki","Geppo"}},
    {"Buy Soru",{"BuyHaki","Soru"}}, {"Buy Ken",{"KenTalk","Buy"}},
    {"Buy Black Leg",{"BuyBlackLeg"}}, {"Buy Electro",{"BuyElectro"}},
    {"Buy Fishman Karate",{"BuyFishmanKarate"}}, {"Buy Superhuman",{"BuySuperhuman"}},
    {"Buy Death Step",{"BuyDeathStep"}}, {"Buy Sharkman Karate",{"BuySharkmanKarate"}},
    {"Buy Electric Claw",{"BuyElectricClaw"}}, {"Buy Dragon Talon",{"BuyDragonTalon"}},
    {"Buy Godhuman",{"BuyGodhuman"}}, {"Buy Sanguine Art",{"BuySanguineArt"}},
    {"Buy Katana",{"BuyItem","Katana"}}, {"Buy Cutlass",{"BuyItem","Cutlass"}},
    {"Buy Dual Katana",{"BuyItem","Dual Katana"}}, {"Buy Iron Mace",{"BuyItem","Iron Mace"}},
    {"Buy Triple Katana",{"BuyItem","Triple Katana"}}, {"Buy Pipe",{"BuyItem","Pipe"}},
    {"Buy Soul Cane",{"BuyItem","Soul Cane"}}, {"Buy Bisento",{"BuyItem","Bisento"}}
}
for _, b in ipairs(quickBtns) do
    local a = b[2]
    Tabs.QuestItem:AddButton({Title=b[1], Callback=function()
        safe(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end

Tabs.QuestItem:AddSection("Special Items")
Tabs.QuestItem:AddButton({Title="Buy Legendary Swords", Callback=function()
    safe(function()
        CommF_:InvokeServer("LegendarySwordDealer","1")
        CommF_:InvokeServer("LegendarySwordDealer","2")
        CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
end})
Tabs.QuestItem:AddButton({Title="Buy True Triple Katana", Callback=function()
    safe(function() CommF_:InvokeServer("MysteriousMan","2") end)
end})
Tabs.QuestItem:AddButton({Title="Buy Ghoul Race", Callback=function()
    safe(function() CommF_:InvokeServer("Ectoplasm","Change",4) end)
end})
Tabs.QuestItem:AddButton({Title="Buy Cyborg Race", Callback=function()
    safe(function() CommF_:InvokeServer("CyborgTrainer","Buy") end)
end})

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if optVal("AutoGetSword",false) then
                local map = {
                    ["Twin Hooks"]={"Captain Elephant"}, ["Buddy Sword"]={"Cake Queen"},
                    ["Canvander"]={"Beautiful Pirate"}, ["Dark Dagger"]={"rip_indra True Form"},
                    ["Spikey Trident"]={"Dough King"}, ["Hallow Scythe"]={"Soul Reaper"}
                }
                local e = findEnemy(map[optVal("SwordSel","")] or {})
                if e then Attack.Kill(e, true) end
            end
            if optVal("AutoGetSerpent",false) then
                local e = findEnemy({"Island Empress"})
                if e then Attack.Kill(e, true)
                else tp(CFrame.new(5659,602,244)) end
            end
            if optVal("AutoTrial",false) and LocalPlayer.Character and RaceData then
                local race = tostring(RaceData.Value)
                if race == "Mink" and Map:FindFirstChild("MinkTrial") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        Map.MinkTrial.Ceiling.CFrame * CFrame.new(0,-20,0)
                elseif race == "Cyborg" and Map:FindFirstChild("CyborgTrial") then
                    tp(Map.CyborgTrial.Floor.CFrame * CFrame.new(0,500,0))
                elseif race == "Skypiea" and Map:FindFirstChild("SkyTrial") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame =
                        Map.SkyTrial.Model.FinishPart.CFrame
                elseif race == "Human" or race == "Ghoul" then
                    local e = findEnemy({"Ancient Vampire","Ancient Zombie"})
                    if e then Attack.Kill(e, true) end
                end
            end
            if optVal("AutoKillTrial",false) then
                local t = MainGui:FindFirstChild("Timer")
                if t and t.Visible then
                    for _, c in pairs(Characters:GetChildren()) do
                        if c.Name ~= LocalPlayer.Name and isAlive(c)
                            and c:FindFirstChild("HumanoidRootPart") then
                            if getDist(c.HumanoidRootPart.Position) <= 250 then
                                Attack.Kill(c, true)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB 5: VOLCANO
--=====================================================================
Tabs.Volcano:AddSection("Prehistoric Island")
Tabs.Volcano:AddToggle("AutoSummonPrehis",{Title="Auto Summon Prehistoric Island",Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Volcano:AddToggle("TweenPrehis",     {Title="Tween to Prehistoric Island",   Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Volcano:AddToggle("AutoStartPrehis", {Title="Auto Start Prehistoric Event", Default=false})
Tabs.Volcano:AddToggle("AutoPatchPrehis", {Title="Auto Patch Prehistoric Event", Default=false})
Tabs.Volcano:AddToggle("CollectDinoBones",{Title="Auto Collect Dino Bones",       Default=false}):OnChanged(function(v) shouldTween=v end)
Tabs.Volcano:AddToggle("CollectDragonEggs",{Title="Auto Collect Dragon Eggs",     Default=false})

Tabs.Volcano:AddSection("Dragon Trial")
Tabs.Volcano:AddButton({Title="Teleport Dragon Dojo", Callback=function()
    safe(function()
        CommF_:InvokeServer("requestEntrance", Vector3.new(5661,1013,-334))
        tp(CFrame.new(5814,1208,884))
    end)
end})
Tabs.Volcano:AddToggle("AutoDojo",    {Title="Auto Dojo Trainer", Default=false})
Tabs.Volcano:AddToggle("AutoDracoV1", {Title="Auto Draco V1", Default=false})
Tabs.Volcano:AddToggle("AutoDracoV2", {Title="Auto Draco V2 (Fire Flowers)", Default=false})
Tabs.Volcano:AddToggle("AutoDracoV3", {Title="Auto Draco V3 (Sea)", Default=false})

Tabs.Volcano:AddSection("Crafting")
for _, item in ipairs({"Dragonheart","Dragonstorm","DinoHood","TRexSkull"}) do
    Tabs.Volcano:AddButton({Title="Craft "..item, Callback=function()
        safe(function() CommF_:InvokeServer("CraftItem","Craft",item) end)
    end})
end

task.spawn(function()
    while task.wait(0.4) do
        safe(function()
            if not LocalPlayer.Character then return end

            if optVal("AutoSummonPrehis",false) and not Map:FindFirstChild("PrehistoricIsland") then
                local boat
                local boatsFolder = workspace:FindFirstChild("Boats")
                if boatsFolder then
                    for _, b in pairs(boatsFolder:GetChildren()) do
                        local owner = b:FindFirstChild("Owner")
                        if owner and tostring(owner.Value) == LocalPlayer.Name then
                            boat = b; break
                        end
                    end
                end
                if not boat then
                    local shop = CFrame.new(-13.48, 10.31, 2927.69)
                    tp(shop)
                    if getDist(shop) < 10 then
                        CommF_:InvokeServer("BuyBoat","PirateBrigade")
                    end
                elseif boat and boat:FindFirstChild("VehicleSeat") and boat.PrimaryPart then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Sit then
                        pcall(function()
                            local bv = boat.PrimaryPart:FindFirstChild("PrehisBoatVel")
                            if not bv then
                                bv = Instance.new("BodyVelocity")
                                bv.Name="PrehisBoatVel"
                                bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                                bv.Velocity=Vector3.zero
                                bv.Parent=boat.PrimaryPart
                            end
                            TweenService:Create(boat.PrimaryPart,
                                TweenInfo.new(200,Enum.EasingStyle.Linear),
                                {CFrame=boat.PrimaryPart.CFrame*CFrame.new(0,5,-50000)}):Play()
                        end)
                    else tp(boat.VehicleSeat.CFrame) end
                end
            end

            if optVal("TweenPrehis",false) then
                local p = Map:FindFirstChild("PrehistoricIsland")
                if p then tp(p:GetPivot()*CFrame.new(2,20,2)) end
            end
            if optVal("CollectDinoBones",false) then
                for _, d in pairs(workspace:GetChildren()) do
                    if d.Name == "DinoBone" then tp(d.CFrame) end
                end
            end
            if optVal("CollectDragonEggs",false) then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    local core = isl:FindFirstChild("Core")
                    if core and core:FindFirstChild("SpawnedDragonEggs") then
                        local egg = core.SpawnedDragonEggs:FindFirstChild("DragonEgg")
                        if egg and egg:FindFirstChild("Molten") then
                            tp(egg.Molten.CFrame)
                            pcall(function()
                                fireproximityprompt(egg.Molten.ProximityPrompt, 30)
                            end)
                        end
                    end
                end
            end
            if optVal("AutoStartPrehis",false) then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    local core = isl:FindFirstChild("Core")
                    if core then
                        local prompt = core:FindFirstChild("ActivationPrompt", true)
                        if prompt and prompt:FindFirstChild("ProximityPrompt") then
                            tp(prompt.CFrame)
                            if getDist(prompt.CFrame.Position) <= 150 then
                                pcall(function()
                                    fireproximityprompt(prompt.ProximityPrompt, math.huge)
                                end)
                                sendKey("E", 1.5)
                            end
                        end
                    end
                end
            end
            if optVal("AutoPatchPrehis",false) then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    for _, o in pairs(isl:GetDescendants()) do
                        if (o:IsA("BasePart") or o:IsA("MeshPart"))
                            and o.Name:lower():find("lava") then
                            o:Destroy()
                        end
                    end
                end
            end
            if optVal("AutoDracoV2",false) then
                for _, d in pairs(workspace:GetChildren()) do
                    if d.Name == "FireFlowers" then
                        for _, f in pairs(d:GetChildren()) do
                            if f.PrimaryPart then
                                local pos = f.PrimaryPart.Position
                                tp(CFrame.new(pos))
                                if getDist(pos) <= 100 then sendKey("E",1.5) end
                            end
                        end
                    end
                end
            end
            if optVal("AutoDojo",false) and Net then
                pcall(function()
                    local rf = Net:FindFirstChild("RF/InteractDragonQuest")
                    if rf then
                        local resp = rf:InvokeServer({NPC="Dojo Trainer",Command="RequestQuest"})
                        if not resp or not resp.Quest or not resp.Quest.BeltName then
                            tp(CFrame.new(5865,1208,871))
                        end
                    end
                end)
            end
        end)
    end
end)

--=====================================================================
-- TAB 6: STATS & ESP
--=====================================================================
Tabs.StatsESP:AddSection("Stats Upgrade")
Tabs.StatsESP:AddSlider("StatsVal", {
    Title="Points Per Stat", Default=10, Min=1, Max=100, Rounding=0
})
for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
    Tabs.StatsESP:AddToggle("autoStat_"..stat, {Title="Auto "..stat, Default=false})
end

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if not Data or not Data:FindFirstChild("Points") then return end
            for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                if optVal("autoStat_"..stat, false) then
                    if Data.Points.Value > 0 then
                        CommF_:InvokeServer("AddPoint",
                            stat == "Blox Fruit" and "Demon Fruit" or stat,
                            tonumber(optVal("StatsVal",10)) or 10)
                    end
                end
            end
        end)
    end
end)

Tabs.StatsESP:AddSection("ESP")
local ESPNum = math.random(100000, 999999)
local function createESP(part, color, label)
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
Tabs.StatsESP:AddToggle("EspPlayer",{Title="ESP Player",Default=false})
Tabs.StatsESP:AddToggle("EspChest", {Title="ESP Chest", Default=false})
Tabs.StatsESP:AddToggle("EspFruit", {Title="ESP Devil Fruit", Default=false})
Tabs.StatsESP:AddToggle("EspBerry", {Title="ESP Berry", Default=false})
Tabs.StatsESP:AddToggle("EspEvent", {Title="ESP Event Islands", Default=false})
Tabs.StatsESP:AddButton({Title="Clear All ESP", Callback=function()
    safe(function()
        for _, d in pairs(workspace:GetDescendants()) do
            if d.Name == "FarmESP"..ESPNum then d:Destroy() end
        end
    end)
end})

task.spawn(function()
    while task.wait(1) do
        safe(function()
            if optVal("EspPlayer",false) then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character
                        and p.Character:FindFirstChild("Head") then
                        local d = getDist(p.Character.Head.Position)
                        createESP(p.Character.Head, Color3.fromRGB(0,255,0),
                            string.format("%s [%d]", p.Name, math.floor(d/3)))
                    end
                end
            end
            if optVal("EspChest",false) then
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not c:GetAttribute("IsDisabled") then
                        local part = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
                        if part then
                            createESP(part, Color3.fromRGB(255,255,0),
                                "Chest ["..math.floor(getDist(part.Position)/3).."]")
                        end
                    end
                end
            end
            if optVal("EspFruit",false) then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        createESP(f.Handle, Color3.fromRGB(255,100,100), f.Name)
                    end
                end
            end
            if optVal("EspEvent",false) and WorldOrigin:FindFirstChild("Locations") then
                for _, i in pairs(WorldOrigin.Locations:GetChildren()) do
                    if (i.Name=="Mirage Island" or i.Name=="Prehistoric Island"
                        or i.Name=="Kitsune Island" or i.Name=="Frozen Dimension")
                        and i:IsA("BasePart") then
                        createESP(i, Color3.fromRGB(150,255,150), i.Name)
                    end
                end
            end
        end)
    end
end)

--=====================================================================
-- TAB 7: FRUIT & RAID
--=====================================================================
Tabs.FruitRaid:AddSection("Fruit Management")
Tabs.FruitRaid:AddToggle("AutoRandomFruit",{Title="Auto Random Fruit",Default=false})
Tabs.FruitRaid:AddToggle("AutoStoreFruit", {Title="Auto Store Fruit", Default=false})
Tabs.FruitRaid:AddToggle("AutoDropFruit",  {Title="Auto Drop Fruit",  Default=false})
Tabs.FruitRaid:AddToggle("AutoFindFruit",  {Title="Auto Find Fruit",  Default=false}):OnChanged(function(v) shouldTween=v end)

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
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
                    if t:IsA("Tool") and string.find(t.Name,"Fruit")
                        and t:FindFirstChild("EatRemote") then
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

Tabs.FruitRaid:AddSection("Raids")
Tabs.FruitRaid:AddDropdown("RaidChip", {
    Title="Raid Chip",
    Values={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default="Flame"
})
Tabs.FruitRaid:AddToggle("AutoBuyChip",{Title="Auto Buy Chip", Default=false})
Tabs.FruitRaid:AddToggle("AutoAwake",  {Title="Auto Awakening",Default=false})

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
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

--=====================================================================
-- TAB 8: LOCAL PLAYER
--=====================================================================
Tabs.LocalPlayer:AddSection("Aimbot")
local plrNames = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end
if #plrNames == 0 then plrNames = {""} end

Tabs.LocalPlayer:AddDropdown("AimPlayer", {
    Title="Target Player", Values=plrNames, Default=plrNames[1]
})
Tabs.LocalPlayer:AddDropdown("AimMethod", {
    Title="Aim Method", Values={"Aim Player","Nearest Aim"}, Default="Aim Player"
})
Tabs.LocalPlayer:AddToggle("Aimbot", {Title="Aimbot Skills", Default=false}):OnChanged(function(v)
    _G.AimbotEnabled = v
end)
Tabs.LocalPlayer:AddToggle("NoClip", {Title="No Clip", Default=false})

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

task.spawn(function()
    safe(function()
        if not getrawmetatable then return end
        local meta = getrawmetatable(game)
        local old = meta.__namecall
        if not setreadonly then return end
        setreadonly(meta, false)
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if _G.AimbotEnabled and method == "FireServer"
                and tostring(self) == "RemoteEvent"
                and typeof(args[2]) == "Vector3" then
                local target
                if optVal("AimMethod","Aim Player") == "Aim Player" then
                    target = Players:FindFirstChild(optVal("AimPlayer",""))
                elseif optVal("AimMethod","Aim Player") == "Nearest Aim" then
                    local nd, tgt = math.huge, nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character
                            and p.Character:FindFirstChild("HumanoidRootPart")
                            and p.Team ~= LocalPlayer.Team then
                            local d = getDist(p.Character.HumanoidRootPart.Position)
                            if d < nd then nd=d; tgt=p end
                        end
                    end
                    target = tgt
                end
                if target and target.Character
                    and target.Character:FindFirstChild("HumanoidRootPart") then
                    args[2] = target.Character.HumanoidRootPart.Position
                    return old(self, unpack(args))
                end
            end
            return old(self, ...)
        end)
        setreadonly(meta, true)
    end)
end)

Tabs.LocalPlayer:AddSection("Player Hunter")
Tabs.LocalPlayer:AddButton({Title="Get Player Quest", Callback=function()
    safe(function() CommF_:InvokeServer("PlayerHunter") end)
end})
Tabs.LocalPlayer:AddToggle("AutoGetPlayerQuest", {Title="Auto Get Player Quest",Default=false})
Tabs.LocalPlayer:AddToggle("AutoKillPlayerQuest",{Title="Auto Kill Player Quest",Default=false})
Tabs.LocalPlayer:AddToggle("AutoPvP",            {Title="Auto Enable PvP",Default=false})

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
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

--=====================================================================
-- TAB 9: TELEPORT
--=====================================================================
Tabs.Teleport:AddSection("Worlds")
Tabs.Teleport:AddButton({Title="Sea 1", Callback=function() safe(function() CommF_:InvokeServer("TravelMain") end) end})
Tabs.Teleport:AddButton({Title="Sea 2", Callback=function() safe(function() CommF_:InvokeServer("TravelDressrosa") end) end})
Tabs.Teleport:AddButton({Title="Sea 3", Callback=function() safe(function() CommF_:InvokeServer("TravelZou") end) end})

Tabs.Teleport:AddSection("Islands")
local islandNames = {}
if WorldOrigin:FindFirstChild("Locations") then
    for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
        table.insert(islandNames, l.Name)
    end
end
if #islandNames == 0 then islandNames = {""} end
Tabs.Teleport:AddDropdown("IslandSel", {
    Title="Island", Values=islandNames, Default=islandNames[1]
})
Tabs.Teleport:AddToggle("TweenIsland", {Title="Auto Travel Island", Default=false}):OnChanged(function(v) shouldTween=v end)

Tabs.Teleport:AddSection("Portals")
local portals = {
    {"Sky (Sea1)", {"requestEntrance", Vector3.new(-7894,5547,-380)}},
    {"Underwater (Sea1)", {"requestEntrance", Vector3.new(61163,11,1819)}},
    {"Swan Room (Sea2)", {"requestEntrance", Vector3.new(2285,15,905)}},
    {"Cursed Ship (Sea2)", {"requestEntrance", Vector3.new(923,126,32852)}},
    {"Castle On The Sea (Sea3)", {"requestEntrance", Vector3.new(-5097,316,-3142)}},
    {"Mansion (Sea3)", {"requestEntrance", Vector3.new(-12471,374,-7551)}},
    {"Hydra (Sea3)", {"requestEntrance", Vector3.new(5643,1013,-340)}}
}
for _, p in ipairs(portals) do
    local a = p[2]
    Tabs.Teleport:AddButton({Title=p[1], Callback=function()
        safe(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end

task.spawn(function()
    while task.wait(0.3) do
        safe(function()
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

--=====================================================================
-- TAB 10: SHOPPING
--=====================================================================
Tabs.Shopping:AddSection("Shop")
for _, b in ipairs(quickBtns) do
    local a = b[2]
    Tabs.Shopping:AddButton({Title=b[1], Callback=function()
        safe(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end
Tabs.Shopping:AddSection("Fragments")
Tabs.Shopping:AddButton({Title="Reroll Race (Frags)", Callback=function()
    safe(function() CommF_:InvokeServer("BlackbeardReward","Reroll","2") end)
end})
Tabs.Shopping:AddButton({Title="Refund Stats (Frags)", Callback=function()
    safe(function() CommF_:InvokeServer("BlackbeardReward","Refund","2") end)
end})
Tabs.Shopping:AddButton({Title="Buy Legendary Swords", Callback=function()
    safe(function()
        CommF_:InvokeServer("LegendarySwordDealer","1")
        CommF_:InvokeServer("LegendarySwordDealer","2")
        CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
end})
Tabs.Shopping:AddButton({Title="Buy True Triple Katana", Callback=function()
    safe(function() CommF_:InvokeServer("MysteriousMan","2") end)
end})
Tabs.Shopping:AddButton({Title="Buy Ghoul Race", Callback=function()
    safe(function() CommF_:InvokeServer("Ectoplasm","Change",4) end)
end})
Tabs.Shopping:AddButton({Title="Buy Cyborg Race", Callback=function()
    safe(function() CommF_:InvokeServer("CyborgTrainer","Buy") end)
end})

--=====================================================================
-- TAB 11: MISC
--=====================================================================
Tabs.Misc:AddSection("Server")
Tabs.Misc:AddButton({Title="Hop Server", Callback=function()
    safe(function()
        local data = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        ))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
            end
        end
    end)
end})
Tabs.Misc:AddButton({Title="Rejoin Server", Callback=function()
    safe(function() TeleportService:Teleport(PlaceId, LocalPlayer) end)
end})
Tabs.Misc:AddButton({Title="Copy Job ID", Callback=function()
    safe(function() setclipboard(tostring(game.JobId)) end)
end})

Tabs.Misc:AddSection("Teams")
Tabs.Misc:AddButton({Title="Join Pirates", Callback=function() safe(function() CommF_:InvokeServer("SetTeam","Pirates") end) end})
Tabs.Misc:AddButton({Title="Join Marines", Callback=function() safe(function() CommF_:InvokeServer("SetTeam","Marines") end) end})

Tabs.Misc:AddSection("Visual")
Tabs.Misc:AddToggle("RemoveDamage",{Title="Remove Damage Numbers", Default=false})
Tabs.Misc:AddToggle("RemoveNotify",{Title="Remove Notifications", Default=false})
Tabs.Misc:AddToggle("WalkWater",   {Title="Walk on Water", Default=false}):OnChanged(function(v)
    local w = Map:FindFirstChild("WaterBase-Plane")
    if w then w.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
end)
Tabs.Misc:AddToggle("FullBright", {Title="Full Bright", Default=false}):OnChanged(function(v)
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
Tabs.Misc:AddToggle("LowCPU", {Title="Low CPU Mode", Default=false}):OnChanged(function(v)
    if v then
        safe(function()
            local t = workspace.Terrain
            t.WaterWaveSize=0; t.WaterWaveSpeed=0
            t.WaterReflectance=0; t.WaterTransparency=0
            Lighting.GlobalShadows=false
            Lighting.FogEnd=9e9
            Lighting.Brightness=0
            pcall(function() settings().Rendering.QualityLevel = "Level01" end)
        end)
    end
end)

Tabs.Misc:AddSection("Redeem & Menu")
Tabs.Misc:AddButton({Title="Redeem All Codes", Callback=function()
    safe(function()
        local codes = {
            "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
            "BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
            "SUB2GAMEROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
            "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
            "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
            "Starcodeheo","Bluxxy","SUB2GAMEROBOT_EXP1","Sub2NoobMaster123",
            "Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie",
            "TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN"
        }
        local RedeemRemote = Remotes:FindFirstChild("Redeem")
        if not RedeemRemote then return end
        for _, code in ipairs(codes) do
            pcall(function()
                if RedeemRemote.InvokeServer then RedeemRemote:InvokeServer(code)
                else RedeemRemote:FireServer(code) end
            end)
            task.wait(0.1)
        end
    end)
end})
Tabs.Misc:AddButton({Title="Open Titles Menu", Callback=function()
    safe(function()
        CommF_:InvokeServer("getTitles", true)
        MainGui.Titles.Visible = true
    end)
end})
Tabs.Misc:AddButton({Title="Open Haki Colors", Callback=function()
    safe(function() MainGui.Colors.Visible = true end)
end})
Tabs.Misc:AddButton({Title="Open Awakening Menu", Callback=function()
    safe(function() MainGui.AwakeningToggler.Visible = true end)
end})

task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if optVal("RemoveDamage",false) then
                local dmg = ReplicatedStorage.Assets
                    and ReplicatedStorage.Assets.GUI
                    and ReplicatedStorage.Assets.GUI.DamageCounter
                if dmg then dmg.Enabled = false end
            end
            if PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = not optVal("RemoveNotify", false)
            end
        end)
    end
end)

--=====================================================================
-- TAB 12: SETTINGS
--=====================================================================
Tabs.Settings:AddSection("Combat")
Tabs.Settings:AddToggle("KillAura", {Title="Kill Aura", Default=false})
Tabs.Settings:AddDropdown("WeaponTool_S", {
    Title="Weapon Tool",
    Values={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee"
}):OnChanged(function(v)
    local o = Options.WeaponTool
    if o then pcall(function() o:SetValue(v) end) end
end)
Tabs.Settings:AddDropdown("TweenSpeed", {
    Title="Tween Speed",
    Values={"100","200","300","400","500","800","1000"}, Default="300"
})
Tabs.Settings:AddToggle("BringMob", {Title="Bring Mob", Default=true})
Tabs.Settings:AddDropdown("BringRadius", {
    Title="Bring Radius",
    Values={"100","200","300","400","500","1000"}, Default="300"
})
Tabs.Settings:AddToggle("FastAttack", {Title="Fast Attack", Default=false})

Tabs.Settings:AddSection("Auto Abilities")
Tabs.Settings:AddToggle("AutoTurnV3", {Title="Auto Turn V3", Default=false})
Tabs.Settings:AddToggle("AutoTurnV4", {Title="Auto Turn V4", Default=false})
Tabs.Settings:AddToggle("AutoBuso",   {Title="Auto Turn on Buso", Default=false})
Tabs.Settings:AddToggle("AutoKen",    {Title="Auto Haki Observation", Default=false})

Tabs.Settings:AddSection("Anti / Notifications")
Tabs.Settings:AddToggle("AntiAFK", {Title="Anti AFK", Default=true}):OnChanged(function(v)
    if v then
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end
end)
Tabs.Settings:AddToggle("AntiAdmin",    {Title="Auto Anti-Admin Join Server", Default=false})
Tabs.Settings:AddToggle("DisableNotify",{Title="Disable Notify", Default=false})

--// KILL AURA
task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if optVal("KillAura",false) and Root then
                pcall(function()
                    if sethiddenproperty then
                        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
                    end
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
            end
        end)
    end
end)

--// AUTO ABILITIES
task.spawn(function()
    while task.wait(0.5) do
        safe(function()
            if not LocalPlayer.Character then return end
            if optVal("AutoBuso",false)
                and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                CommF_:InvokeServer("Buso")
            end
            if optVal("AutoKen",false) and CommE then
                CommE:FireServer("Ken", true)
            end
            if optVal("AutoTurnV3",false) and CommE then
                CommE:FireServer("ActivateAbility")
            end
            if optVal("AutoTurnV4",false)
                and LocalPlayer.Character:FindFirstChild("RaceEnergy") then
                if LocalPlayer.Character.RaceEnergy.Value == 1 then sendKey("Y") end
            end
            if optVal("DisableNotify",false)
                and PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = false
            end
        end)
    end
end)

--// ANTI-ADMIN
task.spawn(function()
    while task.wait(2) do
        safe(function()
            if not optVal("AntiAdmin",false) then return end
            if #Players:GetPlayers() <= 1 then return end
            local blacklist = {
                "red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock",
                "oofficialnoobie","Uzoth","Azarth","arlthmetic","Death_King","Lunoven",
                "TheGreateAced","rip_fud","drip_mama"
            }
            for _, p in pairs(Players:GetPlayers()) do
                if table.find(blacklist, p.Name) then
                    TeleportService:Teleport(game.PlaceId, LocalPlayer); break
                end
            end
        end)
    end
end)

--=====================================================================
-- SAVE / INTERFACE MANAGER
--=====================================================================
pcall(function() SaveManager:SetLibrary(Fluent) end)
pcall(function() InterfaceManager:SetLibrary(Fluent) end)
pcall(function() SaveManager:IgnoreThemeSettings() end)
pcall(function() SaveManager:SetIgnoreIndexes({}) end)
pcall(function() InterfaceManager:SetFolder("BloxFruitsFarm") end)
pcall(function() SaveManager:SetFolder("BloxFruitsFarm/BloxFruits") end)
pcall(function() InterfaceManager:BuildInterfaceSection(Tabs.Settings) end)
pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end)

pcall(function() Window:SelectTab(1) end)

Fluent:Notify({
    Title = "Blox Fruits Farm",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

pcall(function() SaveManager:LoadAutoloadConfig() end)
