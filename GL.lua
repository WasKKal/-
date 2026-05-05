local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/WindQW.lua"))()

local lp = game:GetService("Players").LocalPlayer
local ws = game:GetService("Workspace")
local rs = game:GetService("RunService")
local cam = ws.CurrentCamera
local uis = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local tween = game:GetService("TweenService")
local vu = game:GetService("VirtualUser")
local http = game:GetService("HttpService")
local cg = game:GetService("CoreGui")
local reps = game:GetService("ReplicatedStorage")
local ts = game:GetService("TeleportService")
local ss = game:GetService("SoundService")
local Players = game:GetService("Players")

local getgenv = getgenv or function() return _G end

local DrawingLib
if Drawing then
    DrawingLib = Drawing
else
    DrawingLib = { new = function() return { Visible = false, Remove = function() end } end }
end

local TrashGeneral = getgenv().TrashGeneral or {
    SpeedEnabled = false; SpeedValue = 50;
    FlyEnabled = false; FlySpeed = 5;
    HighJumpEnabled = false; JumpPower = 70;
    AntiRagdoll = false;
    AntiAFK = false;
    NightVision = false;
    RemoveShadows = false;
    SelectedTime = "8:00";
    SelectedWeather = "Default";
    InfJump = false;
    NoPromptCD = false;
    Aimbot = {
        Enabled = false;
        ShowFOV = false;
        FOVSize = 150;
        CheckObstacles = true;
        Smooth = false;
        Speed = 300;
        Distance = 1000;
    };
    EnemyVisual = {
        Enabled = false;
        Hitbox = {
            Size = 5;
            Color = Color3.fromRGB(255,0,0);
            Transparency = 0.7;
        };
    };
    SilentAim = {
        Enabled = false;
        TeamCheck = false;
        VisibleCheck = false;
        TargetMode = "所有";
        TargetPart = "HumanoidRootPart";
        Method = "Raycast";
        FOVRadius = 130;
        FOVVisible = true;
        ShowTarget = false;
        MouseHitPrediction = false;
        MouseHitPredictionAmount = 0.165;
        HitChance = 100;
        HeadshotChanceEnabled = false;
        HeadshotChance = 0;
        FixedFOV = true;
        IndicatorStyle = "Circle";
        TargetIndicatorRadius = 20;
        CrosshairLength = 30;
        CrosshairGap = 5;
        IndicatorRotationEnabled = false;
        IndicatorRotationSpeed = 1;
        IndicatorRainbowEnabled = false;
        IndicatorRainbowSpeed = 1;
        MaxDistance = 500;
        PriorityMode = "准星最近";
        TargetInfoStyle = "面板";
        ShowTargetName = true;
        ShowTargetHealth = true;
        ShowTargetDistance = true;
        ShowTargetCategory = false;
        ShowDamageNotifier = false;
        HighlightEnabled = false;
        HighlightRainbow = false;
        HighlightColor = Color3.fromRGB(255,255,0);
        Wallbang = false;
        LeakAndHitMode = false;
        EnableNameTargeting = false;
        WhitelistedNames = {};
        BlacklistedNames = {};
        ShowTracer = false;
        TracerYOffset = 0;
        IndicatorBreathing = true;
        IndicatorBreathingSpeed = 1;
        IndicatorBreathingMin = 0.8;
        IndicatorBreathingMax = 1.2;
        ThreeLineCrosshair = true;
        ThreeLineCrosshairLength = 30;
        ThreeLineCrosshairGap = 5;
    };
    ESP = {
        Enabled = false;
        TeamCheck = true;
        MaxDistance = 200;
        FontSize = 11;
        FadeOut = { OnDistance = true; OnDeath = false; OnLeave = false };
        Options = {
            Teamcheck = false; TeamcheckRGB = Color3.fromRGB(0,255,0);
            Friendcheck = true; FriendcheckRGB = Color3.fromRGB(0,255,0);
            Highlight = false; HighlightRGB = Color3.fromRGB(255,0,0);
        };
        Drawing = {
            Chams = {
                Enabled = true; Thermal = true;
                FillRGB = Color3.fromRGB(119,120,255);
                Fill_Transparency = 100;
                OutlineRGB = Color3.fromRGB(119,120,255);
                Outline_Transparency = 100;
                VisibleCheck = true;
            };
            Names = { Enabled = true; RGB = Color3.fromRGB(255,255,255) };
            Flags = { Enabled = true };
            Distances = { Enabled = true; Position = "Text"; RGB = Color3.fromRGB(255,255,255) };
            Weapons = {
                Enabled = true;
                WeaponTextRGB = Color3.fromRGB(119,120,255);
                Outlined = false;
                Gradient = false;
                GradientRGB1 = Color3.fromRGB(255,255,255);
                GradientRGB2 = Color3.fromRGB(119,120,255);
            };
            Healthbar = {
                Enabled = true;
                HealthText = true;
                Lerp = false;
                HealthTextRGB = Color3.fromRGB(119,120,255);
                Width = 2.5;
                Gradient = true;
                GradientRGB1 = Color3.fromRGB(200,0,0);
                GradientRGB2 = Color3.fromRGB(60,60,125);
                GradientRGB3 = Color3.fromRGB(119,120,255);
            };
            Boxes = {
                Animate = true;
                RotationSpeed = 300;
                Gradient = false;
                GradientRGB1 = Color3.fromRGB(119,120,255);
                GradientRGB2 = Color3.fromRGB(0,0,0);
                GradientFill = true;
                GradientFillRGB1 = Color3.fromRGB(119,120,255);
                GradientFillRGB2 = Color3.fromRGB(0,0,0);
                Filled = { Enabled = true; Transparency = 0.75; RGB = Color3.fromRGB(0,0,0) };
                Full = { Enabled = true; RGB = Color3.fromRGB(255,255,255) };
                Corner = { Enabled = true; RGB = Color3.fromRGB(255,255,255) };
            };
        };
    };
    Teleport = {
        TargetPlayer = nil;
        SmoothTeleport = false;
        TweenSpeed = 300;
        SuckAll = false;
        LockPlayerToMe = false;
    };
    Entertainment = {
        Rotate = { Enabled = false; Speed = 30 };
        BunnyHop = { Enabled = false; SpeedBoost = 2 };
        RandomRagdoll = false;
        ReverseControl = false;
        IceSkating = false;
    };
    Invisibility = {
        Enabled = false;
        Mode = "Client";
    };
    OtherScript = { CardKey = ""; DamaCardKey = "" };
    JobIdToJoin = "";
    Threads = {};
    Controls = {};
}
getgenv().TrashGeneral = TrashGeneral

local Controls = TrashGeneral.Controls

local function char() return lp.Character or lp.CharacterAdded:Wait() end
local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = char() return c and c:FindFirstChild("Humanoid") end

local function IsEnemy(p)
    if not p or p == lp then return false end
    if lp.Team and p.Team then if lp.Team == p.Team then return false end end
    local a1 = lp:GetAttribute("Team")
    local a2 = p:GetAttribute("Team")
    if a1 and a2 and a1 == a2 then return false end
    return true
end

local function ValidEnemies()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if IsEnemy(p) then
            local c = p.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local h = c:FindFirstChild("Humanoid")
                if h and h.Health > 0 then table.insert(t, p) end
            end
        end
    end
    return t
end

local function AllEnemies()
    local t = {}
    local f = ws:FindFirstChild("Enemies")
    if f then
        for _, e in ipairs(f:GetChildren()) do
            if e:IsA("Model") then
                local h = e:FindFirstChild("Humanoid")
                if h and h.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
                    table.insert(t, e)
                end
            end
        end
    end
    return t
end

local function hasObstacle(targetPos, targetPlayer)
    if not cam then return true end
    local origin = cam.CFrame.Position
    local dir = (targetPos - origin).Unit
    local dist = (targetPos - origin).Magnitude
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {lp.Character, cam}
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.IgnoreWater = true
    local res = ws:Raycast(origin, dir * dist, rp)
    if res then
        local hit = res.Instance
        if hit then
            local hitPlr = Players:GetPlayerFromCharacter(hit:FindFirstAncestorOfClass("Model"))
            return hitPlr and hitPlr ~= targetPlayer or not hitPlr
        end
    end
    return false
end

local function TargetInFOV()
    local hrp = root()
    if not hrp or not cam then return nil, nil end
    local fovRad = TrashGeneral.Aimbot.FOVSize
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local closest, closestPos, closestDist = nil, nil, fovRad
    for _, p in ipairs(ValidEnemies()) do
        local tp = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
        if tp then
            local dist = (tp.Position - hrp.Position).Magnitude
            if dist <= TrashGeneral.Aimbot.Distance then
                local sp, onScr = cam:WorldToViewportPoint(tp.Position)
                if onScr and sp.Z > 0 then
                    local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                    if d <= fovRad then
                        if TrashGeneral.Aimbot.CheckObstacles and hasObstacle(tp.Position, p) then continue end
                        if d < closestDist then
                            closestDist = d
                            closest = p
                            closestPos = tp.Position
                        end
                    end
                end
            end
        end
    end
    return closest, closestPos
end

local function aimLoop()
    if not TrashGeneral.Aimbot.Enabled then return end
    local _, tpos = TargetInFOV()
    if tpos then
        pcall(function()
            local cpos = cam.CFrame.Position
            if (tpos - cpos).Magnitude < 0.001 then return end
            local cf = CFrame.lookAt(cpos, tpos)
            if TrashGeneral.Aimbot.Smooth then
                local speed = (TrashGeneral.Aimbot.Speed / 500) * 0.2
                speed = math.clamp(speed, 0.02, 0.2)
                cam.CFrame = cam.CFrame:Lerp(cf, speed)
            else
                cam.CFrame = cf
            end
        end)
    end
end

local fovCircle
local function updateFOV()
    if not fovCircle or not fovCircle.Parent then return end
    local frame = fovCircle:FindFirstChild("FOVFrame")
    if frame then
        local size = TrashGeneral.Aimbot.FOVSize * 2
        frame.Size = UDim2.new(0, size, 0, size)
        frame.Position = UDim2.new(0.5, -TrashGeneral.Aimbot.FOVSize, 0.5, -TrashGeneral.Aimbot.FOVSize)
        local _, t = TargetInFOV()
        frame.UIStroke.Color = t and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
