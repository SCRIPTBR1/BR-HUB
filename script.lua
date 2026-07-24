repeat task.wait() until game:IsLoaded()
local Players,RunService,UIS,HS = game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

-- ========== BLACKLIST CHECK ==========
local cursedResetRemote = nil
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"

task.spawn(function()
	local BLACKLIST_URL="https://pastebin.com/2zLUXv2K"
	pcall(function() HS.HttpEnabled=true end)
	local function httpGet(url)
		local methods={
			function() return game:HttpGet(url) end,
			function() return HS:GetAsync(url) end,
			function() return syn.request({Url=url,Method="GET"}).Body end,
			function() return http_request({Url=url,Method="GET"}).Body end,
			function() return request({Url=url,Method="GET"}).Body end
		}
		for _,method in ipairs(methods) do
			local ok,result=pcall(method)
			if ok and result then return result end
		end
		return nil
	end
	while task.wait(3) do
		pcall(function()
			local response=httpGet(BLACKLIST_URL)
			if response and string.find(response,tostring(LP.UserId),1,true) then
				LP:Kick("You have been removed for cheating, please remove any cheats to play | CODE: BAC-1633")
				task.wait(999999)
			end
		end)
	end
end)

-- ========== CURSED RESET DETECTION ==========
pcall(function()
	if hookfunction and newcclosure then
		local oldFire
		oldFire=hookfunction(Instance.new("RemoteEvent").FireServer,newcclosure(function(self,...)
			if not cursedResetRemote and typeof(self)=="Instance" and self:IsA("RemoteEvent") and self.Name:sub(1,3)=="RE/" then cursedResetRemote=self end
			return oldFire(self,...)
		end))
	end
end)

task.spawn(function()
	task.wait(2)
	if cursedResetRemote then return end
	for _,desc in ipairs(game:GetDescendants()) do
		if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then cursedResetRemote=desc;break end
	end
end)

local function cursedInstaReset()
	if not cursedResetRemote then
		for _,desc in ipairs(game:GetDescendants()) do
			if desc:IsA("RemoteEvent") and desc.Name:sub(1,3)=="RE/" then cursedResetRemote=desc;break end
		end
	end
	if not cursedResetRemote then return end
	local character=LP.Character
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health<=0 then pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID,LP,"balloon") end);return end
	local resetDetected=false
	local conns={}
	if humanoid then
		table.insert(conns,humanoid.Died:Connect(function() resetDetected=true end))
		table.insert(conns,humanoid:GetPropertyChangedSignal("Health"):Connect(function() if humanoid.Health<=0 then resetDetected=true end end))
	end
	if character then table.insert(conns,character.AncestryChanged:Connect(function(_,parent) if not parent then resetDetected=true end end)) end
	task.spawn(function()
		for _=1,50 do
			if resetDetected then break end
			pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID,LP,"balloon") end)
			task.wait()
		end
		for _,conn in ipairs(conns) do pcall(function() conn:Disconnect() end) end
	end)
end

-- ========== ANTI-LAG & VISUAL FEATURES ==========
local stretchRezEnabled = false
local stretchRezConn = nil
local antiLagEnabled = false
local removeAccessoriesEnabled = false
local removeAccessoriesConn = nil
local antiLagDescConn = nil
local defLightBrightness,defLightClock,defLightAmbient

local fovOn = false
local galaxyOn = false
local antiBatOn = false
local antiFlingOn = false
local detectDistance = 15
local galaxySky = nil

local function enableStretchRez()
	stretchRezEnabled=true
	workspace.CurrentCamera.FieldOfView=107
	if stretchRezConn then stretchRezConn:Disconnect() end
	stretchRezConn=RunService.RenderStepped:Connect(function()
		if not stretchRezEnabled then stretchRezConn:Disconnect();stretchRezConn=nil;return end
		workspace.CurrentCamera.FieldOfView=107
	end)
end

local function disableStretchRez()
	stretchRezEnabled=false
	if stretchRezConn then stretchRezConn:Disconnect();stretchRezConn=nil end
	workspace.CurrentCamera.FieldOfView=70
end

local function applyAntiLagDerender(obj)
	pcall(function()
		if obj:IsA("BasePart") then obj.Material=Enum.Material.Plastic;obj.Reflectance=0;obj.CastShadow=false
		elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency=1
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled=false
		elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
			for _,t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
		end
	end)
end

local function removeAccessoriesFromChar(char)
	if not char then return end
	for _, obj in ipairs(char:GetChildren()) do
		pcall(function()
			if obj:IsA("Accessory") or obj:IsA("Hat") or 
			   (obj:IsA("Model") and (obj.Name:lower():find("hat") or obj.Name:lower():find("accessory") or obj.Name:lower():find("hair") or obj.Name:lower():find("helmet"))) then
				obj:Destroy()
			end
		end)
	end
end

local function enableRemoveAccessories()
	removeAccessoriesEnabled = true
	removeAccessoriesFromChar(LP.Character)
	if removeAccessoriesConn then removeAccessoriesConn:Disconnect() end
	removeAccessoriesConn = LP.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		if removeAccessoriesEnabled then removeAccessoriesFromChar(char) end
	end)
end

local function disableRemoveAccessories()
	removeAccessoriesEnabled = false
	if removeAccessoriesConn then removeAccessoriesConn:Disconnect(); removeAccessoriesConn = nil end
end

local function enableAntiLag()
	antiLagEnabled=true
	defLightBrightness=defLightBrightness or game:GetService("Lighting").Brightness
	defLightClock=defLightClock or game:GetService("Lighting").ClockTime
	defLightAmbient=defLightAmbient or game:GetService("Lighting").OutdoorAmbient
	local LightingSvc = game:GetService("Lighting")
	LightingSvc.GlobalShadows=false;LightingSvc.FogEnd=1e10;LightingSvc.Brightness=1
	LightingSvc.EnvironmentDiffuseScale=0;LightingSvc.EnvironmentSpecularScale=0
	for _,e in pairs(LightingSvc:GetChildren()) do
		pcall(function()
			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end
		end)
	end
	for _,obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
	if antiLagDescConn then antiLagDescConn:Disconnect() end
	antiLagDescConn=workspace.DescendantAdded:Connect(function(obj)
		if antiLagEnabled then applyAntiLagDerender(obj) end
	end)
end

local function disableAntiLag()
	antiLagEnabled=false
	if antiLagDescConn then antiLagDescConn:Disconnect();antiLagDescConn=nil end
	pcall(function()
		local LightingSvc = game:GetService("Lighting")
		if defLightBrightness then LightingSvc.Brightness=defLightBrightness end
		if defLightClock then LightingSvc.ClockTime=defLightClock end
		if defLightAmbient then LightingSvc.OutdoorAmbient=defLightAmbient end
		LightingSvc.ExposureCompensation=0
	end)
end

local function updateGalaxy()
	if galaxyOn then
		if galaxySky then galaxySky:Destroy() end
		galaxySky = Instance.new("Sky")
		galaxySky.Name = "NgasGalaxySky"
		galaxySky.SkyboxBk = "rbxassetid://159454299"
		galaxySky.SkyboxDn = "rbxassetid://159454296"
		galaxySky.SkyboxFt = "rbxassetid://159454293"
		galaxySky.SkyboxLf = "rbxassetid://159454286"
		galaxySky.SkyboxRt = "rbxassetid://159454289"
		galaxySky.SkyboxUp = "rbxassetid://159454291"
		galaxySky.Parent = Lighting
		Lighting.Brightness = 0
		Lighting.ClockTime = 0
		Lighting.ExposureCompensation = -2
		Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
	else
		if galaxySky then galaxySky:Destroy(); galaxySky = nil end
		if defLightBrightness then Lighting.Brightness = defLightBrightness end
		if defLightClock then Lighting.ClockTime = defLightClock end
		Lighting.ExposureCompensation = 0
		if defLightAmbient then Lighting.OutdoorAmbient = defLightAmbient end
	end
end

RunService.Stepped:Connect(function()
	if antiFlingOn and LP.Character then
		for _, obj in pairs(LP.Character:GetDescendants()) do
			if obj:IsA("BasePart") then obj.CanCollide = false end
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")
	if not root or not hum then return end

	local currentTool = char:FindFirstChildOfClass("Tool")
	local holdingBat = currentTool and currentTool.Name:lower():find("bat")

	if not antiBatOn or holdingBat then
		local spin = root:FindFirstChild("NgasForce")
		if spin then spin:Destroy() hum.AutoRotate = true end
		return
	end

	local threat = false
	for _, other in pairs(Players:GetPlayers()) do
		if other ~= LP and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
			if (root.Position - other.Character.HumanoidRootPart.Position).Magnitude <= detectDistance then
				threat = true break
			end
		end
	end

	local spin = root:FindFirstChild("NgasForce")
	if threat then
		if not spin then
			local bv = Instance.new("BodyAngularVelocity")
			bv.Name = "NgasForce"
			bv.MaxTorque = Vector3.new(0, math.huge, 0)
			bv.AngularVelocity = Vector3.new(0, 50, 0)
			bv.Parent = root
			hum.AutoRotate = false
		end
	elseif spin then
		spin:Destroy()
		hum.AutoRotate = true
	end
end)

-- ========== SONGS SYSTEM ==========
local Songs = {
	ActiveSong = nil,
	ActiveSongId = nil,
	ToggleStates = {},
	SongList = {
		{"Low Cortisol", 110919391228823},
		{"Tuff Song", 115853391091360},
		{"Tuff a$$ song 2", 89762852335338},
		{"Tuff a$$ song 3", 103409564066173},
		{"RIP MY GRANNY", 121252909004354},
		{"Hello Juliet", 101816084223643},
		{"67 Phonk", 125476440612900}
	}
}

local function playSong(assetId)
	if Songs.ActiveSong then
		Songs.ActiveSong:Stop()
		Songs.ActiveSong:Destroy()
		Songs.ActiveSong = nil
		Songs.ActiveSongId = nil
	end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. tostring(assetId)
	s.Volume = 1
	s.Looped = true
	s.Parent = SoundService
	s:Play()
	Songs.ActiveSong = s
	Songs.ActiveSongId = assetId
end

local function stopSong()
	if Songs.ActiveSong then
		Songs.ActiveSong:Stop()
		Songs.ActiveSong:Destroy()
		Songs.ActiveSong = nil
		Songs.ActiveSongId = nil
	end
end

local function saveSongConfig()
	local saveData = {Songs = {}}
	for k, v in pairs(Songs.ToggleStates) do
		saveData.Songs[k] = v
	end
	pcall(function() writefile("NomeHub_Songs_config.json", HS:JSONEncode(saveData)) end)
end

local function loadSongConfig()
	pcall(function()
		if isfile("NomeHub_Songs_config.json") then
			local data = HS:JSONDecode(readfile("NomeHub_Songs_config.json"))
			if data.Songs then
				for k, v in pairs(data.Songs) do
					Songs.ToggleStates[k] = v
				end
			end
		end
	end)
end

