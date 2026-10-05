local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Farm",
    SubTitle = "Speed Hub X + OK Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Info     = Window:AddTab({ Title = "Info & Status", Icon = "info" }),
    Main     = Window:AddTab({ Title = "Main", Icon = "" }),
    Fish     = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Quest    = Window:AddTab({ Title = "Quest & Item", Icon = "scroll" }),
    Volcano  = Window:AddTab({ Title = "Volcano Event", Icon = "flame" }),
    Esp      = Window:AddTab({ Title = "Stats & ESP", Icon = "eye" }),
    Raid     = Window:AddTab({ Title = "Fruit & Raid", Icon = "apple" }),
    LocalP   = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    Travel   = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Shop     = Window:AddTab({ Title = "Shop", Icon = "cart" }),
    Misc     = Window:AddTab({ Title = "Miscellaneous", Icon = "settings-2" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--=============================================================
-- VARIÁVEIS GLOBAIS E SERVIÇOS
--=============================================================
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
local StarterGui          = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

repeat task.wait() until game:IsLoaded()

local _G = getgenv()

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
local World1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local World2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local World3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart")
    Hum  = c:WaitForChild("Humanoid")
end
if LocalPlayer.Character then bindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindChar)

local Data      = LocalPlayer:WaitForChild("Data")
local Level     = Data:WaitForChild("Level")
local Beli      = Data:WaitForChild("Beli")
local Frags     = Data:WaitForChild("Fragments")
local RaceData  = Data:WaitForChild("Race")

--=============================================================
-- TWEEN SYSTEM
--=============================================================
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
        local speed = tonumber(Options.TweenSpeed.Value) or 300
        currentTween = TweenService:Create(tweenBlock, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = CF})
        currentTween:Play()
    end)
end
_G.tp = tp

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

--=============================================================
-- FUNÇÕES AUXILIARES
--=============================================================
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
    for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then equipToolByName(t.Name); return end
    end
end

local function equipSelected()
    equipByTip(Options.WeaponTool.Value or "Melee")
end

local function sendKey(key, hold)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(hold or 0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end
_G.sendKey = sendKey

local function hasTool(name)
    if not LocalPlayer.Character then return false end
    return LocalPlayer.Backpack:FindFirstChild(name) ~= nil or LocalPlayer.Character:FindFirstChild(name) ~= nil
end

local function getMaterial(name)
    for _, item in pairs(CommF_:InvokeServer("getInventory")) do
        if type(item) == "table" and item.Type == "Material" and item.Name == name then
            return item.Count
        end
    end
    return 0
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

local function bringEnemy(target, centerCF)
    if not Options.BringMob.Value or not target or not centerCF then return end
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)
    local radius = tonumber(Options.BringRadius.Value) or 300
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
        if Options["Skill"..k].Value then sendKey(k) end
    end
end
_G.Attack = Attack

-- Fast Attack
task.spawn(function()
    while task.wait() do
        if Options.FastAttack.Value and LocalPlayer.Character and Root then
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

--=============================================================
-- QUEST INFO
--=============================================================
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

--=============================================================
-- CONSTRUÇÃO DA UI
--=============================================================
do

--=============================================================
-- TAB INFO & STATUS
--=============================================================
Tabs.Info:AddSection("Informações do Servidor")

local TimePara = Tabs.Info:AddParagraph({ Title = "Horário", Content = "..." })
local GameTimePara = Tabs.Info:AddParagraph({ Title = "Game Time", Content = "..." })
local PlayerPara = Tabs.Info:AddParagraph({ Title = "Jogadores", Content = "0/12" })
local RacePara = Tabs.Info:AddParagraph({ Title = "Raça", Content = "..." })
local LevelPara = Tabs.Info:AddParagraph({ Title = "Level", Content = "0" })
local BeliPara = Tabs.Info:AddParagraph({ Title = "Beli", Content = "0" })
local FragsPara = Tabs.Info:AddParagraph({ Title = "Fragments", Content = "0" })
local MoonPara = Tabs.Info:AddParagraph({ Title = "Moon", Content = "0/5" })
local MiragePara = Tabs.Info:AddParagraph({ Title = "Mirage Island", Content = "..." })
local KitsunePara = Tabs.Info:AddParagraph({ Title = "Kitsune Island", Content = "..." })
local PrehisPara = Tabs.Info:AddParagraph({ Title = "Prehistoric Island", Content = "..." })
local FrozenPara = Tabs.Info:AddParagraph({ Title = "Frozen Dimension", Content = "..." })
local ElitePara = Tabs.Info:AddParagraph({ Title = "Elite Progress", Content = "0/30" })
local BonesPara = Tabs.Info:AddParagraph({ Title = "Bones", Content = "0" })

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            TimePara:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
            local gt = math.floor(workspace.DistributedGameTime)
            GameTimePara:SetDesc(string.format("%dh %dm %ds", math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
            PlayerPara:SetDesc(#Players:GetPlayers().." jogadores")
            LevelPara:SetDesc(tostring(Level.Value))
            BeliPara:SetDesc(tostring(Beli.Value))
            FragsPara:SetDesc(tostring(Frags.Value))
            RacePara:SetDesc(tostring(RaceData.Value))
            MiragePara:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "Spawned" or "Não spawned")
            KitsunePara:SetDesc(Map:FindFirstChild("KitsuneIsland") and "Spawned" or "Não spawned")
            PrehisPara:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "Spawned" or "Não spawned")
            FrozenPara:SetDesc(WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "Spawned" or "Não spawned")
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            if moon:find("9709149431") then MoonPara:SetDesc("Full Moon (5/5)")
            elseif moon:find("9709149052") then MoonPara:SetDesc("4/5")
            elseif moon:find("9709143733") then MoonPara:SetDesc("3/5")
            elseif moon:find("9709150401") then MoonPara:SetDesc("2/5")
            elseif moon:find("9709149680") then MoonPara:SetDesc("1/5")
            end
            local b = CommF_:InvokeServer("Bones", "Check")
            if b then BonesPara:SetDesc(tostring(b)) end
            local ep = CommF_:InvokeServer("EliteHunter", "Progress")
            if ep then ElitePara:SetDesc(tostring(ep).."/30") end
        end)
    end
end)

