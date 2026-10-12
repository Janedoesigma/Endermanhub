--[[
    ██╗  ██╗██╗   ██╗██████╗  ██████╗ ██╗   ██╗ █████╗ 
    ██║ ██╔╝╚██╗ ██╔╝██╔══██╗██╔═══██╗██║   ██║██╔══██╗
    █████╔╝  ╚████╔╝ ██████╔╝██║   ██║██║   ██║███████║
    ██╔═██╗   ╚██╔╝  ██╔══██╗██║   ██║╚██╗ ██╔╝██╔══██║
    ██║  ██╗   ██║   ██║  ██║╚██████╔╝ ╚████╔╝ ██║  ██║
    ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝   ╚═══╝  ╚═╝  ╚═╝
    
    Kyrova Hub  |  UI: Vind UI Reborn
    Logic merged from: Speed Hub X + OK Hub
    Icon: rbxassetid://71647128089295
--]]

--============================================================
-- ANTI-DETECTION / LOADER (Speed Hub X)
--============================================================
repeat task.wait() until game:IsLoaded()

local tbl = {
    IsDetected = false,
    _unpack = function(arg, arg2, arg3)
        arg2 = arg2 or 1
        local n = arg3 or #arg
        if n < arg2 then return end
        return arg[arg2], tbl._unpack(arg, arg2 + 1, n)
    end,
    _pcall = function(arg, ...)
        local args = { ... }
        local ok, result = pcall(function()
            return arg(tbl._unpack(args))
        end)
        if not ok then return false, result end
        return true, result
    end,
}

local function _fn() return true end
local v, v2 = tbl._pcall(debug.info, _fn, "f")
if not v or v2 ~= _fn then tbl.IsDetected = true; if LPH_CRASH then LPH_CRASH() end end

local cloneref_ = (cloneref or function(a) return a end)
local RunService_ = cloneref_(game:GetService("RunService"))
if RunService_:IsStudio() then tbl.IsDetected = true end
if RunService_:IsServer() then tbl.IsDetected = true end

pcall(function()
    loadstring([[
        function LPH_NO_VIRTUALIZE(f) return f end;
        function LPH_JIT_MAX(f) return f end;
        function LPH_JIT(f) return f end;
        function LPH_ENCNUM(n, ...) return n end;
        function LPH_ENCSTR(s, ...) return s end;
        function LPH_ENCFUNC(f, ...) return f end;
        function LPH_ENCBUF(b, ...) return b end;
        function LPH_ATTRIBUTES(...) end;
        function LPH_REWRITE(expr, ...) return expr end;
        function LPH_STACKALLOC(size, zeroOrOne) return {} end;
        function LPH_PRECHECK(...) end;
        function VM(...) end; function PRESET(...) end;
        function ENCRYPT(...) end; function OPTIMIZE(...) end;
        function ERROR_HANDLING(...) end; function TRANSFORM(...) end;
        NONE, OPAL, ONYX = 0, 1, 2; FAST, SECURE = 0, 1;
        CONTROL_FLOW, EXTRACT, INLINE, UNROLL, NO_UPVALUES, level = 0, 0, 0, 0, 0, 0;
    ]])()
end)

--============================================================
-- SERVICES & SETUP
--============================================================
local Players           = game:GetService("Players")
local LocalPlayer       = Players.LocalPlayer
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local VIM               = game:GetService("VirtualInputManager")
local VU                = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local TPS               = game:GetService("TeleportService")
local CS                = game:GetService("CollectionService")
local Http              = game:GetService("HttpService")
local UIS               = game:GetService("UserInputService")
local StarterGui        = game:GetService("StarterGui")

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local PlaceId = game.PlaceId
local World1  = PlaceId == 2753915549 or PlaceId == 85211729168715
local World2  = PlaceId == 4442272183 or PlaceId == 79091703265657
local World3  = PlaceId == 7449423635 or PlaceId == 100117331123089

local CommF_  = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local Net     = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
local RegAttack = Net:WaitForChild("RE/RegisterAttack", 10)
local RegHit    = Net:WaitForChild("RE/RegisterHit", 10)

--============================================================
-- GLOBAL STATE
--============================================================
getgenv().K = getgenv().K or {}
local K = getgenv().K

K.WeaponTool      = "Melee"
K.SelectWeapon    = nil
K.TweenSpeed      = 350
K.BringMob        = true
K.BringMobRadius  = 300
K.FastAttack      = true
K.FastAttackDelay = 0
K.FarmDistance    = 20
K.StopItems       = true
K.SafeMode        = false
K._B              = true
K.Seriality       = true
K.RandomCFrame    = false
K.MousePos        = Vector3.zero
K.SoulGuitar      = false

-- Speed Hub style block
local TweenBlock = Workspace:FindFirstChild("KyrovaTweenBlock") or Instance.new("Part")
TweenBlock.Name = "KyrovaTweenBlock"
TweenBlock.Size = Vector3.new(1,1,1)
TweenBlock.Anchored = true
TweenBlock.CanCollide = false
TweenBlock.CanTouch = false
TweenBlock.Transparency = 1
TweenBlock.Parent = Workspace

-- No clip / highlight state
task.spawn(function()
    while task.wait() do
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            if K.shouldTween then
                if not char:FindFirstChild("KyrovaHighlight") then
                    local h = Instance.new("Highlight")
                    h.Name = "KyrovaHighlight"
                    h.Enabled = true
                    h.FillColor = Color3.fromRGB(0,255,254)
                    h.OutlineColor = Color3.fromRGB(0,255,254)
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0.2
                    h.Parent = char
                end
                for _, p in pairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            else
                if char:FindFirstChild("KyrovaHighlight") then
                    char.KyrovaHighlight:Destroy()
                end
            end
        end)
    end
end)

-- Block follower (Speed Hub style)
task.spawn(function()
    local lp = LocalPlayer
    repeat task.wait() until lp.Character and lp.Character.PrimaryPart
    TweenBlock.CFrame = lp.Character.PrimaryPart.CFrame
    while task.wait() do
        pcall(function()
            if K.shouldTween then
                local b = lp.Character and lp.Character.PrimaryPart
                if b then
                    if (b.Position - TweenBlock.Position).Magnitude <= 200 then
                        b.CFrame = TweenBlock.CFrame
                    else
                        TweenBlock.CFrame = b.CFrame
                    end
                end
            end
        end)
    end
end)

--============================================================
-- CORE HELPERS
--============================================================
local function Root()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
K.Root = Root

local function IsAlive(model)
    if not model then return false end
    local h = model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end
K.IsAlive = IsAlive

local function EquipWeapon(name)
    if not name then return end
    local bp = LocalPlayer.Backpack
    local tool = bp and bp:FindFirstChild(name)
    if tool then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(tool) end
    end
end
K.EquipWeapon = EquipWeapon

local function weaponSc(tip)
    local bp = LocalPlayer.Backpack
    if not bp then return end
    for _, v in pairs(bp:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == tip then
            EquipWeapon(v.Name)
            K.SelectWeapon = v.Name
            return
        end
    end
end
K.weaponSc = weaponSc

local function EquipSelected()
    if K.SelectWeapon and LocalPlayer.Backpack:FindFirstChild(K.SelectWeapon) then
        EquipWeapon(K.SelectWeapon)
    else
        weaponSc(K.WeaponTool)
    end
end
K.Equip = EquipSelected

local function SendKey(key, dur)
    dur = dur or 0.05
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(dur)
    VIM:SendKeyEvent(false, key, false, game)
end
K.SendKey = SendKey

local function SendMouseClick()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    task.wait(0.05)
end
K.SendMouseClick = SendMouseClick

local function ActivateHaki()
    local c = LocalPlayer.Character
    if c and not c:FindFirstChild("HasBuso") then
        CommF_:InvokeServer("Buso")
    end
end
K.ActivateHaki = ActivateHaki

--============================================================
-- TWEEN (Speed Hub X style _tp)
--============================================================
function K.Tp(target)
    local cf
    if typeof(target) == "Vector3" then cf = CFrame.new(target)
    elseif typeof(target) == "CFrame" then cf = target
    elseif target and target.CFrame then cf = target.CFrame
    else return end

    local hrp = Root()
    if not hrp then return end

    local dist = (cf.Position - hrp.Position).Magnitude
    if dist > 5000 then
        pcall(function()
            CommF_:InvokeServer("requestEntrance", cf.Position)
        end)
    end

    TweenBlock.CFrame = hrp.CFrame
    local tw = TweenService:Create(TweenBlock, TweenInfo.new(dist/math.max(K.TweenSpeed,1), Enum.EasingStyle.Linear), { CFrame = cf })
    tw:Play()

    task.spawn(function()
        while tw.PlaybackState == Enum.PlaybackState.Playing do
            if K.shouldTween == false and dist > 500 then break end
            RunService.Heartbeat:Wait()
        end
    end)
end
getgenv()._tp = K.Tp
getgenv().toPos = K.Tp

function K.Notween(cf)
    local hrp = Root()
    if hrp then hrp.CFrame = cf end
end
getgenv().notween = K.Notween

--============================================================
-- BRING ENEMY (Speed Hub + OK Hub merge)
--============================================================
function K.BringEnemy(target)
    if not K.BringMob and not K._B then return end
    local hrp = Root(); if not hrp then return end

    local function Network(part)
        if isnetworkowner then return isnetworkowner(part) end
        return part.ReceiveAge == 0 and not part.Anchored and part.Velocity.Magnitude > 0
    end

    -- If no target, find closest
    if not target then
        local closest, dist = nil, math.huge
        for _, e in ipairs(Workspace.Enemies:GetChildren()) do
            if IsAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                local d = (e.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then dist = d; closest = e end
            end
        end
        target = closest
    end
    if not target or not target:FindFirstChild("HumanoidRootPart") then return end

    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            sethiddenproperty(LocalPlayer, "MaxSimulationRadius", math.huge)
        end
    end)

    local targetPos = target.HumanoidRootPart.Position
    local radius = K.BringMobRadius or 300
    local r2 = radius * radius

    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
        if v ~= target and IsAlive(v) and v.Name == target.Name then
            local vhrp = v:FindFirstChild("HumanoidRootPart")
            local vhum = v:FindFirstChildOfClass("Humanoid")
            if vhrp and vhum then
                local dx = vhrp.Position.X - targetPos.X
                local dy = vhrp.Position.Y - targetPos.Y
                local dz = vhrp.Position.Z - targetPos.Z
                if dx*dx + dy*dy + dz*dz <= r2 then
                    if not vhrp:GetAttribute("KyrovaBring") then
                        vhrp:SetAttribute("KyrovaBring", true)
                        vhrp.CanCollide = false
                        vhum.WalkSpeed = 0
                        vhum.JumpPower = 0
                        pcall(function()
                            if Network(vhrp) then
                                vhrp.CFrame = CFrame.new(targetPos)
                            end
                            vhum:ChangeState(Enum.HumanoidStateType.Physics)
                        end)
                        task.delay(0.15, function()
                            if vhrp and vhrp.Parent then
                                vhrp:SetAttribute("KyrovaBring", false)
                            end
                        end)
                    end
                end
            end
        end
    end

    if target:FindFirstChild("HumanoidRootPart") then
        target.HumanoidRootPart.CanCollide = false
        local th = target:FindFirstChildOfClass("Humanoid")
        if th then th.WalkSpeed = 0; th.JumpPower = 0 end
    end
end
getgenv().BringEnemy = K.BringEnemy

--============================================================
-- ATTACK.KILL (Speed Hub + OK Hub)
--============================================================
K.Attack = K.Attack or {}

function K.Attack.Alive(model)
    return IsAlive(model)
end

function K.Attack.Kill(model, enabled)
    if not enabled or not model or not IsAlive(model) then return end
    local hrp = Root(); if not hrp then return end
    local thrp = model:FindFirstChild("HumanoidRootPart"); if not thrp then return end

    EquipSelected()
    ActivateHaki()
    K.BringEnemy(model)

    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local tip = tool and tool.ToolTip or "Melee"

    if tip == "Blox Fruit" then
        K.Tp(thrp.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        K.Tp(thrp.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, math.rad(180), 0))
    end

    if K.RandomCFrame then
        task.wait(0.3)
        K.Tp(thrp.CFrame * CFrame.new(0, 30, 25))
        task.wait(0.3)
        K.Tp(thrp.CFrame * CFrame.new(25, 30, 0))
        task.wait(0.3)
        K.Tp(thrp.CFrame * CFrame.new(-25, 30, 0))
    end
end

function K.Attack.KillSea(model, enabled)
    if not enabled or not model then return end
    local hrp = Root(); if not hrp then return end
    local thrp = model:FindFirstChild("HumanoidRootPart"); if not thrp then return end

    EquipSelected()
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    local tip = tool and tool.ToolTip or "Melee"

    if tip == "Blox Fruit" then
        K.Tp(thrp.CFrame * CFrame.new(0, 10, 0) * CFrame.Angles(0, math.rad(90), 0))
    else
        K.Notween(thrp.CFrame * CFrame.new(0, 50, 8))
        task.wait(0.85)
        K.Notween(thrp.CFrame * CFrame.new(0, 400, 0))
        task.wait(1)
    end
end

K.Attack.Melee = K.Attack.Kill
getgenv().Attack = K.Attack

--============================================================
-- FAST ATTACK (Register Hit - Speed Hub X)
--============================================================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if not K.FastAttack then return end
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not tool then return end
            if not RegAttack or not RegHit then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local hits = {}
            for _, e in ipairs(Workspace.Enemies:GetChildren()) do
                local ehrp = e:FindFirstChild("HumanoidRootPart")
                local ehum = e:FindFirstChildOfClass("Humanoid")
                if ehrp and ehum and ehum.Health > 0 and e ~= char then
                    if (ehrp.Position - hrp.Position).Magnitude <= 60 then
                        table.insert(hits, {e, ehrp})
                    end
                end
            end
            for _, p in ipairs(Workspace.Characters:GetChildren()) do
                if p ~= char and IsAlive(p) then
                    local phrp = p:FindFirstChild("HumanoidRootPart")
                    if phrp and (phrp.Position - hrp.Position).Magnitude <= 60 then
                        table.insert(hits, {p, phrp})
                    end
                end
            end

            if #hits > 0 then
                RegAttack:FireServer(K.FastAttackDelay or 0)
                RegHit:FireServer(hits[1][2], hits)
            end
        end)
    end