-- ========== ORIGINAL STATE ==========
local State = {
	normalSpeed = 60, carrySpeed = 30, laggerSpeed = 13,
	speedType = "normal",
	laggerActive = false,
	autoBatToggled = false,
	hittingCooldown = false, infJumpEnabled = false,
	antiRagdollEnabled = false, fpsBoostEnabled = false,
	guiVisible = true,
	isStealing = false, stealStartTime = nil, lastStealTick = 0,
	medusaLastUsed = 0, medusaDebounce = false, medusaCounterEnabled = false,
	dropBrainrotActive = false,
	autoTpDownEnabled = false, autoTpDownY = 20,
	autoLeftEnabled = false, autoRightEnabled = false,
	autoLeftPhase = 1, autoRightPhase = 1,
	_tpInProgress = false,
	lastMoveDir = Vector3.new(0,0,0),
	animEnabled = false, unwalkEnabled = false,
	infJumpMode = "manual",
	dropBrainrotToggled = false,
	tpDownToggled = false,
	keyAutoLeft = Enum.KeyCode.Unknown,
	keyAutoRight = Enum.KeyCode.Unknown,
	keyDropBR = Enum.KeyCode.Unknown,
	keyTpDown = Enum.KeyCode.Unknown,
	keyAutoBat = Enum.KeyCode.Unknown,
	keyInstantReset = Enum.KeyCode.T,
	keyHideUI = Enum.KeyCode.LeftControl,
}

-- ========== AUTO‑STEAL ==========
local AutoSteal = {
	Enabled = false,
	Radius = 20,
	Duration = 1.3,
	IsStealing = false,
	Data = {},
	ProgressFill = nil,
	ProgressText = nil,
}

local function isMyPlotByName(plotName)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return false end
	local plot = plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yb = sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
	end
	return false
end

local function findNearestPrompt()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local bestPrompt, bestDist, bestName = nil, math.huge, nil
	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if not podiums then continue end
		for _, pod in ipairs(podiums:GetChildren()) do
			pcall(function()
				local base = pod:FindFirstChild("Base")
				local spawn = base and base:FindFirstChild("Spawn")
				if spawn then
					local dist = (spawn.Position - root.Position).Magnitude
					if dist < bestDist and dist <= AutoSteal.Radius then
						local att = spawn:FindFirstChild("PromptAttachment")
						if att then
							for _, child in ipairs(att:GetChildren()) do
								if child:IsA("ProximityPrompt") then
									bestPrompt, bestDist, bestName = child, dist, pod.Name
									break
								end
							end
						end
					end
				end
			end)
		end
	end
	return bestPrompt, bestDist, bestName
end

local function executeSteal(prompt, animalName)
	if AutoSteal.IsStealing then return end
	if not AutoSteal.Data[prompt] then
		AutoSteal.Data[prompt] = {hold = {}, trigger = {}, ready = true}
		pcall(function()
			if getconnections then
				for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
					if c.Function then table.insert(AutoSteal.Data[prompt].hold, c.Function) end
				end
				for _, c in ipairs(getconnections(prompt.Triggered)) do
					if c.Function then table.insert(AutoSteal.Data[prompt].trigger, c.Function) end
				end
			end
		end)
	end
	local data = AutoSteal.Data[prompt]
	if not data.ready then return end
	data.ready = false
	AutoSteal.IsStealing = true
	local startTime = tick()

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not AutoSteal.IsStealing then
			conn:Disconnect()
			return
		end
		local prog = math.clamp((tick() - startTime) / AutoSteal.Duration, 0, 1)
		if AutoSteal.ProgressFill then
			AutoSteal.ProgressFill.Size = UDim2.new(prog, 0, 1, 0)
		end
		if AutoSteal.ProgressText then
			AutoSteal.ProgressText.Text = math.floor(prog * 100).."%"
		end
	end)

	task.spawn(function()
		for _, f in ipairs(data.hold) do task.spawn(f) end
		task.wait(AutoSteal.Duration)
		for _, f in ipairs(data.trigger) do task.spawn(f) end
		AutoSteal.IsStealing = false
		data.ready = true
		task.wait(0.6)
		if not AutoSteal.IsStealing and AutoSteal.ProgressFill then
			TweenService:Create(AutoSteal.ProgressFill, TweenInfo.new(0.4), {Size = UDim2.new(0,0,1,0)}):Play()
		end
		if AutoSteal.ProgressText then
			AutoSteal.ProgressText.Text = "0%"
		end
	end)
end

local autoStealConnection = nil
local function startAutoSteal()
	if autoStealConnection then return end
	autoStealConnection = RunService.Heartbeat:Connect(function()
		if AutoSteal.Enabled and not AutoSteal.IsStealing then
			local p, _, name = findNearestPrompt()
			if p then executeSteal(p, name) end
		end
	end)
end
local function stopAutoSteal()
	if autoStealConnection then
		autoStealConnection:Disconnect()
		autoStealConnection = nil
	end
	AutoSteal.IsStealing = false
	for k, v in pairs(AutoSteal.Data) do
		if v.ready ~= nil then v.ready = true end
	end
end

-- ========== MOVEMENT ==========
local MOVE_KEYS = {
	[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
	[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
	[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,
	[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,
}

local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150

local POS = {
	L1 = Vector3.new(-476.48,-6.28,92.73), L2 = Vector3.new(-483.12,-4.95,94.80),
	R1 = Vector3.new(-476.16,-6.52,25.62), R2 = Vector3.new(-483.04,-5.09,23.14),
}

local Conns = {
	autoSteal = nil, antiRag = nil,
	autoLeft = nil, autoRight = nil,
	anchor = {}, progress = nil,
}

local h, hrp, speedLbl
local setAutoLeft, setAutoRight, setInstaGrab, setAutoBat, setInfJump, setAntiRag, setFps, setMedusaCounter, setAutoTpDown
local setAnimToggle, setUnwalkToggle, setupMedusaCounter, stopMedusaCounter, startAntiRagdoll, stopAntiRagdoll, applyFPSBoost
local modeValLbl, normalBox, carryBox, laggerBox
local setSpeedToggleUI, setLaggerToggleUI, progressRadLbl, setMenuDropBR, setMenuTpDown
local antiLagToggleUI, stretchRezToggleUI, removeAccToggleUI
local fovToggleUI, galaxyToggleUI, antiBatToggleUI, antiFlingToggleUI

-- ========== AUTO‑SAVE ==========
local saveDebounce = false
local function autoSaveConfig()
	if saveDebounce then return end
	saveDebounce = true
	task.delay(0.5, function()
		local cfg = {
			normalSpeed=State.normalSpeed, carrySpeed=State.carrySpeed,
			laggerSpeed=State.laggerSpeed,
			speedType=State.speedType, laggerActive=State.laggerActive,
			autoBatToggled=State.autoBatToggled,
			autoLeftEnabled=State.autoLeftEnabled, autoRightEnabled=State.autoRightEnabled,
			autoStealEnabled=AutoSteal.Enabled, grabRadius=AutoSteal.Radius,
			infJump=State.infJumpEnabled, antiRagdoll=State.antiRagdollEnabled, fpsBoost=State.fpsBoostEnabled,
			medusaCounter=State.medusaCounterEnabled,
			animEnabled=State.animEnabled, unwalkEnabled=State.unwalkEnabled,
			autoTpDown=State.autoTpDownEnabled, autoTpDownY=State.autoTpDownY,
			infJumpMode=State.infJumpMode,
			keyAutoLeft=State.keyAutoLeft.Name, keyAutoRight=State.keyAutoRight.Name,
			keyDropBR=State.keyDropBR.Name, keyTpDown=State.keyTpDown.Name, keyAutoBat=State.keyAutoBat.Name,
			keyInstantReset=State.keyInstantReset.Name, keyHideUI=State.keyHideUI.Name,
			antiLag=antiLagEnabled, stretchRez=stretchRezEnabled, removeAccessories=removeAccessoriesEnabled,
			fovOn=fovOn, galaxyOn=galaxyOn, antiBatOn=antiBatOn, antiFlingOn=antiFlingOn
		}
		pcall(function() writefile("NomeHubConfig.json", HS:JSONEncode(cfg)) end)
		saveDebounce = false
	end)
end

-- ========== SPEED FUNCTIONS ==========
local function refreshUIToggles()
	if setSpeedToggleUI then setSpeedToggleUI(State.speedType == "carry") end
	if setLaggerToggleUI then setLaggerToggleUI(State.laggerActive) end
	if State.laggerActive then
		modeValLbl.Text = "Lagger Mode"
	else
		modeValLbl.Text = (State.speedType == "normal") and "Normal" or "Carry"
	end
end

local function deactivateAllSpeedModes()
	if State.speedType == "carry" then
		State.speedType = "normal"
	end
	if State.laggerActive then
		State.laggerActive = false
	end
end

local function toggleSpeedType()
	if State.speedType == "carry" then
		State.speedType = "normal"
		refreshUIToggles()
		autoSaveConfig()
		return
	end
	deactivateAllSpeedModes()
	State.speedType = "carry"
	refreshUIToggles()
	autoSaveConfig()
end

local function toggleLagger()
	if State.laggerActive then
		State.laggerActive = false
		refreshUIToggles()
		autoSaveConfig()
		return
	end
	deactivateAllSpeedModes()
	State.laggerActive = true
	refreshUIToggles()
	autoSaveConfig()
end

local function getCurrentSpeed()
	if State.laggerActive then
		return State.laggerSpeed
	else
		return State.speedType == "normal" and State.normalSpeed or State.carrySpeed
	end
end

local function getAutoMoveSpeed()
	if State.laggerActive then
		return State.laggerSpeed
	else
		return State.normalSpeed
	end
end

-- ========== UTILITY FUNCTIONS ==========
local function tpToGround()
	local char = LP.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local rot = root.CFrame.Rotation
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}
	local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -500, 0), raycastParams)
	if rayResult then
		root.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0)) * rot
	else
		root.CFrame = CFrame.new(root.Position + Vector3.new(0, -20, 0)) * rot
	end
end

local function runDropBrainrot()
	if State.dropBrainrotActive then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
	State.dropBrainrotActive=true; local t0=tick(); local dc
	dc=RunService.Heartbeat:Connect(function()
		local r=char and char:FindFirstChild("HumanoidRootPart")
		if not r then dc:Disconnect(); State.dropBrainrotActive=false; return end
		if tick()-t0>=DROP_ASCEND_DURATION then
			dc:Disconnect()
			local rp=RaycastParams.new(); rp.FilterDescendantsInstances={char}; rp.FilterType=Enum.RaycastFilterType.Exclude
			local rr=workspace:Raycast(r.Position,Vector3.new(0,-2000,0),rp)
			if rr then
				local hum2=char:FindFirstChildOfClass("Humanoid")
				local off=(hum2 and hum2.HipHeight or 2)+(r.Size.Y/2)
				r.CFrame=CFrame.new(r.Position.X,rr.Position.Y+off,r.Position.Z); r.AssemblyLinearVelocity=Vector3.new(0,0,0)
			end
			State.dropBrainrotActive=false; return
		end
		r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X,DROP_ASCEND_SPEED,r.AssemblyLinearVelocity.Z)
	end)
end

-- ========== ANIMATIONS ==========
local Anims = {
	idle1    = "rbxassetid://133806214992291",
	idle2    = "rbxassetid://94970088341563",
	walk     = "rbxassetid://707897309",
	run      = "rbxassetid://707861613",
	jump     = "rbxassetid://116936326516985",
	fall     = "rbxassetid://116936326516985",
	climb    = "rbxassetid://116936326516985",
	swim     = "rbxassetid://116936326516985",
	swimidle = "rbxassetid://116936326516985",
}

local animHeartbeatConn = nil
local savedAnimate = nil
local originalAnims = nil

local function isPackAnim(id)
	if not id then return false end
	for _, v in pairs(Anims) do if v == id then return true end end
	return false
end

