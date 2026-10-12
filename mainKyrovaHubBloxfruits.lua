--═══════════════════════════════════════════════════════════════════
--  KYROVA HUB • Blox Fruits
--  UI: Vind UI Reborn  |  Engine: Speed Hub X (fiel ao original)
--  Icon/Fundo: 71647128089295  |  Toggle: RightShift
--═══════════════════════════════════════════════════════════════════

if _G.__KyrovaLoaded then return end
_G.__KyrovaLoaded = true

repeat task.wait() until game:IsLoaded()

-- // Services
local Players           = game:GetService("Players")
local RS                = game:GetService("ReplicatedStorage")
local TS                = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TeleportService   = game:GetService("TeleportService")
local VIM               = game:GetService("VirtualInputManager")
local VU                = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local playerGui   = LocalPlayer:WaitForChild("PlayerGui")

local Remotes        = RS:WaitForChild("Remotes")
local CommF_         = Remotes:WaitForChild("CommF_")
local Net            = RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit    = Net:WaitForChild("RE/RegisterHit")

repeat task.wait() until LocalPlayer:FindFirstChild("Data")

local World1 = game.PlaceId == 2753915549 or game.PlaceId == 85211729168715
local World2 = game.PlaceId == 4442272183 or game.PlaceId == 79091703265657
local World3 = game.PlaceId == 7449423635 or game.PlaceId == 100117331123089
local Enemies = workspace:WaitForChild("Enemies", 30)
local Unloaded = false

--════════════════════════ SETTINGS ════════════════════════
local Settings = {
    ["Weapon Tool"] = "Melee", ["Tween Speed"] = 350,
    ["Bring Mob"] = false, ["Bring Radius"] = 300,
    ["Fast Attack"] = false, ["Fast Attack Delay"] = 0,
    ["Kill Aura"] = false, ["Disable Notify"] = false,
    ["Stop On Rare Items"] = false, ["Anti AFK"] = false, ["Anti Admin"] = false,
    ["Auto Turn On Buso"] = false, ["Auto Ken"] = false,
    ["Auto Turn V3"] = false, ["Auto Turn V4"] = false,
    ["Choose Chip"] = "Flame", ["Choose Material"] = "", ["Choose Boss"] = "",
    ["Choose Fruit"] = "", ["Stat Select"] = "Melee", ["Stat Points"] = 10,
    ["Stack Farming Enabled"] = false,
    ["WalkSpeed"] = 16, ["JumpPower"] = 50,
}

local BossList = World1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"}
    or World2 and {"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}

local MaterialList = World1 and {"Leather + Scrap Metal","Angel Wings","Magma Ore","Fish Tail"}
    or World2 and {"Leather + Scrap Metal","Radioactive Material","Ectoplasm","Mystic Droplet","Magma Ore","Vampire Fang"}
    or {"Scrap Metal","Demonic Wisp","Conjured Cocoa","Dragon Scale","Gunpowder","Fish Tail","Mini Tusk"}

local MaterialNPCs = {
    ["Leather + Scrap Metal"] = {"Pirate","Brute"},
    ["Angel Wings"] = {"God's Guard"},
    ["Magma Ore"] = {"Military Soldier","Military Detective"},
    ["Fish Tail"] = {"Fishman Warrior","Fishman Commando"},
    ["Radioactive Material"] = {"Factory Staff"},
    ["Ectoplasm"] = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"},
    ["Mystic Droplet"] = {"Water Fighter"},
    ["Vampire Fang"] = {"Vampire"},
    ["Scrap Metal"] = {"Pirate","Brute"},
    ["Demonic Wisp"] = {"Demonic Soul"},
    ["Conjured Cocoa"] = {"Cocoa Warrior","Chocolate Bar Battler"},
    ["Dragon Scale"] = {"Dragon Crew Warrior","Dragon Crew Archer"},
    ["Gunpowder"] = {"Jungle Pirate","Arctic Warrior"},
    ["Mini Tusk"] = {"Mythological Pirate"},
}

local FruitList = {"Rocket Fruit","Spin Fruit","Chop Fruit","Spring Fruit","Bomb Fruit","Smoke Fruit","Spike Fruit","Flame Fruit","Falcon Fruit","Ice Fruit","Sand Fruit","Dark Fruit","Ghost Fruit","Diamond Fruit","Light Fruit","Rubber Fruit","Barrier Fruit","Magma Fruit","Quake Fruit","Buddha Fruit","Love Fruit","Spider Fruit","Sound Fruit","Phoenix Fruit","Portal Fruit","Rumble Fruit","Pain Fruit","Blizzard Fruit","Gravity Fruit","Mammoth Fruit","T-Rex Fruit","Dough Fruit","Shadow Fruit","Venom Fruit","Control Fruit","Spirit Fruit","Dragon Fruit","Leopard Fruit","Yeti Fruit","Kitsune Fruit","Gas Fruit"}
local ChipList = {"Flame","Ice","Quake","Light","Dark","Spider","Rumble","Magma","Buddha","Sand","Phoenix","Dough"}

-- ponte Settings → _G (lógicas do OK Hub coladas na extensão leem essas _G)
local G_NAMES = {
    ["Auto Saber"]="AutoSaber",["Auto Pole"]="AutoPole",["Auto Pole V2"]="AutoPoleV2",
    ["Auto Saw"]="AutoSaw",["Auto Trident"]="AutoTridentW2",["Auto Yama"]="Auto_Yama",
    ["Auto Tushita"]="Auto_Tushita",["Auto CDK"]="CDK",["Auto Soul Guitar"]="Auto_Soul_Guitar",
    ["Auto Serpent Bow"]="AutoSerpentBow",["Auto Superhuman"]="Auto_SuperHuman",
    ["Auto Death Step"]="AutoDeathStep",["Auto Sharkman"]="Auto_SharkMan_Karate",
    ["Auto Electric Claw"]="Auto_Electric_Claw",["Auto Dragon Talon"]="AutoDragonTalon",
    ["Auto God Human"]="Auto_God_Human",["Auto Rainbow Haki"]="Auto_Rainbow_Haki",
    ["Auto Bartilo"]="Bartilo_Quest",["Auto Citizen"]="CitizenQuest",
    ["Auto Elite Hunter"]="FarmEliteHunt",["Auto Cavender"]="Auto_Cavender",
    ["Auto Dough King"]="AutoDoughKing",["Auto Cake Prince"]="Auto_Cake_Prince",
    ["Auto Soul Reaper"]="AutoMatSoul",["Auto Factory"]="AutoFactory",
    ["Auto Ectoplasm"]="AutoEctoplasm",["Auto Collect Chest"]="AutoFarmChest",
    ["Auto Farm Level"]="Level",["Auto Farm Nearest"]="AutoFarmNear",
    ["Auto Farm Bones"]="AutoFarm_Bone",["Auto Raid"]="AutoFarmRaid",
    ["Auto Sea Beast"]="SeaBeast1",["Auto Shark"]="Shark",["Auto Terrorshark"]="TerrorShark",
    ["Auto Piranha"]="Piranha",["Auto Fish Crew"]="MobCrew",
}

local function Notify(title, text, ntype)
    if Settings["Disable Notify"] then return end
    pcall(function() VindUI:Notify({Title=title, Text=text, Type=ntype or "info", Duration=3}) end)
end

--════════════════════════ ENGINE (Speed Hub X) ════════════════════════

local function IsEntityAlive(m) local h = m and m:FindFirstChildOfClass("Humanoid") return h and h.Health > 0 end
local function GetDistance(target)
    local char = LocalPlayer.Character
    if not char or not char.PrimaryPart then return math.huge end
    local pos = typeof(target)=="CFrame" and target.Position or target
    return (char.PrimaryPart.Position - pos).Magnitude
end
local function FireRemote(...) return CommF_:InvokeServer(select(2, ...)) end

local function FindEnemy(names)
    local list = type(names)=="table" and names or {names}
    for _, v in ipairs(Enemies:GetChildren()) do
        if table.find(list, v.Name) and v:FindFirstChild("HumanoidRootPart") and IsEntityAlive(v) then return v end
    end
end

-- // Tween Controller — verbatim Speed Hub X
local ActiveController = nil
local function DestroyTween()
    if ActiveController then pcall(function() ActiveController:Destroy() end) ActiveController = nil end
end

local function CreateTweenController(hrp)
    if not hrp or not hrp.Parent then return nil end
    local ctrl = {}
    local originalVel = hrp.AssemblyLinearVelocity
    local savedCollide, savedAnchor = {}, {}
    local tween, bv, conn, flag = nil, nil, nil, false

    local function cleanup()
        if conn then conn:Disconnect() conn = nil end
        if tween then tween:Cancel() tween = nil end
        if bv then bv:Destroy() bv = nil end
        for _, d in ipairs(hrp.Parent:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanCollide = savedCollide[d] ~= nil and savedCollide[d] or true
                savedCollide[d] = nil
                if savedAnchor[d] ~= nil then d.Anchored = savedAnchor[d] savedAnchor[d] = nil end
            end
        end
        pcall(function()
            hrp.AssemblyLinearVelocity = originalVel
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        flag = false
    end

    function ctrl.ExecuteTween(target, speed)
        if flag then cleanup() end
        originalVel = hrp.AssemblyLinearVelocity
        for _, d in ipairs(hrp.Parent:GetDescendants()) do
            if d:IsA("BasePart") then
                savedCollide[d] = d.CanCollide
                savedAnchor[d] = d.Anchored
                d.CanCollide = false
            end
        end
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000,4000,4000)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local t = math.max(0.05, (hrp.CFrame.Position - target.Position).Magnitude / math.max(speed or 100, 0.01))
        flag = true
        tween = TS:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = target})
        conn = tween.Completed:Connect(cleanup)
        tween:Play()
    end
    function ctrl.Destroy() cleanup() end
    return ctrl