end)

--============================================================
-- SKILLS (OK Hub)
--============================================================
function K.UseSkills(weapon, skill)
    weaponSc(weapon)
    if skill then
        SendKey(skill)
    end
end
getgenv().Useskills = K.UseSkills

--============================================================
-- STATS
--============================================================
K.statsSettings = function(stat, value)
    if LocalPlayer.Data.Points.Value ~= 0 then
        CommF_:InvokeServer("AddPoint", stat, value)
    end
end
getgenv().statsSetings = K.statsSettings

--============================================================
-- GET HELPERS (OK Hub)
--============================================================
function K.GetBP(name)
    return LocalPlayer.Backpack:FindFirstChild(name) or LocalPlayer.Character:FindFirstChild(name)
end
getgenv().GetBP = K.GetBP

function K.GetM(name)
    for _, tab in pairs(CommF_:InvokeServer("getInventory")) do
        if type(tab) == "table" and tab.Type == "Material" and tab.Name == name then
            return tab.Count
        end
    end
    return 0
end
getgenv().GetM = K.GetM

function K.GetWP(name)
    for _, v in pairs(CommF_:InvokeServer("getInventory")) do
        if type(v) == "table" and v.Type == "Sword" and v.Name == name then
            return true
        end
    end
    return false
end
getgenv().GetWP = K.GetWP

function K.GetConnectionEnemies(names)
    if type(names) == "string" then names = {names} end
    for _, v in ipairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("Model") and table.find(names, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
    for _, v in ipairs(Workspace.Enemies:GetChildren()) do
        if v:IsA("Model") and table.find(names, v.Name) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            return v
        end
    end
end
getgenv().GetConnectionEnemies = K.GetConnectionEnemies

--============================================================
-- HOP (OK Hub / Speed Hub)
--============================================================
function K.Hop()
    pcall(function()
        local ok, servers = pcall(function()
            return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
        end)
        if ok and servers then
            for _, s in ipairs(servers) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
    end)
end
getgenv().Hop = K.Hop

--============================================================
-- GET QUEST DATA (OK Hub - simplified)
--============================================================
function K.GetQuestInfo()
    local lvl = LocalPlayer.Data.Level.Value
    local Quests = require(ReplicatedStorage:WaitForChild("Quests"))
    local GuideModule = require(ReplicatedStorage:WaitForChild("GuideModule"))
    local blacklist = {"MarineQuest", "BartiloQuest", "CitizenQuest", "Trainees"}
    local result = {mob = nil, id = nil, quest = nil, lvl = 0, cframe = nil}

    local highLvl = 0
    for name, quests in pairs(Quests) do
        if not table.find(blacklist, name) then
            for id, q in pairs(quests) do
                if lvl >= q.LevelReq and q.LevelReq > highLvl then
                    for mobName, _ in pairs(q.Task) do
                        highLvl = q.LevelReq
                        result.mob = mobName
                        result.id = id
                        result.quest = name
                        result.lvl = q.LevelReq
                    end
                end
            end
        end
    end

    if GuideModule and GuideModule.Data and GuideModule.Data.LastClosestNPC then
        for _, npc in pairs(Workspace.NPCs:GetChildren()) do
            if npc.Name == GuideModule.Data.LastClosestNPC and npc:FindFirstChild("HumanoidRootPart") then
                result.cframe = npc.HumanoidRootPart.CFrame
            end
        end
        for _, npc in pairs(ReplicatedStorage.NPCs:GetChildren()) do
            if npc.Name == GuideModule.Data.LastClosestNPC and npc:FindFirstChild("HumanoidRootPart") then
                result.cframe = npc.HumanoidRootPart.CFrame
            end
        end
    end

    return result
end

function K.isQuestOn()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if gui and gui:FindFirstChild("Quest") then
        return gui.Quest.Visible
    end
    return false
end
getgenv().isQuestOn = K.isQuestOn

--============================================================
-- DYNAMIC WEAPON SELECT (Speed Hub style)
--============================================================
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local bp = LocalPlayer.Backpack
            if not bp then return end
            for _, v in pairs(bp:GetChildren()) do
                if v:IsA("Tool") and v.ToolTip == K.WeaponTool then
                    K.SelectWeapon = v.Name
                    break
                end
            end
        end)
    end
end)

--============================================================
-- MONITOR SKILL USAGE (Speed Hub)
--============================================================
task.spawn(function()
    local function monitor(char)
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = hum:FindFirstChildOfClass("Animator")
        if not anim then return end
        anim.AnimationPlayed:Connect(function(track)
            if K.AutoDodgeSkill and track and track.Animation then
                local t = math.max(track.TimePosition or 1.5, 1.5)
                if tick() < (_G.KDodgeTime or 0) then
                    _G.KDodgeTime = _G.KDodgeTime + math.floor(t)
                else
                    _G.KDodgeTime = tick() + math.floor(t)
                end
            end
        end)
    end
    if LocalPlayer.Character then monitor(LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(monitor)
end)

--============================================================
-- NAME CALL HOOK (OK Hub - For Sea Beasts/Skills aiming)
--============================================================
pcall(function()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local args = {...}
        if tostring(method) == "FireServer" then
            if tostring(args[1]) == "RemoteEvent" then
                if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
                    if K.SeaAim or K.UseMousePos then
                        args[2] = K.MousePos
                        return old(unpack(args))
                    end
                end
            end
        end
        return old(...)
    end)
    setreadonly(mt, true)
end)

--============================================================
-- VIND UI REBORN
--============================================================
local VindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skinny-yz/vindUI-Test/main/full.luau"))()

VindUI:SetTheme("Dark")
VindUI:PreloadIcons({ "Lucide", "Material", "Phosphor", "SF" })
VindUI:SetScaleRange(0.75, 1.35)

local Window = VindUI:CreateWindow({
    Title     = "Kyrova Hub",
    Subtitle  = "Blox Fruits · Powered by SpeedHubX + OKHub Logic",
    Icon      = "rbxassetid://71647128089295",
    Size      = UDim2.fromOffset(760, 520),
    MinSize   = Vector2.new(600, 420),
    Draggable = true,
    Resizable = true,
    UseBlur   = true,
    DefaultTab= "Info",
    TabWidth  = 155,
    UserInfo  = { Enabled = true, Avatar = "player", NameMode = "display" },
})

VindUI:Notify({
    Title = "Kyrova Hub",
    Text  = "Carregado. Ícone: 71647128089295. Bom farm!",
    Type  = "success",
    Duration = 5,
})

local MainGroup = Window:AddTabGroup({ Name = "KYROVA HUB" })

--============================================================
-- TAB: INFO & STATUS
--============================================================
local InfoTab = MainGroup:AddTab({ Name = "Info", Icon = "rbxassetid://71647128089295" })
InfoTab:AddParagraph({
    Title = "Kyrova Hub Status",
    Icon  = "Lucide:sparkles",
    Text  = "Monitoramento em tempo real do servidor.",
})
InfoTab:AddDivider()