local function saveOriginalAnims(char)
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function g(obj) return obj and obj.AnimationId or nil end
	local ids = {
		idle1    = g(animate.idle     and animate.idle.Animation1),
		idle2    = g(animate.idle     and animate.idle.Animation2),
		walk     = g(animate.walk     and animate.walk.WalkAnim),
		run      = g(animate.run      and animate.run.RunAnim),
		jump     = g(animate.jump     and animate.jump.JumpAnim),
		fall     = g(animate.fall     and animate.fall.FallAnim),
		climb    = g(animate.climb    and animate.climb.ClimbAnim),
		swim     = g(animate.swim     and animate.swim.Swim),
		swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
	}
	if not isPackAnim(ids.walk) then originalAnims = ids end
end

local function applyAnimPack(char)
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function s(obj, id) if obj then obj.AnimationId = id end end
	s(animate.idle     and animate.idle.Animation1,     Anims.idle1)
	s(animate.idle     and animate.idle.Animation2,     Anims.idle2)
	s(animate.walk     and animate.walk.WalkAnim,       Anims.walk)
	s(animate.run      and animate.run.RunAnim,         Anims.run)
	s(animate.jump     and animate.jump.JumpAnim,       Anims.jump)
	s(animate.fall     and animate.fall.FallAnim,       Anims.fall)
	s(animate.climb    and animate.climb.ClimbAnim,     Anims.climb)
	s(animate.swim     and animate.swim.Swim,           Anims.swim)
	s(animate.swimidle and animate.swimidle.SwimIdle,   Anims.swimidle)
end

local function restoreOriginalAnims(char)
	if not originalAnims then return end
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function s(obj, id) if obj and id then obj.AnimationId = id end end
	s(animate.idle     and animate.idle.Animation1,     originalAnims.idle1)
	s(animate.idle     and animate.idle.Animation2,     originalAnims.idle2)
	s(animate.walk     and animate.walk.WalkAnim,       originalAnims.walk)
	s(animate.run      and animate.run.RunAnim,         originalAnims.run)
	s(animate.jump     and animate.jump.JumpAnim,       originalAnims.jump)
	s(animate.fall     and animate.fall.FallAnim,       originalAnims.fall)
	s(animate.climb    and animate.climb.ClimbAnim,     originalAnims.climb)
	s(animate.swim     and animate.swim.Swim,           originalAnims.swim)
	s(animate.swimidle and animate.swimidle.SwimIdle,   originalAnims.swimidle)
	local hum2 = char:FindFirstChildOfClass("Humanoid")
	if hum2 then
		for _, track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end
		hum2:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function startAnimToggle()
	if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
	local char = LP.Character
	if char then
		saveOriginalAnims(char)
		applyAnimPack(char)
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then
			for _, track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end
			hum2:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
	animHeartbeatConn = RunService.Heartbeat:Connect(function()
		if not State.animEnabled then return end
		local c = LP.Character
		if c then applyAnimPack(c) end
	end)
end

local function stopAnimToggle()
	if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
	local char = LP.Character
	if char then restoreOriginalAnims(char) end
end

local function startUnwalk()
	if State.unwalkEnabled then return end
	State.unwalkEnabled = true
	local c = LP.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
	local anim = c:FindFirstChild("Animate")
	if anim then savedAnimate = anim:Clone(); anim:Destroy() end
end

local function stopUnwalk()
	if not State.unwalkEnabled then return end
	State.unwalkEnabled = false
	local c = LP.Character
	if c and savedAnimate then
		savedAnimate.Parent = c; savedAnimate.Disabled = false; savedAnimate = nil
	end
	task.spawn(function()
		task.wait(0.15)
		local char = LP.Character
		if not char then return end
		if State.animEnabled then saveOriginalAnims(char); applyAnimPack(char)
		else restoreOriginalAnims(char) end
	end)
end

-- ========== MEDUSA ==========
local function findMedusa()
	local char=LP.Character; if not char then return nil end
	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then local tn=tool.Name:lower()
			if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end
	end
	local bp2=LP:FindFirstChild("Backpack")
	if bp2 then for _,tool in ipairs(bp2:GetChildren()) do
		if tool:IsA("Tool") then local tn=tool.Name:lower()
			if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end
	end end
	return nil
end

local function useMedusaCounter()
	if State.medusaDebounce then return end
	if tick()-State.medusaLastUsed<25 then return end
	local char=LP.Character; if not char then return end
	State.medusaDebounce=true
	local med=findMedusa(); if not med then State.medusaDebounce=false; return end
	if med.Parent~=char then local hum2=char:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(med) end end
	pcall(function() med:Activate() end)
	State.medusaLastUsed=tick(); State.medusaDebounce=false
end

local function onAnchorChanged(part)
	return part:GetPropertyChangedSignal("Anchored"):Connect(function()
		if part.Anchored and part.Transparency==1 then useMedusaCounter() end
	end)
end
setupMedusaCounter = function(char)
	stopMedusaCounter(); if not char then return end
	for _,part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
	end
	table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
	end))
end
stopMedusaCounter = function()
	for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end; Conns.anchor={}
end

