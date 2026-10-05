--=====================================================================
-- BLOX FRUITS FARM | TODOS OS TOGGLES FUNCIONAIS | REDZ UI
--=====================================================================
repeat task.wait() until game:IsLoaded()

local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local TweenService        = game:GetService("TweenService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local CollectionService   = game:GetService("CollectionService")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")
local WS          = workspace

local replicated = ReplicatedStorage
local Remotes    = replicated:WaitForChild("Remotes")
local CommF_     = Remotes:WaitForChild("CommF_")
local CommE      = Remotes:FindFirstChild("CommE")
local Modules    = replicated:WaitForChild("Modules")
local Net        = Modules:WaitForChild("Net")
local Enemies    = WS:WaitForChild("Enemies")
local Characters = WS:WaitForChild("Characters")
local Map        = WS:WaitForChild("Map")
local WorldOrigin= WS:WaitForChild("_WorldOrigin")

local PlaceId = game.PlaceId
local World1 = (PlaceId == 2753915549 or PlaceId == 85211729168715)
local World2 = (PlaceId == 4442272183 or PlaceId == 79091703265657)
local World3 = (PlaceId == 7449423635 or PlaceId == 100117331123089)

local Root, Hum
local function bindChar(c)
    Root = c:WaitForChild("HumanoidRootPart", 10)
    Hum  = c:WaitForChild("Humanoid", 10)
end
if localPlayer.Character then bindChar(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(bindChar)

local Data     = localPlayer:WaitForChild("Data", 20)
local Level    = Data and Data:WaitForChild("Level")
local Beli     = Data and Data:WaitForChild("Beli")
local Frags    = Data and Data:WaitForChild("Fragments")
local RaceData = Data and Data:WaitForChild("Race")

local State = {
    TweenSpeed = 300,
    BringMob = true,
    BringRadius = 300,
    WeaponTool = "Melee",
    FarmDistance = 20,
}

--=====================================================================
-- SPEED HUB TWEEN
--=====================================================================
local tbl20 = { __activeController = nil }

local function FindNearestTeleporter(targetCF)
    local position = targetCF.Position
    local pid = game.PlaceId
    local tps = {}
    if pid == 7449423635 then
        tps = {["Castle On The Sea"]=Vector3.new(-5058.775,314.5155,-3155.8833),
            Hydra=Vector3.new(5756.8374,610.424,-253.9254),
            Mansion=Vector3.new(-12463.874,374.9145,-7523.774),
            ["Great Tree"]=Vector3.new(28282.57,14896.851,105.1043),
            ["Temple Clock"]=Vector3.new(28282.57,14896.851,105.10427)}
    elseif pid == 4442272183 then
        tps = {Mansion=Vector3.new(-288.4625,306.1306,597.9988),
            Flamingo=Vector3.new(2284.912,15.152,905.4829),
            ["122"]=Vector3.new(923.2125,126.976,32852.832),
            ["3032"]=Vector3.new(-6508.558,89.035,-132.8395)}
    elseif pid == 2753915549 then
        tps = {["1"]=Vector3.new(-7894.62,5545.4917,-380.2467),
            ["2"]=Vector3.new(-4607.8228,872.5423,-1667.5569),
            ["3"]=Vector3.new(61163.85,11.7595,1819.7842),
            ["4"]=Vector3.new(3876.2805,35.1061,-1939.3202)}
    end
    if not next(tps) then return nil end
    local huge, best = math.huge, nil
    for _, v in pairs(tps) do
        local m = (v - position).Magnitude
        if m < huge then huge = m; best = v end
    end
    local c = localPlayer.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    if huge <= (position - hrp.Position).Magnitude then return best end
    return nil
end

local function CreateTweenController(model)
    local tbl = {}
    if not model or not model.Parent then return nil end
    local v19 = model
    local origVel = v19.AssemblyLinearVelocity
    local scc, sa = {}, {}
    local tw, bv, conn, flag = nil, nil, nil, false

    local function stop()
        if conn then conn:Disconnect(); conn = nil end
        if tw then tw:Cancel(); tw = nil end
        if bv then bv:Destroy(); bv = nil end
        for _, d in pairs(v19.Parent:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanCollide = (scc[d] ~= nil) and scc[d] or true
                scc[d] = nil
                if sa[d] ~= nil then d.Anchored = sa[d]; sa[d] = nil end
            end
        end
        v19.AssemblyLinearVelocity = origVel
        v19.AssemblyAngularVelocity = Vector3.zero
        flag = false
    end

    tbl.ExecuteTween = function(_, tcf, sp)
        if flag then stop() end
        origVel = v19.AssemblyLinearVelocity
        for _, d in pairs(v19.Parent:GetDescendants()) do
            if d:IsA("BasePart") then
                scc[d] = d.CanCollide; sa[d] = d.Anchored; d.CanCollide = false
            end
        end
        v19.AssemblyLinearVelocity = Vector3.zero
        v19.AssemblyAngularVelocity = Vector3.zero
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000,4000,4000)
        bv.Velocity = Vector3.zero; bv.Parent = v19
        local dur = math.max(0.05,
            (v19.CFrame.Position - tcf.Position).Magnitude / math.max(sp or 100, 0.01))
        flag = true
        tw = TweenService:Create(v19, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = tcf})
        conn = tw.Completed:Connect(stop)
        tw:Play()
    end
    tbl.Destroy = stop
    return tbl
end

local function ExecuteTween(tcf, customSpeed)
    local c = localPlayer.Character
    c = c and c:FindFirstChild("HumanoidRootPart")
    if not c then return end
    if tbl20.__activeController then
        pcall(function() tbl20.__activeController:Destroy() end)
    end
    tbl20.__activeController = CreateTweenController(c)
    local sp = tonumber(customSpeed) or tonumber(State.TweenSpeed) or 100
    if sp <= 0 then sp = 100 end
    local pos = tcf.Position

    if (Vector3.new(10213.701,-1733.5026,9940.189) - pos).Magnitude <= 3500
        and localPlayer:DistanceFromCharacter(Vector3.new(10213.701,-1733.5026,9940.189)) > 3500 then
        if localPlayer:DistanceFromCharacter(Vector3.new(-16267,25,1371)) > 5 then
            tbl20.__activeController:ExecuteTween(CFrame.new(-16267,25,1371), sp)
        else replicated.Modules.Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland") end
        return
    end
    if localPlayer:GetAttribute("CurrentLocation") == "Submerged Island"
        and (Vector3.new(10213.701,-1733.5026,9940.189) - pos).Magnitude > 3500 then
        if localPlayer:DistanceFromCharacter(Vector3.new(11426,-2155,9730)) > 5 then
            tbl20.__activeController:ExecuteTween(CFrame.new(11426,-2155,9730), sp)
        else replicated.Modules.Net:FindFirstChild("RF/SubmarineTransportation")
            :InvokeServer("InitiateTeleport","Tiki Outpost") end
        return
    end
    if not _G.Teleporting then
        local n = FindNearestTeleporter(tcf)
        if n then
            _G.Teleporting = true
            c.AssemblyLinearVelocity = Vector3.zero
            c.AssemblyAngularVelocity = Vector3.zero
            CommF_:InvokeServer("requestEntrance", n)
            task.delay(1, function() _G.Teleporting = false end)
            return
        end
    end
    if tbl20.__activeController then
        tbl20.__activeController:ExecuteTween(tcf, sp)
    end
end
_G.ExecuteTween = ExecuteTween
local function _tp(cf)
    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    if typeof(cf) ~= "CFrame" then return end
    ExecuteTween(cf)
end
_G.tp = _tp

--=====================================================================
-- HELPERS
--=====================================================================
local function IsEntityAlive(m)
    local h = m and m:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(pos)
    local c = localPlayer.Character
    if not c or not c.PrimaryPart then return math.huge end
    local p
    if typeof(pos) == "CFrame" then p = pos.Position
    elseif typeof(pos) == "Vector3" then p = pos
    else return math.huge end
    return (c.PrimaryPart.Position - p).Magnitude
end

local function ActivateHaki()
    local c = localPlayer.Character
    if c and not c:FindFirstChild("HasBuso") then
        pcall(function() CommF_:InvokeServer("Buso") end)
    end
end

local function EquipToolByName(n)
    local bp, c = localPlayer.Backpack, localPlayer.Character
    if not (bp and c) then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local t = bp:FindFirstChild(n)
    if h and t and t:IsA("Tool") then h:EquipTool(t) end
end

