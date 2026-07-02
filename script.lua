

-- 🌹 BR HUB - Versão Corrigida para Delta Executor
-- Cores: Vermelho, Preto e Branco

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local UI_NAME = "BRHub"
local MOBILE_UI_NAME = "BRHubMobileButtons"

-- Limpar GUIs antigas
pcall(function()
    local old = CoreGui:FindFirstChild(UI_NAME)
    if old then old:Destroy() end
    local oldMobile = CoreGui:FindFirstChild(MOBILE_UI_NAME)
    if oldMobile then oldMobile:Destroy() end
end)

_G.BRHubRunning = true

-- ============================================================
--  CORES - VERMELHO, PRETO E BRANCO
-- ============================================================
local COLORS = {
    BG = Color3.fromRGB(0, 0, 0),
    PANEL = Color3.fromRGB(0, 0, 0),
    CARD = Color3.fromRGB(10, 10, 12),
    RED = Color3.fromRGB(200, 0, 0),
    RED_BRIGHT = Color3.fromRGB(255, 20, 20),
    RED_DARK = Color3.fromRGB(100, 0, 0),
    WHITE = Color3.fromRGB(255, 255, 255),
    GRAY = Color3.fromRGB(180, 180, 180),
    DARK_GRAY = Color3.fromRGB(40, 40, 45),
    STROKE = Color3.fromRGB(60, 0, 0),
}

-- ============================================================
--  VARIÁVEIS GLOBAIS
-- ============================================================
local NS, CS = 60, 30
local LAGGER_SPEED = 15
local LAGGER_CARRY_SPEED = 24.5
local aimbotSpeed = 58
local speedMode = false
local laggerToggled = false
local antiRagdollEnabled = false
local antiDieEnabled = false
local infJumpEnabled = false
local medusaCounterEnabled = false
local batCounterEnabled = false
local unwalkEnabled = false
local autoLeftEnabled = false
local autoRightEnabled = false
local autoBatEnabled = false
local autoSwingEnabled = true
local autoTPEnabled = false
local autoTPHeight = 20
local hitCountdownEnabled = false
local CONFIG = {
    AUTO_STEAL_ENABLED = false,
    HOLD_MIN = 1.3,
    HOLD_MAX = 2.6,
    ENTRY_DELAY = 0.3,
    COOLDOWN = 0.05,
    STEAL_RANGE = 9,
    PRIME_RANGE = 80
}
local uiLocked = false
local showIntroEnabled = true
local uiScaleValue = 1
local mobileButtonScaleValue = 1
local editMobileButtons = false
local hideMobileButtons = false
local mobileButtonPositions = {}
local mainUIScale = nil
local mobileUIScale = nil
local mobileButtonFrames = {}
local MobileButtonActions = {}
local progressFill = nil
local progressPct = nil
local progressRadLbl = nil
local modeValLbl = nil
local speedLabel = nil
local autoLeftSetVisual = nil
local autoRightSetVisual = nil
local autoBatSetVisual = nil
local dropActive = false
local cursedResetRemote = nil
local CURSED_RESET_GUID = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
local medusaDebounce = false
local medusaLastUsed = 0
local MEDUSA_COOLDOWN = 25
local batCounterDebounce = false
local Conns = {antiRag = nil, batCounter = nil, antiDie = {}, anchor = {}}
local antiDieToken = 0
local batMotionAntiDieGuard = false
local _anyKeyListening = false
local mobileButtonsScreen = nil
local mobileButtonContainerRef = nil
local mobileEditBanner = nil
local instaResetPanelOpen = false
local instaResetPanelPosition = nil
local progressBarPosition = nil
local instaResetPanelRef = nil
local setInstaResetPanelVisible = nil
local setLockGuiVisual = nil
local setTopLockVisual = nil
local setEditMobileVisual = nil
local setHideMobileVisual = nil
local setAutoTPVisual = nil
local setStretchRezVisual = nil
local setAntiLagVisual = nil
local setAutoSwingVisual = nil
local setBatCounterVisual = nil
local setMedusaVisual = nil
local setInfJumpVisual = nil
local setAntiRagVisual = nil
local setUnwalkVisual = nil
local setHitCountdownVisual = nil
local setShowIntroVisual = nil
local setShowFpsPingVisual = nil
local setInstaGrab = nil
local normalBox, carryBox, laggerBox, laggerCarryBox, radInput, autoTPHeightBox = nil, nil, nil, nil, nil, nil
local uiSizeSetters = {}
local mobileSizeSetters = {}
local showActionNotification = nil
local refreshMobileButtonUi = nil
local resetMobileButtonLayout = nil
local startAutoSteal = nil
local stopAutoSteal = nil
local startBatCounter = nil
local stopBatCounter = nil
local startAntiDie = nil
local stopAntiDie = nil
local clearAntiDieConns = nil
local refreshBatMotionAntiDieGuard = nil
local startUnwalk = nil
local stopUnwalk = nil
local runDrop = nil
local startAutoTP = nil
local stopAutoTP = nil
local runTPFloor = nil
local enableStretchRez = nil
local disableStretchRez = nil
local enableAntiLag = nil
local disableAntiLag = nil
local setupMedusa = nil
local stopMedusaCounter = nil
local startHitCountdownSystem = nil
local stopHitCountdownSystem = nil
local cursedInstaReset = nil
local startBatAimbot = nil
local stopBatAimbot = nil
local resetAutoBatMotion = nil
local toggleCarryMode = nil
local toggleLaggerMode = nil
local setCarryModeState = nil
local setLaggerModeState = nil
local refreshSpeedModeLabel = nil
local queueAutoLeftStart = nil
local queueAutoRightStart = nil
local stopAutoLeft = nil
local stopAutoRight = nil
local startAutoLeft = nil
local startAutoRight = nil
local startAntiRagdoll = nil
local stopAntiRagdoll = nil

-- ============================================================
--  KEYBINDS
-- ============================================================
KB = {
    DropBrainrot = {kb = Enum.KeyCode.X, gp = nil},
    AutoLeft = {kb = Enum.KeyCode.Z, gp = nil},
    AutoRight = {kb = Enum.KeyCode.C, gp = nil},
    AutoBat = {kb = Enum.KeyCode.E, gp = nil},
    TPFloor = {kb = Enum.KeyCode.F, gp = nil},
    InstaReset = {kb = Enum.KeyCode.T, gp = nil},
    GuiHide = {kb = Enum.KeyCode.LeftControl, gp = nil},
    SpeedToggle = {kb = Enum.KeyCode.Q, gp = nil},
    LaggerToggle = {kb = Enum.KeyCode.R, gp = nil}
}

-- ============================================================
--  FUNÇÕES DE UTILIDADE
-- ============================================================
local function showNotif(text)
    if showActionNotification then
        showActionNotification(text)
    else
        print("[BR HUB] " .. text)
    end
end

local function isRagdollState(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand or st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
end

local function getActiveMoveSpeed()
    if laggerToggled and speedMode then
        return LAGGER_CARRY_SPEED
    elseif laggerToggled then
        return LAGGER_SPEED
    elseif speedMode then
        return CS
    else
        return NS
    end
end

local function getAutoPathSpeed()
    return NS
end

-- ============================================================
--  FUNÇÕES DAS FEATURES
-- ============================================================

-- ANTI RAGDOLL
startAntiRagdoll = function()
    if Conns.antiRag then return end
    Conns.antiRag = RunService.Heartbeat:Connect(function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                pcall(function()
                    local pm = LP.PlayerScripts:FindFirstChild("PlayerModule")
                    if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
                end)
                if root then root.Velocity = Vector3.zero end
            end
        end
    end)
end

stopAntiRagdoll = function()
    if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag = nil end
end

-- ANTI DIE
clearAntiDieConns = function()
    for _, conn in ipairs(Conns.antiDie) do
        pcall(function() conn:Disconnect() end)
    end
    Conns.antiDie = {}
end

stopAntiDie = function()
    if batMotionAntiDieGuard then
        if startAntiDie then startAntiDie() end
        return
    end
    antiDieToken = antiDieToken + 1
    clearAntiDieConns()
end

startAntiDie = function()
    antiDieToken = antiDieToken + 1
    local token = antiDieToken
    clearAntiDieConns()
    local char = LP.Character or LP.CharacterAdded:Wait()
    task.spawn(function()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if token ~= antiDieToken or not hum then return end
        pcall(function() hum.BreakJointsOnDeath = false end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
        table.insert(Conns.antiDie, hum:GetPropertyChangedSignal("Health"):Connect(function()
            if token ~= antiDieToken then return end
            if hum.Health <= 0 then pcall(function() hum.Health = hum.MaxHealth end) end
        end))
        table.insert(Conns.antiDie, hum.Died:Connect(function()
            if token ~= antiDieToken then return end
            task.wait(0.1)
            local newChar = LP.Character
            if newChar then
                local newHum = newChar:FindFirstChildOfClass("Humanoid")
                if newHum and newHum ~= hum then
                    pcall(function() newHum.Health = newHum.MaxHealth end)
                end
            end
        end))
    end)
end

refreshBatMotionAntiDieGuard = function()
    batMotionAntiDieGuard = (autoBatEnabled) and true or false
    if batMotionAntiDieGuard then
        if startAntiDie then startAntiDie() end
    elseif not antiDieEnabled then
        stopAntiDie()
    end
end

-- INFINITE JUMP
local holdJumpPressed = false
local holdJumpActive = false
local function applyInfJumpBoost(boost)
    if not infJumpEnabled then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.new(root.Velocity.X, boost, root.Velocity.Z) end
end

UserInputService.JumpRequest:Connect(function() applyInfJumpBoost(50) end)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space and not UserInputService:GetFocusedTextBox() then
        holdJumpPressed = true
        task.delay(0.12, function()
            if holdJumpPressed then
                holdJumpActive = true
                applyInfJumpBoost(50)
            end
        end)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
        holdJumpPressed = false
        holdJumpActive = false
    end
end)
RunService.Heartbeat:Connect(function()
    if holdJumpActive then applyInfJumpBoost(50) end
end)

-- SPEED INDICATOR
setupSpeedIndicator = function(char, player)
    player = player or LP
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
    if not head then return end
    local old = head:FindFirstChild(player == LP and "BRHubSpeedBB" or "BRHubOtherSpeedBB")
    if old then old:Destroy() end
    local bb = Instance.new("BillboardGui", head)
    bb.Name = player == LP and "BRHubSpeedBB" or "BRHubOtherSpeedBB"
    bb.Size = UDim2.new(0, player == LP and 190 or 90, 0, player == LP and 54 or 30)
    bb.StudsOffset = Vector3.new(0, player == LP and 3.35 or 2.85, 0)
    bb.AlwaysOnTop = true
    
    if player == LP then
        local tag = Instance.new("TextLabel", bb)
        tag.Size = UDim2.new(1, 0, 0, 22)
        tag.Position = UDim2.new(0, 0, 0, 0)
        tag.BackgroundTransparency = 1
        tag.Text = "🌹 BR HUB"
        tag.TextColor3 = COLORS.WHITE
        tag.Font = Enum.Font.GothamBlack
        tag.TextSize = 13
        tag.TextXAlignment = Enum.TextXAlignment.Center
        tag.TextStrokeTransparency = 0.32
        tag.TextStrokeColor3 = COLORS.BG
        local tagGrad = Instance.new("UIGradient", tag)
        tagGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        tagGrad.Rotation = 0
    end
    
    local val = Instance.new("TextLabel", bb)
    val.Size = UDim2.new(1, 0, 0, player == LP and 26 or 30)
    val.Position = UDim2.new(0, 0, 0, player == LP and 24 or 0)
    val.BackgroundTransparency = 1
    val.Text = player == LP and "Speed: 0.0" or "0"
    val.TextColor3 = player == LP and COLORS.WHITE or COLORS.RED
    val.Font = Enum.Font.GothamBlack
    val.TextSize = player == LP and 17 or 22
    val.TextXAlignment = Enum.TextXAlignment.Center
    val.TextStrokeTransparency = 0.35
    val.TextStrokeColor3 = COLORS.BG
    
    if player == LP then
        local valGrad = Instance.new("UIGradient", val)
        valGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        valGrad.Rotation = 0
        speedLabel = val
    end
end

-- AUTO LEFT/RIGHT
local AP_L1, AP_L2 = Vector3.new(-476.47, -6.28, 92.73), Vector3.new(-483.12, -4.95, 94.81)
local AP_R1, AP_R2 = Vector3.new(-476.16, -6.52, 25.62), Vector3.new(-483.06, -5.03, 25.48)
local alConn, arConn = nil, nil
local alPhase, arPhase = 1, 1

stopAutoLeft = function()
    if alConn then alConn:Disconnect(); alConn = nil end
    alPhase = 1
    local char = LP.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h:Move(Vector3.zero, false) end
    end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
end

stopAutoRight = function()
    if arConn then arConn:Disconnect(); arConn = nil end
    arPhase = 1
    local char = LP.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h:Move(Vector3.zero, false) end
    end
    if autoRightSetVisual then autoRightSetVisual(false) end
end

startAutoLeft = function()
    if alConn then alConn:Disconnect() end
    alPhase = 1
    alConn = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero, false); return end
        local spd = getAutoPathSpeed()
        if alPhase == 1 then
            local tgt = Vector3.new(AP_L1.X, hrp.Position.Y, AP_L1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP_L2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
                return
            end
            local d = AP_L1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP_L2.X, hrp.Position.Y, AP_L2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.Velocity = Vector3.zero
                autoLeftEnabled = false
                if alConn then alConn:Disconnect(); alConn = nil end
                alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                return
            end
            local d = AP_L2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
        end
    end)