end

local function createFOV()
    if fovCircle then pcall(function() fovCircle:Destroy() end) end
    local guiParent = cg or lp:FindFirstChild("PlayerGui")
    if not guiParent then return end
    fovCircle = Instance.new("ScreenGui")
    fovCircle.Name = "TrashFOV"
    fovCircle.Parent = guiParent
    fovCircle.IgnoreGuiInset = true
    fovCircle.DisplayOrder = 999999
    fovCircle.Enabled = TrashGeneral.Aimbot.ShowFOV
    fovCircle.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Name = "FOVFrame"
    frame.Size = UDim2.new(0, TrashGeneral.Aimbot.FOVSize*2, 0, TrashGeneral.Aimbot.FOVSize*2)
    frame.Position = UDim2.new(0.5, -TrashGeneral.Aimbot.FOVSize, 0.5, -TrashGeneral.Aimbot.FOVSize)
    frame.BackgroundTransparency = 1
    frame.Parent = fovCircle
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(1,0); corner.Parent = frame
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255,0,0); stroke.Transparency = 0.3; stroke.Parent = frame
    if TrashGeneral.Threads.FOV then task.cancel(TrashGeneral.Threads.FOV) end
    TrashGeneral.Threads.FOV = task.spawn(function()
        while fovCircle and fovCircle.Parent and TrashGeneral.Aimbot.ShowFOV do
            pcall(updateFOV)
            task.wait(0.1)
        end
    end)
end

local function toggleAimbot(state)
    TrashGeneral.Aimbot.Enabled = state
    if state then
        if TrashGeneral.Threads.Aimbot then TrashGeneral.Threads.Aimbot:Disconnect() end
        TrashGeneral.Threads.Aimbot = rs.RenderStepped:Connect(aimLoop)
    else
        if TrashGeneral.Threads.Aimbot then TrashGeneral.Threads.Aimbot:Disconnect(); TrashGeneral.Threads.Aimbot = nil end
    end
end

local function toggleFOV(state)
    TrashGeneral.Aimbot.ShowFOV = state
    if state then
        if not fovCircle or not fovCircle.Parent then createFOV() else fovCircle.Enabled = true end
    else
        if fovCircle then fovCircle.Enabled = false end
    end
end

local enemyVisObjects = {}
local enemyVisLoop
local function updateEnemyVis()
    for enemy, data in pairs(enemyVisObjects) do
        if not enemy or not enemy.Parent or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then
            if data.highlight then data.highlight:Destroy() end
            if data.conn then data.conn:Disconnect() end
            if data.rem then data.rem:Disconnect() end
            enemyVisObjects[enemy] = nil
        end
    end
    if not TrashGeneral.EnemyVisual.Enabled then return end
    local all = {}
    for _, p in ipairs(Players:GetPlayers()) do if IsEnemy(p) and p.Character then table.insert(all, p.Character) end end
    for _, e in ipairs(AllEnemies()) do table.insert(all, e) end
    for _, enemyChar in ipairs(all) do
        if enemyChar and enemyChar:FindFirstChild("Humanoid") and enemyChar.Humanoid.Health > 0 then
            local rp = enemyChar:FindFirstChild("HumanoidRootPart") or enemyChar:FindFirstChild("Head")
            if not rp then continue end
            if not enemyVisObjects[enemyChar] then
                local data = {}
                local hl = Instance.new("Highlight")
                hl.Adornee = enemyChar
                hl.FillColor = TrashGeneral.EnemyVisual.Hitbox.Color
                hl.FillTransparency = TrashGeneral.EnemyVisual.Hitbox.Transparency
                hl.OutlineColor = TrashGeneral.EnemyVisual.Hitbox.Color
                hl.OutlineTransparency = 0.5
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = enemyChar
                data.highlight = hl
                local hum = enemyChar:FindFirstChild("Humanoid")
                local cleanup
                if hum then
                    cleanup = hum.Died:Connect(function()
                        if data.highlight then data.highlight:Destroy() end
                        if enemyVisObjects[enemyChar] then
                            if enemyVisObjects[enemyChar].conn then enemyVisObjects[enemyChar].conn:Disconnect() end
                            if enemyVisObjects[enemyChar].rem then enemyVisObjects[enemyChar].rem:Disconnect() end
                            enemyVisObjects[enemyChar] = nil
                        end
                    end)
                end
                local removing
                removing = enemyChar.AncestryChanged:Connect(function()
                    if not enemyChar.Parent then
                        if data.highlight then data.highlight:Destroy() end
                        if enemyVisObjects[enemyChar] then
                            if enemyVisObjects[enemyChar].conn then enemyVisObjects[enemyChar].conn:Disconnect() end
                            if enemyVisObjects[enemyChar].rem then enemyVisObjects[enemyChar].rem:Disconnect() end
                            enemyVisObjects[enemyChar] = nil
                        end
                    end
                end)
                data.conn = cleanup
                data.rem = removing
                enemyVisObjects[enemyChar] = data
            else
                local d = enemyVisObjects[enemyChar]
                if d.highlight then
                    d.highlight.FillColor = TrashGeneral.EnemyVisual.Hitbox.Color
                    d.highlight.FillTransparency = TrashGeneral.EnemyVisual.Hitbox.Transparency
                    d.highlight.OutlineColor = TrashGeneral.EnemyVisual.Hitbox.Color
                end
            end
        end
    end
end

local function startEnemyVisLoop()
    if enemyVisLoop then task.cancel(enemyVisLoop) end
    enemyVisLoop = task.spawn(function()
        while TrashGeneral.EnemyVisual.Enabled do
            pcall(updateEnemyVis)
            task.wait(0.2)
        end
        for enemy, data in pairs(enemyVisObjects) do
            if data.highlight then data.highlight:Destroy() end
            if data.conn then data.conn:Disconnect() end
            if data.rem then data.rem:Disconnect() end
        end
        enemyVisObjects = {}
    end)
end

local function toggleEnemyVis(state)
    TrashGeneral.EnemyVisual.Enabled = state
    if state then startEnemyVisLoop()
    else
        if enemyVisLoop then task.cancel(enemyVisLoop); enemyVisLoop = nil end
        for _, data in pairs(enemyVisObjects) do
            if data.highlight then data.highlight:Destroy() end
            if data.conn then data.conn:Disconnect() end
            if data.rem then data.rem:Disconnect() end
        end
        enemyVisObjects = {}
    end
    WindUI:Notify({ Title = "敌人视觉辅助", Content = state and "已开启" or "已关闭", Duration = 1.5 })
end

local flightConn
local function startFlight()
    if flightConn then flightConn:Disconnect() end
    local c = lp.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local head = c:FindFirstChild("Head")
    if not h or not head then return end
    h.PlatformStand = true
    head.Anchored = true
    local cam = ws.CurrentCamera
    flightConn = rs.Heartbeat:Connect(function(dt)
        if not TrashGeneral.FlyEnabled or not lp.Character then stopFlight(); return end
        local c = lp.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local hd = c and c:FindFirstChild("Head")
        if not h or not hd then stopFlight(); return end
        local moveDir = h.MoveDirection * (TrashGeneral.FlySpeed * dt * 50)
        local headCF = hd.CFrame
        local camCF = cam.CFrame
        local camOffset = headCF:ToObjectSpace(camCF).Position
        camCF = camCF * CFrame.new(-camOffset.X, -camOffset.Y, -camOffset.Z + 1)
        local camPos = camCF.Position
        local headPos = headCF.Position
        local objSpace = CFrame.new(camPos, Vector3.new(headPos.X, camPos.Y, headPos.Z)):VectorToObjectSpace(moveDir)
        hd.CFrame = CFrame.new(headPos) * (camCF - camPos) * CFrame.new(objSpace)
    end)
end

local function stopFlight()
    if flightConn then flightConn:Disconnect(); flightConn = nil end
    local c = lp.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        local hd = c:FindFirstChild("Head")
        if h then h.PlatformStand = false end
        if hd then hd.Anchored = false end
    end
end

local rotateThread
local function startRotate()
    if rotateThread then task.cancel(rotateThread) end
    rotateThread = task.spawn(function()
        local last = os.clock()
        while TrashGeneral.Entertainment.Rotate.Enabled do
            local now = os.clock()
            local dt = now - last
            last = now
            local sp = TrashGeneral.Entertainment.Rotate.Speed
            if sp > 0 and dt > 0 then
                local hrp = root()
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(sp * dt), 0) end
            end
            task.wait()
        end
    end)
end
local function stopRotate()
    if rotateThread then task.cancel(rotateThread); rotateThread = nil end
end

local bunnyHopThread
local origWalkSpeed = 16
local function startBunnyHop()
    if bunnyHopThread then task.cancel(bunnyHopThread) end
    bunnyHopThread = task.spawn(function()
        local lastJump = 0
        while TrashGeneral.Entertainment.BunnyHop.Enabled do
            local h = hum()
            local hrp = root()
            if h and hrp then
                local moving = h.MoveDirection.Magnitude > 0.1
                local onGround = h.FloorMaterial ~= Enum.Material.Air
                if moving and onGround and (tick() - lastJump) > 0.3 then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastJump = tick()
                    if h.WalkSpeed ~= TrashGeneral.Entertainment.BunnyHop.SpeedBoost * 16 then
                        origWalkSpeed = h.WalkSpeed
                        h.WalkSpeed = TrashGeneral.Entertainment.BunnyHop.SpeedBoost * 16
                    end
                elseif not moving and h.WalkSpeed ~= origWalkSpeed then
                    h.WalkSpeed = origWalkSpeed
                end
            end
            task.wait(0.05)
        end
        local h = hum()
        if h then h.WalkSpeed = origWalkSpeed end
    end)
end
local function stopBunnyHop()
    if bunnyHopThread then task.cancel(bunnyHopThread); bunnyHopThread = nil end
    local h = hum()
    if h then h.WalkSpeed = origWalkSpeed end
end