-- ========== AUTO LEFT/RIGHT ==========
startAutoLeft = function()
	if Conns.autoLeft then Conns.autoLeft:Disconnect() end
	State.autoLeftPhase = 1
	Conns.autoLeft = RunService.Heartbeat:Connect(function()
		if not State.autoLeftEnabled then return end
		local char = LP.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum2 then return end
		local spd = getAutoMoveSpeed()
		if State.autoLeftPhase == 1 then
			local tgt = Vector3.new(POS.L1.X, root.Position.Y, POS.L1.Z)
			if (tgt - root.Position).Magnitude < 1 then
				State.autoLeftPhase = 2
				return
			end
			local d = (POS.L1 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		elseif State.autoLeftPhase == 2 then
			local tgt = Vector3.new(POS.L2.X, root.Position.Y, POS.L2.Z)
			if (tgt - root.Position).Magnitude < 1 then
				hum2:Move(Vector3.zero, false)
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				State.autoLeftEnabled = false
				if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft = nil end
				State.autoLeftPhase = 1
				if setAutoLeft then setAutoLeft(false) end
				return
			end
			local d = (POS.L2 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
end

stopAutoLeft = function()
	if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft = nil end
	State.autoLeftPhase = 1
	local char = LP.Character
	if char then
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:Move(Vector3.zero, false) end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
	end
end

startAutoRight = function()
	if Conns.autoRight then Conns.autoRight:Disconnect() end
	State.autoRightPhase = 1
	Conns.autoRight = RunService.Heartbeat:Connect(function()
		if not State.autoRightEnabled then return end
		local char = LP.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum2 then return end
		local spd = getAutoMoveSpeed()
		if State.autoRightPhase == 1 then
			local tgt = Vector3.new(POS.R1.X, root.Position.Y, POS.R1.Z)
			if (tgt - root.Position).Magnitude < 1 then
				State.autoRightPhase = 2
				return
			end
			local d = (POS.R1 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		elseif State.autoRightPhase == 2 then
			local tgt = Vector3.new(POS.R2.X, root.Position.Y, POS.R2.Z)
			if (tgt - root.Position).Magnitude < 1 then
				hum2:Move(Vector3.zero, false)
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				State.autoRightEnabled = false
				if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight = nil end
				State.autoRightPhase = 1
				if setAutoRight then setAutoRight(false) end
				return
			end
			local d = (POS.R2 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
end

stopAutoRight = function()
	if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight = nil end
	State.autoRightPhase = 1
	local char = LP.Character
	if char then
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:Move(Vector3.zero, false) end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
	end
end

-- ========== ANTI RAGDOLL ==========
startAntiRagdoll = function()
	if Conns.antiRag then return end
	Conns.antiRag=RunService.Heartbeat:Connect(function()
		local char=LP.Character; if not char then return end
		local hum2=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
		if hum2 then
			local st=hum2:GetState()
			if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
				hum2:ChangeState(Enum.HumanoidStateType.Running); workspace.CurrentCamera.CameraSubject=hum2
				pcall(function() local pm=LP.PlayerScripts:FindFirstChild("PlayerModule"); if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)
				if root then root.Velocity=Vector3.new(0,0,0); root.RotVelocity=Vector3.new(0,0,0) end
			end
		end
		for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
	end)
end
stopAntiRagdoll = function()
	if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag=nil end
end

-- ========== FPS BOOST ==========
applyFPSBoost = function()
	pcall(function() setfpscap(999999999) end)
	local function processObj(v)
		pcall(function()
			if v:IsA("Model") then v.LevelOfDetail=Enum.ModelLevelOfDetail.Disabled; v.ModelStreamingMode=Enum.ModelStreamingMode.Nonatomic
			elseif v:IsA("MeshPart") then v.CastShadow=false; v.DoubleSided=false; v.RenderFidelity=Enum.RenderFidelity.Performance
			elseif v:IsA("BasePart") then v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0
			elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
			elseif v:IsA("SpecialMesh") then v.TextureId=""
			elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false
			elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then v:Destroy()
			elseif v:IsA("Attachment") then v.Visible=false end
		end)
	end
	for _,v in pairs(workspace:GetDescendants()) do processObj(v) end
	pcall(function()
		local lighting=game:GetService("Lighting")
		for _,v in pairs(lighting:GetDescendants()) do
			pcall(function()
				if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds") or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then v:Destroy() end
			end)
		end
		pcall(function() sethiddenproperty(game:GetService("Lighting"),"Technology",Enum.Technology.Legacy) end)
		local lighting2=game:GetService("Lighting")
		lighting2.GlobalShadows=false; lighting2.FogEnd=9e9; lighting2.Brightness=0
		local terrain=workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function() sethiddenproperty(terrain,"Decoration",false) end)
			terrain.WaterReflectance=0; terrain.WaterTransparency=0.7; terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0
		end
	end)
	workspace.DescendantAdded:Connect(function(v) if State.fpsBoostEnabled then task.spawn(processObj,v) end end)
end

-- ========== BAT ==========
local function getBat()
	local char=LP.Character; if not char then return nil end
	local tool=char:FindFirstChild("Bat"); if tool then return tool end
	local bp2=LP:FindFirstChild("Backpack")
	if bp2 then tool=bp2:FindFirstChild("Bat"); if tool then tool.Parent=char; return tool end end
	return nil
end
local function tryHitBat()
	if State.hittingCooldown then return end; State.hittingCooldown=true
	pcall(function()
		local bat=getBat(); if bat then
			bat:Activate(); local ev=bat:FindFirstChildWhichIsA("RemoteEvent")
			if ev then ev:FireServer() end
		end
	end)
	task.delay(0.08, function() State.hittingCooldown=false end)
end

local function getClosestPlayer()
	if not hrp then return nil,math.huge end
	local cp,cd=nil,math.huge
	for _,p in pairs(Players:GetPlayers()) do
		if p~=LP and p.Character then
			local tr=p.Character:FindFirstChild("HumanoidRootPart")
			if tr then local d=(hrp.Position-tr.Position).Magnitude; if d<cd then cd=d; cp=p end end
		end
	end
	return cp,cd
end

-- ========== KEYBOARD BINDINGS SYSTEM ==========
local KeybindHandler = {
	Bindings = {},
	Listeners = {},
	ListeningForBind = nil,
	ListeningCallback = nil,
}

function KeybindHandler:RegisterBinding(name, defaultKey, callback)
	self.Bindings[name] = {
		Key = defaultKey,
		Callback = callback,
	}
end

function KeybindHandler:SetBinding(name, keyCode)
	if self.Bindings[name] then
		self.Bindings[name].Key = keyCode
		autoSaveConfig()
		return true
	end
	return false
end

function KeybindHandler:GetBinding(name)
	return self.Bindings[name] and self.Bindings[name].Key or Enum.KeyCode.Unknown
end

function KeybindHandler:StartListening(callback)
	self.ListeningForBind = true
	self.ListeningCallback = callback
end

function KeybindHandler:StopListening()
	self.ListeningForBind = false
	self.ListeningCallback = nil
end

-- Register default keybindings
KeybindHandler:RegisterBinding("AutoLeft", State.keyAutoLeft, function()
	State.autoLeftEnabled = not State.autoLeftEnabled
	if setAutoLeft then setAutoLeft(State.autoLeftEnabled) end
	if State.autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
	autoSaveConfig()
end)

KeybindHandler:RegisterBinding("AutoRight", State.keyAutoRight, function()
	State.autoRightEnabled = not State.autoRightEnabled
	if setAutoRight then setAutoRight(State.autoRightEnabled) end
	if State.autoRightEnabled then startAutoRight() else stopAutoRight() end
	autoSaveConfig()
end)

KeybindHandler:RegisterBinding("DropBrainrot", State.keyDropBR, function()
	runDropBrainrot()
	if setMenuDropBR then setMenuDropBR(true) end
	task.delay(0.5, function()
		if setMenuDropBR then setMenuDropBR(false) end
	end)
end)

KeybindHandler:RegisterBinding("TpDown", State.keyTpDown, function()
	tpToGround()
	if setMenuTpDown then setMenuTpDown(true) end
	task.delay(0.5, function()
		if setMenuTpDown then setMenuTpDown(false) end
	end)
end)

KeybindHandler:RegisterBinding("AutoBat", State.keyAutoBat, function()
	State.autoBatToggled = not State.autoBatToggled
	if setAutoBat then setAutoBat(State.autoBatToggled) end
	autoSaveConfig()
end)

KeybindHandler:RegisterBinding("InstantReset", State.keyInstantReset, function()
	cursedInstaReset()
end)

KeybindHandler:RegisterBinding("HideUI", State.keyHideUI, function()
	main.Visible = not main.Visible
end)

-- Keyboard input handler
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Handle key binding listening mode
	if KeybindHandler.ListeningForBind and input.UserInputType == Enum.UserInputType.Keyboard then
		local keyCode = input.KeyCode
		if keyCode ~= Enum.KeyCode.Unknown then
			KeybindHandler.ListeningForBind = false
			if KeybindHandler.ListeningCallback then
				KeybindHandler.ListeningCallback(keyCode)
				KeybindHandler.ListeningCallback = nil
			end
		end
		return
	end
	
	-- Normal keybind processing
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local keyCode = input.KeyCode
		for name, binding in pairs(KeybindHandler.Bindings) do
			if binding.Key == keyCode and binding.Callback then
				task.spawn(binding.Callback)
				break
			end
		end
	end
end)

-- ========== MOBILE BUTTONS ==========
local MobileButtons = {
	Visible = true,
	Locked = true,
	Frame = nil,
	Containers = {},
	Buttons = {}
}

local function createMobilePanel()
	local panel = Instance.new("ScreenGui")
	panel.Name = "NomeHubButtons"
	panel.Parent = LP:WaitForChild("PlayerGui")
	panel.ResetOnSpawn = false
	panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local BTN_W = 52
	local BTN_H = 52
	local CORNER = 12
	local GAP = 10
	local COL1_X = -(BTN_W + GAP + BTN_W + 8)
	local COL2_X = -(BTN_W + 8)
	local BASE_Y = 0.30
	local ROW_Y  = {-((BTN_H*4+GAP*3)/2), -((BTN_H*4+GAP*3)/2)+(BTN_H+GAP),
					-((BTN_H*4+GAP*3)/2)+(BTN_H+GAP)*2, -((BTN_H*4+GAP*3)/2)+(BTN_H+GAP)*3}

	local function makeSeparateBtn(name, text, defaultPos, saveKey, callback, isToggle)
		local container = Instance.new("Frame")
		container.Name = name
		container.Parent = panel
		container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		container.BackgroundTransparency = 0
		container.BorderSizePixel = 0
		container.Size = UDim2.new(0, BTN_W, 0, BTN_H)
		container.Position = defaultPos
		Instance.new("UICorner", container).CornerRadius = UDim.new(0, CORNER)
		
		local btnStroke = Instance.new("UIStroke", container)
		btnStroke.Color = Color3.fromRGB(255, 255, 255)
		btnStroke.Thickness = 1.5
		btnStroke.Transparency = 0

		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Font = Enum.Font.GothamBlack
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 11
		btn.TextWrapped = true
		btn.AutoButtonColor = false

		local active = false
		local function setActive(state)
			active = state
			if active then
				container.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end

		btn.MouseButton1Down:Connect(function()
			container.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		end)
		btn.MouseButton1Up:Connect(function()
			if not isToggle then
				container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end)
		btn.MouseButton1Click:Connect(function()
			if isToggle then setActive(not active) end
			if callback then callback(setActive, active) end
		end)

		local dragging = false
		local dragStart = nil
		local startPos = nil
		container.InputBegan:Connect(function(input)
			if MobileButtons.Locked then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = container.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancelled then
						dragging = false
					end
				end)
			end
		end)
		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)

		local savedPos = nil
		pcall(function() savedPos = readfile(saveKey) end)
		if savedPos and savedPos ~= "" then
			local parts = {}
			for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
			if #parts >= 4 then
				container.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
			end
		end
		local lastSave = 0
		container:GetPropertyChangedSignal("Position"):Connect(function()
			if tick() - lastSave > 0.5 then
				lastSave = tick()
				local pos = container.Position
				local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
				pcall(function() writefile(saveKey, str) end)
			end
		end)

		container.Visible = MobileButtons.Visible
		table.insert(MobileButtons.Containers, container)
		return setActive
	end

	local dropBRSetActive = makeSeparateBtn("BtnDropBR", "DROP\nBR",
		UDim2.new(1, COL1_X, BASE_Y, ROW_Y[1]), "NomeBtn_dropbr.txt",
		function(setActive, currentActive)
			runDropBrainrot()
			if setMenuDropBR then setMenuDropBR(true) end
			task.delay(0.5, function()
				if setMenuDropBR then setMenuDropBR(false) end
				setActive(false)
			end)
		end, true)

	local autoLeftSetActive = makeSeparateBtn("BtnAutoLeft", "AUTO\nLEFT",
		UDim2.new(1, COL2_X, BASE_Y, ROW_Y[1]), "NomeBtn_autoleft.txt",
		function(setActive)
			State.autoLeftEnabled = not State.autoLeftEnabled
			if setAutoLeft then setAutoLeft(State.autoLeftEnabled) end
			if State.autoLeftEnabled then startAutoLeft(); setActive(true)
			else stopAutoLeft(); setActive(false) end
			autoSaveConfig()
		end, true)

	local autoBatSetActive = makeSeparateBtn("BtnAutoBat", "BAT\nAIMBOT",
		UDim2.new(1, COL1_X, BASE_Y, ROW_Y[2]), "NomeBtn_autobat.txt",
		function(setActive)
			State.autoBatToggled = not State.autoBatToggled
			setAutoBat(State.autoBatToggled)
			setActive(State.autoBatToggled)
			autoSaveConfig()
		end, true)

	local autoRightSetActive = makeSeparateBtn("BtnAutoRight", "AUTO\nRIGHT",
		UDim2.new(1, COL2_X, BASE_Y, ROW_Y[2]), "NomeBtn_autoright.txt",
		function(setActive)
			State.autoRightEnabled = not State.autoRightEnabled
			if setAutoRight then setAutoRight(State.autoRightEnabled) end
			if State.autoRightEnabled then startAutoRight(); setActive(true)
			else stopAutoRight(); setActive(false) end
			autoSaveConfig()
		end, true)

	local tpDownSetActive = makeSeparateBtn("BtnTpDown", "TP\nDOWN",
		UDim2.new(1, COL1_X, BASE_Y, ROW_Y[3]), "NomeBtn_tpdown.txt",
		function(setActive, currentActive)
			tpToGround()
			if setMenuTpDown then setMenuTpDown(true) end
			task.delay(0.5, function()
				if setMenuTpDown then setMenuTpDown(false) end
				setActive(false)
			end)
		end, true)

	local carrySpeedSetActive = makeSeparateBtn("BtnCarrySpd", "CARRY\nSPD",
		UDim2.new(1, COL2_X, BASE_Y, ROW_Y[3]), "NomeBtn_carryspd.txt",
		function(setActive)
			toggleSpeedType()
			setActive(State.speedType == "carry")
		end, true)

	local instantResetSetActive = makeSeparateBtn("BtnInstantReset", "INSTANT\nRESET",
		UDim2.new(1, COL1_X, BASE_Y, ROW_Y[4]), "NomeBtn_instantreset.txt",
		function(setActive, currentActive)
			cursedInstaReset()
			setActive(true)
			task.delay(0.1, function() setActive(false) end)
		end, true)

	local laggerSetActive = makeSeparateBtn("BtnLaggerMode", "LAGGER\nMODE",
		UDim2.new(1, COL2_X, BASE_Y, ROW_Y[4]), "NomeBtn_laggermode.txt",
		function(setActive)
			toggleLagger()
			setActive(State.laggerActive)
		end, true)

	MobileButtons.Buttons = {
		autoLeft = autoLeftSetActive,
		autoRight = autoRightSetActive,
		autoBat = autoBatSetActive,
		carrySpeed = carrySpeedSetActive,
		lagger = laggerSetActive,
		dropBR = dropBRSetActive,
		tpDown = tpDownSetActive,
		instantReset = instantResetSetActive,
	}

	task.spawn(function()
		task.wait(0.1)
		if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(State.autoLeftEnabled) end
		if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(State.autoRightEnabled) end
		if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(State.autoBatToggled) end
		if MobileButtons.Buttons.carrySpeed then MobileButtons.Buttons.carrySpeed(State.speedType == "carry") end
		if MobileButtons.Buttons.lagger then MobileButtons.Buttons.lagger(State.laggerActive) end
	end)

	return panel
end

-- ========== GUI HELPER FUNCTIONS ==========
local function ApplyStyle(obj)
    obj.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    obj.BackgroundTransparency = 0.15
    
    local Corner = Instance.new("UICorner", obj)
    Corner.CornerRadius = UDim.new(0, 4)

    local Stroke = Instance.new("UIStroke", obj)
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.3
end

-- ========== TAB SYSTEM ==========
local BG    = Color3.fromRGB(0,0,0)
local BG2   = Color3.fromRGB(5,0,0)
local CARD  = Color3.fromRGB(10,0,0)
local HOV   = Color3.fromRGB(20,0,0)
local RED   = Color3.fromRGB(255,0,0)
local REDDIM= Color3.fromRGB(100,0,0)
local W     = Color3.fromRGB(255,255,255)
local INP   = Color3.fromRGB(8,0,0)
local OFF   = Color3.fromRGB(20,0,0)

-- Clean up old GUIs
for _, name in pairs({"VexulHubGUI","NOMEHUB","NgasDualHelper_V2"}) do
	local old = game:GetService("CoreGui"):FindFirstChild(name)
	if old then old:Destroy() end
	local old2 = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild(name)
	if old2 then old2:Destroy() end
end

-- Create main ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "NOMEHUB"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.IgnoreGuiInset = true
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then 
	gui.Parent = LP:WaitForChild("PlayerGui") 
end

-- ========== MAIN CIRCLE BUTTON (🌹) ==========
local circleButton = Instance.new("ImageButton", gui)
circleButton.Size = UDim2.new(0, 45, 0, 45)
circleButton.Position = UDim2.new(0.02, 0, 0.05, 0)
circleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
circleButton.BackgroundTransparency = 0
circleButton.BorderSizePixel = 0
circleButton.Image = "rbxassetid://7073894519"
circleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
circleButton.ImageTransparency = 0.2

local circleCorner = Instance.new("UICorner", circleButton)
circleCorner.CornerRadius = UDim.new(1, 0)

local circleStroke = Instance.new("UIStroke", circleButton)
circleStroke.Color = Color3.fromRGB(255, 0, 0)
circleStroke.Thickness = 2
circleStroke.Transparency = 0

local circleText = Instance.new("TextLabel", circleButton)
circleText.Size = UDim2.new(1, 0, 1, 0)
circleText.BackgroundTransparency = 1
circleText.Text = "🌹"
circleText.TextColor3 = Color3.fromRGB(255, 255, 255)
circleText.Font = Enum.Font.GothamBold
circleText.TextSize = 24
circleText.TextScaled = true

-- Make circle draggable
local function dragCircle(btn)
	local dn, ds, sp, di = false
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dn = true; ds = i.Position; sp = btn.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dn = false end end)
		end
	end)
	btn.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
	end)
	UIS.InputChanged:Connect(function(i)
		if i == di and dn then
			local nX = sp.X.Offset + (i.Position.X - ds.X)
			local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
			btn.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
		end
	end)
