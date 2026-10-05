--=====================================================================
-- BLOX FRUITS FARM - FLUENT UI (com fallback de carregamento)
-- Base: Speed Hub X + OK Hub
--=====================================================================

--// Carregador seguro do Fluent (testa vários links)
repeat task.wait() until game:IsLoaded()

local Fluent, SaveManager, InterfaceManager

local function tryLoad(url)
    local ok, res = pcall(function()
        local src = game:HttpGet(url)
        if not src or #src < 200 then error("Resposta vazia") end
        return loadstring(src)()
    end)
    return ok and res or nil
end

local urls = {
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/ActualMasterOogway/Fluent/main/main.lua",
    "https://raw.githubusercontent.com/Chocomilk999/Fluent-UI-Chocomilk/main/main.lua",
    "https://fluent.dawid.pro/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
}
for _, u in ipairs(urls) do
    Fluent = tryLoad(u)
    if Fluent then break end
end

if not Fluent then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Erro", Text = "Fluent não carregou", Duration = 8
    })
    return
end

SaveManager = tryLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/SaveManager.lua")
    or tryLoad("https://raw.githubusercontent.com/ActualMasterOogway/Fluent/main/Addons/SaveManager.lua")
InterfaceManager = tryLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/InterfaceManager.lua")
    or tryLoad("https://raw.githubusercontent.com/ActualMasterOogway/Fluent/main/Addons/InterfaceManager.lua")

-- Fallback dummy se os addons falharem
if not SaveManager then
    SaveManager = {SetLibrary=function() end, IgnoreThemeSettings=function() end,
        SetIgnoreIndexes=function() end, SetFolder=function() end,
        BuildConfigSection=function() end, LoadAutoloadConfig=function() end}
end
if not InterfaceManager then
    InterfaceManager = {SetLibrary=function() end, SetFolder=function() end, BuildInterfaceSection=function() end}
end

--// Serviços
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

--// Cria janela
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Farm",
    SubTitle = "Speed Hub X + OK Hub",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Info     = Window:AddTab({ Title = "Info & Status", Icon = "info" }),
    Main     = Window:AddTab({ Title = "Main", Icon = "home" }),
    Fish     = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Quest    = Window:AddTab({ Title = "Quest & Item", Icon = "scroll" }),
    Volcano  = Window:AddTab({ Title = "Volcano Event", Icon = "flame" }),
    Esp      = Window:AddTab({ Title = "Stats & ESP", Icon = "eye" }),
    Raid     = Window:AddTab({ Title = "Fruit & Raid", Icon = "apple" }),
    LocalP   = Window:AddTab({ Title = "Local Player", Icon = "user" }),
    Travel   = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Shop     = Window:AddTab({ Title = "Shopping", Icon = "cart" }),
    Misc     = Window:AddTab({ Title = "Miscellaneous", Icon = "settings-2" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// Tween System
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
        local speed = tonumber(Options.TweenSpeed and Options.TweenSpeed.Value or 300) or 300
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

--// Auxiliares
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
    local tip = "Melee"
    if Options.WeaponTool and Options.WeaponTool.Value then tip = Options.WeaponTool.Value end
    equipByTip(tip)
end

local function sendKey(key, hold)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(hold or 0.05)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function hasTool(name)
    if not LocalPlayer.Character then return false end
    return LocalPlayer.Backpack:FindFirstChild(name) ~= nil or LocalPlayer.Character:FindFirstChild(name) ~= nil
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
    if not (Options.BringMob and Options.BringMob.Value) or not target or not centerCF then return end
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)
    local radius = tonumber(Options.BringRadius and Options.BringRadius.Value or 300) or 300
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
        local opt = Options["Skill"..k]
        if opt and opt.Value then sendKey(k) end
    end
end
_G.Attack = Attack

--// Fast Attack
task.spawn(function()
    while task.wait() do
        if Options.FastAttack and Options.FastAttack.Value and LocalPlayer.Character and Root then
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

--// Quest info
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
-- TAB INFO
--=============================================================
Tabs.Info:AddSection("Status")
local TimeP = Tabs.Info:AddParagraph({Title = "Horário", Content = "..."})
local MoonP = Tabs.Info:AddParagraph({Title = "Moon", Content = "..."})
local RaceP = Tabs.Info:AddParagraph({Title = "Race", Content = "..."})
local LevelP = Tabs.Info:AddParagraph({Title = "Level", Content = "0"})
local MirageP = Tabs.Info:AddParagraph({Title = "Mirage Island", Content = "..."})
local KitsuneP = Tabs.Info:AddParagraph({Title = "Kitsune Island", Content = "..."})
local PrehisP = Tabs.Info:AddParagraph({Title = "Prehistoric Island", Content = "..."})

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            TimeP:SetDesc(os.date("%d/%m/%Y %H:%M:%S"))
            LevelP:SetDesc("Lv "..Level.Value.." | Beli "..Beli.Value.." | Frags "..Frags.Value)
            RaceP:SetDesc(tostring(RaceData.Value))
            MirageP:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "✅ Spawned" or "❌")
            KitsuneP:SetDesc(Map:FindFirstChild("KitsuneIsland") and "✅ Spawned" or "❌")
            PrehisP:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "✅ Spawned" or "❌")
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            local moonMap = {
                ["9709149431"] = "5/5 Full", ["9709149052"] = "4/5",
                ["9709143733"] = "3/5", ["9709150401"] = "2/5", ["9709149680"] = "1/5"
            }
            for k, v in pairs(moonMap) do
                if moon:find(k) then MoonP:SetDesc(v); break end
            end
        end)
    end