--=============================================================
-- TAB MAIN - FARMING
--=============================================================
Tabs.Main:AddSection("Farm Principal")

local AutoFarmLevel = Tabs.Main:AddToggle("AutoFarmLevel", {
    Title = "Auto Farm Level",
    Description = "Farm quests baseado no level",
    Default = false
})
AutoFarmLevel:OnChanged(function()
    shouldTween = Options.AutoFarmLevel.Value
end)

local AutoFarmNearest = Tabs.Main:AddToggle("AutoFarmNearest", {
    Title = "Auto Farm Nearest",
    Description = "Farm mob mais próximo",
    Default = false
})
AutoFarmNearest:OnChanged(function()
    shouldTween = Options.AutoFarmNearest.Value
end)

local AutoFactory = Tabs.Main:AddToggle("AutoFactory", {
    Title = "Auto Factory Raid",
    Description = "Farm no Factory",
    Default = false
})
AutoFactory:OnChanged(function()
    shouldTween = Options.AutoFactory.Value
end)

local AutoEctoplasm = Tabs.Main:AddToggle("AutoEctoplasm", {
    Title = "Auto Farm Ectoplasm",
    Description = "Farm Ectoplasm no Cursed Ship",
    Default = false
})
AutoEctoplasm:OnChanged(function()
    shouldTween = Options.AutoEctoplasm.Value
end)

Tabs.Main:AddSection("Coleta")

local AutoCollectChest = Tabs.Main:AddToggle("AutoCollectChest", {
    Title = "Auto Collect Chest",
    Default = false
})
AutoCollectChest:OnChanged(function()
    shouldTween = Options.AutoCollectChest.Value
end)

local AutoHopNoChest = Tabs.Main:AddToggle("AutoHopNoChest", {
    Title = "Auto Hop If No Chest",
    Default = false
})

local StopRareItems = Tabs.Main:AddToggle("StopRareItems", {
    Title = "Stop on Rare Items",
    Default = true
})

local AutoCollectBerry = Tabs.Main:AddToggle("AutoCollectBerry", {
    Title = "Auto Collect Berry",
    Default = false
})
AutoCollectBerry:OnChanged(function()
    shouldTween = Options.AutoCollectBerry.Value
end)

Tabs.Main:AddSection("Mastery Farming")

local MasteryMode = Tabs.Main:AddDropdown("MasteryMode", {
    Title = "Modo Mastery",
    Values = {"Level","Bone","Cake Prince","Nearest"},
    Default = "Level"
})

local MasteryWeapon = Tabs.Main:AddDropdown("MasteryWeapon", {
    Title = "Arma Mastery",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
})

local MasterySkills = Tabs.Main:AddDropdown("MasterySkills", {
    Title = "Skills",
    Values = {"Z","X","C","V","F"},
    Default = {"Z","X","C","V"},
    Multi = true
})

local AutoMastery = Tabs.Main:AddToggle("AutoMastery", {
    Title = "Auto Farm Mastery",
    Default = false
})
AutoMastery:OnChanged(function()
    shouldTween = Options.AutoMastery.Value
end)

Tabs.Main:AddSection("Farm Material")

local materialList = World1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or World2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang","Ectoplasm"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale","Demonic Wisp"}

local MaterialSel = Tabs.Main:AddDropdown("MaterialSel", {
    Title = "Escolher Material",
    Values = materialList,
    Default = materialList[1]
})

local AutoMaterial = Tabs.Main:AddToggle("AutoMaterial", {
    Title = "Auto Farm Material",
    Default = false
})
AutoMaterial:OnChanged(function()
    shouldTween = Options.AutoMaterial.Value
end)

Tabs.Main:AddSection("Farm Boss")

local bossList = World1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
    or World2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}

local BossSel = Tabs.Main:AddDropdown("BossSel", {
    Title = "Escolher Boss",
    Values = bossList,
    Default = bossList[1]
})

local AutoBoss = Tabs.Main:AddToggle("AutoBoss", {
    Title = "Auto Attack Boss",
    Default = false
})
AutoBoss:OnChanged(function()
    shouldTween = Options.AutoBoss.Value
end)

local AutoAllBoss = Tabs.Main:AddToggle("AutoAllBoss", {
    Title = "Auto Attack All Boss",
    Default = false
})
AutoAllBoss:OnChanged(function()
    shouldTween = Options.AutoAllBoss.Value
end)

Tabs.Main:AddSection("Cake Prince & Dough King")

local AutoCakePrince = Tabs.Main:AddToggle("AutoCakePrince", {
    Title = "Auto Cake Prince",
    Default = false
})
AutoCakePrince:OnChanged(function()
    shouldTween = Options.AutoCakePrince.Value
end)

local AutoSummonCake = Tabs.Main:AddToggle("AutoSummonCake", {
    Title = "Auto Summon Cake Prince",
    Default = false
})

local AutoDoughKing = Tabs.Main:AddToggle("AutoDoughKing", {
    Title = "Auto Dough King",
    Default = false
})
AutoDoughKing:OnChanged(function()
    shouldTween = Options.AutoDoughKing.Value
end)