end
dragCircle(circleButton)

-- ========== FULLSCREEN MAIN MENU ==========
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(1, 0, 1, 0)
main.Position = UDim2.new(0, 0, 0, 0)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 0)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(255, 0, 0)
mainStroke.Thickness = 2
mainStroke.Transparency = 0

circleButton.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	TweenService:Create(circleButton, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
	task.delay(0.2, function()
		TweenService:Create(circleButton, TweenInfo.new(0.2), {ImageTransparency = 0.2}):Play()
	end)
end)

-- Header
local hdr = Instance.new("Frame", main)
hdr.Size = UDim2.new(1, 0, 0, 45)
hdr.Position = UDim2.new(0, 0, 0, 0)
hdr.BackgroundColor3 = BG2
hdr.BorderSizePixel = 0
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 0)

local ttl = Instance.new("TextLabel", hdr)
ttl.Size = UDim2.new(1, -100, 1, 0)
ttl.Position = UDim2.new(0, 20, 0, 0)
ttl.BackgroundTransparency = 1
ttl.Text = "🌹 BR DUELS"
ttl.TextColor3 = RED
ttl.Font = Enum.Font.GothamBlack
ttl.TextSize = 20
ttl.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", hdr)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -50, 0.5, -17.5)
closeBtn.BackgroundColor3 = BG2
closeBtn.BorderSizePixel = 0
closeBtn.Text = "✕"
closeBtn.TextColor3 = REDDIM
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local function hideGui() main.Visible = false; autoSaveConfig() end
closeBtn.MouseButton1Click:Connect(hideGui)

-- Tab Bar
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 45)
tabBar.BackgroundColor3 = BG2
tabBar.BorderSizePixel = 0

local tabMain = Instance.new("TextButton", tabBar)
tabMain.Size = UDim2.new(0.25, 0, 1, 0)
tabMain.Position = UDim2.new(0, 0, 0, 0)
tabMain.BackgroundTransparency = 1
tabMain.Text = "MAIN"
tabMain.TextColor3 = RED
tabMain.Font = Enum.Font.GothamBold
tabMain.TextSize = 14

local tabVisual = Instance.new("TextButton", tabBar)
tabVisual.Size = UDim2.new(0.25, 0, 1, 0)
tabVisual.Position = UDim2.new(0.25, 0, 0, 0)
tabVisual.BackgroundTransparency = 1
tabVisual.Text = "VISUAL"
tabVisual.TextColor3 = Color3.fromRGB(100,0,0)
tabVisual.Font = Enum.Font.GothamBold
tabVisual.TextSize = 14

local tabSongs = Instance.new("TextButton", tabBar)
tabSongs.Size = UDim2.new(0.25, 0, 1, 0)
tabSongs.Position = UDim2.new(0.5, 0, 0, 0)
tabSongs.BackgroundTransparency = 1
tabSongs.Text = "SONGS"
tabSongs.TextColor3 = Color3.fromRGB(100,0,0)
tabSongs.Font = Enum.Font.GothamBold
tabSongs.TextSize = 14

local tabKeybinds = Instance.new("TextButton", tabBar)
tabKeybinds.Size = UDim2.new(0.25, 0, 1, 0)
tabKeybinds.Position = UDim2.new(0.75, 0, 0, 0)
tabKeybinds.BackgroundTransparency = 1
tabKeybinds.Text = "KEYBINDS"
tabKeybinds.TextColor3 = Color3.fromRGB(100,0,0)
tabKeybinds.Font = Enum.Font.GothamBold
tabKeybinds.TextSize = 14

-- Content Frames
local mainContent = Instance.new("ScrollingFrame", main)
mainContent.Size = UDim2.new(1, -40, 1, -105)
mainContent.Position = UDim2.new(0, 20, 0, 85)
mainContent.BackgroundTransparency = 1
mainContent.BorderSizePixel = 0
mainContent.ClipsDescendants = true
mainContent.ScrollBarThickness = 6
mainContent.ScrollBarImageColor3 = Color3.fromRGB(255,0,0)
mainContent.CanvasSize = UDim2.new(0, 0, 0, 0)
mainContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

local visualContent = Instance.new("ScrollingFrame", main)
visualContent.Size = UDim2.new(1, -40, 1, -105)
visualContent.Position = UDim2.new(0, 20, 0, 85)
visualContent.BackgroundTransparency = 1
visualContent.BorderSizePixel = 0
visualContent.ClipsDescendants = true
visualContent.ScrollBarThickness = 6
visualContent.ScrollBarImageColor3 = Color3.fromRGB(255,0,0)
visualContent.CanvasSize = UDim2.new(0, 0, 0, 0)
visualContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
visualContent.Visible = false

local songsContent = Instance.new("ScrollingFrame", main)
songsContent.Size = UDim2.new(1, -40, 1, -105)
songsContent.Position = UDim2.new(0, 20, 0, 85)
songsContent.BackgroundTransparency = 1
songsContent.BorderSizePixel = 0
songsContent.ClipsDescendants = true
songsContent.ScrollBarThickness = 6
songsContent.ScrollBarImageColor3 = Color3.fromRGB(255,0,0)
songsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
songsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
songsContent.Visible = false

local keybindsContent = Instance.new("ScrollingFrame", main)
keybindsContent.Size = UDim2.new(1, -40, 1, -105)
keybindsContent.Position = UDim2.new(0, 20, 0, 85)
keybindsContent.BackgroundTransparency = 1
keybindsContent.BorderSizePixel = 0
keybindsContent.ClipsDescendants = true
keybindsContent.ScrollBarThickness = 6
keybindsContent.ScrollBarImageColor3 = Color3.fromRGB(255,0,0)
keybindsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
keybindsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
keybindsContent.Visible = false

-- Tab switching
local function switchTab(tab)
	mainContent.Visible = (tab == "main")
	visualContent.Visible = (tab == "visual")
	songsContent.Visible = (tab == "songs")
	keybindsContent.Visible = (tab == "keybinds")
	
	tabMain.TextColor3 = tab == "main" and RED or Color3.fromRGB(100,0,0)
	tabVisual.TextColor3 = tab == "visual" and RED or Color3.fromRGB(100,0,0)
	tabSongs.TextColor3 = tab == "songs" and RED or Color3.fromRGB(100,0,0)
	tabKeybinds.TextColor3 = tab == "keybinds" and RED or Color3.fromRGB(100,0,0)
end

tabMain.MouseButton1Click:Connect(function() switchTab("main") end)
tabVisual.MouseButton1Click:Connect(function() switchTab("visual") end)
tabSongs.MouseButton1Click:Connect(function() switchTab("songs") end)
tabKeybinds.MouseButton1Click:Connect(function() switchTab("keybinds") end)

-- Layout lists
local mainLL = Instance.new("UIListLayout", mainContent)
mainLL.SortOrder = Enum.SortOrder.LayoutOrder
mainLL.Padding = UDim.new(0, 8)
local mainPad = Instance.new("UIPadding", mainContent)
mainPad.PaddingLeft = UDim.new(0, 10)
mainPad.PaddingRight = UDim.new(0, 10)
mainPad.PaddingTop = UDim.new(0, 10)
mainPad.PaddingBottom = UDim.new(0, 10)

local visualLL = Instance.new("UIListLayout", visualContent)
visualLL.SortOrder = Enum.SortOrder.LayoutOrder
visualLL.Padding = UDim.new(0, 8)
local visualPad = Instance.new("UIPadding", visualContent)
visualPad.PaddingLeft = UDim.new(0, 10)
visualPad.PaddingRight = UDim.new(0, 10)
visualPad.PaddingTop = UDim.new(0, 10)
visualPad.PaddingBottom = UDim.new(0, 10)

local songsLL = Instance.new("UIListLayout", songsContent)
songsLL.SortOrder = Enum.SortOrder.LayoutOrder
songsLL.Padding = UDim.new(0, 8)
local songsPad = Instance.new("UIPadding", songsContent)
songsPad.PaddingLeft = UDim.new(0, 10)
songsPad.PaddingRight = UDim.new(0, 10)
songsPad.PaddingTop = UDim.new(0, 10)
songsPad.PaddingBottom = UDim.new(0, 10)

local keybindsLL = Instance.new("UIListLayout", keybindsContent)
keybindsLL.SortOrder = Enum.SortOrder.LayoutOrder
keybindsLL.Padding = UDim.new(0, 8)
local keybindsPad = Instance.new("UIPadding", keybindsContent)
keybindsPad.PaddingLeft = UDim.new(0, 10)
keybindsPad.PaddingRight = UDim.new(0, 10)
keybindsPad.PaddingTop = UDim.new(0, 10)
keybindsPad.PaddingBottom = UDim.new(0, 10)

local lo = 0
local function LO() lo = lo + 1; return lo end