end

startAutoRight = function()
    if arConn then arConn:Disconnect() end
    arPhase = 1
    arConn = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if isRagdollState(hum) then hum:Move(Vector3.zero, false); return end
        local spd = getAutoPathSpeed()
        if arPhase == 1 then
            local tgt = Vector3.new(AP_R1.X, hrp.Position.Y, AP_R1.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP_R2 - hrp.Position
                local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false)
                hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
                return
            end
            local d = AP_R1 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP_R2.X, hrp.Position.Y, AP_R2.Z)
            if (tgt - hrp.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false)
                hrp.Velocity = Vector3.zero
                autoRightEnabled = false
                if arConn then arConn:Disconnect(); arConn = nil end
                arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                return
            end
            local d = AP_R2 - hrp.Position
            local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false)
            hrp.Velocity = Vector3.new(mv.X * spd, hrp.Velocity.Y, mv.Z * spd)
        end
    end)
end

queueAutoLeftStart = function()
    autoLeftEnabled = true
    if autoRightEnabled then autoRightEnabled = false; if autoRightSetVisual then autoRightSetVisual(false) end; stopAutoRight() end
    if autoBatEnabled then stopBatAimbot(); if autoBatSetVisual then autoBatSetVisual(false) end end
    startAutoLeft()
end

queueAutoRightStart = function()
    autoRightEnabled = true
    if autoLeftEnabled then autoLeftEnabled = false; if autoLeftSetVisual then autoLeftSetVisual(false) end; stopAutoLeft() end
    if autoBatEnabled then stopBatAimbot(); if autoBatSetVisual then autoBatSetVisual(false) end end
    startAutoRight()
end

-- AUTO STEAL
local function initializeAutoStealSync()
    -- Simplified version that just works
    return true
end

local function scanAllPlots()
    -- Placeholder
    return 0
end

startAutoSteal = function()
    if stealConnection then return end
    -- Placeholder
end

stopAutoSteal = function()
    if stealConnection then
        stealConnection:Disconnect()
        stealConnection = nil
    end
end

-- BAT COUNTER
startBatCounter = function()
    if Conns.batCounter then return end
    Conns.batCounter = RunService.Heartbeat:Connect(function()
        if not batCounterEnabled then return end
        if batCounterDebounce then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown then
            batCounterDebounce = true
            task.spawn(function()
                local bat = char:FindFirstChildOfClass("Tool")
                if bat then pcall(function() bat:Activate() end) end
                task.wait(0.3)
                batCounterDebounce = false
            end)
        end
    end)
end

stopBatCounter = function()
    if Conns.batCounter then Conns.batCounter:Disconnect(); Conns.batCounter = nil end
    batCounterDebounce = false
end

-- MEDUSA COUNTER
setupMedusa = function(char)
    -- Simplified
end

stopMedusaCounter = function()
    for _, c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end
    Conns.anchor = {}
end

-- DROP BRAINROT
local _wfConns = {}
runDrop = function()
    if dropActive then return end
    if showActionNotification then showActionNotification("DROP!") end
    dropActive = true
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not root then dropActive = false; return end
    
    pcall(function() root.Anchored = false end)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum.PlatformStand = false end)
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    
    local flingThread = coroutine.create(function()
        while dropActive do
            RunService.Heartbeat:Wait()
            local c = LP.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if not r then break end
            pcall(function() r.Anchored = false end)
            local vel = r.Velocity
            pcall(function() r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0) end)
            RunService.RenderStepped:Wait()
            if r and r.Parent then pcall(function() r.Velocity = vel end) end
            RunService.Stepped:Wait()
            if r and r.Parent then pcall(function() r.Velocity = vel + Vector3.new(0, 0.1, 0) end) end
        end
    end)
    coroutine.resume(flingThread)
    
    task.delay(0.25, function()
        dropActive = false
    end)
end

-- TP DOWN
local _lastTPTime = 0
local function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if hum.Health <= 0 then return end
    
    local now = tick()
    if now - _lastTPTime < 0.08 then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if not (hrp.Position.Y >= autoTPHeight) then return end
    end
    if hrp.Position.Y <= -6.5 and not force then return end
    _lastTPTime = now
    hrp.CFrame = CFrame.new(hrp.Position.X, -7.00, hrp.Position.Z) * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
    hrp.Velocity = Vector3.zero
end

startAutoTP = function()
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
    autoTPConn = task.spawn(function()
        while autoTPEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
    end)
end

stopAutoTP = function()
    autoTPEnabled = false
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
end

runTPFloor = function()
    pcall(function() doAutoTPDown(true) end)
end

-- STRETCH REZ / FPS BOOST
enableStretchRez = function()
    stretchRezEnabled = true
    workspace.CurrentCamera.FieldOfView = 107
    if stretchRezConn then stretchRezConn:Disconnect() end
    stretchRezConn = RunService.RenderStepped:Connect(function()
        if not stretchRezEnabled then stretchRezConn:Disconnect(); stretchRezConn = nil; return end
        workspace.CurrentCamera.FieldOfView = 107
    end)
end

disableStretchRez = function()
    stretchRezEnabled = false
    if stretchRezConn then stretchRezConn:Disconnect(); stretchRezConn = nil end
    workspace.CurrentCamera.FieldOfView = 70
end

-- ANTI LAG
enableAntiLag = function()
    antiLagEnabled = true
    Lighting.GlobalShadows = false
    Lighting.Brightness = 1
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        end)
    end
end

disableAntiLag = function()
    antiLagEnabled = false
end

-- UNWALK
local unwalkSavedAnimate = nil
startUnwalk = function()
    local c = LP.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then unwalkSavedAnimate = anim:Clone(); anim:Destroy() end
end

stopUnwalk = function()
    local c = LP.Character
    if c and unwalkSavedAnimate then unwalkSavedAnimate:Clone().Parent = c; unwalkSavedAnimate = nil end
end

-- HIT COUNTDOWN
startHitCountdownSystem = function()
    -- Simplified
end

stopHitCountdownSystem = function()
    -- Simplified
end

-- CURSED INSTA RESET
cursedInstaReset = function()
    if showActionNotification then showActionNotification("RESET!") end
    if not cursedResetRemote then
        for _, desc in ipairs(game:GetDescendants()) do
            if desc:IsA("RemoteEvent") and desc.Name:sub(1, 3) == "RE/" then
                cursedResetRemote = desc
                break
            end
        end
    end
    if not cursedResetRemote then return end
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon") end)
        return
    end
    for _ = 1, 20 do
        pcall(function() cursedResetRemote:FireServer(CURSED_RESET_GUID, LP, "balloon") end)
        task.wait()
    end
end

-- BAT AIMBOT
local _aimbotTarget = nil
local _aimbotTargetPlr = nil

resetAutoBatMotion = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.Velocity = hrp.Velocity * 0.3
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if hum then hum.AutoRotate = true end
end

local function findBat()
    local char = LP.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end

local function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local closest, closestPlr, minDist = nil, nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then minDist = dist; closest = tRoot; closestPlr = plr end
            end
        end
    end
    return closest, closestPlr, minDist
end

local function getStickyTarget(currentRoot)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local newClosest, newPlr, newDist = getClosestTarget()
    if not newClosest then return nil, nil end
    if currentRoot and currentRoot.Parent then
        local currentPlr = Players:GetPlayerFromCharacter(currentRoot.Parent)
        local hum = currentRoot.Parent:FindFirstChildOfClass("Humanoid")
        if currentPlr and hum and hum.Health > 0 then
            local currentDist = (currentRoot.Position - root.Position).Magnitude
            if currentPlr == newPlr or newDist > currentDist * 0.7 then
                return currentRoot, currentPlr
            end
        end
    end
    return newClosest, newPlr
end

local function swingCurrentBat(char)
    if not autoSwingEnabled then return end
    local bat = findBat()
    if bat and bat.Parent == char and bat:IsA("Tool") then
        pcall(function() bat:Activate() end)
    end
end

local aimbotConn = nil

startBatAimbot = function()
    if aimbotConn then aimbotConn:Disconnect() end
    if autoLeftEnabled then autoLeftEnabled = false; if autoLeftSetVisual then autoLeftSetVisual(false) end; stopAutoLeft() end
    if autoRightEnabled then autoRightEnabled = false; if autoRightSetVisual then autoRightSetVisual(false) end; stopAutoRight() end
    
    autoBatEnabled = true
    if refreshBatMotionAntiDieGuard then refreshBatMotionAntiDieGuard() end
    
    local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum0 then hum0.AutoRotate = false end
    
    aimbotConn = RunService.RenderStepped:Connect(function()
        if not autoBatEnabled then return end
        local char = LP.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        
        if not char:FindFirstChildOfClass("Tool") then
            local bat = findBat()
            if bat then pcall(function() hum:EquipTool(bat) end) end
        end
        
        local target, targetPlr = getStickyTarget(_aimbotTarget)
        if not target then
            _aimbotTarget = nil
            _aimbotTargetPlr = nil
            swingCurrentBat(char)
            return
        end
        _aimbotTarget = target
        _aimbotTargetPlr = targetPlr
        
        local targetVel = target.Velocity
        local myPos = root.Position
        local targetPos = target.Position
        local distance = (targetPos - myPos).Magnitude
        
        local leadTime = 0.14
        local predictPos = targetPos + targetVel * leadTime
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0.01 then flatDir = flatDir.Unit else flatDir = Vector3.new(0, 0, 0) end
        
        local chaseSpeed = aimbotSpeed
        
        local jumpOffset = math.max(0, targetVel.Y * 0.18)
        local desiredHeight = targetPos.Y + 3.7 + jumpOffset
        local yVel = (desiredHeight - myPos.Y) * 22 + targetVel.Y * 1.1
        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 135)
        
        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        root.Velocity = root.Velocity:Lerp(desiredVel, 0.85)
        
        local toPredict = targetPos - myPos
        if toPredict.Magnitude > 0.1 then
            local goalCF = CFrame.lookAt(myPos, targetPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 50, ry * 50, rz * 50))
        end
        
        swingCurrentBat(char)
    end)