local suckAllThread
local function startSuckAll()
    if suckAllThread then task.cancel(suckAllThread) end
    suckAllThread = task.spawn(function()
        while TrashGeneral.Teleport.SuckAll do
            local myHRP = root()
            if myHRP then
                local tcf = myHRP.CFrame
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp then
                        local c = p.Character
                        if c then
                            local hrp = c:FindFirstChild("HumanoidRootPart")
                            if hrp then hrp.CFrame = tcf end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end
local function stopSuckAll()
    if suckAllThread then task.cancel(suckAllThread); suckAllThread = nil end
end

local lockPlayerThread
local function startLockPlayer()
    if lockPlayerThread then task.cancel(lockPlayerThread) end
    lockPlayerThread = task.spawn(function()
        while TrashGeneral.Teleport.LockPlayerToMe do
            local myRoot = root()
            local target = TrashGeneral.Teleport.TargetPlayer
            if myRoot and target then
                local tchar = target.Character
                if tchar then
                    local trp = tchar:FindFirstChild("HumanoidRootPart")
                    if trp then
                        trp.CFrame = myRoot.CFrame * CFrame.new(10, 5, 0)
                    end
                end
            end
            task.wait()
        end
    end)
end
local function stopLockPlayer()
    if lockPlayerThread then task.cancel(lockPlayerThread); lockPlayerThread = nil end
end

local ESPManager = {}
do
    local ScreenGui
    local Connections = {}
    local RotationAngle = -45
    local Tick = tick()
    local function Create(cls, props)
        local inst = typeof(cls) == 'string' and Instance.new(cls) or cls
        for k, v in pairs(props) do inst[k] = v end
        return inst
    end
    local function FadeOut(el, dist)
        if not el then return end
        local t = math.max(0.1, 1 - dist/TrashGeneral.ESP.MaxDistance)
        if el:IsA("TextLabel") then el.TextTransparency = 1-t
        elseif el:IsA("ImageLabel") then el.ImageTransparency = 1-t
        elseif el:IsA("UIStroke") then el.Transparency = 1-t
        elseif el:IsA("Frame") then el.BackgroundTransparency = 1-t
        elseif el:IsA("Highlight") then el.FillTransparency = 1-t; el.OutlineTransparency = 1-t
        end
    end
    local function CreateESP(plr)
        if not ScreenGui or Connections[plr] then return end
        local Name = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,-11), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true})
        local Dist = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,11), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true})
        local Weapon = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,31), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0), RichText=true})
        local Box = Create("Frame", {Parent=ScreenGui, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.75, BorderSizePixel=0})
        local Grad1 = Create("UIGradient", {Parent=Box, Enabled=TrashGeneral.ESP.Drawing.Boxes.GradientFill, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TrashGeneral.ESP.Drawing.Boxes.GradientFillRGB1),ColorSequenceKeypoint.new(1,TrashGeneral.ESP.Drawing.Boxes.GradientFillRGB2)}})
        local Outline = Create("UIStroke", {Parent=Box, Enabled=TrashGeneral.ESP.Drawing.Boxes.Gradient, Transparency=0, Color=Color3.fromRGB(255,255,255), LineJoinMode=Enum.LineJoinMode.Miter})
        local Grad2 = Create("UIGradient", {Parent=Outline, Enabled=TrashGeneral.ESP.Drawing.Boxes.Gradient, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TrashGeneral.ESP.Drawing.Boxes.GradientRGB1),ColorSequenceKeypoint.new(1,TrashGeneral.ESP.Drawing.Boxes.GradientRGB2)}})
        local Healthbar = Create("Frame", {Parent=ScreenGui, BackgroundColor3=Color3.fromRGB(255,255,255), BackgroundTransparency=0})
        local BehindHB = Create("Frame", {Parent=ScreenGui, ZIndex=-1, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0})
        local HBGrad = Create("UIGradient", {Parent=Healthbar, Enabled=TrashGeneral.ESP.Drawing.Healthbar.Gradient, Rotation=-90, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TrashGeneral.ESP.Drawing.Healthbar.GradientRGB1),ColorSequenceKeypoint.new(0.5,TrashGeneral.ESP.Drawing.Healthbar.GradientRGB2),ColorSequenceKeypoint.new(1,TrashGeneral.ESP.Drawing.Healthbar.GradientRGB3)}})
        local HealthText = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,31), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0)})
        local Chams = Create("Highlight", {Parent=ScreenGui, FillTransparency=1, OutlineTransparency=0, OutlineColor=Color3.fromRGB(119,120,255), DepthMode="AlwaysOnTop"})
        local WeaponIcon = Create("ImageLabel", {Parent=ScreenGui, BackgroundTransparency=1, BorderColor3=Color3.fromRGB(0,0,0), BorderSizePixel=0, Size=UDim2.new(0,40,0,40)})
        local Grad3 = Create("UIGradient", {Parent=WeaponIcon, Rotation=-90, Enabled=TrashGeneral.ESP.Drawing.Weapons.Gradient, Color=ColorSequence.new{ColorSequenceKeypoint.new(0,TrashGeneral.ESP.Drawing.Weapons.GradientRGB1),ColorSequenceKeypoint.new(1,TrashGeneral.ESP.Drawing.Weapons.GradientRGB2)}})
        local LeftTop = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local LeftSide = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local RightTop = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local RightSide = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local BottomSide = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local BottomDown = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local BottomRightSide = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local BottomRightDown = Create("Frame", {Parent=ScreenGui, BackgroundColor3=TrashGeneral.ESP.Drawing.Boxes.Corner.RGB, Position=UDim2.new(0,0,0,0)})
        local Flag1 = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0)})
        local Flag2 = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(1,0,0,0), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.fromRGB(255,255,255), Font=Enum.Font.Code, TextSize=TrashGeneral.ESP.FontSize, TextStrokeTransparency=0, TextStrokeColor3=Color3.fromRGB(0,0,0)})
        local function Hide()
            Box.Visible,Name.Visible,Dist.Visible,Weapon.Visible = false,false,false,false
            Healthbar.Visible,BehindHB.Visible,HealthText.Visible,WeaponIcon.Visible = false,false,false,false
            LeftTop.Visible,LeftSide.Visible,BottomSide.Visible,BottomDown.Visible = false,false,false,false
            RightTop.Visible,RightSide.Visible,BottomRightSide.Visible,BottomRightDown.Visible = false,false,false,false
            Flag1.Visible,Flag2.Visible,Chams.Enabled = false,false,false
        end
        local conn = rs.RenderStepped:Connect(function()
            if not TrashGeneral.ESP.Enabled then Hide(); return end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = plr.Character.HumanoidRootPart
                local Hum = plr.Character:FindFirstChild("Humanoid")
                if not Hum then return end
                local Pos,OnScr = cam:WorldToScreenPoint(HRP.Position)
                local DistVal = (cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                if OnScr and DistVal <= TrashGeneral.ESP.MaxDistance then
                    local size = HRP.Size.Y
                    local scale = (size * cam.ViewportSize.Y) / (Pos.Z * 2)
                    local w, h = 3*scale, 4.5*scale
                    if TrashGeneral.ESP.FadeOut.OnDistance then
                        FadeOut(Box,DistVal); FadeOut(Outline,DistVal); FadeOut(Name,DistVal); FadeOut(Dist,DistVal)
                        FadeOut(Weapon,DistVal); FadeOut(Healthbar,DistVal); FadeOut(BehindHB,DistVal)
                        FadeOut(HealthText,DistVal); FadeOut(WeaponIcon,DistVal); FadeOut(LeftTop,DistVal)
                        FadeOut(LeftSide,DistVal); FadeOut(BottomSide,DistVal); FadeOut(BottomDown,DistVal)
                        FadeOut(RightTop,DistVal); FadeOut(RightSide,DistVal); FadeOut(BottomRightSide,DistVal)
                        FadeOut(BottomRightDown,DistVal); FadeOut(Chams,DistVal); FadeOut(Flag1,DistVal)
                        FadeOut(Flag2,DistVal)
                    end
                    if (not TrashGeneral.ESP.TeamCheck) or IsEnemy(plr) then
                        Chams.Adornee = plr.Character
                        Chams.Enabled = TrashGeneral.ESP.Drawing.Chams.Enabled
                        Chams.FillColor = TrashGeneral.ESP.Drawing.Chams.FillRGB
                        Chams.OutlineColor = TrashGeneral.ESP.Drawing.Chams.OutlineRGB
                        if TrashGeneral.ESP.Drawing.Chams.Thermal then
                            local breathe = math.atan(math.sin(tick()*2))*2/math.pi
                            Chams.FillTransparency = TrashGeneral.ESP.Drawing.Chams.Fill_Transparency * breathe * 0.01
                            Chams.OutlineTransparency = TrashGeneral.ESP.Drawing.Chams.Outline_Transparency * breathe * 0.01
                        else
                            Chams.FillTransparency = TrashGeneral.ESP.Drawing.Chams.Fill_Transparency * 0.01
                            Chams.OutlineTransparency = TrashGeneral.ESP.Drawing.Chams.Outline_Transparency * 0.01
                        end
                        Chams.DepthMode = TrashGeneral.ESP.Drawing.Chams.VisibleCheck and "Occluded" or "AlwaysOnTop"
                        LeftTop.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; LeftTop.Position = UDim2.new(0,Pos.X-w/2,0,Pos.Y-h/2); LeftTop.Size = UDim2.new(0,w/5,0,1)
                        LeftSide.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; LeftSide.Position = UDim2.new(0,Pos.X-w/2,0,Pos.Y-h/2); LeftSide.Size = UDim2.new(0,1,0,h/5)
                        BottomSide.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; BottomSide.Position = UDim2.new(0,Pos.X-w/2,0,Pos.Y+h/2); BottomSide.Size = UDim2.new(0,1,0,h/5); BottomSide.AnchorPoint = Vector2.new(0,5)
                        BottomDown.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; BottomDown.Position = UDim2.new(0,Pos.X-w/2,0,Pos.Y+h/2); BottomDown.Size = UDim2.new(0,w/5,0,1); BottomDown.AnchorPoint = Vector2.new(0,1)
                        RightTop.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; RightTop.Position = UDim2.new(0,Pos.X+w/2,0,Pos.Y-h/2); RightTop.Size = UDim2.new(0,w/5,0,1); RightTop.AnchorPoint = Vector2.new(1,0)
                        RightSide.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; RightSide.Position = UDim2.new(0,Pos.X+w/2-1,0,Pos.Y-h/2); RightSide.Size = UDim2.new(0,1,0,h/5); RightSide.AnchorPoint = Vector2.new(0,0)
                        BottomRightSide.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; BottomRightSide.Position = UDim2.new(0,Pos.X+w/2,0,Pos.Y+h/2); BottomRightSide.Size = UDim2.new(0,1,0,h/5); BottomRightSide.AnchorPoint = Vector2.new(1,1)
                        BottomRightDown.Visible = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled; BottomRightDown.Position = UDim2.new(0,Pos.X+w/2,0,Pos.Y+h/2); BottomRightDown.Size = UDim2.new(0,w/5,0,1); BottomRightDown.AnchorPoint = Vector2.new(1,1)
                        Box.Position = UDim2.new(0,Pos.X-w/2,0,Pos.Y-h/2); Box.Size = UDim2.new(0,w,0,h)
                        Box.Visible = TrashGeneral.ESP.Drawing.Boxes.Full.Enabled
                        if TrashGeneral.ESP.Drawing.Boxes.Filled.Enabled then Box.BackgroundColor3 = TrashGeneral.ESP.Drawing.Boxes.Filled.RGB; Box.BackgroundTransparency = TrashGeneral.ESP.Drawing.Boxes.Filled.Transparency else Box.BackgroundTransparency = 1 end
                        RotationAngle = RotationAngle + (tick()-Tick)*TrashGeneral.ESP.Drawing.Boxes.RotationSpeed * math.cos(math.pi/4*tick()-math.pi/2)
                        if TrashGeneral.ESP.Drawing.Boxes.Animate then Grad1.Rotation = RotationAngle; Grad2.Rotation = RotationAngle else Grad1.Rotation = -45; Grad2.Rotation = -45 end
                        Tick = tick()
                        local health = Hum.Health/Hum.MaxHealth
                        Healthbar.Visible = TrashGeneral.ESP.Drawing.Healthbar.Enabled; Healthbar.Position = UDim2.new(0,Pos.X-w/2-6,0,Pos.Y-h/2 + h*(1-health)); Healthbar.Size = UDim2.new(0,TrashGeneral.ESP.Drawing.Healthbar.Width,0,h*health)
                        BehindHB.Visible = TrashGeneral.ESP.Drawing.Healthbar.Enabled; BehindHB.Position = UDim2.new(0,Pos.X-w/2-6,0,Pos.Y-h/2); BehindHB.Size = UDim2.new(0,TrashGeneral.ESP.Drawing.Healthbar.Width,0,h)
                        if TrashGeneral.ESP.Drawing.Healthbar.HealthText then
                            local pct = math.floor(Hum.Health/Hum.MaxHealth*100)
                            HealthText.Position = UDim2.new(0,Pos.X-w/2-6,0,Pos.Y-h/2+h*(1-pct/100)+3)
                            HealthText.Text = tostring(pct)
                            HealthText.Visible = Hum.Health < Hum.MaxHealth
                            if TrashGeneral.ESP.Drawing.Healthbar.Lerp then
                                local col = health>=0.75 and Color3.fromRGB(0,255,0) or health>=0.5 and Color3.fromRGB(255,255,0) or health>=0.25 and Color3.fromRGB(255,170,0) or Color3.fromRGB(255,0,0)
                                HealthText.TextColor3 = col
                            else
                                HealthText.TextColor3 = TrashGeneral.ESP.Drawing.Healthbar.HealthTextRGB
                            end
                        else HealthText.Visible = false end
                        Name.Visible = TrashGeneral.ESP.Drawing.Names.Enabled
                        if TrashGeneral.ESP.Options.Friendcheck and lp:IsFriendsWith(plr.UserId) then
                            Name.Text = string.format('(<font color="rgb(%d,%d,%d)">F</font>) %s', TrashGeneral.ESP.Options.FriendcheckRGB.R*255,TrashGeneral.ESP.Options.FriendcheckRGB.G*255,TrashGeneral.ESP.Options.FriendcheckRGB.B*255, plr.Name)
                        else
                            Name.Text = string.format('(<font color="rgb(%d,%d,%d)">E</font>) %s', 255,0,0, plr.Name)
                        end
                        Name.Position = UDim2.new(0,Pos.X,0,Pos.Y-h/2-9)
                        if TrashGeneral.ESP.Drawing.Distances.Enabled then
                            if TrashGeneral.ESP.Drawing.Distances.Position == "Bottom" then
                                Weapon.Position = UDim2.new(0,Pos.X,0,Pos.Y+h/2+18)
                                WeaponIcon.Position = UDim2.new(0,Pos.X-21,0,Pos.Y+h/2+15)
                                Dist.Position = UDim2.new(0,Pos.X,0,Pos.Y+h/2+7)
                                Dist.Text = string.format("%d meters", math.floor(DistVal)); Dist.Visible = true
                            elseif TrashGeneral.ESP.Drawing.Distances.Position == "Text" then
                                Weapon.Position = UDim2.new(0,Pos.X,0,Pos.Y+h/2+8)
                                WeaponIcon.Position = UDim2.new(0,Pos.X-21,0,Pos.Y+h/2+5)
                                Dist.Visible = false
                                if TrashGeneral.ESP.Options.Friendcheck and lp:IsFriendsWith(plr.UserId) then
                                    Name.Text = string.format('(<font color="rgb(%d,%d,%d)">F</font>) %s [%d]', TrashGeneral.ESP.Options.FriendcheckRGB.R*255,TrashGeneral.ESP.Options.FriendcheckRGB.G*255,TrashGeneral.ESP.Options.FriendcheckRGB.B*255, plr.Name, math.floor(DistVal))
                                else
                                    Name.Text = string.format('(<font color="rgb(%d,%d,%d)">E</font>) %s [%d]', 255,0,0, plr.Name, math.floor(DistVal))
                                end
                                Name.Visible = TrashGeneral.ESP.Drawing.Names.Enabled
                            end
                        end
                        Weapon.Text = "none"; Weapon.Visible = TrashGeneral.ESP.Drawing.Weapons.Enabled
                    else Hide() end
                else Hide() end
            else Hide() end
        end)
        Connections[plr] = {conn}
    end
    function ESPManager.Start()
        if ScreenGui then return end
        ScreenGui = Create("ScreenGui", {Parent=cg, Name="Trash_ESPHolder"})
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= lp and not Connections[v] then CreateESP(v) end
        end
        Connections.PlayerAdded = Players.PlayerAdded:Connect(function(v)
            if v ~= lp and not Connections[v] then CreateESP(v) end
        end)
    end
    function ESPManager.Stop()
        if ScreenGui then ScreenGui:Destroy(); ScreenGui = nil end
        for _, conn in pairs(Connections) do
            if type(conn) == "table" then for _, c in ipairs(conn) do c:Disconnect() end else conn:Disconnect() end
        end
        Connections = {}
    end
    function ESPManager.SetEnabled(v)
        TrashGeneral.ESP.Enabled = v
        if v then ESPManager.Start() else ESPManager.Stop() end
    end
end

local function teleportToPlayer(target)
    if not target then return end
    local tchar = target.Character
    if not tchar then
        local timeout = 0
        while not tchar and timeout < 5 do task.wait(0.1); tchar = target.Character; timeout += 0.1 end
        if not tchar then WindUI:Notify({Title="传送", Content="目标玩家未加载", Duration=2}); return end
    end
    local trp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Head") or tchar:FindFirstChild("Torso")
    if not trp then WindUI:Notify({Title="传送", Content="目标玩家无可用根部件", Duration=2}); return end
    local tcf = trp.CFrame
    if TrashGeneral.Teleport.SmoothTeleport then
        local function tweenTo(cf, speed)
            local hrp = root()
            if not hrp then return end
            local dist = (hrp.Position - cf.Position).Magnitude
            local dur = dist / speed
            local tw = tween:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = cf})
            tw:Play()
        end
        tweenTo(tcf, TrashGeneral.Teleport.TweenSpeed)
    else
        local hrp = root()
        if hrp then hrp.CFrame = tcf end
    end
    WindUI:Notify({Title="传送", Content="已传送至 "..target.Name, Duration=2})
