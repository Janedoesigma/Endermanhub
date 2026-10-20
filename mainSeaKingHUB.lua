--// Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

repeat task.wait() until game:IsLoaded()

--// Services
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Remotes = RS:WaitForChild("Remotes")
local CommF_ = Remotes:WaitForChild("CommF_")
local Net = RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
local RegisterHit = Net:WaitForChild("RE/RegisterHit")
local Enemies = WS:WaitForChild("Enemies")

--// Config (edite aqui)
local Config = {
	["Weapon Tool"] = "Melee",   -- Melee | Sword | Blox Fruit | Gun
	["Farm Distance"] = 20,
	["Tween Speed"] = 300,
	["Bring Mob Radius"] = 300,
	["Nearest Range"] = "Infinite", -- 1000 | 2000 | 3000 | Infinite

	-- estados dos toggles
	["Auto Farm Level"] = false,
	["Auto Take Quest"] = false,
	["Auto Farm Nearest"] = false,
	["Bring Mob"] = false,
	["Fast Attack"] = false,
	["Auto Random Fruit"] = false,
	["Auto Find Fruit"] = false,
}

local function Unloaded()
	return Fluent.Unloaded
end

local function FireRemote(...)
	return CommF_:InvokeServer(...)
end

local function IsAlive(model)
	local hum = model and model:FindFirstChild("Humanoid")
	return hum and hum.Health > 0
end

local function GetDistance(target)
	local char = LP.Character
	if not char or not char.PrimaryPart then return math.huge end
	local pos
	if typeof(target) == "CFrame" then
		pos = target.Position
	elseif typeof(target) == "Vector3" then
		pos = target
	else
		return math.huge
	end
	return (char.PrimaryPart.Position - pos).Magnitude
end

----------------------------------------------------------------
-- TWEEN
----------------------------------------------------------------
local ActiveController

local function CreateTweenController(root)
	local ctrl = {}
	local oldCollide, oldAnchor = {}, {}
	local tween, bv, conn

	local function cleanup()
		if conn then conn:Disconnect() conn = nil end
		if tween then tween:Cancel() tween = nil end
		if bv then bv:Destroy() bv = nil end
		if root and root.Parent then
			for _, d in pairs(root.Parent:GetDescendants()) do
				if d:IsA("BasePart") then
					if oldCollide[d] ~= nil then d.CanCollide = oldCollide[d] end
					oldCollide[d] = nil
					if oldAnchor[d] ~= nil then d.Anchored = oldAnchor[d] oldAnchor[d] = nil end
				end
			end
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	function ctrl:Run(cf, speed)
		for _, d in pairs(root.Parent:GetDescendants()) do
			if d:IsA("BasePart") then
				oldCollide[d] = d.CanCollide
				oldAnchor[d] = d.Anchored
				d.CanCollide = false
			end
		end
		root.AssemblyLinearVelocity = Vector3.zero
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(4000, 4000, 4000)
		bv.Velocity = Vector3.zero
		bv.Parent = root
		local t = math.max(0.05, (root.CFrame.Position - cf.Position).Magnitude / math.max(speed or 100, 0.01))
		tween = TweenService:Create(root, TweenInfo.new(t, Enum.EasingStyle.Linear), { CFrame = cf })
		conn = tween.Completed:Connect(cleanup)
		tween:Play()
	end

	function ctrl:Destroy() cleanup() end
	return ctrl
end

local function FindNearestTeleporter(cf)
	local pos = cf.Position
	local list = {}
	local pid = game.PlaceId
	if pid == 7449423635 then
		list = {
			Vector3.new(-5058.775, 314.5155, -3155.8833),
			Vector3.new(5756.8374, 610.424, -253.9254),
			Vector3.new(-12463.874, 374.9145, -7523.774),
			Vector3.new(28282.57, 14896.851, 105.1043),
		}
	elseif pid == 4442272183 then
		list = {
			Vector3.new(-288.4625, 306.1306, 597.9988),
			Vector3.new(2284.912, 15.152, 905.4829),
			Vector3.new(923.2125, 126.976, 32852.832),
			Vector3.new(-6508.558, 89.035, -132.8395),
		}
	elseif pid == 2753915549 then
		list = {
			Vector3.new(-7894.62, 5545.4917, -380.2467),
			Vector3.new(-4607.8228, 872.5423, -1667.5569),
			Vector3.new(61163.85, 11.7595, 1819.7842),
			Vector3.new(3876.2805, 35.1061, -1939.3202),
		}
	end
	if #list == 0 then return nil end

	local best, bestDist = nil, math.huge
	for _, v in ipairs(list) do
		local m = (v - pos).Magnitude
		if m < bestDist then bestDist = m best = v end
	end

	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	if bestDist <= (pos - root.Position).Magnitude then
		return best
	end
	return nil