end

-- // FindNearestTeleporter — verbatim Speed Hub X
local function FindNearestTeleporter(targetCF)
    local pos, spots = targetCF.Position, {}
    if game.PlaceId == 7449423635 then
        spots = {["Castle On The Sea"]=Vector3.new(-5058.775,314.5155,-3155.8833),Hydra=Vector3.new(5756.8374,610.424,-253.9254),Mansion=Vector3.new(-12463.874,374.9145,-7523.774),["Great Tree"]=Vector3.new(28282.57,14896.851,105.1043),["Temple Clock"]=Vector3.new(28282.57,14896.851,105.10427)}
    elseif game.PlaceId == 4442272183 then
        spots = {Mansion=Vector3.new(-288.4625,306.1306,597.9988),Flamingo=Vector3.new(2284.912,15.152,905.4829),["122"]=Vector3.new(923.2125,126.976,32852.832),["3032"]=Vector3.new(-6508.558,89.035,-132.8395)}
    elseif game.PlaceId == 2753915549 then
        spots = {["1"]=Vector3.new(-7894.62,5545.4917,-380.2467),["2"]=Vector3.new(-4607.8228,872.5423,-1667.5569),["3"]=Vector3.new(61163.85,11.7595,1819.7842),["4"]=Vector3.new(3876.2805,35.1061,-1939.3202)}
    end
    if not next(spots) then return nil end
    local huge, best = math.huge, nil
    for _, v in pairs(spots) do
        local mag = (v - pos).Magnitude
        if mag < huge then huge, best = mag, v end
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if huge <= (pos - hrp.Position).Magnitude then return best end
    return nil
end

-- // ExecuteTween — verbatim Speed Hub X (Submerged Island + teleporters)
local Teleporting = false
local function ExecuteTween(targetCF)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (char and hrp) then return end
    if typeof(targetCF) == "Vector3" then targetCF = CFrame.new(targetCF) end

    DestroyTween()
    ActiveController = CreateTweenController(hrp)
    local speed = tonumber(Settings["Tween Speed"]) or 100
    if speed <= 0 then speed = 100 end

    local position = targetCF.Position
    if (Vector3.new(10213.701,-1733.5026,9940.189) - position).Magnitude <= 3500
        and LocalPlayer:DistanceFromCharacter(Vector3.new(10213.701,-1733.5026,9940.189)) > 3500 then
        if LocalPlayer:DistanceFromCharacter(Vector3.new(-16267,25,1371)) > 5 then
            if ActiveController then ActiveController:ExecuteTween(CFrame.new(-16267,25,1371), speed) end
        else
            Net:FindFirstChild("RF/SubmarineWorkerSpeak"):InvokeServer("TravelToSubmergedIsland")
        end
        return
    end
    if LocalPlayer:GetAttribute("CurrentLocation") == "Submerged Island"
        and (Vector3.new(10213.701,-1733.5026,9940.189) - position).Magnitude > 3500 then
        if LocalPlayer:DistanceFromCharacter(Vector3.new(11426,-2155,9730)) > 5 then
            if ActiveController then ActiveController:ExecuteTween(CFrame.new(11426,-2155,9730), speed) end
        else
            Net:FindFirstChild("RF/SubmarineTransportation"):InvokeServer("InitiateTeleport","Tiki Outpost")
        end
        return
    end

    if not _G.Teleporting then
        local tp = FindNearestTeleporter(targetCF)
        if tp then
            _G.Teleporting = true
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            CommF_:InvokeServer("requestEntrance", tp)
            task.delay(1, function() _G.Teleporting = false end)
            return
        end
    end
    if ActiveController then ActiveController:ExecuteTween(targetCF, speed) end
end

-- // Feature flags → noclip (lista do Speed Hub X + extras)
local FeatureFlags = {
    "Auto Farm Level","Auto Farm Nearest","Auto Farm Mastery","Auto Collect Chest",
    "Auto Collect Berry","Auto Factory","Auto Attack Boss","Auto Attack All Boss",
    "Auto Pirates Sea","Auto Farm Material","Auto Get Sword","Auto Get Serpent Bow",
    "Auto Farm Bones","Auto Cake Prince","Auto Dough King","Auto Elite Hunter",
    "Auto Soul Reaper","Auto Citizen Quest","Auto Summon Kitsune Island",
    "Tween to Kitsune Island","Auto Collect Azure Ember","Auto Farm Sea",
    "Tween to Frozen Dimension","Auto Find Leviathan","Auto Attack Leviathan",
    "Auto Attack Leviathan Segment","Auto Attack Leviathan Tail","Auto Wood Planks",
    "Tween To Island","Auto Find Fruit","Auto Gets Fruit Spawner",
    "Auto Summon Mirage Island","Tween To Mirage Island","Auto Raid",
    "Auto Collect Gift","Auto Summon Prehistoric Island","Tween To Prehistoric Island",
    "Auto Dragon Hunter Quests","Auto Kill Player After Trial","Auto Trial","Auto V2","Auto V3",
    "Auto Factory Raid","Auto Farm Ectoplasma","Auto Shark","Auto Terrorshark",
    "Auto Piranha","Auto Fish Crew","Auto Sea Beast",
}
local function IsAnyFeatureActive()
    for _, f in ipairs(FeatureFlags) do
        if Settings[f] then return true end
    end
    return false
end

-- // Noclip — sistema Stepped verbatim Speed Hub X
local Noclip = {parts = {}, charConn = nil, currentChar = nil, lastUpdate = 0}
local function DisableParts(char)
    if not char or not char.Parent then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d.CanCollide and not Noclip.parts[d] then
            Noclip.parts[d] = true
            d.CanCollide = false
        end
    end
    if Noclip.charConn then Noclip.charConn:Disconnect() Noclip.charConn = nil end
    Noclip.charConn = char.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") and d.CanCollide and not Noclip.parts[d] then
            Noclip.parts[d] = true
            task.defer(function() d.CanCollide = false end)
        end
    end)
end
local function RestoreParts(char)
    if not char then return end
    for part in pairs(Noclip.parts) do
        if part and part.Parent and part:IsA("BasePart") then part.CanCollide = true end
        Noclip.parts[part] = nil
    end
    if Noclip.charConn then Noclip.charConn:Disconnect() Noclip.charConn = nil end
end
RunService.Stepped:Connect(function()
    if tick() - Noclip.lastUpdate < 0.2 then return end
    Noclip.lastUpdate = tick()
    if Unloaded then RestoreParts(Noclip.currentChar) return end
    local char = LocalPlayer.Character
    if IsAnyFeatureActive() and char and char ~= Noclip.currentChar then
        if Noclip.currentChar then RestoreParts(Noclip.currentChar) end
        Noclip.currentChar = char
        DisableParts(char)
    elseif not IsAnyFeatureActive() and Noclip.currentChar then
        RestoreParts(Noclip.currentChar)
        Noclip.currentChar = nil
    end
end)

-- // Equip / Haki — verbatim Speed Hub X
local function EquipToolByName(name)
    local backpack, char = LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character
    if not (backpack and char) then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local tool = backpack:FindFirstChild(name)
    if hum and tool and tool:IsA("Tool") then hum:EquipTool(tool) end