Tabs.Main:AddSection("Bones & Soul Reaper")

local AutoBone = Tabs.Main:AddToggle("AutoBone", {
    Title = "Auto Farm Bone",
    Default = false
})
AutoBone:OnChanged(function()
    shouldTween = Options.AutoBone.Value
end)

local AutoSoulReaper = Tabs.Main:AddToggle("AutoSoulReaper", {
    Title = "Auto Soul Reaper",
    Default = false
})
AutoSoulReaper:OnChanged(function()
    shouldTween = Options.AutoSoulReaper.Value
end)

local AutoRandomBone = Tabs.Main:AddToggle("AutoRandomBone", {
    Title = "Auto Random Bones",
    Default = false
})

local AutoTryLuck = Tabs.Main:AddToggle("AutoTryLuck", {
    Title = "Auto Try Luck",
    Default = false
})

local AutoPray = Tabs.Main:AddToggle("AutoPray", {
    Title = "Auto Pray Gravestone",
    Default = false
})

Tabs.Main:AddSection("Elite Hunter")

local AutoElite = Tabs.Main:AddToggle("AutoElite", {
    Title = "Auto Elite Hunter",
    Default = false
})
AutoElite:OnChanged(function()
    shouldTween = Options.AutoElite.Value
end)

Tabs.Main:AddSection("Outros Farms")

local AutoPiratesSea = Tabs.Main:AddToggle("AutoPiratesSea", {
    Title = "Auto Pirates Sea",
    Default = false
})
AutoPiratesSea:OnChanged(function()
    shouldTween = Options.AutoPiratesSea.Value
end)

local AutoRipIndra = Tabs.Main:AddToggle("AutoRipIndra", {
    Title = "Auto Attack Rip Indra",
    Default = false
})
AutoRipIndra:OnChanged(function()
    shouldTween = Options.AutoRipIndra.Value
end)

local AutoRainbowHaki = Tabs.Main:AddToggle("AutoRainbowHaki", {
    Title = "Auto Rainbow Haki",
    Default = false
})
AutoRainbowHaki:OnChanged(function()
    shouldTween = Options.AutoRainbowHaki.Value
end)

local AutoTyrant = Tabs.Main:AddToggle("AutoTyrant", {
    Title = "Auto Kill Tyrant of the Skies",
    Default = false
})
AutoTyrant:OnChanged(function()
    shouldTween = Options.AutoTyrant.Value
end)

local AutoCitizen = Tabs.Main:AddToggle("AutoCitizen", {
    Title = "Auto Citizen Quest",
    Default = false
})
AutoCitizen:OnChanged(function()
    shouldTween = Options.AutoCitizen.Value
end)

local AutoDragonHunter = Tabs.Main:AddToggle("AutoDragonHunter", {
    Title = "Auto Dragon Hunter Quest",
    Default = false
})
AutoDragonHunter:OnChanged(function()
    shouldTween = Options.AutoDragonHunter.Value
end)

--=============================================================
-- LOOP DE FARMING
--=============================================================
task.spawn(function()
    while task.wait(0.15) do
        pcall(function()
            if not LocalPlayer.Character or not Root then return end

            if Options.AutoFarmLevel.Value then
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
                            repeat Attack.Kill(enemy, true); task.wait()
                            until not Options.AutoFarmLevel.Value or not isAlive(enemy)
                        end
                    end
                end
            end

            if Options.AutoFarmNearest.Value then
                local nearest, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd then nd = d; nearest = e end
                    end
                end
                if nearest then Attack.Kill(nearest, true) end
            end

            if Options.AutoFactory.Value then
                local core = findEnemy({"Core"})
                if core then Attack.Kill(core, true)
                else tp(CFrame.new(502, 143, -379)) end
            end

            if Options.AutoEctoplasm.Value then
                local e = findEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
                if e then Attack.Kill(e, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(923, 126, 32852)) end
            end

            if Options.AutoCollectChest.Value then
                local chests = CollectionService:GetTagged("_ChestTagged")
                local nearest, nd = nil, math.huge
                for _, c in ipairs(chests) do
                    if not c:GetAttribute("IsDisabled") then
                        local d = (c:GetPivot().Position - Root.Position).Magnitude
                        if d < nd then nd = d; nearest = c end
                    end
                end
                if nearest then tp(nearest:GetPivot()) end
            end

            if Options.AutoCollectBerry.Value then
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

            if Options.AutoMastery.Value then
                local mode = Options.MasteryMode.Value
                equipByTip(Options.MasteryWeapon.Value)
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
                            if d < nd and d < 3500 then nd = d; enemy = e end
                        end
                    end
                end
                if enemy then
                    for skill, state in pairs(Options.MasterySkills.Value) do
                        if state then sendKey(skill) end
                    end
                    Attack.Kill(enemy, true)
                end
            end

            if Options.AutoMaterial.Value and Options.MaterialSel.Value then
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
                local mons = matData[Options.MaterialSel.Value]
                if mons then
                    local e = findEnemy(mons)
                    if e then Attack.Kill(e, true) end
                end
            end

            if Options.AutoBoss.Value and Options.BossSel.Value then
                local b = findEnemy({Options.BossSel.Value})
                if b then Attack.Kill(b, true) end
            end

            if Options.AutoAllBoss.Value then
                local b = findEnemy(bossList)
                if b then Attack.Kill(b, true) end
            end

            if Options.AutoCakePrince.Value then
                local cm = findEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then Attack.Kill(cm, true) end
                local cp = findEnemy({"Cake Prince","Dough King"})
                if cp then Attack.Kill(cp, true) end
            end

            if Options.AutoSummonCake.Value then
                pcall(function()
                    local resp = CommF_:InvokeServer("CakePrinceSpawner", true)
                    if resp and string.find(resp, "open the portal now") then
                        CommF_:InvokeServer("CakePrinceSpawner")
                    end
                end)
            end

            if Options.AutoDoughKing.Value then
                local dk = findEnemy({"Dough King"})
                if dk then Attack.Kill(dk, true) end
            end

            if Options.AutoBone.Value then
                local b = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-9516, 142, 5536)) end
            end

            if Options.AutoSoulReaper.Value then
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

            if Options.AutoRandomBone.Value then
                CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end

            if Options.AutoTryLuck.Value then
                local pos = CFrame.new(-8761, 164, 6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 1) end
            end

            if Options.AutoPray.Value then
                local pos = CFrame.new(-8761, 164, 6161)
                tp(pos)
                if getDist(pos) < 5 then CommF_:InvokeServer("gravestoneEvent", 2) end
            end

            if Options.AutoElite.Value then
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

            if Options.AutoPiratesSea.Value then
                local b = findEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then Attack.Kill(b, true)
                else tp(CFrame.new(-5556, 314, -2988)) end
            end

            if Options.AutoRipIndra.Value then
                local ri = findEnemy({"rip_indra"})
                if ri then Attack.Kill(ri, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097, 316, -3142)) end
            end

            if Options.AutoRainbowHaki.Value then
                local quest = PlayerGui.Main.Quest
                if not quest.Visible then
                    tp(CFrame.new(-11892, 930, -8760))
                    if getDist(CFrame.new(-11892, 930, -8760)) < 10 then
                        CommF_:InvokeServer("HornedMan", "Bet")
                    end
                else
                    local e = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if e then Attack.Kill(e, true) end
                end
            end

            if Options.AutoTyrant.Value then
                local t = findEnemy({"Tyrant of the Skies"})
                if t then Attack.Kill(t, true)
                else tp(CFrame.new(-16557, 202, 508)) end
            end

            if Options.AutoCitizen.Value then
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

            if Options.AutoDragonHunter.Value then
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