end

local invisThread, invisPlatform
local function startInvis()
    local mode = TrashGeneral.Invisibility.Mode
    local c = lp.Character
    if not c then return end
    if mode == "Client" then
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end end
    elseif mode == "CFrame" then
        local hrp = root()
        if hrp then hrp.CFrame = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z) end
        local h = hum()
        if h then h.PlatformStand = true end
        if invisPlatform then invisPlatform:Destroy() end
        invisPlatform = Instance.new("Part")
        invisPlatform.Name = "InvisPlatform"; invisPlatform.Size = Vector3.new(5,0.5,5); invisPlatform.Anchored = true; invisPlatform.CanCollide = true; invisPlatform.Transparency = 1; invisPlatform.Parent = ws
        if invisThread then task.cancel(invisThread) end
        invisThread = task.spawn(function()
            while TrashGeneral.Invisibility.Enabled and TrashGeneral.Invisibility.Mode == "CFrame" do
                local hrp = root()
                if hrp then invisPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y-2, hrp.Position.Z) end
                task.wait(0.05)
            end
        end)
    end
end
local function stopInvis()
    local mode = TrashGeneral.Invisibility.Mode
    local c = lp.Character
    if c then
        if mode == "Client" then
            for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end end
        elseif mode == "CFrame" then
            local h = hum()
            if h then h.PlatformStand = false end
            if invisPlatform then invisPlatform:Destroy(); invisPlatform = nil end
            if invisThread then task.cancel(invisThread); invisThread = nil end
        end
    end
end
local function toggleInvis(state)
    TrashGeneral.Invisibility.Enabled = state
    if state then startInvis(); WindUI:Notify({Title="隐身", Content="已开启 ("..TrashGeneral.Invisibility.Mode..")", Duration=1.5})
    else stopInvis(); WindUI:Notify({Title="隐身", Content="已关闭", Duration=1.5}) end