local function mkSect(parent, txt)
	local f = Instance.new("Frame", parent)
	f.Size = UDim2.new(1, 0, 0, 25)
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.LayoutOrder = LO()
	local l = Instance.new("TextLabel", f)
	l.Size = UDim2.new(1, -8, 1, 0)
	l.Position = UDim2.new(0, 8, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = txt:upper()
	l.TextColor3 = RED
	l.Font = Enum.Font.GothamBlack
	l.TextSize = 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextStrokeTransparency = 0.85
end

local function mkRow(parent, h)
	local f = Instance.new("Frame", parent)
	f.Size = UDim2.new(1, 0, 0, h or 35)
	f.BackgroundColor3 = CARD
	f.BorderSizePixel = 0
	f.LayoutOrder = LO()
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", f).Color = Color3.fromRGB(40,0,0)
	return f
end

local function mkLabel(row, txt)
	local l = Instance.new("TextLabel", row)
	l.Size = UDim2.new(0.6, 0, 1, 0)
	l.Position = UDim2.new(0, 12, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = W
	l.Font = Enum.Font.GothamBold
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
end

local function mkPill(row, offset)
	local pill = Instance.new("Frame", row)
	pill.Size = UDim2.new(0, 40, 0, 22)
	pill.Position = UDim2.new(1, -(offset or 48), 0.5, -11)
	pill.BackgroundColor3 = OFF
	pill.BorderSizePixel = 0
	pill.ZIndex = 3
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
	local dot = Instance.new("Frame", pill)
	dot.Size = UDim2.new(0, 14, 0, 14)
	dot.Position = UDim2.new(0, 4, 0.5, -7)
	dot.BackgroundColor3 = Color3.fromRGB(40,0,0)
	dot.BorderSizePixel = 0
	dot.ZIndex = 4
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	return pill, dot
end

local function animPill(pill, dot, on)
	TweenService:Create(pill, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = on and Color3.fromRGB(80,0,0) or OFF}):Play()
	TweenService:Create(dot, TweenInfo.new(0.18, Enum.EasingStyle.Back), {
		Position = on and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
		BackgroundColor3 = on and RED or Color3.fromRGB(40,0,0)
	}):Play()
end

local function mkToggle(parent, txt, cb)
	local row = mkRow(parent, 35)
	mkLabel(row, txt)
	local pill, dot = mkPill(row, 48)
	local on = false
	local function sv(s) on = s; animPill(pill, dot, s) end
	local clk = Instance.new("TextButton", pill)
	clk.Size = UDim2.new(1, 0, 1, 0)
	clk.BackgroundTransparency = 1
	clk.Text = ""
	clk.ZIndex = 5
	clk.Activated:Connect(function() on = not on; sv(on); cb(on) end)
	return sv
end

local function mkInputRow(parent, label, default, onChange)
	local row = mkRow(parent, 38)
	mkLabel(row, label)
	
	local box = Instance.new("TextBox", row)
	box.Size = UDim2.new(0, 80, 0, 28)
	box.Position = UDim2.new(1, -90, 0.5, -14)
	box.BackgroundColor3 = INP
	box.BorderSizePixel = 0
	box.Text = tostring(default)
	box.TextColor3 = W
	box.Font = Enum.Font.GothamBold
	box.TextSize = 13
	box.ClearTextOnFocus = true
	box.PlaceholderText = "0"
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", box).Color = Color3.fromRGB(40,0,0)
	
	box.FocusLost:Connect(function(enterPressed)
		local num = tonumber(box.Text)
		if num ~= nil then
			local finalVal = math.floor(math.clamp(num, 0, 500))
			box.Text = tostring(finalVal)
			if onChange then onChange(finalVal) end
		else
			box.Text = tostring(default)
		end
	end)
	
	return box
end

local function mkStatusRow(parent, label)
	local row = mkRow(parent, 32)
	mkLabel(row, label)
	local val = Instance.new("TextLabel", row)
	val.Size = UDim2.new(0.4, -10, 1, 0)
	val.Position = UDim2.new(0.6, 0, 0, 0)
	val.BackgroundTransparency = 1
	val.Text = "Normal"
	val.TextColor3 = Color3.fromRGB(180,180,180)
	val.Font = Enum.Font.GothamBold
	val.TextSize = 13
	val.TextXAlignment = Enum.TextXAlignment.Right
	return val
end

-- Keybind row builder
local function mkKeybindRow(parent, label, bindingName)
	local row = mkRow(parent, 45)
	mkLabel(row, label)
	
	local keyDisplay = Instance.new("TextButton", row)
	keyDisplay.Size = UDim2.new(0, 100, 0, 28)
	keyDisplay.Position = UDim2.new(1, -110, 0.5, -14)
	keyDisplay.BackgroundColor3 = INP
	keyDisplay.BorderSizePixel = 0
	keyDisplay.Text = tostring(KeybindHandler:GetBinding(bindingName)):gsub("Enum.KeyCode.", "")
	keyDisplay.TextColor3 = W
	keyDisplay.Font = Enum.Font.GothamBold
	keyDisplay.TextSize = 12
	Instance.new("UICorner", keyDisplay).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", keyDisplay).Color = Color3.fromRGB(40,0,0)
	
	local listening = false
	local originalText = ""
	
	keyDisplay.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		originalText = keyDisplay.Text
		keyDisplay.Text = "PRESS KEY..."
		keyDisplay.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
		
		KeybindHandler:StartListening(function(keyCode)
			listening = false
			keyDisplay.Text = tostring(keyCode):gsub("Enum.KeyCode.", "")
			keyDisplay.BackgroundColor3 = INP
			KeybindHandler:SetBinding(bindingName, keyCode)
			-- Update state keys if needed
			if bindingName == "AutoLeft" then State.keyAutoLeft = keyCode
			elseif bindingName == "AutoRight" then State.keyAutoRight = keyCode
			elseif bindingName == "DropBrainrot" then State.keyDropBR = keyCode
			elseif bindingName == "TpDown" then State.keyTpDown = keyCode
			elseif bindingName == "AutoBat" then State.keyAutoBat = keyCode
			elseif bindingName == "InstantReset" then State.keyInstantReset = keyCode
			elseif bindingName == "HideUI" then State.keyHideUI = keyCode
			end
			autoSaveConfig()
		end)
		
		task.delay(5, function()
			if listening then
				listening = false
				keyDisplay.Text = originalText
				keyDisplay.BackgroundColor3 = INP
				KeybindHandler:StopListening()
			end
		end)
	end)
	
	return keyDisplay
end

-- ========== BUILD MAIN TAB ==========
mkSect(mainContent, "Speed")
normalBox = mkInputRow(mainContent, "Normal Speed", State.normalSpeed, function(v) State.normalSpeed = v; autoSaveConfig() end)
carryBox = mkInputRow(mainContent, "Carry Speed", State.carrySpeed, function(v) State.carrySpeed = v; autoSaveConfig() end)
laggerBox = mkInputRow(mainContent, "Lagger Speed", State.laggerSpeed, function(v) State.laggerSpeed = v; autoSaveConfig() end)
modeValLbl = mkStatusRow(mainContent, "Current Mode")
setSpeedToggleUI = mkToggle(mainContent, "Carry Mode", function(on) if on then toggleSpeedType() else toggleSpeedType() end end)
setLaggerToggleUI = mkToggle(mainContent, "Lagger Mode", function(on) if on then toggleLagger() else toggleLagger() end end)

mkSect(mainContent, "Combat")
local autoBatRow = mkRow(mainContent, 35)
mkLabel(autoBatRow, "Auto Bat")
local autoBatPill, autoBatDot = mkPill(autoBatRow, 100)
local autoBatOn = false
local function setAutoBatVisual(on)
	autoBatOn = on
	animPill(autoBatPill, autoBatDot, on)
	State.autoBatToggled = on
	autoSaveConfig()
end
local autoBatClick = Instance.new("TextButton", autoBatPill)
autoBatClick.Size = UDim2.new(1,0,1,0)
autoBatClick.BackgroundTransparency = 1
autoBatClick.Text = ""
autoBatClick.Activated:Connect(function() setAutoBatVisual(not autoBatOn) end)
setAutoBat = setAutoBatVisual

setInstaGrab = mkToggle(mainContent, "Auto Grab", function(on)
	AutoSteal.Enabled = on
	if on then startAutoSteal() else stopAutoSteal() end
	autoSaveConfig()
end)

local grabRow = mkRow(mainContent, 38)
mkLabel(grabRow, "Grab Radius")
local radiusBox = Instance.new("TextBox", grabRow)
radiusBox.Size = UDim2.new(0, 80, 0, 28)
radiusBox.Position = UDim2.new(1, -90, 0.5, -14)
radiusBox.BackgroundColor3 = INP
radiusBox.BorderSizePixel = 0
radiusBox.Text = tostring(AutoSteal.Radius)
radiusBox.TextColor3 = W
radiusBox.Font = Enum.Font.GothamBold
radiusBox.TextSize = 13
radiusBox.ClearTextOnFocus = true
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", radiusBox).Color = Color3.fromRGB(40,0,0)
radiusBox.FocusLost:Connect(function()
	local n = tonumber(radiusBox.Text)
	if n and n >= 5 and n <= 300 then
		AutoSteal.Radius = math.floor(n)
		radiusBox.Text = tostring(AutoSteal.Radius)
		if progressRadLbl then progressRadLbl.Text = "Radius: "..AutoSteal.Radius end
		autoSaveConfig()
	else
		radiusBox.Text = tostring(AutoSteal.Radius)
	end
end)

mkSect(mainContent, "Mechanics")
setInfJump = mkToggle(mainContent, "Infinite Jump", function(on)
	State.infJumpEnabled = on
	autoSaveConfig()
end)

local jumpModeRow = mkRow(mainContent, 38)
mkLabel(jumpModeRow, "Jump Mode")
local manualBtn = Instance.new("TextButton", jumpModeRow)
manualBtn.Size = UDim2.new(0, 65, 0, 26)
manualBtn.Position = UDim2.new(1, -140, 0.5, -13)
manualBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
manualBtn.BorderSizePixel = 0
manualBtn.Text = "Manual"
manualBtn.TextColor3 = W
manualBtn.Font = Enum.Font.GothamBold
manualBtn.TextSize = 11
Instance.new("UICorner", manualBtn).CornerRadius = UDim.new(0, 6)

local holdBtn = Instance.new("TextButton", jumpModeRow)
holdBtn.Size = UDim2.new(0, 65, 0, 26)
holdBtn.Position = UDim2.new(1, -70, 0.5, -13)
holdBtn.BackgroundColor3 = OFF
holdBtn.BorderSizePixel = 0
holdBtn.Text = "Hold"
holdBtn.TextColor3 = Color3.fromRGB(100,0,0)
holdBtn.Font = Enum.Font.GothamBold
holdBtn.TextSize = 11
Instance.new("UICorner", holdBtn).CornerRadius = UDim.new(0, 6)

local function updateJumpModeUI()
	if State.infJumpMode == "manual" then
		manualBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
		manualBtn.TextColor3 = W
		holdBtn.BackgroundColor3 = OFF
		holdBtn.TextColor3 = Color3.fromRGB(100,0,0)
	else
		manualBtn.BackgroundColor3 = OFF
		manualBtn.TextColor3 = Color3.fromRGB(100,0,0)
		holdBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
		holdBtn.TextColor3 = W
	end
end

manualBtn.MouseButton1Click:Connect(function()
	State.infJumpMode = "manual"
	updateJumpModeUI()
	autoSaveConfig()
end)
holdBtn.MouseButton1Click:Connect(function()
	State.infJumpMode = "hold"
	updateJumpModeUI()
	autoSaveConfig()
end)

setAutoTpDown = mkToggle(mainContent, "Auto Tp Down", function(on)
	State.autoTpDownEnabled = on
	autoSaveConfig()
end)

