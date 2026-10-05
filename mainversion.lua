--=====================================================================
-- BLOX FRUITS FARM | REDZ UI | ENGLISH VERSION
--=====================================================================
repeat task.wait() until game:IsLoaded()

--// SERVICE
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local replicated = ReplicatedStorage
local Remotes = replicated:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local CommE = Remotes:FindFirstChild("CommE")
local Modules = replicated:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")
local WS = workspace
local Enemies = WS:WaitForChild("Enemies")
local Characters = WS:WaitForChild("Characters")
local WorldOrigin = WS:WaitForChild("_WorldOrigin")
local Map = WS:WaitForChild("Map")

local PlaceId = game.PlaceId
local World1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local World2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local World3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart", 10)
    Hum  = c:WaitForChild("Humanoid", 10)
end
if plr.Character then bindChar(plr.Character) end
plr.CharacterAdded:Connect(bindChar)

local Data    = plr:WaitForChild("Data", 20)
local Level   = Data and Data:WaitForChild("Level")
local Beli    = Data and Data:WaitForChild("Beli")
local Frags   = Data and Data:WaitForChild("Fragments")
local RaceData= Data and Data:WaitForChild("Race")

--// STATE
local State = {
    TweenSpeed = 300,
    BringMob = true,
    BringRadius = 300,
    WeaponTool = "Melee",
}

--// TWEEN BLOCK
local tweenBlock = Instance.new("Part")
tweenBlock.Size = Vector3.new(1,1,1)
tweenBlock.Anchored = true
tweenBlock.CanCollide = false
tweenBlock.CanTouch = false
tweenBlock.Transparency = 1
tweenBlock.Name = "RedzTweenBlock"
tweenBlock.Parent = WS

local currentTween
local function _tp(cf)
    if not Root or not plr.Character then return end
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    if typeof(cf) ~= "CFrame" then return end
    pcall(function()
        if currentTween then currentTween:Cancel() end
        local sp = math.max(1, tonumber(State.TweenSpeed) or 300)
        local d = (cf.Position - tweenBlock.Position).Magnitude
        currentTween = TweenService:Create(tweenBlock,
            TweenInfo.new(d/sp, Enum.EasingStyle.Linear), {CFrame = cf})
        currentTween:Play()
    end)
end
_G.tp = _tp

task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.__shouldTween and Root then
                Root.CFrame = tweenBlock.CFrame
                if plr.Character then
                    for _, p in pairs(plr.Character:GetDescendants()) do
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

--// HELPERS
local function isAlive(m)
    if not m then return false end
    local h = m:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function getDist(pos)
    if not Root then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    return (Root.Position - pos).Magnitude
end

local function equipByTip(tip)
    if not tip or not plr.Backpack or not plr.Character then return end
    for _, t in pairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then
            pcall(function()
                plr.Character:FindFirstChildOfClass("Humanoid"):EquipTool(t)
            end)
            return
        end
    end
end

local function equipSelected()
    equipByTip(State.WeaponTool)
end

local function sendKey(k, hold)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, k, false, game)
        task.wait(hold or 0.05)
        VirtualInputManager:SendKeyEvent(false, k, false, game)
    end)
end

local function hasTool(name)
    return plr.Character and
        ((plr.Backpack and plr.Backpack:FindFirstChild(name))
        or plr.Character:FindFirstChild(name)) ~= nil
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
    if not State.BringMob or not target or not centerCF then return end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(plr, "SimulationRadius", math.huge)
            sethiddenproperty(plr, "MaxSimulationRadius", math.huge)
        end
    end)
    local r = tonumber(State.BringRadius) or 300
    local r2 = r * r
    local c = centerCF.Position
    for _, e in pairs(Enemies:GetChildren()) do
        if e.Name == target.Name and isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
            local rt = e.HumanoidRootPart
            local h = e:FindFirstChildOfClass("Humanoid")
            local d = (rt.Position - c).Magnitude
            if d*d <= r2 and h then
                rt.CanCollide = false
                h.WalkSpeed = 0
                h.JumpPower = 0
                rt.CFrame = CFrame.new(c + Vector3.new(math.random(-3,3), 3, math.random(-3,3)))
            end
        end
    end
end