--=============================================================
-- TAB FISHING
--=============================================================
Tabs.Fish:AddSection("Fishing")

local FishingRod = Tabs.Fish:AddDropdown("FishingRod", {
    Title = "Escolher Vara",
    Values = {"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default = "Fishing Rod"
})

local AutoEquipRod = Tabs.Fish:AddToggle("AutoEquipRod", {
    Title = "Auto Equip Rod",
    Default = false
})

local AutoFishing = Tabs.Fish:AddToggle("AutoFishing", {
    Title = "Auto Fishing",
    Default = false
})

local AutoSellFish = Tabs.Fish:AddToggle("AutoSellFish", {
    Title = "Auto Sell Fish",
    Default = false
})

local AutoSellCorrupt = Tabs.Fish:AddToggle("AutoSellCorrupt", {
    Title = "Auto Sell Corrupted Fish",
    Default = false
})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            local tool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")

            if Options.AutoEquipRod.Value and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        LocalPlayer.Character.Humanoid:EquipTool(t); break
                    end
                end
            end

            if Options.AutoFishing.Value and tool and tool:GetAttribute("InventoryCategory") == "Rod" then
                if tool:GetAttribute("SkillChargeAlpha") and tool:GetAttribute("SkillChargeAlpha") >= 1 then
                    Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true)
                end
                local state = tool:GetAttribute("State")
                if state == "ReeledIn" then
                    ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("StartCasting")
                    task.wait(0.7)
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local ray = Ray.new(LocalPlayer.Character.Head.Position, hrp.CFrame.LookVector * 100)
                    local _, hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Characters, Enemies})
                    if hit then
                        ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("CastLineAtLocation", hit, 100, true)
                    end
                elseif state == "Biting" then
                    ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("Catching", true)
                    task.wait(0.25)
                    ReplicatedStorage.FishReplicated.FishingRequest:InvokeServer("Catch", 1)
                end
            end

            if Options.AutoSellFish.Value then
                Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellFish")
            end
            if Options.AutoSellCorrupt.Value then
                Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellCorruptedFish")
            end
        end)
    end
end)

--=============================================================
-- TAB QUEST & ITEM
--=============================================================
Tabs.Quest:AddSection("Espadas")