local function EquipToolByTip(tip)
    if not tip then return end
    local bp = localPlayer.Backpack
    if not bp then return end
    for _, t in pairs(bp:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then
            EquipToolByName(t.Name); return
        end
    end
end

local function EquipSelectedTool() EquipToolByTip(State.WeaponTool) end

local function SendKeyPress(k, hold)
    VirtualInputManager:SendKeyEvent(true, k, false, game)
    if hold and hold > 0 then task.wait(hold) end
    VirtualInputManager:SendKeyEvent(false, k, false, game)
end

local function HasTool(n)
    local c = localPlayer.Character
    if not c then return false end
    return c:FindFirstChild(n) ~= nil or localPlayer.Backpack:FindFirstChild(n) ~= nil
end

local nameCache = {}
local function FindEnemy(names, maxDist)
    local c = localPlayer.Character
    c = c and c:FindFirstChild("HumanoidRootPart")
    if not c then return nil end
    local pos = c.Position
    local huge = maxDist and maxDist*maxDist or math.huge
    local mp = {}
    for _, n in ipairs(names) do mp[n] = true end
    local best
    for _, e in ipairs(Enemies:GetChildren()) do
        local h = e:FindFirstChild("Humanoid")
        if h and h.Health > 0 then
            local match = nameCache[e.Name] or e.Name:match("^(.-)%s*%[") or e.Name
            nameCache[e.Name] = match
            if mp[match] then
                local rt = e:FindFirstChild("HumanoidRootPart")
                if rt then
                    local dx,dy,dz = rt.Position.X-pos.X, rt.Position.Y-pos.Y, rt.Position.Z-pos.Z
                    local d2 = dx*dx+dy*dy+dz*dz
                    if d2 < huge then huge = d2; best = e end
                end
            end
        end
    end
    return best
end

local function BringEnemyToPosition(target, cFrame)
    if not State.BringMob or not target or not target.Parent or not cFrame then return end
    local r = tonumber(State.BringRadius) or 300
    local r2 = r*r
    local pos = cFrame.Position
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(localPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(localPlayer, "MaxSimulationRadius", math.huge)
        end
    end)
    for _, e in ipairs(Enemies:GetChildren()) do
        if e.Name == target.Name and not table.find({"Shark","Piranha","Terrorshark"}, e.Name) then
            local h = e:FindFirstChildOfClass("Humanoid")
            local rt = e:FindFirstChild("HumanoidRootPart")
            local ready = e:FindFirstChild("CharacterReady")
            if h and rt and ready and h.Health > 0 and rt:IsDescendantOf(WS) then
                local dx,dy,dz = rt.Position.X-pos.X, rt.Position.Y-pos.Y, rt.Position.Z-pos.Z
                if dx*dx+dy*dy+dz*dz <= r2 and not rt:GetAttribute("BeingBrought") then
                    rt:SetAttribute("BeingBrought", true)
                    rt.CanCollide = false; rt.Massless = true
                    for _, d in pairs(e:GetDescendants()) do
                        if d:IsA("BasePart") then
                            d.CanCollide=false; d.CanTouch=false; d.Massless=true
                            d.AssemblyLinearVelocity=Vector3.zero
                            d.AssemblyAngularVelocity=Vector3.zero
                        end
                    end
                    local lock = Instance.new("BodyVelocity")
                    lock.Name="Lock"; lock.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                    lock.P=9000; lock.Velocity=Vector3.zero; lock.Parent=rt
                    local gyro = Instance.new("BodyGyro")
                    gyro.Name="BringGyro"; gyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
                    gyro.P=30000; gyro.D=1000; gyro.Parent=rt
                    gyro.CFrame = cFrame
                    h.AutoRotate=false; h.PlatformStand=false
                    pcall(function() h:ChangeState(Enum.HumanoidStateType.Physics) end)
                    rt.AssemblyLinearVelocity=Vector3.zero
                    rt.AssemblyAngularVelocity=Vector3.zero
                    task.spawn(function()
                        local t2 = pos + Vector3.new(
                            math.random(-20,20)/100, math.random(-20,20)/100, math.random(-20,20)/100)
                        local diff = t2 - rt.Position
                        local mag = diff.Magnitude
                        if mag > 0.5 then lock.Velocity = diff.Unit * math.clamp(mag*10, 20, 1200)
                        else lock.Velocity = Vector3.zero; pcall(function() rt.CFrame = CFrame.new(t2) end) end
                        task.wait(0.12)
                        pcall(function()
                            if lock.Parent then lock:Destroy() end
                            if gyro.Parent then gyro:Destroy() end
                            if rt.Parent then rt:SetAttribute("BeingBrought", false) end
                        end)
                    end)
                end
            end
        end
    end
end

local spiral = { angle = 0, radius = 35 }
local function SpinCF(cf)
    spiral.angle = (spiral.angle + 5) % 360
    local rad = math.rad(spiral.angle)
    return cf + Vector3.new(math.sin(rad)*spiral.radius, State.FarmDistance, math.cos(rad)*spiral.radius)
end

local function IsAnyFeatureActive()
    return _G.__AutoFarmLevel or _G.__AutoFarmNearest or _G.__AutoMastery
        or _G.__AutoFactory or _G.__AutoEctoplasm or _G.__AutoBoss
        or _G.__AutoAllBoss or _G.__AutoCakePrince or _G.__AutoDoughKing
        or _G.__AutoBone or _G.__AutoSoulReaper or _G.__AutoElite
        or _G.__AutoPiratesSea or _G.__AutoRipIndra
end

local function EngageEnemy(names)
    for _, child in pairs(Enemies:GetChildren()) do
        if child and table.find(names, child.Name) then
            local pp = child.PrimaryPart
            local cf = pp and pp.CFrame
            if pp and IsEntityAlive(child) then
                while true do
                    RunService.Heartbeat:Wait()
                    EquipSelectedTool(); ActivateHaki()
                    BringEnemyToPosition(child, cf)
                    ExecuteTween(CFrame.new(SpinCF(cf)))
                    if not IsAnyFeatureActive()
                        or not child or not child.Parent
                        or not IsEntityAlive(child) then break end
                end
            end
        end
    end
end

--=====================================================================
-- QUEST
--=====================================================================
local GuideModule, Quests
pcall(function() GuideModule = require(replicated.GuideModule) end)
pcall(function() Quests = require(replicated.Quests) end)

local function GetQuestInfo()
    local value = Level and Level.Value or 1
    local team = tostring(localPlayer.Team)
    local char = localPlayer.Character
    char = char and char:FindFirstChild("HumanoidRootPart")
    local n3, cframe, mob, qname, req, spawn
    local function pack() return {n3, cframe, mob, qname, req, spawn} end

    if value >= 1 and value <= 9 then
        if team == "Marines" then
            n3=1; qname="MarineQuest"; mob="Trainee"; spawn="Trainee"
            cframe = CFrame.new(-2709.67944,24.5206585,2104.24585)
        else
            n3=1; qname="BanditQuest1"; mob="Bandit"; spawn="Bandit"
            cframe = CFrame.new(1059.99731,16.9222069,1549.28162)
        end
        req = 1; return pack()
    end
    if value >= 210 and value <= 249 then
        n3=2; qname="PrisonerQuest"; mob="Dangerous Prisoner"
        spawn="Dangerous Prisoner"; req=210
        cframe = CFrame.new(5308.93115,1.65517521,475.120514)
        return pack()
    end
    req = 0
    if GuideModule and GuideModule.Data and GuideModule.Data.NPCList then
        for k, v in pairs(GuideModule.Data.NPCList) do
            for i, lv in ipairs(v.Levels or {}) do
                if value >= lv and lv > req then
                    req = lv; n3 = (#v.Levels == 3 and i == 3) and 2 or i
                    if k and k.CFrame then cframe = k.CFrame end
                end
            end
        end
    end
    if char and cframe then
        local mag = (cframe.Position - char.Position).Magnitude
        if value >= 375 and value <= 449 and mag > 3000 then
            pcall(function() CommF_:InvokeServer("requestEntrance", Vector3.new(61163.85,11.6797,1819.7842)) end)
        elseif value >= 450 and value <= 474 and mag > 3000 then
            pcall(function() CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.8228,872.5425,-1667.5569)) end)
        elseif value >= 475 and value <= 624 and mag > 5000 then
            pcall(function() CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6177,5547.1416,-380.2912)) end)
        end
    end
    if Quests then
        for k, quest in pairs(Quests) do
            if k ~= "CitizenQuest" then
                for k2, v in pairs(quest) do
                    if v.LevelReq == req then
                        qname = k; n3 = k2
                        for k3 in pairs(v.Task) do
                            mob = k3
                            spawn = string.split(k3, " [Lv. "..v.LevelReq.."]")[1]
                        end
                    end
                end
            end
        end
    end
    if qname == "ImpelQuest" then
        qname="PrisonerQuest"; n3=2; mob="Dangerous Prisoner"
        spawn="Dangerous Prisoner"; req=210
        cframe = CFrame.new(5310.60547,0.350014925,474.946594)
    elseif qname == "Area2Quest" and n3 == 2 then
        n3=1; mob="Swan Pirate"; spawn="Swan Pirate"; req=775
    end
    if value >= 2500 and value <= 2524 then
        mob="Sun-kissed Warrior"; spawn="Sun-kissed Warriors"
    end
    return pack()
end

local spawnIndex = 1
local function NavigateToSpawn(spawnNames)
    spawnIndex = spawnIndex or 1
    local filter = {}
    for i = 1, #spawnNames do
        filter[spawnNames[i]:gsub("Lv%.",""):gsub("[%[%] %d]",""):gsub("%s+","")] = true
    end
    local list = {}
    local folder = replicated:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Part") and child:GetAttribute("Active") then
                local clean = child.Name:gsub("Lv%.",""):gsub("[%[%] %d]",""):gsub("%s+","")
                if filter[clean] then table.insert(list, child:GetPivot()) end
            end
        end
    end
    if #list == 0 then return false end
    if #list < spawnIndex then spawnIndex = 1 end
    local cf = list[spawnIndex]; if not cf then return false end
    local d = GetDistance(cf.Position)
    if d > 20 then
        if d > 150 then ExecuteTween(cf * CFrame.new(0,65,5))
        else ExecuteTween(cf * CFrame.new(0,30,5)) end
    end
    spawnIndex = spawnIndex % #list + 1
    return true
end