end
local function EquipSelectedTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local want = Settings["Weapon Tool"]
    for _, v in ipairs(backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == want then
            EquipToolByName(v.Name) return
        end
    end
end
local function ActivateHaki()
    local char = LocalPlayer.Character
    if char and not char:FindFirstChild("HasBuso") then FireRemote("Buso") end
end
local function HasTool(name)
    local char = LocalPlayer.Character
    if not char then return false end
    return char:FindFirstChild(name) ~= nil or LocalPlayer.Backpack:FindFirstChild(name) ~= nil
end

-- // Attack System — verbatim Speed Hub X
local HitKey = tostring(LocalPlayer.UserId):sub(2,4) .. "078da"

local function GetGlobalHitThread()
    local ok, result = pcall(function()
        local global = RS:FindFirstChild("Global")
        if global then
            for _, v in pairs(getupvalues(require(global).SendHitsToServer)) do
                if type(v) == "thread" and coroutine.status(v) ~= "dead" then return v end
            end
        end
    end)
    return ok and result or nil
end

local hitThread = coroutine.create(function()
    pcall(function()
        RegisterHit:FireServer(HitKey)
        while true do
            local target, list = coroutine.yield()
            RegisterHit:FireServer(target, list, nil, HitKey)
        end
    end)
end)
coroutine.resume(hitThread)

local function GetHits(radius)
    local hits = {}
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return hits end
    for _, fname in ipairs({"Enemies","Characters"}) do
        local folder = workspace:FindFirstChild(fname)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                local hum = child:FindFirstChildOfClass("Humanoid")
                local ehrp = child:FindFirstChild("HumanoidRootPart")
                if child ~= char and hum and ehrp and hum.Health > 0
                    and (ehrp.Position - hrp.Position).Magnitude <= radius then
                    table.insert(hits, {child, child:FindFirstChild("Head") or ehrp})
                end
            end
        end
    end
    return hits
end

local function ExecuteAttack()
    local char = LocalPlayer.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not (tool and table.find({"Melee","Sword","Blox Fruit","Gun"}, tool.ToolTip)) then return end
    local hits = GetHits(60)
    if #hits > 0 then
        RegisterAttack:FireServer(0)
        local first = table.remove(hits, 1)[2]
        local thread = GetGlobalHitThread() or hitThread
        if thread then coroutine.resume(thread, first, hits)
        else RegisterHit:FireServer(first, hits, nil, HitKey) end
    end
end

local m1State = {last = 0, delay = 0}
local function ExecuteFruitM1(tool)
    pcall(function()
        local now = tick()
        if now - m1State.last <= 0.4 then m1State.delay = math.min(m1State.delay + 1, 4)
        else m1State.delay = 1 end
        m1State.last = now
        local char = LocalPlayer.Character
        local pp = char and char.PrimaryPart
        if not pp then return end
        local pos = pp.Position
        for _, v in ipairs(Enemies:GetChildren()) do
            local epp = v.PrimaryPart
            if epp and IsEntityAlive(v) then
                local dx, dy, dz = epp.Position.X-pos.X, epp.Position.Y-pos.Y, epp.Position.Z-pos.Z
                if dx*dx + dy*dy + dz*dz <= 2500 then
                    tool.LeftClickRemote:FireServer((epp.Position - pos).Unit, m1State.delay)
                end
            end
        end
    end)
end

local function ExecuteBladeHits()
    xpcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildWhichIsA("Tool")
        if not tool then return end
        if tool.ToolTip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
            ExecuteFruitM1(tool)
        elseif tool.ToolTip ~= "Gun" then
            ExecuteAttack()
        end
    end, function(err) warn("[Kyrova Attack] " .. tostring(err)) end)
end