end

local SilentAimIndicators = {}
do
    local circle = DrawingLib.new and DrawingLib.new("Circle") or { Visible = false }
    local lines = {}
    for i=1,5 do lines[i] = DrawingLib.new and DrawingLib.new("Line") or { Visible = false } end
    local tracer = DrawingLib.new and DrawingLib.new("Line") or { Visible = false }
    SilentAimIndicators = {circle=circle, lines=lines, tracer=tracer}
end

local SilentAim = {Indicators = SilentAimIndicators}
local function hideSilentVisuals()
    SilentAim.Indicators.circle.Visible = false
    for _, l in ipairs(SilentAim.Indicators.lines) do l.Visible = false end
    SilentAim.Indicators.tracer.Visible = false
end

local function isNPC(obj)
    return obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj)
end

local function updateNPCs()
    local new = {}
    local tmode = TrashGeneral.SilentAim.TargetMode
    if tmode == "NPC" or tmode == "所有" then
        for _, v in ipairs(ws:GetDescendants()) do
            if isNPC(v) then table.insert(new, v) end
        end
    end
    SilentAim.NPCs = new
end

local function isBlacklisted(name)
    local ln = name:lower()
    for _, bl in ipairs(TrashGeneral.SilentAim.BlacklistedNames) do
        if bl:lower() == ln then return true end
    end
    return false
end

local function partVisible(part)
    if not part then return false end
    local c = lp.Character; if not c then return false end
    local origin = cam.CFrame.Position
    local dir = part.Position - origin
    local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {c, part.Parent}
    return not ws:Raycast(origin, dir.Unit * dir.Magnitude, rp)
end

local function getTarget()
    local c = lp.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local localRoot = c.HumanoidRootPart
    local aimPoint = TrashGeneral.SilentAim.FixedFOV and (cam.ViewportSize/2) or uis:GetMouseLocation()
    local candidates = {}
    local tmode = TrashGeneral.SilentAim.TargetMode
    local function process(model, isPlr)
        if isBlacklisted(model.Name) then return end
        if TrashGeneral.SilentAim.TeamCheck and model.Team and model.Team == lp.Team then return end
        local hum = model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = model:FindFirstChild(TrashGeneral.SilentAim.TargetPart) or model:FindFirstChild("HumanoidRootPart")
        if not part then return end
        if TrashGeneral.SilentAim.VisibleCheck and not partVisible(part) then return end
        local dist = (localRoot.Position - part.Position).Magnitude
        if dist > TrashGeneral.SilentAim.MaxDistance then return end
        local fovDist = math.huge
        if TrashGeneral.SilentAim.PriorityMode ~= "最近的人(无FOV)" then
            local sp, on = cam:WorldToViewportPoint(part.Position)
            if on then fovDist = (aimPoint - Vector2.new(sp.X, sp.Y)).Magnitude
            else return end
            if fovDist > TrashGeneral.SilentAim.FOVRadius then return end
        end
        table.insert(candidates, {model=model, part=part, dist=dist, health=hum.Health, fov=fovDist})
    end
    if tmode == "玩家" or tmode == "所有" then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then process(p.Character, true) end
        end
    end
    if tmode == "NPC" or tmode == "所有" then
        for _, npc in ipairs(SilentAim.NPCs or {}) do process(npc, false) end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a,b)
        if TrashGeneral.SilentAim.PriorityMode == "最低血量" then return a.health < b.health
        elseif TrashGeneral.SilentAim.PriorityMode == "距离最近" or TrashGeneral.SilentAim.PriorityMode == "最近的人(无FOV)" then return a.dist < b.dist
        else return a.fov < b.fov end
    end)
    return candidates[1].model, candidates[1].part
end

local currentTargetChar, currentTargetPart
local silentRainbowHue, silentRotAngle = 0, 0
local recentShots = {}

local function silentAimRender()
    local enabled = TrashGeneral.SilentAim.Enabled
    hideSilentVisuals()
    if not enabled then currentTargetChar, currentTargetPart = nil, nil; return end
    local char, part = getTarget()
    currentTargetChar, currentTargetPart = char, part
    if part and DrawingLib then
        local pos, on = cam:WorldToViewportPoint(part.Position)
        if on and TrashGeneral.SilentAim.ShowTarget then
            local rad = TrashGeneral.SilentAim.TargetIndicatorRadius
            local color = partVisible(part) and Color3.fromRGB(0,255,0) or (TrashGeneral.SilentAim.IndicatorRainbowEnabled and Color3.fromHSV(silentRainbowHue,1,1) or Color3.fromRGB(255,0,0))
            local style = TrashGeneral.SilentAim.IndicatorStyle
            local breath = 1
            if TrashGeneral.SilentAim.IndicatorBreathing then
                breath = TrashGeneral.SilentAim.IndicatorBreathingMin + (TrashGeneral.SilentAim.IndicatorBreathingMax - TrashGeneral.SilentAim.IndicatorBreathingMin) * (math.sin(tick()*TrashGeneral.SilentAim.IndicatorBreathingSpeed*math.pi*2)*0.5+0.5)
            end
            if style == "Circle" then
                local c = SilentAim.Indicators.circle; c.Visible = true; c.Color = color; c.Radius = rad*breath; c.Position = Vector2.new(pos.X, pos.Y)
            elseif style == "十字准星" then
                local len = TrashGeneral.SilentAim.CrosshairLength * breath; local gap = TrashGeneral.SilentAim.CrosshairGap * breath
                local cx, cy = pos.X, pos.Y
                local l = SilentAim.Indicators.lines
                l[1].Visible = true; l[1].From = Vector2.new(cx, cy - len); l[1].To = Vector2.new(cx, cy - gap); l[1].Color = color
                l[2].Visible = true; l[2].From = Vector2.new(cx, cy + len); l[2].To = Vector2.new(cx, cy + gap); l[2].Color = color
                l[3].Visible = true; l[3].From = Vector2.new(cx - len, cy); l[3].To = Vector2.new(cx - gap, cy); l[3].Color = color
                l[4].Visible = true; l[4].From = Vector2.new(cx + len, cy); l[4].To = Vector2.new(cx + gap, cy); l[4].Color = color
            end
        end
        if TrashGeneral.SilentAim.ShowTracer then
            local tr = SilentAim.Indicators.tracer
            tr.Visible = true; tr.From = cam.ViewportSize/2; tr.To = Vector2.new(pos.X, pos.Y)
        end
    end
    if TrashGeneral.SilentAim.IndicatorRainbowEnabled then silentRainbowHue = (tick()%6)/6 end
    if TrashGeneral.SilentAim.IndicatorRotationEnabled then silentRotAngle = (silentRotAngle + TrashGeneral.SilentAim.IndicatorRotationSpeed/50) % (math.pi*2) end
end

local oldNamecall, oldIndex, oldRayNew
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod()
    local args = {...}
    local self = args[1]
    if TrashGeneral.SilentAim.Enabled and not checkcaller() and math.random() <= TrashGeneral.SilentAim.HitChance/100 and currentTargetPart then
        local curMethod = TrashGeneral.SilentAim.Method
        local origin = nil
        if (method == "FindPartOnRayWithIgnoreList" and curMethod == method) or
           (method == "FindPartOnRayWithWhitelist" and curMethod == method) or
           ((method == "FindPartOnRay" or method == "findPartOnRay") and curMethod:lower() == method:lower()) then
            if args[2] and args[2].Origin then
                origin = args[2].Origin
                table.insert(recentShots, {origin=origin, time=tick()})
                if TrashGeneral.SilentAim.Wallbang then
                    return currentTargetPart, currentTargetPart.Position, currentTargetPart.CFrame.LookVector, currentTargetPart.Material
                end
                local dir = (currentTargetPart.Position - origin).Unit * 1000
                args[2] = Ray.new(origin, dir)
                return oldNamecall(unpack(args))
            end
        elseif method == "Raycast" and curMethod == method then
            if args[2] and args[3] then
                origin = args[2]
                table.insert(recentShots, {origin=origin, time=tick()})
                if TrashGeneral.SilentAim.Wallbang then
                    local dir = (currentTargetPart.Position - origin).Unit * 1000
                    local wp = RaycastParams.new(); wp.FilterType = Enum.RaycastFilterType.Include; wp.FilterDescendantsInstances = {currentTargetPart.Parent}
                    return oldNamecall(args[1], origin, dir, wp)
                end
                args[3] = (currentTargetPart.Position - origin).Unit * 1000
                return oldNamecall(unpack(args))
            end
        elseif (method == "ScreenPointToRay" or method == "ViewportPointToRay") and curMethod == method and self == cam then
            origin = cam.CFrame.Position
            table.insert(recentShots, {origin=origin, time=tick()})
            return Ray.new(origin, (currentTargetPart.Position - origin).Unit)
        end
    end
    return oldNamecall(...)
end))

oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if self == lp:GetMouse() and not checkcaller() and TrashGeneral.SilentAim.Enabled and TrashGeneral.SilentAim.Method == "Mouse.Hit/Target" then
        if currentTargetPart then
            table.insert(recentShots, {origin=lp.Character and lp.Character:FindFirstChild("Head") and lp.Character.Head.Position or cam.CFrame.Position, time=tick()})
            if idx:lower() == "target" then return currentTargetPart
            elseif idx:lower() == "hit" then
                if TrashGeneral.SilentAim.MouseHitPrediction then
                    return (currentTargetPart.CFrame + (currentTargetPart.Velocity * currentTargetPart.Velocity.magnitude * TrashGeneral.SilentAim.MouseHitPredictionAmount))
                else return currentTargetPart.CFrame end
            end
        end
    end
    return oldIndex(self, idx)
end))

oldRayNew = hookfunction(Ray.new, newcclosure(function(origin, direction)
    if TrashGeneral.SilentAim.Enabled and TrashGeneral.SilentAim.Method == "Ray" and currentTargetPart and not checkcaller() and math.random() <= TrashGeneral.SilentAim.HitChance/100 then
        table.insert(recentShots, {origin=origin, time=tick()})
        return oldRayNew(origin, (currentTargetPart.Position - origin).Unit * 1000)
    end
    return oldRayNew(origin, direction)
end))