local tpYRow = mkRow(mainContent, 38)
mkLabel(tpYRow, "Y Trigger Height")
local tpYBox = Instance.new("TextBox", tpYRow)
tpYBox.Size = UDim2.new(0, 80, 0, 28)
tpYBox.Position = UDim2.new(1, -90, 0.5, -14)
tpYBox.BackgroundColor3 = INP
tpYBox.BorderSizePixel = 0
tpYBox.Text = tostring(State.autoTpDownY)
tpYBox.TextColor3 = W
tpYBox.Font = Enum.Font.GothamBold
tpYBox.TextSize = 13
tpYBox.ClearTextOnFocus = true
Instance.new("UICorner", tpYBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", tpYBox).Color = Color3.fromRGB(40,0,0)
tpYBox.FocusLost:Connect(function()
	local n = tonumber(tpYBox.Text)
	if n then State.autoTpDownY = n; autoSaveConfig() end
end)

setAntiRag = mkToggle(mainContent, "Anti Ragdoll", function(on)
	State.antiRagdollEnabled = on
	if on then startAntiRagdoll() else stopAntiRagdoll() end
	autoSaveConfig()
end)

setFps = mkToggle(mainContent, "FPS Boost", function(on)
	State.fpsBoostEnabled = on
	if on then pcall(applyFPSBoost) end
	autoSaveConfig()
end)

setMedusaCounter = mkToggle(mainContent, "Medusa Counter", function(on)
	State.medusaCounterEnabled = on
	if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
	autoSaveConfig()
end)

setUnwalkToggle = mkToggle(mainContent, "Unwalk", function(on)
	if on then startUnwalk() else stopUnwalk() end
	autoSaveConfig()
end)

setAnimToggle = mkToggle(mainContent, "Anim Pack", function(on)
	State.animEnabled = on
	if on then startAnimToggle() else stopAnimToggle() end
	autoSaveConfig()
end)

mkSect(mainContent, "Teleport")
setAutoLeft = mkToggle(mainContent, "Auto Left", function(on)
	State.autoLeftEnabled = on
	if on then startAutoLeft() else stopAutoLeft() end
	autoSaveConfig()
end)

setAutoRight = mkToggle(mainContent, "Auto Right", function(on)
	State.autoRightEnabled = on
	if on then startAutoRight() else stopAutoRight() end
	autoSaveConfig()
end)

setMenuDropBR = mkToggle(mainContent, "Drop Brainrot", function(on)
	if on then
		runDropBrainrot()
		task.delay(0.5, function()
			if setMenuDropBR then setMenuDropBR(false) end
		end)
	end
end)

setMenuTpDown = mkToggle(mainContent, "Tp Down", function(on)
	if on then
		tpToGround()
		task.delay(0.5, function()
			if setMenuTpDown then setMenuTpDown(false) end
		end)
	end
end)

-- ========== BUILD VISUAL TAB ==========
mkSect(visualContent, "Performance")
antiLagToggleUI = mkToggle(visualContent, "Anti Lag", function(on)
	if on then enableAntiLag() else disableAntiLag() end
	autoSaveConfig()
end)

stretchRezToggleUI = mkToggle(visualContent, "Stretch Rez", function(on)
	if on then enableStretchRez() else disableStretchRez() end
	autoSaveConfig()
end)

removeAccToggleUI = mkToggle(visualContent, "Remove Accessories", function(on)
	if on then enableRemoveAccessories() else disableRemoveAccessories() end
	autoSaveConfig()
end)

mkSect(visualContent, "Camera")
fovToggleUI = mkToggle(visualContent, "FOV (120 FOV)", function(on)
	fovOn = on
	workspace.CurrentCamera.FieldOfView = on and 120 or 70
	autoSaveConfig()
end)

mkSect(visualContent, "Environment")
galaxyToggleUI = mkToggle(visualContent, "Galaxy Skybox", function(on)
	galaxyOn = on
	updateGalaxy()
	autoSaveConfig()
end)

mkSect(visualContent, "Combat")
antiBatToggleUI = mkToggle(visualContent, "Anti Bat (Spin)", function(on)
	antiBatOn = on
	autoSaveConfig()
end)

antiFlingToggleUI = mkToggle(visualContent, "Anti Fling", function(on)
	antiFlingOn = on
	autoSaveConfig()
end)

-- ========== BUILD SONGS TAB ==========
mkSect(songsContent, "Music Player")

local songToggleRefs = {}

for _, songData in ipairs(Songs.SongList) do
	local songName = songData[1]
	local songId = songData[2]
	local isActive = Songs.ToggleStates[songName] or false
	
	local Row = mkRow(songsContent, 45)
	
	local SongLabel = Instance.new("TextLabel", Row)
	SongLabel.Size = UDim2.new(0.55, 0, 1, 0)
	SongLabel.Position = UDim2.new(0.05, 0, 0, 0)
	SongLabel.BackgroundTransparency = 1
	SongLabel.Text = songName
	SongLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	SongLabel.TextSize = 14
	SongLabel.Font = Enum.Font.GothamBold
	SongLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	local StatusLabel = Instance.new("TextLabel", Row)
	StatusLabel.Size = UDim2.new(0, 45, 0, 1)
	StatusLabel.Position = UDim2.new(0.68, 0, 0, 0)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Text = isActive and "ON" or "OFF"
	StatusLabel.TextColor3 = isActive and Color3.fromRGB(255,0,0) or Color3.fromRGB(100,0,0)
	StatusLabel.TextSize = 12
	StatusLabel.Font = Enum.Font.GothamBold
	
	local ToggleBg = Instance.new("Frame", Row)
	ToggleBg.Size = UDim2.new(0, 50, 0, 24)
	ToggleBg.Position = UDim2.new(0.9, -50, 0.5, -12)
	ToggleBg.BackgroundColor3 = isActive and Color3.fromRGB(255,0,0) or Color3.fromRGB(20,0,0)
	Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
	
	local Circle = Instance.new("Frame", ToggleBg)
	Circle.Size = UDim2.new(0, 19, 0, 19)
	Circle.Position = isActive and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0)
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
	
	local ClickBtn = Instance.new("TextButton", Row)
	ClickBtn.Size = UDim2.new(1, 0, 1, 0)
	ClickBtn.BackgroundTransparency = 1
	ClickBtn.Text = ""
	
	songToggleRefs[songName] = {ToggleBg = ToggleBg, Circle = Circle, StatusLabel = StatusLabel, isActive = isActive}
	
	ClickBtn.MouseButton1Click:Connect(function()
		local newState = not Songs.ToggleStates[songName]
		
		if newState then
			for name, ref in pairs(songToggleRefs) do
				if name ~= songName and ref.isActive then
					ref.isActive = false
					Songs.ToggleStates[name] = false
					TweenService:Create(ref.ToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20,0,0)}):Play()
					TweenService:Create(ref.Circle, TweenInfo.new(0.15), {Position = UDim2.new(0.1, 0, 0.1, 0)}):Play()
					ref.StatusLabel.Text = "OFF"
					ref.StatusLabel.TextColor3 = Color3.fromRGB(100,0,0)
				end
			end
			Songs.ToggleStates[songName] = true
			songToggleRefs[songName].isActive = true
			playSong(songId)
		else
			Songs.ToggleStates[songName] = false
			songToggleRefs[songName].isActive = false
			if Songs.ActiveSongId == songId then
				stopSong()
			end
		end
		
		TweenService:Create(ToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = newState and Color3.fromRGB(255,0,0) or Color3.fromRGB(20,0,0)}):Play()
		TweenService:Create(Circle, TweenInfo.new(0.15), {Position = newState and UDim2.new(0.55, 0, 0.1, 0) or UDim2.new(0.1, 0, 0.1, 0)}):Play()
		StatusLabel.Text = newState and "ON" or "OFF"
		StatusLabel.TextColor3 = newState and Color3.fromRGB(255,0,0) or Color3.fromRGB(100,0,0)
		saveSongConfig()
	end)
end

-- ========== BUILD KEYBINDS TAB ==========
mkSect(keybindsContent, "Keybindings (Click to change)")

mkKeybindRow(keybindsContent, "Auto Left", "AutoLeft")
mkKeybindRow(keybindsContent, "Auto Right", "AutoRight")
mkKeybindRow(keybindsContent, "Drop Brainrot", "DropBrainrot")
mkKeybindRow(keybindsContent, "Teleport Down", "TpDown")
mkKeybindRow(keybindsContent, "Auto Bat", "AutoBat")
mkKeybindRow(keybindsContent, "Instant Reset", "InstantReset")
mkKeybindRow(keybindsContent, "Hide UI", "HideUI")

mkSect(keybindsContent, "Info")
local infoRow = mkRow(keybindsContent, 40)
local infoLabel = Instance.new("TextLabel", infoRow)
infoLabel.Size = UDim2.new(1, -24, 1, 0)
infoLabel.Position = UDim2.new(0, 12, 0, 0)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Click any keybind button and press a key to change it"
infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextWrapped = true

-- ========== STEAL PROGRESS BAR ==========
local stealProgressBar = Instance.new("Frame", gui)
stealProgressBar.Size = UDim2.new(0, 280, 0, 60)
stealProgressBar.Position = UDim2.new(0.5, -140, 1, -80)
stealProgressBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
stealProgressBar.BackgroundTransparency = 0
stealProgressBar.BorderSizePixel = 0
stealProgressBar.ZIndex = 100
Instance.new("UICorner", stealProgressBar).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", stealProgressBar).Color = Color3.fromRGB(255, 0, 0)
Instance.new("UIStroke", stealProgressBar).Thickness = 1

local pctLbl = Instance.new("TextLabel", stealProgressBar)
pctLbl.Size = UDim2.new(0.42, 0, 0, 28)
pctLbl.Position = UDim2.new(0, 15, 0, 8)
pctLbl.BackgroundTransparency = 1
pctLbl.Text = "0%"
pctLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
pctLbl.Font = Enum.Font.GothamBlack
pctLbl.TextSize = 22
pctLbl.TextXAlignment = Enum.TextXAlignment.Left
pctLbl.ZIndex = 101

progressRadLbl = Instance.new("TextLabel", stealProgressBar)
progressRadLbl.Size = UDim2.new(0.58, -10, 0, 28)
progressRadLbl.Position = UDim2.new(0.42, 0, 0, 8)
progressRadLbl.BackgroundTransparency = 1
progressRadLbl.Text = "Radius: "..AutoSteal.Radius
progressRadLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
progressRadLbl.Font = Enum.Font.GothamBlack
progressRadLbl.TextSize = 16
progressRadLbl.TextXAlignment = Enum.TextXAlignment.Right
progressRadLbl.ZIndex = 101

local barTrack = Instance.new("Frame", stealProgressBar)
barTrack.Size = UDim2.new(1, -30, 0, 14)
barTrack.Position = UDim2.new(0, 15, 0, 40)
barTrack.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
barTrack.BorderSizePixel = 0
barTrack.ZIndex = 101
Instance.new("UICorner", barTrack).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame", barTrack)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 102
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

AutoSteal.ProgressFill = barFill
AutoSteal.ProgressText = pctLbl