local SwordSel = Tabs.Quest:AddDropdown("SwordSel", {
    Title = "Escolher Espada",
    Values = {"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default = "Twin Hooks"
})

local AutoGetSword = Tabs.Quest:AddToggle("AutoGetSword", {
    Title = "Auto Get Sword",
    Default = false
})
AutoGetSword:OnChanged(function()
    shouldTween = Options.AutoGetSword.Value
end)

local AutoGetSerpent = Tabs.Quest:AddToggle("AutoGetSerpent", {
    Title = "Auto Get Serpent Bow",
    Default = false
})
AutoGetSerpent:OnChanged(function()
    shouldTween = Options.AutoGetSerpent.Value
end)

local AutoTushita = Tabs.Quest:AddToggle("AutoTushita", {
    Title = "Auto Tushita Sword",
    Default = false
})

local AutoYama = Tabs.Quest:AddToggle("AutoYama", {
    Title = "Auto Yama Sword",
    Default = false
})

Tabs.Quest:AddSection("Fighting Styles")

local AutoSuperhuman = Tabs.Quest:AddToggle("AutoSuperhuman", {Title = "Auto Superhuman", Default = false})
local AutoDeathStep = Tabs.Quest:AddToggle("AutoDeathStep", {Title = "Auto Death Step", Default = false})
local AutoSharkman = Tabs.Quest:AddToggle("AutoSharkman", {Title = "Auto Sharkman Karate", Default = false})
local AutoElectricClaw = Tabs.Quest:AddToggle("AutoElectricClaw", {Title = "Auto Electric Claw", Default = false})
local AutoDragonTalon = Tabs.Quest:AddToggle("AutoDragonTalon", {Title = "Auto Dragon Talon", Default = false})
local AutoGodHuman = Tabs.Quest:AddToggle("AutoGodHuman", {Title = "Auto Godhuman", Default = false})
local AutoSanguine = Tabs.Quest:AddToggle("AutoSanguine", {Title = "Auto Sanguine Art", Default = false})

Tabs.Quest:AddSection("Races")

local AutoV2 = Tabs.Quest:AddToggle("AutoV2", {Title = "Auto Race V2", Default = false})
local AutoV3 = Tabs.Quest:AddToggle("AutoV3", {Title = "Auto Race V3", Default = false})

Tabs.Quest:AddSection("Trial V4")

Tabs.Quest:AddButton({ Title = "Teleport Temple of Time", Callback = function()
    if Root then Root.CFrame = CFrame.new(28286, 14895, 102) end
    pcall(function()
        local stash = ReplicatedStorage:FindFirstChild("MapStash")
        if stash and stash:FindFirstChild("Temple of Time") and not Map:FindFirstChild("Temple of Time") then
            stash["Temple of Time"].Parent = Map
        end
    end)
end})

Tabs.Quest:AddButton({ Title = "Pull Lever", Callback = function()
    pcall(function()
        for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
            if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
        end
    end)
end})

local AutoTrial = Tabs.Quest:AddToggle("AutoTrial", {Title = "Auto Complete Trial", Default = false})
local AutoKillTrial = Tabs.Quest:AddToggle("AutoKillTrial", {Title = "Auto Kill Players After Trial", Default = false})

Tabs.Quest:AddSection("Compras Rápidas")

local quickBtns = {
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
for _, b in ipairs(quickBtns) do
    local args = b[2]
    Tabs.Quest:AddButton({ Title = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Options.AutoGetSword.Value and Options.SwordSel.Value then
                local map = {
                    ["Twin Hooks"] = {"Captain Elephant"},
                    ["Buddy Sword"] = {"Cake Queen"},
                    ["Canvander"] = {"Beautiful Pirate"},
                    ["Dark Dagger"] = {"rip_indra True Form"},
                    ["Spikey Trident"] = {"Dough King"},
                    ["Hallow Scythe"] = {"Soul Reaper"}
                }
                local e = findEnemy(map[Options.SwordSel.Value] or {})
                if e then Attack.Kill(e, true) end
            end
            if Options.AutoGetSerpent.Value then
                local e = findEnemy({"Island Empress"})
                if e then Attack.Kill(e, true) end
            end
            if Options.AutoTrial.Value and LocalPlayer.Character then
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
                end
            end
            if Options.AutoKillTrial.Value and PlayerGui.Main.Timer.Visible then
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

--=============================================================
-- TAB VOLCANO EVENT
--=============================================================
Tabs.Volcano:AddSection("Prehistoric Island")

local AutoSummonPrehis = Tabs.Volcano:AddToggle("AutoSummonPrehis", {Title = "Auto Summon Prehistoric Island", Default = false})
AutoSummonPrehis:OnChanged(function()
    shouldTween = Options.AutoSummonPrehis.Value
end)

local TweenPrehis = Tabs.Volcano:AddToggle("TweenPrehis", {Title = "Tween to Prehistoric Island", Default = false})
TweenPrehis:OnChanged(function()
    shouldTween = Options.TweenPrehis.Value
end)

local AutoStartPrehis = Tabs.Volcano:AddToggle("AutoStartPrehis", {Title = "Auto Start Prehistoric Event", Default = false})
local AutoPatchPrehis = Tabs.Volcano:AddToggle("AutoPatchPrehis", {Title = "Auto Patch Prehistoric", Default = false})
local CollectDinoBones = Tabs.Volcano:AddToggle("CollectDinoBones", {Title = "Auto Collect Dino Bones", Default = false})
local CollectDragonEggs = Tabs.Volcano:AddToggle("CollectDragonEggs", {Title = "Auto Collect Dragon Eggs", Default = false})

Tabs.Volcano:AddSection("Dragon Trial")

Tabs.Volcano:AddButton({ Title = "Teleport Dragon Dojo", Callback = function()
    pcall(function()
        CommF_:InvokeServer("requestEntrance", Vector3.new(5661, 1013, -334))
        tp(CFrame.new(5814, 1208, 884))
    end)
end})

local AutoDojo = Tabs.Volcano:AddToggle("AutoDojo", {Title = "Auto Dojo Trainer", Default = false})

Tabs.Volcano:AddSection("Crafting")

for _, item in ipairs({"Dragonheart","Dragonstorm","DinoHood","TRexSkull"}) do
    Tabs.Volcano:AddButton({ Title = "Craft "..item, Callback = function()
        pcall(function() CommF_:InvokeServer("CraftItem", "Craft", item) end)
    end})
end

task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not LocalPlayer.Character then return end

            if Options.AutoSummonPrehis.Value and not Map:FindFirstChild("PrehistoricIsland") then
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
                            TweenService:Create(boat.PrimaryPart, TweenInfo.new(200, Enum.EasingStyle.Linear), {CFrame = boat.PrimaryPart.CFrame * CFrame.new(0,5,-50000)}):Play()
                        end)
                    else tp(boat.VehicleSeat.CFrame) end
                end
            end

            if Options.TweenPrehis.Value then
                local p = Map:FindFirstChild("PrehistoricIsland")
                if p then tp(p:GetPivot() * CFrame.new(2, 20, 2)) end
            end

            if Options.CollectDinoBones.Value then
                for _, d in pairs(workspace:GetChildren()) do
                    if d.Name == "DinoBone" then tp(d.CFrame) end
                end
            end

            if Options.CollectDragonEggs.Value then
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

            if Options.AutoStartPrehis.Value then
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

            if Options.AutoPatchPrehis.Value then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    for _, o in pairs(isl:GetDescendants()) do
                        if (o:IsA("BasePart") or o:IsA("MeshPart")) and o.Name:lower():find("lava") then
                            o:Destroy()
                        end
                    end
                end
            end
        end)
    end
end)

--=============================================================
-- TAB STATS & ESP
--=============================================================
Tabs.Esp:AddSection("Stats Upgrade")

local StatsVal = Tabs.Esp:AddSlider("StatsVal", {
    Title = "Valor dos Pontos",
    Default = 10, Min = 1, Max = 100, Rounding = 0
})

local AutoStatMelee = Tabs.Esp:AddToggle("AutoStatMelee", {Title = "Auto Melee", Default = false})
local AutoStatDefense = Tabs.Esp:AddToggle("AutoStatDefense", {Title = "Auto Defense", Default = false})
local AutoStatSword = Tabs.Esp:AddToggle("AutoStatSword", {Title = "Auto Sword", Default = false})
local AutoStatGun = Tabs.Esp:AddToggle("AutoStatGun", {Title = "Auto Gun", Default = false})
local AutoStatFruit = Tabs.Esp:AddToggle("AutoStatFruit", {Title = "Auto Blox Fruit", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local v = tonumber(Options.StatsVal.Value) or 10
            if Options.AutoStatMelee.Value then CommF_:InvokeServer("AddPoint", "Melee", v) end
            if Options.AutoStatDefense.Value then CommF_:InvokeServer("AddPoint", "Defense", v) end
            if Options.AutoStatSword.Value then CommF_:InvokeServer("AddPoint", "Sword", v) end
            if Options.AutoStatGun.Value then CommF_:InvokeServer("AddPoint", "Gun", v) end
            if Options.AutoStatFruit.Value then CommF_:InvokeServer("AddPoint", "Demon Fruit", v) end
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

local EspPlayer = Tabs.Esp:AddToggle("EspPlayer", {Title = "ESP Player", Default = false})
local EspChest = Tabs.Esp:AddToggle("EspChest", {Title = "ESP Chest", Default = false})
local EspFruit = Tabs.Esp:AddToggle("EspFruit", {Title = "ESP Devil Fruit", Default = false})
local EspEvent = Tabs.Esp:AddToggle("EspEvent", {Title = "ESP Event Islands", Default = false})

Tabs.Esp:AddButton({ Title = "Clear All ESP", Callback = function()
    for _, d in pairs(workspace:GetDescendants()) do
        if d.Name == "FarmESP"..ESPNum then d:Destroy() end
    end
end})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Options.EspPlayer.Value then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        local d = getDist(p.Character.Head.Position)
                        createESP(p.Character.Head, Color3.fromRGB(0,255,0), string.format("%s [%d]", p.Name, math.floor(d/3)))
                    end
                end
            end
            if Options.EspChest.Value then
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
            if Options.EspFruit.Value then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name, "Fruit") and f:FindFirstChild("Handle") then
                        createESP(f.Handle, Color3.fromRGB(255,100,100), f.Name)
                    end
                end
            end
            if Options.EspEvent.Value then
                for _, i in pairs(WorldOrigin.Locations:GetChildren()) do
                    if (i.Name == "Mirage Island" or i.Name == "Prehistoric Island" or i.Name == "Kitsune Island" or i.Name == "Frozen Dimension") and i:IsA("BasePart") then
                        createESP(i, Color3.fromRGB(150,255,150), i.Name)
                    end
                end
            end
        end)
    end
end)