local function disableAll()
    TrashGeneral.FlyEnabled = false; stopFlight(); if Controls.FlightToggle then Controls.FlightToggle:Set(false) end
    TrashGeneral.SpeedEnabled = false; local h = hum(); if h then h.WalkSpeed = 16 end; if Controls.SpeedToggle then Controls.SpeedToggle:Set(false) end
    TrashGeneral.HighJumpEnabled = false; h = hum(); if h then h.JumpPower = 50; if TrashGeneral.Threads.HighJump then TrashGeneral.Threads.HighJump:Disconnect(); TrashGeneral.Threads.HighJump = nil end end; if Controls.HighJumpToggle then Controls.HighJumpToggle:Set(false) end
    TrashGeneral.AntiAFK = false; if TrashGeneral.Threads.AntiAFK then task.cancel(TrashGeneral.Threads.AntiAFK); TrashGeneral.Threads.AntiAFK = nil end; if Controls.AntiAFK then Controls.AntiAFK:Set(false) end
    TrashGeneral.ESP.Enabled = false; ESPManager.Stop(); if Controls.ESPEnabled then Controls.ESPEnabled:Set(false) end
    TrashGeneral.EnemyVisual.Enabled = false; toggleEnemyVis(false); if Controls.EnemyVisual then Controls.EnemyVisual:Set(false) end
    TrashGeneral.Entertainment.Rotate.Enabled = false; stopRotate(); if Controls.RotateToggle then Controls.RotateToggle:Set(false) end
    TrashGeneral.Entertainment.BunnyHop.Enabled = false; stopBunnyHop(); if Controls.BunnyHopToggle then Controls.BunnyHopToggle:Set(false) end
    TrashGeneral.Teleport.SuckAll = false; stopSuckAll(); if Controls.SuckAll then Controls.SuckAll:Set(false) end
    TrashGeneral.Teleport.LockPlayerToMe = false; stopLockPlayer(); if Controls.LockPlayerToggle then Controls.LockPlayerToggle:Set(false) end
    TrashGeneral.Aimbot.Enabled = false; toggleAimbot(false); if Controls.Aimbot then Controls.Aimbot:Set(false) end
    TrashGeneral.SilentAim.Enabled = false; if Controls.SilentAimEnabled then Controls.SilentAimEnabled:Set(false) end
    TrashGeneral.Invisibility.Enabled = false; toggleInvis(false); if Controls.InvisibilityToggle then Controls.InvisibilityToggle:Set(false) end
    TrashGeneral.InfJump = false; if TrashGeneral.Threads.InfJump then TrashGeneral.Threads.InfJump:Disconnect(); TrashGeneral.Threads.InfJump = nil end; if Controls.InfJumpToggle then Controls.InfJumpToggle:Set(false) end
    TrashGeneral.Entertainment.RandomRagdoll = false; if TrashGeneral.Threads.RandomRagdoll then task.cancel(TrashGeneral.Threads.RandomRagdoll) end; if Controls.RandomRagdoll then Controls.RandomRagdoll:Set(false) end
    TrashGeneral.Entertainment.ReverseControl = false; if TrashGeneral.Threads.ReverseControl then TrashGeneral.Threads.ReverseControl:Disconnect() end; if Controls.ReverseControl then Controls.ReverseControl:Set(false) end
    TrashGeneral.Entertainment.IceSkating = false; local c = lp.Character; if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = nil end end end; if Controls.IceSkating then Controls.IceSkating:Set(false) end
    TrashGeneral.NoPromptCD = false; if Controls.NoPromptCD then Controls.NoPromptCD:Set(false) end
    WindUI:Notify({Title="关闭所有功能", Content="已关闭", Duration=2})
end