end

local Teleporting = false
local function ExecuteTween(cf, speed)
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if ActiveController then pcall(function() ActiveController:Destroy() end) end
	ActiveController = CreateTweenController(root)

	speed = tonumber(speed) or tonumber(Config["Tween Speed"]) or 100
	if speed <= 0 then speed = 100 end

	if not Teleporting then
		local tp = FindNearestTeleporter(cf)
		if tp then
			Teleporting = true
			root.AssemblyLinearVelocity = Vector3.zero
			FireRemote("requestEntrance", tp)
			task.delay(1, function() Teleporting = false end)
			return
		end
	end

	ActiveController:Run(cf, speed)
end

local function StopTween()
	if ActiveController then
		ActiveController:Destroy()
		ActiveController = nil
	end
end

----------------------------------------------------------------
-- EQUIP / HAKI
----------------------------------------------------------------
local function EquipSelectedTool()
	local backpack, char = LP.Backpack, LP.Character
	if not (backpack and char) then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	for _, t in ipairs(backpack:GetChildren()) do
		if t:IsA("Tool") and t.ToolTip == Config["Weapon Tool"] then
			if hum then hum:EquipTool(t) end
			return
		end
	end
end

local function ActivateHaki()
	local char = LP.Character
	if not char or not char:FindFirstChild("HasBuso") then
		FireRemote("Buso")
	end
end

----------------------------------------------------------------
-- FAST ATTACK
----------------------------------------------------------------
local hitStr = tostring(LP.UserId):sub(2, 4) .. "078da"

local function GetHitThread()
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

local hitThread = coroutine.create(function()
	pcall(function()
		RegisterHit:FireServer(hitStr)
		while true do
			local a, b = coroutine.yield()
			RegisterHit:FireServer(a, b, nil, hitStr)
		end
	end)
end)
coroutine.resume(hitThread)

local function GetHits(range)
	local list = {}
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return list end

	for _, folder in ipairs({ WS.Enemies, WS.Characters }) do
		for _, c in ipairs(folder:GetChildren()) do
			local hum = c:FindFirstChildOfClass("Humanoid")
			local hrp = c:FindFirstChild("HumanoidRootPart")
			if c ~= char and hum and hrp and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= range then
				table.insert(list, { c, c:FindFirstChild("Head") or hrp })
			end
		end
	end
	return list
end

local m1State = { last = 0, delay = 0 }
local function FruitM1(tool)
	pcall(function()
		local now = tick()
		local d
		if now - m1State.last <= 0.4 then
			d = math.min(m1State.delay + 1, 4)
		else
			d = 1
		end
		m1State.last, m1State.delay = now, d

		local char = LP.Character
		local pp = char and char.PrimaryPart
		if not pp then return end
		local pos = pp.Position

		for _, e in ipairs(Enemies:GetChildren()) do
			local ep = e.PrimaryPart
			if ep and IsAlive(e) then
				if (ep.Position - pos).Magnitude <= 50 then
					tool.LeftClickRemote:FireServer((ep.Position - pos).Unit, d)
				end
			end
		end
	end)
end

local function NormalAttack()
	local char = LP.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not (tool and table.find({ "Melee", "Sword", "Blox Fruit", "Gun" }, tool.ToolTip)) then return end

	local hits = GetHits(60)
	if #hits > 0 then
		RegisterAttack:FireServer(0)
		local first = table.remove(hits, 1)[2]
		local th = GetHitThread() or hitThread
		if th then
			coroutine.resume(th, first, hits)
		else
			RegisterHit:FireServer(first, hits, nil, hitStr)
		end
	end