end

stopBatAimbot = function()
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
    _aimbotTarget = nil
    _aimbotTargetPlr = nil
    autoBatEnabled = false
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.Velocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
    if resetAutoBatMotion then resetAutoBatMotion() end
    if refreshBatMotionAntiDieGuard then refreshBatMotionAntiDieGuard() end
end

-- SPEED MODE TOGGLES
toggleCarryMode = function()
    speedMode = not speedMode
    refreshSpeedModeLabel()
end

toggleLaggerMode = function()
    laggerToggled = not laggerToggled
    refreshSpeedModeLabel()
end

setCarryModeState = function(on)
    if speedMode ~= on then toggleCarryMode() end
end

setLaggerModeState = function(on)
    if laggerToggled ~= on then toggleLaggerMode() end
end

refreshSpeedModeLabel = function()
    if modeValLbl then
        if laggerToggled and speedMode then
            modeValLbl.Text = "Lagger Carry"
        elseif laggerToggled then
            modeValLbl.Text = "Lagger"
        elseif speedMode then
            modeValLbl.Text = "Carry"
        else
            modeValLbl.Text = "Normal"
        end
    end
end

-- ============================================================
--  SPEED LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    if isRagdollState(hum) then return end
    
    local spd = getActiveMoveSpeed()
    if hum.WalkSpeed ~= spd then hum.WalkSpeed = spd end
    
    if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then
        local md = hum.MoveDirection
        if md.Magnitude > 0 then
            hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
        end
    end
    
    if speedLabel then
        local actualSpeed = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z).Magnitude
        if actualSpeed < 0.05 then actualSpeed = 0 end
        speedLabel.Text = string.format("Speed: %.1f", actualSpeed)
    end
end)

-- ============================================================
--  SPEED INDICATOR SETUP
-- ============================================================
LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setupSpeedIndicator(char)
end)

if LP.Character then setupSpeedIndicator(LP.Character) end

-- ============================================================
--  NOTIFICATION SYSTEM
-- ============================================================
do
    local actionNotifGui = nil
    showActionNotification = function(text)
        if not actionNotifGui or not actionNotifGui.Parent then
            actionNotifGui = Instance.new("ScreenGui")
            actionNotifGui.Name = "BRActionNotif"
            actionNotifGui.ResetOnSpawn = false
            actionNotifGui.DisplayOrder = 55
            actionNotifGui.IgnoreGuiInset = true
            pcall(function()
                if syn and syn.protect_gui then syn.protect_gui(actionNotifGui) end
            end)
            if not pcall(function() actionNotifGui.Parent = CoreGui end) then
                actionNotifGui.Parent = LP:WaitForChild("PlayerGui")
            end
        end
        actionNotifGui:ClearAllChildren()
        
        local label = Instance.new("TextLabel", actionNotifGui)
        label.Size = UDim2.new(0, 320, 0, 80)
        label.Position = UDim2.new(0.5, -160, 0.2, -40)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = COLORS.WHITE
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 60
        label.TextStrokeColor3 = COLORS.BG
        label.TextStrokeTransparency = 0.25
        label.TextTransparency = 1
        label.ZIndex = 55
        
        local grad = Instance.new("UIGradient", label)
        grad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        grad.Rotation = 0
        
        label.TextSize = 30
        TweenService:Create(label, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextSize = 64,
            TextTransparency = 0
        }):Play()
        
        task.delay(0.45, function()
            if not label or not label.Parent then return end
            TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                TextTransparency = 1,
                TextSize = 50
            }):Play()
            task.delay(0.32, function()
                if label and label.Parent then label:Destroy() end
            end)
        end)
    end
end