end)

--=============================================================
-- TAB MAIN
--=============================================================
Tabs.Main:AddSection("Configuração")

local WeaponTool = Tabs.Main:AddDropdown("WeaponTool", {
    Title = "Weapon Tool",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
})

Tabs.Main:AddSection("Farm Level")

Tabs.Main:AddToggle("AutoFarmLevel", {Title = "Auto Farm Level", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoFarmNearest", {Title = "Auto Farm Nearest", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddDropdown("NearestRange", {
    Title = "Search Range",
    Values = {"1000","2000","3000","Infinite"},
    Default = "Infinite"
})

Tabs.Main:AddToggle("AutoFactory", {Title = "Auto Factory Raid", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoEctoplasm", {Title = "Auto Farm Ectoplasm", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddSection("Coleta")

Tabs.Main:AddToggle("AutoCollectChest", {Title = "Auto Collect Chest", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("StopRareItems", {Title = "Stop on Rare Items", Default = true})

Tabs.Main:AddToggle("AutoCollectBerry", {Title = "Auto Collect Berry", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddSection("Mastery")

Tabs.Main:AddDropdown("MasteryMode", {
    Title = "Modo Mastery",
    Values = {"Level","Bone","Cake Prince","Nearest"},
    Default = "Level"
})

Tabs.Main:AddDropdown("MasteryWeapon", {
    Title = "Arma Mastery",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
})

Tabs.Main:AddToggle("AutoMastery", {Title = "Auto Farm Mastery", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddSection("Material")

local materialList = Sea1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or Sea2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}

Tabs.Main:AddDropdown("MaterialSel", {
    Title = "Material",
    Values = materialList,
    Default = materialList[1]
})

Tabs.Main:AddToggle("AutoMaterial", {Title = "Auto Farm Material", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddSection("Boss")

local bossList = Sea1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
    or Sea2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}

Tabs.Main:AddDropdown("BossSel", {
    Title = "Boss",
    Values = bossList,
    Default = bossList[1]
})

Tabs.Main:AddToggle("AutoBoss", {Title = "Auto Attack Boss", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoAllBoss", {Title = "Auto Attack All Boss", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddSection("Outros")

Tabs.Main:AddToggle("AutoCakePrince", {Title = "Auto Cake Prince", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoDoughKing", {Title = "Auto Dough King", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoBone", {Title = "Auto Farm Bone", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoSoulReaper", {Title = "Auto Soul Reaper", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoElite", {Title = "Auto Elite Hunter", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoPiratesSea", {Title = "Auto Pirates Sea", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoRipIndra", {Title = "Auto Attack Rip Indra", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoRainbowHaki", {Title = "Auto Rainbow Haki", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoTyrant", {Title = "Auto Kill Tyrant of the Skies", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoCitizen", {Title = "Auto Citizen Quest", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Main:AddToggle("AutoDragonHunter", {Title = "Auto Dragon Hunter", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

-- Loop principal
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
                local maxR = Options.NearestRange.Value == "Infinite" and math.huge or tonumber(Options.NearestRange.Value)
                local nearest, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d <= maxR then nd = d; nearest = e end
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
                if enemy then Attack.Kill(enemy, true) end
            end

            if Options.AutoMaterial.Value then
                local matData = {
                    ["Angel Wings"] = {"Royal Soldier","Royal Squad"},
                    ["Leather + Scrap Metal"] = {"Pirate","Brute","Marine Captain","Jungle Pirate","Forest Pirate"},
                    ["Magma Ore"] = {"Military Soldier","Military Spy","Magma Ninja","Lava Pirate"},
                    ["Fish Tail"] = {"Fishman Warrior","Fishman Commando","Fishman Captain","Fishman Raider"},
                    ["Mystic Droplet"] = {"Water Fighter"},
                    ["Radioactive Material"] = {"Factory Staff"},
                    ["Vampire Fang"] = {"Vampire"},
                    ["Gunpowder"] = {"Pistol Billionaire"},
                    ["Mini Tusk"] = {"Mythological Pirate"},
                    ["Conjured Cocoa"] = {"Chocolate Bar Battler","Cocoa Warrior"},
                    ["Dragon Scale"] = {"Dragon Crew Archer","Dragon Crew Warrior"}
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

            if Options.AutoElite.Value then
                local elite = findEnemy({"Diablo","Deandre","Urban"})
                if elite then Attack.Kill(elite, true)
                else
                    pcall(function() CommF_:InvokeServer("EliteHunter") end)
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

Tabs.Fish:AddDropdown("FishingRod", {
    Title = "Vara",
    Values = {"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default = "Fishing Rod"
})

Tabs.Fish:AddToggle("AutoEquipRod", {Title = "Auto Equip Rod", Default = false})
Tabs.Fish:AddToggle("AutoFishing", {Title = "Auto Fishing", Default = false})
Tabs.Fish:AddToggle("AutoSellFish", {Title = "Auto Sell Fish", Default = false})
Tabs.Fish:AddToggle("AutoSellCorrupt", {Title = "Auto Sell Corrupted Fish", Default = false})

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

            if Options.AutoSellFish.Value then
                pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellFish") end)
            end
            if Options.AutoSellCorrupt.Value then
                pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC", "SellCorruptedFish") end)
            end
        end)
    end
end)

--=============================================================
-- TAB QUEST & ITEM
--=============================================================
Tabs.Quest:AddSection("Espadas")

Tabs.Quest:AddDropdown("SwordSel", {
    Title = "Espada",
    Values = {"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default = "Twin Hooks"
})

Tabs.Quest:AddToggle("AutoGetSword", {Title = "Auto Get Sword", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Quest:AddToggle("AutoGetSerpent", {Title = "Auto Get Serpent Bow", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

Tabs.Quest:AddSection("Compras Rápidas")

local quickBtns = {
    {"Buy Buso", {"BuyHaki","Buso"}},
    {"Buy Geppo", {"BuyHaki","Geppo"}},
    {"Buy Soru", {"BuyHaki","Soru"}},
    {"Buy Ken", {"KenTalk","Buy"}},
    {"Buy Black Leg", {"BuyBlackLeg"}},
    {"Buy Electro", {"BuyElectro"}},
    {"Buy Fishman Karate", {"BuyFishmanKarate"}},
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
    {"Buy Soul Cane", {"BuyItem","Soul Cane"}},
    {"Buy Bisento", {"BuyItem","Bisento"}},
}
for _, b in ipairs(quickBtns) do
    local args = b[2]
    Tabs.Quest:AddButton({Title = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

--=============================================================
-- TAB ESP
--=============================================================
Tabs.Esp:AddSection("Stats")

Tabs.Esp:AddSlider("StatsVal", {
    Title = "Pontos por click",
    Default = 10, Min = 1, Max = 100, Rounding = 0
})

for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
    Tabs.Esp:AddToggle("autoStat_"..stat, {Title = "Auto "..stat, Default = false})
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, stat in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                if Options["autoStat_"..stat].Value then
                    CommF_:InvokeServer("AddPoint", stat == "Blox Fruit" and "Demon Fruit" or stat, tonumber(Options.StatsVal.Value) or 10)
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
    tl.Text = label
end

Tabs.Esp:AddToggle("EspPlayer", {Title = "ESP Player", Default = false})
Tabs.Esp:AddToggle("EspChest", {Title = "ESP Chest", Default = false})
Tabs.Esp:AddToggle("EspFruit", {Title = "ESP Devil Fruit", Default = false})
Tabs.Esp:AddToggle("EspEvent", {Title = "ESP Event Islands", Default = false})

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
        end)
    end
end)

--=============================================================
-- TAB RAID
--=============================================================
Tabs.Raid:AddSection("Fruit Management")

Tabs.Raid:AddToggle("AutoRandomFruit", {Title = "Auto Random Fruit", Default = false})
Tabs.Raid:AddToggle("AutoStoreFruit", {Title = "Auto Store Fruit", Default = false})
Tabs.Raid:AddToggle("AutoDropFruit", {Title = "Auto Drop Fruit", Default = false})
Tabs.Raid:AddToggle("AutoFindFruit", {Title = "Auto Find Fruit", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

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
        end)
    end
end)

Tabs.Raid:AddSection("Raid")

Tabs.Raid:AddDropdown("RaidChip", {
    Title = "Chip",
    Values = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default = "Flame"
})

Tabs.Raid:AddToggle("AutoBuyChip", {Title = "Auto Buy Chip", Default = false})

Tabs.Raid:AddToggle("AutoAwake", {Title = "Auto Awakening", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Options.AutoBuyChip.Value then
                if not hasTool("Special Microchip") then
                    CommF_:InvokeServer("RaidsNpc", "Select", Options.RaidChip.Value)
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

Tabs.LocalP:AddDropdown("AimPlayer", {
    Title = "Player",
    Values = plrNames,
    Default = plrNames[1] or ""
})

Tabs.LocalP:AddDropdown("AimMethod", {
    Title = "Método",
    Values = {"Aim Player","Nearest Aim"},
    Default = "Aim Player"
})

Tabs.LocalP:AddToggle("Aimbot", {Title = "Aimbot Skills", Default = false}):OnChanged(function(v)
    _G.AimbotEnabled = v
end)

Tabs.LocalP:AddToggle("NoClip", {Title = "No Clip", Default = false})

task.spawn(function()
    RunService.Stepped:Connect(function()
        if Options.NoClip.Value and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end)
end)

--=============================================================
-- TAB TELEPORT
--=============================================================
Tabs.Travel:AddSection("Mundos")
Tabs.Travel:AddButton({Title = "Sea 1", Callback = function() CommF_:InvokeServer("TravelMain") end})
Tabs.Travel:AddButton({Title = "Sea 2", Callback = function() CommF_:InvokeServer("TravelDressrosa") end})
Tabs.Travel:AddButton({Title = "Sea 3", Callback = function() CommF_:InvokeServer("TravelZou") end})

Tabs.Travel:AddSection("Ilhas")

local islandNames = {}
for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandNames, l.Name) end

Tabs.Travel:AddDropdown("IslandSel", {
    Title = "Ilha",
    Values = islandNames,
    Default = islandNames[1] or ""
})

Tabs.Travel:AddToggle("TweenIsland", {Title = "Auto Travel Ilha", Default = false}):OnChanged(function(v)
    shouldTween = v
end)

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
-- TAB SHOP
--=============================================================
Tabs.Shop:AddSection("Compras")

local shopItems = {
    {"Buy Buso","BuyHaki","Buso"},
    {"Buy Geppo","BuyHaki","Geppo"},
    {"Buy Soru","BuyHaki","Soru"},
    {"Buy Ken","KenTalk","Buy"},
    {"Reroll Race", {"BlackbeardReward","Reroll","2"}},
    {"Refund Stats", {"BlackbeardReward","Refund","2"}},
}
for _, it in ipairs(shopItems) do
    if type(it[2]) == "table" then
        local args = it[2]
        Tabs.Shop:AddButton({Title = it[1], Callback = function()
            pcall(function() CommF_:InvokeServer(unpack(args)) end)
        end})
    else
        local args = {it[2], it[3]}
        Tabs.Shop:AddButton({Title = it[1], Callback = function()
            pcall(function() CommF_:InvokeServer(unpack(args)) end)
        end})
    end
end

Tabs.Shop:AddButton({Title = "Buy Legendary Swords", Callback = function()
    CommF_:InvokeServer("LegendarySwordDealer", "1")
    CommF_:InvokeServer("LegendarySwordDealer", "2")
    CommF_:InvokeServer("LegendarySwordDealer", "3")
end})

Tabs.Shop:AddButton({Title = "Buy Ghoul Race", Callback = function()
    CommF_:InvokeServer("Ectoplasm", "Change", 4)
end})

Tabs.Shop:AddButton({Title = "Buy Cyborg Race", Callback = function()
    CommF_:InvokeServer("CyborgTrainer", "Buy")
end})

--=============================================================
-- TAB MISC
--=============================================================
Tabs.Misc:AddSection("Servidor")

Tabs.Misc:AddButton({Title = "Hop Server", Callback = function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, LocalPlayer); break
            end
        end
    end)
end})

Tabs.Misc:AddButton({Title = "Rejoin Server", Callback = function()
    TeleportService:Teleport(PlaceId, LocalPlayer)
end})

Tabs.Misc:AddButton({Title = "Copiar Job ID", Callback = function()
    setclipboard(tostring(game.JobId))
end})

Tabs.Misc:AddSection("Teams")

Tabs.Misc:AddButton({Title = "Pirates", Callback = function() CommF_:InvokeServer("SetTeam", "Pirates") end})
Tabs.Misc:AddButton({Title = "Marines", Callback = function() CommF_:InvokeServer("SetTeam", "Marines") end})

Tabs.Misc:AddSection("Visual")

Tabs.Misc:AddToggle("RemoveDamage", {Title = "Remover Números de Dano", Default = false})
Tabs.Misc:AddToggle("RemoveNotify", {Title = "Remover Notificações", Default = false})
Tabs.Misc:AddToggle("WalkWater", {Title = "Walk on Water", Default = false}):OnChanged(function(v)
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

Tabs.Misc:AddSection("Redeem")

Tabs.Misc:AddButton({Title = "Redeem All Codes", Callback = function()
    local codes = {
        "LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
        "BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
        "SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10",
        "fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
        "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK",
        "Starcodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123",
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
Tabs.Settings:AddSection("Geral")

Tabs.Settings:AddDropdown("WeaponToolS", {
    Title = "Weapon Tool",
    Values = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee"
}):OnChanged(function(v) end)

Tabs.Settings:AddDropdown("TweenSpeed", {
    Title = "Tween Speed",
    Values = {"100","200","300","400","500","800","1000"},
    Default = "300"
})

Tabs.Settings:AddToggle("BringMob", {Title = "Bring Mob", Default = true})

Tabs.Settings:AddDropdown("BringRadius", {
    Title = "Bring Radius",
    Values = {"100","200","300","400","500","1000"},
    Default = "300"
})

Tabs.Settings:AddToggle("FastAttack", {Title = "Fast Attack", Default = false})

Tabs.Settings:AddSection("Skills Auto")

Tabs.Settings:AddToggle("SkillZ", {Title = "Auto Skill Z", Default = true})
Tabs.Settings:AddToggle("SkillX", {Title = "Auto Skill X", Default = true})
Tabs.Settings:AddToggle("SkillC", {Title = "Auto Skill C", Default = true})
Tabs.Settings:AddToggle("SkillV", {Title = "Auto Skill V", Default = true})
Tabs.Settings:AddToggle("SkillF", {Title = "Auto Skill F", Default = false})

Tabs.Settings:AddSection("Race / Haki")

Tabs.Settings:AddToggle("AutoRaceV3", {Title = "Auto Race V3", Default = false})
Tabs.Settings:AddToggle("AutoRaceV4", {Title = "Auto Race V4", Default = false})
Tabs.Settings:AddToggle("AutoBuso", {Title = "Auto Buso", Default = false})
Tabs.Settings:AddToggle("AutoKen", {Title = "Auto Ken", Default = false})

Tabs.Settings:AddSection("Anti")

Tabs.Settings:AddToggle("AntiAFK", {Title = "Anti AFK", Default = true}):OnChanged(function(v)
    if v then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

Tabs.Settings:AddToggle("AntiAdmin", {Title = "Anti Admin Join", Default = false})
Tabs.Settings:AddToggle("DisableNotifyS", {Title = "Disable Notify", Default = false})

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not LocalPlayer.Character then return end
            if Options.AutoBuso.Value and not LocalPlayer.Character:FindFirstChild("HasBuso") then
                CommF_:InvokeServer("Buso")
            end
            if Options.AutoKen.Value then CommE:FireServer("Ken", true) end
            if Options.AutoRaceV3.Value then CommE:FireServer("ActivateAbility") end
            if Options.AutoRaceV4.Value and LocalPlayer.Character:FindFirstChild("RaceEnergy") then
                if LocalPlayer.Character.RaceEnergy.Value == 1 then sendKey("Y") end
            end
            if Options.DisableNotifyS.Value then PlayerGui.Notifications.Enabled = false end
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if Options.AntiAdmin.Value then
                local blacklist = {"red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock","Uzoth","Azarth"}
                for _, p in pairs(Players:GetPlayers()) do
                    if table.find(blacklist, p.Name) then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer); break
                    end
                end
            end
        end)
    end
end)

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

Window:SelectTab(1)

Fluent:Notify({
    Title = "Blox Fruits Farm",
    Content = "Script carregado com sucesso!",
    Duration = 5
})

pcall(function() SaveManager:LoadAutoloadConfig() end)