--=============================================================
-- TAB FRUIT & RAID
--=============================================================
Tabs.Raid:AddSection("Fruit Management")

local AutoRandomFruit = Tabs.Raid:AddToggle("AutoRandomFruit", {Title = "Auto Random Fruit", Default = false})
local AutoStoreFruit = Tabs.Raid:AddToggle("AutoStoreFruit", {Title = "Auto Store Fruit", Default = false})
local AutoDropFruit = Tabs.Raid:AddToggle("AutoDropFruit", {Title = "Auto Drop Fruit", Default = false})
local AutoFindFruit = Tabs.Raid:AddToggle("AutoFindFruit", {Title = "Auto Find Fruit", Default = false})
AutoFindFruit:OnChanged(function()
    shouldTween = Options.AutoFindFruit.Value
end)

Tabs.Raid:AddSection("Raid / Dungeon")

local RaidChip = Tabs.Raid:AddDropdown("RaidChip", {
    Title = "Escolher Chip",
    Values = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default = "Flame"
})

local AutoBuyChip = Tabs.Raid:AddToggle("AutoBuyChip", {Title = "Auto Buy Chip", Default = false})
local AutoAwake = Tabs.Raid:AddToggle("AutoAwake", {Title = "Auto Awakening", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Options.AutoRandomFruit.Value then CommF_:InvokeServer("Cousin", "Buy") end
            if Options.AutoStoreFruit.Value then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote") then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if Options.AutoDropFruit.Value then
                for _, t in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name, "Fruit") and t:FindFirstChild("EatRemote") then
                        t.EatRemote:InvokeServer("Drop")
                    end
                end
            end
            if Options.AutoFindFruit.Value and Root then
                for _, f in pairs(workspace:GetChildren()) do
                    if string.find(f.Name, "Fruit") and f:FindFirstChild("Handle") then
                        tp(f.Handle.CFrame); break
                    end
                end
            end
            if Options.AutoBuyChip.Value and Options.RaidChip.Value then
                if not hasTool("Special Microchip") then
                    if Options.RaidChip.Value == "Rumble" then
                        CommF_:InvokeServer("ThunderGodTalk")
                    else
                        CommF_:InvokeServer("RaidsNpc", "Select", Options.RaidChip.Value)
                    end
                end
            end
            if Options.AutoAwake.Value then
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end
        end)
    end