-- // BringEnemyToPosition — Speed Hub X (final completado)
local function BringEnemies(mob, cframe)
    if not Settings["Bring Mob"] then return end
    if not mob or not mob.Parent or not cframe then return end
    local radius = tonumber(Settings["Bring Radius"]) or 300
    local pos = cframe.Position
    pcall(function()
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
    end)
    for _, v in ipairs(Enemies:GetChildren()) do
        if v.Name == mob.Name and not table.find({"Shark","Piranha","Terrorshark"}, v.Name) then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local ehrp = v:FindFirstChild("HumanoidRootPart")
            if hum and ehrp and v:FindFirstChild("CharacterReady") and hum.Health > 0 then
                local d = (ehrp.Position - pos).Magnitude
                if d <= radius * radius * 0.001 + radius then -- alcance do bring
                    if not ehrp:FindFirstChild("BodyVelocity") then
                        local bv = Instance.new("BodyVelocity")
                        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                        bv.Velocity = Vector3.zero
                        bv.Parent = ehrp
                    end
                    local owned = true
                    if isnetworkowner then owned = isnetworkowner(ehrp) end
                    if d > 10 and owned then
                        ehrp.CFrame = CFrame.new(pos + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
                    end
                    ehrp.CanCollide = false
                end
            end
        end
    end
end

-- // CreateLoop — padrão Speed Hub X
local Loops = {}
local function CreateLoop(name, interval, fn)
    if Loops[name] then return end
    Loops[name] = true
    task.spawn(function()
        while true do
            if not Unloaded and Loops[name] then
                if Settings[name] then
                    local ok, err = pcall(fn)
                    if not ok then warn("[Kyrova:"..name.."] "..tostring(err)) end
                end
                task.wait(interval or 0.1)
            else break end
        end
        Loops[name] = nil
    end)
end

-- // ServerHop — verbatim Speed Hub X
local function ServerHop()
    pcall(function()
        for i = 1, 100 do
            local response = RS.__ServerBrowser:InvokeServer(i)
            for k, v in pairs(response) do
                if k ~= game.JobId and v.Count <= 8 and not string.find(tostring(v.Private), "true") then
                    task.spawn(function() RS.__ServerBrowser:InvokeServer("teleport", k) end)
                    return
                end
            end
        end
    end)
end

-- // remove death effect / camera shake — Speed Hub X
task.spawn(function()
    pcall(function()
        hookfunction(require(RS.Effect.Container:FindFirstChild("Death")), function() end)
        require(RS.Util.CameraShaker):Stop()
    end)
end)

--════════════════════════ QUEST DATA (Auto Farm Level) ════════════════════════
local QuestData = {
    [1] = {
        {L=1,Q="BanditQuest1",N=1,M="Bandit",QP=CFrame.new(1059.997,16.397,1549.288)},
        {L=10,Q="JungleQuest",N=1,M="Monkey",QP=CFrame.new(-1598.169,36.852,153.388)},
        {L=15,Q="JungleQuest",N=2,M="Gorilla",QP=CFrame.new(-1598.169,36.852,153.388)},
        {L=30,Q="BuggyQuest1",N=1,M="Pirate",QP=CFrame.new(-1140.176,4.752,3827.406)},
        {L=40,Q="BuggyQuest1",N=2,M="Brute",QP=CFrame.new(-1140.176,4.752,3827.406)},
        {L=60,Q="DesertQuest",N=1,M="Desert Bandit",QP=CFrame.new(896.36,6.48,4375.77)},
        {L=75,Q="DesertQuest",N=2,M="Desert Officer",QP=CFrame.new(896.36,6.48,4375.77)},
        {L=90,Q="SnowQuest",N=1,M="Snow Bandit",QP=CFrame.new(1386.807,87.272,-1298.357)},
        {L=105,Q="SnowQuest",N=2,M="Snowman",QP=CFrame.new(1386.807,87.272,-1298.357)},
        {L=120,Q="MarineQuest2",N=1,M="Chief Petty Officer",QP=CFrame.new(-5036.247,28.678,4324.566)},
        {L=150,Q="MarineQuest2",N=2,M="Vice Admiral",QP=CFrame.new(-5036.247,28.678,4324.566)},
        {L=175,Q="SkyQuest",N=1,M="Sky Bandit",QP=CFrame.new(-4839.53,716.37,-2615.03)},
        {L=190,Q="SkyQuest",N=2,M="Dark Master",QP=CFrame.new(-4839.53,716.37,-2615.03)},
        {L=225,Q="PrisonerQuest",N=1,M="Prisoner",QP=CFrame.new(5304.94,2.96,471.66)},
        {L=250,Q="PrisonerQuest",N=2,M="Dangerous Prisoner",QP=CFrame.new(5304.94,2.96,471.66)},
        {L=275,Q="MagmaQuest",N=1,M="Military Soldier",QP=CFrame.new(-5314.622,12.262,8517.279)},
        {L=300,Q="MagmaQuest",N=2,M="Military Detective",QP=CFrame.new(-5314.622,12.262,8517.279)},
        {L=325,Q="FishmanQuest",N=1,M="Fishman Warrior",QP=CFrame.new(61122.652,18.497,1569.399)},
        {L=350,Q="FishmanQuest",N=2,M="Fishman Commando",QP=CFrame.new(61122.652,18.497,1569.399)},
        {L=375,Q="GodsGuardiansQuest",N=1,M="God's Guard",QP=CFrame.new(-4698.09,718.79,-1516.66)},
        {L=400,Q="SkyExp2Quest",N=1,M="Royal Squad",QP=CFrame.new(-7903.383,5635.99,-1410.924)},
        {L=425,Q="SkyExp2Quest",N=2,M="Royal Soldier",QP=CFrame.new(-7903.383,5635.99,-1410.924)},
        {L=450,Q="FountainQuest",N=1,M="Galley Pirate",QP=CFrame.new(5258.279,38.527,4050.045)},
        {L=500,Q="FountainQuest",N=2,M="Galley Captain",QP=CFrame.new(5258.279,38.527,4050.045)},
    },
    [2] = {
        {L=875,Q="Area1Quest",N=1,M="Raider",QP=CFrame.new(-427.567,73.314,1835.421)},
        {L=900,Q="Area1Quest",N=2,M="Mercenary",QP=CFrame.new(-427.567,73.314,1835.421)},
        {L=925,Q="Area1Quest",N=3,M="Swan Pirate",QP=CFrame.new(-427.567,73.314,1835.421)},
        {L=950,Q="Area2Quest",N=1,M="Factory Staff",QP=CFrame.new(636.799,73.414,918.004)},
        {L=975,Q="Area2Quest",N=2,M="Marine Lieutenant",QP=CFrame.new(636.799,73.414,918.004)},
        {L=1000,Q="Area2Quest",N=3,M="Marine Captain",QP=CFrame.new(636.799,73.414,918.004)},
        {L=1050,Q="MarineQuest3",N=1,M="Zombie",QP=CFrame.new(-2441.986,73.359,-3217.532)},
        {L=1075,Q="MarineQuest3",N=2,M="Vampire",QP=CFrame.new(-2441.986,73.359,-3217.532)},
        {L=1100,Q="MarineQuest3",N=3,M="Snow Trooper",QP=CFrame.new(-2441.986,73.359,-3217.532)},
    },
    [3] = {
        {L=1475,M="Pirate Millionaire",P=CFrame.new(-712.827,98.577,5711.954)},
        {L=1525,M="Pistol Billionaire",P=CFrame.new(-723.433,147.429,5931.993)},
        {L=1575,M="Dragon Crew Warrior",P=CFrame.new(7021.504,55.763,-730.129)},
        {L=1625,M="Dragon Crew Archer",P=CFrame.new(6625,378,244)},
        {L=1675,M="Female Islander",P=CFrame.new(4692.794,797.977,858.848)},
        {L=1725,M="Venomous Assailant",P=CFrame.new(4902,670,39)},
        {L=1775,M="Marine Commodore",P=CFrame.new(2401,123,-7589)},
        {L=1825,M="Marine Rear Admiral",P=CFrame.new(3588,229,-7085)},
        {L=1875,M="Fishman Raider",P=CFrame.new(-10941,332,-8760)},
        {L=1925,M="Fishman Captain",P=CFrame.new(-11035,332,-9087)},
        {L=1975,M="Forest Pirate",P=CFrame.new(-13446,413,-7760)},
        {L=2025,M="Mythological Pirate",P=CFrame.new(-13510,584,-6987)},
        {L=2075,M="Jungle Pirate",P=CFrame.new(-11778,426,-10592)},
        {L=2125,M="Musketeer Pirate",P=CFrame.new(-13282,496,-9565)},
        {L=2175,M="Reborn Skeleton",P=CFrame.new(-8764,142,5963)},
        {L=2200,M="Living Zombie",P=CFrame.new(-10227,421,6161)},
        {L=2225,M="Demonic Soul",P=CFrame.new(-9579,6,6194)},
        {L=2250,M="Possessed Mummy",P=CFrame.new(-9579,6,6194)},
        {L=2275,M="Peanut Scout",P=CFrame.new(-1993,187,-10103)},
        {L=2300,M="Peanut President",P=CFrame.new(-2215,159,-10474)},
        {L=2325,M="Ice Cream Chef",P=CFrame.new(-877,118,-11032)},
        {L=2350,M="Ice Cream Commander",P=CFrame.new(-877,118,-11032)},
        {L=2375,M="Cookie Crafter",P=CFrame.new(-2021,38,-12028)},
        {L=2400,M="Cake Guard",P=CFrame.new(-2024,38,-12026)},
        {L=2425,M="Baking Staff",P=CFrame.new(-1932,38,-12848)},
        {L=2450,M="Head Baker",P=CFrame.new(-1932,38,-12848)},
        {L=2475,M="Cocoa Warrior",P=CFrame.new(95,73,-12309)},
        {L=2500,M="Chocolate Bar Battler",P=CFrame.new(647,42,-12401)},
        {L=2525,M="Sweet Thief",P=CFrame.new(116,36,-12478)},
        {L=2550,M="Candy Rebel",P=CFrame.new(47,61,-12889)},
    },
}
local function GetQuestByLevel(level)
    local data = World1 and QuestData[1] or World2 and QuestData[2] or QuestData[3]
    local chosen = data[1]
    for _, q in ipairs(data) do
        if level >= q.L then chosen = q else break end
    end
    return chosen
end

--════════════════════════ FARM HELPERS ════════════════════════
-- ataque genérico: tween se longe, hit se perto (estilo Attack.Kill do OK Hub)
local function AttackNearest(names, offsetY)
    local enemy = FindEnemy(names)
    if not enemy then DestroyTween() return false end
    local ehrp = enemy:FindFirstChild("HumanoidRootPart")
    if not ehrp then return false end
    BringEnemies(enemy, ehrp.CFrame)
    ActivateHaki()
    EquipSelectedTool()
    local target = ehrp.CFrame * CFrame.new(0, offsetY or 30, 0)
    if GetDistance(target) > 150 then
        ExecuteTween(target)
    else
        DestroyTween()
        ExecuteBladeHits()
    end
    return true
end

-- Stack Farming — portado do CheckStackPriority do Speed Hub X
local PriorityTable = {
    {name="Auto Farm Level",p=1,check=function() local q=GetQuestByLevel(LocalPlayer.Data.Level.Value) return q and FindEnemy(q.M) ~= nil end},
    {name="Auto Farm Nearest",p=2,check=function() return #Enemies:GetChildren() > 0 end},
    {name="Auto Farm Mastery",p=3,check=function() return FindEnemy({"Reborn Skeleton","Demonic Soul","Living Zombie","Possessed Mummy"}) ~= nil end},
    {name="Auto Collect Chest",p=4,check=function()
        for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
            if c and not c:GetAttribute("IsDisabled") then return true end
        end
        return false
    end},
    {name="Auto Farm Material",p=6,check=function()
        local npcs = MaterialNPCs[Settings["Choose Material"]]
        return npcs and FindEnemy(npcs) ~= nil
    end},
    {name="Auto Farm Bones",p=7,check=function() return FindEnemy({"Soul Reaper"}) ~= nil or FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"}) ~= nil end},
    {name="Auto Attack Boss",p=8,check=function() return Settings["Choose Boss"] ~= "" and FindEnemy(Settings["Choose Boss"]) ~= nil end},
    {name="Auto Attack All Boss",p=9,check=function()
        for _, v in ipairs(RS:GetChildren()) do
            if v:GetAttribute("IsBoss") and v:FindFirstChild("HumanoidRootPart") then return true end
        end
        return FindEnemy(function() end) ~= nil
    end},
    {name="Auto Soul Reaper",p=10,check=function() return FindEnemy({"Soul Reaper"}) ~= nil or HasTool("Hallow Essence") end},
    {name="Auto Elite Hunter",p=11,check=function() return FindEnemy({"Diablo","Deandre","Urban"}) ~= nil end},
    {name="Auto Citizen Quest",p=13,check=function() return FindEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"}) ~= nil end},
    {name="Auto Dough King",p=14,check=function() return HasTool("God's Chalice") or HasTool("Sweet Chalice") or FindEnemy({"Dough King"}) ~= nil end},
    {name="Auto Cake Prince",p=15,check=function() return FindEnemy({"Cake Prince","Dough King"}) ~= nil or FindEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"}) ~= nil end},
}
local function CanFarm(featureName)
    if not Settings["Stack Farming Enabled"] then return true end
    local me
    for _, e in ipairs(PriorityTable) do if e.name == featureName then me = e break end end
    if not me or not Settings[featureName] then return false end
    for _, e in ipairs(PriorityTable) do
        if Settings[e.name] and e.p < me.p then
            local ok, res = pcall(e.check)
            if ok and res then return false end
        end
    end
    return true
end

-- item raro (Stop On Rare Items)
local function HasRareItem()
    local rare = {"God's Chalice","Fist of Darkness","Sweet Chalice","Hallow Essence"}
    for _, cont in ipairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
        if cont then
            for _, it in ipairs(cont:GetChildren()) do
                if it:IsA("Tool") then
                    for _, rn in ipairs(rare) do
                        if string.find(it.Name, rn, 1, true) then return it.Name end
                    end
                end
            end
        end
    end
end

--════════════════════════ LOOPS DE FARM ════════════════════════

-- Auto Farm Level
CreateLoop("Auto Farm Level", 0.1, function()
    if not CanFarm("Auto Farm Level") then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hum and hum.Health > 0) then return end
    local quest = GetQuestByLevel(LocalPlayer.Data.Level.Value)
    if not quest then return end
    if quest.QP then
        local hasQuest = false
        pcall(function() hasQuest = playerGui.Main.Quest.Visible end)
        if not hasQuest then
            if GetDistance(quest.QP) > 250 then ExecuteTween(quest.QP) return end
            CommF_:InvokeServer("StartQuest", quest.Q, quest.N)
            task.wait(0.3)
        end
    end
    if not AttackNearest(quest.M) then
        DestroyTween()
    end
end)

-- Auto Farm Nearest
CreateLoop("Auto Farm Nearest", 0.1, function()
    if not CanFarm("Auto Farm Nearest") then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local nearest, nd = nil, math.huge
    for _, e in ipairs(Enemies:GetChildren()) do
        local ehrp = e:FindFirstChild("HumanoidRootPart")
        if ehrp and IsEntityAlive(e) then
            local d = (ehrp.Position - hrp.Position).Magnitude
            if d < nd then nd, nearest = d, e end
        end
    end
    if nearest then
        BringEnemies(nearest, nearest.HumanoidRootPart.CFrame)
        ActivateHaki()
        EquipSelectedTool()
        local target = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
        if GetDistance(target) > 150 then ExecuteTween(target)
        else DestroyTween() ExecuteBladeHits() end
    else
        DestroyTween()
    end
end)

-- Auto Factory Raid
local FactoryPos = CFrame.new(430, 22, -425)
CreateLoop("Auto Factory Raid", 0.1, function()
    if not FindEnemy("Core") then
        DestroyTween()
        if GetDistance(FactoryPos) > 150 then ExecuteTween(FactoryPos) end
        return
    end
    AttackNearest("Core", 20)
end)

-- Auto Farm Ectoplasma
local EctoMobs = {"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}
local CursedShipCF = CFrame.new(923.212, 126.976, 32852.832)
CreateLoop("Auto Farm Ectoplasma", 0.1, function()
    if not FindEnemy(EctoMobs) then
        DestroyTween()
        if GetDistance(CursedShipCF) > 400 then ExecuteTween(CursedShipCF) end
        return
    end
    AttackNearest(EctoMobs)
end)

-- Auto Collect Chest — CollectionService (Speed Hub X)
CreateLoop("Auto Collect Chest", 0.1, function()
    if not CanFarm("Auto Collect Chest") then return end
    local best, bd = nil, math.huge
    for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
        if chest and not chest:GetAttribute("IsDisabled") and chest.Parent then
            local part = chest:IsA("BasePart") and chest
                or (chest:IsA("Model") and (chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")))
            if part then
                local d = GetDistance(part.CFrame)
                if d < bd then bd, best = d, part end
            end
        end
    end
    if best then
        if GetDistance(best.CFrame) > 20 then ExecuteTween(best.CFrame)
        else
            DestroyTween()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and firetouchinterest then
                firetouchinterest(hrp, best, 0)
                firetouchinterest(hrp, best, 1)
            end
        end
    else
        DestroyTween()
    end
end)

-- Auto Farm Bones
CreateLoop("Auto Farm Bones", 0.1, function()
    if not CanFarm("Auto Farm Bones") then return end
    if not AttackNearest({"Reborn Skeleton","Demonic Soul","Living Zombie","Possessed Mummy"}) then
        DestroyTween()
    end
end)

-- Auto Farm Material
CreateLoop("Auto Farm Material", 0.1, function()
    if not CanFarm("Auto Farm Material") then return end
    local npcs = MaterialNPCs[Settings["Choose Material"]]
    if npcs and not AttackNearest(npcs) then DestroyTween() end
end)

-- Auto Attack Boss / All Boss
CreateLoop("Auto Attack Boss", 0.1, function()
    if not CanFarm("Auto Attack Boss") then return end
    local sel = Settings["Choose Boss"]
    if sel and sel ~= "" and not AttackNearest(sel) then DestroyTween() end
end)
CreateLoop("Auto Attack All Boss", 0.1, function()
    if not CanFarm("Auto Attack All Boss") then return end
    local best, bd = nil, math.huge
    for _, v in ipairs(Enemies:GetChildren()) do
        if v:GetAttribute("IsBoss") and v:FindFirstChild("HumanoidRootPart") and IsEntityAlive(v) then
            local d = GetDistance(v.HumanoidRootPart.CFrame)
            if d < bd then bd, best = d, v end
        end
    end
    if not best then
        for _, v in ipairs(RS:GetChildren()) do
            if v:IsA("Model") and v:GetAttribute("IsBoss") and v:FindFirstChild("HumanoidRootPart") then
                local d = GetDistance(v.HumanoidRootPart.CFrame)
                if d < bd then bd, best = d, v end
            end
        end
    end
    if best then
        ActivateHaki()
        EquipSelectedTool()
        local target = best.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0)
        if GetDistance(target) > 150 then ExecuteTween(target)
        else DestroyTween() ExecuteBladeHits() end
    else
        DestroyTween()
    end
end)

-- Cake Prince / Dough King / Soul Reaper / Elite Hunter / Citizen
CreateLoop("Auto Cake Prince", 0.1, function()
    if not CanFarm("Auto Cake Prince") then return end
    if not AttackNearest({"Cake Prince","Dough King","Baking Staff","Head Baker","Cake Guard","Cookie Crafter"}) then DestroyTween() end
end)
CreateLoop("Auto Dough King", 0.1, function()
    if not CanFarm("Auto Dough King") then return end
    if not AttackNearest({"Dough King","Cake Prince"}) then DestroyTween() end
end)
CreateLoop("Auto Soul Reaper", 0.1, function()
    if not CanFarm("Auto Soul Reaper") then return end
    if not FindEnemy("Soul Reaper") and HasTool("Hallow Essence") then
        pcall(function() CommF_:InvokeServer("ActivateHallowEssence") end)
    end
    if not AttackNearest("Soul Reaper") then DestroyTween() end
end)
CreateLoop("Auto Elite Hunter", 0.1, function()
    if not CanFarm("Auto Elite Hunter") then return end
    if not AttackNearest({"Diablo","Deandre","Urban"}) then DestroyTween() end
end)
CreateLoop("Auto Citizen Quest", 0.1, function()
    if not CanFarm("Auto Citizen Quest") then return end
    if not AttackNearest({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"}) then DestroyTween() end
end)

-- Sea Events (Fishing) — checks do OK Hub + attack da engine
CreateLoop("Auto Shark", 0.1, function() if not AttackNearest("Shark", 20) then DestroyTween() end end)
CreateLoop("Auto Terrorshark", 0.1, function() if not AttackNearest("Terrorshark", 20) then DestroyTween() end end)
CreateLoop("Auto Piranha", 0.1, function() if not AttackNearest("Piranha", 20) then DestroyTween() end end)
CreateLoop("Auto Fish Crew", 0.1, function() if not AttackNearest({"Fish Crew Member","Haunted Crew Member"}, 20) then DestroyTween() end end)
CreateLoop("Auto Sea Beast", 0.1, function()
    local sb = workspace:FindFirstChild("SeaBeasts") and workspace.SeaBeasts:FindFirstChild("SeaBeast1")
    if sb then
        ActivateHaki() EquipSelectedTool()
        if GetDistance(sb:GetPivot()) > 200 then ExecuteTween(sb:GetPivot())
        else DestroyTween() ExecuteBladeHits() end
    else DestroyTween() end
end)

-- Fast Attack + Kill Aura — Speed Hub X
task.spawn(function()
    while task.wait() do
        if Unloaded then break end
        if Settings["Fast Attack"] or Settings["Kill Aura"] then
            local delay = tonumber(Settings["Fast Attack Delay"]) or 0
            pcall(ExecuteBladeHits)
            if delay > 0 then task.wait(delay) end
        end
    end
end)

-- Stop On Rare Items
task.spawn(function()
    while task.wait(1) do
        if Unloaded then break end
        if Settings["Stop On Rare Items"] and IsAnyFeatureActive() then
            local found = HasRareItem()
            if found then
                for _, f in ipairs(FeatureFlags) do
                    Settings[f] = false
                    if G_NAMES[f] then _G[G_NAMES[f]] = false end
                    pcall(function() VindUI:SetUIElementValue(f, false, false) end)
                end
                Notify("Item Raro!", found .. " encontrado — farms desligados!", "success")
            end
        end
    end
end)

-- Auto Store Fruit (OK Hub)
CreateLoop("Auto Store Fruit", 1, function()
    for _, x in ipairs(LocalPlayer.Backpack:GetChildren()) do
        local remote = x:FindFirstChild("EatRemote", true)
        if remote then
            pcall(function()
                CommF_:InvokeServer("StoreFruit", remote.Parent:GetAttribute("OriginalName"), x)
            end)
        end
    end
end)

-- Auto Add Points (OK Hub — statsSetings)
CreateLoop("Auto Add Points", 0.5, function()
    pcall(function()
        local stat = Settings["Stat Select"] == "Devil Fruit" and "Demon Fruit" or Settings["Stat Select"]
        if LocalPlayer.Data.Points.Value > 0 then
            CommF_:InvokeServer("AddPoint", stat, math.min(Settings["Stat Points"] or 10, LocalPlayer.Data.Points.Value))
        end
    end)
end)

-- Auto Turn On Buso
task.spawn(function()
    while task.wait(1) do
        if Unloaded then break end
        if Settings["Auto Turn On Buso"] then pcall(ActivateHaki) end
    end
end)

-- Auto Haki Observation (aperta F ao renascer — igual OK Hub AutoKen)
task.spawn(function()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2)
        if Settings["Auto Ken"] then
            pcall(function()
                VIM:SendKeyEvent(true, "F", false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, "F", false, game)
            end)
        end
    end)
end)

-- Anti AFK (OK Hub)
local antiAfkConn = nil
task.spawn(function()
    while task.wait(1) do
        if Unloaded then break end
        if Settings["Anti AFK"] and not antiAfkConn then
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                VU:CaptureController()
                VU:ClickButton2(Vector2.new())
            end)
        elseif not Settings["Anti AFK"] and antiAfkConn then
            antiAfkConn:Disconnect() antiAfkConn = nil
        end
    end
end)

-- Auto Anti Admin Join Server (OK Hub)
local AdminWatchlist = {} -- adicione usernames aqui
Players.PlayerAdded:Connect(function(plr)
    task.wait(0.5)
    if Settings["Anti Admin"] and (table.find(AdminWatchlist, plr.Name) or table.find(AdminWatchlist, plr.DisplayName)) then
        Notify("Anti Admin", plr.Name .. " entrou — saindo!", "warning")
        task.wait(1)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- ESP
local function ApplyESP(model, tag, color)
    if not model or not model.Parent then return end
    local h = model:FindFirstChild("KyrovaESP_" .. tag)
    if not h then
        h = Instance.new("Highlight")
        h.Name = "KyrovaESP_" .. tag
        h.FillTransparency = 0.6
        h.Parent = model
    end
    h.FillColor, h.OutlineColor, h.Enabled = color, color, true
end
local function RemoveESP(model, tag)
    local h = model and model:FindFirstChild("KyrovaESP_" .. tag)
    if h then h:Destroy() end
end
task.spawn(function()
    while task.wait(1) do
        if Unloaded then break end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if Settings["ESP Player"] then ApplyESP(plr.Character,"Player",Color3.fromRGB(255,0,0))
                else RemoveESP(plr.Character,"Player") end
            end
        end
        for _, mob in ipairs(Enemies:GetChildren()) do
            if Settings["ESP Mob"] then ApplyESP(mob,"Mob",Color3.fromRGB(255,255,0))
            else RemoveESP(mob,"Mob") end
        end
        for _, ch in ipairs(CollectionService:GetTagged("_ChestTagged")) do
            if ch:IsA("BasePart") or ch:IsA("Model") then
                if Settings["ESP Chest"] then ApplyESP(ch,"Chest",Color3.fromRGB(0,255,0))
                else RemoveESP(ch,"Chest") end
            end
        end
        for _, f in ipairs(workspace:GetChildren()) do
            if string.find(f.Name, "Fruit") then
                if Settings["ESP Fruit"] then ApplyESP(f,"Fruit",Color3.fromRGB(170,0,255))
                else RemoveESP(f,"Fruit") end
            end
        end
    end
end)

-- Remove Fog
task.spawn(function()
    local default = Lighting.FogEnd
    while task.wait(1) do
        if Unloaded then break end
        Lighting.FogEnd = Settings["Remove Fog"] and 9e9 or default
    end
end)

-- WalkSpeed / JumpPower / Infinite Energy
task.spawn(function()
    while task.wait(0.2) do
        if Unloaded then break end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            if Settings["Apply WalkSpeed"] then pcall(function() hum.WalkSpeed = Settings["WalkSpeed"] end) end
            if Settings["Apply JumpPower"] then pcall(function() hum.JumpPower = Settings["JumpPower"] end) end
        end
        if char and Settings["Infinite Energy"] then
            pcall(function()
                local energy = char:FindFirstChild("Energy")
                if energy then energy.Value = math.max(energy.Value, 1) end
            end)
        end
    end
end)

-- Auto Turn v3 / v4 (OK Hub) — HOOKS: cole as lógicas na extensão
CreateLoop("Auto Turn V3", 1, function() -- [LOGICA OK HUB — Human v3]
    -- os mobs estão em Human_v3_Mob = {"Fajita","Jeremy","Diamond"} no OK Hub
end)
CreateLoop("Auto Turn V4", 1, function() -- [LOGICA OK HUB — Race V4]
end)

--════════════════════════ UI — KYROVA HUB ════════════════════════

getgenv().CONFIG = {
    Theme = "Dark",
    Intro = {
        Enabled = true, Title = "Kyrova Hub", Eyebrow = "BEM-VINDO",
        Subtitle = "Blox Fruits • Carregando...", Logo = "rbxassetid://71647128089295",
        UseBlur = true, Transparency = 0.22, Shimmer = true,
        Duration = 2.6, Skippable = true, ReducedMotion = false,
    },
    Integrations = {Spotify=false, Assistant=false, Cloud=false, GlobalChat=false},
    MobileScaleReference = 450,
    UserInfo = {Enabled=true, Avatar="player", NameMode="display"},
    FeedbackWebhook = "", CloudBaseUrl = "", CommunityUrl = "",
}

local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/vindUI-Test/main/full.luau"))()
VindUI:SetTheme(getgenv().CONFIG.Theme)
VindUI:PreloadIcons({"Lucide","Material","Phosphor","SF"})
VindUI:SetScaleRange(0.75, 1.35)
VindUI:SetMobileScaleReference(getgenv().CONFIG.MobileScaleReference)
VindUI:ShowIntro(getgenv().CONFIG.Intro):Wait()

local Window = VindUI:CreateWindow({
    Title = "Kyrova Hub",
    Subtitle = "Blox Fruits • Sea " .. (World1 and 1 or World2 and 2 or 3),
    Icon = "rbxassetid://71647128089295",
    Size = UDim2.fromOffset(640, 455),
    MinSize = Vector2.new(500, 360),
    Draggable = true, Resizable = true, UseBlur = true,
    DefaultTab = "Main", TabWidth = 145, TabScrollbar = true,
    UserInfo = getgenv().CONFIG.UserInfo,
})

local function AddToggle(tab, key, text, extra)
    Settings[key] = Settings[key] or false
    local opts = {Text = text, Flag = key, Default = Settings[key]}
    if extra then for k, v in pairs(extra) do if k ~= "Callback" then opts[k] = v end end end
    opts.Callback = function(value)
        Settings[key] = value
        if G_NAMES[key] then _G[G_NAMES[key]] = value end
        if extra and extra.Callback then extra.Callback(value) end
    end
    return tab:AddToggle(opts)
end

local Tabs = {}
local MainGroup = Window:AddTabGroup({Name = "KYROVA HUB"})
Tabs.Info     = MainGroup:AddTab({Name="Info / Status", Icon="Lucide:info"})
Tabs.Main     = MainGroup:AddTab({Name="Main", Icon="Lucide:swords"})
Tabs.Fishing  = MainGroup:AddTab({Name="Fishing", Icon="Lucide:fish"})
Tabs.Quest    = MainGroup:AddTab({Name="Quest & Item", Icon="Lucide:scroll"})
Tabs.Volcano  = MainGroup:AddTab({Name="Volcano Event", Icon="Lucide:flame"})
Tabs.Stats    = MainGroup:AddTab({Name="Stats & ESP", Icon="Lucide:bar-chart-3"})
Tabs.Fruit    = MainGroup:AddTab({Name="Fruit & Raid", Icon="Lucide:cherry"})
Tabs.LocalP   = MainGroup:AddTab({Name="Local Player", Icon="Lucide:user"})
Tabs.Teleport = MainGroup:AddTab({Name="Teleport", Icon="Lucide:map-pin"})
Tabs.Shop     = MainGroup:AddTab({Name="Shopping", Icon="Lucide:shopping-cart"})
Tabs.Misc     = MainGroup:AddTab({Name="Miscellaneous", Icon="Lucide:puzzle"})
local SysGroup = Window:AddTabGroup({Name = "SYSTEM"})
Tabs.Settings = SysGroup:AddTab({Name="Settings", Icon="Lucide:settings-2"})

-- ─── INFO / STATUS (OK Hub, sem discord) ───
do
    Tabs.Info:AddCard({
        UserId = LocalPlayer.UserId,
        Title = "Bem-vindo, " .. LocalPlayer.DisplayName,
        Description = "Kyrova Hub • " .. (World1 and "1st Sea" or World2 and "2nd Sea" or "3rd Sea"),
    })
    Tabs.Info:AddSystemInfoGrid({Description = "FPS, Ping, Executor e info da sessão"})
    pcall(function()
        Tabs.Info:AddInfoGrid({
            Title = "Suas Informações", Columns = 2,
            Items = {
                {Label="Level",Value=tostring(LocalPlayer.Data.Level.Value)},
                {Label="Beli",Value=tostring(LocalPlayer.Data.Money.Value)},
                {Label="Fragments",Value=tostring(LocalPlayer.Data.Fragments.Value)},
                {Label="Bounty",Value=tostring(LocalPlayer.Data.Bounty.Value)},
                {Label="Race",Value=tostring(LocalPlayer.Data.Race.Value)},
                {Label="Fruit",Value=tostring(LocalPlayer.Data.DevilFruit.Value)},
            },
        })
    end)
    Tabs.Info:AddButton({Text="Rejoin Server", Icon="Lucide:log-in",
        Callback=function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
    Tabs.Info:AddButton({Text="Copy Job ID", Icon="Lucide:clipboard",
        Callback=function()
            if setclipboard then setclipboard(game.JobId); Notify("Copiado","Job ID na área de transferência","success")
            else Notify("Erro","Executor sem setclipboard","warning") end
        end})
end

-- ─── MAIN ───
do
    Tabs.Main:AddSection("Farm", "Lucide:swords")
    AddToggle(Tabs.Main, "Auto Farm Level", "Auto Farm")                    -- Speed Hub X
    AddToggle(Tabs.Main, "Auto Farm Nearest", "Auto Farm Nearest")          -- Speed Hub X
    AddToggle(Tabs.Main, "Auto Factory Raid", "Auto Factory Raid")
    AddToggle(Tabs.Main, "Auto Farm Ectoplasma", "Auto Farm Ectoplasma")
    AddToggle(Tabs.Main, "Auto Collect Chest", "Auto Collect Chest")        -- Speed Hub X
    AddToggle(Tabs.Main, "Stop On Rare Items", "Stop On Rare Items")        -- Speed Hub
    Tabs.Main:AddSection("Farming", "Lucide:leaf")
    AddToggle(Tabs.Main, "Auto Farm Bones", "Auto Farm Bones")
    AddToggle(Tabs.Main, "Auto Farm Material", "Auto Farm Material")
    Tabs.Main:AddDropdown({Text="Select Material", Flag="Choose Material",
        Options=MaterialList, Default=MaterialList[1],
        Callback=function(v) Settings["Choose Material"]=v end})
    AddToggle(Tabs.Main, "Auto Cake Prince", "Auto Cake Prince")
    AddToggle(Tabs.Main, "Auto Dough King", "Auto Dough King")
    AddToggle(Tabs.Main, "Auto Soul Reaper", "Auto Soul Reaper")
    AddToggle(Tabs.Main, "Auto Elite Hunter", "Auto Elite Hunter")
    AddToggle(Tabs.Main, "Auto Citizen Quest", "Auto Citizen Quest")
    Tabs.Main:AddSection("Boss", "Lucide:skull")
    Tabs.Main:AddDropdown({Text="Select Boss", Flag="Choose Boss",
        Options=BossList, Default=BossList[1],
        Callback=function(v) Settings["Choose Boss"]=v end})
    AddToggle(Tabs.Main, "Auto Attack Boss", "Auto Attack Boss")
    AddToggle(Tabs.Main, "Auto Attack All Boss", "Auto Attack All Boss")
    Tabs.Main:AddSection("Stack", "Lucide:layers")
    AddToggle(Tabs.Main, "Stack Farming Enabled", "Enable Stack Farming (prioridade)")
end

-- ─── FISHING ───
do
    Tabs.Fishing:AddSection("Sea Events", "Lucide:fish")
    AddToggle(Tabs.Fishing, "Auto Shark", "Auto Kill Shark")
    AddToggle(Tabs.Fishing, "Auto Terrorshark", "Auto Kill Terrorshark")
    AddToggle(Tabs.Fishing, "Auto Piranha", "Auto Kill Piranha")
    AddToggle(Tabs.Fishing, "Auto Fish Crew", "Auto Kill Fish Crew")
    AddToggle(Tabs.Fishing, "Auto Sea Beast", "Auto Kill Sea Beast")
end

-- ─── QUEST & ITEM (OK Hub — flags _G prontas) ───
do
    Tabs.Quest:AddSection("Swords & Guns", "Lucide:swords")
    AddToggle(Tabs.Quest, "Auto Saber", "Auto Saber")
    AddToggle(Tabs.Quest, "Auto Pole", "Auto Pole (v1)")
    AddToggle(Tabs.Quest, "Auto Pole V2", "Auto Pole V2")
    AddToggle(Tabs.Quest, "Auto Saw", "Auto Saw")
    AddToggle(Tabs.Quest, "Auto Trident", "Auto Trident W2")
    AddToggle(Tabs.Quest, "Auto Yama", "Auto Yama")
    AddToggle(Tabs.Quest, "Auto Tushita", "Auto Tushita")
    AddToggle(Tabs.Quest, "Auto CDK", "Auto CDK")
    AddToggle(Tabs.Quest, "Auto Soul Guitar", "Auto Soul Guitar")
    AddToggle(Tabs.Quest, "Auto Serpent Bow", "Auto Serpent Bow")
    Tabs.Quest:AddSection("Fighting Styles", "Lucide:fist")
    AddToggle(Tabs.Quest, "Auto Superhuman", "Auto Superhuman")
    AddToggle(Tabs.Quest, "Auto Death Step", "Auto Death Step")
    AddToggle(Tabs.Quest, "Auto Sharkman", "Auto Sharkman Karate")
    AddToggle(Tabs.Quest, "Auto Electric Claw", "Auto Electric Claw")
    AddToggle(Tabs.Quest, "Auto Dragon Talon", "Auto Dragon Talon")
    AddToggle(Tabs.Quest, "Auto God Human", "Auto God Human")
    Tabs.Quest:AddSection("Quests", "Lucide:scroll")
    AddToggle(Tabs.Quest, "Auto Rainbow Haki", "Auto Rainbow Haki")
    AddToggle(Tabs.Quest, "Auto Bartilo", "Auto Bartilo Quest")
    AddToggle(Tabs.Quest, "Auto Cavender", "Auto Cavender")
    Tabs.Quest:AddParagraph({Title="Nota",
        Text="Esses toggles setam as flags _G (AutoSaber, Auto_Yama, etc). Cole as funções do OK Hub na área de extensão no fim do script e elas ativam automaticamente."})
end

-- ─── VOLCANO EVENT ───
do
    Tabs.Volcano:AddSection("Volcano Event (Sea 3)", "Lucide:flame")
    AddToggle(Tabs.Volcano, "Auto Collect Ember", "Auto Collect Azure Ember")       -- [LOGICA OK HUB]
    AddToggle(Tabs.Volcano, "Auto Prehistoric", "Auto Summon Prehistoric Island")   -- [LOGICA OK HUB]
    AddToggle(Tabs.Volcano, "Tween Prehistoric", "Tween to Prehistoric Island")     -- [LOGICA OK HUB]
end

-- ─── STATS & ESP ───
do
    Tabs.Stats:AddSection("Auto Stats", "Lucide:bar-chart-3")
    Tabs.Stats:AddDropdown({Text="Select Stat", Flag="Stat Select",
        Options={"Melee","Defense","Sword","Gun","Devil Fruit"}, Default="Melee",
        Callback=function(v) Settings["Stat Select"]=v end})
    Tabs.Stats:AddSlider({Text="Points per tick", Flag="Stat Points",
        Min=1, Max=100, Default=10, Increment=1,
        Callback=function(v) Settings["Stat Points"]=v end})
    AddToggle(Tabs.Stats, "Auto Add Points", "Auto Add Points")
    Tabs.Stats:AddSection("ESP", "Lucide:eye")
    AddToggle(Tabs.Stats, "ESP Player", "Player ESP")
    AddToggle(Tabs.Stats, "ESP Mob", "Mob ESP")
    AddToggle(Tabs.Stats, "ESP Chest", "Chest ESP")
    AddToggle(Tabs.Stats, "ESP Fruit", "Fruit ESP")
end

-- ─── FRUIT & RAID ───
do
    Tabs.Fruit:AddSection("Fruits", "Lucide:cherry")
    AddToggle(Tabs.Fruit, "Auto Store Fruit", "Auto Store Fruits")
    Tabs.Fruit:AddDropdown({Text="Select Fruit", Flag="Choose Fruit",
        Options=FruitList, Default=FruitList[1],
        Callback=function(v) Settings["Choose Fruit"]=v end})
    Tabs.Fruit:AddSection("Raid", "Lucide:swords")
    Tabs.Fruit:AddDropdown({Text="Select Chip", Flag="Choose Chip",
        Options=ChipList, Default="Flame",
        Callback=function(v) Settings["Choose Chip"]=v end})
    AddToggle(Tabs.Fruit, "Auto Raid", "Auto Raid")   -- [LOGICA OK HUB]
end

-- ─── LOCAL PLAYER ───
do
    Tabs.LocalP:AddSection("Character", "Lucide:user")
    Tabs.LocalP:AddSlider({Text="Walk Speed", Flag="WalkSpeed",
        Min=16, Max=500, Default=16, Increment=1,
        Callback=function(v) Settings["WalkSpeed"]=v end})
    Tabs.LocalP:AddSlider({Text="Jump Power", Flag="JumpPower",
        Min=50, Max=500, Default=50, Increment=1,
        Callback=function(v) Settings["JumpPower"]=v end})
    AddToggle(Tabs.LocalP, "Apply WalkSpeed", "Enable Walk Speed")
    AddToggle(Tabs.LocalP, "Apply JumpPower", "Enable Jump Power")
    AddToggle(Tabs.LocalP, "Infinite Energy", "Infinite Energy")
    Tabs.LocalP:AddButton({Text="Reset Character", Icon="Lucide:skull",
        Callback=function() pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end) end})
end

-- ─── TELEPORT ───
do
    local Locations = {}
    pcall(function()
        for _, v in ipairs(workspace._WorldOrigin.Locations:GetChildren()) do
            table.insert(Locations, v.Name)
        end
    end)
    table.sort(Locations)
    if #Locations == 0 then Locations = {"(entre no jogo)"} end
    Tabs.Teleport:AddSection("Teleport", "Lucide:map-pin")
    Tabs.Teleport:AddDropdown({Text="Select Island", Flag="TP Island",
        Options=Locations, Default=Locations[1],
        Callback=function(v) Settings["TP Island"]=v end})
    Tabs.Teleport:AddButton({Text="Tween to Island", Icon="Lucide:rocket",
        Callback=function()
            local loc = workspace._WorldOrigin.Locations:FindFirstChild(Settings["TP Island"])
            if loc then
                ExecuteTween(CFrame.new(loc.Position + Vector3.new(0, 50, 0)))
                Notify("Teleport", "Indo para " .. Settings["TP Island"], "info")
            end
        end})
    Tabs.Teleport:AddButton({Text="Stop Tween", Icon="Lucide:x", Callback=DestroyTween})
end

-- ─── SHOPPING (Speed Hub X verbatim) ───
do
    local Shop = {
        ["Fragments"] = {
            {"Race Reroll", {"BlackbeardReward","Reroll","2"}},
            {"Reset Stats", {"BlackbeardReward","Refund","2"}},
        },
        ["Fighting Style"] = {
            {"Buy Black Leg",{"BuyBlackLeg"}},{"Buy Electro",{"BuyElectro"}},
            {"Buy Fishman Karate",{"BuyFishmanKarate"}},
            {"Buy Dragon Claw",{"BlackbeardReward","DragonClaw","2"}},
            {"Buy Superhuman",{"BuySuperhuman"}},{"Buy Death Step",{"BuyDeathStep"}},
            {"Buy Sharkman Karate",{"BuySharkmanKarate"}},
            {"Buy Electric Claw",{"BuyElectricClaw"}},
            {"Buy Dragon Talon",{"BuyDragonTalon"}},
            {"Buy Godhuman",{"BuyGodhuman"}},{"Buy Sanguine Art",{"BuySanguineArt"}},
        },
        ["Ability Teacher"] = {
            {"Buy Geppo",{"BuyHaki","Geppo"}},{"Buy Buso",{"BuyHaki","Buso"}},
            {"Buy Soru",{"BuyHaki","Soru"}},{"Buy Ken (Observation)",{"KenTalk","Buy"}},
        },
        ["Sword"] = {
            {"Buy Katana",{"BuyItem","Katana"}},{"Buy Cutlass",{"BuyItem","Cutlass"}},
            {"Buy Dual Katana",{"BuyItem","Dual Katana"}},
            {"Buy Iron Mace",{"BuyItem","Iron Mace"}},
            {"Buy Triple Katana",{"BuyItem","Triple Katana"}},
            {"Buy Pipe",{"BuyItem","Pipe"}},
            {"Buy Dual-Headed Blade",{"BuyItem","Dual-Headed Blade"}},
            {"Buy Soul Cane",{"BuyItem","Soul Cane"}},
            {"Buy Bisento",{"BuyItem","Bisento"}},
        },
        ["Gun"] = {
            {"Buy Musket",{"BuyItem","Musket"}},
            {"Buy Slingshot",{"BuyItem","Slingshot"}},
            {"Buy Flintlock",{"BuyItem","Flintlock"}},
            {"Buy Refined Slingshot",{"BuyItem","Refined Slingshot"}},
            {"Buy Refined Flintlock",{"BuyItem","Refined Flintlock"}},
            {"Buy Cannon",{"BuyItem","Cannon"}},
            {"Buy Kabucha",{"BlackbeardReward","Slingshot","2"}},
        },
        ["Accessories"] = {
            {"Buy Black Cape",{"BuyItem","Black Cape"}},
            {"Buy Swordsman Hat",{"BuyItem","Swordsman Hat"}},
            {"Buy Tomoe Ring",{"BuyItem","Tomoe Ring"}},
        },
        ["Race"] = {
            {"Ghoul Race",{"Ectoplasm","Change","4"}},
            {"Cyborg Race",{"CyborgTrainer","Buy"}},
        },
    }
    for _, sectionName in ipairs({"Fragments","Fighting Style","Ability Teacher","Sword","Gun","Accessories","Race"}) do
        Tabs.Shop:AddSection(sectionName, "Phosphor:shopping-cart")
        for _, item in ipairs(Shop[sectionName]) do
            Tabs.Shop:AddButton({Text=item[1], Callback=function()
                pcall(function() CommF_:InvokeServer(unpack(item[2])) end)
                Notify("Shop", item[1], "success")
            end})
        end
    end
end

-- ─── MISCELLANEOUS ───
do
    Tabs.Misc:AddSection("Performance", "Lucide:gauge")
    AddToggle(Tabs.Misc, "FPS Boost", "FPS Boost", {Callback=function(v)
        if v then
            pcall(function()
                local t = workspace.Terrain
                t.WaterWaveSize=0 t.WaterWaveSpeed=0 t.WaterReflectance=0 t.WaterTransparency=0
                Lighting.GlobalShadows=false Lighting.FogEnd=9e9 Lighting.Brightness=0
                settings().Rendering.QualityLevel="Level01"
                for _, e in ipairs(Lighting:GetChildren()) do
                    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
                        or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                        e.Enabled = false
                    end
                end
            end)
        end
    end})
    AddToggle(Tabs.Misc, "Remove Fog", "Remove Fog")
    Tabs.Misc:AddSection("Server", "Lucide:server")
    Tabs.Misc:AddButton({Text="Server Hop", Icon="Lucide:refresh-cw",
        Callback=function() ServerHop() Notify("Hop","Procurando servidor...","info") end})
    Tabs.Misc:AddButton({Text="Rejoin", Icon="Lucide:log-in",
        Callback=function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
end

-- ─── SETTINGS (na ordem exata que você pediu) ───
do
    Tabs.Settings:AddSection("Combat", "Lucide:swords")
    AddToggle(Tabs.Settings, "Kill Aura", "Kill Aura")                          -- da tab Volcano Event
    Tabs.Settings:AddDropdown({Text="Weapon Tool", Flag="Weapon Tool",          -- Speed Hub X
        Options={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee",
        Callback=function(v) Settings["Weapon Tool"]=v end})
    Tabs.Settings:AddDropdown({Text="Tween Speed", Flag="Tween Speed",          -- Speed Hub X
        Options={"250","300","350","400","500","700"}, Default="350",
        Callback=function(v) Settings["Tween Speed"]=tonumber(v) end})
    AddToggle(Tabs.Settings, "Bring Mob", "Bring Mob")                          -- Speed Hub X
    Tabs.Settings:AddDropdown({Text="Bring Radius", Flag="Bring Radius",        -- Speed Hub X
        Options={"150","200","250","300","500","1000"}, Default="300",
        Callback=function(v) Settings["Bring Radius"]=tonumber(v) end})
    AddToggle(Tabs.Settings, "Fast Attack", "Fast Attack")                      -- Speed Hub X
    Tabs.Settings:AddSlider({Text="Fast Attack Delay", Flag="Fast Attack Delay",
        Min=0, Max=1, Default=0, Increment=0.05, Suffix="s",
        Callback=function(v) Settings["Fast Attack Delay"]=v end})
    Tabs.Settings:AddSection("General", "Lucide:settings-2")
    AddToggle(Tabs.Settings, "Auto Turn V3", "Auto Turn v3")                    -- OK Hub [hook]
    AddToggle(Tabs.Settings, "Auto Turn V4", "Auto Turn v4")                    -- OK Hub [hook]
    AddToggle(Tabs.Settings, "Anti AFK", "Anti AFK")                            -- OK Hub
    AddToggle(Tabs.Settings, "Anti Admin", "Auto Anti Admin Join Server")       -- OK Hub
    AddToggle(Tabs.Settings, "Disable Notify", "Disable Notify")                -- OK Hub
    AddToggle(Tabs.Settings, "Auto Turn On Buso", "Auto Turn On Buso")          -- OK Hub
    AddToggle(Tabs.Settings, "Auto Ken", "Auto Haki Observation")               -- OK Hub
    Tabs.Settings:AddSection("Config", "Lucide:save")
    Tabs.Settings:AddButton({Text="Save Config", Icon="Lucide:save",
        Callback=function()
            local ok, err = VindUI:SaveConfig("KyrovaHub")
            Notify("Config", ok and "Configuração salva!" or tostring(err), ok and "success" or "error")
        end})
    Tabs.Settings:AddButton({Text="Load Config", Icon="Lucide:folder-open",
        Callback=function()
            local ok, err = VindUI:LoadConfig("KyrovaHub")
            Notify("Config", ok and "Configuração carregada!" or tostring(err), ok and "success" or "warning")
        end})
    Tabs.Settings:AddButton({Text="Unload Kyrova Hub", Icon="Lucide:power",
        Callback=function()
            Unloaded = true
            DestroyTween()
            VindUI:Unload()
        end})
end

Window:AddAppearanceTab()
Window:SelectTab("Main")
Window:Open()
Notify("Kyrova Hub", "Carregado! RightShift para abrir/fechar.", "success")

--═══════════════════════════════════════════════════════════════════
--  ÁREA DE EXTENSÃO — cole aqui as funções do OK Hub
--  (a partir do QuestB em diante: farm de quests, volcano, raids...)
--
--  Elas já têm acesso a:
--    • Settings["Auto Saber"] etc. (todas as flags)
--    • _G.AutoSaber, _G.Auto_Yama... (pontes automáticas)
--    • ExecuteTween(cf), DestroyTween(), ExecuteBladeHits(),
--      BringEnemies(mob, cf), AttackNearest(names), FindEnemy(names),
--      GetDistance(cf), EquipSelectedTool(), ActivateHaki(), FireRemote(...)
--  Exemplo:
--    task.spawn(function() while task.wait() do
--        if Settings["Auto Saber"] then
--            -- cole aqui o loop do Auto Saber do OK Hub (trocando _tp → ExecuteTween)
--        end
--    end end)
--═══════════════════════════════════════════════════════════════════