local pMirage   = InfoTab:AddParagraph({ Title = "Mirage Island", Text = "..." })
local pKitsune  = InfoTab:AddParagraph({ Title = "Kitsune Island", Text = "..." })
local pPrehis   = InfoTab:AddParagraph({ Title = "Prehistoric Island", Text = "..." })
local pFrozen   = InfoTab:AddParagraph({ Title = "Frozen Dimension", Text = "..." })
local pCake     = InfoTab:AddParagraph({ Title = "Cake Prince", Text = "..." })
local pDough    = InfoTab:AddParagraph({ Title = "Dough King", Text = "..." })
local pRip      = InfoTab:AddParagraph({ Title = "Rip Indra", Text = "..." })
local pMoon     = InfoTab:AddParagraph({ Title = "Full Moon", Text = "..." })
local pBones    = InfoTab:AddParagraph({ Title = "Bones", Text = "..." })
local pTime     = InfoTab:AddParagraph({ Title = "Time", Text = "..." })
local pElite    = InfoTab:AddParagraph({ Title = "Elite Hunter", Text = "..." })
local pTyrant   = InfoTab:AddParagraph({ Title = "Tyrant of the Skies", Text = "..." })

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local w = Workspace._WorldOrigin
            pMirage:Set({ Title = "Mirage Island", Text = w and w.Locations:FindFirstChild("Mirage Island") and "✅ Spawnado" or "❌" })
            pKitsune:Set({ Title = "Kitsune Island", Text = Workspace.Map:FindFirstChild("KitsuneIsland") and "✅ Spawnado" or "❌" })
            pPrehis:Set({ Title = "Prehistoric Island", Text = w and w.Locations:FindFirstChild("Prehistoric Island") and "✅ Spawnado" or "❌" })
            pFrozen:Set({ Title = "Frozen Dimension", Text = w and w.Locations:FindFirstChild("Frozen Dimension") and "✅ Spawnado" or "❌" })
        end)
        pcall(function()
            local cp = CommF_:InvokeServer("CakePrinceSpawner")
            local txt = "Não spawnado"
            if type(cp) == "string" and string.len(cp) >= 86 then
                txt = "Killed: " .. tostring(cp):sub(39,41)
            end
            pCake:Set({ Title = "Cake Prince", Text = txt })
        end)
        pcall(function()
            local d = ReplicatedStorage:FindFirstChild("Dough King") or Workspace.Enemies:FindFirstChild("Dough King")
            pDough:Set({ Title = "Dough King", Text = d and "✅" or "❌" })
        end)
        pcall(function()
            local r = ReplicatedStorage:FindFirstChild("rip_indra True Form") or Workspace.Enemies:FindFirstChild("rip_indra")
            pRip:Set({ Title = "Rip Indra", Text = r and "✅" or "❌" })
        end)
        pcall(function()
            local sky = Lighting:FindFirstChildOfClass("Sky")
            local moon = sky and sky.MoonTextureId or ""
            local t = "Desconhecido"
            if moon:find("9709149431") then t = "5/5 Full Moon ✅"
            elseif moon:find("9709149052") then t = "4/5"
            elseif moon:find("9709143733") then t = "3/5"
            elseif moon:find("9709150401") then t = "2/5"
            elseif moon:find("9709149680") then t = "1/5" end
            pMoon:Set({ Title = "Full Moon", Text = t })
        end)
        pcall(function()
            local b = CommF_:InvokeServer("Bones", "Check")
            pBones:Set({ Title = "Bones", Text = tostring(b) .. " bones" })
        end)
        pcall(function()
            pTime:Set({ Title = "Time", Text = os.date("%d/%m/%Y %H:%M:%S") })
        end)
        pcall(function()
            local prog = CommF_:InvokeServer("EliteHunter", "Progress")
            pElite:Set({ Title = "Elite Hunter", Text = tostring(prog) .. "/30" })
        end)
        pcall(function()
            pTyrant:Set({ Title = "Tyrant of the Skies", Text = Workspace.Enemies:FindFirstChild("Tyrant of the Skies") and "✅" or "❌" })
        end)
    end
end)

--============================================================
-- TAB: MAIN (Farming)
--============================================================
local MainTab = MainGroup:AddTab({ Name = "Main", Icon = "Lucide:swords" })