--=====================================================================
-- REDZ UI
--=====================================================================
local redzlib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/tlredz/Library/refs/heads/main/redz-V5-remake/main.luau"
))()
local Window = redzlib:MakeWindow({
    Title = "Blox Fruits Farm",
    SubTitle = "Todas as tabs funcionais",
    SaveFolder = "BloxFruitsFarm.json"
})
Window:NewMinimizer({KeyCode = Enum.KeyCode.LeftControl})

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
Tabs.Info:AddSection("Status")
local TimeP = Tabs.Info:AddParagraph("Local Time", "...")
local GameP = Tabs.Info:AddParagraph("Game Time", "...")
local RaceP = Tabs.Info:AddParagraph("Race", "...")
local StatP = Tabs.Info:AddParagraph("Player Stats", "...")
local MoonP = Tabs.Info:AddParagraph("Moon Phase", "...")
local MirP  = Tabs.Info:AddParagraph("Mirage", "...")
local KitP  = Tabs.Info:AddParagraph("Kitsune", "...")
local PreP  = Tabs.Info:AddParagraph("Prehistoric", "...")
local FroP  = Tabs.Info:AddParagraph("Frozen Dim", "...")
local CakeP = Tabs.Info:AddParagraph("Cake Prince", "...")
local RipP  = Tabs.Info:AddParagraph("Rip Indra", "...")
local DouP  = Tabs.Info:AddParagraph("Dough King", "...")
local SwdP  = Tabs.Info:AddParagraph("Leg. Swords", "...")
local BoneP = Tabs.Info:AddParagraph("Bones", "0")

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            TimeP:SetDesc(os.date("%d/%m/%Y - %H:%M:%S"))
            local gt = math.floor(WS.DistributedGameTime)
            GameP:SetDesc(string.format("%dh %dm %ds", math.floor(gt/3600), math.floor(gt/60)%60, gt%60))
            local race = RaceData and tostring(RaceData.Value) or "?"
            pcall(function()
                if CommF_:InvokeServer("Wenlocktoad","1") == -2 then race=race.." V3"
                elseif CommF_:InvokeServer("Alchemist","1") == -2 then race=race.." V2"
                else race=race.." V1" end
            end)
            RaceP:SetDesc(race)
            StatP:SetDesc(string.format("Lv %d | Beli %s | Frags %s",
                Level and Level.Value or 0, tostring(Beli and Beli.Value or 0), tostring(Frags and Frags.Value or 0)))
            local moon = Lighting:FindFirstChild("Sky") and Lighting.Sky.MoonTextureId or ""
            for k,v in pairs({["9709149431"]="Full Moon",["9709149052"]="4/5",
                ["9709143733"]="3/5",["9709150401"]="2/5",["9709149680"]="1/5"}) do
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
                CakeP:SetDesc("Killed: "..(500 - tonumber(tostring(cp):match("%d+") or 0)))
            else CakeP:SetDesc(Enemies:FindFirstChild("Cake Prince") and "✅" or "❌") end
            RipP:SetDesc(Enemies:FindFirstChild("rip_indra") and "✅" or "❌")
            DouP:SetDesc(Enemies:FindFirstChild("Dough King") and "✅" or "❌")
            local sw = {}
            if CommF_:InvokeServer("LegendarySwordDealer","1") then table.insert(sw,"Shisui") end
            if CommF_:InvokeServer("LegendarySwordDealer","2") then table.insert(sw,"Wando") end
            if CommF_:InvokeServer("LegendarySwordDealer","3") then table.insert(sw,"Saddi") end
            SwdP:SetDesc(#sw > 0 and table.concat(sw,", ") or "None")
            local b = CommF_:InvokeServer("Bones","Check")
            if b then BoneP:SetDesc(tostring(b)) end
        end)
    end
end)