end

local function ExecuteBladeHits()
	pcall(function()
		local char = LP.Character
		if not char then return end
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end

		if tool.ToolTip == "Blox Fruit" and tool:FindFirstChild("LeftClickRemote") then
			FruitM1(tool)
		elseif tool.ToolTip ~= "Gun" then
			NormalAttack()
		end
	end)
end

task.spawn(function()
	while task.wait() do
		if Unloaded() then break end
		if Config["Fast Attack"] then
			ExecuteBladeHits()
		end
	end
end)

----------------------------------------------------------------
-- BRING MOB
----------------------------------------------------------------
local function BringEnemyToPosition(enemy, cf)
	if not Config["Bring Mob"] then return end
	if not enemy or not enemy.Parent or not cf then return end

	local radius = tonumber(Config["Bring Mob Radius"]) or 300
	local radius2 = radius * radius
	local pos = cf.Position

	pcall(function()
		sethiddenproperty(LP, "SimulationRadius", math.huge)
		sethiddenproperty(LP, "MaxSimulationRadius", math.huge)
	end)

	for _, v in ipairs(Enemies:GetChildren()) do
		if v.Name == enemy.Name and not table.find({ "Shark", "Piranha", "Terrorshark" }, v.Name) then
			local hum = v:FindFirstChildOfClass("Humanoid")
			local hrp = v:FindFirstChild("HumanoidRootPart")
			local ready = v:FindFirstChild("CharacterReady")

			if hum and hrp and ready and hum.Health > 0 and hrp:IsDescendantOf(WS) then
				local d = hrp.Position - pos
				if d:Dot(d) <= radius2 and not hrp:GetAttribute("BeingBrought") then
					hrp:SetAttribute("BeingBrought", true)
					hrp.CanCollide = false
					hrp.Massless = true

					for _, p in ipairs(v:GetDescendants()) do
						if p:IsA("BasePart") then
							p.CanCollide = false
							p.CanTouch = false
							p.Massless = true
							p.AssemblyLinearVelocity = Vector3.zero
							p.AssemblyAngularVelocity = Vector3.zero
						end
					end

					local lock = hrp:FindFirstChild("Lock")
					if not lock then
						lock = Instance.new("BodyVelocity")
						lock.Name = "Lock"
						lock.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						lock.P = 9000
						lock.Velocity = Vector3.zero
						lock.Parent = hrp
					end

					local gyro = hrp:FindFirstChild("BringGyro")
					if not gyro then
						gyro = Instance.new("BodyGyro")
						gyro.Name = "BringGyro"
						gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
						gyro.P = 30000
						gyro.D = 1000
						gyro.Parent = hrp
					end

					gyro.CFrame = cf
					hum.AutoRotate = false
					hum.PlatformStand = false
					pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

					task.spawn(function()
						local target = pos + Vector3.new(math.random(-20, 20) / 100, math.random(-20, 20) / 100, math.random(-20, 20) / 100)
						local diff = target - hrp.Position
						local mag = diff.Magnitude
						if mag > 0.5 then
							lock.Velocity = diff.Unit * math.clamp(mag * 10, 20, 1200)
						else
							lock.Velocity = Vector3.zero
							pcall(function() hrp.CFrame = CFrame.new(target) end)
						end
						task.wait(0.12)
						pcall(function()
							if lock and lock.Parent then lock:Destroy() end
							if gyro and gyro.Parent then gyro:Destroy() end
							if hrp and hrp.Parent then hrp:SetAttribute("BeingBrought", false) end
						end)
					end)
				end
			end
		end
	end
end

----------------------------------------------------------------
-- AUTO FARM LEVEL
----------------------------------------------------------------
local enemyNameCache = {}

local function NormalizeEnemyName(name)
	if type(name) ~= "string" then return "" end
	return name:match("^(.-)%s*%[") or name
end