MainTab:AddSection("Farming Core")
MainTab:AddToggle({
    Text = "Auto Farm Level",
    Description = "Farm por quest/level (Speed Hub X)",
    Flag = "AutoFarmLevel",
    Default = false,
    Callback = function(v) K.T_FarmLevel = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Nearest",
    Description = "Farm inimigo mais próximo",
    Flag = "AutoFarmNearest",
    Default = false,
    Callback = function(v) K.T_FarmNearest = v end,
})
MainTab:AddToggle({
    Text = "Auto Factory Raid",
    Description = "Ataca o Core da Factory (World 2)",
    Flag = "AutoFactory",
    Default = false,
    Callback = function(v) K.T_Factory = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Ectoplasm",
    Description = "Farm Ectoplasm no Cursed Ship",
    Flag = "AutoEcto",
    Default = false,
    Callback = function(v) K.T_Ecto = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Chest & Rare Items")
MainTab:AddToggle({
    Text = "Auto Collect Chest",
    Description = "Coleta todos os baús (Speed Hub)",
    Flag = "AutoChest",
    Default = false,
    Callback = function(v) K.T_Chest = v end,
})
MainTab:AddToggle({
    Text = "Stop on Rare Items",
    Description = "Para o chest farm ao pegar Chalice/Fist",
    Flag = "StopRare",
    Default = true,
    Callback = function(v) K.StopItems = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Berry")
MainTab:AddToggle({
    Text = "Auto Farm Berry",
    Flag = "AutoBerry",
    Default = false,
    Callback = function(v) K.T_Berry = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Berry + Hop",
    Flag = "AutoBerryHop",
    Default = false,
    Callback = function(v) K.T_BerryHop = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Farm Mob")
local mobList = World1 and {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer"}
    or World2 and {"Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire"}
    or {"Pirate Millionaire","Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Forest Pirate","Mythological Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Cookie Crafter"}

MainTab:AddDropdown({
    Text = "Select Mob",
    Options = mobList,
    Default = mobList[1],
    Callback = function(v) K.SelectedMob = v end,
})
MainTab:AddToggle({
    Text = "Auto Kill Mob",
    Flag = "AutoKillMob",
    Default = false,
    Callback = function(v) K.T_KillMob = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Boss / Elite")
MainTab:AddToggle({
    Text = "Auto Farm Elite",
    Flag = "AutoElite",
    Default = false,
    Callback = function(v) K.T_Elite = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Elite + Hop",
    Flag = "AutoEliteHop",
    Default = false,
    Callback = function(v) K.T_EliteHop = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Cake Prince",
    Flag = "AutoCakePrince",
    Default = false,
    Callback = function(v) K.T_CakePrince = v end,
})
MainTab:AddToggle({
    Text = "Auto Summon Cake Prince",
    Flag = "AutoSummonCP",
    Default = false,
    Callback = function(v) K.T_SummonCP = v end,
})
MainTab:AddToggle({
    Text = "Auto Dough King",
    Flag = "AutoDoughKing",
    Default = false,
    Callback = function(v) K.T_DoughKing = v end,
})
MainTab:AddToggle({
    Text = "Auto Attack Rip Indra",
    Flag = "AutoRipIndra",
    Default = false,
    Callback = function(v) K.T_RipIndra = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Boss TOTS",
    Description = "Tyrant of the Skies",
    Flag = "AutoTyrant",
    Default = false,
    Callback = function(v) K.T_Tyrant = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Soul Reaper / Bones")
MainTab:AddToggle({
    Text = "Auto Soul Reaper",
    Flag = "AutoSoulReaper",
    Default = false,
    Callback = function(v) K.T_SoulReaper = v end,
})
MainTab:AddToggle({
    Text = "Auto Farm Bones",
    Flag = "AutoFarmBones",
    Default = false,
    Callback = function(v) K.T_FarmBones = v end,
})
MainTab:AddToggle({
    Text = "Auto Trade Bones",
    Flag = "AutoTradeBones",
    Default = false,
    Callback = function(v) K.T_TradeBones = v end,
})
MainTab:AddToggle({
    Text = "Auto Random Bones",
    Flag = "AutoRandomBones",
    Default = false,
    Callback = function(v) K.T_RandomBones = v end,
})
MainTab:AddToggle({
    Text = "Auto Try Luck Gravestone",
    Flag = "TryLuck",
    Default = false,
    Callback = function(v) K.T_TryLuck = v end,
})
MainTab:AddToggle({
    Text = "Auto Pray Gravestone",
    Flag = "Pray",
    Default = false,
    Callback = function(v) K.T_Pray = v end,
})

MainTab:AddDivider()
MainTab:AddSection("Mastery")
MainTab:AddDropdown({
    Text = "Mastery Island",
    Options = {"Cake", "Bone"},
    Default = "Bone",
    Callback = function(v) K.MasteryIsland = v end,
})
MainTab:AddToggle({
    Text = "Auto Mastery Fruit",
    Flag = "MasteryFruit",
    Default = false,
    Callback = function(v) K.T_MasteryFruit = v end,
})
MainTab:AddToggle({
    Text = "Auto Mastery Gun",
    Flag = "MasteryGun",
    Default = false,
    Callback = function(v) K.T_MasteryGun = v end,
})
MainTab:AddToggle({
    Text = "Auto Mastery Sword",
    Flag = "MasterySword",
    Default = false,
    Callback = function(v) K.T_MasterySword = v end,
})

--============================================================
-- TAB: FISHING
--============================================================
local FishTab = MainGroup:AddTab({ Name = "Fishing", Icon = "Lucide:fish" })

FishTab:AddDropdown({
    Text = "Select Fishing Rod",
    Options = {"Fishing Rod","Gold Rod","Shark Rod","Shell Rod","Treasure Rod"},
    Default = "Fishing Rod",
    Callback = function(v) K.Rod = v end,
})
FishTab:AddDropdown({
    Text = "Select Bait",
    Options = {"Basic Bait","Kelp Bait","Good Bait","Abyssal Bait","Frozen Bait","Epic Bait","Carnivore Bait"},
    Default = "Basic Bait",
    Callback = function(v) K.Bait = v end,
})
FishTab:AddToggle({ Text = "Auto Buy Bait", Flag = "AutoBuyBait", Default = false, Callback = function(v) K.T_BuyBait = v end })
FishTab:AddToggle({ Text = "Auto Fishing", Flag = "AutoFishing", Default = false, Callback = function(v) K.T_Fishing = v end })
FishTab:AddToggle({ Text = "Auto Quest Fishing", Flag = "AutoFishQuest", Default = false, Callback = function(v) K.T_FishQuest = v end })
FishTab:AddToggle({ Text = "Auto Complete Quest", Flag = "AutoFishComplete", Default = false, Callback = function(v) K.T_FishComplete = v end })
FishTab:AddToggle({ Text = "Auto Sell Fish", Flag = "AutoSellFish", Default = false, Callback = function(v) K.T_SellFish = v end })
FishTab:AddToggle({ Text = "Auto Spam Skill Z", Flag = "AutoSpamZ", Default = false, Callback = function(v) K.T_SpamZ = v end })

--============================================================
-- TAB: QUESTS
--============================================================
local QuestTab = MainGroup:AddTab({ Name = "Quests", Icon = "Lucide:scroll" })

QuestTab:AddSection("Sea Progress")
QuestTab:AddToggle({ Text = "Auto Quest Sea 2", Flag = "QuestSea2", Default = false, Callback = function(v) K.T_Sea2 = v end })
QuestTab:AddToggle({ Text = "Auto Quest Sea 3", Flag = "QuestSea3", Default = false, Callback = function(v) K.T_Sea3 = v end })

QuestTab:AddDivider()
QuestTab:AddSection("Swords")
local swordsToggles = {
    {"Auto Saber", "T_Saber"},
    {"Auto Tushita", "T_Tushita"},
    {"Auto Yama", "T_Yama"},
    {"Auto CDK (Last)", "T_CDK"},
    {"Auto Yama CDK", "T_YamaCDK"},
    {"Auto Tushita CDK", "T_TushitaCDK"},
    {"Auto Saw", "T_Saw"},
    {"Auto Bisento", "T_Bisento"},
    {"Auto Warden Sword", "T_Warden"},
    {"Auto Rengoku", "T_Rengoku"},
    {"Auto Key Rengoku", "T_KeyRen"},
    {"Auto Dragon Trident", "T_Trident"},
    {"Auto Canvander", "T_Canvander"},
    {"Auto Twin Hooks", "T_TwinHooks"},
    {"Auto Serpent Bow", "T_SerpentBow"},
    {"Auto Long Sword", "T_LongSword"},
    {"Auto Dark Blade V3", "T_DarkBlade"},
}
for _, entry in ipairs(swordsToggles) do
    QuestTab:AddToggle({
        Text = entry[1], Flag = entry[2], Default = false,
        Callback = function(v) K[entry[2]] = v end,
    })
end

QuestTab:AddDivider()
QuestTab:AddSection("Fighting Styles")
local stylesToggles = {
    {"Auto Superhuman", "T_Superhuman"},
    {"Auto Death Step", "T_DeathStep"},
    {"Auto Sharkman Karate", "T_Sharkman"},
    {"Auto Electric Claw", "T_ElectricClaw"},
    {"Auto Dragon Talon", "T_DragonTalon"},
    {"Auto Godhuman", "T_Godhuman"},
    {"Auto Sanguine Art", "T_Sanguine"},
}
for _, entry in ipairs(stylesToggles) do
    QuestTab:AddToggle({
        Text = entry[1], Flag = entry[2], Default = false,
        Callback = function(v) K[entry[2]] = v end,
    })
end

QuestTab:AddDivider()
QuestTab:AddSection("Race / Haki")
QuestTab:AddToggle({ Text = "Auto V2", Flag = "AutoV2", Default = false, Callback = function(v) K.T_V2 = v end })
QuestTab:AddToggle({ Text = "Auto V3", Flag = "AutoV3", Default = false, Callback = function(v) K.T_V3 = v end })
QuestTab:AddToggle({ Text = "Auto Trial", Flag = "AutoTrial", Default = false, Callback = function(v) K.T_Trial = v end })
QuestTab:AddToggle({ Text = "Auto Kill Player After Trial", Flag = "KillAfterTrial", Default = false, Callback = function(v) K.T_KillAfterTrial = v end })
QuestTab:AddToggle({ Text = "Auto Observation (Ken)", Flag = "AutoKen", Default = false, Callback = function(v) K.T_Ken = v end })
QuestTab:AddToggle({ Text = "Auto Rainbow Haki", Flag = "AutoRainbowHaki", Default = false, Callback = function(v) K.T_RainbowHaki = v end })
QuestTab:AddToggle({ Text = "Auto Pull Lever", Flag = "PullLever", Default = false, Callback = function(v) K.T_PullLever = v end })
QuestTab:AddToggle({ Text = "Auto Train V4", Flag = "TrainV4", Default = false, Callback = function(v) K.T_TrainV4 = v end })

QuestTab:AddDivider()
QuestTab:AddSection("Misc Quests")
QuestTab:AddToggle({ Text = "Auto Bartilo Quest", Flag = "Bartilo", Default = false, Callback = function(v) K.T_Bartilo = v end })
QuestTab:AddToggle({ Text = "Auto Citizen Quest", Flag = "Citizen", Default = false, Callback = function(v) K.T_Citizen = v end })
QuestTab:AddToggle({ Text = "Auto Training Dummy", Flag = "Dummy", Default = false, Callback = function(v) K.T_Dummy = v end })
QuestTab:AddToggle({ Text = "Auto Skull Guitar", Flag = "SkullGuitar", Default = false, Callback = function(v) K.T_SkullGuitar = v end })
QuestTab:AddToggle({ Text = "Auto Farm Material Skull Guitar", Flag = "SkullGuitarMat", Default = false, Callback = function(v) K.T_SkullGuitarMat = v end })

--============================================================
-- TAB: VOLCANO / PREHISTORIC
--============================================================
local VolTab = MainGroup:AddTab({ Name = "Volcano", Icon = "Lucide:flame" })

VolTab:AddButton({
    Text = "Teleport To Dragon Dojo",
    Callback = function()
        CommF_:InvokeServer("requestEntrance", Vector3.new(5661.53, 1013.09, -334.96))
        K.Tp(CFrame.new(5814.43, 1208.33, 884.58))
    end,
})
VolTab:AddToggle({ Text = "Auto Dojo Trainer", Flag = "Dojo", Default = false, Callback = function(v) K.T_Dojo = v end })
VolTab:AddToggle({ Text = "Auto Dragon Hunter", Flag = "BlazeEM", Default = false, Callback = function(v) K.T_DragonHunter = v end })
VolTab:AddToggle({ Text = "Tween To Upgrade Drago Trial", Flag = "UpgradeDrago", Default = false, Callback = function(v) K.T_UpgradeDrago = v end })
VolTab:AddToggle({ Text = "Auto Drago V1", Flag = "DragoV1", Default = false, Callback = function(v) K.T_DragoV1 = v end })
VolTab:AddToggle({ Text = "Auto Drago V2", Flag = "DragoV2", Default = false, Callback = function(v) K.T_DragoV2 = v end })
VolTab:AddToggle({ Text = "Auto Drago V3", Flag = "DragoV3", Default = false, Callback = function(v) K.T_DragoV3 = v end })
VolTab:AddToggle({ Text = "Auto Train Drago V4", Flag = "TrainDrago", Default = false, Callback = function(v) K.T_TrainDrago = v end })
VolTab:AddToggle({ Text = "Swap Drago Race", Flag = "SwapDrago", Default = false, Callback = function(v) K.T_SwapDrago = v end })
VolTab:AddToggle({ Text = "Upgrade Dragon Talon With Uzoth", Flag = "TalonUzoth", Default = false, Callback = function(v) K.T_TalonUzoth = v end })

VolTab:AddDivider()
VolTab:AddSection("Prehistoric")
VolTab:AddToggle({ Text = "Auto Find Prehistoric Island", Flag = "FindPrehis", Default = false, Callback = function(v) K.T_FindPrehis = v end })
VolTab:AddToggle({ Text = "Auto Summon Prehistoric Island", Flag = "SummonPrehis", Default = false, Callback = function(v) K.T_SummonPrehis = v end })
VolTab:AddToggle({ Text = "Tween To Prehistoric Island", Flag = "TweenPrehis", Default = false, Callback = function(v) K.T_TweenPrehis = v end })
VolTab:AddToggle({ Text = "Auto Start Prehistoric Event", Flag = "StartPrehis", Default = false, Callback = function(v) K.T_StartPrehis = v end })
VolTab:AddToggle({ Text = "Auto Patch Prehistoric Event", Flag = "PatchPrehis", Default = false, Callback = function(v) K.T_PatchPrehis = v end })
VolTab:AddToggle({ Text = "Auto Collect Dino Bones", Flag = "DinoBones", Default = false, Callback = function(v) K.T_DinoBones = v end })
VolTab:AddToggle({ Text = "Auto Collect Dragon Eggs", Flag = "DragonEggs", Default = false, Callback = function(v) K.T_DragonEggs = v end })
VolTab:AddButton({ Text = "Craft Dragonheart", Callback = function() CommF_:InvokeServer("CraftItem", "Craft", "Dragonheart") end })
VolTab:AddButton({ Text = "Craft Dragonstorm", Callback = function() CommF_:InvokeServer("CraftItem", "Craft", "Dragonstorm") end })
VolTab:AddButton({ Text = "Craft Dino Hood", Callback = function() CommF_:InvokeServer("CraftItem", "Craft", "DinoHood") end })
VolTab:AddButton({ Text = "Craft T-Rex Skull", Callback = function() CommF_:InvokeServer("CraftItem", "Craft", "TRexSkull") end })

--============================================================
-- TAB: ESP / STATS
--============================================================
local EspTab = MainGroup:AddTab({ Name = "ESP & Stats", Icon = "Lucide:eye" })

EspTab:AddSection("Stats Upgrade")
local statsValue = 10
EspTab:AddSlider({
    Text = "Stats Value", Min = 0, Max = 1000, Default = 10,
    Callback = function(v) statsValue = v end,
})
local statToggles = {
    {"Auto Melee", "AutoMelee", "Melee"},
    {"Auto Sword", "AutoSword", "Sword"},
    {"Auto Gun", "AutoGun", "Gun"},
    {"Auto Blox Fruit", "AutoDevil", "Demon Fruit"},
    {"Auto Defense", "AutoDefense", "Defense"},
}
for _, s in ipairs(statToggles) do
    EspTab:AddToggle({
        Text = s[1], Flag = s[2], Default = false,
        Callback = function(v) K[s[2]] = v; K[s[2].."_stat"] = s[3] end,
    })
end

EspTab:AddDivider()
EspTab:AddSection("ESP Visual")

local EspNumber = math.random(1, 1e6)
local function clearESP(classifier)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local tag = p.Character.Head:FindFirstChild("KyrovaESP" .. EspNumber)
            if tag then tag:Destroy() end
        end
    end
    for _, c in ipairs(CS:GetTagged("_ChestTagged")) do
        local tag = c:FindFirstChild("KyrovaChestESP")
        if tag then tag:Destroy() end
    end
end

local function espLoop()
    task.spawn(function()
        while K.T_EspPlayer or K.T_EspChest or K.T_EspFruit do
            local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            if head then
                if K.T_EspPlayer then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                            local ph = p.Character.Head
                            if not ph:FindFirstChild("KyrovaESP" .. EspNumber) then
                                local bb = Instance.new("BillboardGui", ph)
                                bb.Name = "KyrovaESP" .. EspNumber
                                bb.Size = UDim2.new(1, 200, 1, 30)
                                bb.StudsOffset = Vector3.new(0, 3, 0)
                                bb.AlwaysOnTop = true
                                local lbl = Instance.new("TextLabel", bb)
                                lbl.Size = UDim2.new(1,0,1,0)
                                lbl.BackgroundTransparency = 1
                                lbl.TextStrokeTransparency = 0.5
                                lbl.TextColor3 = p.Team == LocalPlayer.Team and Color3.new(0,0,1) or Color3.new(1,0,0)
                                lbl.Font = Enum.Font.Code
                                lbl.TextSize = 14
                                lbl.Text = p.Name
                            end
                        end
                    end
                end
                if K.T_EspChest then
                    for _, chest in ipairs(CS:GetTagged("_ChestTagged")) do
                        if not chest:GetAttribute("IsDisabled") and not chest:FindFirstChild("KyrovaChestESP") then
                            local bb = Instance.new("BillboardGui", chest)
                            bb.Name = "KyrovaChestESP"
                            bb.Size = UDim2.new(1, 200, 1, 30)
                            bb.StudsOffset = Vector3.new(0, 3, 0)
                            bb.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
                            lbl.Font = Enum.Font.Code
                            lbl.Text = "Chest"
                        end
                    end
                end
                if K.T_EspFruit then
                    for _, f in ipairs(Workspace:GetChildren()) do
                        if f.Name:find("Fruit") and f:FindFirstChild("Handle") and not f.Handle:FindFirstChild("KyrovaFruitESP") then
                            local bb = Instance.new("BillboardGui", f.Handle)
                            bb.Name = "KyrovaFruitESP"
                            bb.Size = UDim2.new(1, 200, 1, 30)
                            bb.StudsOffset = Vector3.new(0, 2, 0)
                            bb.AlwaysOnTop = true
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                            lbl.Font = Enum.Font.Code
                            lbl.Text = f.Name
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

EspTab:AddToggle({
    Text = "ESP Player", Flag = "EspPlayer", Default = false,
    Callback = function(v) K.T_EspPlayer = v; if v then espLoop() else clearESP() end end,
})
EspTab:AddToggle({
    Text = "ESP Chest", Flag = "EspChest", Default = false,
    Callback = function(v) K.T_EspChest = v; if v then espLoop() end end,
})
EspTab:AddToggle({
    Text = "ESP Fruit", Flag = "EspFruit", Default = false,
    Callback = function(v) K.T_EspFruit = v; if v then espLoop() end end,
})

--============================================================
-- TAB: FRUITS & RAID
--============================================================
local FruitTab = MainGroup:AddTab({ Name = "Fruits & Raid", Icon = "Lucide:apple" })

FruitTab:AddSection("Fruit Options")
FruitTab:AddToggle({ Text = "Auto Random Fruit", Flag = "RandomFruit", Default = false, Callback = function(v) K.T_RandomFruit = v end })
FruitTab:AddToggle({ Text = "Auto Drop Fruit", Flag = "DropFruit", Default = false, Callback = function(v) K.T_DropFruit = v end })
FruitTab:AddToggle({ Text = "Auto Store Fruit", Flag = "StoreFruit", Default = false, Callback = function(v) K.T_StoreFruit = v end })
FruitTab:AddToggle({ Text = "Auto Tween to Fruit", Flag = "TweenFruit", Default = false, Callback = function(v) K.T_TweenFruit = v end })
FruitTab:AddToggle({ Text = "Auto Collect Fruit", Flag = "CollectFruit", Default = false, Callback = function(v) K.T_CollectFruit = v end })
FruitTab:AddToggle({ Text = "Auto Buy Fruits Sniper", Flag = "FruitSniper", Default = false, Callback = function(v) K.T_FruitSniper = v end })

FruitTab:AddDivider()
FruitTab:AddSection("Raid")

local chipList = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
FruitTab:AddDropdown({
    Text = "Select Chip",
    Options = chipList,
    Default = "Flame",
    Callback = function(v) K.SelectedChip = v end,
})
FruitTab:AddToggle({ Text = "Auto Buy Chip [Beli]", Flag = "ChipBeli", Default = false, Callback = function(v) K.T_ChipBeli = v end })
FruitTab:AddToggle({ Text = "Auto Buy Chip [Fruit]", Flag = "ChipFruit", Default = false, Callback = function(v) K.T_ChipFruit = v end })
FruitTab:AddToggle({ Text = "Auto Start Raid", Flag = "StartRaid", Default = false, Callback = function(v) K.T_StartRaid = v end })
FruitTab:AddToggle({ Text = "Auto Raid + Next Island", Flag = "Raiding", Default = false, Callback = function(v) K.T_Raiding = v end })
FruitTab:AddToggle({ Text = "Auto Farm Dungeon", Flag = "FarmDungeon", Default = false, Callback = function(v) K.T_FarmDungeon = v end })
FruitTab:AddToggle({ Text = "Auto Awakening", Flag = "Awakening", Default = false, Callback = function(v) K.T_Awakening = v end })
FruitTab:AddButton({ Text = "Buy Microchip Law", Callback = function() CommF_:InvokeServer("BlackbeardReward","Microchip","2") end })

--============================================================
-- TAB: LOCAL PLAYER
--============================================================
local LPTab = MainGroup:AddTab({ Name = "Local Player", Icon = "Lucide:user" })

LPTab:AddSection("Combat")
LPTab:AddToggle({ Text = "Auto Enable PvP", Flag = "AutoPvP", Default = false, Callback = function(v) K.T_AutoPvP = v end })
LPTab:AddToggle({ Text = "Auto Safe Mode", Flag = "SafeMode", Default = false, Callback = function(v) K.SafeMode = v end })
LPTab:AddToggle({ Text = "Auto Kill Player Quest", Flag = "AutoKillPlayer", Default = false, Callback = function(v) K.T_AutoKillPlayer = v end })
LPTab:AddToggle({ Text = "Auto Get PlayerQuest", Flag = "AutoGetPlayerQuest", Default = false, Callback = function(v) K.T_AutoGetPlayerQuest = v end })

LPTab:AddDivider()
LPTab:AddSection("Infinite Abilities")
LPTab:AddToggle({ Text = "Instance Energy [INF]", Flag = "InfEnergy", Default = false, Callback = function(v) K.T_InfEnergy = v end })
LPTab:AddToggle({ Text = "Instance Soru [INF]", Flag = "InfSoru", Default = false, Callback = function(v) K.T_InfSoru = v end })
LPTab:AddToggle({ Text = "Instance Observation Range [INF]", Flag = "InfObRange", Default = false, Callback = function(v) K.T_InfObRange = v end })
LPTab:AddToggle({ Text = "Instance Mink V3 [INF]", Flag = "InfMink", Default = false, Callback = function(v) K.T_InfMink = v end })
LPTab:AddToggle({ Text = "Dash No Cooldown", Flag = "NoCD", Default = false, Callback = function(v) K.T_NoCD = v end })

--============================================================
-- TAB: TELEPORT
--============================================================
local TpTab = MainGroup:AddTab({ Name = "Teleport", Icon = "Lucide:map-pin" })

TpTab:AddSection("Worlds")
TpTab:AddButton({ Text = "World 1 (East Blue)", Callback = function() CommF_:InvokeServer("TravelMain") end })
TpTab:AddButton({ Text = "World 2 (Dressrosa)", Callback = function() CommF_:InvokeServer("TravelDressrosa") end })
TpTab:AddButton({ Text = "World 3 (Zou)", Callback = function() CommF_:InvokeServer("TravelZou") end })

TpTab:AddDivider()
TpTab:AddSection("Islands")

local islands = {}
for _, v in ipairs(Workspace._WorldOrigin.Locations:GetChildren()) do
    table.insert(islands, v.Name)
end

TpTab:AddDropdown({
    Text = "Select Island",
    Options = islands,
    Default = islands[1] or "Starting Island",
    Callback = function(v) K.SelectedIsland = v end,
})
TpTab:AddToggle({
    Text = "Auto Travel", Flag = "AutoTravel", Default = false,
    Callback = function(v) K.T_AutoTravel = v end,
})

TpTab:AddDivider()
TpTab:AddSection("NPCs")
local npcList = {}
for _, v in ipairs(ReplicatedStorage:FindFirstChild("NPCs"):GetChildren()) do table.insert(npcList, v.Name) end
TpTab:AddDropdown({
    Text = "Select NPC",
    Options = npcList,
    Default = npcList[1] or "",
    Callback = function(v) K.SelectedNPC = v end,
})
TpTab:AddToggle({ Text = "Auto Tween To NPC", Flag = "TweenNPC", Default = false, Callback = function(v) K.T_TweenNPC = v end })

--============================================================
-- TAB: SHOP
--============================================================
local ShopTab = MainGroup:AddTab({ Name = "Shop", Icon = "Lucide:shopping-cart" })

ShopTab:AddSection("Haki")
ShopTab:AddButton({ Text = "Buy Buso", Callback = function() CommF_:InvokeServer("BuyHaki","Buso") end })
ShopTab:AddButton({ Text = "Buy Geppo", Callback = function() CommF_:InvokeServer("BuyHaki","Geppo") end })
ShopTab:AddButton({ Text = "Buy Soru", Callback = function() CommF_:InvokeServer("BuyHaki","Soru") end })
ShopTab:AddButton({ Text = "Buy Ken", Callback = function() CommF_:InvokeServer("KenTalk","Buy") end })

ShopTab:AddDivider()
ShopTab:AddSection("Fighting Styles")
local styleButtons = {
    {"Black Leg","BuyBlackLeg"},{"Electro","BuyElectro"},{"Fishman Karate","BuyFishmanKarate"},
    {"Superhuman","BuySuperhuman"},{"Death Step","BuyDeathStep"},{"Sharkman Karate","BuySharkmanKarate"},
    {"Electric Claw","BuyElectricClaw"},{"Dragon Talon","BuyDragonTalon"},{"Godhuman","BuyGodhuman"},
}
for _, b in ipairs(styleButtons) do
    ShopTab:AddButton({ Text = "Buy " .. b[1], Callback = function() CommF_:InvokeServer(b[2]) end })
end

ShopTab:AddDivider()
ShopTab:AddSection("Fragments")
ShopTab:AddButton({ Text = "Refund Stats", Callback = function() CommF_:InvokeServer("BlackbeardReward","Refund","2") end })
ShopTab:AddButton({ Text = "Reroll Race", Callback = function() CommF_:InvokeServer("BlackbeardReward","Reroll","2") end })
ShopTab:AddButton({ Text = "Buy Ghoul Race", Callback = function() CommF_:InvokeServer("Ectoplasm","Change", 4) end })
ShopTab:AddButton({ Text = "Buy Cyborg Race", Callback = function() CommF_:InvokeServer("CyborgTrainer","Buy") end })

ShopTab:AddDivider()
ShopTab:AddSection("Weapons")
local weapons = {
    "Katana","Cutlass","Iron Mace","Dual Katana","Triple Katana","Pipe",
    "Dual-Headed Blade","Bisento","Soul Cane","Slingshot","Musket","Flintlock",
    "Refined Slingshot","Refined Flintlock","Cannon",
}
for _, w in ipairs(weapons) do
    ShopTab:AddButton({ Text = "Buy " .. w, Callback = function() CommF_:InvokeServer("BuyItem", w) end })
end

--============================================================
-- TAB: MISC
--============================================================
local MiscTab = MainGroup:AddTab({ Name = "Misc", Icon = "Lucide:settings" })

MiscTab:AddSection("Server")
MiscTab:AddButton({ Text = "Rejoin Server", Callback = function() TPS:Teleport(game.PlaceId, LocalPlayer) end })
MiscTab:AddButton({ Text = "Hop Server (Low Players)", Callback = function() K.Hop() end })
MiscTab:AddButton({ Text = "Copy JobID", Callback = function() if setclipboard then setclipboard(game.JobId) end end })
MiscTab:AddButton({
    Text = "Redeem All Codes",
    Callback = function()
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
        local RedeemRemote = ReplicatedStorage.Remotes:FindFirstChild("Redeem")
        if not RedeemRemote then return end
        for _, code in ipairs(codes) do
            task.wait(0.1)
            pcall(function()
                RedeemRemote:InvokeServer(code)
            end)
        end
    end,
})

MiscTab:AddDivider()
MiscTab:AddSection("Team")
MiscTab:AddButton({ Text = "Join Pirates", Callback = function() CommF_:InvokeServer("SetTeam","Pirates") end })
MiscTab:AddButton({ Text = "Join Marines", Callback = function() CommF_:InvokeServer("SetTeam","Marines") end })

MiscTab:AddDivider()
MiscTab:AddSection("GUI")
MiscTab:AddToggle({ Text = "Disable Chat", Flag = "DisableChat", Default = false, Callback = function(v) StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v) end })
MiscTab:AddToggle({ Text = "Disable Leaderboard", Flag = "DisableLB", Default = false, Callback = function(v) StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v) end })

MiscTab:AddDivider()
MiscTab:AddSection("Graphics")
MiscTab:AddToggle({
    Text = "Full Bright", Flag = "FullBright", Default = false,
    Callback = function(v)
        if v then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.ColorShift_Bottom = Color3.new(1,1,1)
            Lighting.ColorShift_Top = Color3.new(1,1,1)
        else
            Lighting.Ambient = Color3.new(0,0,0)
        end
    end,
})
MiscTab:AddToggle({
    Text = "Walk on Water", Flag = "WalkWater", Default = false,
    Callback = function(v)
        local plane = Workspace.Map:FindFirstChild("WaterBase-Plane")
        if plane then
            plane.Size = v and Vector3.new(1000, 112, 1000) or Vector3.new(1000, 80, 1000)
        end
    end,
})
MiscTab:AddToggle({
    Text = "Remove Damage Numbers", Flag = "NoDamage", Default = false,
    Callback = function(v)
        local dc = ReplicatedStorage:FindFirstChild("Assets") and ReplicatedStorage.Assets:FindFirstChild("GUI") and ReplicatedStorage.Assets.GUI:FindFirstChild("DamageCounter")
        if dc then dc.Enabled = not v end
    end,
})
MiscTab:AddToggle({
    Text = "Remove Notifications", Flag = "NoNotify", Default = false,
    Callback = function(v)
        if LocalPlayer.PlayerGui:FindFirstChild("Notifications") then
            LocalPlayer.PlayerGui.Notifications.Enabled = not v
        end
    end,
})

--============================================================
-- TAB: SETTINGS
--============================================================
local SetTab = MainGroup:AddTab({ Name = "Settings", Icon = "Lucide:sliders" })

SetTab:AddSection("Combat Config (Speed Hub)")
SetTab:AddToggle({
    Text = "Kill Aura",
    Description = "Mata inimigos em 500 studs (Volcano Event)",
    Flag = "KillAura",
    Default = false,
    Callback = function(v) K.T_KillAura = v end,
})
SetTab:AddDropdown({
    Text = "Weapon Tool",
    Options = {"Melee", "Sword", "Blox Fruit", "Gun"},
    Default = "Melee",
    Callback = function(v) K.WeaponTool = v end,
})
SetTab:AddDropdown({
    Text = "Tween Speed",
    Options = {"100", "200", "300", "400", "500"},
    Default = "300",
    Callback = function(v) K.TweenSpeed = tonumber(v) or 300 end,
})
SetTab:AddToggle({
    Text = "Bring Mob",
    Flag = "BringMob",
    Default = true,
    Callback = function(v) K.BringMob = v end,
})
SetTab:AddDropdown({
    Text = "Bring Mob Radius",
    Options = {"100", "200", "300", "400", "500"},
    Default = "300",
    Callback = function(v) K.BringMobRadius = tonumber(v) or 300 end,
})
SetTab:AddToggle({
    Text = "Fast Attack",
    Flag = "FastAttack",
    Default = true,
    Callback = function(v) K.FastAttack = v end,
})
SetTab:AddToggle({
    Text = "Auto Dodge Skill",
    Flag = "AutoDodge",
    Default = false,
    Callback = function(v) K.AutoDodgeSkill = v end,
})

SetTab:AddDivider()
SetTab:AddSection("Race / Haki (OK Hub)")
SetTab:AddToggle({
    Text = "Auto Turn On V3", Flag = "AutoV3Turn", Default = false,
    Callback = function(v) K.T_AutoV3 = v end,
})
SetTab:AddToggle({
    Text = "Auto Turn On V4", Flag = "AutoV4Turn", Default = false,
    Callback = function(v) K.T_AutoV4 = v end,
})
SetTab:AddToggle({
    Text = "Auto Turn On Buso", Flag = "AutoBuso", Default = false,
    Callback = function(v) K.T_AutoBuso = v end,
})
SetTab:AddToggle({
    Text = "Auto Haki Observation", Flag = "AutoKen", Default = false,
    Callback = function(v) K.T_AutoKen = v end,
})

SetTab:AddDivider()
SetTab:AddSection("Anti / Safety")
SetTab:AddToggle({
    Text = "Anti AFK", Flag = "AntiAFK", Default = true,
    Callback = function(v)
        if v then
            LocalPlayer.Idled:Connect(function()
                VU:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                VU:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end)
        end
    end,
})
SetTab:AddToggle({
    Text = "Auto Anti Admin Join Server", Flag = "AntiAdmin", Default = false,
    Callback = function(v) K.T_AntiAdmin = v end,
})
SetTab:AddToggle({
    Text = "Disable Notify", Flag = "DisableNotify", Default = false,
    Callback = function(v)
        if LocalPlayer.PlayerGui:FindFirstChild("Notifications") then
            LocalPlayer.PlayerGui.Notifications.Enabled = not v
        end
    end,
})
SetTab:AddToggle({
    Text = "Safe Mode (Foge se HP baixo)", Flag = "SafeMode", Default = false,
    Callback = function(v) K.SafeMode = v end,
})

--============================================================
-- CORE LOOPS
--============================================================

-- Auto Farm Level
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_FarmLevel then continue end
        pcall(function()
            local q = K.GetQuestInfo()
            if not q or not q.mob then return end
            if K.isQuestOn() then
                local enemy = K.GetConnectionEnemies(q.mob)
                if enemy then
                    repeat
                        task.wait()
                        K.Attack.Kill(enemy, true)
                    until not K.T_FarmLevel or not IsAlive(enemy)
                else
                    local spawns = Workspace["_WorldOrigin"].EnemySpawns
                    for _, sp in ipairs(spawns:GetChildren()) do
                        if sp.Name:find(q.mob) then
                            K.Tp(sp.CFrame * CFrame.new(0, 30, 0))
                            break
                        end
                    end
                end
            else
                if q.cframe then
                    K.Tp(q.cframe)
                    if Root() and (Root().Position - q.cframe.Position).Magnitude <= 8 then
                        CommF_:InvokeServer("StartQuest", q.quest, q.id)
                    end
                else
                    CommF_:InvokeServer("StartQuest", q.quest, q.id)
                end
            end
        end)
    end
end)

-- Auto Farm Nearest
task.spawn(function()
    while task.wait(0.3) do
        if not K.T_FarmNearest then continue end
        pcall(function()
            local hrp = Root(); if not hrp then return end
            local closest, dist = nil, math.huge
            for _, e in ipairs(Workspace.Enemies:GetChildren()) do
                if IsAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                    local d = (e.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if d < dist then dist = d; closest = e end
                end
            end
            if closest then
                repeat task.wait() K.Attack.Kill(closest, true) until not K.T_FarmNearest or not IsAlive(closest)
            end
        end)
    end
end)

-- Auto Factory
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_Factory then continue end
        pcall(function()
            local core = K.GetConnectionEnemies("Core")
            if core then
                repeat task.wait()
                    K.Tp(CFrame.new(448.47, 199.36, -441.39))
                    K.Attack.Kill(core, true)
                until not K.T_Factory or not IsAlive(core)
            else
                K.Tp(CFrame.new(448.47, 199.36, -441.39))
            end
        end)
    end
end)

-- Auto Ectoplasm
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_Ecto then continue end
        pcall(function()
            local target = K.GetConnectionEnemies({"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Arctic Warrior"})
            if target then
                repeat task.wait() K.Attack.Kill(target, true) until not K.T_Ecto or not IsAlive(target)
            else
                CommF_:InvokeServer("requestEntrance", Vector3.new(923.21, 126.98, 32852.83))
            end
        end)
    end
end)

-- Auto Chest
task.spawn(function()
    while task.wait(0.3) do
        if not K.T_Chest then continue end
        pcall(function()
            local hrp = Root(); if not hrp then return end
            local near, nd = nil, math.huge
            for _, chest in ipairs(CS:GetTagged("_ChestTagged")) do
                if not chest:GetAttribute("IsDisabled") then
                    local d = (chest:GetPivot().Position - hrp.Position).Magnitude
                    if d < nd then nd = d; near = chest end
                end
            end
            if near then K.Tp(near:GetPivot()) end

            if K.StopItems then
                local function has(name)
                    return (LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild(name)) or
                           (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(name))
                end
                if has("God's Chalice") or has("Sweet Chalice") or has("Fist of Darkness") then
                    K.T_Chest = false
                end
            end
        end)
    end
end)

-- Auto Berry
task.spawn(function()
    while task.wait(0.3) do
        if not K.T_Berry then continue end
        pcall(function()
            local bushes = CS:GetTagged("BerryBush")
            for _, bush in ipairs(bushes) do
                for _, attr in pairs(bush:GetAttributes()) do
                    if type(attr) == "string" then
                        K.Tp(bush.Parent:GetPivot())
                        for _, child in ipairs(bush:GetChildren()) do
                            if child:FindFirstChild("ProximityPrompt") then
                                K.Tp(child.WorldPivot)
                                fireproximityprompt(child.ProximityPrompt, math.huge)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Kill Mob
task.spawn(function()
    while task.wait(0.2) do
        if not K.T_KillMob or not K.SelectedMob then continue end
        pcall(function()
            local e = K.GetConnectionEnemies(K.SelectedMob)
            if e then
                repeat task.wait() K.Attack.Kill(e, true) until not K.T_KillMob or not IsAlive(e)
            end
        end)
    end
end)

-- Auto Elite
task.spawn(function()
    while task.wait(1) do
        if not K.T_Elite then continue end
        pcall(function()
            if not K.isQuestOn() then
                CommF_:InvokeServer("EliteHunter")
            else
                local e = K.GetConnectionEnemies({"Diablo","Deandre","Urban"})
                if e then
                    repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e) or not K.isQuestOn()
                end
            end
        end)
    end
end)

-- Auto Elite + Hop
task.spawn(function()
    while task.wait(1.5) do
        if not K.T_EliteHop then continue end
        pcall(function()
            if not K.isQuestOn() then
                local r = CommF_:InvokeServer("EliteHunter")
                if r == nil or (type(r) == "string" and string.find(r, "Cooldown")) then
                    K.Hop()
                end
            else
                local e = K.GetConnectionEnemies({"Diablo","Deandre","Urban"})
                if e then
                    repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e) or not K.isQuestOn()
                else
                    K.Hop()
                end
            end
        end)
    end
end)

-- Auto Cake Prince
task.spawn(function()
    while task.wait(0.3) do
        if not K.T_CakePrince then continue end
        pcall(function()
            local mirror = Workspace.Map:FindFirstChild("CakeLoaf") and Workspace.Map.CakeLoaf:FindFirstChild("BigMirror")
            if not mirror then
                K.Tp(CFrame.new(-2077, 252, -12373))
                return
            end
            if mirror.Other.Transparency == 0 then
                local boss = K.GetConnectionEnemies({"Cake Prince","Dough King"})
                if boss then
                    repeat task.wait() K.Attack.Kill(boss, true) until not IsAlive(boss)
                else
                    K.Tp(CFrame.new(-2151.82, 149.32, -12404.91))
                end
            else
                local mob = K.GetConnectionEnemies({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"})
                if mob then
                    repeat task.wait() K.Attack.Kill(mob, true) until not IsAlive(mob) or (mirror and mirror.Other.Transparency == 0)
                else
                    K.Tp(CFrame.new(-2077, 252, -12373))
                end
            end
        end)
    end
end)

-- Auto Summon Cake Prince
task.spawn(function()
    while task.wait(2) do
        if not K.T_SummonCP then continue end
        pcall(function()
            local mirror = Workspace.Map.CakeLoaf:FindFirstChild("BigMirror")
            if not mirror or mirror.Other.Transparency == 0 then return end
            if Workspace.Enemies:FindFirstChild("Cake Prince") then return end
            CommF_:InvokeServer("CakePrinceSpawner", true)
        end)
    end
end)

-- Auto Dough King
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_DoughKing then continue end
        pcall(function()
            local dk = K.GetConnectionEnemies("Dough King")
            if dk then
                repeat task.wait() K.Attack.Kill(dk, true) until not IsAlive(dk)
            else
                K.Tp(CFrame.new(-1943.67, 251.50, -12337.88))
            end
        end)
    end
end)

-- Auto Rip Indra
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_RipIndra then continue end
        pcall(function()
            local r = K.GetConnectionEnemies("rip_indra")
            if r then
                repeat task.wait() K.Attack.Kill(r, true) until not IsAlive(r)
            else
                CommF_:InvokeServer("requestEntrance", Vector3.new(-5097.93, 316.44, -3142.66))
                task.wait(0.3)
                K.Tp(CFrame.new(-5344.82, 423.98, -2725.09))
            end
        end)
    end
end)

-- Auto Tyrant
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_Tyrant then continue end
        pcall(function()
            local boss = Workspace.Enemies:FindFirstChild("Tyrant of the Skies")
            if boss and IsAlive(boss) then
                repeat task.wait() K.Attack.Kill(boss, true) until not IsAlive(boss)
            else
                local mob = K.GetConnectionEnemies({"Serpent Hunter","Skull Slayer","Isle Champion","Sun-kissed Warrior"})
                if mob then
                    repeat task.wait() K.Attack.Kill(mob, true) until not IsAlive(mob)
                else
                    K.Tp(CFrame.new(-16268.29, 152.62, 1390.77))
                end
            end
        end)
    end
end)

-- Auto Soul Reaper
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_SoulReaper then continue end
        pcall(function()
            local sr = K.GetConnectionEnemies("Soul Reaper")
            if sr then
                repeat task.wait() K.Attack.Kill(sr, true) until not IsAlive(sr)
            elseif K.GetBP("Hallow Essence") then
                EquipWeapon("Hallow Essence")
                K.Tp(CFrame.new(-8932.32, 146.83, 6062.55))
            else
                CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end
        end)
    end
end)

-- Auto Farm Bones
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_FarmBones then continue end
        pcall(function()
            local bones = {"Reborn Skeleton","Demonic Soul","Living Zombie","Possessed Mummy"}
            local e = K.GetConnectionEnemies(bones)
            if e then
                repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e)
            else
                K.Tp(CFrame.new(-9516.98, 142.47, 5536.74))
            end
        end)
    end
end)

-- Auto Trade Bones
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_TradeBones then continue end
        pcall(function() CommF_:InvokeServer("Bones", "Buy", 1, 1) end)
    end
end)

-- Auto Random Bones
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_RandomBones then continue end
        pcall(function() CommF_:InvokeServer("Bones", "Buy", 1, 1) end)
    end
end)

-- Auto Try Luck / Pray
task.spawn(function()
    local cfr = CFrame.new(-8761.31, 164.85, 6161.15)
    while task.wait(0.3) do
        if K.T_TryLuck then
            pcall(function()
                if (Root().Position - cfr.Position).Magnitude > 5 then
                    K.Tp(cfr)
                else
                    CommF_:InvokeServer("gravestoneEvent", 1)
                end
            end)
        end
        if K.T_Pray then
            pcall(function()
                if (Root().Position - cfr.Position).Magnitude > 5 then
                    K.Tp(cfr)
                else
                    CommF_:InvokeServer("gravestoneEvent", 2)
                end
            end)
        end
    end
end)

-- Auto Mastery (Fruit/Gun/Sword)
task.spawn(function()
    while task.wait(0.4) do
        pcall(function()
            local island = K.MasteryIsland or "Bone"
            local mob = island == "Cake" and "Cookie Crafter" or "Reborn Skeleton"
            local pos = island == "Cake" and CFrame.new(-1943.67, 251.5, -12337.88) or CFrame.new(-9495.68, 453.58, 5977.34)

            if K.T_MasteryFruit then
                local e = K.GetConnectionEnemies(mob)
                if e then
                    repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e)
                else K.Tp(pos) end
            end
            if K.T_MasterySword then
                local e = K.GetConnectionEnemies(mob)
                if e then
                    repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e)
                else K.Tp(pos) end
            end
            if K.T_MasteryGun then
                local e = K.GetConnectionEnemies(mob)
                if e then
                    repeat task.wait()
                        weaponSc("Gun")
                        local g = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if g and g.ToolTip == "Gun" then
                            local shoot = Net:FindFirstChild("RE/ShootGunEvent")
                            if shoot then
                                K.MousePos = e.HumanoidRootPart.Position
                                shoot:FireServer(K.MousePos, {e.HumanoidRootPart})
                            end
                            SendMouseClick()
                        end
                    until not IsAlive(e)
                else K.Tp(pos) end
            end
        end)
    end
end)