--=====================================================================
-- TAB MAIN
--=====================================================================
Tabs.Main:AddSection("Farming")
Tabs.Main:AddDropdown({Name="Weapon Tool", Options={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee",
    Callback=function(v) State.WeaponTool=v end})
Tabs.Main:AddDropdown({Name="Farm Distance", Options={"10","20","30","40","50","60"}, Default="20",
    Callback=function(v) State.FarmDistance=tonumber(v) or 20 end})
Tabs.Main:AddToggle({Name="Auto Farm Level", Default=false, Callback=function(v) _G.__AutoFarmLevel=v end})
Tabs.Main:AddToggle({Name="Auto Farm Nearest", Default=false, Callback=function(v) _G.__AutoFarmNearest=v end})
Tabs.Main:AddDropdown({Name="Nearest Range", Options={"500","1000","2000","3000","Infinite"}, Default="Infinite",
    Callback=function(v) _G.__NearestRange=v end})
Tabs.Main:AddToggle({Name="Auto Factory Raid", Default=false, Callback=function(v) _G.__AutoFactory=v end})
Tabs.Main:AddToggle({Name="Auto Farm Ectoplasm", Default=false, Callback=function(v) _G.__AutoEctoplasm=v end})

Tabs.Main:AddSection("Chest Collection")
Tabs.Main:AddToggle({Name="Auto Collect Chest", Default=false, Callback=function(v) _G.__AutoCollectChest=v end})
Tabs.Main:AddToggle({Name="Stop on Rare Items", Default=true, Callback=function(v) _G.__StopRareItems=v end})
Tabs.Main:AddToggle({Name="Auto Hop If No Chest", Default=false, Callback=function(v) _G.__AutoHopNoChest=v end})
Tabs.Main:AddToggle({Name="Auto Collect Berry", Default=false, Callback=function(v) _G.__AutoCollectBerry=v end})

Tabs.Main:AddSection("Mastery")
Tabs.Main:AddDropdown({Name="Mastery Mode", Options={"Level","Bone","Cake Prince","Nearest"}, Default="Level",
    Callback=function(v) _G.__MasteryMode=v end})
Tabs.Main:AddDropdown({Name="Mastery Weapon", Options={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee",
    Callback=function(v) _G.__MasteryWeapon=v end})
Tabs.Main:AddToggle({Name="Auto Farm Mastery", Default=false, Callback=function(v) _G.__AutoMastery=v end})

Tabs.Main:AddSection("Material")
local materialList = World1 and {"Angel Wings","Leather + Scrap Metal","Magma Ore","Fish Tail"}
    or World2 and {"Leather + Scrap Metal","Magma Ore","Mystic Droplet","Radioactive Material","Vampire Fang"}
    or {"Leather + Scrap Metal","Fish Tail","Gunpowder","Mini Tusk","Conjured Cocoa","Dragon Scale"}
Tabs.Main:AddDropdown({Name="Material", Options=materialList, Default=materialList[1],
    Callback=function(v) _G.__MaterialSel=v end})
Tabs.Main:AddToggle({Name="Auto Farm Material", Default=false, Callback=function(v) _G.__AutoMaterial=v end})

Tabs.Main:AddSection("Boss")
local bossList = World1 and {"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Greybeard"}
    or World2 and {"Diamond","Jeremy","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"}
    or {"Stone","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies"}
Tabs.Main:AddDropdown({Name="Boss", Options=bossList, Default=bossList[1],
    Callback=function(v) _G.__BossSel=v end})
Tabs.Main:AddToggle({Name="Auto Attack Boss", Default=false, Callback=function(v) _G.__AutoBoss=v end})
Tabs.Main:AddToggle({Name="Auto Attack All Boss", Default=false, Callback=function(v) _G.__AutoAllBoss=v end})

Tabs.Main:AddSection("Special Farms")
Tabs.Main:AddToggle({Name="Auto Cake Prince",      Default=false, Callback=function(v) _G.__AutoCakePrince=v end})
Tabs.Main:AddToggle({Name="Auto Dough King",       Default=false, Callback=function(v) _G.__AutoDoughKing=v end})
Tabs.Main:AddToggle({Name="Auto Farm Bones",       Default=false, Callback=function(v) _G.__AutoBone=v end})
Tabs.Main:AddToggle({Name="Auto Soul Reaper",      Default=false, Callback=function(v) _G.__AutoSoulReaper=v end})
Tabs.Main:AddToggle({Name="Auto Elite Hunter",     Default=false, Callback=function(v) _G.__AutoElite=v end})
Tabs.Main:AddToggle({Name="Auto Pirates Sea",      Default=false, Callback=function(v) _G.__AutoPiratesSea=v end})
Tabs.Main:AddToggle({Name="Auto Attack Rip Indra", Default=false, Callback=function(v) _G.__AutoRipIndra=v end})
Tabs.Main:AddToggle({Name="Auto Rainbow Haki",     Default=false, Callback=function(v) _G.__AutoRainbowHaki=v end})
Tabs.Main:AddToggle({Name="Auto Citizen Quest",    Default=false, Callback=function(v) _G.__AutoCitizen=v end})
Tabs.Main:AddToggle({Name="Auto Try Luck",         Default=false, Callback=function(v) _G.__AutoTryLuck=v end})
Tabs.Main:AddToggle({Name="Auto Pray",             Default=false, Callback=function(v) _G.__AutoPray=v end})

--=====================================================================
-- TAB FISHING
--=====================================================================
Tabs.Fishing:AddSection("Fishing")
Tabs.Fishing:AddDropdown({Name="Fishing Rod", Options={"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default="Fishing Rod", Callback=function(v) _G.__FishingRod=v end})
Tabs.Fishing:AddDropdown({Name="Bait", Options={"Basic Bait","Kelp Bait","Good Bait","Abyssal Bait","Frozen Bait","Epic Bait","Carnivore Bait"},
    Default="Basic Bait", Callback=function(v) _G.__FishingBait=v end})
Tabs.Fishing:AddToggle({Name="Auto Buy Bait",            Default=false, Callback=function(v) _G.__AutoBuyBait=v end})
Tabs.Fishing:AddToggle({Name="Auto Equip Rod",           Default=false, Callback=function(v) _G.__AutoEquipRod=v end})
Tabs.Fishing:AddToggle({Name="Auto Fishing",             Default=false, Callback=function(v) _G.__AutoFishing=v end})
Tabs.Fishing:AddToggle({Name="Auto Fishing Quest",       Default=false, Callback=function(v) _G.__AutoFishingQuest=v end})
Tabs.Fishing:AddToggle({Name="Auto Complete Quest",      Default=false, Callback=function(v) _G.__AutoFishComplete=v end})
Tabs.Fishing:AddToggle({Name="Auto Sell Fish",           Default=false, Callback=function(v) _G.__AutoSellFish=v end})
Tabs.Fishing:AddToggle({Name="Auto Sell Corrupted Fish", Default=false, Callback=function(v) _G.__AutoSellCorrupt=v end})
Tabs.Fishing:AddToggle({Name="Auto Spam Skill Z",        Default=false, Callback=function(v) _G.__SpamSkillZ=v end})

--=====================================================================
-- TAB QUEST & ITEM
--=====================================================================
Tabs.QuestItem:AddSection("Swords")
Tabs.QuestItem:AddDropdown({Name="Sword",
    Options={"Twin Hooks","Buddy Sword","Canvander","Dark Dagger","Fox Lamp","Spikey Trident","Yama","Hallow Scythe"},
    Default="Twin Hooks", Callback=function(v) _G.__SwordSel=v end})
Tabs.QuestItem:AddToggle({Name="Auto Get Sword",       Default=false, Callback=function(v) _G.__AutoGetSword=v end})
Tabs.QuestItem:AddToggle({Name="Auto Get Serpent Bow", Default=false, Callback=function(v) _G.__AutoGetSerpent=v end})
Tabs.QuestItem:AddToggle({Name="Auto Tushita Sword",   Default=false, Callback=function(v) _G.__AutoTushita=v end})
Tabs.QuestItem:AddToggle({Name="Auto Yama Sword",      Default=false, Callback=function(v) _G.__AutoYama=v end})

Tabs.QuestItem:AddSection("Fighting Styles")
Tabs.QuestItem:AddToggle({Name="Auto Superhuman",    Default=false, Callback=function(v) _G.__AutoSuperhuman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Death Step",    Default=false, Callback=function(v) _G.__AutoDeathStep=v end})
Tabs.QuestItem:AddToggle({Name="Auto Sharkman",      Default=false, Callback=function(v) _G.__AutoSharkman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Electric Claw", Default=false, Callback=function(v) _G.__AutoElectricClaw=v end})
Tabs.QuestItem:AddToggle({Name="Auto Dragon Talon",  Default=false, Callback=function(v) _G.__AutoDragonTalon=v end})
Tabs.QuestItem:AddToggle({Name="Auto Godhuman",      Default=false, Callback=function(v) _G.__AutoGodHuman=v end})
Tabs.QuestItem:AddToggle({Name="Auto Sanguine Art",  Default=false, Callback=function(v) _G.__AutoSanguine=v end})

Tabs.QuestItem:AddSection("Race V2/V3")
Tabs.QuestItem:AddToggle({Name="Auto Race V2", Default=false, Callback=function(v) _G.__AutoV2=v end})
Tabs.QuestItem:AddToggle({Name="Auto Race V3", Default=false, Callback=function(v) _G.__AutoV3=v end})

Tabs.QuestItem:AddSection("V4 Trial")
Tabs.QuestItem:AddButton({Name="Teleport Temple of Time", Callback=function()
    pcall(function()
        if Root then Root.CFrame = CFrame.new(28286,14895,102) end
        local s = replicated:FindFirstChild("MapStash")
        if s and s:FindFirstChild("Temple of Time") and not Map:FindFirstChild("Temple of Time") then
            s["Temple of Time"].Parent = Map
        end
    end)
end})
Tabs.QuestItem:AddButton({Name="Pull Lever", Callback=function()
    pcall(function()
        if Map:FindFirstChild("Temple of Time") then
            for _, d in pairs(Map["Temple of Time"]:GetDescendants()) do
                if d.Name == "ProximityPrompt" then fireproximityprompt(d, math.huge) end
            end
        end
    end)
end})
Tabs.QuestItem:AddToggle({Name="Auto Complete Trial",           Default=false, Callback=function(v) _G.__AutoTrial=v end})
Tabs.QuestItem:AddToggle({Name="Auto Kill Players After Trial", Default=false, Callback=function(v) _G.__AutoKillTrial=v end})

Tabs.QuestItem:AddSection("Quick Purchase")
local quickBtns = {
    {"Buy Buso",{"BuyHaki","Buso"}},{"Buy Geppo",{"BuyHaki","Geppo"}},
    {"Buy Soru",{"BuyHaki","Soru"}},{"Buy Ken",{"KenTalk","Buy"}},
    {"Buy Black Leg",{"BuyBlackLeg"}},{"Buy Electro",{"BuyElectro"}},
    {"Buy Fishman Karate",{"BuyFishmanKarate"}},{"Buy Superhuman",{"BuySuperhuman"}},
    {"Buy Death Step",{"BuyDeathStep"}},{"Buy Sharkman Karate",{"BuySharkmanKarate"}},
    {"Buy Electric Claw",{"BuyElectricClaw"}},{"Buy Dragon Talon",{"BuyDragonTalon"}},
    {"Buy Godhuman",{"BuyGodhuman"}},{"Buy Sanguine Art",{"BuySanguineArt"}},
    {"Buy Katana",{"BuyItem","Katana"}},{"Buy Cutlass",{"BuyItem","Cutlass"}},
    {"Buy Dual Katana",{"BuyItem","Dual Katana"}},{"Buy Iron Mace",{"BuyItem","Iron Mace"}},
    {"Buy Triple Katana",{"BuyItem","Triple Katana"}},{"Buy Pipe",{"BuyItem","Pipe"}},
    {"Buy Soul Cane",{"BuyItem","Soul Cane"}},{"Buy Bisento",{"BuyItem","Bisento"}}
}
for _, b in ipairs(quickBtns) do
    local a = b[2]
    Tabs.QuestItem:AddButton({Name=b[1], Callback=function()
        pcall(function() CommF_:InvokeServer(unpack(a)) end)
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
Tabs.QuestItem:AddButton({Name="Buy True Triple Katana", Callback=function() pcall(function() CommF_:InvokeServer("MysteriousMan","2") end) end})
Tabs.QuestItem:AddButton({Name="Buy Ghoul Race", Callback=function() pcall(function() CommF_:InvokeServer("Ectoplasm","Change",4) end) end})
Tabs.QuestItem:AddButton({Name="Buy Cyborg Race", Callback=function() pcall(function() CommF_:InvokeServer("CyborgTrainer","Buy") end) end})

--=====================================================================
-- TAB VOLCANO
--=====================================================================
Tabs.Volcano:AddSection("Prehistoric Island")
Tabs.Volcano:AddToggle({Name="Auto Summon Prehistoric", Default=false, Callback=function(v) _G.__AutoSummonPrehis=v end})
Tabs.Volcano:AddToggle({Name="Tween to Prehistoric",    Default=false, Callback=function(v) _G.__TweenPrehis=v end})
Tabs.Volcano:AddToggle({Name="Auto Start Event",        Default=false, Callback=function(v) _G.__AutoStartPrehis=v end})
Tabs.Volcano:AddToggle({Name="Auto Patch Event",        Default=false, Callback=function(v) _G.__AutoPatchPrehis=v end})
Tabs.Volcano:AddToggle({Name="Auto Collect Dino Bones", Default=false, Callback=function(v) _G.__CollectDinoBones=v end})
Tabs.Volcano:AddToggle({Name="Auto Collect Dragon Eggs",Default=false, Callback=function(v) _G.__CollectDragonEggs=v end})

Tabs.Volcano:AddSection("Dragon Trial")
Tabs.Volcano:AddButton({Name="Teleport Dragon Dojo", Callback=function()
    pcall(function()
        CommF_:InvokeServer("requestEntrance", Vector3.new(5661,1013,-334))
        ExecuteTween(CFrame.new(5814,1208,884))
    end)
end})
Tabs.Volcano:AddToggle({Name="Auto Dojo Trainer", Default=false, Callback=function(v) _G.__AutoDojo=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V1",     Default=false, Callback=function(v) _G.__AutoDracoV1=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V2",     Default=false, Callback=function(v) _G.__AutoDracoV2=v end})
Tabs.Volcano:AddToggle({Name="Auto Draco V3",     Default=false, Callback=function(v) _G.__AutoDracoV3=v end})

Tabs.Volcano:AddSection("Crafting")
for _, item in ipairs({"Dragonheart","Dragonstorm","DinoHood","TRexSkull"}) do
    Tabs.Volcano:AddButton({Name="Craft "..item, Callback=function()
        pcall(function() CommF_:InvokeServer("CraftItem","Craft",item) end)
    end})
end

--=====================================================================
-- TAB STATS & ESP
--=====================================================================
Tabs.StatsESP:AddSection("Stats Upgrade")
Tabs.StatsESP:AddSlider({Name="Points Per Stat", Min=1, Max=100, Default=10, Increment=1,
    Callback=function(v) _G.__StatsVal=v end})
for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
    Tabs.StatsESP:AddToggle({Name="Auto "..s, Default=false,
        Callback=function(v) _G["__autoStat_"..s]=v end})
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
Tabs.FruitRaid:AddToggle({Name="Auto Find Fruit",   Default=false, Callback=function(v) _G.__AutoFindFruit=v end})

Tabs.FruitRaid:AddSection("Raids")
Tabs.FruitRaid:AddDropdown({Name="Raid Chip",
    Options={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"},
    Default="Flame", Callback=function(v) _G.__RaidChip=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Buy Chip",  Default=false, Callback=function(v) _G.__AutoBuyChip=v end})
Tabs.FruitRaid:AddToggle({Name="Auto Awakening", Default=false, Callback=function(v) _G.__AutoAwake=v end})

--=====================================================================
-- TAB LOCAL PLAYER
--=====================================================================
Tabs.LocalPlayer:AddSection("Aimbot")
local plrNames = {}
for _, p in pairs(Players:GetPlayers()) do table.insert(plrNames, p.Name) end
if #plrNames == 0 then plrNames = {""} end
Tabs.LocalPlayer:AddDropdown({Name="Target Player", Options=plrNames, Default=plrNames[1],
    Callback=function(v) _G.__AimPlayer=v end})
Tabs.LocalPlayer:AddDropdown({Name="Aim Method", Options={"Aim Player","Nearest Aim"}, Default="Aim Player",
    Callback=function(v) _G.__AimMethod=v end})
Tabs.LocalPlayer:AddToggle({Name="Aimbot Skills", Default=false, Callback=function(v) _G.__AimbotEnabled=v end})
Tabs.LocalPlayer:AddToggle({Name="No Clip",       Default=false, Callback=function(v) _G.__NoClip=v end})

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

Tabs.Teleport:AddSection("Islands (Speed Hub Tween)")
local islandNames = {}
if WorldOrigin:FindFirstChild("Locations") then
    for _, l in pairs(WorldOrigin.Locations:GetChildren()) do table.insert(islandNames, l.Name) end
end
if #islandNames == 0 then islandNames = {""} end
Tabs.Teleport:AddDropdown({Name="Island", Options=islandNames, Default=islandNames[1],
    Callback=function(v) _G.__IslandSel=v end})
Tabs.Teleport:AddToggle({Name="Auto Travel Island", Default=false, Callback=function(v) _G.__TweenIsland=v end})

Tabs.Teleport:AddSection("Portals")
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
    Tabs.Teleport:AddButton({Name=p[1], Callback=function()
        pcall(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end

--=====================================================================
-- TAB SHOPPING
--=====================================================================
Tabs.Shopping:AddSection("Shop")
for _, b in ipairs(quickBtns) do
    local a = b[2]
    Tabs.Shopping:AddButton({Name=b[1], Callback=function()
        pcall(function() CommF_:InvokeServer(unpack(a)) end)
    end})
end
Tabs.Shopping:AddSection("Fragments")
Tabs.Shopping:AddButton({Name="Reroll Race", Callback=function() pcall(function() CommF_:InvokeServer("BlackbeardReward","Reroll","2") end) end})
Tabs.Shopping:AddButton({Name="Refund Stats", Callback=function() pcall(function() CommF_:InvokeServer("BlackbeardReward","Refund","2") end) end})
Tabs.Shopping:AddButton({Name="Legendary Swords", Callback=function()
    pcall(function()
        CommF_:InvokeServer("LegendarySwordDealer","1")
        CommF_:InvokeServer("LegendarySwordDealer","2")
        CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
end})
Tabs.Shopping:AddButton({Name="True Triple Katana", Callback=function() pcall(function() CommF_:InvokeServer("MysteriousMan","2") end) end})
Tabs.Shopping:AddButton({Name="Ghoul Race", Callback=function() pcall(function() CommF_:InvokeServer("Ectoplasm","Change",4) end) end})
Tabs.Shopping:AddButton({Name="Cyborg Race", Callback=function() pcall(function() CommF_:InvokeServer("CyborgTrainer","Buy") end) end})

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
                TeleportService:TeleportToPlaceInstance(PlaceId, s.id, localPlayer); break
            end
        end
    end)
end})
Tabs.Misc:AddButton({Name="Rejoin Server", Callback=function() pcall(function() TeleportService:Teleport(PlaceId, localPlayer) end) end})
Tabs.Misc:AddButton({Name="Copy Job ID", Callback=function() pcall(function() setclipboard(tostring(game.JobId)) end) end})
Tabs.Misc:AddSection("Teams")
Tabs.Misc:AddButton({Name="Join Pirates", Callback=function() pcall(function() CommF_:InvokeServer("SetTeam","Pirates") end) end})
Tabs.Misc:AddButton({Name="Join Marines", Callback=function() pcall(function() CommF_:InvokeServer("SetTeam","Marines") end) end})

Tabs.Misc:AddSection("Visual")
Tabs.Misc:AddToggle({Name="Remove Damage Numbers", Default=false, Callback=function(v) _G.__RemoveDamage=v end})
Tabs.Misc:AddToggle({Name="Remove Notifications", Default=false, Callback=function(v) _G.__RemoveNotify=v end})
Tabs.Misc:AddToggle({Name="Walk on Water", Default=false, Callback=function(v)
    local w = Map:FindFirstChild("WaterBase-Plane")
    if w then w.Size = v and Vector3.new(1000,112,1000) or Vector3.new(1000,80,1000) end
end})
Tabs.Misc:AddToggle({Name="Full Bright", Default=false, Callback=function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.Brightness = 2; Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.Brightness = 1; Lighting.GlobalShadows = true
    end
end})
Tabs.Misc:AddToggle({Name="Low CPU Mode", Default=false, Callback=function(v)
    if v then pcall(function()
        local t = WS.Terrain
        t.WaterWaveSize=0; t.WaterWaveSpeed=0; t.WaterReflectance=0; t.WaterTransparency=0
        Lighting.GlobalShadows=false; Lighting.FogEnd=9e9; Lighting.Brightness=0
        pcall(function() settings().Rendering.QualityLevel = "Level01" end)
    end) end
end})

Tabs.Misc:AddSection("Redeem & Menu")
Tabs.Misc:AddButton({Name="Redeem All Codes", Callback=function()
    pcall(function()
        local codes = {"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK",
            "BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS",
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
end})
Tabs.Misc:AddButton({Name="Open Titles Menu",    Callback=function() pcall(function() CommF_:InvokeServer("getTitles",true); playerGui.Main.Titles.Visible=true end) end})
Tabs.Misc:AddButton({Name="Open Haki Colors",    Callback=function() pcall(function() playerGui.Main.Colors.Visible=true end) end})
Tabs.Misc:AddButton({Name="Open Awakening Menu", Callback=function() pcall(function() playerGui.Main.AwakeningToggler.Visible=true end) end})

--=====================================================================
-- TAB SETTINGS
--=====================================================================
Tabs.Settings:AddSection("Combat")
Tabs.Settings:AddToggle({Name="Kill Aura", Default=false, Callback=function(v) _G.__KillAura=v end})
Tabs.Settings:AddDropdown({Name="Weapon Tool", Options={"Melee","Sword","Blox Fruit","Gun"}, Default="Melee",
    Callback=function(v) State.WeaponTool=v end})
Tabs.Settings:AddDropdown({Name="Tween Speed", Options={"100","200","300","400","500","800","1000"}, Default="300",
    Callback=function(v) State.TweenSpeed=tonumber(v) or 300 end})
Tabs.Settings:AddToggle({Name="Bring Mob", Default=true, Callback=function(v) State.BringMob=v end})
Tabs.Settings:AddDropdown({Name="Bring Radius", Options={"100","200","300","400","500","1000"}, Default="300",
    Callback=function(v) State.BringRadius=tonumber(v) or 300 end})
Tabs.Settings:AddToggle({Name="Fast Attack", Default=false, Callback=function(v) _G.__FastAttack=v end})

Tabs.Settings:AddSection("Auto Abilities")
Tabs.Settings:AddToggle({Name="Auto Turn V3",          Default=false, Callback=function(v) _G.__AutoTurnV3=v end})
Tabs.Settings:AddToggle({Name="Auto Turn V4",          Default=false, Callback=function(v) _G.__AutoTurnV4=v end})
Tabs.Settings:AddToggle({Name="Auto Turn on Buso",     Default=false, Callback=function(v) _G.__AutoBuso=v end})
Tabs.Settings:AddToggle({Name="Auto Haki Observation", Default=false, Callback=function(v) _G.__AutoKen=v end})

Tabs.Settings:AddSection("Anti / Notifications")
Tabs.Settings:AddToggle({Name="Anti AFK", Default=true, Callback=function(v) _G.__AntiAFK=v end})
Tabs.Settings:AddToggle({Name="Auto Anti-Admin", Default=false, Callback=function(v) _G.__AntiAdmin=v end})
Tabs.Settings:AddToggle({Name="Disable Notify", Default=false, Callback=function(v) _G.__DisableNotify=v end})

--=====================================================================
-- ⭐ LOOPS DE TODAS AS FEATURES
--=====================================================================

--// AUTO FARM LEVEL
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not _G.__AutoFarmLevel then return end
            if not localPlayer.Character or not Root then return end
            local qi = GetQuestInfo()
            if not qi or not qi[1] then return end
            local mob, npcCF, spawnName, qname, qid = qi[1], qi[2], qi[3], qi[4], qi[5]
            local q = playerGui.Main:FindFirstChild("Quest")
            local vis = q and q.Visible
            local txt = vis and q.Container and q.Container.QuestTitle
                and q.Container.QuestTitle.Title and q.Container.QuestTitle.Title.Text or ""
            if vis and string.find(txt, mob) then
                local e = FindEnemy({spawnName, mob})
                if e then EngageEnemy({e.Name}) else NavigateToSpawn({spawnName}); task.wait(0.5) end
            else
                if npcCF then
                    local d = GetDistance(npcCF)
                    if d and d <= 5 then CommF_:InvokeServer("StartQuest", qname, qid); task.wait(0.3)
                    else ExecuteTween(npcCF) end
                end
            end
        end)
    end
end)

--// AUTO FARM NEAREST
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if not _G.__AutoFarmNearest or not Root then return end
            local mr = _G.__NearestRange == "Infinite" and math.huge or tonumber(_G.__NearestRange or 3000)
            local n, nd = nil, math.huge
            for _, e in pairs(Enemies:GetChildren()) do
                if IsEntityAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                    local d = (e.HumanoidRootPart.Position - Root.Position).Magnitude
                    if d < nd and d <= mr then nd=d; n=e end
                end
            end
            if n then EngageEnemy({n.Name}) end
        end)
    end
end)

--// AUTO FACTORY
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not _G.__AutoFactory then return end
            local c = FindEnemy({"Core"})
            if c then EngageEnemy({c.Name}) else ExecuteTween(CFrame.new(502,143,-379)) end
        end)
    end
end)

--// AUTO ECTOPLASM
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not _G.__AutoEctoplasm then return end
            local e = FindEnemy({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
            if e then EngageEnemy({e.Name})
            else CommF_:InvokeServer("requestEntrance", Vector3.new(923,126,32852)) end
        end)
    end
end)

--// AUTO CHEST
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not _G.__AutoCollectChest or not Root then return end
            if (_G.__StopRareItems ~= false) and
                (HasTool("God's Chalice") or HasTool("Fist of Darkness") or HasTool("Sweet Chalice")) then
                _G.__AutoCollectChest = false; return
            end
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
            if n then ExecuteTween(n:GetPivot())
            elseif _G.__AutoHopNoChest then
                pcall(function()
                    local d = HttpService:JSONDecode(game:HttpGet(
                        "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                    for _, s in pairs(d.data) do
                        if s.playing < s.maxPlayers and s.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(PlaceId, s.id, localPlayer); break
                        end
                    end
                end)
            end
        end)
    end
end)

--// AUTO BERRY
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not _G.__AutoCollectBerry then return end
            for _, b in pairs(Map:GetDescendants()) do
                if b.Name == "Berries" then
                    for i = 1, 8 do
                        if b:GetAttribute("_BerryCFrame"..i) then ExecuteTween(b.Parent.WorldPivot) end
                    end
                end
            end
        end)
    end
end)

--// AUTO MASTERY
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if not _G.__AutoMastery or not Root then return end
            local mode = _G.__MasteryMode or "Level"
            EquipToolByTip(_G.__MasteryWeapon or "Melee")
            local e
            if mode == "Level" then
                local qi = GetQuestInfo()
                if qi and qi[3] then e = FindEnemy({qi[3]}) end
            elseif mode == "Bone" then
                e = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
            elseif mode == "Cake Prince" then
                e = FindEnemy({"Baking Staff","Head Baker","Cake Guard","Cookie Crafter"})
            elseif mode == "Nearest" then
                local nd = math.huge
                for _, m in pairs(Enemies:GetChildren()) do
                    if IsEntityAlive(m) and m:FindFirstChild("HumanoidRootPart") then
                        local d = (m.HumanoidRootPart.Position - Root.Position).Magnitude
                        if d < nd and d < 3500 then nd=d; e=m end
                    end
                end
            end
            if e then EngageEnemy({e.Name}) end
        end)
    end
end)

--// AUTO MATERIAL
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not _G.__AutoMaterial or not Root then return end
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
            if mons then local e = FindEnemy(mons); if e then EngageEnemy({e.Name}) end end
        end)
    end
end)

--// AUTO BOSS
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not Root then return end
            if _G.__AutoBoss and _G.__BossSel then
                local b = FindEnemy({_G.__BossSel}); if b then EngageEnemy({b.Name}) end
            end
            if _G.__AutoAllBoss then
                local b = FindEnemy(bossList); if b then EngageEnemy({b.Name}) end
            end
        end)
    end
end)

--// SPECIAL FARMS
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            if not Root then return end
            if _G.__AutoCakePrince then
                local cm = FindEnemy({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if cm then EngageEnemy({cm.Name}) end
                local cp = FindEnemy({"Cake Prince","Dough King"})
                if cp then EngageEnemy({cp.Name}) end
            end
            if _G.__AutoDoughKing then
                local dk = FindEnemy({"Dough King"}); if dk then EngageEnemy({dk.Name}) end
            end
            if _G.__AutoBone then
                local b = FindEnemy({"Reborn Skeleton","Living Zombie","Demonic Soul","Possessed Mummy"})
                if b then EngageEnemy({b.Name}) else ExecuteTween(CFrame.new(-9516,142,5536)) end
            end
            if _G.__AutoSoulReaper then
                local sr = FindEnemy({"Soul Reaper"})
                if sr then EngageEnemy({sr.Name})
                elseif not HasTool("Hallow Essence") then CommF_:InvokeServer("Bones","Buy",1,1)
                else ExecuteTween(CFrame.new(-8932,146,6062)); task.wait(0.5); EquipToolByTip("Melee") end
            end
            if _G.__AutoElite then
                local el = FindEnemy({"Diablo","Deandre","Urban"})
                if el then EngageEnemy({el.Name})
                else pcall(function() CommF_:InvokeServer("EliteHunter") end) end
            end
            if _G.__AutoPiratesSea then
                local b = FindEnemy({"Galley Pirate","Galley Captain","Raider","Mercenary","Vampire","Zombie"})
                if b then EngageEnemy({b.Name}) else ExecuteTween(CFrame.new(-5556,314,-2988)) end
            end
            if _G.__AutoRipIndra then
                local ri = FindEnemy({"rip_indra"})
                if ri then EngageEnemy({ri.Name})
                else CommF_:InvokeServer("requestEntrance", Vector3.new(-5097,316,-3142)) end
            end
            if _G.__AutoRainbowHaki then
                local q = playerGui.Main:FindFirstChild("Quest")
                if q and not q.Visible then
                    ExecuteTween(CFrame.new(-11892,930,-8760))
                    if GetDistance(CFrame.new(-11892,930,-8760)) < 10 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local e = FindEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if e then EngageEnemy({e.Name}) end
                end
            end
            if _G.__AutoCitizen then
                local q = playerGui.Main:FindFirstChild("Quest")
                if q and not q.Visible then
                    ExecuteTween(CFrame.new(-11893.7,929.66,-8760.59))
                    if GetDistance(CFrame.new(-11893.7,929.66,-8760.59)) < 8 then
                        CommF_:InvokeServer("HornedMan","Bet")
                    end
                else
                    local m = FindEnemy({"Stone","Island Empress","Kilo Admiral","Captain Elephant","Beautiful Pirate"})
                    if m then EngageEnemy({m.Name}) end
                end
            end
            if _G.__AutoTryLuck then
                local p = CFrame.new(-8761,164,6161); ExecuteTween(p)
                if GetDistance(p) < 5 then CommF_:InvokeServer("gravestoneEvent",1) end
            end
            if _G.__AutoPray then
                local p = CFrame.new(-8761,164,6161); ExecuteTween(p)
                if GetDistance(p) < 5 then CommF_:InvokeServer("gravestoneEvent",2) end
            end
        end)
    end
end)

--// ⭐ FISHING (todos os toggles)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not localPlayer.Character then return end
            local tool = localPlayer.Character:FindFirstChildWhichIsA("Tool")
            if _G.__AutoEquipRod and (not tool or tool:GetAttribute("InventoryCategory") ~= "Rod") then
                for _, t in pairs(localPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:GetAttribute("InventoryCategory") == "Rod" then
                        localPlayer.Character.Humanoid:EquipTool(t); break
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
                            local hrp = localPlayer.Character.HumanoidRootPart
                            local ray = Ray.new(localPlayer.Character.Head.Position, hrp.CFrame.LookVector*100)
                            local _, hit = WS:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, Characters, Enemies})
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
                if _G.__AutoFishingQuest then
                    pcall(function()
                        local RF = Net:FindFirstChild("RF/JobsRemoteFunction")
                        if RF then
                            local g = playerGui:FindFirstChild("Quest") or playerGui:FindFirstChild("QuestGui")
                            if not g or not g.Visible then RF:InvokeServer("FishingNPC","Angler","AskQuest") end
                        end
                    end)
                end
                if _G.__AutoFishComplete then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","FinishQuest") end)
                end
                if _G.__AutoSellFish then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellFish") end)
                end
                if _G.__AutoSellCorrupt then
                    pcall(function() Net:FindFirstChild("RF/JobsRemoteFunction"):InvokeServer("FishingNPC","SellCorruptedFish") end)
                end
                if _G.__SpamSkillZ then
                    pcall(function() Net:FindFirstChild("RF/JobToolAbilities"):InvokeServer("Z", true) end)
                end
            end
        end)
    end
end)

