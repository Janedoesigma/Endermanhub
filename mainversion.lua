--[[
    Blox Fruits Hub | Fluent UI
    Porte do Speed Hub X v5.5.0 (partes Home, Main e Third World / Automatically)
    Home:  Config, Local Player, Server Manager, Stat Manager
    Main:  Status, Stack Farming, Hop Boss, Level, Nearest, Mastery, Chest/Berry,
           Factory / Pirates Sea, Boss, Material
    Auto:  Swords, Serpent Bow, Bones, Soul Reaper, Cake Prince, Dough King,
           Elite Hunter, Haki Colors, Rainbow Haki
]]

repeat task.wait() until game:IsLoaded()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

----------------------------------------------------------------------
-- Serviços / referências
----------------------------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local Enemies = Workspace:WaitForChild("Enemies")
local Map = Workspace:WaitForChild("Map")
local WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local CommF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net = RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")

local pid = game.PlaceId
local Sea1 = pid == 2753915549 or pid == 85211729168715
local Sea2 = pid == 4442272183 or pid == 79091703265657
local Sea3 = pid == 7449423635 or pid == 100117331123089

local HitToken = tostring(LP.UserId):sub(2, 4) .. "078da"

----------------------------------------------------------------------
-- Janela
----------------------------------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "Blox Fruits Hub",
    SubTitle = "Fluent | porte Speed Hub X",
    TabWidth = 160,
    Size = UDim2.fromOffset(620, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Auto = Window:AddTab({ Title = "Automatically", Icon = "bot" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local function O(name, default)
    local o = Options[name]
    if o == nil then return default end
    local v = o.Value
    if v == nil then return default end
    return v
end

local function Selected(name)
    local v = O(name, {})
    local r = {}
    if type(v) == "table" then
        for k, s in pairs(v) do
            if s == true then table.insert(r, k) end
        end
    end
    return r
end

-- Helpers de UI -------------------------------------------------------
local function UIToggle(sec, id, title, desc, default, cb)
    local t = sec:AddToggle(id, { Title = title, Description = desc, Default = default or false })
    if cb then
        t:OnChanged(function() cb(Options[id].Value) end)
    end
    return t
end

local function UIDropdown(sec, id, title, desc, values, default, multi)
    return sec:AddDropdown(id, {
        Title = title,
        Description = desc,
        Values = values or {},
        Multi = multi or false,
        Default = default
    })
end

local function SetPara(p, title, content)
    pcall(function()
        if title then p:SetTitle(title) end
        p:SetDesc(content)
    end)
end

local function Notify(title, content)
    Fluent:Notify({ Title = title, Content = content, Duration = 5 })
end

----------------------------------------------------------------------
-- Lista de features (usada por noclip / EngageEnemy)
----------------------------------------------------------------------
local Features = {
    "Auto Farm Level", "Auto Farm Nearest", "Auto Farm Mastery", "Auto Collect Chest",
    "Auto Collect Berry", "Auto Factory", "Auto Attack Boss", "Auto Attack All Boss",
    "Auto Pirates Sea", "Auto Farm Material", "Auto Get Sword", "Auto Get Serpent Bow",
    "Auto Farm Bones", "Auto Cake Prince", "Auto Dough King", "Auto Elite Hunter",
    "Auto Soul Reaper", "Auto Citizen Quest"
}

local function AnyFeatureActive()
    for i = 1, #Features do
        if O(Features[i], false) then return true end
    end
    return false
end

----------------------------------------------------------------------
-- Utilidades básicas
----------------------------------------------------------------------
local function GetHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(model)
    local h = model and model:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetDistance(pos)
    local c = LP.Character
    if not c or not c.PrimaryPart then return math.huge end
    if typeof(pos) == "CFrame" then pos = pos.Position end
    if typeof(pos) ~= "Vector3" then return math.huge end
    return (c.PrimaryPart.Position - pos).Magnitude
end

local function FireRemote(...)
    return CommF:InvokeServer(...)
end

local function HasTool(name)
    local c = LP.Character
    if not c then return false end
    return c:FindFirstChild(name) ~= nil or LP.Backpack:FindFirstChild(name) ~= nil
end

local function EquipToolByName(name)
    local c = LP.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    local tool = LP.Backpack:FindFirstChild(name)
    if hum and tool and tool:IsA("Tool") then hum:EquipTool(tool) end
end

local function EquipToolByTip(tip)
    for _, t in ipairs(LP.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tip then
            EquipToolByName(t.Name)
            return
        end
    end
end

local function EquipSelectedTool()
    EquipToolByTip(O("Weapon Tool", "Melee"))
end

local lastHaki = 0
local function ActivateHaki()
    local c = LP.Character
    if c and not c:FindFirstChild("HasBuso") and tick() - lastHaki > 3 then
        lastHaki = tick()
        task.spawn(function() FireRemote("Buso") end)
    end
end

local function SendKeyPress(key, hold)
    VIM:SendKeyEvent(true, key, false, game)
    if hold and hold > 0 then task.wait(hold) end
    VIM:SendKeyEvent(false, key, false, game)
end

local function IsSkillAvailable(key)
    local ok, res = pcall(function()
        local tool = LP.Character:FindFirstChildOfClass("Tool")
        if not tool then return false end
        local frame = PlayerGui.Main.Skills[tool.Name]
        if not frame then return false end
        for _, f in ipairs(frame:GetChildren()) do
            if f:IsA("Frame") and f.Name == key then
                local title = f:FindFirstChild("Title")
                if title and title.TextColor3 == Color3.fromRGB(255, 255, 255) then
                    return true
                end
            end
        end
        return false
    end)
    return ok and res
end

local function QuestActive()
    local tracked = PlayerGui:FindFirstChild("TrackedQuestFrame")
    if tracked and tracked:FindFirstChild("Frame") then
        return tracked.Frame.Visible
    end
    local main = PlayerGui:FindFirstChild("Main")
    local q = main and main:FindFirstChild("Quest")
    return q and q.Visible or false
end

-- Inventário (materiais) ----------------------------------------------
local ItemReplicationService, KEYS, ItemId, ItemConfig
pcall(function()
    ItemReplicationService = require(RS.ItemReplicationService)
    KEYS = require(RS.ItemReplicationService.KEYS)
    ItemId = require(RS.Economy.ItemId)
    ItemConfig = require(RS.ItemConfig)
end)

local function GetMaterialCount(name)
    local ok, res = pcall(function()
        local items = ItemReplicationService:GetItems(KEYS.QUANTITY)
        for _, item in pairs(items or {}) do
            local n = item.Value or 0
            if n > 0 then
                local cfg = ItemConfig.match(item.ItemId)
                if cfg:isOk() then
                    local u = cfg:unwrap()
                    local index = u.Index or u.Data or u
                    local t = index.IdType or index.Type
                    if t == "Material" then
                        local d = ItemId.getDataFromId(item.ItemId)
                        if d:isOk() and d:unwrap().StorageKey == name then
                            return n
                        end
                    end
                end
            end
        end
        return 0
    end)
    return ok and res or 0
end

-- Remove efeito de morte e camera shake (menos lag) -------------------
task.spawn(function()
    if _G.ExecutedRemove then return end
    _G.ExecutedRemove = true
    pcall(function()
        local container = RS.Effect.Container
        local CameraShaker = require(RS.Util.CameraShaker)
        hookfunction(require(container:FindFirstChild("Death")), function() end)
        CameraShaker:Stop()
    end)
end)

----------------------------------------------------------------------
-- Tween
----------------------------------------------------------------------
local ActiveController

local function CreateTweenController(hrp)
    if not hrp or not hrp.Parent then return nil end
    local ctrl = {}
    local savedVel = hrp.AssemblyLinearVelocity
    local collideMap, anchorMap = {}, {}
    local tween, bv, conn, running = nil, nil, nil, false

    local function cleanup()
        if conn then conn:Disconnect() conn = nil end
        if tween then tween:Cancel() tween = nil end
        if bv then bv:Destroy() bv = nil end
        if hrp.Parent then
            for _, d in pairs(hrp.Parent:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.CanCollide = (collideMap[d] ~= nil) and collideMap[d] or true
                    collideMap[d] = nil
                    if anchorMap[d] ~= nil then
                        d.Anchored = anchorMap[d]
                        anchorMap[d] = nil
                    end
                end
            end
            hrp.AssemblyLinearVelocity = savedVel
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
        running = false
    end

    function ctrl.Execute(_, cf, speed)
        if running then cleanup() end
        savedVel = hrp.AssemblyLinearVelocity
        for _, d in pairs(hrp.Parent:GetDescendants()) do
            if d:IsA("BasePart") then
                collideMap[d] = d.CanCollide
                anchorMap[d] = d.Anchored
                d.CanCollide = false
            end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local t = math.max(0.05, (hrp.CFrame.Position - cf.Position).Magnitude / math.max(speed or 100, 0.01))
        running = true
        tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
        conn = tween.Completed:Connect(cleanup)
        tween:Play()
    end

    function ctrl.Destroy() cleanup() end
    return ctrl
end

local function FindNearestTeleporter(cf)
    local pos = cf.Position
    local list = {}
    if pid == 7449423635 then
        list = {
            ["Castle On The Sea"] = Vector3.new(-5058.775, 314.5155, -3155.8833),
            Hydra = Vector3.new(5756.8374, 610.424, -253.9254),
            Mansion = Vector3.new(-12463.874, 374.9145, -7523.774),
            ["Great Tree"] = Vector3.new(28282.57, 14896.851, 105.1043),
            ["Temple Clock"] = Vector3.new(28282.57, 14896.851, 105.10427),
        }
    elseif pid == 4442272183 then
        list = {
            Mansion = Vector3.new(-288.4625, 306.1306, 597.9988),
            Flamingo = Vector3.new(2284.912, 15.152, 905.4829),
            ["122"] = Vector3.new(923.2125, 126.976, 32852.832),
            ["3032"] = Vector3.new(-6508.558, 89.035, -132.8395),
        }
    elseif pid == 2753915549 then
        list = {
            ["1"] = Vector3.new(-7894.62, 5545.4917, -380.2467),
            ["2"] = Vector3.new(-4607.8228, 872.5423, -1667.5569),
            ["3"] = Vector3.new(61163.85, 11.7595, 1819.7842),
            ["4"] = Vector3.new(3876.2805, 35.1061, -1939.3202),
        }
    end
    if not next(list) then return nil end

    local best, bestDist = nil, math.huge
    for _, v in pairs(list) do
        local m = (v - pos).Magnitude
        if m < bestDist then bestDist = m best = v end
    end

    local hrp = GetHRP()
    if not hrp then return nil end
    if bestDist <= (pos - hrp.Position).Magnitude then return best end
    return nil
end

local SUBMERGED = Vector3.new(10213.701, -1733.5026, 9940.189)

local function ExecuteTween(cf, speed)
    local hrp = GetHRP()
    if not hrp then return end

    if ActiveController then pcall(function() ActiveController:Destroy() end) end
    ActiveController = CreateTweenController(hrp)
    local spd = tonumber(speed) or tonumber(O("Tween Speed", 300)) or 100
    if spd <= 0 then spd = 100 end

    local pos = cf.Position

    -- Ilha submersa
    if (SUBMERGED - pos).Magnitude <= 3500 and LP:DistanceFromCharacter(SUBMERGED) > 3500 then
        if LP:DistanceFromCharacter(Vector3.new(-16267, 25, 1371)) > 5 then
            ActiveController:Execute(CFrame.new(-16267, 25, 1371), spd)
        else
            pcall(function() Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland") end)
        end
        return
    end

    if LP:GetAttribute("CurrentLocation") == "Submerged Island" and (SUBMERGED - pos).Magnitude > 3500 then
        if LP:DistanceFromCharacter(Vector3.new(11426, -2155, 9730)) > 5 then
            ActiveController:Execute(CFrame.new(11426, -2155, 9730), spd)
        else
            pcall(function() Net:FindFirstChild("RF/SubmarineTransportation"):InvokeServer("InitiateTeleport", "Tiki Outpost") end)
        end
        return
    end

    -- Teleporte entre regiões
    if not _G.Teleporting then
        local tp = FindNearestTeleporter(cf)
        if tp then
            _G.Teleporting = true
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            task.spawn(function() FireRemote("requestEntrance", tp) end)
            task.delay(1, function() _G.Teleporting = false end)
            return
        end
    end

    ActiveController:Execute(cf, spd)
end

local function StopTween()
    task.spawn(function()
        if ActiveController then
            ActiveController:Destroy()
            ActiveController = nil
        end
    end)
end

-- Noclip enquanto alguma feature estiver ligada -----------------------
local ncParts, ncChar, ncConn, ncLast = {}, nil, nil, 0

local function ncDisable(char)
    for p in pairs(ncParts) do
        if p and p.Parent and p:IsA("BasePart") then p.CanCollide = true end
        ncParts[p] = nil
    end
    if ncConn then ncConn:Disconnect() ncConn = nil end
end

local function ncEnable(char)
    if not char or not char.Parent then return end
    for _, d in pairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d.CanCollide and not ncParts[d] then
            ncParts[d] = true
            d.CanCollide = false
        end
    end
    if ncConn then ncConn:Disconnect() end
    ncConn = char.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") and d.CanCollide and not ncParts[d] then
            ncParts[d] = true
            task.defer(function() d.CanCollide = false end)
        end
    end)
end

RunService.Stepped:Connect(function()
    local now = tick()
    if now - ncLast < 0.2 then return end
    ncLast = now
    local char = LP.Character
    local active = AnyFeatureActive()
    if active and char and char ~= ncChar then
        if ncChar then ncDisable(ncChar) end
        ncChar = char
        ncEnable(char)
    elseif not active and ncChar then
        ncDisable(ncChar)
        ncChar = nil
    end
end)

----------------------------------------------------------------------
-- Fast Attack
----------------------------------------------------------------------
local hitThread = coroutine.create(function()
    pcall(function()
        RegisterHit:FireServer(HitToken)
        while true do
            local head, others = coroutine.yield()
            RegisterHit:FireServer(head, others, nil, HitToken)
        end
    end)
end)
coroutine.resume(hitThread)

local function GetGameHitThread()
    local ok, res = pcall(function()
        local global = RS:FindFirstChild("Global")
        if global then
            for _, v in pairs(getupvalues(require(global).SendHitsToServer)) do
                if type(v) == "thread" and coroutine.status(v) ~= "dead" then
                    return v
                end
            end
        end
    end)
    return ok and res or nil
end

local m1State = { last = 0, delay = 0 }

local function FruitM1(tool)
    pcall(function()
        local now = tick()
        m1State.delay = (now - m1State.last <= 0.4) and math.min(m1State.delay + 1, 4) or 1
        m1State.last = now
        local c = LP.Character
        local pp = c and c.PrimaryPart
        if not pp then return end
        for _, mob in ipairs(Enemies:GetChildren()) do
            local root = mob.PrimaryPart
            if root and IsAlive(mob) then
                local d = root.Position - pp.Position
                if d.X * d.X + d.Y * d.Y + d.Z * d.Z <= 2500 then
                    tool.LeftClickRemote:FireServer(d.Unit, m1State.delay)
                end
            end
        end
    end)
end

local function GetHits(range)
    local hits = {}
    local hrp = GetHRP()
    if not hrp then return hits end
    for _, mob in ipairs(Enemies:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.Health > 0 and (root.Position - hrp.Position).Magnitude <= range then
            table.insert(hits, { mob, mob:FindFirstChild("Head") or root })
        end
    end
    return hits
end

local function ExecuteAttack()
    local c = LP.Character
    local tool = c and c:FindFirstChildOfClass("Tool")
    if not (tool and table.find({ "Melee", "Sword", "Blox Fruit", "Gun" }, tool.ToolTip)) then return end
    local hits = GetHits(60)
    if #hits > 0 then
        RegisterAttack:FireServer(0)
        local head = table.remove(hits, 1)[2]
        local th = GetGameHitThread() or hitThread
        coroutine.resume(th, head, hits)
    end
end

local function ExecuteBladeHits()
    pcall(function()
        local c = LP.Character
        local tool = c and c:FindFirstChildWhichIsA("Tool")
        if not tool then return end
        local tip = tool.ToolTip
        if tip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
            FruitM1(tool)
        elseif tip ~= "Gun" then
            ExecuteAttack()
        else
            task.wait(0.5)
        end
    end)
end

task.spawn(function()
    while task.wait() and not Fluent.Unloaded do
        if O("Fast Attack", true) then
            ExecuteBladeHits()
        end
    end
end)

----------------------------------------------------------------------
-- Bring Mob
----------------------------------------------------------------------
local function BringEnemyToPosition(target, cf)
    if not O("Bring Mob", true) then return end
    if not target or not target.Parent or not cf then return end

    local radius = tonumber(O("Bring Mob Radius", 300)) or 300
    local r2 = radius * radius
    local center = cf.Position

    pcall(function()
        sethiddenproperty(LP, "SimulationRadius", math.huge)
        sethiddenproperty(LP, "MaxSimulationRadius", math.huge)
    end)

    for _, mob in ipairs(Enemies:GetChildren()) do
        if mob.Name == target.Name and not table.find({ "Shark", "Piranha", "Terrorshark" }, mob.Name) then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            local root = mob:FindFirstChild("HumanoidRootPart")
            local ready = mob:FindFirstChild("CharacterReady")

            if hum and root and ready and hum.Health > 0 and root:IsDescendantOf(Workspace) then
                local d = root.Position - center
                if d.X * d.X + d.Y * d.Y + d.Z * d.Z <= r2 and not root:GetAttribute("BeingBrought") then
                    root:SetAttribute("BeingBrought", true)
                    root.CanCollide = false
                    root.Massless = true

                    for _, p in ipairs(mob:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                            p.CanTouch = false
                            p.Massless = true
                            p.AssemblyLinearVelocity = Vector3.zero
                            p.AssemblyAngularVelocity = Vector3.zero
                        end
                    end

                    local lock = root:FindFirstChild("Lock")
                    if not lock or not lock.Parent then
                        lock = Instance.new("BodyVelocity")
                        lock.Name = "Lock"
                        lock.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        lock.P = 9000
                        lock.Velocity = Vector3.zero
                        lock.Parent = root
                    end

                    local gyro = root:FindFirstChild("BringGyro")
                    if not gyro or not gyro.Parent then
                        gyro = Instance.new("BodyGyro")
                        gyro.Name = "BringGyro"
                        gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                        gyro.P = 30000
                        gyro.D = 1000
                        gyro.Parent = root
                    end

                    gyro.CFrame = cf
                    hum.AutoRotate = false
                    hum.PlatformStand = false
                    hum.BreakJointsOnDeath = false
                    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero

                    task.spawn(function()
                        local goal = center + Vector3.new(math.random(-20, 20) / 100, math.random(-20, 20) / 100, math.random(-20, 20) / 100)
                        local diff = goal - root.Position
                        local mag = diff.Magnitude
                        if mag > 0.5 then
                            lock.Velocity = diff.Unit * math.clamp(mag * 10, 20, 1200)
                        else
                            lock.Velocity = Vector3.zero
                            pcall(function() root.CFrame = CFrame.new(goal) end)
                        end
                        task.wait(0.12)
                        pcall(function()
                            if lock and lock.Parent then lock:Destroy() end
                            if gyro and gyro.Parent then gyro:Destroy() end
                            if root and root.Parent then root:SetAttribute("BeingBrought", false) end
                        end)
                    end)
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- Busca de inimigos
----------------------------------------------------------------------
local nameCache = {}

local function FindEnemy(names, maxRange, mode)
    local hrp = GetHRP()
    if not hrp then return nil end
    local pos = hrp.Position
    local best = maxRange and maxRange * maxRange or math.huge
    local set = {}
    for _, n in ipairs(names) do set[n] = true end
    local found = nil

    for _, mob in ipairs(Enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            local clean = nameCache[mob.Name] or mob.Name:match("^(.-)%s*%[") or mob.Name
            nameCache[mob.Name] = clean
            if set[clean] then
                local part = (mode == "Boat" and mob:FindFirstChild("VehicleSeat")) or mob:FindFirstChild("HumanoidRootPart")
                if part then
                    local d = part.Position - pos
                    local m = d.X * d.X + d.Y * d.Y + d.Z * d.Z
                    if m < best then
                        best = m
                        found = mob
                    end
                end
            end
        end
    end
    return found
end

----------------------------------------------------------------------
-- Dodge (anim de skill do inimigo)
----------------------------------------------------------------------
local IgnoredAnims = {
    ["rbxassetid://9802959564"] = true,
    ["rbxassetid://507766388"] = true,
    ["http://www.roblox.com/asset/?id=9884584522"] = true,
}

local function MonitorSkillUsage(mob)
    if not mob or not mob.Parent then return end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return end
    animator.AnimationPlayed:Connect(function(track)
        if not track or not track.Animation then return end
        if IgnoredAnims[track.Animation.AnimationId] then return end
        local t = math.max(track.TimePosition or 1.5, 1.5)
        if O("Auto Dodge Skill", false) then
            local dt = _G.DodgeTime or 0
            if tick() < dt then
                _G.DodgeTime = dt + math.floor(t)
            else
                _G.DodgeTime = tick() + math.floor(t)
            end
        end
    end)
end

----------------------------------------------------------------------
-- Combate
----------------------------------------------------------------------
local orbit = 0

local function FarmPosition(base)
    orbit = (orbit + 5) % 360
    local r = math.rad(orbit)
    local h = tonumber(O("Farm Distance", 20)) or 20
    return base + Vector3.new(math.sin(r) * 35, h, math.cos(r) * 35)
end

local function EngageEnemy(names)
    for _, mob in pairs(Enemies:GetChildren()) do
        if mob and table.find(names, mob.Name) then
            local pp = mob.PrimaryPart
            local cf = pp and pp.CFrame

            if pp and IsAlive(mob) then
                MonitorSkillUsage(mob)
                while true do
                    RunService.Heartbeat:Wait()

                    if not _G.DodgeTime or _G.DodgeTime < tick() then
                        EquipSelectedTool()
                        ActivateHaki()
                        BringEnemyToPosition(mob, cf)
                        ExecuteTween(CFrame.new(FarmPosition(cf.Position)))
                    else
                        pcall(function()
                            LP.Character.PrimaryPart.CFrame = mob.PrimaryPart.CFrame * CFrame.new(0, 500, 0)
                        end)
                    end

                    if not AnyFeatureActive() or Fluent.Unloaded or not mob or not mob.Parent or not IsAlive(mob) then
                        break
                    end
                end
            end
        end
    end

    -- Bosses ainda no ReplicatedStorage (não spawnados): vai até a posição
    for _, child in pairs(RS:GetChildren()) do
        if table.find(names, child.Name) and child.PrimaryPart then
            ExecuteTween(CFrame.new(child.PrimaryPart.CFrame.Position + Vector3.new(0, tonumber(O("Farm Distance", 20)) or 20, 10)))
        end
    end
end

----------------------------------------------------------------------
-- Quest info
----------------------------------------------------------------------
local lastEntrance = 0
local function Entrance(pos)
    if tick() - lastEntrance < 5 then return end
    lastEntrance = tick()
    task.spawn(function() FireRemote("requestEntrance", pos) end)
end

local function GetQuestInfo()
    local level = LP.Data.Level.Value
    local team = tostring(LP.Team)

    -- { nº quest, CFrame do NPC, nome do mob, nome da quest, level req, nome limpo }
    if level >= 1 and level <= 9 then
        if team == "Marines" then
            return { 1, CFrame.new(-2709.67944, 24.5206585, 2104.24585), "Trainee", "MarineQuest", 1, "Trainee" }
        end
        return { 1, CFrame.new(1059.99731, 16.9222069, 1549.28162), "Bandit", "BanditQuest1", 1, "Bandit" }
    end

    if level >= 210 and level <= 249 then
        return { 2, CFrame.new(5308.93115, 1.65517521, 475.120514), "Dangerous Prisoner", "PrisonerQuest", 210, "Dangerous Prisoner" }
    end

    local num, cf, fullName, questName, mobName
    local reqLv = 0

    for npc, data in pairs(require(RS.GuideModule).Data.NPCList) do
        for i, lv in ipairs(data.Levels) do
            if level >= lv and lv > reqLv then
                reqLv = lv
                num = (#data.Levels == 3 and i == 3) and 2 or i
                cf = npc.CFrame
            end
        end
    end

    local hrp = GetHRP()
    if hrp and cf then
        local far = (cf.Position - hrp.Position).Magnitude
        if level >= 375 and level <= 449 and far > 3000 then
            Entrance(Vector3.new(61163.85, 11.6797, 1819.7842))
        elseif level >= 450 and level <= 474 and far > 3000 then
            Entrance(Vector3.new(-4607.8228, 872.5425, -1667.5569))
        elseif level >= 475 and level <= 624 and far > 5000 then
            Entrance(Vector3.new(-7894.6177, 5547.1416, -380.2912))
        end
    end

    for qName, quest in pairs(require(RS.Quests)) do
        if qName ~= "CitizenQuest" then
            for qNum, info in pairs(quest) do
                if info.LevelReq == reqLv then
                    questName = qName
                    num = qNum
                    for taskName in pairs(info.Task) do
                        fullName = taskName
                        mobName = string.split(taskName, " [Lv. " .. info.LevelReq .. "]")[1]
                    end
                end
            end
        end
    end

    if questName == "ImpelQuest" then
        questName, num = "PrisonerQuest", 2
        fullName, mobName, reqLv = "Dangerous Prisoner", "Dangerous Prisoner", 210
        cf = CFrame.new(5310.60547, 0.350014925, 474.946594)
    elseif questName == "Area2Quest" and num == 2 then
        num, fullName, mobName, reqLv = 1, "Swan Pirate", "Swan Pirate", 775
    end

    if level >= 2500 and level <= 2524 then
        fullName, mobName = "Sun-kissed Warrior", "Sun-kissed Warriors"
    end

    return { num, cf, fullName, questName, reqLv, mobName }
end

local function CleanSpawnName(name)
    local s = name:gsub("Lv%.", "")
    s = s:gsub("[%[%] %d]", "")
    s = s:gsub("%s+", "")
    return s
end

local spawnIndex = 1
local function NavigateToSpawn(names)
    local want = {}
    for _, n in ipairs(names) do want[CleanSpawnName(n)] = true end

    local spots = {}
    local fort = RS:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
    if fort then
        for _, part in ipairs(fort:GetChildren()) do
            if part:IsA("Part") and part:GetAttribute("Active") and want[CleanSpawnName(part.Name)] then
                table.insert(spots, part:GetPivot())
            end
        end
    end
    if #spots == 0 then return false end
    if spawnIndex > #spots then spawnIndex = 1 end

    local cf = spots[spawnIndex]
    local dist = GetDistance(cf.Position)
    if dist > 20 then
        if dist > 150 then
            ExecuteTween(cf * CFrame.new(0, 65, 5))
        else
            ExecuteTween(cf * CFrame.new(0, 30, 5))
        end
    end
    spawnIndex = spawnIndex % #spots + 1
    return true
end

----------------------------------------------------------------------
-- Materiais / bosses
----------------------------------------------------------------------
local function GetMaterialList()
    if Sea1 then return { "Angel Wings", "Leather + Scrap Metal", "Magma Ore", "Fish Tail" } end
    if Sea2 then return { "Leather + Scrap Metal", "Magma Ore", "Mystic Droplet", "Radioactive Material", "Vampire Fang" } end
    if Sea3 then return { "Leather + Scrap Metal", "Fish Tail", "Gunpowder", "Mini Tusk", "Conjured Cocoa", "Dragon Scale" } end
    return {}
end

local MaterialData = {
    Sea1 = {
        ["Angel Wings"] = { { "Royal Soldier", "Royal Squad" }, CFrame.new(-7742, 5634, -1564) },
        ["Leather + Scrap Metal"] = { { "Pirate", "Brute" }, CFrame.new(-1257, 54, 4091) },
        ["Magma Ore"] = { { "Military Soldier" }, CFrame.new(-5408, 11, 8456) },
        ["Fish Tail"] = { { "Fishman Warrior" }, CFrame.new(60931, 19, 1574) },
    },
    Sea2 = {
        ["Leather + Scrap Metal"] = { { "Scrap Metal" }, CFrame.new(-1026, 73, 1375) },
        ["Magma Ore"] = { { "Lava Pirate" }, CFrame.new(-5241, 50, -4713) },
        ["Mystic Droplet"] = { { "Water Fighter" }, CFrame.new(-3350, 282, -10527) },
        ["Radioactive Material"] = { { "Factory Staff" }, CFrame.new(-73, 149, -112) },
        ["Vampire Fang"] = { { "Vampire" }, CFrame.new(-6030, 6, -1281) },
    },
    Sea3 = {
        ["Leather + Scrap Metal"] = { { "Pirate Millionaire" }, CFrame.new(-364, 116, 5692) },
        ["Fish Tail"] = { { "Fishman Captain", "Fishman Raider" }, CFrame.new(-10679, 398, -8975) },
        Gunpowder = { { "Pistol Billionaire" }, CFrame.new(-394, 135, 5981) },
        ["Mini Tusk"] = { { "Mythological Pirate" }, CFrame.new(-13510, 584, -6986) },
        ["Conjured Cocoa"] = { { "Cocoa Warrior", "Chocolate Bar Battler" }, CFrame.new(400, 81, -12257) },
        ["Dragon Scale"] = { { "Dragon Crew Archer" }, CFrame.new(6689, 378, 331) },
    },
}

local function GetMaterialData(name)
    local sea = Sea1 and "Sea1" or Sea2 and "Sea2" or Sea3 and "Sea3"
    local entry = sea and MaterialData[sea][name]
    if entry then return { NPCs = entry[1], Position = entry[2] } end
    return { NPCs = nil, Position = nil }
end

local function GetBossList()
    local list = {}
    local function scan(container)
        for _, v in ipairs(container:GetDescendants()) do
            local hum = v:FindFirstChildOfClass("Humanoid")
            if hum and hum.DisplayName:find("Boss") then
                table.insert(list, v.Name)
            end
        end
    end
    scan(RS)
    scan(Enemies)
    return list
end

----------------------------------------------------------------------
-- Stack Farming (prioridade)
----------------------------------------------------------------------
local MasteryMobs = {
    Bone = { "Reborn Skeleton", "Demonic Soul", "Living Zombie", "Possessed Mummy" },
    ["Cake Prince"] = { "Baking Staff", "Head Baker", "Cake Guard", "Cookie Crafter" },
}

local function AnyAliveEnemy()
    for _, mob in pairs(Enemies:GetChildren()) do
        if IsAlive(mob) and mob:FindFirstChild("HumanoidRootPart") then return true end
    end
    return false
end

local StackDefs = {
    { "Auto Farm Level", 1, function()
        local info = GetQuestInfo()
        return info and info[3] and FindEnemy({ info[3] }) ~= nil
    end },
    { "Auto Farm Nearest", 2, AnyAliveEnemy },
    { "Auto Farm Mastery", 3, function()
        local mode = O("Choose Mastery Mode", nil)
        if not mode then return false end
        if mode == "Level" then
            local info = GetQuestInfo()
            return info and info[3] and FindEnemy({ info[3] }) ~= nil
        elseif mode == "Neareast" then
            return AnyAliveEnemy()
        elseif MasteryMobs[mode] then
            return FindEnemy(MasteryMobs[mode]) ~= nil
        end
        return false
    end },
    { "Auto Collect Chest", 4, function()
        for _, c in ipairs(CollectionService:GetTagged("_ChestTagged")) do
            if not c:GetAttribute("IsDisabled") then return true end
        end
        return false
    end },
    { "Auto Collect Berry", 5, function()
        for _, d in pairs(Map:GetDescendants()) do
            if d.Name == "Berries" then
                for i = 1, 8 do
                    if d:GetAttribute("_BerryCFrame" .. i) then return true end
                end
            end
        end
        return false
    end },
    { "Auto Farm Material", 6, function()
        local mat = O("Choose Material", "")
        if mat == "" then return false end
        local data = GetMaterialData(mat)
        return data.NPCs ~= nil and FindEnemy(data.NPCs) ~= nil
    end },
    { "Auto Farm Bones", 7, function()
        return FindEnemy({ "Soul Reaper" }) ~= nil or FindEnemy(MasteryMobs.Bone) ~= nil
    end },
    { "Auto Attack Boss", 8, function()
        local boss = O("Choose Boss", "")
        return boss ~= "" and FindEnemy({ boss }) ~= nil
    end },
    { "Auto Attack All Boss", 9, function()
        for _, c in pairs(RS:GetChildren()) do
            if c:GetAttribute("IsBoss") and c:FindFirstChild("HumanoidRootPart") then return true end
        end
        for _, c in pairs(Enemies:GetChildren()) do
            if c:GetAttribute("IsBoss") and IsAlive(c) and c:FindFirstChild("HumanoidRootPart") then return true end
        end
        return false
    end },
    { "Auto Soul Reaper", 10, function()
        return FindEnemy({ "Soul Reaper" }) ~= nil or HasTool("Hallow Essence")
    end },
    { "Auto Elite Hunter", 11, function()
        return FindEnemy({ "Diablo", "Deandre", "Urban" }) ~= nil or QuestActive()
    end },
    { "Auto Kill Tyrant of the Skies", 12, function() return false end },
    { "Auto Citizen Quest", 13, function()
        return FindEnemy({ "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate" }) ~= nil
    end },
    { "Auto Dough King", 14, function()
        return HasTool("God's Chalice") or HasTool("Sweet Chalice") or FindEnemy({ "Dough King" }) ~= nil
    end },
    { "Auto Cake Prince", 15, function()
        return FindEnemy({ "Cake Prince", "Dough King" }) ~= nil or FindEnemy(MasteryMobs["Cake Prince"]) ~= nil
    end },
}

local function CheckStackPriority(name)
    if not O("Stack Farming Enabled", false) then return true end
    if not O(name, false) then return false end

    local myPriority
    for _, d in ipairs(StackDefs) do
        if d[1] == name then
            myPriority = tonumber(O("Priority: " .. name, d[2])) or d[2]
            break
        end
    end
    if not myPriority then return false end

    for _, d in ipairs(StackDefs) do
        if O(d[1], false) then
            local p = tonumber(O("Priority: " .. d[1], d[2])) or d[2]
            if p < myPriority then
                local ok, res = pcall(d[3])
                if ok and res then return false end
            end
        end
    end
    return true
end

----------------------------------------------------------------------
-- Aim (skills da Mastery) - hook de namecall
----------------------------------------------------------------------
local AimTarget = nil       -- { part, position }
local AimVector = Vector3.zero
local AimStamp = 0

local function AimActive()
    return AimTarget ~= nil and O("Auto Farm Mastery", false)
end

local function GetAimVector()
    if not AimTarget then return Vector3.zero end
    local now = tick()
    if now - AimStamp > 0.1 then
        AimVector = AimTarget[1] and AimTarget[1].Position or AimTarget[2] or Vector3.zero
        AimStamp = now
    end
    return AimVector
end

local function SetAim(part)
    if not part then
        AimTarget = nil
        AimVector = Vector3.zero
        return
    end
    pcall(function()
        local Mouse = require(RS:WaitForChild("Mouse"))
        if Mouse then
            Mouse.Hit = CFrame.new(part.Position)
            Mouse.Target = part
        end
    end)
    AimTarget = { part, part.Position }
    AimVector = part.Position
    AimStamp = tick()
end

task.spawn(function()
    if _G.EnabledAimBot then return end
    _G.EnabledAimBot = true

    pcall(function()
        local main = PlayerGui:FindFirstChild("Main")
        local wn = main and main:FindFirstChild("WhatsNew")
        if wn then wn:Destroy() end
    end)

    pcall(function()
        local wrap = newcclosure or function(f) return f end
        local mt = getrawmetatable(game)
        local oldNamecall, oldIndex, oldNewindex = mt.__namecall, mt.__index, mt.__newindex
        setreadonly(mt, false)

        mt.__namecall = wrap(function(self, a2, a3, ...)
            local extra = table.pack(...)
            local method = getnamecallmethod():lower()

            if tostring(self) == "RemoteEvent" then
                if method == "fireserver" and typeof(a2) == "Vector3" and AimActive() then
                    local v = GetAimVector()
                    if v ~= Vector3.zero then
                        return oldNamecall(self, v, a3, ...)
                    end
                end

                if method == "invokeserver" then
                    local isSkill = table.find({ "Z", "X", "C", "V", "F" }, a2) ~= nil
                    if isSkill and typeof(a3) == "Vector3" then
                        if not select(1, ...) and AimActive() then
                            local v = GetAimVector()
                            if v ~= Vector3.zero then
                                return oldNamecall(self, v, a3, table.unpack(extra, 1, extra.n))
                            end
                        end
                        return oldNamecall(self, a2, a3, table.unpack(extra, 1, extra.n))
                    end
                end
            end

            return oldNamecall(self, a2, a3, ...)
        end)

        mt.__index = wrap(function(self, key)
            if key == "Part_Aim" and AimActive() then
                return AimTarget and AimTarget[1]
            end
            return oldIndex(self, key)
        end)

        mt.__newindex = wrap(function(self, key, value)
            if key == "Part_Aim" and value == nil then
                AimTarget = nil
                AimVector = Vector3.zero
                return
            end
            return oldNewindex(self, key, value)
        end)

        setreadonly(mt, true)
    end)
end)

----------------------------------------------------------------------
-- Server hop / loops
----------------------------------------------------------------------
local function ServerHop(region, maxPlayers)
    maxPlayers = maxPlayers or tonumber(O("Count Player", 5)) or 5
    for page = 1, 100 do
        pcall(function()
            PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = region or "Singapore"
        end)
        local ok, servers = pcall(function() return RS.__ServerBrowser:InvokeServer(page) end)
        if ok and type(servers) == "table" then
            for jobId, info in pairs(servers) do
                if jobId ~= game.JobId and info.Count <= maxPlayers and not string.find(tostring(info.Private), "true") then
                    task.spawn(function() RS.__ServerBrowser:InvokeServer("teleport", jobId) end)
                    return
                end
            end
        end
    end
end

local function CreateLoop(name, fn, delay)
    task.spawn(function()
        while not Fluent.Unloaded do
            if O(name, false) then pcall(fn) end
            task.wait(delay or 0)
        end
    end)
end

local function TweenOffToggle(v)
    if not v then StopTween() end
end

----------------------------------------------------------------------
-- ABA HOME
----------------------------------------------------------------------
local Config = Tabs.Home:AddSection("Configuration")

UIDropdown(Config, "Weapon Tool", "Weapon Tool", "Select weapon type", { "Melee", "Sword", "Blox Fruit", "Gun" }, "Melee")
UIDropdown(Config, "Farm Distance", "Farm Distance", "Distance from enemies", { "10", "20", "30", "40", "50", "60" }, "20")
UIDropdown(Config, "Tween Speed", "Tween Speed", "Movement speed", { "100", "200", "300", "400", "500" }, "300")
UIToggle(Config, "Bring Mob", "Bring Mob", "Pull enemies closer", true)
UIDropdown(Config, "Bring Mob Radius", "Bring Mob Radius", "Pull radius", { "100", "200", "300", "400", "500" }, "300")
UIToggle(Config, "Fast Attack", "Fast Attack", "Faster attack speed", true)
UIToggle(Config, "Auto Dodge Skill", "Auto Dodge Skill", "Dodge enemy skills", false)
UIToggle(Config, "Auto Use Race V3", "Auto Use Race V3", "Auto activate V3", false)
UIToggle(Config, "Auto Use Race V4", "Auto Use Race V4", "Auto activate V4", false)

CreateLoop("Auto Use Race V3", function()
    RS.Remotes.CommE:FireServer("ActivateAbility")
end, 1)

CreateLoop("Auto Use Race V4", function()
    if not LP.Character.RaceTransformed.Value then
        SendKeyPress("Y", 0.1)
    end
end, 1)

local LocalSec = Tabs.Home:AddSection("Local Player")

LocalSec:AddInput("Set Length", { Title = "Dash Length", Default = "", Placeholder = "70" })
LocalSec:AddButton({
    Title = "Apply Dash Length",
    Description = "Apply dash length",
    Callback = function()
        pcall(function()
            LP.Character:SetAttribute("DashLength", tonumber(O("Set Length", "")) or 70)
        end)
    end
})

LocalSec:AddInput("Set Speed", { Title = "Speed Multiplier", Default = "", Placeholder = "1-10" })
LocalSec:AddButton({
    Title = "Apply Speed",
    Description = "Apply speed multiplier",
    Callback = function()
        pcall(function()
            LP.Character:SetAttribute("SpeedMultiplier", tonumber(O("Set Speed", "")) or 3)
        end)
    end
})

local ServerSec = Tabs.Home:AddSection("Server Manager")

UIDropdown(ServerSec, "Count Player", "Max Player Count", "Max players before hop",
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, "5")

ServerSec:AddButton({
    Title = "Hop Server",
    Description = "Teleport to another server",
    Callback = function() ServerHop("Singapore", tonumber(O("Count Player", 5))) end
})

ServerSec:AddButton({
    Title = "Rejoin Server",
    Description = "Reconnect to current server",
    Callback = function() TeleportService:Teleport(game.PlaceId, LP) end
})

local StatSec = Tabs.Home:AddSection("Stat Manager")

UIDropdown(StatSec, "Point Stats", "Points Per Stat", "Points per click",
    { "1", "5", "10", "15", "20", "25", "30", "35", "40", "50" }, "1")

for _, stat in ipairs({ "Melee", "Defense", "Sword", "Gun", "Demon Fruit" }) do
    UIToggle(StatSec, "Auto " .. stat, "Auto " .. stat, "Auto allocate points", false)
    CreateLoop("Auto " .. stat, function()
        FireRemote("AddPoint", stat, tonumber(O("Point Stats", 1)))
    end, 0.2)
end

----------------------------------------------------------------------
-- ABA MAIN
----------------------------------------------------------------------
-- Status --------------------------------------------------------------
local StatusSec = Tabs.Main:AddSection("Server & Player Status")
local StatusPara = StatusSec:AddParagraph({ Title = "Status", Content = "..." })

task.spawn(function()
    pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky") or Lighting:WaitForChild("Sky")
        local data = LP:WaitForChild("Data")
        local leaderstats = LP:WaitForChild("leaderstats")
        local raceC = data:WaitForChild("Race"):WaitForChild("C")
        local vision = LP:WaitForChild("VisionRadius")
        local level = data:WaitForChild("Level")
        local exp = data:WaitForChild("Exp")
        local bounty = leaderstats:WaitForChild("Bounty/Honor")
        local beli = data:WaitForChild("Beli")
        local frags = data:WaitForChild("Fragments")

        local moons = {
            ["http://www.roblox.com/asset/?id=9709149431"] = "Full Moon (5/5)",
            ["http://www.roblox.com/asset/?id=9709149052"] = "Gibbous (4/5)",
            ["http://www.roblox.com/asset/?id=9709143733"] = "Quarter (3/5)",
            ["http://www.roblox.com/asset/?id=9709150401"] = "Crescent (2/5)",
            ["http://www.roblox.com/asset/?id=9709149680"] = "New Moon (1/5)",
        }

        local function fmt(n)
            return n >= 1000000 and string.format("%.1fM", n / 1000000) or tostring(n)
        end

        local function update()
            local moon = sky and moons[sky.MoonTextureId] or "Unknown"
            local text = string.format(
                "Moon: %s\nRace Tier: %s/4\nVision: %s / 5000 XP\nLv. %s | XP: %s (%d%%)\nBounty: %s (%s)\nBeli: %s | Frags: %s",
                moon,
                tostring(raceC.Value),
                tostring(vision.Value),
                tostring(level.Value),
                tostring(exp.Value),
                math.floor(exp.Value / (level.Value * 100 + 50) * 100),
                fmt(bounty.Value), tostring(bounty.Value),
                fmt(beli.Value), tostring(frags.Value)
            )
            SetPara(StatusPara, "Status", text)
        end

        update()
        if sky then sky:GetPropertyChangedSignal("MoonTextureId"):Connect(update) end
        for _, v in ipairs({ raceC, vision, level, exp, bounty, beli, frags }) do
            v.Changed:Connect(update)
        end
    end)
end)

-- Stack farming -------------------------------------------------------
local StackSec = Tabs.Main:AddSection("Stack Farming System")
StackSec:AddParagraph({
    Title = "Priority-Based Farming",
    Content = "Só a feature de maior prioridade com alvo disponível roda."
})
UIToggle(StackSec, "Stack Farming Enabled", "Enable Stack Farming", "Activate priority system", false)

local prioNums = {}
for i = 1, 15 do table.insert(prioNums, tostring(i)) end

for _, d in ipairs({
    { "Auto Farm Level", "1", "Farm quest enemies" },
    { "Auto Farm Nearest", "2", "Farm nearest enemies" },
    { "Auto Farm Mastery", "3", "Farm for mastery" },
    { "Auto Collect Chest", "4", "Collect chests" },
    { "Auto Collect Berry", "5", "Collect berries" },
    { "Auto Farm Material", "6", "Farm materials" },
    { "Auto Farm Bones", "7", "Farm bones" },
    { "Auto Attack Boss", "8", "Attack selected boss" },
    { "Auto Attack All Boss", "9", "Attack all bosses" },
    { "Auto Soul Reaper", "10", "Farm Soul Reaper" },
    { "Auto Elite Hunter", "11", "Hunt elites" },
    { "Auto Citizen Quest", "13", "Complete citizen quests" },
    { "Auto Dough King", "14", "Fight Dough King" },
    { "Auto Cake Prince", "15", "Fight Cake Prince" },
}) do
    UIDropdown(StackSec, "Priority: " .. d[1], "Priority: " .. d[1], d[3], prioNums, d[2])
end

-- Hop Boss ------------------------------------------------------------
local HopSec = Tabs.Main:AddSection("Hop Boss")

local Bosses1 = { "Greybeard", "The Saw", "Saber Expert", "The Gorilla King", "Bobby", "Yeti", "Vice Admiral", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg" }
local Bosses2 = { "Darkbeard", "Cursed Captain", "Order", "Don Swan", "Diamond", "Jeremy", "Fajita", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper" }
local Bosses3 = { "Dough King", "Cake Prince", "rip_indra True Form", "Soul Reaper", "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "Longma" }

UIDropdown(HopSec, "Choose World", "Select World", "Choose world to hop", { "First", "Second", "Third" }, "Third")
UIDropdown(HopSec, "Choose Boss 1", "Select Boss [1st World]", "Boss in first world", Bosses1, "Greybeard")
UIDropdown(HopSec, "Choose Boss 2", "Select Boss [2nd World]", "Boss in second world", Bosses2, "Darkbeard")
UIDropdown(HopSec, "Choose Boss 3", "Select Boss [3rd World]", "Boss in third world", Bosses3, "rip_indra True Form")

local function ParseList(str)
    local out = {}
    for match in str:gmatch("[^%[%],%s]+") do
        local s = match:gsub("^'", ""):gsub("'$", "")
        table.insert(out, tonumber(s) or s)
    end
    return out
end

local function BossServerData(bossName)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end
    local res = req({ Url = "https://prvf.onrender.com/data", Method = "GET" })
    if not res or not res.Body then return nil end
    local data = HttpService:JSONDecode(res.Body)
    local matches = {}
    for id, names in pairs(data) do
        for _, n in pairs(names) do
            if n == bossName then
                table.insert(matches, id)
                break
            end
        end
    end
    if #matches == 0 then return nil end
    return matches[math.random(1, #matches)]
end

HopSec:AddButton({
    Title = "Hop",
    Description = "Find server with boss",
    Callback = function()
        local world = O("Choose World", "Third")
        local boss = (world == "First" and O("Choose Boss 1")) or (world == "Second" and O("Choose Boss 2")) or O("Choose Boss 3")
        local ok, id = pcall(BossServerData, boss)
        if ok and id then
            local parts = ParseList(id)
            if parts[1] and parts[2] then
                Notify("Hop Boss", "JobId: " .. tostring(parts[2]) .. " | Boss: " .. tostring(boss))
                task.wait(1)
                TeleportService:TeleportToPlaceInstance(parts[1], parts[2], LP)
                return
            end
        end
        Notify("Hop Boss", "No server with boss found")
    end
})

-- Level Farming -------------------------------------------------------
local LevelSec = Tabs.Main:AddSection("Level Farming")

local exec = ""
pcall(function() exec = identifyexecutor() or "" end)

if exec:find("Solara") or exec:find("Xeno") then
    LevelSec:AddParagraph({
        Title = "Incompatible Executor",
        Content = "Solara e Xeno não são suportados.\nUse 'Auto Farm Nearest'."
    })
else
    UIToggle(LevelSec, "No Quest", "No Quest Mode", "Skip quests and farm directly", false)
    UIToggle(LevelSec, "Take Quest", "Auto Take Quest", "Auto-accept quests", false)
    UIToggle(LevelSec, "Auto Farm Level", "Auto Farm Level", "Farm based on level", false, TweenOffToggle)

    CreateLoop("Auto Farm Level", function()
        if not CheckStackPriority("Auto Farm Level") then return end
        local info = GetQuestInfo()
        local mob = info[3]

        local function farmOrGo()
            if FindEnemy({ mob }) then
                EngageEnemy({ mob })
            else
                NavigateToSpawn({ mob })
                task.wait(1)
            end
        end

        local noQuest, takeQuest = O("No Quest", false), O("Take Quest", false)

        if noQuest and not takeQuest then
            farmOrGo()
        elseif takeQuest and not noQuest then
            if QuestActive() then
                farmOrGo()
            else
                FireRemote("StartQuest", info[4], info[1])
            end
        elseif QuestActive() then
            farmOrGo()
        else
            local d = GetDistance(info[2])
            if d and d <= 5 then
                FireRemote("StartQuest", info[4], info[1])
            else
                ExecuteTween(info[2])
            end
        end
    end)
end

-- Nearest -------------------------------------------------------------
local NearSec = Tabs.Main:AddSection("Nearest Enemy Farming")

UIDropdown(NearSec, "Neareast Range", "Search Range", "Maximum search distance", { "1000", "2000", "3000", "Infinite" }, "Infinite")
UIToggle(NearSec, "Auto Farm Nearest", "Auto Farm Nearest", "Farm closest enemy", false, TweenOffToggle)

CreateLoop("Auto Farm Nearest", function()
    if not CheckStackPriority("Auto Farm Nearest") then return end
    local range = O("Neareast Range", "Infinite")
    range = (range == "Infinite") and math.huge or tonumber(range)

    local hrp = GetHRP()
    if not hrp then return end

    local best, bestDist = nil, math.huge
    for _, mob in pairs(Enemies:GetChildren()) do
        if mob.PrimaryPart and IsAlive(mob) then
            local m = (mob.PrimaryPart.Position - hrp.Position).Magnitude
            if m < bestDist and m <= range then
                bestDist = m
                best = mob
            end
        end
    end

    if best then EngageEnemy({ best.Name }) end
end)

-- Mastery -------------------------------------------------------------
local MastSec = Tabs.Main:AddSection("Mastery Farming")

UIDropdown(MastSec, "Choose Mastery Mode", "Farm Mode", "Enemy selection mode", { "Level", "Bone", "Cake Prince", "Neareast" }, "Level")
UIDropdown(MastSec, "Choose Mastery Tool", "Weapon Type", "Weapon to gain mastery for", { "Blox Fruit", "Sword", "Gun", "Melee" }, "Blox Fruit")
UIDropdown(MastSec, "Mastery Health", "Health Threshold", "HP % to use skills", { "10", "20", "25", "30", "45", "50", "60", "70", "75", "85", "95" }, "45")
UIDropdown(MastSec, "Skill", "Combat Skills", "Skills to use", { "Z", "X", "C", "V", "F" }, { "Z", "X", "C", "V" }, true)
UIToggle(MastSec, "Auto Farm Mastery", "Auto Farm Mastery", "Farm for mastery", false, function(v)
    if not v then
        StopTween()
        SetAim(nil)
    end
end)

local function MasteryFight(names, mode)
    local mob = FindEnemy(names)
    if not mob then return end
    local pp = mob.PrimaryPart
    local cf = pp.CFrame
    local threshold = tonumber(O("Mastery Health", 45)) or 45
    local height = tonumber(O("Farm Distance", 20)) or 20

    while true do
        task.wait()
        if not mob or not mob.Parent or not IsAlive(mob) then break end
        if not O("Auto Farm Mastery", false) or O("Choose Mastery Mode", "") ~= mode then break end

        local hpPct = mob.Humanoid.Health / mob.Humanoid.MaxHealth * 100
        if hpPct <= threshold then
            EquipToolByTip(O("Choose Mastery Tool", "Blox Fruit"))
            ExecuteTween(cf + Vector3.new(0, height, 1))
            ActivateHaki()
            BringEnemyToPosition(mob, cf)
            SetAim(pp)
            for _, key in ipairs(Selected("Skill")) do
                if IsSkillAvailable(key) then SendKeyPress(key) end
            end
        else
            EquipSelectedTool()
            BringEnemyToPosition(mob, cf)
            ExecuteTween(cf + Vector3.new(0, height, 1))
            ActivateHaki()
        end
    end
    SetAim(nil)
end

CreateLoop("Auto Farm Mastery", function()
    if not CheckStackPriority("Auto Farm Mastery") then return end
    local mode = O("Choose Mastery Mode", "Level")

    if mode == "Level" then
        local info = GetQuestInfo()
        if QuestActive() then
            MasteryFight({ info[3] }, "Level")
        else
            local d = GetDistance(info[2])
            if d and d <= 5 then
                FireRemote("StartQuest", info[4], info[1])
            else
                ExecuteTween(info[2])
            end
        end
    elseif mode == "Bone" then
        MasteryFight(MasteryMobs.Bone, "Bone")
    elseif mode == "Cake Prince" then
        MasteryFight(MasteryMobs["Cake Prince"], "Cake Prince")
    elseif mode == "Neareast" then
        local hrp = GetHRP()
        if not hrp then return end
        local best, bestDist = nil, math.huge
        for _, mob in pairs(Enemies:GetChildren()) do
            if mob.PrimaryPart and IsAlive(mob) then
                local m = (mob.PrimaryPart.Position - hrp.Position).Magnitude
                if m < bestDist and m <= 3500 then
                    bestDist = m
                    best = mob
                end
            end
        end
        if best then MasteryFight({ best.Name }, "Neareast") end
    end
end)

-- Coleta --------------------------------------------------------------
local CollectSec = Tabs.Main:AddSection("Collection Farming")

UIToggle(CollectSec, "Auto Hop If Chest Is Not Found", "Auto Hop If No Chest", "Hop if no chests found", false)
UIToggle(CollectSec, "Disable Auto Collect Chest If Have Item", "Stop on Rare Items", "Stop if rare items owned", false)
local ChestToggle = UIToggle(CollectSec, "Auto Collect Chest", "Auto Collect Chest", "Collect chests", false, TweenOffToggle)

CreateLoop("Auto Collect Chest", function()
    if not CheckStackPriority("Auto Collect Chest") then return end

    if O("Disable Auto Collect Chest If Have Item", false) and (HasTool("God's Chalice") or HasTool("Fist of Darkness")) then
        ChestToggle:SetValue(false)
        return
    end

    if not IsAlive(LP.Character) then return end
    local pos = LP.Character.PrimaryPart.Position

    local best, bestDist = nil, math.huge
    for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
        if not chest:GetAttribute("IsDisabled") then
            local m = (chest:GetPivot().Position - pos).Magnitude
            if m < bestDist then
                bestDist = m
                best = chest
            end
        end
    end

    if best then
        ExecuteTween(best:GetPivot())
    elseif O("Auto Hop If Chest Is Not Found", false) then
        ServerHop("Singapore", 8)
    end
end)

UIToggle(CollectSec, "Auto Collect Berry", "Auto Collect Berry", "Collect berries", false, TweenOffToggle)

CreateLoop("Auto Collect Berry", function()
    if not CheckStackPriority("Auto Collect Berry") then return end
    for _, d in pairs(Map:GetDescendants()) do
        if d.Name == "Berries" then
            for i = 1, 8 do
                if d:GetAttribute("_BerryCFrame" .. i) then
                    ExecuteTween(d.Parent.WorldPivot)
                    for _, child in pairs(d:GetChildren()) do
                        if GetDistance(child.WorldPivot) > 5 then
                            ExecuteTween(child.WorldPivot)
                        else
                            for _, pr in ipairs(Workspace:GetDescendants()) do
                                if pr:IsA("ProximityPrompt") then
                                    local par = pr.Parent
                                    local p = par:IsA("BasePart") and par.Position or (par:IsA("Model") and par:GetPivot().Position)
                                    local hrp = GetHRP()
                                    if p and hrp and (p - hrp.Position).Magnitude <= 10 then
                                        pr.MaxActivationDistance = 10
                                        pcall(function()
                                            pr:InputHoldBegin()
                                            task.wait(pr.HoldDuration + 1)
                                            pr:InputHoldEnd()
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Factory / Pirates Sea ----------------------------------------------
if Sea2 then
    local sec = Tabs.Main:AddSection("Farming Factory")
    UIToggle(sec, "Auto Factory", "Auto Factory", "Destroy factory core", false, TweenOffToggle)
    CreateLoop("Auto Factory", function()
        if FindEnemy({ "Core" }) then
            EngageEnemy({ "Core" })
        else
            ExecuteTween(CFrame.new(502.7349853515625, 143.07490539550781, -379.078125))
        end
    end)
elseif Sea3 then
    local sec = Tabs.Main:AddSection("Farming Pirates Sea")
    UIToggle(sec, "Auto Pirates Sea", "Auto Pirates Sea", "Farm in Pirates Sea", false, TweenOffToggle)
    CreateLoop("Auto Pirates Sea", function()
        local target
        for _, mob in pairs(Enemies:GetChildren()) do
            if mob.Name ~= "rip_indra True Form" and mob.Name ~= "Blank Buddy" then
                local hum = mob:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 and mob.PrimaryPart then
                    if (mob.PrimaryPart.Position - Vector3.new(-5556, 314, -2988)).Magnitude < 700 then
                        target = mob
                        break
                    end
                end
            end
        end
        if target then
            EngageEnemy({ target.Name })
        else
            ExecuteTween(CFrame.new(Vector3.new(-5556, 314, -2988)))
        end
    end)
end

-- Boss ----------------------------------------------------------------
local BossSec = Tabs.Main:AddSection("Boss Farming")

local bossList = GetBossList()
local BossDropdown = UIDropdown(BossSec, "Choose Boss", "Select Boss", "Choose boss to farm", bossList, bossList[1])

BossSec:AddButton({
    Title = "Refresh Boss List",
    Description = "Update boss list",
    Callback = function()
        pcall(function() BossDropdown:SetValues(GetBossList()) end)
    end
})

UIToggle(BossSec, "Auto Attack Boss", "Auto Attack Boss", "Attack selected boss", false, TweenOffToggle)
CreateLoop("Auto Attack Boss", function()
    if not CheckStackPriority("Auto Attack Boss") then return end
    local boss = O("Choose Boss", "")
    if boss ~= "" then EngageEnemy({ boss }) end
end)

UIToggle(BossSec, "Auto Attack All Boss", "Auto Attack All Bosses", "Attack all bosses", false, TweenOffToggle)
CreateLoop("Auto Attack All Boss", function()
    if not CheckStackPriority("Auto Attack All Boss") then return end
    local all = {}
    for _, list in ipairs({ Bosses1, Bosses2, Bosses3 }) do
        for _, n in ipairs(list) do table.insert(all, n) end
    end
    EngageEnemy(all)
end)

-- Material ------------------------------------------------------------
local MatSec = Tabs.Main:AddSection("Material Farming")
local matList = GetMaterialList()

UIDropdown(MatSec, "Choose Material", "Select Material", "Choose material to farm", matList, matList[1])
UIToggle(MatSec, "Auto Farm Material", "Auto Farm Material", "Farm selected material", false, TweenOffToggle)

CreateLoop("Auto Farm Material", function()
    if not CheckStackPriority("Auto Farm Material") then return end
    local data = GetMaterialData(O("Choose Material", ""))
    if data and data.NPCs then
        if FindEnemy(data.NPCs) then
            EngageEnemy(data.NPCs)
        elseif data.Position then
            ExecuteTween(data.Position)
        end
    end
end)

----------------------------------------------------------------------
-- ABA AUTOMATICALLY (Third World)
----------------------------------------------------------------------
-- Swords --------------------------------------------------------------
local SwordSec = Tabs.Auto:AddSection("Third World | Sword Collection")

local swordList = { "Twin Hooks", "Buddy Sword", "Canvander", "Dark Dagger", "Fox Lamp", "Spikey Trident", "Yama", "Hallow Scythe" }
UIDropdown(SwordSec, "Choose Sword", "Select Sword", "Sword to obtain", swordList, swordList[1])
UIToggle(SwordSec, "Auto Get Sword", "Auto Get Sword", "Obtain selected sword", false, TweenOffToggle)

CreateLoop("Auto Get Sword", function()
    local sword = O("Choose Sword", "")

    if sword == "Twin Hooks" then
        EngageEnemy({ "Captain Elephant" })
    elseif sword == "Buddy Sword" then
        EngageEnemy({ "Cake Queen" })
    elseif sword == "Canvander" then
        EngageEnemy({ "Beautiful Pirate" })
    elseif sword == "Dark Dagger" then
        EngageEnemy({ "rip_indra True Form" })
    elseif sword == "Fox Lamp" then
        if Workspace:FindFirstChild("KitsuneIsland") then
            if GetMaterialCount("Azure Ember") >= 20 then
                Net:FindFirstChild("RF/KitsuneStatuePray"):InvokeServer()
            elseif Workspace:FindFirstChild("AttachedAzureEmber") then
                ExecuteTween(Workspace:WaitForChild("EmberTemplate"):FindFirstChild("Part").CFrame, 500)
            end
        end
    elseif sword == "Spikey Trident" then
        EngageEnemy({ "Dough King" })
    elseif sword == "Yama" then
        local progress = FireRemote("EliteHunter", "Progress")
        if type(progress) == "number" and progress >= 30 then
            fireclickdetector(Workspace.Map.Waterfall.SealedKatana.Handle.ClickDetecter)
        end
    elseif sword == "Hallow Scythe" then
        if FindEnemy({ "Soul Reaper" }) then
            EngageEnemy({ "Soul Reaper" })
        elseif HasTool("Hallow Essence") then
            EquipToolByName("Hallow Essence")
            pcall(function() ExecuteTween(Workspace.Map["Haunted Castle"].Summoner.Detection.CFrame) end)
        else
            ExecuteTween(CFrame.new(-9529, 316, 6712))
        end
    end
end)

-- Serpent Bow ---------------------------------------------------------
local GunSec = Tabs.Auto:AddSection("Gun Collection")
UIToggle(GunSec, "Auto Get Serpent Bow", "Auto Get Serpent Bow", "Farm Island Empress for bow", false, TweenOffToggle)

CreateLoop("Auto Get Serpent Bow", function()
    if FindEnemy({ "Island Empress" }) then
        EngageEnemy({ "Island Empress" })
    else
        ExecuteTween(CFrame.new(5659, 602, 244))
    end
end)

-- Bones ---------------------------------------------------------------
local BoneSec = Tabs.Auto:AddSection("Bone Farming")
local BonePara = BoneSec:AddParagraph({ Title = "Bones Collected", Content = "0" })

task.spawn(function()
    while task.wait(2) and not Fluent.Unloaded do
        SetPara(BonePara, "Bones Collected", tostring(GetMaterialCount("Bones")))
    end
end)

UIToggle(BoneSec, "Auto Soul Reaper", "Auto Soul Reaper", "Farm Soul Reaper", false, TweenOffToggle)
CreateLoop("Auto Soul Reaper", function()
    if not CheckStackPriority("Auto Soul Reaper") then return end
    if FindEnemy({ "Soul Reaper" }) then
        EngageEnemy({ "Soul Reaper" })
    elseif HasTool("Hallow Essence") then
        EquipToolByName("Hallow Essence")
        pcall(function() ExecuteTween(Workspace.Map["Haunted Castle"].Summoner.Detection.CFrame) end)
    else
        ExecuteTween(CFrame.new(-9529, 316, 6712))
    end
end)

UIToggle(BoneSec, "Auto Farm Bones", "Auto Farm Bones", "Farm skeletons", false, TweenOffToggle)
CreateLoop("Auto Farm Bones", function()
    if not CheckStackPriority("Auto Farm Bones") then return end
    if FindEnemy({ "Soul Reaper" }) then
        EngageEnemy({ "Soul Reaper" })
    elseif FindEnemy(MasteryMobs.Bone) then
        EngageEnemy(MasteryMobs.Bone)
    else
        ExecuteTween(CFrame.new(-9516.9853515625, 142.47166442871094, 5536.74755859375))
    end
end)

UIToggle(BoneSec, "Auto Trade Bones", "Auto Trade Bones", "Trade bones for rewards", false, TweenOffToggle)
CreateLoop("Auto Trade Bones", function()
    FireRemote("Bones", "Buy", 1, 1)
end, 1)

-- Cake Prince / Dough King -------------------------------------------
local CakeSec = Tabs.Auto:AddSection("Cake Prince & Dough King")
local CakePara = CakeSec:AddParagraph({ Title = "Boss Status", Content = "Checking..." })

task.spawn(function()
    while task.wait(2) and not Fluent.Unloaded do
        pcall(function()
            if FindEnemy({ "Dough King" }) then
                SetPara(CakePara, "Boss Status", "Dough King is Spawned!")
            elseif FindEnemy({ "Cake Prince" }) then
                SetPara(CakePara, "Boss Status", "Cake Prince is Spawned!")
            else
                local prog = "N/A"
                if Sea3 then
                    prog = string.gsub(tostring(CommF:InvokeServer("CakePrinceSpawner", true)), "%D", "")
                end
                SetPara(CakePara, "Boss Status", "Progress: " .. prog .. "%")
            end
        end)
    end
end)

UIToggle(CakeSec, "Auto Cake Prince", "Auto Cake Prince", "Farm Cake Prince", false, TweenOffToggle)
CreateLoop("Auto Cake Prince", function()
    if not CheckStackPriority("Auto Cake Prince") then return end
    local spawnPos = CFrame.new(-2090.6201171875, 70.349876403808594, -12125.5556640625)
    local mirror = Vector3.new(-1990.6726, 4532.9995, -14973.675)

    if FindEnemy({ "Cake Prince", "Dough King" }) then
        if LP:DistanceFromCharacter(mirror) > 5294.99853515625 then
            ExecuteTween(spawnPos)
        else
            local hrp = GetHRP()
            local main = Workspace.Map.CakeLoaf.BigMirror.Main
            if hrp then
                firetouchinterest(hrp, main, 0)
                task.wait()
                firetouchinterest(hrp, main, 1)
            end
        end
    elseif FindEnemy(MasteryMobs["Cake Prince"]) then
        EngageEnemy(MasteryMobs["Cake Prince"])
        local res = CommF:InvokeServer("CakePrinceSpawner", true)
        if res and tostring(res):find("open the portal now") then
            CommF:InvokeServer("CakePrinceSpawner")
        end
    else
        ExecuteTween(CFrame.new(-2072.1494140625, 70.133811950683594, -12097.0849609375))
    end
end)

UIToggle(CakeSec, "Auto Dough King", "Auto Dough King", "Summon and fight Dough King", false, TweenOffToggle)
CreateLoop("Auto Dough King", function()
    if not CheckStackPriority("Auto Dough King") then return end

    if HasTool("God's Chalice") then
        local res = CommF:InvokeServer("SweetChaliceNpc")
        if res and string.find(tostring(res), "Where") then
            EngageEnemy({ "Chocolate Bar Battler", "Cocoa Warrior" })
        else
            CommF:InvokeServer("SweetChaliceNpc")
        end
    elseif HasTool("Sweet Chalice") then
        local res = CommF:InvokeServer("CakePrinceSpawner")
        if res and string.find(tostring(res), "Do you want to open the portal now?") then
            CommF:InvokeServer("CakePrinceSpawner")
        else
            EngageEnemy(MasteryMobs["Cake Prince"])
        end
    elseif FindEnemy({ "Dough King" }) then
        EngageEnemy({ "Dough King" })
    end
end)

-- Elite Hunter --------------------------------------------------------
local EliteSec = Tabs.Auto:AddSection("Elite Hunter")
local EliteStatus = EliteSec:AddParagraph({ Title = "Elite Status", Content = "Checking..." })
local EliteProg = EliteSec:AddParagraph({ Title = "Elite Progress", Content = "0/30" })

task.spawn(function()
    while task.wait(2) and not Fluent.Unloaded do
        SetPara(EliteStatus, "Elite Status", FindEnemy({ "Diablo", "Deandre", "Urban" }) and "Elite is Spawned!" or "Elite is not Spawned")
        pcall(function()
            local prog = Sea3 and tostring(CommF:InvokeServer("EliteHunter", "Progress")) or "N/A"
            SetPara(EliteProg, "Elite Progress", prog .. "/30")
        end)
    end
end)

UIToggle(EliteSec, "Auto Elite Hunter", "Auto Elite Hunter", "Complete elite quests", false, TweenOffToggle)
CreateLoop("Auto Elite Hunter", function()
    if not CheckStackPriority("Auto Elite Hunter") then return end
    local elites = { "Diablo", "Deandre", "Urban" }

    if FindEnemy(elites) and QuestActive() then
        EngageEnemy(elites)
    else
        if HasTool("God's Chalice") then
            FireRemote("requestEntrance", Vector3.new(-12471.17, 374.94025, -7551.6777))
            return
        end
        if not QuestActive() then
            FireRemote("EliteHunter")
        end
    end
end)

-- Haki ----------------------------------------------------------------
local HakiSec = Tabs.Auto:AddSection("Haki Color")

UIToggle(HakiSec, "Auto Buy Haki Color", "Auto Buy Haki Colors", "Purchase all Haki colors", false, TweenOffToggle)
CreateLoop("Auto Buy Haki Color", function()
    FireRemote("ColorsDealer", "1")
    FireRemote("ColorsDealer", "2")
end, 1)

UIToggle(HakiSec, "Auto Rainbow Haki", "Auto Rainbow Haki", "Complete quests for Rainbow Haki", false, TweenOffToggle)
CreateLoop("Auto Rainbow Haki", function()
    local targets = {
        { name = "Stone", pos = CFrame.new(-1049, 40, 6791) },
        { name = "Island Empress", pos = CFrame.new(5730, 602, 199) },
        { name = "Kilo Admiral", pos = CFrame.new(2889, 424, -7233) },
        { name = "Captain Elephant", pos = CFrame.new(-13393, 319, -8423) },
        { name = "Beautiful Pirate", pos = CFrame.new(5241, 23, 129) },
    }

    local engaged = false
    for _, t in ipairs(targets) do
        if FindEnemy({ t.name }) then
            EngageEnemy({ t.name })
            engaged = true
            break
        end
    end

    if not engaged then
        for _, t in ipairs(targets) do
            if not FindEnemy({ t.name }) then
                ExecuteTween(t.pos)
                break
            end
        end
        FireRemote("HornedMan", "Bet")
    end
end)

----------------------------------------------------------------------
-- Settings / addons
----------------------------------------------------------------------
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloxFruitsHub")
SaveManager:SetFolder("BloxFruitsHub/full")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Blox Fruits Hub",
    Content = "Script carregado.",
    Duration = 6
})

SaveManager:LoadAutoloadConfig()