local function makeStealBarDraggable(frame)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local activeDragConn = nil

	local function stopDrag()
		dragging = false
		dragInput = nil
		dragStart = nil
		startPos = nil
		if activeDragConn then activeDragConn:Disconnect(); activeDragConn = nil end
	end

	local function startDragWatch()
		if activeDragConn then activeDragConn:Disconnect() end
		activeDragConn = RunService.Heartbeat:Connect(function()
			if dragging and MobileButtons.Locked then stopDrag() end
		end)
	end

	frame.InputBegan:Connect(function(input)
		if MobileButtons.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			startDragWatch()
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancelled then
					stopDrag()
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if not dragging then return end
		if MobileButtons.Locked then stopDrag(); return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			if MobileButtons.Locked then stopDrag(); return end
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

makeStealBarDraggable(stealProgressBar)

-- ========== LOAD CONFIG ==========
local function loadConfig()
	local hasFile = false
	pcall(function() hasFile = isfile("NomeHubConfig.json") end)
	if not hasFile then return end
	local ok, cfg = pcall(function() return HS:JSONDecode(readfile("NomeHubConfig.json")) end)
	if not ok or not cfg then return end
	
	if cfg.normalSpeed and type(cfg.normalSpeed)=="number" then State.normalSpeed=cfg.normalSpeed; normalBox.Text=tostring(cfg.normalSpeed) end
	if cfg.carrySpeed and type(cfg.carrySpeed)=="number" then State.carrySpeed=cfg.carrySpeed; carryBox.Text=tostring(cfg.carrySpeed) end
	if cfg.laggerSpeed and type(cfg.laggerSpeed)=="number" then State.laggerSpeed=cfg.laggerSpeed; laggerBox.Text=tostring(cfg.laggerSpeed) end
	if cfg.speedType == "normal" or cfg.speedType == "carry" then State.speedType = cfg.speedType; refreshUIToggles() end
	if type(cfg.laggerActive) == "boolean" then State.laggerActive = cfg.laggerActive; if setLaggerToggleUI then setLaggerToggleUI(cfg.laggerActive) end end
	if cfg.grabRadius and type(cfg.grabRadius)=="number" then AutoSteal.Radius=cfg.grabRadius; radiusBox.Text=tostring(cfg.grabRadius); if progressRadLbl then progressRadLbl.Text="Radius: "..cfg.grabRadius end end
	if cfg.autoStealEnabled then AutoSteal.Enabled=true; setInstaGrab(true); pcall(startAutoSteal) end
	if cfg.infJump then State.infJumpEnabled=true; setInfJump(true) end
	if cfg.infJumpMode == "manual" or cfg.infJumpMode == "hold" then State.infJumpMode = cfg.infJumpMode; updateJumpModeUI() end
	if cfg.autoTpDown then State.autoTpDownEnabled=cfg.autoTpDown; setAutoTpDown(cfg.autoTpDown) end
	if cfg.autoTpDownY then State.autoTpDownY=cfg.autoTpDownY; tpYBox.Text=tostring(cfg.autoTpDownY) end
	if cfg.antiRagdoll then State.antiRagdollEnabled=true; setAntiRag(true); startAntiRagdoll() end
	if cfg.fpsBoost then State.fpsBoostEnabled=true; setFps(true); applyFPSBoost() end
	if cfg.medusaCounter then State.medusaCounterEnabled=true; setMedusaCounter(true); setupMedusaCounter(LP.Character) end
	if cfg.animEnabled then State.animEnabled=true; setAnimToggle(true); startAnimToggle() end
	if cfg.unwalkEnabled then setUnwalkToggle(true); task.spawn(function() task.wait(0.5); State.unwalkEnabled=false; startUnwalk() end) end
	if type(cfg.autoBatToggled) == "boolean" then State.autoBatToggled = cfg.autoBatToggled; if setAutoBat then setAutoBat(cfg.autoBatToggled) end end
	if type(cfg.autoLeftEnabled) == "boolean" then State.autoLeftEnabled = cfg.autoLeftEnabled; if setAutoLeft then setAutoLeft(cfg.autoLeftEnabled) end; if cfg.autoLeftEnabled then startAutoLeft() end end
	if type(cfg.autoRightEnabled) == "boolean" then State.autoRightEnabled = cfg.autoRightEnabled; if setAutoRight then setAutoRight(cfg.autoRightEnabled) end; if cfg.autoRightEnabled then startAutoRight() end end
	if cfg.antiLag then enableAntiLag(); if antiLagToggleUI then antiLagToggleUI(true) end end
	if cfg.stretchRez then enableStretchRez(); if stretchRezToggleUI then stretchRezToggleUI(true) end end
	if cfg.removeAccessories then enableRemoveAccessories(); if removeAccToggleUI then removeAccToggleUI(true) end end
	if cfg.fovOn then fovOn = true; workspace.CurrentCamera.FieldOfView = 120; if fovToggleUI then fovToggleUI(true) end end
	if cfg.galaxyOn then galaxyOn = true; updateGalaxy(); if galaxyToggleUI then galaxyToggleUI(true) end end
	if cfg.antiBatOn then antiBatOn = true; if antiBatToggleUI then antiBatToggleUI(true) end end
	if cfg.antiFlingOn then antiFlingOn = true; if antiFlingToggleUI then antiFlingToggleUI(true) end end
	
	-- Load keybindings
	if cfg.keyAutoLeft then State.keyAutoLeft = Enum.KeyCode[cfg.keyAutoLeft] or Enum.KeyCode.Unknown; KeybindHandler:SetBinding("AutoLeft", State.keyAutoLeft) end
	if cfg.keyAutoRight then State.keyAutoRight = Enum.KeyCode[cfg.keyAutoRight] or Enum.KeyCode.Unknown; KeybindHandler:SetBinding("AutoRight", State.keyAutoRight) end
	if cfg.keyDropBR then State.keyDropBR = Enum.KeyCode[cfg.keyDropBR] or Enum.KeyCode.Unknown; KeybindHandler:SetBinding("DropBrainrot", State.keyDropBR) end
	if cfg.keyTpDown then State.keyTpDown = Enum.KeyCode[cfg.keyTpDown] or Enum.KeyCode.Unknown; KeybindHandler:SetBinding("TpDown", State.keyTpDown) end
	if cfg.keyAutoBat then State.keyAutoBat = Enum.KeyCode[cfg.keyAutoBat] or Enum.KeyCode.Unknown; KeybindHandler:SetBinding("AutoBat", State.keyAutoBat) end
	if cfg.keyInstantReset then State.keyInstantReset = Enum.KeyCode[cfg.keyInstantReset] or Enum.KeyCode.T; KeybindHandler:SetBinding("InstantReset", State.keyInstantReset) end
	if cfg.keyHideUI then State.keyHideUI = Enum.KeyCode[cfg.keyHideUI] or Enum.KeyCode.LeftControl; KeybindHandler:SetBinding("HideUI", State.keyHideUI) end
	
	refreshUIToggles()
end

loadSongConfig()

for songName, isActive in pairs(Songs.ToggleStates) do
	if isActive then
		for _, songData in ipairs(Songs.SongList) do
			if songData[1] == songName then
				playSong(songData[2])
				break
			end
		end
		break
	end
end

-- ========== CHARACTER SETUP ==========
local function setupChar(char)
	task.wait(0.1)
	originalAnims = nil
	h = char:WaitForChild("Humanoid", 5)
	hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not h or not hrp then return end
	local head = char:FindFirstChild("Head")
	if head then
		local oldBB = head:FindFirstChild("SpeedBillboard")
		if oldBB then oldBB:Destroy() end
		local bb = Instance.new("BillboardGui", head)
		bb.Name = "SpeedBillboard"
		bb.Size = UDim2.new(0, 120, 0, 22)
		bb.StudsOffset = Vector3.new(0, 3, 0)
		bb.AlwaysOnTop = true
		speedLbl = Instance.new("TextLabel", bb)
		speedLbl.Size = UDim2.new(1, 0, 1, 0)
		speedLbl.BackgroundTransparency = 1
		speedLbl.TextColor3 = Color3.fromRGB(200,200,200)
		speedLbl.Font = Enum.Font.GothamBold
		speedLbl.TextScaled = true
		speedLbl.TextStrokeTransparency = 0
	end
	if State.antiRagdollEnabled and not Conns.antiRag then task.wait(0.5); startAntiRagdoll() end
	if State.medusaCounterEnabled then setupMedusaCounter(char) end
	if State.animEnabled then task.wait(0.3); saveOriginalAnims(char); applyAnimPack(char) end
	if State.unwalkEnabled then State.unwalkEnabled = false; task.wait(0.3); startUnwalk() end
	if removeAccessoriesEnabled then task.wait(0.5); removeAccessoriesFromChar(char) end
end

LP.CharacterAdded:Connect(setupChar)
if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

-- ========== MOVEMENT & COMBAT LOOPS ==========
RunService.Stepped:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP and p.Character then
			for _,part in ipairs(p.Character:GetChildren()) do
				if part:IsA("BasePart") then part.CanCollide=false end
			end
		end
	end
end)

UIS.JumpRequest:Connect(function()
	if not State.infJumpEnabled then return end
	if State.infJumpMode ~= "manual" then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then root.Velocity=Vector3.new(root.Velocity.X,55,root.Velocity.Z) end
end)

RunService.Heartbeat:Connect(function()
	if not State.infJumpEnabled and not State.autoTpDownEnabled then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if State.infJumpEnabled then
		local hum2=char:FindFirstChildOfClass("Humanoid")
		if State.infJumpMode == "hold" then
			local jumpHeld=UIS:IsKeyDown(Enum.KeyCode.Space) or (hum2 and hum2.Jump==true)
			if jumpHeld and root.Velocity.Y < 30 then
				root.Velocity=Vector3.new(root.Velocity.X,55,root.Velocity.Z)
			end
		end
		if root.Velocity.Y<-120 then root.Velocity=Vector3.new(root.Velocity.X,-120,root.Velocity.Z) end
	end
	if State.autoTpDownEnabled then
		local curY = root.Position.Y
		if curY >= State.autoTpDownY then
			local rot = root.CFrame.Rotation
			root.CFrame = CFrame.new(root.Position.X, -8.80, root.Position.Z) * rot
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not (h and hrp) then return end
	if State._tpInProgress then return end

	if State.autoLeftEnabled or State.autoRightEnabled then
		if speedLbl then
			local hs=Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude
			speedLbl.Text="Speed: "..string.format("%.1f",hs)
		end
		return
	end

	local md = h.MoveDirection
	local spd = getCurrentSpeed()

	if md.Magnitude > 0 then
		State.lastMoveDir = md
		hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
	elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude > 0 then
		local anyHeld = false
		for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld = true; break end end
		if anyHeld then
			hrp.Velocity = Vector3.new(State.lastMoveDir.X * spd, hrp.Velocity.Y, State.lastMoveDir.Z * spd)
		end
	end

	if speedLbl then
		local hs = Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude
		speedLbl.Text = "Speed: " .. string.format("%.1f", hs)
	end
end)

RunService.Heartbeat:Connect(function()
	if not (State.autoBatToggled and h and hrp) then return end
	local target,dist=getClosestPlayer()
	if target and target.Character then
		local tr=target.Character:FindFirstChild("HumanoidRootPart")
		if tr then
			local fp=tr.Position+tr.CFrame.LookVector*1.5
			local dir=(fp-hrp.Position).Unit
			hrp.Velocity=Vector3.new(dir.X*56.5,dir.Y*56.5,dir.Z*56.5)
			if dist<=5 then tryHitBat() end
		end
	end
end)

-- ========== SAVE POSITIONS ==========
local function saveStealBarPosition()
	local pos = stealProgressBar.Position
	local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
	pcall(function() writefile("NomeStealBarPos.txt", str) end)
end

local function loadStealBarPosition()
	local savedPos = nil
	pcall(function() savedPos = readfile("NomeStealBarPos.txt") end)
	if savedPos and savedPos ~= "" then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			stealProgressBar.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end
end

local function saveCirclePosition()
	local pos = circleButton.Position
	local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
	pcall(function() writefile("NomeCirclePos.txt", str) end)
end

local function loadCirclePosition()
	local savedPos = nil
	pcall(function() savedPos = readfile("NomeCirclePos.txt") end)
	if savedPos and savedPos ~= "" then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			circleButton.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end
end

local lastCircleSaveTime = 0
circleButton:GetPropertyChangedSignal("Position"):Connect(function()
	if tick() - lastCircleSaveTime > 0.5 then
		lastCircleSaveTime = tick()
		saveCirclePosition()
	end
end)

local lastStealBarSave = 0
stealProgressBar:GetPropertyChangedSignal("Position"):Connect(function()
	if tick() - lastStealBarSave > 0.5 then
		lastStealBarSave = tick()
		saveStealBarPosition()
	end
end)

-- ========== INITIALIZATION ==========
task.spawn(function()
	task.wait(0.5)
	createMobilePanel()
end)

loadCirclePosition()
loadStealBarPosition()
loadConfig()
refreshUIToggles()
updateJumpModeUI()
switchTab("main")

print("🌹 BR DUELS Loaded - Fullscreen Menu + Keyboard Bindings Added!")
print("Press T to instant reset | Press CTRL to toggle UI | Customize all keybinds in the KEYBINDS tab!")