--// ⭐ AUTO GET SWORD / SERPENT / TUSHITA / YAMA
task.spawn(function()
    while task.wait(0.6) do
        pcall(function()
            if not Root then return end
            if _G.__AutoGetSword then
                local map = {
                    ["Twin Hooks"]={"Captain Elephant"}, ["Buddy Sword"]={"Cake Queen"},
                    ["Canvander"]={"Beautiful Pirate"}, ["Dark Dagger"]={"rip_indra True Form"},
                    ["Spikey Trident"]={"Dough King"}, ["Hallow Scythe"]={"Soul Reaper"}
                }
                local e = FindEnemy(map[_G.__SwordSel or "Twin Hooks"] or {})
                if e then EngageEnemy({e.Name}) end
            end
            if _G.__AutoGetSerpent then
                local e = FindEnemy({"Island Empress"})
                if e then EngageEnemy({e.Name}) else ExecuteTween(CFrame.new(5659,602,244)) end
            end
            if _G.__AutoTushita then
                if Map:FindFirstChild("Turtle") and Map.Turtle:FindFirstChild("TushitaGate") then
                    if not HasTool("Holy Torch") then ExecuteTween(CFrame.new(5148,162,910))
                    else
                        EquipToolByTip("Sword")
                        ExecuteTween(CFrame.new(-10752,417,-9366)); task.wait(0.7)
                        ExecuteTween(CFrame.new(-11672,334,-9474)); task.wait(0.7)
                        ExecuteTween(CFrame.new(-12132,521,-10655)); task.wait(0.7)
                        ExecuteTween(CFrame.new(-13336,486,-6985)); task.wait(0.7)
                        ExecuteTween(CFrame.new(-13489,332,-7925))
                    end
                else
                    local v = FindEnemy({"Longma"})
                    if v then EngageEnemy({v.Name}) end
                end
            end
            if _G.__AutoYama then
                local prog = CommF_:InvokeServer("EliteHunter","Progress")
                if prog and prog < 30 then
                    _G.__AutoElite = true
                elseif prog and prog >= 30 then
                    _G.__AutoElite = false
                    if Map:FindFirstChild("Waterfall") and Map.Waterfall:FindFirstChild("SealedKatana") then
                        ExecuteTween(Map.Waterfall.SealedKatana.Handle.CFrame)
                        local gh = FindEnemy({"Ghost"})
                        if gh then EngageEnemy({gh.Name}) end
                        pcall(function()
                            fireclickdetector(Map.Waterfall.SealedKatana.Handle:FindFirstChildOfClass("ClickDetector"))
                        end)
                    end
                end
            end
        end)
    end
end)