local function FindEnemy(names)
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local wanted = {}
	for _, name in ipairs(names or {}) do
		wanted[NormalizeEnemyName(name)] = true
	end

	local best, bestDist = nil, math.huge
	for _, enemy in ipairs(Enemies:GetChildren()) do
		local hum = enemy:FindFirstChildOfClass("Humanoid")
		local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
		if hum and hum.Health > 0 and hrp then
			local normalized = enemyNameCache[enemy.Name]
			if not normalized then
				normalized = NormalizeEnemyName(enemy.Name)
				enemyNameCache[enemy.Name] = normalized
			end
			if wanted[normalized] then
				local distance = (hrp.Position - root.Position).Magnitude
				if distance < bestDist then
					bestDist, best = distance, enemy
				end
			end
		end
	end
	return best
end

local function FindNearestEnemy(maxDistance)
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	maxDistance = tonumber(maxDistance) or math.huge
	local best, bestDistance = nil, maxDistance
	for _, enemy in ipairs(Enemies:GetChildren()) do
		local hum = enemy:FindFirstChildOfClass("Humanoid")
		local hrp = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
		if hum and hum.Health > 0 and hrp then
			local distance = (hrp.Position - root.Position).Magnitude
			if distance <= bestDistance then
				best, bestDistance = enemy, distance
			end
		end
	end
	return best
end

local circle = { angle = 0, radius = 35 }
local function FarmOffset(cf)
	circle.angle = (circle.angle + 5) % 360
	local a = math.rad(circle.angle)
	local h = tonumber(Config["Farm Distance"]) or 20
	return cf + Vector3.new(math.sin(a) * circle.radius, h, math.cos(a) * circle.radius)
end

local function EngageEnemy(enemy, mode)
	if not enemy then return end
	mode = mode or "level"

	local function modeEnabled()
		if mode == "nearest" then
			return Config["Auto Farm Nearest"] and not Config["Auto Farm Level"]
		end
		return Config["Auto Farm Level"]
	end

	while modeEnabled() and not Unloaded() and enemy.Parent and IsAlive(enemy) do
		RunService.Heartbeat:Wait()
		if not modeEnabled() or Unloaded() or not enemy.Parent or not IsAlive(enemy) then
			break
		end

		local character = LP.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
		if not root or not enemyRoot then break end

		local enemyCFrame = enemyRoot.CFrame
		EquipSelectedTool()
		ActivateHaki()
		BringEnemyToPosition(enemy, enemyCFrame)
		ExecuteTween(FarmOffset(enemyCFrame))
	end