-- Auto Fishing (OK Hub)
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_Fishing then continue end
        pcall(function()
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not tool or tool:GetAttribute("InventoryCategory") ~= "Rod" then
                if K.Rod and LocalPlayer.Backpack:FindFirstChild(K.Rod) then
                    char.Humanoid:EquipTool(LocalPlayer.Backpack[K.Rod])
                end
                return
            end

            local FishRep = ReplicatedStorage:FindFirstChild("FishReplicated")
            if not FishRep then return end
            local FishingReq = FishRep:FindFirstChild("FishingRequest")

            local state = tool:GetAttribute("State")
            local serverState = tool:GetAttribute("ServerState")

            if state == "ReeledIn" or serverState == "ReeledIn" then
                FishingReq:InvokeServer("StartCasting")
                task.wait(0.5)
                if FishingReq then
                    FishingReq:InvokeServer("CastLineAtLocation", char.HumanoidRootPart.Position + Vector3.new(0, -5, -20), 100, true)
                end
            elseif state == "Biting" or serverState == "Biting" then
                FishingReq:InvokeServer("Catching", true)
                task.wait(0.15)
                FishingReq:InvokeServer("Catch", 1)
            end
        end)
    end
end)

-- Auto Buy Bait / Fishing Quest / Sell Fish
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            local RF = ReplicatedStorage.Modules.Net:FindFirstChild("RF/JobsRemoteFunction")
            local RFCraft = ReplicatedStorage.Modules.Net:FindFirstChild("RF/Craft")
            if K.T_BuyBait and K.Bait and RFCraft then
                pcall(function() RFCraft:InvokeServer("Craft", K.Bait, {}) end)
            end
            if K.T_SellFish and RF then
                pcall(function() RF:InvokeServer("FishingNPC", "SellFish") end)
            end
            if K.T_FishComplete and RF then
                pcall(function() RF:InvokeServer("FishingNPC", "FinishQuest") end)
            end
            if K.T_FishQuest and RF then
                pcall(function() RF:InvokeServer("FishingNPC", "Angler", "AskQuest") end)
            end
            if K.T_SpamZ then
                local ability = ReplicatedStorage.Modules.Net:FindFirstChild("RF/JobToolAbilities")
                if ability then
                    pcall(function() ability:InvokeServer("Z", true) end)
                end
            end
        end)
    end