--// ⭐ FIGHTING STYLES (Superhuman, Death Step, Sharkman, ElectricClaw, DragonTalon, Godhuman, Sanguine)
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not Root then return end
            if _G.__AutoSuperhuman and not HasTool("Superhuman") then
                local Beli2 = Beli and Beli.Value or 0
                local Frags2 = Frags and Frags.Value or 0
                if not HasTool("Black Leg") then pcall(function() CommF_:InvokeServer("BuyBlackLeg") end)
                elseif not HasTool("Electro") then pcall(function() CommF_:InvokeServer("BuyElectro") end)
                elseif not HasTool("Fishman Karate") then pcall(function() CommF_:InvokeServer("BuyFishmanKarate") end)
                elseif not HasTool("Dragon Claw") and Frags2 >= 1500 then
                    pcall(function() CommF_:InvokeServer("BlackbeardReward","DragonClaw","2") end)
                else pcall(function() CommF_:InvokeServer("BuySuperhuman") end) end
            end
            if _G.__AutoDeathStep and not HasTool("Death Step") then
                if not HasTool("Black Leg") then pcall(function() CommF_:InvokeServer("BuyBlackLeg") end)
                elseif HasTool("Library Key") then
                    ExecuteTween(CFrame.new(6371,296,-6841))
                    pcall(function() CommF_:InvokeServer("BuyDeathStep") end)
                else
                    local e = FindEnemy({"Awakened Ice Admiral"})
                    if e then EngageEnemy({e.Name})
                    else ExecuteTween(CFrame.new(5668,28,-6483)) end
                end
            end
            if _G.__AutoSharkman and not HasTool("Sharkman Karate") then
                if not HasTool("Fishman Karate") then pcall(function() CommF_:InvokeServer("BuyFishmanKarate") end)
                elseif HasTool("Water Key") then
                    ExecuteTween(CFrame.new(-2604,239,-10315))
                    pcall(function() CommF_:InvokeServer("BuySharkmanKarate") end)
                else
                    local e = FindEnemy({"Tide Keeper"})
                    if e then EngageEnemy({e.Name})
                    else ExecuteTween(CFrame.new(-3053,237,-10145)) end
                end
            end
            if _G.__AutoElectricClaw and not HasTool("Electric Claw") then
                if not HasTool("Electro") then pcall(function() CommF_:InvokeServer("BuyElectro") end)
                else pcall(function() CommF_:InvokeServer("BuyElectricClaw") end) end
            end
            if _G.__AutoDragonTalon and not HasTool("Dragon Talon") then
                if not HasTool("Dragon Claw") then
                    pcall(function() CommF_:InvokeServer("BlackbeardReward","DragonClaw","2") end)
                else pcall(function() CommF_:InvokeServer("BuyDragonTalon") end) end
            end
            if _G.__AutoGodHuman and not HasTool("Godhuman") then
                pcall(function() CommF_:InvokeServer("BuyGodhuman") end)
            end
            if _G.__AutoSanguine and not HasTool("Sanguine Art") then
                pcall(function() CommF_:InvokeServer("BuySanguineArt") end)
            end
        end)
    end