local function applyNoPromptCD(state)
    TrashGeneral.NoPromptCD = state
    for _, obj in ipairs(ws:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = state and 0 or obj:GetAttribute("OriginalHoldDuration") or 0.5
        end
    end
    if state then
        TrashGeneral.Threads.NoPromptCD = rs.Heartbeat:Connect(function()
            for _, obj in ipairs(ws:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then obj.HoldDuration = 0 end
            end
        end)
    else
        if TrashGeneral.Threads.NoPromptCD then
            TrashGeneral.Threads.NoPromptCD:Disconnect()
            TrashGeneral.Threads.NoPromptCD = nil
        end
    end
end

local Window = WindUI:CreateWindow({
    Title = "<font color='#ffaa00'>TrashHub </font>通用",
    Author = "Was",
    Folder = "TrashGeneral",
    Size = UDim2.fromOffset(320, 620),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 100,
    ScrollBarEnabled = true,
    Background = "https://chaton-images.s3.us-east-2.amazonaws.com/o7hkoAxrjanwZ1BaDWuAXj6cJ0VNtkTTtHBjBfG6HpiuD4X1jR6X9V6PJmpGsCMV_1920x1080x683842.jpeg",
    BackgroundImageTransparency = 0.5,
})

Window:EditOpenButton({
    Title = "<font color='#ffaa00'>TrashHub </font><font color='#ffffff'>通用</font>",
    CornerRadius = UDim.new(0,10),
    StrokeThickness = 2.5,
    Color = ColorSequence.new(Color3.fromHex("#ffaa00"), Color3.fromHex("#ffdd44")),
    Draggable = true,
})

local TabCharacters = Window:Tab({ Title = "人物", Icon = "user" })
local TabEnvironment = Window:Tab({ Title = "环境", Icon = "cloud" })
local TabAim = Window:Tab({ Title = "瞄准", Icon = "crosshair" })
local TabESP = Window:Tab({ Title = "ESP", Icon = "eye" })
local TabTeleport = Window:Tab({ Title = "传送", Icon = "map-pin" })
local TabOthers = Window:Tab({ Title = "其他", Icon = "settings" })
local TabEntertainment = Window:Tab({ Title = "娱乐", Icon = "sparkles" })
local TabConfig = Window:Tab({ Title = "配置", Icon = "settings" })

TabCharacters:Section({ Title = "移动辅助", Opened = true })
Controls.FlightToggle = TabCharacters:Toggle({ Title = "飞行", Icon = "plane", Value = TrashGeneral.FlyEnabled, Callback = function(v) TrashGeneral.FlyEnabled = v; if v then startFlight(); else stopFlight() end end })
TabCharacters:Slider({ Title = "飞行速度", Icon = "gauge", Value = { Min = 1, Max = 10, Default = TrashGeneral.FlySpeed }, Callback = function(v) TrashGeneral.FlySpeed = v end })
Controls.SpeedToggle = TabCharacters:Toggle({ Title = "加速", Icon = "gauge", Value = TrashGeneral.SpeedEnabled, Callback = function(v) TrashGeneral.SpeedEnabled = v; local h = hum(); if h then h.WalkSpeed = v and TrashGeneral.SpeedValue or 16 end end })
TabCharacters:Slider({ Title = "加速速度", Icon = "tachometer", Value = { Min = 16, Max = 200, Default = TrashGeneral.SpeedValue }, Callback = function(v) TrashGeneral.SpeedValue = v; if TrashGeneral.SpeedEnabled then local h = hum(); if h then h.WalkSpeed = v end end end })
Controls.HighJumpToggle = TabCharacters:Toggle({ Title = "高跳", Icon = "arrow-up", Value = TrashGeneral.HighJumpEnabled, Callback = function(v) TrashGeneral.HighJumpEnabled = v; local h = hum(); if h then if v then h.JumpPower = TrashGeneral.JumpPower; if not TrashGeneral.Threads.HighJump then TrashGeneral.Threads.HighJump = h.Jumping:Connect(function() h.JumpPower = TrashGeneral.JumpPower end) end else h.JumpPower = 50; if TrashGeneral.Threads.HighJump then TrashGeneral.Threads.HighJump:Disconnect(); TrashGeneral.Threads.HighJump = nil end end end end })
TabCharacters:Slider({ Title = "跳跃高度", Icon = "sliders", Value = { Min = 30, Max = 200, Default = TrashGeneral.JumpPower }, Callback = function(v) TrashGeneral.JumpPower = v; if TrashGeneral.HighJumpEnabled then local h = hum(); if h then h.JumpPower = v end end end })
Controls.InfJumpToggle = TabCharacters:Toggle({ Title = "无限跳跃", Icon = "arrow-up-circle", Value = false, Callback = function(v) TrashGeneral.InfJump = v; if v then TrashGeneral.Threads.InfJump = uis.JumpRequest:Connect(function() if TrashGeneral.InfJump then local h = hum(); if h and h:GetState() == Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end) else if TrashGeneral.Threads.InfJump then TrashGeneral.Threads.InfJump:Disconnect(); TrashGeneral.Threads.InfJump = nil end end end })
TabCharacters:Divider()
TabCharacters:Section({ Title = "防护", Opened = true })
Controls.AntiRagdoll = TabCharacters:Toggle({ Title = "反布娃娃", Icon = "shield", Value = TrashGeneral.AntiRagdoll, Callback = function(v) TrashGeneral.AntiRagdoll = v; if v then local h = hum(); if h then h.StateChanged:Connect(function(_, new) if new == Enum.HumanoidStateType.Ragdoll then h:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end end end })
Controls.AntiAFK = TabCharacters:Toggle({ Title = "反挂机", Icon = "clock", Value = TrashGeneral.AntiAFK, Callback = function(v) TrashGeneral.AntiAFK = v; if v then TrashGeneral.Threads.AntiAFK = task.spawn(function() while TrashGeneral.AntiAFK do pcall(function() vu:Button2Down(Vector2.new(0,0), cam.CFrame); task.wait(1); vu:Button2Up(Vector2.new(0,0), cam.CFrame); task.wait(60) end) end end) else if TrashGeneral.Threads.AntiAFK then task.cancel(TrashGeneral.Threads.AntiAFK) end end end })
TabCharacters:Divider()
TabCharacters:Section({ Title = "隐身", Opened = true })
Controls.InvisibilityToggle = TabCharacters:Toggle({ Title = "启用隐身", Icon = "eye-off", Value = TrashGeneral.Invisibility.Enabled, Callback = toggleInvis })
Controls.InvisibilityMode = TabCharacters:Dropdown({ Title = "隐身模式", Values = {"Client", "CFrame"}, Value = TrashGeneral.Invisibility.Mode, Callback = function(v) TrashGeneral.Invisibility.Mode = v; if TrashGeneral.Invisibility.Enabled then stopInvis(); startInvis() end end })

TabEnvironment:Section({ Title = "视觉增强", Opened = true })
TabEnvironment:Toggle({ Title = "夜视", Icon = "moon", Value = TrashGeneral.NightVision, Callback = function(v) TrashGeneral.NightVision = v; lighting.Ambient = v and Color3.new(1,1,1) or Color3.new(0,0,0); lighting.Brightness = v and 2 or 0.5; lighting.OutdoorAmbient = v and Color3.new(1,1,1) or Color3.new(0,0,0) end })
TabEnvironment:Toggle({ Title = "删除阴影", Icon = "sun", Value = TrashGeneral.RemoveShadows, Callback = function(v) TrashGeneral.RemoveShadows = v; lighting.GlobalShadows = not v; for _, o in ipairs(ws:GetDescendants()) do if o:IsA("BasePart") then o.CastShadow = not v end end end })
TabEnvironment:Button({ Title = "删除纹理", Icon = "zap", Callback = function() pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01; lighting.FogEnd = 9e9; for _, v in ipairs(ws:GetDescendants()) do if v:IsA("Part") or v:IsA("MeshPart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0 elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end end; WindUI:Notify({Title="删除纹理", Content="已优化", Duration=2}) end) end })
TabEnvironment:Button({ Title = "删除天空盒", Icon = "cloud-off", Callback = function() pcall(function() if lighting.Sky then lighting.Sky:Destroy() end end) end })
TabEnvironment:Section({ Title = "时间调节", Opened = true })
TabEnvironment:Dropdown({ Title = "修改时间", Values = {"8:00","12:00","18:00","24:00"}, Value = TrashGeneral.SelectedTime, Callback = function(s) TrashGeneral.SelectedTime = s end })
TabEnvironment:Button({ Title = "确认修改时间", Icon = "check", Callback = function() local h = tonumber(TrashGeneral.SelectedTime:match("(%d+):")); if h then lighting.TimeOfDay = string.format("%02d:00:00", h) end end })
TabEnvironment:Section({ Title = "天气调节", Opened = true })
TabEnvironment:Dropdown({ Title = "修改天气", Values = {"Default","Rain","Storm","Snow","Fog","Sandstorm"}, Value = TrashGeneral.SelectedWeather, Callback = function(s) TrashGeneral.SelectedWeather = s end })
TabEnvironment:Button({ Title = "确认修改天气", Icon = "check", Callback = function() local w = TrashGeneral.SelectedWeather; if w == "Default" then lighting.FogEnd = 100000; lighting.FogStart = 0 end end })

TabAim:Section({ Title = "普通自瞄", Opened = true })
Controls.Aimbot = TabAim:Toggle({ Title = "自动瞄准", Icon = "target", Value = TrashGeneral.Aimbot.Enabled, Callback = toggleAimbot })
Controls.ShowFOV = TabAim:Toggle({ Title = "显示FOV圈", Icon = "eye", Value = TrashGeneral.Aimbot.ShowFOV, Callback = toggleFOV })
TabAim:Slider({ Title = "FOV大小", Icon = "ruler", Value = {Min=30,Max=500,Default=TrashGeneral.Aimbot.FOVSize}, Step=5, Callback = function(v) TrashGeneral.Aimbot.FOVSize = v; if TrashGeneral.Aimbot.ShowFOV then createFOV() end end })
Controls.CheckObstacles = TabAim:Toggle({ Title = "掩体判断", Icon = "shield", Value = TrashGeneral.Aimbot.CheckObstacles, Callback = function(v) TrashGeneral.Aimbot.CheckObstacles = v end })
TabAim:Toggle({ Title = "平滑自瞄", Icon = "activity", Value = TrashGeneral.Aimbot.Smooth, Callback = function(v) TrashGeneral.Aimbot.Smooth = v end })
TabAim:Slider({ Title = "自瞄速度", Icon = "gauge", Value = {Min=100,Max=500,Default=TrashGeneral.Aimbot.Speed}, Step=10, Callback = function(v) TrashGeneral.Aimbot.Speed = v end })
TabAim:Slider({ Title = "自瞄距离", Icon = "map-pin", Value = {Min=100,Max=5000,Default=TrashGeneral.Aimbot.Distance}, Step=100, Callback = function(v) TrashGeneral.Aimbot.Distance = v end })
TabAim:Divider()
TabAim:Section({ Title = "敌人视觉辅助", Opened = true })
Controls.EnemyVisual = TabAim:Toggle({ Title = "启用", Icon = "box", Value = TrashGeneral.EnemyVisual.Enabled, Callback = toggleEnemyVis })
TabAim:Slider({ Title = "Hitbox大小", Icon = "ruler", Value = {Min=1,Max=20,Default=TrashGeneral.EnemyVisual.Hitbox.Size}, Step=0.5, Callback = function(v) TrashGeneral.EnemyVisual.Hitbox.Size = v end })
TabAim:Slider({ Title = "Hitbox透明度", Icon = "droplet", Value = {Min=0,Max=1,Default=TrashGeneral.EnemyVisual.Hitbox.Transparency}, Step=0.05, Callback = function(v) TrashGeneral.EnemyVisual.Hitbox.Transparency = v end })
TabAim:Divider()
TabAim:Section({ Title = "静默自瞄", Opened = true })
Controls.SilentAimEnabled = TabAim:Toggle({ Title = "启用静默自瞄", Value = TrashGeneral.SilentAim.Enabled, Callback = function(v) TrashGeneral.SilentAim.Enabled = v end })
TabAim:Dropdown({ Title = "目标种类", Values = {"玩家","NPC","所有"}, Value = TrashGeneral.SilentAim.TargetMode, Callback = function(v) TrashGeneral.SilentAim.TargetMode = v end })
TabAim:Dropdown({ Title = "目标部位", Values = {"Head","HumanoidRootPart"}, Value = TrashGeneral.SilentAim.TargetPart, Callback = function(v) TrashGeneral.SilentAim.TargetPart = v end })
TabAim:Dropdown({ Title = "优先模式", Values = {"准星最近","距离最近","最低血量","最近的人(无FOV)"}, Value = TrashGeneral.SilentAim.PriorityMode, Callback = function(v) TrashGeneral.SilentAim.PriorityMode = v end })
TabAim:Dropdown({ Title = "静默方式", Values = {"Raycast","FindPartOnRay","FindPartOnRayWithWhitelist","FindPartOnRayWithIgnoreList","ScreenPointToRay","ViewportPointToRay","Ray","Mouse.Hit/Target"}, Value = TrashGeneral.SilentAim.Method, Callback = function(v) TrashGeneral.SilentAim.Method = v end })
TabAim:Slider({ Title = "命中率", Value = {Min=0,Max=100,Default=TrashGeneral.SilentAim.HitChance}, Rounding=1, Suffix="%", Callback = function(v) TrashGeneral.SilentAim.HitChance = v end })
TabAim:Toggle({ Title = "可见性检查", Value = TrashGeneral.SilentAim.VisibleCheck, Callback = function(v) TrashGeneral.SilentAim.VisibleCheck = v end })
TabAim:Toggle({ Title = "穿墙", Value = TrashGeneral.SilentAim.Wallbang, Callback = function(v) TrashGeneral.SilentAim.Wallbang = v end })
TabAim:Slider({ Title = "最大距离", Value = {Min=10,Max=2000,Default=TrashGeneral.SilentAim.MaxDistance}, Callback = function(v) TrashGeneral.SilentAim.MaxDistance = v end })
TabAim:Toggle({ Title = "显示目标指示器", Value = TrashGeneral.SilentAim.ShowTarget, Callback = function(v) TrashGeneral.SilentAim.ShowTarget = v end })
TabAim:Dropdown({ Title = "指示器样式", Values = {"Circle","十字准星"}, Value = TrashGeneral.SilentAim.IndicatorStyle, Callback = function(v) TrashGeneral.SilentAim.IndicatorStyle = v end })
TabAim:Slider({ Title = "指示器大小", Value = {Min=5,Max=50,Default=TrashGeneral.SilentAim.TargetIndicatorRadius}, Callback = function(v) TrashGeneral.SilentAim.TargetIndicatorRadius = v end })
TabAim:Toggle({ Title = "显示FOV圈", Value = TrashGeneral.SilentAim.FOVVisible, Callback = function(v) TrashGeneral.SilentAim.FOVVisible = v end })
TabAim:Slider({ Title = "FOV范围", Value = {Min=10,Max=1000,Default=TrashGeneral.SilentAim.FOVRadius}, Callback = function(v) TrashGeneral.SilentAim.FOVRadius = v end })

TabESP:Section({ Title = "基础控制", Opened = true })
Controls.ESPEnabled = TabESP:Toggle({ Title = "启用ESP", Value = TrashGeneral.ESP.Enabled, Callback = function(v) ESPManager.SetEnabled(v) end })
TabESP:Slider({ Title = "最大距离", Icon = "ruler", Value = {Min=50,Max=500,Default=TrashGeneral.ESP.MaxDistance}, Step=10, Callback = function(v) TrashGeneral.ESP.MaxDistance = v end })
TabESP:Toggle({ Title = "队伍检测", Value = TrashGeneral.ESP.TeamCheck, Callback = function(v) TrashGeneral.ESP.TeamCheck = v end })
TabESP:Slider({ Title = "字体大小", Value = {Min=8,Max=20,Default=TrashGeneral.ESP.FontSize}, Callback = function(v) TrashGeneral.ESP.FontSize = v end })
TabESP:Divider()
TabESP:Section({ Title = "ESP 元素", Opened = true })
TabESP:Toggle({ Title = "名字", Value = TrashGeneral.ESP.Drawing.Names.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Names.Enabled = v end })
TabESP:Toggle({ Title = "距离", Value = TrashGeneral.ESP.Drawing.Distances.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Distances.Enabled = v end })
TabESP:Dropdown({ Title = "距离位置", Values = {"Text","Bottom"}, Value = TrashGeneral.ESP.Drawing.Distances.Position, Callback = function(v) TrashGeneral.ESP.Drawing.Distances.Position = v end })
TabESP:Toggle({ Title = "武器", Value = TrashGeneral.ESP.Drawing.Weapons.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Weapons.Enabled = v end })
TabESP:Toggle({ Title = "血条", Value = TrashGeneral.ESP.Drawing.Healthbar.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Healthbar.Enabled = v end })
TabESP:Slider({ Title = "血条宽度", Value = {Min=1,Max=8,Default=TrashGeneral.ESP.Drawing.Healthbar.Width}, Step=0.5, Callback = function(v) TrashGeneral.ESP.Drawing.Healthbar.Width = v end })
TabESP:Divider()
TabESP:Section({ Title = "方框设置", Opened = true })
TabESP:Toggle({ Title = "启用方框", Value = TrashGeneral.ESP.Drawing.Boxes.Full.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.Full.Enabled = v end })
TabESP:Toggle({ Title = "填充方框", Value = TrashGeneral.ESP.Drawing.Boxes.Filled.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.Filled.Enabled = v end })
TabESP:Slider({ Title = "填充透明度", Value = {Min=0,Max=1,Default=TrashGeneral.ESP.Drawing.Boxes.Filled.Transparency}, Step=0.05, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.Filled.Transparency = v end })
TabESP:Toggle({ Title = "角框", Value = TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.Corner.Enabled = v end })
TabESP:Toggle({ Title = "动画", Value = TrashGeneral.ESP.Drawing.Boxes.Animate, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.Animate = v end })
TabESP:Slider({ Title = "旋转速度", Value = {Min=0,Max=1000,Default=TrashGeneral.ESP.Drawing.Boxes.RotationSpeed}, Callback = function(v) TrashGeneral.ESP.Drawing.Boxes.RotationSpeed = v end })
TabESP:Divider()
TabESP:Section({ Title = "Chams 设置", Opened = true })
TabESP:Toggle({ Title = "启用Chams", Value = TrashGeneral.ESP.Drawing.Chams.Enabled, Callback = function(v) TrashGeneral.ESP.Drawing.Chams.Enabled = v end })

TabTeleport:Section({ Title = "玩家传送", Opened = true })
local teleportDropdown = TabTeleport:Dropdown({ Title = "选择玩家", Values = {}, Value = "", Callback = function(sel) for _, p in ipairs(Players:GetPlayers()) do if p.Name == sel then TrashGeneral.Teleport.TargetPlayer = p; break end end end })
task.spawn(function() while task.wait(5) do local names = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(names, p.Name) end end; table.sort(names); teleportDropdown:Refresh(names); local cur = teleportDropdown.Value; if cur and not table.find(names, cur) then teleportDropdown:Select(""); TrashGeneral.Teleport.TargetPlayer = nil end end end)
TabTeleport:Button({ Title = "确认传送", Icon = "send", Callback = function() if TrashGeneral.Teleport.TargetPlayer then teleportToPlayer(TrashGeneral.Teleport.TargetPlayer) else WindUI:Notify({Title="传送", Content="请选择玩家"}) end end })
TabTeleport:Toggle({ Title = "锁定玩家到自己", Value = TrashGeneral.Teleport.LockPlayerToMe, Callback = function(v) TrashGeneral.Teleport.LockPlayerToMe = v; if v then startLockPlayer() else stopLockPlayer() end end })
TabTeleport:Toggle({ Title = "平滑传送", Value = TrashGeneral.Teleport.SmoothTeleport, Callback = function(v) TrashGeneral.Teleport.SmoothTeleport = v end })
TabTeleport:Slider({ Title = "传送速度", Value = {Min=50,Max=500,Default=TrashGeneral.Teleport.TweenSpeed}, Callback = function(v) TrashGeneral.Teleport.TweenSpeed = v end })
TabTeleport:Toggle({ Title = "循环吸人", Icon = "users", Value = TrashGeneral.Teleport.SuckAll, Callback = function(v) TrashGeneral.Teleport.SuckAll = v; if v then startSuckAll() else stopSuckAll() end end })

TabOthers:Section({ Title = "游戏信息", Opened = true })
TabOthers:Button({ Title = "复制PlaceID", Icon = "copy", Callback = function() if setclipboard then setclipboard(tostring(game.PlaceId)); WindUI:Notify({Title="复制", Content="已复制"}) end end })
TabOthers:Button({ Title = "复制JobID", Icon = "copy", Callback = function() if setclipboard then setclipboard(game.JobId); WindUI:Notify({Title="复制", Content="已复制"}) end end })
TabOthers:Section({ Title = "服务器跳跃", Opened = true })
local jobInput = TabOthers:Input({ Title = "JobID", Placeholder = "输入目标JobID", Callback = function(v) TrashGeneral.JobIdToJoin = v end })
TabOthers:Button({ Title = "确认加入", Icon = "log-in", Callback = function() if TrashGeneral.JobIdToJoin ~= "" then pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, TrashGeneral.JobIdToJoin, lp) end) end end })
TabOthers:Button({ Title = "切换服务器", Icon = "refresh-cw", Callback = function() pcall(function() ts:Teleport(game.PlaceId) end) end })
TabOthers:Section({ Title = "全局聊天", Opened = true })
TabOthers:Toggle({ Title = "启用全局聊天", Value = true, Callback = function(v) pcall(function() game:GetService("TextChatService").ChatWindowConfiguration.Enabled = v end) end })
TabOthers:Toggle({ Title = "交互无CD", Value = false, Callback = function(v) applyNoPromptCD(v) end })

TabEntertainment:Section({ Title = "旋转", Opened = true })
Controls.RotateToggle = TabEntertainment:Toggle({ Title = "启用旋转", Icon = "rotate-cw", Value = TrashGeneral.Entertainment.Rotate.Enabled, Callback = function(v) TrashGeneral.Entertainment.Rotate.Enabled = v; if v then startRotate() else stopRotate() end end })
TabEntertainment:Slider({ Title = "旋转速度", Icon = "gauge", Value = {Min=360,Max=720,Default=TrashGeneral.Entertainment.Rotate.Speed}, Step=5, Callback = function(v) TrashGeneral.Entertainment.Rotate.Speed = v end })
TabEntertainment:Divider()
TabEntertainment:Section({ Title = "兔子跳", Opened = true })
Controls.BunnyHopToggle = TabEntertainment:Toggle({ Title = "启用兔子跳", Icon = "rabbit", Value = TrashGeneral.Entertainment.BunnyHop.Enabled, Callback = function(v) TrashGeneral.Entertainment.BunnyHop.Enabled = v; if v then startBunnyHop() else stopBunnyHop() end end })
TabEntertainment:Slider({ Title = "加速倍率", Value = {Min=1,Max=5,Default=TrashGeneral.Entertainment.BunnyHop.SpeedBoost}, Step=0.5, Callback = function(v) TrashGeneral.Entertainment.BunnyHop.SpeedBoost = v end })
TabEntertainment:Divider()
TabEntertainment:Section({ Title = "恶搞自己", Opened = true })
Controls.RandomRagdoll = TabEntertainment:Toggle({ Title = "随机摔倒", Value = TrashGeneral.Entertainment.RandomRagdoll, Callback = function(v) TrashGeneral.Entertainment.RandomRagdoll = v; if v then TrashGeneral.Threads.RandomRagdoll = task.spawn(function() while TrashGeneral.Entertainment.RandomRagdoll do local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll); task.wait(0.1); h:ChangeState(Enum.HumanoidStateType.GettingUp) end; task.wait(math.random(30,90)/10) end end) else if TrashGeneral.Threads.RandomRagdoll then task.cancel(TrashGeneral.Threads.RandomRagdoll) end end end })
Controls.ReverseControl = TabEntertainment:Toggle({ Title = "反向控制", Value = TrashGeneral.Entertainment.ReverseControl, Callback = function(v) TrashGeneral.Entertainment.ReverseControl = v; if v then TrashGeneral.Threads.ReverseControl = rs.Heartbeat:Connect(function() local h = hum(); if h then h.MoveDirection = -h.MoveDirection end end) else if TrashGeneral.Threads.ReverseControl then TrashGeneral.Threads.ReverseControl:Disconnect() end end end })
Controls.IceSkating = TabEntertainment:Toggle({ Title = "隐形滑板", Value = TrashGeneral.Entertainment.IceSkating, Callback = function(v) TrashGeneral.Entertainment.IceSkating = v; local c = lp.Character; if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = v and PhysicalProperties.new(0,0,0,0,0) or nil end end end end })

TabConfig:Section({ Title = "全局控制", Opened = true })
TabConfig:Button({ Title = "关闭所有功能", Icon = "power", Callback = disableAll })

rs.RenderStepped:Connect(function()
    if TrashGeneral.SpeedEnabled then local h = hum(); if h then h.WalkSpeed = TrashGeneral.SpeedValue end end
    silentAimRender()
end)

if TrashGeneral.Aimbot.Enabled then toggleAimbot(true) end
if TrashGeneral.Aimbot.ShowFOV then createFOV() end
if TrashGeneral.EnemyVisual.Enabled then toggleEnemyVis(true) end
if TrashGeneral.ESP.Enabled then ESPManager.SetEnabled(true) end
if TrashGeneral.FlyEnabled then startFlight() end
if TrashGeneral.Entertainment.Rotate.Enabled then startRotate() end
if TrashGeneral.Entertainment.BunnyHop.Enabled then startBunnyHop() end
if TrashGeneral.Teleport.SuckAll then startSuckAll() end
if TrashGeneral.Teleport.LockPlayerToMe then startLockPlayer() end
if TrashGeneral.Invisibility.Enabled then toggleInvis(true) end
updateNPCs()
task.spawn(function() while task.wait(10) do updateNPCs() end end)
WindUI:Notify({Title="TrashHub 通用", Content="加载成功", Duration=3, Icon="check"})