end)

-- Kill Aura (Volcano event)
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_KillAura then continue end
        pcall(function()
            local hrp = Root(); if not hrp then return end
            if sethiddenproperty then sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge) end
            for _, e in ipairs(Workspace.Enemies:GetChildren()) do
                if IsAlive(e) and e:FindFirstChild("HumanoidRootPart") then
                    if (e.HumanoidRootPart.Position - hrp.Position).Magnitude <= 500 then
                        e.Humanoid.Health = 0
                    end
                end
            end
        end)
    end
end)

-- Auto V3 / V4 / Buso / Ken
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if K.T_AutoBuso then
                local c = LocalPlayer.Character
                if c and not c:FindFirstChild("HasBuso") then
                    CommF_:InvokeServer("Buso")
                end
            end
            if K.T_AutoKen then
                ReplicatedStorage.Remotes.CommE:FireServer("Ken", true)
            end
            if K.T_AutoV3 then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility")
            end
            if K.T_AutoV4 then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("RaceEnergy") and c.RaceEnergy.Value == 1 then
                    SendKey("Y")
                end
            end
        end)
    end
end)

-- Anti Admin Join
task.spawn(function()
    local blacklist = {
        "red_game43","rip_indra","Axiore","Polkster","wenlocktoad","Daigrock",
        "Uzi","Azarth","Lunoven","TheGreateAced","rip_fud","Hingoi","Death_King",
    }
    while task.wait(1.5) do
        if not K.T_AntiAdmin then continue end
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if table.find(blacklist, p.Name) then
                    K.Hop()
                    return
                end
            end
        end)
    end