local Attack = {}
Attack.Kill = function(model, on)
    if not model or not on then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChild("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    equipSelected()
    if plr.Character and not plr.Character:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
    local tool = plr.Character and plr.Character:FindFirstChildOfClass("Tool")
    local cf = (tool and tool.ToolTip == "Blox Fruit")
        and hrp.CFrame * CFrame.new(0,20,2)
        or  hrp.CFrame * CFrame.new(0,30,2)
    _tp(cf)
    bringEnemy(model, hrp.CFrame)
    for _, k in ipairs({"Z","X","C","V","F"}) do sendKey(k) end
end

--// QUESTS
local Quests, Guide = {}, {Data = {NPCList = {}}}
pcall(function() Quests = require(replicated.Quests) end)
pcall(function() Guide = require(replicated.GuideModule) end)
Guide = Guide or {Data = {NPCList = {}}}

local function getQuestInfo()
    local lvl = Level and Level.Value or 1
    local team = tostring(plr.Team)
    if lvl >= 1 and lvl <= 9 then
        if team == "Marines" then
            return {"Trainee", CFrame.new(-2709,24,2104), "Trainee", "MarineQuest", 1, 1}
        end
        return {"Bandit", CFrame.new(1059,16,1549), "Bandit", "BanditQuest1", 1, 1}
    end
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
    return {mob, cf, sp, qn, qid, cl}
end

--=====================================================================
-- LOAD REDZ
--=====================================================================
local redzlib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()

local Window = redzlib:MakeWindow({
    Title = "Blox Fruits Farm",
    SubTitle = "Redz UI | by dawid/redz",
    SaveFolder = "BloxFruitsFarm.json"
})

local Minimizer = Window:NewMinimizer({ KeyCode = Enum.KeyCode.LeftControl })
Minimizer:CreateMobileMinimizer({
    Image = "rbxassetid://127632820302449",
    BackgroundColor3 = Color3.fromRGB(0, 255, 254)
})

--=====================================================================
-- TAB CREATION
--=====================================================================
local Tabs = {
    Info       = Window:MakeTab({ Title = "Info", Icon = "Info" }),
    Main       = Window:MakeTab({ Title = "Main", Icon = "rbxassetid://7733960981" }),
    Fishing    = Window:MakeTab({ Title = "Fishing", Icon = "rbxassetid://127664059821666" }),
    QuestItem  = Window:MakeTab({ Title = "Quest & Item", Icon = "rbxassetid://13075622619" }),
    Volcano    = Window:MakeTab({ Title = "Volcano Event", Icon = "tent" }),
    StatsESP   = Window:MakeTab({ Title = "Stats & ESP", Icon = "rbxassetid://7040410130" }),
    FruitRaid  = Window:MakeTab({ Title = "Fruit & Raid", Icon = "rbxassetid://11155986081" }),
    LocalPlayer= Window:MakeTab({ Title = "Local Player", Icon = "rbxassetid://13075651575" }),
    Teleport   = Window:MakeTab({ Title = "Teleport", Icon = "locate" }),
    Shopping   = Window:MakeTab({ Title = "Shopping", Icon = "rbxassetid://6031265976" }),
    Misc       = Window:MakeTab({ Title = "Miscellaneous", Icon = "rbxassetid://10709783577" }),
    Settings   = Window:MakeTab({ Title = "Settings", Icon = "rbxassetid://7734053495" }),
}

--=====================================================================
-- TAB INFO
--=====================================================================
Tabs.Info:AddSection("Status Server")
local TimeP = Tabs.Info:AddParagraph("Local Time", "...")
local GameP = Tabs.Info:AddParagraph("Game Time", "...")
local RaceP = Tabs.Info:AddParagraph("Race", "...")
local StatP = Tabs.Info:AddParagraph("Player Stats", "...")
local MoonP = Tabs.Info:AddParagraph("Moon Phase", "...")
local MirP  = Tabs.Info:AddParagraph("Mirage Island", "...")
local KitP  = Tabs.Info:AddParagraph("Kitsune Island", "...")
local PreP  = Tabs.Info:AddParagraph("Prehistoric Island", "...")
local FroP  = Tabs.Info:AddParagraph("Frozen Dimension", "...")
local CakeP = Tabs.Info:AddParagraph("Cake Prince", "...")
local RipP  = Tabs.Info:AddParagraph("Rip Indra", "...")
local DouP  = Tabs.Info:AddParagraph("Dough King", "...")
local SwdP  = Tabs.Info:AddParagraph("Legendary Swords", "...")
local BoneP = Tabs.Info:AddParagraph("Bones", "0")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            TimeP:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
            local gt = math.floor(WS.DistributedGameTime)
            GameP:SetDesc(string.format("%dh %dm %ds",
                math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
            local race = RaceData and tostring(RaceData.Value) or "?"
            pcall(function()
                if CommF_:InvokeServer("Wenlocktoad","1") == -2 then race = race.." V3"
                elseif CommF_:InvokeServer("Alchemist","1") == -2 then race = race.." V2"
                else race = race.." V1" end
            end)
            RaceP:SetDesc(race)
            StatP:SetDesc(string.format("Lv %d | Beli %s | Frags %s",
                Level and Level.Value or 0,
                tostring(Beli and Beli.Value or 0),
                tostring(Frags and Frags.Value or 0)))
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            for k,v in pairs({
                ["9709149431"]="Full Moon (5/5)",["9709149052"]="4/5",
                ["9709143733"]="3/5",["9709150401"]="2/5",["9709149680"]="1/5"
            }) do
                if moon:find(k) then MoonP:SetDesc(v); break end
            end
            if WorldOrigin:FindFirstChild("Locations") then
                MirP:SetDesc(WorldOrigin.Locations:FindFirstChild("Mirage Island") and "✅" or "❌")
                FroP:SetDesc(WorldOrigin.Locations:FindFirstChild("Frozen Dimension") and "✅" or "❌")
            end
            KitP:SetDesc(Map:FindFirstChild("KitsuneIsland") and "✅" or "❌")
            PreP:SetDesc(Map:FindFirstChild("PrehistoricIsland") and "✅" or "❌")
            local cp = CommF_:InvokeServer("CakePrinceSpawner")
            if cp and tostring(cp):find("%d") then
                local kk = tostring(cp):match("%d+")
                CakeP:SetDesc("Killed: "..(500 - tonumber(kk or 0)))
            else
                CakeP:SetDesc(Enemies:FindFirstChild("Cake Prince") and "✅" or "❌")
            end
            RipP:SetDesc(Enemies:FindFirstChild("rip_indra") and "✅" or "❌")
            DouP:SetDesc(Enemies:FindFirstChild("Dough King") and "✅" or "❌")
            local sw = {}
            if CommF_:InvokeServer("LegendarySwordDealer","1") then table.insert(sw,"Shisui") end
            if CommF_:InvokeServer("LegendarySwordDealer","2") then table.insert(sw,"Wando") end
            if CommF_:InvokeServer("LegendarySwordDealer","3") then table.insert(sw,"Saddi") end
            SwdP:SetDesc(#sw > 0 and table.concat(sw, ", ") or "None")
            local b = CommF_:InvokeServer("Bones","Check")
            if b then BoneP:SetDesc(tostring(b)) end
        end)
    end
end)

--=====================================================================
-- TAB MAIN
--=====================================================================
Tabs.Main:AddSection("Farming")

Tabs.Main:AddDropdown({
    Name = "Weapon Tool", Description = "Weapon used for attacks",
    Options = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee",
    Callback = function(v) State.WeaponTool = v end
})

Tabs.Main:AddToggle({
    Name = "Auto Farm Level", Default = false,
    Callback = function(v) _G.__AutoFarmLevel = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddToggle({
    Name = "Auto Farm Nearest", Default = false,
    Callback = function(v) _G.__AutoFarmNearest = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddDropdown({
    Name = "Nearest Range",
    Options = {"500","1000","2000","3000","Infinite"},
    Default = "Infinite",
    Callback = function(v) _G.__NearestRange = v end
})

Tabs.Main:AddToggle({
    Name = "Auto Factory Raid", Default = false,
    Callback = function(v) _G.__AutoFactory = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddToggle({
    Name = "Auto Farm Ectoplasm", Default = false,
    Callback = function(v) _G.__AutoEctoplasm = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddSection("Chest Collection")

Tabs.Main:AddToggle({
    Name = "Auto Collect Chest", Default = false,
    Callback = function(v) _G.__AutoCollectChest = v; if v then _G.__shouldTween = true end end
})
Tabs.Main:AddToggle({
    Name = "Stop on Rare Items", Default = true,
    Callback = function(v) _G.__StopRareItems = v end
})
Tabs.Main:AddToggle({
    Name = "Auto Hop If No Chest", Default = false,
    Callback = function(v) _G.__AutoHopNoChest = v end
})
Tabs.Main:AddToggle({
    Name = "Auto Collect Berry", Default = false,
    Callback = function(v) _G.__AutoCollectBerry = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddSection("Mastery")

Tabs.Main:AddDropdown({
    Name = "Mastery Mode",
    Options = {"Level","Bone","Cake Prince","Nearest"},
    Default = "Level",
    Callback = function(v) _G.__MasteryMode = v end
})
Tabs.Main:AddDropdown({
    Name = "Mastery Weapon",
    Options = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee",
    Callback = function(v) _G.__MasteryWeapon = v end
})
Tabs.Main:AddToggle({
    Name = "Auto Farm Mastery", Default = false,
    Callback = function(v) _G.__AutoMastery = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddSection("Material")
local materialList = World1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or World2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
Tabs.Main:AddDropdown({
    Name = "Material", Options = materialList, Default = materialList[1],
    Callback = function(v) _G.__MaterialSel = v end
})
Tabs.Main:AddToggle({
    Name = "Auto Farm Material", Default = false,
    Callback = function(v) _G.__AutoMaterial = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddSection("Boss")
local bossList = World1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
    or World2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
Tabs.Main:AddDropdown({
    Name = "Boss", Options = bossList, Default = bossList[1],
    Callback = function(v) _G.__BossSel = v end
})
Tabs.Main:AddToggle({
    Name = "Auto Attack Boss", Default = false,
    Callback = function(v) _G.__AutoBoss = v; if v then _G.__shouldTween = true end end
})
Tabs.Main:AddToggle({
    Name = "Auto Attack All Boss", Default = false,
    Callback = function(v) _G.__AutoAllBoss = v; if v then _G.__shouldTween = true end end
})

Tabs.Main:AddSection("Special Farms")
Tabs.Main:AddToggle({Name="Auto Cake Prince",    Default=false, Callback=function(v) _G.__AutoCakePrince=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Dough King",     Default=false, Callback=function(v) _G.__AutoDoughKing=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Farm Bones",     Default=false, Callback=function(v) _G.__AutoBone=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Soul Reaper",    Default=false, Callback=function(v) _G.__AutoSoulReaper=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Elite Hunter",   Default=false, Callback=function(v) _G.__AutoElite=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Pirates Sea",    Default=false, Callback=function(v) _G.__AutoPiratesSea=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Attack Rip Indra",Default=false, Callback=function(v) _G.__AutoRipIndra=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Rainbow Haki",   Default=false, Callback=function(v) _G.__AutoRainbowHaki=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Citizen Quest",  Default=false, Callback=function(v) _G.__AutoCitizen=v; if v then _G.__shouldTween=true end end})
Tabs.Main:AddToggle({Name="Auto Try Luck",       Default=false, Callback=function(v) _G.__AutoTryLuck=v end})
Tabs.Main:AddToggle({Name="Auto Pray",           Default=false, Callback=function(v) _G.__AutoPray=v end})

--=====================================================================
-- TAB FISHING
--=====================================================================
Tabs.Fishing:AddSection("Fishing")
Tabs.Fishing:AddDropdown({
    Name = "Fishing Rod",
    Options = {"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default = "Fishing Rod",
    Callback = function(v) _G.__FishingRod = v end
})
Tabs.Fishing:AddDropdown({
    Name = "Bait",
    Options = {"Basic Bait","Kelp Bait","Good Bait","Abyssal Bait","Frozen Bait","Epic Bait","Carnivore Bait"},
    Default = "Basic Bait",
    Callback = function(v) _G.__FishingBait = v end
})
Tabs.Fishing:AddToggle({Name="Auto Buy Bait",              Default=false, Callback=function(v) _G.__AutoBuyBait=v end})
Tabs.Fishing:AddToggle({Name="Auto Equip Rod",             Default=false, Callback=function(v) _G.__AutoEquipRod=v end})
Tabs.Fishing:AddToggle({Name="Auto Fishing",               Default=false, Callback=function(v) _G.__AutoFishing=v end})
Tabs.Fishing:AddToggle({Name="Auto Fishing Quest",         Default=false, Callback=function(v) _G.__AutoFishingQuest=v end})
Tabs.Fishing:AddToggle({Name="Auto Complete Quest",        Default=false, Callback=function(v) _G.__AutoFishComplete=v end})
Tabs.Fishing:AddToggle({Name="Auto Sell Fish",             Default=false, Callback=function(v) _G.__AutoSellFish=v end})
Tabs.Fishing:AddToggle({Name="Auto Sell Corrupted Fish",   Default=false, Callback=function(v) _G.__AutoSellCorrupt=v end})
Tabs.Fishing:AddToggle({Name="Auto Spam Skill Z",          Default=false, Callback=function(v) _G.__SpamSkillZ=v end})

--=====================================================================
-- TAB QUEST & ITEM
--=====================================================================
Tabs.QuestItem:AddSection("Swords")
Tabs.QuestItem:AddDropdown({
    Name = "Sword",
    Options = {"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default = "Twin Hooks",
    Callback = function(v) _G.__SwordSel = v end
})
Tabs.QuestItem:AddToggle({Name="Auto Get Sword",       Default=false, Callback=function(v) _G.__AutoGetSword=v; if v then _G.__shouldTween=true end end})
Tabs.QuestItem:AddToggle({Name="Auto Get Serpent Bow", Default=false, Callback=function(v) _G.__AutoGetSerpent=v; if v then _G.__shouldTween=true end end})
Tabs.QuestItem:AddToggle({Name="Auto Tushita Sword",   Default=false, Callback=function(v) _G.__AutoTushita=v end})
Tabs.QuestItem:AddToggle({Name="Auto Yama Sword",      Default=false, Callback=function(v) _G.__AutoYama=v end})

Tabs.QuestItem:AddSection("Fighting Styles")
Tabs.QuestItem:AddToggle({Name="Auto Superhuman",     Default=false, Callback=function(v) _G.__AutoSuperhuman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Death Step",     Default=false, Callback=function(v) _G.__AutoDeathStep=v end})
Tabs.QuestItem:AddToggle({Name="Auto Sharkman",       Default=false, Callback=function(v) _G.__AutoSharkman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Electric Claw",  Default=false, Callback=function(v) _G.__AutoElectricClaw=v end})
Tabs.QuestItem:AddToggle({Name="Auto Dragon Talon",   Default=false, Callback=function(v) _G.__AutoDragonTalon=v end})
Tabs.QuestItem:AddToggle({Name="Auto Godhuman",       Default=false, Callback=function(v) _G.__AutoGodHuman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Sanguine Art",   Default=false, Callback=function(v) _G.__AutoSanguine=v end})

Tabs.QuestItem:AddSection("Race V2/V3")
Tabs.QuestItem:AddToggle({Name="Auto Race V2", Default=false, Callback=function(v) _G.__AutoV2=v end})
Tabs.QuestItem:AddToggle({Name="Auto Race V3", Default=false, Callback=function(v) _G.__AutoV3=v end})

Tabs.QuestItem:AddSection("V4 Trial")
Tabs.QuestItem:AddButton({
    Name = "Teleport Temple of Time",
    Callback = function()
        pcall(function()
            if Root then Root.CFrame = CFrame.new(28286, 14895, 102) end
            local s = replicated:FindFirstChild("MapStash")
            if s and s:FindFirstChild("Temple of Time") and not Map:FindFirstChild("Temple of Time") then
                s["Temple of Time"].Parent = Map
            end
        end)
    end
})
Tabs.QuestItem:AddButton({
    Name = "Pull Lever",
    Callback = function()
        pcall(function()
            if Map:FindFirstChild("Temple of Time") then
                for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
                    if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
                end
            end
        end)
    end
})
Tabs.QuestItem:AddToggle({Name="Auto Complete Trial",             Default=false, Callback=function(v) _G.__AutoTrial=v end})
Tabs.QuestItem:AddToggle({Name="Auto Kill Players After Trial",   Default=false, Callback=function(v) _G.__AutoKillTrial=v end})

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
    local args = b[2]
    Tabs.QuestItem:AddButton({Name = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(args)) end)
    end})
end

Tabs.QuestItem:AddSection("Special Items")
Tabs.QuestItem:AddButton({Name="Buy Legendary Swords", Callback=function()
    pcall(function()
        CommF_:InvokeServer("LegendarySwordDealer","1")
        CommF_:InvokeServer("LegendarySwordDealer","2")
        CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
end})
Tabs.QuestItem:AddButton({Name="Buy True Triple Katana", Callback=function()
    pcall(function() CommF_:InvokeServer("MysteriousMan","2") end)
end})
Tabs.QuestItem:AddButton({Name="Buy Ghoul Race", Callback=function()
    pcall(function() CommF_:InvokeServer("Ectoplasm","Change",4) end)
end})
Tabs.QuestItem:AddButton({Name="Buy Cyborg Race", Callback=function()
    pcall(function() CommF_:InvokeServer("CyborgTrainer","Buy") end)
end})

--=====================================================================
-- TAB VOLCANO EVENT
--=====================================================================
Tabs.Volcano:AddSection("Prehistoric Island")
Tabs.Volcano:AddToggle({Name="Auto Summon Prehistoric Island", Default=false, Callback=function(v) _G.__AutoSummonPrehis=v; if v then _G.__shouldTween=true end end})
Tabs.Volcano:AddToggle({Name="Tween to Prehistoric Island",    Default=false, Callback=function(v) _G.__TweenPrehis=v; if v then _G.__shouldTween=true end end})
Tabs.Volcano:AddToggle({Name="Auto Start Prehistoric Event",   Default=false, Callback=function(v) _G.__AutoStartPrehis=v end})
Tabs.Volcano:AddToggle({Name="Auto Patch Prehistoric Event",   Default=false, Callback=function(v) _G.__AutoPatchPrehis=v end})
Tabs.Volcano:AddToggle({Name="Auto Collect Dino Bones",        Default=false, Callback=function(v) _G.__CollectDinoBones=v; if v then _G.__shouldTween=true end end})
Tabs.Volcano:AddToggle({Name="Auto Collect Dragon Eggs",       Default=false, Callback=function(v) _G.__CollectDragonEggs=v end})

Tabs.Volcano:AddSection("Dragon Trial")
Tabs.Volcano:AddButton({
    Name = "Teleport Dragon Dojo",
    Callback = function()
        pcall(function()
            CommF_:InvokeServer("requestEntrance", Vector3.new(5661, 1013, -334))
            _tp(CFrame.new(5814, 1208, 884))
        end)
    end
})
Tabs.Volcano:AddToggle({Name="Auto Dojo Trainer",          Default=false, Callback=function(v) _G.__AutoDojo=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V1",              Default=false, Callback=function(v) _G.__AutoDracoV1=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V2 (FireFlowers)",Default=false, Callback=function(v) _G.__AutoDracoV2=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V3 (Sea)",        Default=false, Callback=function(v) _G.__AutoDracoV3=v end})

Tabs.Volcano:AddSection("Crafting")
for _, item in ipairs({"Dragonheart","Dragonstorm","DinoHood","TRexSkull"}) do
    Tabs.Volcano:AddButton({Name = "Craft "..item, Callback = function()
        pcall(function() CommF_:InvokeServer("CraftItem","Craft",item) end)
    end})
end

--=====================================================================
-- TAB STATS & ESP
--=====================================================================
Tabs.StatsESP:AddSection("Stats Upgrade")
Tabs.StatsESP:AddSlider({
    Name = "Points Per Stat", Min = 1, Max = 100, Default = 10, Increment = 1,
    Callback = function(v) _G.__StatsVal = v end
})
for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
    Tabs.StatsESP:AddToggle({Name = "Auto "..s, Default = false,
        Callback = function(v) _G["__autoStat_"..s] = v end})
end

Tabs.StatsESP:AddSection("ESP")
Tabs.StatsESP:AddToggle({Name="ESP Player",        Default=false, Callback=function(v) _G.__EspPlayer=v end})
Tabs.StatsESP:AddToggle({Name="ESP Chest",         Default=false, Callback=function(v) _G.__EspChest=v end})
Tabs.StatsESP:AddToggle({Name="ESP Devil Fruit",   Default=false, Callback=function(v) _G.__EspFruit=v end})
Tabs.StatsESP:AddToggle({Name="ESP Berry",         Default=false, Callback=function(v) _G.__EspBerry=v end})
Tabs.StatsESP:AddToggle({Name="ESP Event Islands", Default=false, Callback=function(v) _G.__EspEvent=v end})

--=====================================================================
-- TAB FRUIT & RAID
--=====================================================================
Tabs.FruitRaid:AddSection("Fruit Management")
Tabs.FruitRaid:AddToggle({Name="Auto Random Fruit", Default=false, Callback=function(v) _G.__AutoRandomFruit=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Store Fruit",  Default=false, Callback=function(v) _G.__AutoStoreFruit=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Drop Fruit",   Default=false, Callback=function(v) _G.__AutoDropFruit=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Find Fruit",   Default=false, Callback=function(v) _G.__AutoFindFruit=v; if v then _G.__shouldTween=true end end})

Tabs.FruitRaid:AddSection("Raids")
Tabs.FruitRaid:AddDropdown({
    Name = "Raid Chip",
    Options = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default = "Flame",
    Callback = function(v) _G.__RaidChip = v end
})
Tabs.FruitRaid:AddToggle({Name="Auto Buy Chip",     Default=false, Callback=function(v) _G.__AutoBuyChip=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Awakening",    Default=false, Callback=function(v) _G.__AutoAwake=v end})

--=====================================================================
-- TAB LOCAL PLAYER
--=====================================================================
Tabs.LocalPlayer:AddSection("Aimbot")
local plrNames = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end
if #plrNames == 0 then plrNames = {""} end

Tabs.LocalPlayer:AddDropdown({
    Name = "Target Player", Options = plrNames, Default = plrNames[1],
    Callback = function(v) _G.__AimPlayer = v end
})
Tabs.LocalPlayer:AddDropdown({
    Name = "Aim Method", Options = {"Aim Player","Nearest Aim"}, Default = "Aim Player",
    Callback = function(v) _G.__AimMethod = v end
})
Tabs.LocalPlayer:AddToggle({Name="Aimbot Skills", Default=false, Callback=function(v) _G.__AimbotEnabled = v end})
Tabs.LocalPlayer:AddToggle({Name="No Clip",       Default=false, Callback=function(v) _G.__NoClip = v end})

Tabs.LocalPlayer:AddSection("Player Hunter")
Tabs.LocalPlayer:AddButton({Name="Get Player Quest", Callback=function()
    pcall(function() CommF_:InvokeServer("PlayerHunter") end)
end})
Tabs.LocalPlayer:AddToggle({Name="Auto Get Player Quest", Default=false, Callback=function(v) _G.__AutoGetPlayerQuest=v end})
Tabs.LocalPlayer:AddToggle({Name="Auto Kill Player Quest",Default=false, Callback=function(v) _G.__AutoKillPlayerQuest=v end})
Tabs.LocalPlayer:AddToggle({Name="Auto Enable PvP",       Default=false, Callback=function(v) _G.__AutoPvP=v end})

--=====================================================================
-- TAB TELEPORT
--=====================================================================
Tabs.Teleport:AddSection("Worlds")
Tabs.Teleport:AddButton({Name="Sea 1", Callback=function() pcall(function() CommF_:InvokeServer("TravelMain") end) end})
Tabs.Teleport:AddButton({Name="Sea 2", Callback=function() pcall(function() CommF_:InvokeServer("TravelDressrosa") end) end})
Tabs.Teleport:AddButton({Name="Sea 3", Callback=function() pcall(function() CommF_:InvokeServer("TravelZou") end) end})

Tabs.Teleport:AddSection("Islands")
local islandNames = {}
if WorldOrigin:FindFirstChild("Locations") then
    for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandNames, l.Name) end
end
if #islandNames == 0 then islandNames = {""} end
Tabs.Teleport:AddDropdown({
    Name = "Island", Options = islandNames, Default = islandNames[1],
    Callback = function(v) _G.__IslandSel = v end
})
Tabs.Teleport:AddToggle({Name="Auto Travel Island", Default=false, Callback=function(v) _G.__TweenIsland=v; if v then _G.__shouldTween=true end end})

Tabs.Teleport:AddSection("Portals")
local portals = {
    {"Sky (Sea1)",{"requestEntrance",Vector3.new(-7894,5547,-380)}},
    {"Underwater (Sea1)",{"requestEntrance",Vector3.new(61163,11,1819)}},
    {"Swan Room (Sea2)",{"requestEntrance",Vector3.new(2285,15,905)}},
    {"Cursed Ship (Sea2)",{"requestEntrance",Vector3.new(923,126,32852)}},
    {"Castle On The Sea (Sea3)",{"requestEntrance",Vector3.new(-5097,316,-3142)}},
    {"Mansion (Sea3)",{"requestEntrance",Vector3.new(-12471,374,-7551)}},
    {"Hydra (Sea3)",{"requestEntrance",Vector3.new(5643,1013,-340)}}
}
for _, p in ipairs(portals) do
    local a = p[2]
    Tabs.Teleport:AddButton({Name = p[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end

--=====================================================================
-- TAB SHOPPING
--=====================================================================
Tabs.Shopping:AddSection("Shop")
for _, b in ipairs(quickBtns) do
    local a = b[2]
    Tabs.Shopping:AddButton({Name = b[1], Callback = function()
        pcall(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end

Tabs.Shopping:AddSection("Fragments")
Tabs.Shopping:AddButton({Name="Reroll Race",  Callback=function() pcall(function() CommF_:InvokeServer("BlackbeardReward","Reroll","2") end) end})
Tabs.Shopping:AddButton({Name="Refund Stats", Callback=function() pcall(function() CommF_:InvokeServer("BlackbeardReward","Refund","2") end) end})
Tabs.Shopping:AddButton({Name="Buy Legendary Swords", Callback=function()
    pcall(function()
        CommF_:InvokeServer("LegendarySwordDealer","1")
        CommF_:InvokeServer("LegendarySwordDealer","2")
        CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
end})
Tabs.Shopping:AddButton({Name="Buy True Triple Katana", Callback=function() pcall(function() CommF_:InvokeServer("MysteriousMan","2") end) end})
Tabs.Shopping:AddButton({Name="Buy Ghoul Race", Callback=function() pcall(function() CommF_:InvokeServer("Ectoplasm","Change",4) end) end})
Tabs.Shopping:AddButton({Name="Buy Cyborg Race",Callback=function() pcall(function() CommF_:InvokeServer("CyborgTrainer","Buy") end) end})

--=====================================================================
-- TAB MISC
--=====================================================================
Tabs.Misc:AddSection("Server")
Tabs.Misc:AddButton({Name="Hop Server", Callback=function()
    pcall(function()
        local d = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in pairs(d.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, plr); break
            end
        end
    end)
end})
Tabs.Misc:AddButton({Name="Rejoin Server", Callback=function() pcall(function() TeleportService:Teleport(PlaceId, plr) end) end})
Tabs.Misc:AddButton({Name="Copy Job ID",   Callback=function() pcall(function() setclipboard(tostring(game.JobId)) end) end})

Tabs.Misc:AddSection("Teams")
Tabs.Misc:AddButton({Name="Join Pirates", Callback=function() pcall(function() CommF_:InvokeServer("SetTeam","Pirates") end) end})
Tabs.Misc:AddButton({Name="Join Marines", Callback=function() pcall(function() CommF_:InvokeServer("SetTeam","Marines") end) end})

Tabs.Misc:AddSection("Visual")
Tabs.Misc:AddToggle({Name="Remove Damage Numbers", Default=false, Callback=function(v) _G.__RemoveDamage=v end})
Tabs.Misc:AddToggle({Name="Remove Notifications",  Default=false, Callback=function(v) _G.__RemoveNotify=v end})
Tabs.Misc:AddToggle({Name="Walk on Water",         Default=false, Callback=function(v)
    local w = Map:FindFirstChild("WaterBase-Plane")
    if w then w.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
end})
Tabs.Misc:AddToggle({Name="Full Bright", Default=false, Callback=function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end})
Tabs.Misc:AddToggle({Name="Low CPU Mode", Default=false, Callback=function(v)
    if v then pcall(function()
        local t = WS.Terrain
        t.WaterWaveSize=0; t.WaterWaveSpeed=0
        t.WaterReflectance=0; t.WaterTransparency=0
        Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.Brightness=0
        pcall(function() settings().Rendering.QualityLevel = "Level01" end)
    end) end
end})

Tabs.Misc:AddSection("Redeem & Menu")
Tabs.Misc:AddButton({Name="Redeem All Codes", Callback=function()
    pcall(function()
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
        local RR = Remotes:FindFirstChild("Redeem")
        if not RR then return end
        for _, c in ipairs(codes) do
            pcall(function()
                if RR.InvokeServer then RR:InvokeServer(c) else RR:FireServer(c) end
            end)
            task.wait(0.1)
        end
    end)
end})
Tabs.Misc:AddButton({Name="Open Titles Menu",   Callback=function() pcall(function() CommF_:InvokeServer("getTitles",true); PlayerGui.Main.Titles.Visible=true end) end})
Tabs.Misc:AddButton({Name="Open Haki Colors",   Callback=function() pcall(function() PlayerGui.Main.Colors.Visible=true end) end})
Tabs.Misc:AddButton({Name="Open Awakening Menu",Callback=function() pcall(function() PlayerGui.Main.AwakeningToggler.Visible=true end) end})

--=====================================================================
-- TAB SETTINGS
--=====================================================================
Tabs.Settings:AddSection("Combat")
Tabs.Settings:AddToggle({Name="Kill Aura", Default=false, Callback=function(v) _G.__KillAura=v end})
Tabs.Settings:AddDropdown({
    Name = "Weapon Tool",
    Options = {"Melee","Sword","Blox Fruit","Gun"},
    Default = "Melee",
    Callback = function(v) State.WeaponTool = v end
})
Tabs.Settings:AddDropdown({
    Name = "Tween Speed",
    Options = {"100","200","300","400","500","800","1000"},
    Default = "300",
    Callback = function(v) State.TweenSpeed = tonumber(v) or 300 end
})
Tabs.Settings:AddToggle({Name="Bring Mob", Default=true, Callback=function(v) State.BringMob = v end})
Tabs.Settings:AddDropdown({
    Name = "Bring Radius",
    Options = {"100","200","300","400","500","1000"},
    Default = "300",
    Callback = function(v) State.BringRadius = tonumber(v) or 300 end
})
Tabs.Settings:AddToggle({Name="Fast Attack", Default=false, Callback=function(v) _G.__FastAttack=v end})

Tabs.Settings:AddSection("Auto Abilities")
Tabs.Settings:AddToggle({Name="Auto Turn V3",         Default=false, Callback=function(v) _G.__AutoTurnV3=v end})
Tabs.Settings:AddToggle({Name="Auto Turn V4",         Default=false, Callback=function(v) _G.__AutoTurnV4=v end})
Tabs.Settings:AddToggle({Name="Auto Turn on Buso",    Default=false, Callback=function(v) _G.__AutoBuso=v end})
Tabs.Settings:AddToggle({Name="Auto Haki Observation",Default=false, Callback=function(v) _G.__AutoKen=v end})

Tabs.Settings:AddSection("Anti / Notifications")
Tabs.Settings:AddToggle({Name="Anti AFK", Default=true, Callback=function(v) _G.__AntiAFK=v end})
Tabs.Settings:AddToggle({Name="Auto Anti-Admin Join Server", Default=false, Callback=function(v) _G.__AntiAdmin=v end})
Tabs.Settings:AddToggle({Name="Disable Notify", Default=false, Callback=function(v) _G.__DisableNotify=v end})

--=====================================================================
-- LOOPS
--=====================================================================
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not plr.Character or not Root then return end

            if _G.__AutoFarmLevel then
                local q = getQuestInfo()
                if q and q[1] then
                    local quest = PlayerGui.Main:FindFirstChild("Quest")
                    local vis = quest and quest.Visible and quest.Container
                        and quest.Container.QuestTitle and quest.Container.QuestTitle.Title
                    local tOK = vis and string.find(quest.Container.QuestTitle.Title.Text, q[1])
                    if not tOK then
                        if q[2] then
                            _tp(q[2])
                            if getDist(q[2]) < 10 then CommF_:InvokeServer("StartQuest", q[4], q[5]) end
                        end
                    else
                        local e = findEnemy({q[1], q[3]})
                        if e then
                            repeat Attack.Kill(e,true); task.wait()
                            until not _G.__AutoFarmLevel or not isAlive(e)
                        else
                            local sp = WorldOrigin:FindFirstChild("EnemySpawns")
                            if sp then
                                for _, s in pairs(sp:GetChildren()) do
                                    if string.find(s.Name, q[3]) then
                                        _tp(s.CFrame*CFrame.new(0,20,0)); break
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if _G.__AutoFarmNearest then
                local mr = _G.__NearestRange == "Infinite" and math.huge or tonumber(_G.__NearestRange)
                local n, nd = nil, math.huge
                for _, e in pairs(Enemies:GetChildren()) do
                    if isAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                        local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d <= mr then nd=d; n=e end
                    end
                end
                if n then Attack.Kill(n, true) end
            end

            if _G.__AutoFactory then
                local c = findEnemy({"Core"})
                if c then Attack.Kill(c, true) else _tp(CFrame.new(502,143,-379)) end
            end

            if _G.__AutoEctoplasm then
                local e = findEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
                if e then Attack.Kill(e, true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(923,126,32852)) end
            end

            if _G.__AutoCollectChest then
                if (_G.__StopRareItems ~= false) and
                    (hasTool("God's Chalice") or hasTool("Fist of Darkness") or hasTool("Sweet Chalice")) then
                    _G.__AutoCollectChest = false
                else
                    local n, nd = nil, math.huge
                    for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                        if not c:GetAttribute("IsDisabled") then
                            local ok, pv = pcall(function() return c:GetPivot() end)
                            if ok and pv then
                                local d = (pv.Position - Root.Position).Magnitude
                                if d < nd then nd=d; n=c end
                            end
                        end
                    end
                    if n then _tp(n:GetPivot())
                    elseif _G.__AutoHopNoChest then
                        pcall(function()
                            local d = HttpService:JSONDecode(game:HttpGet(
                                "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                            for _, s in pairs(d.data) do
                                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                    TeleportService:TeleportToPlaceInstance(PlaceId, s.id, plr); break
                                end
                            end
                        end)
                    end
                end
            end

            if _G.__AutoCollectBerry then
                for _, b in pairs(Map:GetDescendants()) do
                    if b.Name == "Berries" then
                        for i = 1, 8 do
                            if b:GetAttribute("_BerryCFrame"..i) then _tp(b.Parent.WorldPivot) end
                        end
                    end
                end
            end

            if _G.__AutoMastery then
                local mode = _G.__MasteryMode or "Level"
                equipByTip(_G.__MasteryWeapon or "Melee")
                local e
                if mode == "Level" then
                    local q = getQuestInfo()
                    if q then e = findEnemy({q[1]}) end
                elseif mode == "Bone" then
                    e = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                elseif mode == "Cake Prince" then
                    e = findEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
                elseif mode == "Nearest" then
                    local nd = math.huge
                    for _, m in pairs(Enemies:GetChildren()) do
                        if isAlive(m) and m:FindFirstChild("HumanoidRootPart") then
                            local d = (m.HumanoidRootPart.Position - Root.Position).Magnitude
                            if d < nd and d < 3500 then nd=d; e=m end
                        end
                    end
                end
                if e then Attack.Kill(e, true) end
            end

            if _G.__AutoMaterial then
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
                local mons = md[_G.__MaterialSel or materialList[1]]
                if mons then local e = findEnemy(mons); if e then Attack.Kill(e, true) end end
            end

            if _G.__AutoBoss and _G.__BossSel then
                local b = findEnemy({_G.__BossSel}); if b then Attack.Kill(b,true) end
            end
            if _G.__AutoAllBoss then
                local b = findEnemy(bossList); if b then Attack.Kill(b,true) end
            end
            if _G.__AutoCakePrince then
                local cm = findEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then Attack.Kill(cm,true) end
                local cp = findEnemy({"Cake Prince","Dough King"})
                if cp then Attack.Kill(cp,true) end
            end
            if _G.__AutoDoughKing then
                local dk = findEnemy({"Dough King"}); if dk then Attack.Kill(dk,true) end
            end
            if _G.__AutoBone then
                local b = findEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then Attack.Kill(b,true) else _tp(CFrame.new(-9516,142,5536)) end
            end
            if _G.__AutoSoulReaper then
                local sr = findEnemy({"Soul Reaper"})
                if sr then Attack.Kill(sr,true)
                elseif not hasTool("Hallow Essence") then
                    CommF_:InvokeServer("Bones","Buy",1,1)
                else
                    _tp(CFrame.new(-8932,146,6062)); task.wait(0.5)
                    equipByTip("Melee")
                end
            end
            if _G.__AutoElite then
                local el = findEnemy({"Diablo","Deandre","Urban"})
                if el then Attack.Kill(el,true)
                else pcall(function() CommF_:InvokeServer("EliteHunter") end) end
            end
            if _G.__AutoPiratesSea then
                local b = findEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then Attack.Kill(b,true) else _tp(CFrame.new(-5556,314,-2988)) end
            end
            if _G.__AutoRipIndra then
                local ri = findEnemy({"rip_indra"})
                if ri then Attack.Kill(ri,true)
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097,316,-3142)) end
            end
            if _G.__AutoRainbowHaki then
                local q = PlayerGui.Main:FindFirstChild("Quest")
                if q and not q.Visible then
                    _tp(CFrame.new(-11892,930,-8760))
                    if getDist(CFrame.new(-11892,930,-8760)) < 10 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local e = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if e then Attack.Kill(e,true) end
                end
            end
            if _G.__AutoCitizen then
                local q = PlayerGui.Main:FindFirstChild("Quest")
                if q and not q.Visible then
                    _tp(CFrame.new(-11893.7,929.66,-8760.59))
                    if getDist(CFrame.new(-11893.7,929.66,-8760.59)) < 8 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local m = findEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if m then Attack.Kill(m,true) end
                end
            end
            if _G.__AutoTryLuck then
                local p = CFrame.new(-8761,164,6161); _tp(p)
                if getDist(p) < 5 then CommF_:InvokeServer("gravestoneEvent",1) end
            end
            if _G.__AutoPray then
                local p = CFrame.new(-8761,164,6161); _tp(p)
                if getDist(p) < 5 then CommF_:InvokeServer("gravestoneEvent",2) end
            end

            -- Fishing
            local tool = plr.Character:FindFirstChildWhichIsA("Tool")
            if _G.__AutoEquipRod and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        plr.Character.Humanoid:EquipTool(t); break
                    end
                end
            end
            if _G.__AutoBuyBait and Net then
                pcall(function()
                    local RF = Net:FindFirstChild("RF/Craft")
                    if RF then RF:InvokeServer("Craft", _G.__FishingBait or "Basic Bait", {}) end
                end)
            end
            if _G.__AutoFishing and tool and tool:GetAttribute("InventoryCategory") == "Rod" then
                if tool:GetAttribute("SkillChargeAlpha") and tool:GetAttribute("SkillChargeAlpha") >= 1 and Net then
                    pcall(function() Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true) end)
                end
                local st = tool:GetAttribute("State")
                local FR = replicated:FindFirstChild("FishReplicated")
                FR = FR and FR:FindFirstChild("FishingRequest")
                if FR then
                    if st == "ReeledIn" then
                        pcall(function()
                            FR:InvokeServer("StartCasting"); task.wait(0.7)
                            local hrp = plr.Character.HumanoidRootPart
                            local ray = Ray.new(plr.Character.Head.Position, hrp.CFrame.LookVector*100)
                            local _, hit = WS:FindPartOnRayWithIgnoreList(ray, {plr.Character, Characters, Enemies})
                            if hit then FR:InvokeServer("CastLineAtLocation", hit, 100, true) end
                        end)
                    elseif st == "Biting" then
                        pcall(function()
                            FR:InvokeServer("Catching", true); task.wait(0.25); FR:InvokeServer("Catch", 1)
                        end)
                    end
                end
            end

            -- Stats
            if Data and Data:FindFirstChild("Points") then
                for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                    if _G["__autoStat_"..s] and Data.Points.Value > 0 then
                        CommF_:InvokeServer("AddPoint",
                            s == "Blox Fruit" and "Demon Fruit" or s,
                            tonumber(_G.__StatsVal) or 10)
                    end
                end
            end

            -- Fruits
            if _G.__AutoRandomFruit then CommF_:InvokeServer("Cousin","Buy") end
            if _G.__AutoStoreFruit then
                for _, t in pairs(plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote") then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if _G.__AutoDropFruit then
                for _, t in pairs(plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name,"Fruit") and t:FindFirstChild("EatRemote") then
                        t.EatRemote:InvokeServer("Drop")
                    end
                end
            end
            if _G.__AutoFindFruit then
                for _, f in pairs(WS:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        _tp(f.Handle.CFrame); break
                    end
                end
            end

            -- Abilities
            if _G.__AutoBuso and not plr.Character:FindFirstChild("HasBuso") then
                pcall(function() CommF_:InvokeServer("Buso") end)
            end
            if _G.__AutoKen and CommE then CommE:FireServer("Ken", true) end
            if _G.__AutoTurnV3 and CommE then CommE:FireServer("ActivateAbility") end
            if _G.__AutoTurnV4 and plr.Character:FindFirstChild("RaceEnergy")
                and plr.Character.RaceEnergy.Value == 1 then
                sendKey("Y")
            end
            if _G.__DisableNotify and PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = false
            end
        end)
    end
end)

--// FAST ATTACK
task.spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.__FastAttack or not Net then return end
            if not plr.Character or not Root then return end
            local tool = plr.Character:FindFirstChildOfClass("Tool")
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
            if not _G.__KillAura or not Root then return end
            pcall(function()
                if sethiddenproperty then sethiddenproperty(plr,"SimulationRadius",math.huge) end
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

--// CHIPS / AWAKEN
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.__AutoBuyChip then
                if not hasTool("Special Microchip") then
                    if (_G.__RaidChip or "Flame") == "Rumble" then
                        CommF_:InvokeServer("ThunderGodTalk")
                    else
                        CommF_:InvokeServer("RaidsNpc","Select", _G.__RaidChip or "Flame")
                    end
                end
            end
            if _G.__AutoAwake then
                CommF_:InvokeServer("Awakener","Check")
                CommF_:InvokeServer("Awakener","Awaken")
            end
        end)
    end
end)

--// PLAYER HUNTER / PVP
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.__AutoGetPlayerQuest then CommF_:InvokeServer("PlayerHunter") end
            if _G.__AutoKillPlayerQuest then
                local q = PlayerGui.Main:FindFirstChild("Quest")
                if q and q.Visible then
                    for _, c in pairs(Characters:GetChildren()) do
                        if c.Name ~= plr.Name and isAlive(c) then
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
            if _G.__AutoPvP then
                local pvp = PlayerGui.Main:FindFirstChild("PvpDisabled")
                if pvp and pvp.Visible then CommF_:InvokeServer("EnablePvp") end
            end
        end)
    end
end)

--// TELEPORT ISLAND
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if _G.__TweenIsland and _G.__IslandSel and WorldOrigin:FindFirstChild("Locations") then
                for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
                    if l.Name == _G.__IslandSel then _tp(l.CFrame * CFrame.new(0,30,0)) end
                end
            end
        end)
    end
end)

--// VISUAL
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.__RemoveDamage then
                local dmg = replicated.Assets and replicated.Assets.GUI
                    and replicated.Assets.GUI.DamageCounter
                if dmg then dmg.Enabled = false end
            end
            if PlayerGui:FindFirstChild("Notifications") then
                PlayerGui.Notifications.Enabled = not _G.__RemoveNotify
            end
        end)
    end
end)

--// ANTI ADMIN
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            if not _G.__AntiAdmin then return end
            if #Players:GetPlayers() <= 1 then return end
            local bl = {"red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock",
                "oofficialnoobie","Uzoth","Azarth","arlthmetic","Death_King","Lunoven",
                "TheGreateAced","rip_fud","drip_mama"}
            for _, p in pairs(Players:GetPlayers()) do
                if table.find(bl, p.Name) then
                    TeleportService:Teleport(game.PlaceId, plr); break
                end
            end
        end)
    end
end)

--// ANTI AFK
task.spawn(function()
    pcall(function()
        plr.Idled:Connect(function()
            if _G.__AntiAFK ~= false then
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), WS.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), WS.CurrentCamera.CFrame)
                end)
            end
        end)
    end)
end)

--// NO CLIP
task.spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            if _G.__NoClip and plr.Character then
                for _, p in pairs(plr.Character:GetDescendants()) do
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
            if _G.__AimbotEnabled and m == "FireServer"
                and tostring(self) == "RemoteEvent"
                and typeof(a[2]) == "Vector3" then
                local tgt
                if (_G.__AimMethod or "Aim Player") == "Aim Player" then
                    tgt = Players:FindFirstChild(_G.__AimPlayer or "")
                elseif (_G.__AimMethod or "Aim Player") == "Nearest Aim" then
                    local nd, best = math.huge, nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= plr and p.Character
                            and p.Character:FindFirstChild("HumanoidRootPart")
                            and p.Team ~= plr.Team then
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

--// NOTIFY
Window:Notify({
    Title = "Blox Fruits Farm",
    Content = "Script loaded successfully!",
    Duration = 5
})