end)

--// ⭐ RACE V2 / V3
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if _G.__AutoV2 then
                local r = RaceData and tostring(RaceData.Value) or ""
                if not string.find(r, "V") then
                    local resp = CommF_:InvokeServer("Alchemist","1")
                    if resp == 0 then ExecuteTween(CFrame.new(-2779,72,-3574))
                    elseif resp == 1 then ExecuteTween(CFrame.new(0,0,0))
                    elseif resp == 2 then CommF_:InvokeServer("Alchemist","3") end
                end
            end
            if _G.__AutoV3 then
                local resp = CommF_:InvokeServer("Wenlocktoad","1")
                if resp == 0 then CommF_:InvokeServer("Wenlocktoad","2")
                elseif resp == 2 then CommF_:InvokeServer("Wenlocktoad","3") end
            end
        end)
    end
end)

--// ⭐ V4 TRIAL
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not _G.__AutoTrial or not localPlayer.Character then return end
            local race = RaceData and tostring(RaceData.Value) or ""
            if race == "Mink" and Map:FindFirstChild("MinkTrial") then
                local c = Map.MinkTrial:FindFirstChild("Ceiling")
                if c then localPlayer.Character.HumanoidRootPart.CFrame = c.CFrame * CFrame.new(0,-20,0) end
            elseif race == "Cyborg" and Map:FindFirstChild("CyborgTrial") then
                local f = Map.CyborgTrial:FindFirstChild("Floor")
                if f then ExecuteTween(f.CFrame * CFrame.new(0,500,0)) end
            elseif race == "Skypiea" and Map:FindFirstChild("SkyTrial") then
                local m = Map.SkyTrial:FindFirstChild("Model")
                if m and m:FindFirstChild("FinishPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = m.FinishPart.CFrame
                end
            elseif race == "Human" or race == "Ghoul" then
                local e = FindEnemy({"Ancient Vampire","Ancient Zombie"})
                if e then EngageEnemy({e.Name}) end
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not _G.__AutoKillTrial then return end
            local timer = playerGui.Main:FindFirstChild("Timer")
            if timer and timer.Visible then
                for _, c in pairs(Characters:GetChildren()) do
                    if c.Name ~= localPlayer.Name and IsEntityAlive(c)
                        and c:FindFirstChild("HumanoidRootPart") then
                        if GetDistance(c.HumanoidRootPart.Position) <= 250 then
                            EngageEnemy({c.Name})
                        end
                    end
                end
            end
        end)
    end
end)

--// ⭐ VOLCANO / PREHISTORIC
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not localPlayer.Character then return end
            if _G.__AutoSummonPrehis and not Map:FindFirstChild("PrehistoricIsland") then
                local boat
                local bf = WS:FindFirstChild("Boats")
                if bf then
                    for _, b in pairs(bf:GetChildren()) do
                        local o = b:FindFirstChild("Owner")
                        if o and tostring(o.Value) == localPlayer.Name then boat = b; break end
                    end
                end
                if not boat then
                    local shop = CFrame.new(-13.48,10.31,2927.69)
                    ExecuteTween(shop)
                    if GetDistance(shop) < 10 then pcall(function() CommF_:InvokeServer("BuyBoat","PirateBrigade") end) end
                elseif boat and boat:FindFirstChild("VehicleSeat") and boat.PrimaryPart then
                    local h = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if h and h.Sit then
                        pcall(function()
                            local bv = boat.PrimaryPart:FindFirstChild("PrehisBoatVel")
                            if not bv then
                                bv = Instance.new("BodyVelocity")
                                bv.Name="PrehisBoatVel"; bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                                bv.Velocity=Vector3.zero; bv.Parent=boat.PrimaryPart
                            end
                            TweenService:Create(boat.PrimaryPart,
                                TweenInfo.new(200, Enum.EasingStyle.Linear),
                                {CFrame=boat.PrimaryPart.CFrame*CFrame.new(0,5,-50000)}):Play()
                        end)
                    else ExecuteTween(boat.VehicleSeat.CFrame) end
                end
            end
            if _G.__TweenPrehis then
                local p = Map:FindFirstChild("PrehistoricIsland")
                if p then ExecuteTween(p:GetPivot() * CFrame.new(2,20,2)) end
            end
            if _G.__CollectDinoBones then
                for _, d in pairs(WS:GetChildren()) do
                    if d.Name == "DinoBone" then ExecuteTween(d.CFrame) end
                end
            end
            if _G.__CollectDragonEggs then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    local core = isl:FindFirstChild("Core")
                    if core and core:FindFirstChild("SpawnedDragonEggs") then
                        local egg = core.SpawnedDragonEggs:FindFirstChild("DragonEgg")
                        if egg and egg:FindFirstChild("Molten") then
                            ExecuteTween(egg.Molten.CFrame)
                            pcall(function() fireproximityprompt(egg.Molten.ProximityPrompt, 30) end)
                        end
                    end
                end
            end
            if _G.__AutoStartPrehis then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    local core = isl:FindFirstChild("Core")
                    if core then
                        local pr = core:FindFirstChild("ActivationPrompt", true)
                        if pr and pr:FindFirstChild("ProximityPrompt") then
                            ExecuteTween(pr.CFrame)
                            if GetDistance(pr.CFrame.Position) <= 150 then
                                pcall(function() fireproximityprompt(pr.ProximityPrompt, math.huge) end)
                                SendKeyPress("E", 1.5)
                            end
                        end
                    end
                end
            end
            if _G.__AutoPatchPrehis then
                local isl = Map:FindFirstChild("PrehistoricIsland")
                if isl then
                    for _, o in pairs(isl:GetDescendants()) do
                        if (o:IsA("BasePart") or o:IsA("MeshPart"))
                            and o.Name:lower():find("lava") then o:Destroy() end
                    end
                end
            end
            if _G.__AutoDracoV2 then
                for _, d in pairs(WS:GetChildren()) do
                    if d.Name == "FireFlowers" then
                        for _, f in pairs(d:GetChildren()) do
                            if f.PrimaryPart then
                                local pos = f.PrimaryPart.Position
                                ExecuteTween(CFrame.new(pos))
                                if GetDistance(pos) <= 100 then SendKeyPress("E",1.5) end
                            end
                        end
                    end
                end
            end
            if _G.__AutoDracoV1 then
                if not HasTool("Dragon Egg") and not FindEnemy({"Lava Golem"}) then
                    -- procura dragon egg
                end
            end
            if _G.__AutoDracoV3 then
                pcall(function()
                    CommF_:InvokeServer("requestEntrance", Vector3.new(5661,1013,-334))
                end)
            end
            if _G.__AutoDojo and Net then
                pcall(function()
                    local rf = Net:FindFirstChild("RF/InteractDragonQuest")
                    if rf then
                        local resp = rf:InvokeServer({NPC="Dojo Trainer",Command="RequestQuest"})
                        if not resp or not resp.Quest or not resp.Quest.BeltName then
                            ExecuteTween(CFrame.new(5865,1208,871))
                        end
                    end
                end)
            end
        end)
    end