end)

-- Safe Mode
task.spawn(function()
    while task.wait(0.3) do
        if not K.SafeMode then continue end
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health / hum.MaxHealth * 100 < 25 then
                K.shouldTween = true
                K.Tp(Root().CFrame * CFrame.new(0, 500, 0))
            end
        end)
    end
end)

-- Auto Travel
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_AutoTravel or not K.SelectedIsland then continue end
        pcall(function()
            for _, v in ipairs(Workspace._WorldOrigin.Locations:GetChildren()) do
                if v.Name == K.SelectedIsland then
                    K.Tp(v.CFrame * CFrame.new(0, 30, 0))
                end
            end
        end)
    end
end)

-- Auto Tween NPC
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_TweenNPC or not K.SelectedNPC then continue end
        pcall(function()
            for _, v in ipairs(ReplicatedStorage:FindFirstChild("NPCs"):GetChildren()) do
                if v.Name == K.SelectedNPC and v:FindFirstChild("HumanoidRootPart") then
                    K.Tp(v.HumanoidRootPart.CFrame)
                end
            end
        end)
    end
end)

-- Auto Stats
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local stats = {
                {"AutoMelee", "Melee"},
                {"AutoSword", "Sword"},
                {"AutoGun", "Gun"},
                {"AutoDevil", "Demon Fruit"},
                {"AutoDefense", "Defense"},
            }
            for _, s in ipairs(stats) do
                if K[s[1]] and statsValue > 0 then
                    K.statsSettings(s[2], statsValue)
                end
            end
        end)
    end