end
local function GetQuestInfo()
	local level = LP.Data.Level.Value
	local team = tostring(LP.Team)
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")

	local qNum, qCF, mobName, qName, qLevel, mobName2

	local function pack()
		return { qNum, qCF, mobName, qName, qLevel, mobName2 }
	end

	if level >= 1 and level <= 9 then
		if team == "Marines" then
			qNum, qName, mobName, mobName2 = 1, "MarineQuest", "Trainee", "Trainee"
			qCF = CFrame.new(-2709.67944, 24.5206585, 2104.24585)
		else
			qNum, qName, mobName, mobName2 = 1, "BanditQuest1", "Bandit", "Bandit"
			qCF = CFrame.new(1059.99731, 16.9222069, 1549.28162)
		end
		qLevel = 1
		return pack()
	end

	if level >= 210 and level <= 249 then
		qNum, qName, mobName, mobName2 = 2, "PrisonerQuest", "Dangerous Prisoner", "Dangerous Prisoner"
		qLevel = 210
		qCF = CFrame.new(5308.93115, 1.65517521, 475.120514)
		return pack()
	end

	qLevel = 0
	for npc, data in pairs(require(RS.GuideModule).Data.NPCList) do
		local levels = data.Levels
		for i = 1, #levels do
			local lv = levels[i]
			if level >= lv and lv > qLevel then
				qLevel = lv
				qNum = (#levels == 3 and i == 3) and 2 or i
				qCF = npc.CFrame
			end
		end
	end

	if root and qCF then
		local mag = (qCF.Position - root.Position).Magnitude
		if level >= 375 and level <= 449 and mag > 3000 then
			FireRemote("requestEntrance", Vector3.new(61163.85, 11.6797, 1819.7842))
		elseif level >= 450 and level <= 474 and mag > 3000 then
			FireRemote("requestEntrance", Vector3.new(-4607.8228, 872.5425, -1667.5569))
		elseif level >= 475 and level <= 624 and mag > 5000 then
			FireRemote("requestEntrance", Vector3.new(-7894.6177, 5547.1416, -380.2912))
		end
	end

	local Quests = require(RS.Quests)
	for qn, quest in pairs(Quests) do
		if qn ~= "CitizenQuest" then
			for k2, v in pairs(quest) do
				if v.LevelReq == qLevel then
					qName = qn
					qNum = k2
					for taskName in pairs(v.Task) do
						mobName = taskName
						mobName2 = string.split(taskName, " [Lv. " .. v.LevelReq .. "]")[1]
					end
				end
			end
		end
	end

	if qName == "ImpelQuest" then
		qName, qNum = "PrisonerQuest", 2
		mobName, mobName2 = "Dangerous Prisoner", "Dangerous Prisoner"
		qLevel = 210
		qCF = CFrame.new(5310.60547, 0.350014925, 474.946594)
	elseif qName == "Area2Quest" and qNum == 2 then
		qNum = 1
		mobName, mobName2 = "Swan Pirate", "Swan Pirate"
		qLevel = 775
	end

	if level >= 2500 and level <= 2524 then
		mobName, mobName2 = "Sun-kissed Warrior", "Sun-kissed Warriors"
	end

	return pack()
end

local function IsQuestOn()
	local gui = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild("TrackedQuestFrame")
	local frame = gui and gui:FindFirstChild("Frame")
	return frame ~= nil and frame.Visible == true
end

local spawnIndex = 1
local function NavigateToSpawn(names)
	local clean = {}
	for _, n in ipairs(names) do
		clean[n:gsub("Lv%.", ""):gsub("[%[%] %d]", ""):gsub("%s+", "")] = true
	end

	local spawns = {}
	local folder = RS:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
	if folder then
		for _, c in ipairs(folder:GetChildren()) do
			if c:IsA("Part") and c:GetAttribute("Active") then
				local nm = c.Name:gsub("Lv%.", ""):gsub("[%[%] %d]", ""):gsub("%s+", "")
				if clean[nm] then table.insert(spawns, c:GetPivot()) end
			end
		end
	end

	if #spawns == 0 then return false end
	if #spawns < spawnIndex then spawnIndex = 1 end

	local cf = spawns[spawnIndex]
	if not cf then return false end

	local dist = GetDistance(cf.Position)
	if dist > 20 then
		ExecuteTween(cf * CFrame.new(0, dist > 150 and 65 or 30, 5))
	end

	spawnIndex = spawnIndex % #spawns + 1
	return true
end

-- Auto Farm Level + Auto Take Quest (lógica baseada no Speed Hub)
task.spawn(function()
	while task.wait(0.15) do
		if Unloaded() then break end
		if Config["Auto Farm Level"] then
			pcall(function()
				local quest = GetQuestInfo()
				if not quest or not quest[1] or not quest[2] or not quest[3] or not quest[4] then
					return
				end

				local targetNames = { quest[3], quest[6] }
				if IsQuestOn() then
					local target = FindEnemy(targetNames)
					if target then
						EngageEnemy(target, "level")
					else
						StopTween()
						NavigateToSpawn(targetNames)
						task.wait(1)
					end
				elseif Config["Auto Take Quest"] then
					local distance = GetDistance(quest[2])
					if distance <= 5 then
						FireRemote("StartQuest", quest[4], quest[1])
						task.wait(0.35)
					else
						ExecuteTween(quest[2])
					end
				else
					-- Sem Auto Take Quest: procura os mesmos inimigos sem iniciar missão.
					local target = FindEnemy(targetNames)
					if target then
						EngageEnemy(target, "level")
					else
						StopTween()
						NavigateToSpawn(targetNames)
						task.wait(1)
					end
				end
			end)
		end
	end
end)

-- Auto Farm Nearest: prioriza o inimigo vivo mais próximo dentro do alcance escolhido.
-- Se Auto Farm Level estiver ligado, ele tem prioridade para evitar dois farms controlando o tween.
task.spawn(function()
	while task.wait(0.15) do
		if Unloaded() then break end
		if Config["Auto Farm Nearest"] and not Config["Auto Farm Level"] then
			pcall(function()
				local range = Config["Nearest Range"]
				local maxDistance = (range == "Infinite") and math.huge or tonumber(range) or math.huge
				local target = FindNearestEnemy(maxDistance)
				if target then
					EngageEnemy(target, "nearest")
				else
					StopTween()
				end
			end)
		end
	end
end)

----------------------------------------------------------------
-- FRUTAS
----------------------------------------------------------------
-- Girar fruta (Cousin)
task.spawn(function()
	while task.wait() do
		if Unloaded() then break end
		if Config["Auto Random Fruit"] then
			pcall(function() FireRemote("Cousin", "Buy") end)
		end
	end
end)

-- Ir até fruta
local function FindGroundFruit()
	local char = LP.Character
	local pp = char and char.PrimaryPart
	if not pp then return nil end

	local best, bestDist = nil, math.huge
	for _, c in ipairs(WS:GetChildren()) do
		local handle = c:FindFirstChild("Handle")
		if handle and (c:IsA("Tool") or string.find(c.Name, "Fruit")) then
			local m = (pp.Position - handle.Position).Magnitude
			if m <= bestDist then bestDist = m best = c end
		end
	end
	return best and best:FindFirstChild("Handle")
end

task.spawn(function()
	while task.wait() do
		if Unloaded() then break end
		if Config["Auto Find Fruit"] then
			pcall(function()
				local h = FindGroundFruit()
				if h then ExecuteTween(h.CFrame) end
			end)
		end
	end
end)

----------------------------------------------------------------
-- FLUENT UI
----------------------------------------------------------------
local Window = Fluent:CreateWindow({
	Title = "Blox Fruits",
	SubTitle = "Auto Farm",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "home" }),
	Fruits = Window:AddTab({ Title = "Frutas", Icon = "apple" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

local function AddCfgToggle(tab, id, title, desc, onChange)
	local t = tab:AddToggle(id, { Title = title, Description = desc, Default = Config[id] == true })
	t:OnChanged(function()
		local value = Options[id].Value
		Config[id] = value
		if onChange then onChange(value) end
	end)
	return t
end

-- Main / Farming
AddCfgToggle(Tabs.Main, "Auto Farm Level", "Auto Farm Level", "Farma pelo seu level e segue a missão", function(v)
	if not v and not Config["Auto Farm Nearest"] then StopTween() end
end)
AddCfgToggle(Tabs.Main, "Auto Take Quest", "Auto Take Quest", "Aceita automaticamente a missão do seu level (use com Auto Farm Level)")
AddCfgToggle(Tabs.Main, "Auto Farm Nearest", "Auto Farm Nearest", "Farma o inimigo vivo mais próximo; tem prioridade menor que Auto Farm Level", function(v)
	if not v and not Config["Auto Farm Level"] then StopTween() end
end)

local NearestRangeDropdown = Tabs.Main:AddDropdown("Nearest Range", {
	Title = "Alcance do Farm Próximo",
	Description = "Distância máxima para procurar inimigos",
	Values = { "1000", "2000", "3000", "Infinite" },
	Default = 4,
	Multi = false,
})
NearestRangeDropdown:SetValue(Config["Nearest Range"])
NearestRangeDropdown:OnChanged(function(value)
	Config["Nearest Range"] = value
end)

AddCfgToggle(Tabs.Main, "Bring Mob", "Bring Mob", "Puxa os mobs para perto de você")
AddCfgToggle(Tabs.Main, "Fast Attack", "Fast Attack", "Ataque rápido")

-- Frutas
AddCfgToggle(Tabs.Fruits, "Auto Random Fruit", "Girar Fruta", "Compra fruta aleatória do Cousin")
AddCfgToggle(Tabs.Fruits, "Auto Find Fruit", "Ir até Fruta", "Vai até a fruta no chão", function(v)
	if not v then StopTween() end
end)

-- Settings / Save
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloxFruitsFluent")
SaveManager:SetFolder("BloxFruitsFluent/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "Blox Fruits", Content = "Script carregado.", Duration = 5 })
SaveManager:LoadAutoloadConfig()