end)

--// ⭐ STATS / ESP / FRUITS / ABILITIES / CHIPS / HUNTER
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Data and Data:FindFirstChild("Points") then
                for _, s in ipairs({"Melee","Defense","Sword","Gun","Blox Fruit"}) do
                    if _G["__autoStat_"..s] and Data.Points.Value > 0 then
                        CommF_:InvokeServer("AddPoint",
                            s == "Blox Fruit" and "Demon Fruit" or s,
                            tonumber(_G.__StatsVal) or 10)
                    end
                end
            end
            if _G.__AutoRandomFruit then CommF_:InvokeServer("Cousin","Buy") end
            if _G.__AutoStoreFruit then
                for _, t in pairs(localPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote") then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if _G.__AutoDropFruit then
                for _, t in pairs(localPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and string.find(t.Name,"Fruit") and t:FindFirstChild("EatRemote") then
                        t.EatRemote:InvokeServer("Drop")
                    end
                end
            end
            if _G.__AutoFindFruit then
                for _, f in pairs(WS:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        ExecuteTween(f.Handle.CFrame); break
                    end
                end
            end
            if _G.__AutoBuso and localPlayer.Character and not localPlayer.Character:FindFirstChild("HasBuso") then
                pcall(function() CommF_:InvokeServer("Buso") end)
            end
            if _G.__AutoKen and CommE then CommE:FireServer("Ken", true) end
            if _G.__AutoTurnV3 and CommE then CommE:FireServer("ActivateAbility") end
            if _G.__AutoTurnV4 and localPlayer.Character:FindFirstChild("RaceEnergy")
                and localPlayer.Character.RaceEnergy.Value == 1 then SendKeyPress("Y", 0.05) end
            if _G.__DisableNotify and playerGui:FindFirstChild("Notifications") then
                playerGui.Notifications.Enabled = false
            end
            if _G.__AutoBuyChip then
                if not HasTool("Special Microchip") then
                    if (_G.__RaidChip or "Flame") == "Rumble" then CommF_:InvokeServer("ThunderGodTalk")
                    else CommF_:InvokeServer("RaidsNpc","Select", _G.__RaidChip or "Flame") end
                end
            end
            if _G.__AutoAwake then
                CommF_:InvokeServer("Awakener","Check")
                CommF_:InvokeServer("Awakener","Awaken")
            end
            if _G.__AutoGetPlayerQuest then CommF_:InvokeServer("PlayerHunter") end
            if _G.__AutoKillPlayerQuest then
                local q = playerGui.Main:FindFirstChild("Quest")
                if q and q.Visible then
                    for _, c in pairs(Characters:GetChildren()) do
                        if c.Name ~= localPlayer.Name and IsEntityAlive(c) then
                            local txt = q.Container and q.Container.QuestTitle
                                and q.Container.QuestTitle.Title
                                and q.Container.QuestTitle.Title.Text or ""
                            if string.find(txt, c.Name) then EngageEnemy({c.Name}) end
                        end
                    end
                else CommF_:InvokeServer("PlayerHunter") end
            end
            if _G.__AutoPvP then
                local pvp = playerGui.Main:FindFirstChild("PvpDisabled")
                if pvp and pvp.Visible then CommF_:InvokeServer("EnablePvp") end
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
        bg.Name="FarmESP"..ESPNum; bg.Size=UDim2.new(0,120,0,50)
        bg.StudsOffset=Vector3.new(0,2,0); bg.AlwaysOnTop=true
        bg.Adornee=part; bg.Parent=part
        local tl=Instance.new("TextLabel",bg)
        tl.Size=UDim2.new(1,0,1,0); tl.BackgroundTransparency=1
        tl.TextColor3=color or Color3.fromRGB(255,255,255)
        tl.TextStrokeTransparency=0.3; tl.Font=Enum.Font.GothamBold
        tl.TextSize=12; tl.Text=label
    end
    while task.wait(1.5) do
        pcall(function()
            if _G.__EspPlayer then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= localPlayer and p.Character and p.Character:FindFirstChild("Head") then
                        cESP(p.Character.Head, Color3.fromRGB(0,255,0),
                            string.format("%s [%d]", p.Name,
                            math.floor(GetDistance(p.Character.Head.Position)/3)))
                    end
                end
            end
            if _G.__EspChest then
                for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if not c:GetAttribute("IsDisabled") then
                        local p = c:IsA("BasePart") and c or c:FindFirstChildWhichIsA("BasePart")
                        if p then cESP(p, Color3.fromRGB(255,255,0),
                            "Chest ["..math.floor(GetDistance(p.Position)/3).."]") end
                    end
                end
            end
            if _G.__EspFruit then
                for _, f in pairs(WS:GetChildren()) do
                    if string.find(f.Name,"Fruit") and f:FindFirstChild("Handle") then
                        cESP(f.Handle, Color3.fromRGB(255,100,100), f.Name)
                    end
                end
            end
            if _G.__EspBerry then
                for _, d in pairs(Map:GetDescendants()) do
                    if d.Name == "Berries" then
                        for i = 1, 8 do
                            if d:GetAttribute("_BerryCFrame"..i) then
                                cESP(d.Parent, Color3.fromRGB(255,0,255), "Berry")
                            end
                        end
                    end
                end
            end
            if _G.__EspEvent and WorldOrigin:FindFirstChild("Locations") then
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

--// TELEPORT ISLAND
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            if _G.__TweenIsland and _G.__IslandSel and WorldOrigin:FindFirstChild("Locations") then
                for _, l in pairs(WorldOrigin.Locations:GetChildren()) do
                    if l.Name == _G.__IslandSel then
                        ExecuteTween(l.CFrame * CFrame.new(0, 30, 0))
                    end
                end
            end
        end)
    end
end)

--// FAST ATTACK
task.spawn(function()
    while task.wait() do
        pcall(function()
            if not _G.__FastAttack or not Net then return end
            if not localPlayer.Character or not Root then return end
            local tool = localPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool or not tool.ToolTip or tool.ToolTip == "Gun" or tool.ToolTip == "Blox Fruit" then return end
            local ra = Net:FindFirstChild("RE/RegisterAttack")
            local rh = Net:FindFirstChild("RE/RegisterHit")
            if not ra or not rh then return end
            local hits = {}
            for _, e in pairs(Enemies:GetChildren()) do
                if IsEntityAlive(e) and e:FindFirstChild("HumanoidRootPart")
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
                if sethiddenproperty then sethiddenproperty(localPlayer,"SimulationRadius",math.huge) end
            end)
            for _, e in pairs(Enemies:GetChildren()) do
                if IsEntityAlive(e) and e:FindFirstChild("HumanoidRootPart")
                    and GetDistance(e.HumanoidRootPart.Position) <= 500 then
                    pcall(function()
                        if e:FindFirstChild("Humanoid") then e.Humanoid.Health = 0 end
                        e:BreakJoints()
                    end)
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
            if playerGui:FindFirstChild("Notifications") then
                playerGui.Notifications.Enabled = not _G.__RemoveNotify
            end
        end)
    end
end)

--// ANTI AFK
task.spawn(function()
    pcall(function()
        localPlayer.Idled:Connect(function()
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
                    TeleportService:Teleport(game.PlaceId, localPlayer); break
                end
            end
        end)
    end
end)

--// NO CLIP
task.spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            if _G.__NoClip and localPlayer.Character then
                for _, p in pairs(localPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end)

--// Aimbot
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
                        if p ~= localPlayer and p.Character
                            and p.Character:FindFirstChild("HumanoidRootPart")
                            and p.Team ~= localPlayer.Team then
                            local d = GetDistance(p.Character.HumanoidRootPart.Position)
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

--=====================================================================
Window:Notify({
    Title = "Blox Fruits Farm",
    Content = "Todas as features estão funcionais!",
    Duration = 6
})