end)

-- Fruits Management
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if K.T_RandomFruit then CommF_:InvokeServer("Cousin", "Buy") end
            if K.T_StoreFruit then
                for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t:FindFirstChild("EatRemote", true) then
                        CommF_:InvokeServer("StoreFruit", t:GetAttribute("OriginalName"), t)
                    end
                end
            end
            if K.T_DropFruit then
                for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t.Name:find("Fruit") then
                        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(t)
                        task.wait(0.1)
                        if t:FindFirstChild("EatRemote") then
                            t.EatRemote:InvokeServer("Drop")
                        end
                    end
                end
            end
            if K.T_TweenFruit then
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        K.Tp(v.Handle.CFrame)
                    end
                end
            end
            if K.T_CollectFruit then
                local hrp = Root()
                for _, v in ipairs(Workspace:GetChildren()) do
                    if v.Name:find("Fruit") and v:FindFirstChild("Handle") then
                        v.Handle.CFrame = hrp.CFrame
                    end
                end
            end
            if K.T_FruitSniper then
                local fruits = CommF_:InvokeServer("GetFruits")
                for _, f in ipairs(fruits) do
                    pcall(function() CommF_:InvokeServer("PurchaseRawFruit", f.Name, false) end)
                end
            end
        end)
    end
end)

-- Raid helpers
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if K.T_ChipBeli and not LocalPlayer.Backpack:FindFirstChild("Special Microchip") then
                CommF_:InvokeServer("RaidsNpc", "Select", K.SelectedChip or "Flame")
            end
            if K.T_ChipFruit and not LocalPlayer.Backpack:FindFirstChild("Special Microchip") then
                local fruits = CommF_:InvokeServer("GetFruits")
                for _, f in ipairs(fruits) do
                    if f.Price <= 490000 then
                        CommF_:InvokeServer("LoadFruit", tostring(f.Name))
                        CommF_:InvokeServer("RaidsNpc", "Select", K.SelectedChip or "Flame")
                        break
                    end
                end
            end
            if K.T_Awakening then
                CommF_:InvokeServer("Awakener", "Check")
                CommF_:InvokeServer("Awakener", "Awaken")
            end
            if K.T_AutoPvP then
                local pg = LocalPlayer.PlayerGui
                if pg.Main and pg.Main:FindFirstChild("PvpDisabled") and pg.Main.PvpDisabled.Visible then
                    CommF_:InvokeServer("EnablePvp")
                end
            end
        end)
    end
end)

-- Auto Start Raid
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_StartRaid then continue end
        pcall(function()
            local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
            local top = gui and gui:FindFirstChild("TopHUDList")
            if not top or top.RaidTimer.Visible then return end
            if not LocalPlayer.Backpack:FindFirstChild("Special Microchip") then return end

            if World2 then
                local btn = Workspace.Map.CircleIsland.RaidSummon2.Button.Main
                if btn then
                    if btn:FindFirstChild("ProximityPrompt") then fireproximityprompt(btn.ProximityPrompt)
                    elseif btn:FindFirstChild("ClickDetector") then fireclickdetector(btn.ClickDetector) end
                end
            elseif World3 then
                local btn = Workspace.Map["Boat Castle"].RaidSummon2.Button.Main
                if btn then
                    if btn:FindFirstChild("ProximityPrompt") then fireproximityprompt(btn.ProximityPrompt)
                    elseif btn:FindFirstChild("ClickDetector") then fireclickdetector(btn.ClickDetector) end
                end
            end
        end)
    end
end)

-- Auto Raid + Next Island
task.spawn(function()
    local islands = {"Island 1","Island 2","Island 3","Island 4","Island 5"}
    while task.wait(0.4) do
        if not K.T_Raiding then continue end
        pcall(function()
            local locs = Workspace["_WorldOrigin"].Locations
            local gui = LocalPlayer.PlayerGui.Main.TopHUDList.RaidTimer
            if not gui.Visible then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end

            for _, name in ipairs(islands) do
                local loc = locs:FindFirstChild(name)
                if loc then
                    for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
                        local mh = mob:FindFirstChild("Humanoid")
                        local mhrp = mob:FindFirstChild("HumanoidRootPart")
                        if mh and mhrp and mh.Health > 0 and (mhrp.Position - loc.Position).Magnitude < 450 then
                            repeat task.wait() K.Attack.Kill(mob, true) until not K.T_Raiding or not mob.Parent or mh.Health <= 0
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Farm Dungeon
task.spawn(function()
    while task.wait(0.2) do
        if not K.T_FarmDungeon then continue end
        pcall(function()
            for _, mob in ipairs(Workspace.Enemies:GetChildren()) do
                if not K.T_FarmDungeon then break end
                local mh = mob:FindFirstChild("Humanoid")
                local mhrp = mob:FindFirstChild("HumanoidRootPart")
                if mh and mhrp and mh.Health > 0 then
                    repeat task.wait() K.Attack.Kill(mob, true) until not K.T_FarmDungeon or not mob.Parent or mh.Health <= 0
                end
            end
        end)
    end
end)

-- Auto Random Fruit (redundant safe loop)
task.spawn(function()
    while task.wait(1) do
        if K.T_RandomFruit then
            pcall(function() CommF_:InvokeServer("Cousin", "Buy") end)
        end
    end
end)

-- Prehistoric Island Event (Auto Find)
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_FindPrehis then continue end
        pcall(function()
            local locs = Workspace["_WorldOrigin"].Locations
            local prehis = locs:FindFirstChild("Prehistoric Island")
            if prehis then
                K.Tp(prehis.CFrame * CFrame.new(0, 200, 0))
            end
        end)
    end
end)

-- Auto Start Prehistoric
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_StartPrehis then continue end
        pcall(function()
            if Workspace.Map:FindFirstChild("PrehistoricIsland") then
                local promptPart = Workspace.Map.PrehistoricIsland.Core:FindFirstChild("ActivationPrompt", true)
                if promptPart and promptPart:FindFirstChild("ProximityPrompt") then
                    if (Root().Position - promptPart.CFrame.Position).Magnitude <= 150 then
                        fireproximityprompt(promptPart.ProximityPrompt, math.huge)
                        SendKey("E", 1.5)
                    end
                    K.Tp(promptPart.CFrame)
                end
            end
        end)
    end
end)

-- Auto Collect Dino Bones
task.spawn(function()
    while task.wait(0.4) do
        if not K.T_DinoBones then continue end
        pcall(function()
            for _, v in ipairs(Workspace:GetChildren()) do
                if v.Name == "DinoBone" then K.Tp(v.CFrame) end
            end
        end)
    end
end)

-- Auto Collect Dragon Eggs
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_DragonEggs then continue end
        pcall(function()
            if Workspace.Map:FindFirstChild("PrehistoricIsland") then
                local core = Workspace.Map.PrehistoricIsland:FindFirstChild("Core")
                local eggs = core and core:FindFirstChild("SpawnedDragonEggs")
                if eggs then
                    local egg = eggs:FindFirstChild("DragonEgg")
                    if egg and egg:FindFirstChild("Molten") then
                        K.Tp(egg.Molten.CFrame)
                        fireproximityprompt(egg.Molten.ProximityPrompt, 30)
                    end
                end
            end
        end)
    end
end)

-- Auto Pull Lever (Race V4)
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_PullLever then continue end
        pcall(function()
            local t = Workspace.Map:FindFirstChild("Temple of Time")
            if t then
                for _, d in ipairs(t:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then
                        fireproximityprompt(d, math.huge)
                    end
                end
            end
        end)
    end
end)

-- Auto Train V4
task.spawn(function()
    while task.wait(0.5) do
        if not K.T_TrainV4 then continue end
        pcall(function()
            local char = LocalPlayer.Character
            if char:FindFirstChild("RaceEnergy") and char.RaceEnergy.Value == 1 then
                SendKey("Y")
                CommF_:InvokeServer("UpgradeRace", "Buy")
                K.Tp(CFrame.new(-8987.04, 215.86, 5886.71))
            else
                local e = K.GetConnectionEnemies({"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"})
                if e then
                    repeat task.wait() K.Attack.Kill(e, true) until not IsAlive(e)
                else
                    K.Tp(CFrame.new(-9495.68, 453.58, 5977.34))
                end
            end
        end)
    end
end)

--============================================================
-- FINAL
--============================================================
VindUI:Notify({
    Title = "Kyrova Hub",
    Text  = "Todos os módulos ativos! Ícone: 71647128089295",
    Type  = "info",
    Duration = 5,
})

print("[Kyrova Hub] Loaded successfully.")