-- ============================================================
--  GUI BUILDER
-- ============================================================
local function buildGui()
    local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local GUI_W, GUI_H = IsMobile and 248 or 360, IsMobile and 360 or 462
    local HDR_H = IsMobile and 52 or 58
    local LOGO = IsMobile and 30 or 34
    local PAD = IsMobile and 8 or 10
    local PAGE_TOP = HDR_H + (IsMobile and 10 or 12)
    local PAGE_BOTTOM = PAGE_TOP + (IsMobile and 8 or 10)
    local ROW_H = IsMobile and 28 or 31
    local SECTION_H = IsMobile and 16 or 18
    
    -- GUI principal
    local gui = Instance.new("ScreenGui")
    gui.Name = UI_NAME
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 10
    gui.IgnoreGuiInset = true
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(gui) end
    end)
    if not pcall(function() gui.Parent = CoreGui end) then
        gui.Parent = LP:WaitForChild("PlayerGui")
    end
    
    -- Drag function
    local function drag(f, onDragState)
        local dn, ds, sp, di = false
        local moved = false
        local threshold = 6
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if uiLocked then return end
                dn = true; ds = i.Position; sp = f.Position
                moved = false
                if onDragState then onDragState(false, false) end
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then
                        dn = false
                        if onDragState then onDragState(false, moved) end
                    end
                end)
            end
        end)
        f.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                di = i
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i == di and dn and not uiLocked then
                local dx, dy = i.Position.X - ds.X, i.Position.Y - ds.Y
                if (math.abs(dx) > threshold or math.abs(dy) > threshold) and not moved then
                    moved = true
                    if onDragState then onDragState(true, true) end
                end
                f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + dx, sp.Y.Scale, sp.Y.Offset + dy)
            end
        end)
    end
    
    -- Main Frame
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
    main.Position = UDim2.new(0, 20, 0, 20)
    main.BackgroundColor3 = COLORS.BG
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    mainUIScale = Instance.new("UIScale", main)
    mainUIScale.Scale = (IsMobile and 0.75 or 1) * uiScaleValue
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
    
    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = COLORS.RED
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.2
    local mainStrokeGrad = Instance.new("UIGradient", mainStroke)
    mainStrokeGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    mainStrokeGrad.Rotation = 45
    
    drag(main, function(active, moved)
        if not active and moved then
            _G._BRMainPanelPos = {xs = main.Position.X.Scale, x = main.Position.X.Offset, ys = main.Position.Y.Scale, y = main.Position.Y.Offset}
            pcall(saveConfig)
        end
    end)
    
    -- Header
    local hdr = Instance.new("Frame", main)
    hdr.Size = UDim2.new(1, 0, 0, HDR_H)
    hdr.BackgroundColor3 = COLORS.BG
    hdr.BorderSizePixel = 0
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 16)
    
    -- Logo (Rose)
    local logo = Instance.new("TextLabel", hdr)
    logo.Size = UDim2.new(0, LOGO, 0, LOGO)
    logo.Position = UDim2.new(0, 12, 0, IsMobile and 11 or 12)
    logo.BackgroundTransparency = 1
    logo.Text = "🌹"
    logo.TextColor3 = COLORS.RED
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = LOGO
    logo.TextXAlignment = Enum.TextXAlignment.Center
    logo.TextYAlignment = Enum.TextYAlignment.Center
    
    -- Title
    local ttl = Instance.new("TextLabel", hdr)
    ttl.Size = UDim2.new(1, -(IsMobile and 84 or 98), 0, IsMobile and 19 or 22)
    ttl.Position = UDim2.new(0, IsMobile and 50 or 56, 0, IsMobile and 10 or 11)
    ttl.BackgroundTransparency = 1
    ttl.Text = "🌹 BR HUB"
    ttl.TextColor3 = COLORS.WHITE
    ttl.Font = Enum.Font.GothamBlack
    ttl.TextSize = IsMobile and 14 or 17
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    local ttlGrad = Instance.new("UIGradient", ttl)
    ttlGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    ttlGrad.Rotation = 0
    
    -- Subtitle
    local sub = Instance.new("TextLabel", hdr)
    sub.Size = UDim2.new(1, -(IsMobile and 84 or 98), 0, 15)
    sub.Position = UDim2.new(0, IsMobile and 50 or 56, 0, IsMobile and 29 or 34)
    sub.BackgroundTransparency = 1
    sub.Text = "discord.gg/brhub"
    sub.TextColor3 = COLORS.GRAY
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = IsMobile and 9 or 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local closeBtn = Instance.new("TextButton", hdr)
    closeBtn.Size = UDim2.new(0, IsMobile and 23 or 26, 0, IsMobile and 23 or 26)
    closeBtn.Position = UDim2.new(1, IsMobile and -32 or -38, 0, IsMobile and 11 or 14)
    closeBtn.BackgroundColor3 = COLORS.CARD
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "−"
    closeBtn.TextColor3 = COLORS.RED
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = IsMobile and 17 or 20
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    -- Lock Button
    local lockBtn = Instance.new("TextButton", hdr)
    lockBtn.Size = UDim2.new(0, IsMobile and 34 or 42, 0, IsMobile and 23 or 26)
    lockBtn.Position = UDim2.new(1, IsMobile and -70 or -88, 0, IsMobile and 11 or 14)
    lockBtn.BackgroundColor3 = COLORS.WHITE
    lockBtn.BorderSizePixel = 0
    lockBtn.Text = uiLocked and "🔒" or "🔓"
    lockBtn.TextColor3 = COLORS.BG
    lockBtn.Font = Enum.Font.GothamBlack
    lockBtn.TextSize = IsMobile and 13 or 15
    lockBtn.AutoButtonColor = false
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
    
    local lockBtnGrad = Instance.new("UIGradient", lockBtn)
    lockBtnGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    lockBtnGrad.Rotation = 90
    
    local lockStroke = Instance.new("UIStroke", lockBtn)
    lockStroke.Color = COLORS.RED
    lockStroke.Thickness = 1
    lockStroke.Transparency = 0.34
    
    local function setGuiLock(on, skipSave)
        uiLocked = on and true or false
        if setTopLockVisual then setTopLockVisual(uiLocked) end
        if setLockGuiVisual then setLockGuiVisual(uiLocked) end
        if not skipSave then saveConfig() end
    end
    
    setTopLockVisual = function(on)
        lockBtn.Text = on and "🔒" or "🔓"
        lockStroke.Transparency = on and 0.02 or 0.34
        lockStroke.Thickness = on and 2 or 1
    end
    
    lockBtn.Activated:Connect(function() setGuiLock(not uiLocked) end)
    
    -- Divider
    local divider = Instance.new("Frame", hdr)
    divider.Size = UDim2.new(1, -24, 0, 1)
    divider.Position = UDim2.new(0, 12, 1, -1)
    divider.BackgroundColor3 = COLORS.WHITE
    divider.BorderSizePixel = 0
    divider.BackgroundTransparency = 0.15
    local divGrad = Instance.new("UIGradient", divider)
    divGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    
    -- Mini Button
    local miniBtn = Instance.new("TextButton", gui)
    miniBtn.Size = UDim2.new(0, 116, 0, 32)
    miniBtn.Position = UDim2.new(0, 26, 0, 26)
    miniBtn.BackgroundColor3 = COLORS.PANEL
    miniBtn.BorderSizePixel = 0
    miniBtn.Text = "🌹 BR Hub"
    miniBtn.TextColor3 = COLORS.WHITE
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 12
    miniBtn.ZIndex = 20
    miniBtn.Visible = false
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)
    local miniStroke = Instance.new("UIStroke", miniBtn)
    miniStroke.Color = COLORS.RED
    miniStroke.Thickness = 1
    miniStroke.Transparency = 0.2
    
    local miniDragged = false
    drag(miniBtn, function(active, moved)
        if moved then miniDragged = true end
        if not active and moved then
            task.delay(0.12, function() miniDragged = false end)
        end
    end)
    
    local function showGui()
        main.Visible = true
        miniBtn.Visible = false
        _G._BRMainOpen = true
        pcall(saveConfig)
    end
    
    local function hideGui()
        main.Visible = false
        miniBtn.Visible = true
        if editMobileButtons then
            editMobileButtons = false
            refreshMobileButtonUi()
            if setEditMobileVisual then setEditMobileVisual(false) end
        end
        _G._BRMainOpen = false
        pcall(saveConfig)
    end
    
    showBRGui = showGui
    hideBRGui = hideGui
    isBRGuiVisible = function() return main.Visible end
    
    closeBtn.MouseButton1Click:Connect(hideGui)
    miniBtn.Activated:Connect(function()
        if miniDragged then return end
        showGui()
    end)
    
    -- Progress Bar Frame
    local pbFrame = Instance.new("Frame", gui)
    pbFrame.Size = UDim2.new(0, 302, 0, 40)
    if progressBarPosition then
        pbFrame.Position = UDim2.new(progressBarPosition.xs or 0.5, progressBarPosition.x or -151, progressBarPosition.ys or 1, progressBarPosition.y or -64)
    else
        pbFrame.Position = UDim2.new(0.5, -151, 1, -64)
    end
    pbFrame.BackgroundColor3 = COLORS.BG
    pbFrame.BorderSizePixel = 0
    pbFrame.ClipsDescendants = false
    pbFrame.Active = true
    Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 12)
    local pbs = Instance.new("UIStroke", pbFrame)
    pbs.Color = COLORS.RED
    pbs.Thickness = 1.1
    pbs.Transparency = 0.16
    local pbsGrad = Instance.new("UIGradient", pbs)
    pbsGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    pbsGrad.Rotation = 25
    
    -- Status Label
    progressPct = Instance.new("TextLabel", pbFrame)
    progressPct.Size = UDim2.new(0, 62, 0, 14)
    progressPct.Position = UDim2.new(0, 10, 0, 5)
    progressPct.BackgroundTransparency = 1
    progressPct.Text = "IDLE"
    progressPct.TextColor3 = COLORS.WHITE
    progressPct.Font = Enum.Font.GothamBlack
    progressPct.TextSize = 9
    progressPct.TextXAlignment = Enum.TextXAlignment.Left
    
    -- FPS Label
    local fpsLbl = Instance.new("TextLabel", pbFrame)
    fpsLbl.Size = UDim2.new(0, 52, 0, 14)
    fpsLbl.Position = UDim2.new(0, 82, 0, 5)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS:--"
    fpsLbl.TextColor3 = COLORS.RED
    fpsLbl.Font = Enum.Font.GothamBlack
    fpsLbl.TextSize = 9
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    -- PING Label
    local pingLbl = Instance.new("TextLabel", pbFrame)
    pingLbl.Size = UDim2.new(0, 72, 0, 14)
    pingLbl.Position = UDim2.new(0, 144, 0, 5)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "PING:--"
    pingLbl.TextColor3 = COLORS.WHITE
    pingLbl.Font = Enum.Font.GothamBlack
    pingLbl.TextSize = 9
    pingLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    _G._BRFpsLbl = fpsLbl
    _G._BRPingLbl = pingLbl
    
    -- Radius Label
    local radTag = Instance.new("TextLabel", pbFrame)
    radTag.Size = UDim2.new(0, 30, 0, 14)
    radTag.Position = UDim2.new(0, 226, 0, 5)
    radTag.BackgroundTransparency = 1
    radTag.Text = "RAD"
    radTag.TextColor3 = COLORS.GRAY
    radTag.Font = Enum.Font.GothamBlack
    radTag.TextSize = 9
    radTag.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Radius Value
    progressRadLbl = Instance.new("TextBox", pbFrame)
    progressRadLbl.Size = UDim2.new(0, 42, 0, 18)
    progressRadLbl.Position = UDim2.new(1, -50, 0, 4)
    progressRadLbl.BackgroundColor3 = COLORS.CARD
    progressRadLbl.BorderSizePixel = 0
    progressRadLbl.Text = tostring(CONFIG.STEAL_RANGE)
    progressRadLbl.TextColor3 = COLORS.WHITE
    progressRadLbl.Font = Enum.Font.GothamBlack
    progressRadLbl.TextSize = 11
    progressRadLbl.TextXAlignment = Enum.TextXAlignment.Center
    progressRadLbl.ClearTextOnFocus = false
    progressRadLbl.ZIndex = 3
    Instance.new("UICorner", progressRadLbl).CornerRadius = UDim.new(0, 6)
    local radStroke = Instance.new("UIStroke", progressRadLbl)
    radStroke.Color = COLORS.RED
    radStroke.Thickness = 1
    radStroke.Transparency = 0.35
    
    progressRadLbl.FocusLost:Connect(function()
        local v = tonumber(progressRadLbl.Text)
        if v and v >= 0.5 and v <= 300 then
            CONFIG.STEAL_RANGE = v
            progressRadLbl.Text = tostring(v)
            saveConfig()
        else
            progressRadLbl.Text = tostring(CONFIG.STEAL_RANGE)
        end
    end)
    
    -- Progress Bar
    local pbg = Instance.new("Frame", pbFrame)
    pbg.Size = UDim2.new(1, -20, 0, 6)
    pbg.Position = UDim2.new(0, 10, 1, -11)
    pbg.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    pbg.BorderSizePixel = 0
    Instance.new("UICorner", pbg).CornerRadius = UDim.new(1, 0)
    
    progressFill = Instance.new("Frame", pbg)
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = COLORS.RED
    progressFill.BorderSizePixel = 0
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)
    local fillGrad = Instance.new("UIGradient", progressFill)
    fillGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
    
    -- FPS Counter
    local fpsAccum = 0
    local fpsFrames = 0
    local fpsLast = tick()
    RunService.RenderStepped:Connect(function(dt)
        fpsAccum = fpsAccum + dt
        fpsFrames = fpsFrames + 1
        if tick() - fpsLast >= 0.4 then
            local avg = fpsFrames / fpsAccum
            fpsLbl.Text = string.format("FPS:%d", math.floor(avg + 0.5))
            fpsAccum = 0
            fpsFrames = 0
            fpsLast = tick()
        end
    end)
    
    -- Ping Counter
    task.spawn(function()
        while pbFrame.Parent do
            local ok, ping = pcall(function()
                local stats = game:GetService("Stats")
                return stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok and ping then
                pingLbl.Text = string.format("PING:%dms", math.floor(ping + 0.5))
            else
                local ok2, p2 = pcall(function() return LP:GetNetworkPing() * 1000 end)
                if ok2 and p2 then
                    pingLbl.Text = string.format("PING:%dms", math.floor(p2 + 0.5))
                end
            end
            task.wait(0.6)
        end
    end)
    
    -- Drag Progress Bar
    local pbDragging = false
    local pbDragStart, pbStartPos = nil, nil
    pbFrame.InputBegan:Connect(function(input)
        if uiLocked then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if progressRadLbl:IsFocused() then return end
        pbDragging = true
        pbDragStart = input.Position
        pbStartPos = pbFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                pbDragging = false
                progressBarPosition = {xs = pbFrame.Position.X.Scale, x = pbFrame.Position.X.Offset, ys = pbFrame.Position.Y.Scale, y = pbFrame.Position.Y.Offset}
                saveConfig()
            end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not pbDragging or uiLocked or not pbDragStart or not pbStartPos then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local dx, dy = input.Position.X - pbDragStart.X, input.Position.Y - pbDragStart.Y
        pbFrame.Position = UDim2.new(pbStartPos.X.Scale, pbStartPos.X.Offset + dx, pbStartPos.Y.Scale, pbStartPos.Y.Offset + dy)
    end)
    
    -- Main Scrolling Frame
    local mainPage = Instance.new("ScrollingFrame", main)
    mainPage.Name = "MainPage"
    mainPage.Size = UDim2.new(1, -(PAD * 2), 1, -PAGE_BOTTOM)
    mainPage.Position = UDim2.new(0, PAD, 0, PAGE_TOP)
    mainPage.BackgroundTransparency = 1
    mainPage.BorderSizePixel = 0
    mainPage.ScrollBarThickness = 2
    mainPage.ScrollBarImageColor3 = COLORS.RED
    mainPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    mainPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local pageLayout = Instance.new("UIListLayout", mainPage)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, IsMobile and 5 or 7)
    local pagePad = Instance.new("UIPadding", mainPage)
    pagePad.PaddingLeft = UDim.new(0, 2)
    pagePad.PaddingRight = UDim.new(0, 2)
    pagePad.PaddingTop = UDim.new(0, 1)
    pagePad.PaddingBottom = UDim.new(0, IsMobile and 6 or 8)
    
    -- UI Helpers
    local lo = 0
    local function LO() lo = lo + 1; return lo end
    
    local function mkSect(parent, txt)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, SECTION_H)
        f.BackgroundTransparency = 1
        f.BorderSizePixel = 0
        f.LayoutOrder = LO()
        local bullet = Instance.new("Frame", f)
        bullet.Size = UDim2.new(0, 5, 0, 5)
        bullet.Position = UDim2.new(0, 2, 0.5, -2)
        bullet.BackgroundColor3 = COLORS.RED
        bullet.BorderSizePixel = 0
        Instance.new("UICorner", bullet).CornerRadius = UDim.new(0, 2)
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -18, 1, 0)
        l.Position = UDim2.new(0, 14, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt:upper()
        l.TextColor3 = COLORS.RED
        l.Font = Enum.Font.GothamBlack
        l.TextSize = IsMobile and 8 or 9
        l.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    local function mkRow(parent, h, toggleRow)
        local base = toggleRow and Color3.fromRGB(10, 0, 0) or COLORS.CARD
        local hover = toggleRow and Color3.fromRGB(20, 0, 0) or Color3.fromRGB(12, 12, 12)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, 0, 0, h or ROW_H)
        f.BackgroundColor3 = base
        f.BorderSizePixel = 0
        f.LayoutOrder = LO()
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke", f)
        st.Color = toggleRow and COLORS.RED or COLORS.STROKE
        st.Thickness = 1
        st.Transparency = toggleRow and 0.68 or 0.45
        f.MouseEnter:Connect(function()
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundColor3 = hover}):Play()
            TweenService:Create(st, TweenInfo.new(0.12), {Color = COLORS.RED, Transparency = 0.12}):Play()
        end)
        f.MouseLeave:Connect(function()
            TweenService:Create(f, TweenInfo.new(0.12), {BackgroundColor3 = base}):Play()
            TweenService:Create(st, TweenInfo.new(0.12), {Color = toggleRow and COLORS.RED or COLORS.STROKE, Transparency = toggleRow and 0.68 or 0.45}):Play()
        end)
        return f
    end
    
    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.62, 0, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = COLORS.WHITE
        l.Font = Enum.Font.GothamBold
        l.TextSize = 10
        l.TextXAlignment = Enum.TextXAlignment.Left
        if IsMobile then l.TextSize = 9 end
        return l
    end
    
    local function mkPill(row, offset)
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 40, 0, 20)
        pill.Position = UDim2.new(1, -(offset or 48), 0.5, -10)
        pill.BackgroundColor3 = COLORS.OFF or Color3.fromRGB(20, 0, 0)
        pill.BorderSizePixel = 0
        pill.ZIndex = 3
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local pillStroke = Instance.new("UIStroke", pill)
        pillStroke.Color = Color3.fromRGB(40, 0, 0)
        pillStroke.Thickness = 1
        pillStroke.Transparency = 0.4
        local grad = Instance.new("Frame", pill)
        grad.Size = UDim2.new(1, 0, 1, 0)
        grad.BackgroundColor3 = COLORS.WHITE
        grad.BackgroundTransparency = 1
        grad.BorderSizePixel = 0
        grad.ZIndex = 3
        Instance.new("UICorner", grad).CornerRadius = UDim.new(1, 0)
        local gradFx = Instance.new("UIGradient", grad)
        gradFx.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        gradFx.Rotation = 0
        local dot = Instance.new("Frame", pill)
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0, 3, 0.5, -7)
        dot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        dot.BorderSizePixel = 0
        dot.ZIndex = 5
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return pill, dot, grad, pillStroke
    end
    
    local function animPill(pill, dot, on, grad, pillStroke)
        if grad then
            TweenService:Create(grad, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = on and 0 or 1
            }):Play()
        end
        TweenService:Create(dot, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = on and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(80, 80, 80),
        }):Play()
        if pillStroke then
            TweenService:Create(pillStroke, TweenInfo.new(0.18), {Transparency = on and 0.85 or 0.4}):Play()
        end
    end
    
    local function mkToggle(parent, txt, cb)
        local row = mkRow(parent, ROW_H, true)
        mkLabel(row, txt)
        local pill, dot, grad, pillStroke = mkPill(row, 48)
        local on = false
        local function sv(s)
            on = s
            animPill(pill, dot, s, grad, pillStroke)
        end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 6
        clk.Activated:Connect(function()
            on = not on
            sv(on)
            cb(on)
            pill.Size = UDim2.new(0, 38, 0, 19)
            TweenService:Create(pill, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 40, 0, 20)
            }):Play()
        end)
        return sv
    end
    
    local function mkBox(parent, default, w, xOff, cb)
        local tb = Instance.new("TextBox", parent)
        tb.Size = UDim2.new(0, w or 58, 0, 22)
        tb.Position = UDim2.new(1, -(xOff or 66), 0.5, -11)
        tb.BackgroundColor3 = COLORS.WHITE
        tb.BorderSizePixel = 0
        tb.Text = tostring(default)
        tb.TextColor3 = COLORS.BG
        tb.Font = Enum.Font.GothamBlack
        tb.TextSize = 12
        tb.ClearTextOnFocus = false
        tb.ZIndex = 5
        Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)
        local boxGrad = Instance.new("UIGradient", tb)
        boxGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        boxGrad.Rotation = 0
        local bs = Instance.new("UIStroke", tb)
        bs.Color = COLORS.RED
        bs.Thickness = 1
        bs.Transparency = 0.34
        tb.FocusLost:Connect(function()
            if cb then
                local n = tonumber(tb.Text)
                if n then cb(n) else tb.Text = tostring(default) end
            end
        end)
        return tb
    end
    
    local GAMEPAD_KEYS = {
        [Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
        [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
        [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
        [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
        [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
        [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
        [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
        [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true
    }
    
    local function isGamepadInput(inp)
        return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil
    end
    
    local function isBindableInput(inp)
        if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
        if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
        return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
    end
    
    local function kbMatch(entry, kc)
        return kc and (kc == entry.kb or (entry.gp and kc == entry.gp))
    end
    
    local function mkKB(parent, kbEntry, cb)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 58, 0, 22)
        btn.Position = UDim2.new(1, -66, 0.5, -11)
        btn.BackgroundColor3 = COLORS.WHITE
        btn.BorderSizePixel = 0
        local function getLabel()
            return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None"
        end
        btn.Text = getLabel()
        btn.TextColor3 = COLORS.BG
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12
        btn.ZIndex = 5
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local kbGrad = Instance.new("UIGradient", btn)
        kbGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        kbGrad.Rotation = 0
        local kbStroke = Instance.new("UIStroke", btn)
        kbStroke.Color = COLORS.RED
        kbStroke.Thickness = 1
        kbStroke.Transparency = 0.34
        
        local li = false
        local lc = nil
        local pv = btn.Text
        local listenStart = 0
        
        btn.Activated:Connect(function()
            if li then
                li = false
                _anyKeyListening = false
                if lc then lc:Disconnect(); lc = nil end
                btn.Text = pv
                return
            end
            pv = btn.Text
            li = true
            _anyKeyListening = true
            listenStart = tick()
            btn.Text = "..."
            lc = UserInputService.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then
                    li = false
                    _anyKeyListening = false
                    if lc then lc:Disconnect(); lc = nil end
                    btn.Text = pv
                    return
                end
                local isGp = isGamepadInput(inp)
                if isGp and tick() - listenStart < 0.15 then return end
                if not isBindableInput(inp) then return end
                btn.Text = inp.KeyCode.Name
                pv = inp.KeyCode.Name
                li = false
                _anyKeyListening = false
                if lc then lc:Disconnect(); lc = nil end
                if cb then cb(inp.KeyCode, isGp) end
            end)
        end)
        return btn
    end
    
    local function mkToggleKB(parent, txt, kbEntry, onToggle, onKB)
        local row = mkRow(parent, ROW_H)
        mkLabel(row, txt)
        if kbEntry then
            mkKB(row, kbEntry, function(k, isGp)
                if isGp then kbEntry.gp = k; kbEntry.kb = nil
                else kbEntry.kb = k; kbEntry.gp = nil end
                if onKB then onKB(k, isGp) end
            end)
        end
        local pill, dot, grad, pillStroke = mkPill(row, kbEntry and 116 or 48)
        local on = false
        local function sv(s)
            on = s
            animPill(pill, dot, s, grad, pillStroke)
        end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 6
        clk.Activated:Connect(function()
            if _anyKeyListening then return end
            on = not on
            sv(on)
            if onToggle then onToggle(on) end
        end)
        return sv
    end
    
    -- Apply UI Scale
    local function applyUiScale()
        if mainUIScale then mainUIScale.Scale = (IsMobile and 0.75 or 1) * uiScaleValue end
    end
    
    local function applyMobileButtonScale()
        if mobileUIScale then mobileUIScale.Scale = mobileButtonScaleValue end
        refreshMobileButtonUi()
    end
    
    -- Size Selector
    local SCALE_OPTIONS = {1, 1.25, 1.5, 1.75, 2}
    local function mkSizeSelector(parent, txt, getValue, setValue, setters)
        local row = mkRow(parent, ROW_H)
        local label = mkLabel(row, txt)
        if label then label.Size = UDim2.new(0, IsMobile and 58 or 118, 1, 0) end
        local buttons = {}
        local btnW = IsMobile and 26 or 30
        local step = IsMobile and 30 or 34
        local totalW = (step * 4) + btnW
        for i, v in ipairs(SCALE_OPTIONS) do
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, btnW, 0, 20)
            btn.Position = UDim2.new(1, -totalW + (i - 1) * step, 0.5, -10)
            btn.BackgroundColor3 = COLORS.WHITE
            btn.BorderSizePixel = 0
            btn.Text = tostring(math.floor(v * 100)) .. "%"
            btn.TextColor3 = COLORS.BG
            btn.Font = Enum.Font.GothamBlack
            btn.TextSize = IsMobile and 8 or 9
            btn.AutoButtonColor = false
            btn.ZIndex = 4
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
            local btnGrad = Instance.new("UIGradient", btn)
            btnGrad.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
            btnGrad.Rotation = 0
            local st = Instance.new("UIStroke", btn)
            st.Color = COLORS.RED
            st.Thickness = 1
            st.Transparency = 0.36
            buttons[#buttons + 1] = {btn = btn, stroke = st, gradient = btnGrad, value = v}
            btn.Activated:Connect(function()
                if _anyKeyListening then return end
                setValue(v)
                for _, refresh in ipairs(setters) do refresh() end
                saveConfig()
            end)
        end
        local function refresh()
            for _, item in ipairs(buttons) do
                local active = math.abs(getValue() - item.value) < 0.01
                item.btn.BackgroundTransparency = active and 0 or 0.78
                item.btn.TextColor3 = active and COLORS.BG or Color3.fromRGB(180, 180, 180)
                item.stroke.Transparency = active and 0.04 or 0.36
            end
        end
        table.insert(setters, refresh)
        refresh()
    end
    
    -- ============================================================
    --  UI SECTIONS
    -- ============================================================
    
    mkSect(mainPage, "Speed Values")
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Normal Speed")
        normalBox = mkBox(row, NS, 58, 68, function(v) if v > 0 and v <= 500 then NS = v end; saveConfig() end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Carry Speed")
        carryBox = mkBox(row, CS, 58, 68, function(v) if v > 0 and v <= 500 then CS = v end; saveConfig() end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Lagger Speed")
        laggerBox = mkBox(row, LAGGER_SPEED, 58, 68, function(v) if v > 0 and v <= 500 then LAGGER_SPEED = v end; saveConfig() end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Lagger Carry Speed")
        laggerCarryBox = mkBox(row, LAGGER_CARRY_SPEED, 58, 68, function(v) if v > 0 and v <= 500 then LAGGER_CARRY_SPEED = v end; saveConfig() end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Mode")
        modeValLbl = Instance.new("TextLabel", row)
        modeValLbl.Size = UDim2.new(0, 110, 1, 0)
        modeValLbl.Position = UDim2.new(1, -118, 0, 0)
        modeValLbl.BackgroundTransparency = 1
        modeValLbl.Text = "Normal"
        modeValLbl.TextColor3 = COLORS.RED
        modeValLbl.Font = Enum.Font.GothamBlack
        modeValLbl.TextSize = 11
        modeValLbl.TextXAlignment = Enum.TextXAlignment.Right
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(1, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 2
        clk.Activated:Connect(function()
            if _anyKeyListening then return end
            toggleCarryMode()
            saveConfig()
        end)
    end
    
    mkSect(mainPage, "Speed Keybinds")
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Speed Key")
        mkKB(row, KB.SpeedToggle, function(k, isGp)
            if isGp then KB.SpeedToggle.gp = k; KB.SpeedToggle.kb = nil
            else KB.SpeedToggle.kb = k; KB.SpeedToggle.gp = nil end
            saveConfig()
        end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Lagger Key")
        mkKB(row, KB.LaggerToggle, function(k, isGp)
            if isGp then KB.LaggerToggle.gp = k; KB.LaggerToggle.kb = nil
            else KB.LaggerToggle.kb = k; KB.LaggerToggle.gp = nil end
            saveConfig()
        end)
    end
    
    mkSect(mainPage, "Bat Aimbot")
    setAutoSwingVisual = mkToggle(mainPage, "Auto Swing", function(on)
        autoSwingEnabled = on
        saveConfig()
    end)
    if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end
    
    setBatCounterVisual = mkToggle(mainPage, "Bat Counter", function(on)
        batCounterEnabled = on
        if on then startBatCounter() else stopBatCounter() end
        saveConfig()
    end)
    
    setMedusaVisual = mkToggle(mainPage, "Medusa Counter", function(on)
        medusaCounterEnabled = on
        if on then setupMedusa(LP.Character) else stopMedusaCounter() end
        saveConfig()
    end)
    
    do
        local abRow = mkRow(mainPage, ROW_H)
        mkLabel(abRow, "Aimbot Key")
        mkKB(abRow, KB.AutoBat, function(k, isGp)
            if isGp then KB.AutoBat.gp = k; KB.AutoBat.kb = nil
            else KB.AutoBat.kb = k; KB.AutoBat.gp = nil end
            saveConfig()
        end)
        autoBatSetVisual = function() end
    end
    
    mkSect(mainPage, "Aimbot Speed")
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Set Aimbot Speed")
        local aimbotBox = mkBox(row, aimbotSpeed, 58, 68, function(v)
            if v and v >= 5 and v <= 500 then
                aimbotSpeed = v
                saveConfig()
                if showActionNotification then showActionNotification("AIMBOT: " .. tostring(v)) end
            end
        end)
        _G._BRAimbotValBox = aimbotBox
    end
    
    mkSect(mainPage, "Insta Grab")
    setInstaGrab = mkToggle(mainPage, "Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on
        if on then
            if not pcall(startAutoSteal) then
                CONFIG.AUTO_STEAL_ENABLED = false
                if setInstaGrab then setInstaGrab(false) end
            end
        else
            stopAutoSteal()
        end
        saveConfig()
    end)
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Steal Radius")
        radInput = mkBox(row, CONFIG.STEAL_RANGE, 58, 68, function(v)
            if v >= 0.5 and v <= 300 then
                CONFIG.STEAL_RANGE = v
                if progressRadLbl then progressRadLbl.Text = string.format("%.2g", CONFIG.STEAL_RANGE) end
            end
            saveConfig()
        end)
    end
    
    mkSect(mainPage, "Movement")
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Auto Left")
        mkKB(row, KB.AutoLeft, function(k, isGp)
            if isGp then KB.AutoLeft.gp = k; KB.AutoLeft.kb = nil
            else KB.AutoLeft.kb = k; KB.AutoLeft.gp = nil end
            saveConfig()
        end)
        autoLeftSetVisual = function() end
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Auto Right")
        mkKB(row, KB.AutoRight, function(k, isGp)
            if isGp then KB.AutoRight.gp = k; KB.AutoRight.kb = nil
            else KB.AutoRight.kb = k; KB.AutoRight.gp = nil end
            saveConfig()
        end)
        autoRightSetVisual = function() end
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Drop Brainrot")
        mkKB(row, KB.DropBrainrot, function(k, isGp)
            if isGp then KB.DropBrainrot.gp = k; KB.DropBrainrot.kb = nil
            else KB.DropBrainrot.kb = k; KB.DropBrainrot.gp = nil end
            saveConfig()
        end)
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(0.58, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 2
        clk.Activated:Connect(function() runDrop() end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "TP Down")
        mkKB(row, KB.TPFloor, function(k, isGp)
            if isGp then KB.TPFloor.gp = k; KB.TPFloor.kb = nil
            else KB.TPFloor.kb = k; KB.TPFloor.gp = nil end
            saveConfig()
        end)
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(0.58, 0, 1, 0)
        clk.BackgroundTransparency = 1
        clk.Text = ""
        clk.ZIndex = 2
        clk.Activated:Connect(function() runTPFloor() end)
    end
    setAutoTPVisual = mkToggle(mainPage, "Auto TP Down", function(on)
        autoTPEnabled = on
        if on then startAutoTP() else stopAutoTP() end
        saveConfig()
    end)
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "TP Height")
        autoTPHeightBox = mkBox(row, autoTPHeight, 64, 74, function(v)
            if v >= 0 and v <= 500 then autoTPHeight = v
            else autoTPHeightBox.Text = tostring(autoTPHeight) end
            saveConfig()
        end)
    end
    setInfJumpVisual = mkToggle(mainPage, "Infinite Jump", function(on)
        infJumpEnabled = on
        saveConfig()
        if showActionNotification then showActionNotification(on and "INF JUMP ON" or "INF JUMP OFF") end
    end)
    setUnwalkVisual = mkToggle(mainPage, "Unwalk", function(on)
        unwalkEnabled = on
        if on then startUnwalk() else stopUnwalk() end
        saveConfig()
        if showActionNotification then showActionNotification(on and "UNWALK ON" or "UNWALK OFF") end
    end)
    setAntiRagVisual = mkToggle(mainPage, "Anti Ragdoll", function(on)
        antiRagdollEnabled = on
        if on then startAntiRagdoll() else stopAntiRagdoll() end
        saveConfig()
        if showActionNotification then showActionNotification(on and "ANTI RAG ON" or "ANTI RAG OFF") end
    end)
    setHitCountdownVisual = mkToggle(mainPage, "Hit Countdown", function(on)
        hitCountdownEnabled = on
        if on then startHitCountdownSystem() else stopHitCountdownSystem() end
        saveConfig()
        if showActionNotification then showActionNotification(on and "HIT TIMER ON" or "HIT TIMER OFF") end
    end)
    
    mkSect(mainPage, "Visuals")
    setStretchRezVisual = mkToggle(mainPage, "FPS Boost", function(on)
        if on then enableStretchRez() else disableStretchRez() end
        saveConfig()
        if showActionNotification then showActionNotification(on and "FPS BOOST ON" or "FPS BOOST OFF") end
    end)
    setAntiLagVisual = mkToggle(mainPage, "Anti Lag", function(on)
        if on then enableAntiLag() else disableAntiLag() end
        saveConfig()
        if showActionNotification then showActionNotification(on and "ANTI LAG ON" or "ANTI LAG OFF") end
    end)
    
    mkSect(mainPage, "Settings")
    setLockGuiVisual = mkToggle(mainPage, "Lock GUI", function(on) setGuiLock(on) end)
    setShowIntroVisual = mkToggle(mainPage, "Skip Intro", function(on)
        showIntroEnabled = not on
        saveConfig()
        if showActionNotification then showActionNotification(on and "INTRO OFF" or "INTRO ON") end
    end)
    setShowFpsPingVisual = mkToggle(mainPage, "Show FPS/Ping", function(on)
        _G._BRShowFpsPing = on
        if _G._BRFpsLbl then _G._BRFpsLbl.Visible = on end
        if _G._BRPingLbl then _G._BRPingLbl.Visible = on end
        saveConfig()
    end)
    setHideMobileVisual = mkToggle(mainPage, "Hide Mobile Buttons", function(on)
        hideMobileButtons = on
        refreshMobileButtonUi()
        saveConfig()
    end)
    setEditMobileVisual = mkToggle(mainPage, "Edit Mobile Buttons", function(on)
        editMobileButtons = on
        refreshMobileButtonUi()
        saveConfig()
        if showActionNotification then showActionNotification(on and "EDIT ON - DRAG BUTTONS" or "EDIT OFF") end
    end)
    mkSizeSelector(mainPage, "Mobile Button Size", function() return mobileButtonScaleValue end, function(v)
        mobileButtonScaleValue = v
        applyMobileButtonScale()
    end, mobileSizeSetters)
    mkSizeSelector(mainPage, "UI Size", function() return uiScaleValue end, function(v)
        uiScaleValue = v
        applyUiScale()
    end, uiSizeSetters)
    
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Reset Mobile Buttons")
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 86, 0, 22)
        btn.Position = UDim2.new(1, -94, 0.5, -11)
        btn.BackgroundColor3 = COLORS.WHITE
        btn.BorderSizePixel = 0
        btn.Text = "RESET"
        btn.TextColor3 = COLORS.BG
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ZIndex = 3
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local bg = Instance.new("UIGradient", btn)
        bg.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        bg.Rotation = 0
        btn.Activated:Connect(function()
            if _anyKeyListening then return end
            resetMobileButtonLayout()
            saveConfig()
        end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Hide UI Key")
        mkKB(row, KB.GuiHide, function(k, isGp)
            if isGp then KB.GuiHide.gp = k; KB.GuiHide.kb = nil
            else KB.GuiHide.kb = k; KB.GuiHide.gp = nil end
            saveConfig()
        end)
    end
    do
        local row = mkRow(mainPage, ROW_H)
        mkLabel(row, "Insta Reset")
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 86, 0, 22)
        btn.Position = UDim2.new(1, -94, 0.5, -11)
        btn.BackgroundColor3 = COLORS.WHITE
        btn.BorderSizePixel = 0
        btn.Text = "OPEN"
        btn.TextColor3 = COLORS.BG
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ZIndex = 3
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local bg = Instance.new("UIGradient", btn)
        bg.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        bg.Rotation = 0
        btn.Activated:Connect(function()
            if _anyKeyListening then return end
            if setInstaResetPanelVisible then setInstaResetPanelVisible(true) end
        end)
    end
    
    if setHideMobileVisual then setHideMobileVisual(hideMobileButtons) end
    if setEditMobileVisual then setEditMobileVisual(editMobileButtons) end
    setGuiLock(uiLocked, true)
    
    -- Keybinds
    UserInputService.InputBegan:Connect(function(input, gpe)
        if _anyKeyListening then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if gpe or UserInputService:GetFocusedTextBox() then return end
        elseif not isGamepadInput(input) then
            return
        end
        if not isBindableInput(input) then return end
        local kc = input.KeyCode
        if kbMatch(KB.LaggerToggle, kc) then
            toggleLaggerMode()
            saveConfig()
        elseif kbMatch(KB.SpeedToggle, kc) then
            toggleCarryMode()
            saveConfig()
        elseif kbMatch(KB.DropBrainrot, kc) then
            runDrop()
        elseif kbMatch(KB.TPFloor, kc) then
            runTPFloor()
        elseif kbMatch(KB.InstaReset, kc) then
            cursedInstaReset()
        elseif kbMatch(KB.AutoLeft, kc) then
            autoLeftEnabled = not autoLeftEnabled
            if autoLeftEnabled then queueAutoLeftStart() else stopAutoLeft() end
            if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
        elseif kbMatch(KB.AutoRight, kc) then
            autoRightEnabled = not autoRightEnabled
            if autoRightEnabled then queueAutoRightStart() else stopAutoRight() end
            if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
        elseif kbMatch(KB.AutoBat, kc) then
            if not autoBatEnabled then
                startBatAimbot()
                if autoBatSetVisual then autoBatSetVisual(true) end
            else
                stopBatAimbot()
                if autoBatSetVisual then autoBatSetVisual(false) end
            end
        elseif kbMatch(KB.GuiHide, kc) then
            if main.Visible then hideGui() else showGui() end
        end
    end)
    
    -- Apply saved position
    if _G._BRMainPanelPos then
        local p = _G._BRMainPanelPos
        main.Position = UDim2.new(p.xs or 0.5, p.x or -180, p.ys or 0.5, p.y or -150)
    end
    
    if _G._BRMainOpen == false then
        task.delay(showIntroEnabled and 4 or 0.1, function()
            if _G._BRMainOpen == false then
                main.Visible = false
                miniBtn.Visible = true
            end
        end)
    end
    
    -- Intro
    if showIntroEnabled then
        local originalMainPos = main.Position
        main.Visible = false
        miniBtn.Visible = false
        
        local intro = Instance.new("Frame", gui)
        intro.Name = "BRHubIntro"
        intro.Size = UDim2.new(1, 0, 1, 0)
        intro.BackgroundColor3 = COLORS.BG
        intro.BackgroundTransparency = 0.3
        intro.BorderSizePixel = 0
        intro.ZIndex = 200
        
        local logo2 = Instance.new("TextLabel", intro)
        logo2.Size = UDim2.new(0, 80, 0, 80)
        logo2.Position = UDim2.new(0.5, -40, 0.5, -140)
        logo2.BackgroundTransparency = 1
        logo2.Text = "🌹"
        logo2.TextColor3 = COLORS.RED
        logo2.Font = Enum.Font.GothamBlack
        logo2.TextSize = 60
        logo2.TextTransparency = 1
        logo2.ZIndex = 201
        
        local title2 = Instance.new("TextLabel", intro)
        title2.Size = UDim2.new(0, 520, 0, 52)
        title2.Position = UDim2.new(0.5, -260, 0.5, -50)
        title2.BackgroundTransparency = 1
        title2.Text = "🌹 BR HUB"
        title2.TextColor3 = COLORS.WHITE
        title2.Font = Enum.Font.GothamBlack
        title2.TextSize = 36
        title2.TextTransparency = 1
        title2.ZIndex = 201
        title2.TextXAlignment = Enum.TextXAlignment.Center
        
        local sub2 = Instance.new("TextLabel", intro)
        sub2.Size = UDim2.new(0, 520, 0, 24)
        sub2.Position = UDim2.new(0.5, -260, 0.5, 8)
        sub2.BackgroundTransparency = 1
        sub2.Text = "CARREGANDO..."
        sub2.TextColor3 = COLORS.RED
        sub2.Font = Enum.Font.GothamBlack
        sub2.TextSize = 16
        sub2.TextTransparency = 1
        sub2.ZIndex = 201
        sub2.TextXAlignment = Enum.TextXAlignment.Center
        
        local loading2 = Instance.new("TextLabel", intro)
        loading2.Size = UDim2.new(0, 520, 0, 18)
        loading2.Position = UDim2.new(0.5, -260, 0.5, 72)
        loading2.BackgroundTransparency = 1
        loading2.Text = "discord.gg/brhub"
        loading2.TextColor3 = COLORS.GRAY
        loading2.Font = Enum.Font.GothamBold
        loading2.TextSize = 11
        loading2.TextTransparency = 1
        loading2.ZIndex = 201
        loading2.TextXAlignment = Enum.TextXAlignment.Center
        
        local barBg2 = Instance.new("Frame", intro)
        barBg2.Size = UDim2.new(0, 210, 0, 3)
        barBg2.Position = UDim2.new(0.5, -105, 0.5, 45)
        barBg2.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
        barBg2.BorderSizePixel = 0
        barBg2.ZIndex = 201
        Instance.new("UICorner", barBg2).CornerRadius = UDim.new(1, 0)
        
        local bar2 = Instance.new("Frame", barBg2)
        bar2.Size = UDim2.new(0, 0, 1, 0)
        bar2.BackgroundColor3 = COLORS.RED
        bar2.BorderSizePixel = 0
        bar2.ZIndex = 202
        Instance.new("UICorner", bar2).CornerRadius = UDim.new(1, 0)
        
        local barGrad2 = Instance.new("UIGradient", bar2)
        barGrad2.Color = ColorSequence.new(COLORS.RED, COLORS.RED_DARK)
        
        TweenService:Create(logo2, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            TextSize = 70
        }):Play()
        
        TweenService:Create(title2, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
        TweenService:Create(sub2, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
        TweenService:Create(loading2, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
        TweenService:Create(bar2, TweenInfo.new(2.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        }):Play()
        
        local skipBtn2 = Instance.new("TextButton", intro)
        skipBtn2.Size = UDim2.new(1, 0, 1, 0)
        skipBtn2.BackgroundTransparency = 1
        skipBtn2.Text = ""
        skipBtn2.AutoButtonColor = false
        skipBtn2.ZIndex = 205
        
        local finished = false
        local function finishIntro()
            if finished then return end
            finished = true
            if not intro.Parent then return end
            
            main.Visible = true
            TweenService:Create(intro, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(0.4, function()
                if intro then intro:Destroy() end
            end)
        end
        
        skipBtn2.Activated:Connect(finishIntro)
        
        local skipConn2
        skipConn2 = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
                finishIntro()
                if skipConn2 then skipConn2:Disconnect(); skipConn2 = nil end
            end
        end)
        
        task.delay(2.5, finishIntro)
    end
end

-- ============================================================
--  MOBILE BUTTONS
-- ============================================================
local function buildMobileButtons()
    local screen = Instance.new("ScreenGui")
    screen.Name = MOBILE_UI_NAME
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 8
    screen.IgnoreGuiInset = true
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(screen) end
    end)
    if not pcall(function() screen.Parent = CoreGui end) then
        screen.Parent = LP:WaitForChild("PlayerGui")
    end
    mobileButtonsScreen = screen
    
    local container = Instance.new("Frame", screen)
    container.Name = "ButtonContainer"
    container.Size = UDim2.new(0, 144, 0, 200)
    container.BackgroundTransparency = 1
    container.AnchorPoint = Vector2.new(1, 0)
    if mobileGroupPosition then
        container.Position = UDim2.new(mobileGroupPosition.xs or 1, mobileGroupPosition.x or -20, mobileGroupPosition.ys or 0.12, mobileGroupPosition.y or 0)
    else
        container.Position = UDim2.new(1, -20, 0.12, 0)
    end
    mobileButtonContainerRef = container
    mobileUIScale = Instance.new("UIScale", container)
    mobileUIScale.Scale = mobileButtonScaleValue
    
    -- EDIT MODE banner
    local editBanner = Instance.new("Frame", container)
    editBanner.Name = "EditBanner"
    editBanner.Size = UDim2.new(1, 0, 0, 26)
    editBanner.Position = UDim2.new(0, 0, 0, -32)
    editBanner.BackgroundColor3 = COLORS.RED
    editBanner.BackgroundTransparency = 0
    editBanner.BorderSizePixel = 0
    editBanner.Visible = false
    editBanner.ZIndex = 10
    Instance.new("UICorner", editBanner).CornerRadius = UDim.new(1, 0)
    local ebLbl = Instance.new("TextLabel", editBanner)
    ebLbl.Size = UDim2.new(1, 0, 1, 0)
    ebLbl.BackgroundTransparency = 1
    ebLbl.Text = "EDIT MODE"
    ebLbl.TextColor3 = COLORS.WHITE
    ebLbl.Font = Enum.Font.GothamBlack
    ebLbl.TextSize = 12
    ebLbl.ZIndex = 11
    mobileEditBanner = editBanner
    
    local pressTimes = {}
    
    local function makeBtn(id, label, col, row, defaultLabel)
        local f = Instance.new("Frame", container)
        f.Name = id
        f.Size = UDim2.new(0, 64, 0, 42)
        local defPos = UDim2.new(0, (col - 1) * 72, 0, (row - 1) * 50)
        local saved = mobileButtonPositions[id]
        if saved then
            f.Position = UDim2.new(saved.xs or 0, saved.x or defPos.X.Offset, saved.ys or 0, saved.y or defPos.Y.Offset)
        else
            f.Position = defPos
        end
        f.BackgroundColor3 = COLORS.CARD
        f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 9)
        
        local gradLayer = Instance.new("Frame", f)
        gradLayer.Name = "GradLayer"
        gradLayer.Size = UDim2.new(1, 0, 1, 0)
        gradLayer.BackgroundColor3 = COLORS.RED
        gradLayer.BackgroundTransparency = 1
        gradLayer.BorderSizePixel = 0
        gradLayer.ZIndex = 1
        Instance.new("UICorner", gradLayer).CornerRadius = UDim.new(0, 9)
        
        local st = Instance.new("UIStroke", f)
        st.Color = COLORS.STROKE
        st.Thickness = 1
        st.Transparency = 0.34
        
        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1, -4, 1, -4)
        lbl.Position = UDim2.new(0, 2, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = defaultLabel or label
        lbl.TextColor3 = COLORS.WHITE
        lbl.Font = Enum.Font.GothamBlack
        lbl.TextSize = 9
        lbl.TextWrapped = true
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.ZIndex = 3
        
        local btn = Instance.new("TextButton", f)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 4
        
        mobileButtonFrames[id] = {
            frame = f,
            defaultPosition = defPos,
            stroke = st,
            label = lbl,
            button = btn,
            gradLayer = gradLayer
        }
        
        local dragging = false
        local startInput, startPosition = nil, nil
        local moved = false
        local activeInput = nil
        local pressStartTime = 0
        local TAP_THRESHOLD = 12
        local QUICK_TAP_TIME = 0.18
        
        btn.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            activeInput = input
            startInput = input.Position
            startPosition = f.Position
            moved = false
            pressStartTime = tick()
            dragging = editMobileButtons and (not uiLocked)
            pressTimes[id] = tick()
            gradLayer.BackgroundTransparency = 0
            TweenService:Create(f, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 58, 0, 38)}):Play()
        end)
        
        btn.InputEnded:Connect(function(input)
            if input ~= activeInput then return end
            activeInput = nil
            TweenService:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 64, 0, 42)}):Play()
            local wasDragging = dragging
            dragging = false
            local pressDuration = tick() - pressStartTime
            local isQuickTap = pressDuration < QUICK_TAP_TIME
            
            if not editMobileButtons and ((not moved) or isQuickTap) then
                if MobileButtonActions[id] then
                    task.spawn(MobileButtonActions[id])
                end
            elseif moved and editMobileButtons then
                mobileButtonPositions[id] = {
                    xs = f.Position.X.Scale,
                    x = f.Position.X.Offset,
                    ys = f.Position.Y.Scale,
                    y = f.Position.Y.Offset
                }
                saveConfig()
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if not activeInput or not startInput or not startPosition then return end
            if activeInput.UserInputType == Enum.UserInputType.Touch then
                if input ~= activeInput then return end
            elseif activeInput.UserInputType == Enum.UserInputType.MouseButton1 then
                if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            else
                return
            end
            local dx, dy = input.Position.X - startInput.X, input.Position.Y - startInput.Y
            if math.abs(dx) > TAP_THRESHOLD or math.abs(dy) > TAP_THRESHOLD then moved = true end
            if dragging and moved and editMobileButtons then
                f.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + dx, startPosition.Y.Scale, startPosition.Y.Offset + dy)
            end
        end)
        return f, lbl
    end
    
    -- 2x4 grid
    makeBtn("AutoLeft", "AUTO LEFT", 1, 1)
    makeBtn("AutoRight", "AUTO RIGHT", 2, 1)
    makeBtn("AutoBat", "AIMBOT", 1, 2)
    makeBtn("CarrySpeed", "CARRY", 2, 2)
    makeBtn("DropBrainrot", "DROP BR", 1, 3)
    makeBtn("TPDown", "TP DOWN", 2, 3)
    makeBtn("LaggerCarry", "LAGGER CARRY", 1, 4)
    makeBtn("LaggerSpeed", "LAGGER", 2, 4)
    
    -- Mobile button actions
    MobileButtonActions.AutoLeft = function()
        autoLeftEnabled = not autoLeftEnabled
        if autoLeftEnabled then queueAutoLeftStart() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
    end
    
    MobileButtonActions.AutoRight = function()
        autoRightEnabled = not autoRightEnabled
        if autoRightEnabled then queueAutoRightStart() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
    end
    
    MobileButtonActions.AutoBat = function()
        if not autoBatEnabled then
            startBatAimbot()
            if autoBatSetVisual then autoBatSetVisual(true) end
        else
            stopBatAimbot()
            if autoBatSetVisual then autoBatSetVisual(false) end
        end
    end
    
    MobileButtonActions.CarrySpeed = function()
        toggleCarryMode()
        saveConfig()
    end
    
    MobileButtonActions.DropBrainrot = function()
        runDrop()
    end
    
    MobileButtonActions.TPDown = function()
        runTPFloor()
    end
    
    MobileButtonActions.LaggerCarry = function()
        if laggerToggled and speedMode then
            toggleLaggerMode()
            toggleCarryMode()
        else
            if not laggerToggled then toggleLaggerMode() end
            if not speedMode then toggleCarryMode() end
        end
        saveConfig()
    end
    
    MobileButtonActions.LaggerSpeed = function()
        toggleLaggerMode()
        saveConfig()
    end
    
    -- Sync active state visual
    RunService.Heartbeat:Connect(function(dt)
        dt = dt or 0.016
        local function setActive(id, active)
            local data = mobileButtonFrames[id]
            if not data then return end
            local pt = pressTimes[id]
            local pressedRecently = pt and (tick() - pt) < 0.4
            local lit = active or pressedRecently
            if lit then
                data.gradLayer.BackgroundTransparency = 0
            else
                local t = data.gradLayer.BackgroundTransparency
                if t < 1 then
                    data.gradLayer.BackgroundTransparency = math.min(1, t + dt * 3)
                end
            end
            local intensity = 1 - data.gradLayer.BackgroundTransparency
            data.label.TextColor3 = COLORS.WHITE:Lerp(COLORS.BG, intensity)
            data.stroke.Transparency = 0.34 - intensity * 0.30
        end
        setActive("AutoLeft", autoLeftEnabled)
        setActive("AutoRight", autoRightEnabled)
        setActive("AutoBat", autoBatEnabled)
        setActive("CarrySpeed", speedMode and not laggerToggled)
        setActive("LaggerCarry", laggerToggled and speedMode)
        setActive("LaggerSpeed", laggerToggled and not speedMode)
        setActive("DropBrainrot", false)
        setActive("TPDown", false)
    end)
    
    refreshMobileButtonUi = function()
        if mobileButtonsScreen then mobileButtonsScreen.Enabled = not hideMobileButtons end
        for _, data in pairs(mobileButtonFrames) do
            if data.stroke then
                data.stroke.Transparency = editMobileButtons and 0 or 0.34
                data.stroke.Thickness = editMobileButtons and 2 or 1
                data.stroke.Color = editMobileButtons and COLORS.WHITE or COLORS.STROKE
            end
        end
        if mobileEditBanner then
            mobileEditBanner.Visible = editMobileButtons
        end
    end
    
    resetMobileButtonLayout = function()
        mobileButtonPositions = {}
        mobileGroupPosition = nil
        for id, data in pairs(mobileButtonFrames) do
            if data.frame and data.defaultPosition then
                data.frame.Position = data.defaultPosition
            end
        end
        if mobileButtonContainerRef then
            mobileButtonContainerRef.Position = UDim2.new(1, -20, 0.12, 0)
        end
        if mobileUIScale then mobileUIScale.Scale = mobileButtonScaleValue end
        for _, refresh in ipairs(mobileSizeSetters) do refresh() end
        refreshMobileButtonUi()
        if showActionNotification then showActionNotification("RESET!") end
    end
    
    refreshMobileButtonUi()
end

-- ============================================================
--  CONFIG SAVE/LOAD
-- ============================================================
local function saveConfig()
    local function ks(e)
        return {kb = e.kb and e.kb.Name or nil, gp = e.gp and e.gp.Name or nil}
    end
    local cfg = {
        normalSpeed = NS,
        carrySpeed = CS,
        dropBrainrotKey = ks(KB.DropBrainrot),
        autoLeftKey = ks(KB.AutoLeft),
        autoRightKey = ks(KB.AutoRight),
        speedToggleKey = ks(KB.SpeedToggle),
        autoBatKey = ks(KB.AutoBat),
        laggerToggleKey = ks(KB.LaggerToggle),
        tpFloorKey = ks(KB.TPFloor),
        instaResetKey = ks(KB.InstaReset),
        guiHideKey = ks(KB.GuiHide),
        autoStealRange = CONFIG.STEAL_RANGE,
        holdMax = CONFIG.HOLD_MAX,
        antiRagdoll = antiRagdollEnabled,
        antiDie = antiDieEnabled,
        autoStealEnabled = CONFIG.AUTO_STEAL_ENABLED,
        hitCountdown = hitCountdownEnabled,
        infiniteJump = infJumpEnabled,
        medusaCounter = medusaCounterEnabled,
        batCounter = batCounterEnabled,
        carryMode = speedMode,
        laggerMode = laggerToggled,
        laggerSpeed = LAGGER_SPEED,
        laggerCarrySpeed = LAGGER_CARRY_SPEED,
        aimbotSpeed = aimbotSpeed,
        autoBat = autoBatEnabled,
        autoSwing = autoSwingEnabled,
        unwalkEnabled = unwalkEnabled,
        antiLag = antiLagEnabled,
        stretchRez = stretchRezEnabled,
        autoTPEnabled = autoTPEnabled,
        autoTPHeight = autoTPHeight,
        showIntro = showIntroEnabled,
        uiLocked = uiLocked,
        uiScale = uiScaleValue,
        mobileButtonScale = mobileButtonScaleValue,
        editMobileButtons = editMobileButtons,
        hideMobileButtons = hideMobileButtons,
        mobileButtonPositions = mobileButtonPositions,
        instaResetPanelOpen = instaResetPanelOpen,
        instaResetPanelPosition = instaResetPanelPosition,
        progressBarPosition = progressBarPosition,
        mainPanelOpen = (_G._BRMainOpen ~= false),
        mainPanelPos = _G._BRMainPanelPos,
        showFpsPing = (_G._BRShowFpsPing ~= false),
    }
    if writefile then
        pcall(function()
            writefile("BRHub.json", HttpService:JSONEncode(cfg))
        end)
    end
end

task.spawn(function()
    while task.wait(5) do
        saveConfig()
    end
end)

local function decodeKey(name)
    if not name then return nil end
    local ok, kc = pcall(function() return Enum.KeyCode[name] end)
    if ok and kc then return kc end
    return nil
end

local function loadConfigKeys()
    if not (readfile and isfile) then return end
    local raw = nil
    pcall(function()
        if isfile("BRHub.json") then raw = readfile("BRHub.json") end
    end)
    if not raw then return end
    local ok, cfg = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(cfg) ~= "table" then return end
    
    if cfg.normalSpeed then NS = cfg.normalSpeed end
    if cfg.carrySpeed then CS = cfg.carrySpeed end
    if cfg.laggerSpeed then LAGGER_SPEED = cfg.laggerSpeed end
    if cfg.laggerCarrySpeed then LAGGER_CARRY_SPEED = cfg.laggerCarrySpeed end
    if cfg.aimbotSpeed then aimbotSpeed = cfg.aimbotSpeed end
    if cfg.autoStealRange then CONFIG.STEAL_RANGE = cfg.autoStealRange end
    if cfg.holdMax then CONFIG.HOLD_MAX = cfg.holdMax end
    if cfg.autoTPHeight then autoTPHeight = cfg.autoTPHeight end
    if cfg.uiScale then uiScaleValue = cfg.uiScale end
    if cfg.mobileButtonScale then mobileButtonScaleValue = cfg.mobileButtonScale end
    if cfg.uiLocked ~= nil then uiLocked = cfg.uiLocked end
    if cfg.editMobileButtons ~= nil then editMobileButtons = cfg.editMobileButtons end
    if cfg.hideMobileButtons ~= nil then hideMobileButtons = cfg.hideMobileButtons end
    if cfg.showIntro ~= nil then showIntroEnabled = cfg.showIntro; if setShowIntroVisual then setShowIntroVisual(not showIntroEnabled) end end
    if type(cfg.mobileButtonPositions) == "table" then mobileButtonPositions = cfg.mobileButtonPositions end
    if cfg.instaResetPanelOpen ~= nil then instaResetPanelOpen = cfg.instaResetPanelOpen end
    if type(cfg.instaResetPanelPosition) == "table" then instaResetPanelPosition = cfg.instaResetPanelPosition end
    if type(cfg.progressBarPosition) == "table" then progressBarPosition = cfg.progressBarPosition end
    if cfg.mainPanelOpen ~= nil then _G._BRMainOpen = cfg.mainPanelOpen end
    if type(cfg.mainPanelPos) == "table" then _G._BRMainPanelPos = cfg.mainPanelPos end
    if cfg.showFpsPing ~= nil then
        _G._BRShowFpsPing = cfg.showFpsPing
        if setShowFpsPingVisual then setShowFpsPingVisual(cfg.showFpsPing) end
        if _G._BRFpsLbl then _G._BRFpsLbl.Visible = cfg.showFpsPing end
        if _G._BRPingLbl then _G._BRPingLbl.Visible = cfg.showFpsPing end
    end
    
    local function applyKey(target, saved)
        if not saved or not target then return end
        local kb = decodeKey(saved.kb)
        local gp = decodeKey(saved.gp)
        target.kb = kb
        target.gp = gp
    end
    applyKey(KB.DropBrainrot, cfg.dropBrainrotKey)
    applyKey(KB.AutoLeft, cfg.autoLeftKey)
    applyKey(KB.AutoRight, cfg.autoRightKey)
    applyKey(KB.SpeedToggle, cfg.speedToggleKey)
    applyKey(KB.AutoBat, cfg.autoBatKey)
    applyKey(KB.LaggerToggle, cfg.laggerToggleKey)
    applyKey(KB.TPFloor, cfg.tpFloorKey)
    applyKey(KB.InstaReset, cfg.instaResetKey)
    applyKey(KB.GuiHide, cfg.guiHideKey)
    
    _G._BRLoadedState = cfg
end

local function loadConfigState()
    local cfg = _G._BRLoadedState
    if type(cfg) ~= "table" then return end
    if cfg.antiRagdoll then antiRagdollEnabled = true; startAntiRagdoll(); if setAntiRagVisual then setAntiRagVisual(true) end end
    if cfg.hitCountdown then hitCountdownEnabled = true; if startHitCountdownSystem then startHitCountdownSystem() end; if setHitCountdownVisual then setHitCountdownVisual(true) end end
    if cfg.antiDie then antiDieEnabled = true; startAntiDie(); if setAntiDieVisual then setAntiDieVisual(true) end end
    if cfg.autoStealEnabled then CONFIG.AUTO_STEAL_ENABLED = true; pcall(startAutoSteal); if setInstaGrab then setInstaGrab(true) end end
    if cfg.infiniteJump then infJumpEnabled = true; if setInfJumpVisual then setInfJumpVisual(true) end end
    if cfg.medusaCounter then medusaCounterEnabled = true; setupMedusa(LP.Character); if setMedusaVisual then setMedusaVisual(true) end end
    if cfg.batCounter then batCounterEnabled = true; startBatCounter(); if setBatCounterVisual then setBatCounterVisual(true) end end
    if cfg.carryMode then setCarryModeState(true) end
    if cfg.laggerMode then setLaggerModeState(true) end
    if cfg.autoTPEnabled then autoTPEnabled = true; startAutoTP(); if setAutoTPVisual then setAutoTPVisual(true) end end
    if cfg.autoBat then startBatAimbot(); if autoBatSetVisual then autoBatSetVisual(true) end end
    if cfg.autoSwing ~= nil then autoSwingEnabled = cfg.autoSwing; if setAutoSwingVisual then setAutoSwingVisual(autoSwingEnabled) end end
    if cfg.unwalkEnabled then unwalkEnabled = true; startUnwalk(); if setUnwalkVisual then setUnwalkVisual(true) end end
    if cfg.antiLag then enableAntiLag(); if setAntiLagVisual then setAntiLagVisual(true) end end
    if cfg.stretchRez then enableStretchRez(); if setStretchRezVisual then setStretchRezVisual(true) end end
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED) end
    if laggerCarryBox then laggerCarryBox.Text = tostring(LAGGER_CARRY_SPEED) end
    if _G._BRAimbotValBox then _G._BRAimbotValBox.Text = tostring(aimbotSpeed) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPHeight) end
    if instaResetPanelOpen and setInstaResetPanelVisible then setInstaResetPanelVisible(true, true) end
    _G._BRLoadedState = nil
end

-- ============================================================
--  INIT
-- ============================================================
loadConfigKeys()
buildMobileButtons()
buildGui()
loadConfigState()

print("🌹 BR HUB CARREGADO COM SUCESSO!")
print("Discord: discord.gg/brhub")