end)

--=============================================================
-- TAB LOCAL PLAYER
--=============================================================
Tabs.LocalP:AddSection("Aimbot")

local plrNames = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end

local AimPlayer = Tabs.LocalP:AddDropdown("AimPlayer", {
    Title = "Escolher Player",
    Values = plrNames,
    Default = plrNames[1] or ""
})

local AimMethod = Tabs.LocalP:AddDropdown("AimMethod", {
    Title = "Método",
    Values = {"Aim Player","Nearest Aim"},
    Default = "Aim Player"
})

local Aimbot = Tabs.LocalP:AddToggle("Aimbot", {Title = "Aimbot Skills", Default = false})
Aimbot:OnChanged(function()
    _G.AimbotEnabled = Options.Aimbot.Value
end)

local TPPlayer = Tabs.LocalP:AddToggle("TPPlayer", {Title = "Teleport To Player", Default = false})
TPPlayer:OnChanged(function()
    shouldTween = Options.TPPlayer.Value
end)

local AutoPvP = Tabs.LocalP:AddToggle("AutoPvP", {Title = "Auto Enable PvP", Default = false})

local NoClip = Tabs.LocalP:AddToggle("NoClip", {Title = "No Clip", Default = false})

task.spawn(function()
    RunService.Stepped:Connect(function()
        if Options.NoClip.Value and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

task.spawn(function()
    pcall(function()
        local meta = getrawmetatable(game)
        local old = meta.__namecall
        setreadonly(meta, false)
        meta.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if _G.AimbotEnabled and method == "FireServer" and tostring(self) == "RemoteEvent" then
                if typeof(args[2]) == "Vector3" then
                    local target
                    if Options.AimMethod.Value == "Aim Player" then
                        target = Players:FindFirstChild(Options.AimPlayer.Value)
                    elseif Options.AimMethod.Value == "Nearest Aim" then
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
            if Options.AutoPvP.Value then
                local pvp = PlayerGui.Main:FindFirstChild("PvpDisabled")
                if pvp and pvp.Visible then CommF_:InvokeServer("EnablePvp") end
            end
            if Options.TPPlayer.Value and Options.AimPlayer.Value then
                local p = Players:FindFirstChild(Options.AimPlayer.Value)
                if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    tp(p.Character.HumanoidRootPart.CFrame)
                end
            end
        end)
    end
end)

--=============================================================
-- TAB TELEPORT
--=============================================================
Tabs.Travel:AddSection("Mundos")

Tabs.Travel:AddButton({ Title = "Ir para Sea 1", Callback = function() CommF_:InvokeServer("TravelMain") end})
Tabs.Travel:AddButton({ Title = "Ir para Sea 2", Callback = function() CommF_:InvokeServer("TravelDressrosa") end})
Tabs.Travel:AddButton({ Title = "Ir para Sea 3", Callback = function() CommF_:InvokeServer("TravelZou") end})

Tabs.Travel:AddSection("Ilhas")

local islandNames = {}
for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandNames, l.Name) end

local IslandSel = Tabs.Travel:AddDropdown("IslandSel", {
    Title = "Escolher Ilha",
    Values = islandNames,
    Default = islandNames[1] or ""
})

local TweenIsland = Tabs.Travel:AddToggle("TweenIsland", {Title = "Auto Travel Ilha", Default = false})
TweenIsland:OnChanged(function()
    shouldTween = Options.TweenIsland.Value
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
    Tabs.Travel:AddButton({ Title = p[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if Options.TweenIsland.Value and Options.IslandSel.Value then
                for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
                    if l.Name == Options.IslandSel.Value then tp(l.CFrame * CFrame.new(0, 30, 0)) end
                end
            end
        end)
    end
end)

--=============================================================
-- TAB SHOPPING
--=============================================================
Tabs.Shop:AddSection("Haki / Estilos")

for _, b in ipairs(quickBtns) do
    local args = b[2]
    Tabs.Shop:AddButton({ Title = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

Tabs.Shop:AddSection("Fragments")

Tabs.Shop:AddButton({ Title = "Reroll Race (Frags)", Callback = function() CommF_:InvokeServer("BlackbeardReward", "Reroll", "2") end})
Tabs.Shop:AddButton({ Title = "Refund Stats (Frags)", Callback = function() CommF_:InvokeServer("BlackbeardReward", "Refund", "2") end})
Tabs.Shop:AddButton({ Title = "Buy Legendary Swords", Callback = function()
    CommF_:InvokeServer("LegendarySwordDealer", "1")
    CommF_:InvokeServer("LegendarySwordDealer", "2")
    CommF_:InvokeServer("LegendarySwordDealer", "3")
end})
Tabs.Shop:AddButton({ Title = "Buy True Triple Katana", Callback = function() CommF_:InvokeServer("MysteriousMan", "2") end})
Tabs.Shop:AddButton({ Title = "Buy Ghoul Race", Callback = function() CommF_:InvokeServer("Ectoplasm", "Change", 4) end})
Tabs.Shop:AddButton({ Title = "Buy Cyborg Race", Callback = function() CommF_:InvokeServer("CyborgTrainer", "Buy") end})

--=============================================================
-- TAB MISC
--=============================================================
Tabs.Misc:AddSection("Servidor")

Tabs.Misc:AddButton({ Title = "Hop Server", Callback = function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
            end
        end
    end)
end})

Tabs.Misc:AddButton({ Title = "Rejoin Server", Callback = function()
    TeleportService:Teleport(PlaceId, LocalPlayer)
end})

Tabs.Misc:AddButton({ Title = "Copiar Job ID", Callback = function()
    setclipboard(tostring(game.JobId))
end})

Tabs.Misc:AddSection("Teams")

Tabs.Misc:AddButton({ Title = "Entrar Pirates", Callback = function() CommF_:InvokeServer("SetTeam", "Pirates") end})
Tabs.Misc:AddButton({ Title = "Entrar Marines", Callback = function() CommF_:InvokeServer("SetTeam", "Marines") end})

Tabs.Misc:AddSection("Visual")

local RemoveDamage = Tabs.Misc:AddToggle("RemoveDamage", {Title = "Remover Números de Dano", Default = false})
local RemoveNotify = Tabs.Misc:AddToggle("RemoveNotify", {Title = "Remover Notificações", Default = false})
local WalkWater = Tabs.Misc:AddToggle("WalkWater", {Title = "Walk on Water", Default = false})
WalkWater:OnChanged(function(v)
    local w = Map:FindFirstChild("WaterBase-Plane")
    if w then w.Size = v and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000) end
end)

local FullBright = Tabs.Misc:AddToggle("FullBright", {Title = "Full Bright", Default = false})
FullBright:OnChanged(function(v)
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

Tabs.Misc:AddSection("Redeem / Menu")

Tabs.Misc:AddButton({ Title = "Redeem All Codes", Callback = function()
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

Tabs.Misc:AddButton({ Title = "Open Titles", Callback = function()
    CommF_:InvokeServer("getTitles", true)
    PlayerGui.Main.Titles.Visible = true
end})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Options.RemoveDamage.Value then
                local dmg = ReplicatedStorage.Assets and ReplicatedStorage.Assets.GUI and ReplicatedStorage.Assets.GUI.DamageCounter
                if dmg then dmg.Enabled = false end
            end
            if Options.RemoveNotify.Value then PlayerGui.Notifications.Enabled = false
            else PlayerGui.Notifications.Enabled = true end
        end)
    end
end)

--=============================================================
-- TAB SETTINGS
--=============================================================
Tabs.Settings:AddSection("Configuração Principal")

local WeaponTool = Tabs.Settings:AddDropdown("WeaponTool", {
    Title = "Weapon Tool",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
})

local TweenSpeed = Tabs.Settings:AddDropdown("TweenSpeed", {
    Title = "Tween Speed",
    Values = {"100","200","300","400","500","800","1000"},
    Default = "300"
})

local BringMob = Tabs.Settings:AddToggle("BringMob", {Title = "Bring Mob", Default = true})

local BringRadius = Tabs.Settings:AddDropdown("BringRadius", {
    Title = "Bring Radius",
    Values = {"100","200","300","400","500","1000"},
    Default = "300"
})

local FastAttack = Tabs.Settings:AddToggle("FastAttack", {Title = "Fast Attack", Default = false})

local SkillZ = Tabs.Settings:AddToggle("SkillZ", {Title = "Auto Skill Z", Default = true})
local SkillX = Tabs.Settings:AddToggle("SkillX", {Title = "Auto Skill X", Default = true})
local SkillC = Tabs.Settings:AddToggle("SkillC", {Title = "Auto Skill C", Default = true})
local SkillV = Tabs.Settings:AddToggle("SkillV", {Title = "Auto Skill V", Default = true})
local SkillF = Tabs.Settings:AddToggle("SkillF", {Title = "Auto Skill F", Default = false})

Tabs.Settings:AddSection("Race / Haki Auto")

local AutoRaceV3 = Tabs.Settings:AddToggle("AutoRaceV3", {Title = "Auto Turn Race V3", Default = false})
local AutoRaceV4 = Tabs.Settings:AddToggle("AutoRaceV4", {Title = "Auto Turn Race V4", Default = false})
local AutoBuso = Tabs.Settings:AddToggle("AutoBuso", {Title = "Auto Turn Buso", Default = false})
local AutoKen = Tabs.Settings:AddToggle("AutoKen", {Title = "Auto Haki Observation", Default = false})

Tabs.Settings:AddSection("Anti / Segurança")

local AntiAFK = Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti AFK", Default = true})
AntiAFK:OnChanged(function(v)
    if v then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

local AntiAdmin = Tabs.Settings:AddToggle("AntiAdmin", {Title = "Auto Anti-Admin Join Server", Default = false})
local DisableNotifyS = Tabs.Settings:AddToggle("DisableNotifyS", {Title = "Disable Notify", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            if Options.AutoBuso.Value and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                CommF_:InvokeServer("Buso")
            end
            if Options.AutoKen.Value then
                CommE:FireServer("Ken", true)
            end
            if Options.AutoRaceV3.Value then
                CommE:FireServer("ActivateAbility")
            end
            if Options.AutoRaceV4.Value and LocalPlayer.Character:FindFirstChild("RaceEnergy") then
                if LocalPlayer.Character.RaceEnergy.Value == 1 then sendKey("Y") end
            end
            if Options.DisableNotifyS.Value then
                PlayerGui.Notifications.Enabled = false
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if Options.AntiAdmin.Value then
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
            end
        end)
    end
end)

end -- FIM DO DO BLOCK

--=============================================================
-- SAVE MANAGER / INTERFACE MANAGER
--=============================================================
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
    Content = "Script carregado com sucesso.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
