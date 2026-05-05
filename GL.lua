if not Drawing then
    _G.Drawing = { new = function() return { Visible = false, Remove = function() end } end }
end

local WasUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/WasUI-For-Roblox/main/test.lua", true))()

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
local ts = game:GetService("TeleportService")
local Players = game:GetService("Players")

local getgenv = getgenv or function() return _G end

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
    SnowEnabled = false;
    Aimbot = {
        Enabled = false; ShowFOV = false; FOVSize = 150;
        CheckObstacles = true; Smooth = false; Speed = 300; Distance = 1000;
    };
    EnemyVisual = {
        Enabled = false;
        Hitbox = { Size = 5; Color = Color3.fromRGB(255,0,0); Transparency = 0.7 };
    };
    SilentAim = {
        Enabled = false; TeamCheck = false; VisibleCheck = false;
        TargetMode = "所有"; TargetPart = "HumanoidRootPart"; Method = "Raycast";
        FOVRadius = 130; FOVVisible = true; ShowTarget = false;
        HitChance = 100; HeadshotChanceEnabled = false; HeadshotChance = 0;
        FixedFOV = true; MaxDistance = 500; PriorityMode = "准星最近";
        Wallbang = false; HighlightEnabled = false;
    };
    ESP = {
        Enabled = false; TeamCheck = true; MaxDistance = 200; FontSize = 11;
        FadeOut = { OnDistance = true };
        Drawing = {
            Names = { Enabled = true };
            Distances = { Enabled = true; Position = "Text" };
            Weapons = { Enabled = true };
            Healthbar = { Enabled = true; Width = 2.5 };
            Boxes = { Full = { Enabled = true }; Filled = { Enabled = true; Transparency = 0.75 }; Corner = { Enabled = true } };
            Chams = { Enabled = true };
        };
    };
    Teleport = {
        TargetPlayer = nil; SmoothTeleport = false; TweenSpeed = 300;
        SuckAll = false; LockPlayerToMe = false;
    };
    Entertainment = {
        Rotate = { Enabled = false; Speed = 30 };
        BunnyHop = { Enabled = false; SpeedBoost = 2 };
        RandomRagdoll = false; ReverseControl = false; IceSkating = false;
    };
    Invisibility = { Enabled = false; Mode = "Client" };
    OtherScript = { CardKey = ""; DamaCardKey = "" };
    JobIdToJoin = "";
    Threads = {};
}
getgenv().TrashGeneral = TrashGeneral

local Controls = {}

local function char() return lp.Character or lp.CharacterAdded:Wait() end
local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = char() return c and c:FindFirstChild("Humanoid") end

local function IsEnemy(p)
    if not p or p == lp then return false end
    if lp.Team and p.Team then if lp.Team == p.Team then return false end end
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
    local hrp = root(); if not hrp or not cam then return nil, nil end
    local fovRad = TrashGeneral.Aimbot.FOVSize
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local closest, closestPos = nil, nil
    local closestDist = fovRad
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
                local speed = math.clamp((TrashGeneral.Aimbot.Speed/500)*0.2, 0.02, 0.2)
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
        local size = TrashGeneral.Aimbot.FOVSize*2
        frame.Size = UDim2.new(0, size, 0, size)
        frame.Position = UDim2.new(0.5, -TrashGeneral.Aimbot.FOVSize, 0.5, -TrashGeneral.Aimbot.FOVSize)
        local _, t = TargetInFOV()
        frame.UIStroke.Color = t and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
    end
end

local function createFOV()
    if fovCircle then pcall(function() fovCircle:Destroy() end) end
    local parent = cg or lp:FindFirstChild("PlayerGui")
    if not parent then return end
    fovCircle = Instance.new("ScreenGui")
    fovCircle.Name = "TrashFOV"; fovCircle.Parent = parent
    fovCircle.ResetOnSpawn = false; fovCircle.Enabled = TrashGeneral.Aimbot.ShowFOV
    local frame = Instance.new("Frame"); frame.Name = "FOVFrame"
    frame.Size = UDim2.new(0, TrashGeneral.Aimbot.FOVSize*2, 0, TrashGeneral.Aimbot.FOVSize*2)
    frame.Position = UDim2.new(0.5, -TrashGeneral.Aimbot.FOVSize, 0.5, -TrashGeneral.Aimbot.FOVSize)
    frame.BackgroundTransparency = 1; frame.Parent = fovCircle
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1,0)
    local stroke = Instance.new("UIStroke", frame); stroke.Thickness = 2; stroke.Transparency = 0.3
    if TrashGeneral.Threads.FOV then task.cancel(TrashGeneral.Threads.FOV) end
    TrashGeneral.Threads.FOV = task.spawn(function()
        while fovCircle and fovCircle.Parent and TrashGeneral.Aimbot.ShowFOV do
            pcall(updateFOV); task.wait(0.1)
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

local enemyVisObjects, enemyVisLoop = {}, nil
local function updateEnemyVis()
    for enemy, d in pairs(enemyVisObjects) do
        if not enemy or not enemy.Parent or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then
            if d.highlight then d.highlight:Destroy() end
            if d.conn then d.conn:Disconnect() end
            if d.rem then d.rem:Disconnect() end
            enemyVisObjects[enemy] = nil
        end
    end
    if not TrashGeneral.EnemyVisual.Enabled then return end
    local all = {}
    for _, p in ipairs(Players:GetPlayers()) do if IsEnemy(p) and p.Character then table.insert(all, p.Character) end end
    for _, e in ipairs(all) do
        if e and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
            if not enemyVisObjects[e] then
                local hl = Instance.new("Highlight"); hl.Adornee = e; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = TrashGeneral.EnemyVisual.Hitbox.Color; hl.FillTransparency = TrashGeneral.EnemyVisual.Hitbox.Transparency
                hl.Parent = e
                local data = { highlight = hl }
                local hum = e:FindFirstChild("Humanoid")
                if hum then
                    data.conn = hum.Died:Connect(function()
                        if data.highlight then data.highlight:Destroy() end
                        enemyVisObjects[e] = nil
                    end)
                end
                data.rem = e.AncestryChanged:Connect(function()
                    if not e.Parent then if data.highlight then data.highlight:Destroy() end; enemyVisObjects[e] = nil end
                end)
                enemyVisObjects[e] = data
            else
                local d = enemyVisObjects[e]
                if d.highlight then
                    d.highlight.FillColor = TrashGeneral.EnemyVisual.Hitbox.Color
                    d.highlight.FillTransparency = TrashGeneral.EnemyVisual.Hitbox.Transparency
                end
            end
        end
    end
end

local function startEnemyVisLoop()
    if enemyVisLoop then task.cancel(enemyVisLoop) end
    enemyVisLoop = task.spawn(function()
        while TrashGeneral.EnemyVisual.Enabled do pcall(updateEnemyVis); task.wait(0.2) end
        for _, d in pairs(enemyVisObjects) do if d.highlight then d.highlight:Destroy() end end
        enemyVisObjects = {}
    end)
end

local function toggleEnemyVis(state)
    TrashGeneral.EnemyVisual.Enabled = state
    if state then startEnemyVisLoop() else
        if enemyVisLoop then task.cancel(enemyVisLoop); enemyVisLoop = nil end
        for _, d in pairs(enemyVisObjects) do if d.highlight then d.highlight:Destroy() end end
        enemyVisObjects = {}
    end
end

local flightConn
local function startFlight()
    if flightConn then flightConn:Disconnect() end
    local c = lp.Character; if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid"); local hd = c:FindFirstChild("Head")
    if not h or not hd then return end
    h.PlatformStand = true; hd.Anchored = true
    flightConn = rs.Heartbeat:Connect(function(dt)
        if not TrashGeneral.FlyEnabled or not lp.Character then stopFlight(); return end
        local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid")
        local head = char and char:FindFirstChild("Head")
        if not hum or not head then stopFlight(); return end
        local moveDir = hum.MoveDirection * (TrashGeneral.FlySpeed * dt * 50)
        local headCF = head.CFrame; local camCF = cam.CFrame
        local offset = headCF:ToObjectSpace(camCF).Position
        camCF = camCF * CFrame.new(-offset.X, -offset.Y, -offset.Z + 1)
        local objSpace = CFrame.new(camCF.Position, Vector3.new(headCF.X, camCF.Y, headCF.Z)):VectorToObjectSpace(moveDir)
        head.CFrame = CFrame.new(headCF.Position) * (camCF - camCF.Position) * CFrame.new(objSpace)
    end)
end
local function stopFlight()
    if flightConn then flightConn:Disconnect(); flightConn = nil end
    local c = lp.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
        local hd = c:FindFirstChild("Head")
        if hd then hd.Anchored = false end
    end
end

local rotateThread
local function startRotate()
    if rotateThread then task.cancel(rotateThread) end
    rotateThread = task.spawn(function()
        local last = os.clock()
        while TrashGeneral.Entertainment.Rotate.Enabled do
            local now = os.clock(); local dt = now - last; last = now
            local sp = TrashGeneral.Entertainment.Rotate.Speed
            if sp > 0 and dt > 0 then
                local hrp = root()
                if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(sp * dt), 0) end
            end
            task.wait()
        end
    end)
end
local function stopRotate() if rotateThread then task.cancel(rotateThread); rotateThread = nil end end

local bunnyHopThread
local origWalkSpeed = 16
local function startBunnyHop()
    if bunnyHopThread then task.cancel(bunnyHopThread) end
    bunnyHopThread = task.spawn(function()
        local lastJump = 0
        while TrashGeneral.Entertainment.BunnyHop.Enabled do
            local h = hum(); local hrp = root()
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
        local h = hum(); if h then h.WalkSpeed = origWalkSpeed end
    end)
end
local function stopBunnyHop()
    if bunnyHopThread then task.cancel(bunnyHopThread); bunnyHopThread = nil end
    local h = hum(); if h then h.WalkSpeed = origWalkSpeed end
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
local function stopSuckAll() if suckAllThread then task.cancel(suckAllThread); suckAllThread = nil end end

local lockPlayerThread
local function startLockPlayer()
    if lockPlayerThread then task.cancel(lockPlayerThread) end
    lockPlayerThread = task.spawn(function()
        while TrashGeneral.Teleport.LockPlayerToMe do
            local myRoot = root(); local target = TrashGeneral.Teleport.TargetPlayer
            if myRoot and target then
                local tchar = target.Character
                if tchar then
                    local trp = tchar:FindFirstChild("HumanoidRootPart")
                    if trp then trp.CFrame = myRoot.CFrame * CFrame.new(10, 5, 0) end
                end
            end
            task.wait()
        end
    end)
end
local function stopLockPlayer() if lockPlayerThread then task.cancel(lockPlayerThread); lockPlayerThread = nil end end

local ESPManager = {}
do
    local ScreenGui, Connections = nil, {}
    local function Create(cls, props) local inst = typeof(cls)=='string' and Instance.new(cls) or cls; for k,v in pairs(props) do inst[k]=v end; return inst end
    local function CreateESP(plr)
        if not ScreenGui or Connections[plr] then return end
        local Name = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,-11), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1), Font=Enum.Font.Code, TextSize=11, RichText=true})
        local Dist = Create("TextLabel", {Parent=ScreenGui, Position=UDim2.new(0.5,0,0,11), Size=UDim2.new(0,100,0,20), AnchorPoint=Vector2.new(0.5,0.5), BackgroundTransparency=1, TextColor3=Color3.new(1,1,1), Font=Enum.Font.Code, TextSize=11})
        local Box = Create("Frame", {Parent=ScreenGui, BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.75, BorderSizePixel=0})
        local Outline = Create("UIStroke", {Parent=Box, Color=Color3.new(1,1,1), LineJoinMode=Enum.LineJoinMode.Miter})
        Connections[plr] = rs.RenderStepped:Connect(function()
            if not TrashGeneral.ESP.Enabled then Box.Visible,Name.Visible,Dist.Visible = false,false,false; return end
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local HRP = plr.Character.HumanoidRootPart
                local hum = plr.Character:FindFirstChild("Humanoid"); if not hum then return end
                local pos, on = cam:WorldToScreenPoint(HRP.Position)
                if on then
                    local dist = (cam.CFrame.Position - HRP.Position).Magnitude/3.57
                    if dist <= TrashGeneral.ESP.MaxDistance then
                        local s = HRP.Size.Y; local scale = (s*cam.ViewportSize.Y)/(pos.Z*2); local w,h = 3*scale, 4.5*scale
                        Box.Position = UDim2.new(0,pos.X-w/2,0,pos.Y-h/2); Box.Size = UDim2.new(0,w,0,h); Box.Visible = true
                        if TrashGeneral.ESP.Drawing.Names.Enabled then Name.Position = UDim2.new(0,pos.X,0,pos.Y-h/2-9); Name.Text = plr.Name; Name.Visible = true end
                        if TrashGeneral.ESP.Drawing.Distances.Enabled then Dist.Position = UDim2.new(0,pos.X,0,pos.Y+h/2+7); Dist.Text = math.floor(dist).."m"; Dist.Visible = true end
                    else Box.Visible,Name.Visible,Dist.Visible = false,false,false end
                else Box.Visible,Name.Visible,Dist.Visible = false,false,false end
            else Box.Visible,Name.Visible,Dist.Visible = false,false,false end
        end)
    end
    function ESPManager.Start()
        if ScreenGui then return end
        ScreenGui = Create("ScreenGui", {Parent=cg, Name="Trash_ESPHolder"})
        for _, v in ipairs(Players:GetPlayers()) do if v ~= lp then CreateESP(v) end end
        Connections.PlayerAdded = Players.PlayerAdded:Connect(function(v) if v ~= lp then CreateESP(v) end end)
    end
    function ESPManager.Stop()
        if ScreenGui then ScreenGui:Destroy(); ScreenGui = nil end
        for _, c in pairs(Connections) do if type(c)=="table" then for _,v in ipairs(c) do v:Disconnect() end else c:Disconnect() end end
        Connections = {}
    end
    function ESPManager.SetEnabled(v) TrashGeneral.ESP.Enabled = v; if v then ESPManager.Start() else ESPManager.Stop() end end
end

local function teleportToPlayer(target)
    if not target then return end
    local tchar = target.Character
    if not tchar then local timeout = 0; while not tchar and timeout < 5 do task.wait(0.1); tchar = target.Character; timeout+=0.1 end end
    if not tchar then WasUI:Notify({Title="传送",Content="目标玩家未加载",Duration=2}); return end
    local trp = tchar:FindFirstChild("HumanoidRootPart") or tchar:FindFirstChild("Head")
    if not trp then WasUI:Notify({Title="传送",Content="无可用根部件",Duration=2}); return end
    if TrashGeneral.Teleport.SmoothTeleport then
        local hrp = root(); if not hrp then return end
        local dist = (hrp.Position - trp.Position).Magnitude
        local tw = tween:Create(hrp, TweenInfo.new(dist/TrashGeneral.Teleport.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = trp.CFrame}); tw:Play()
    else
        local hrp = root(); if hrp then hrp.CFrame = trp.CFrame end
    end
    WasUI:Notify({Title="传送",Content="已传送至 "..target.Name, Duration=2})
end

local invisThread, invisPlatform
local function startInvis()
    local mode = TrashGeneral.Invisibility.Mode
    local c = lp.Character; if not c then return end
    if mode == "Client" then
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 1 end end
    elseif mode == "CFrame" then
        local hrp = root(); if hrp then hrp.CFrame = CFrame.new(hrp.Position.X, -1000, hrp.Position.Z) end
        local h = hum(); if h then h.PlatformStand = true end
        if invisPlatform then invisPlatform:Destroy() end
        invisPlatform = Instance.new("Part"); invisPlatform.Size = Vector3.new(5,0.5,5); invisPlatform.Anchored = true; invisPlatform.Transparency = 1; invisPlatform.Parent = ws
        if invisThread then task.cancel(invisThread) end
        invisThread = task.spawn(function()
            while TrashGeneral.Invisibility.Enabled and TrashGeneral.Invisibility.Mode == "CFrame" do
                local hrp = root(); if hrp then invisPlatform.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y-2, hrp.Position.Z) end
                task.wait(0.05)
            end
        end)
    end
end
local function stopInvis()
    if TrashGeneral.Invisibility.Mode == "Client" then
        local c = lp.Character; if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end end end
    elseif TrashGeneral.Invisibility.Mode == "CFrame" then
        local h = hum(); if h then h.PlatformStand = false end
        if invisPlatform then invisPlatform:Destroy(); invisPlatform = nil end
        if invisThread then task.cancel(invisThread); invisThread = nil end
    end
end
local function toggleInvis(state)
    TrashGeneral.Invisibility.Enabled = state
    if state then startInvis() else stopInvis() end
end

local currentTargetPart
local function getTarget()
    local c = lp.Character; if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local localRoot = c.HumanoidRootPart
    local candidates = {}
    local tmode = TrashGeneral.SilentAim.TargetMode
    local function process(model)
        if TrashGeneral.SilentAim.TeamCheck and model.Team and model.Team == lp.Team then return end
        local hum = model:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
        local part = model:FindFirstChild(TrashGeneral.SilentAim.TargetPart) or model:FindFirstChild("HumanoidRootPart")
        if not part then return end
        if TrashGeneral.SilentAim.VisibleCheck then
            local origin = cam.CFrame.Position; local dir = part.Position - origin
            local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {c, part.Parent}
            if ws:Raycast(origin, dir.Unit * dir.Magnitude, rp) then return end
        end
        local dist = (localRoot.Position - part.Position).Magnitude
        if dist > TrashGeneral.SilentAim.MaxDistance then return end
        table.insert(candidates, {model=model, part=part, dist=dist, health=hum.Health})
    end
    if tmode == "玩家" or tmode == "所有" then for _, p in ipairs(Players:GetPlayers()) do if p ~= lp and p.Character then process(p.Character) end end end
    if tmode == "NPC" or tmode == "所有" then
        for _, v in ipairs(ws:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(v) then process(v) end
        end
    end
    if #candidates == 0 then return nil end
    table.sort(candidates, function(a,b)
        local pri = TrashGeneral.SilentAim.PriorityMode
        if pri == "最低血量" then return a.health < b.health
        elseif pri == "距离最近" then return a.dist < b.dist end
        return a.dist < b.dist
    end)
    return candidates[1].part
end

local oldNamecall, oldIndex, oldRayNew
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local method = getnamecallmethod(); local args = {...}; local self = args[1]
    if TrashGeneral.SilentAim.Enabled and not checkcaller() and math.random() <= TrashGeneral.SilentAim.HitChance/100 and currentTargetPart then
        local curMethod = TrashGeneral.SilentAim.Method
        if (method == "FindPartOnRayWithIgnoreList" and curMethod == method) or
           (method == "FindPartOnRayWithWhitelist" and curMethod == method) or
           ((method == "FindPartOnRay" or method == "findPartOnRay") and curMethod:lower() == method:lower()) then
            if args[2] and args[2].Origin then
                if TrashGeneral.SilentAim.Wallbang then return currentTargetPart, currentTargetPart.Position end
                local dir = (currentTargetPart.Position - args[2].Origin).Unit * 1000
                args[2] = Ray.new(args[2].Origin, dir)
                return oldNamecall(unpack(args))
            end
        elseif method == "Raycast" and curMethod == method then
            if args[2] and args[3] then
                if TrashGeneral.SilentAim.Wallbang then
                    local dir = (currentTargetPart.Position - args[2]).Unit * 1000
                    local wp = RaycastParams.new(); wp.FilterType = Enum.RaycastFilterType.Include; wp.FilterDescendantsInstances = {currentTargetPart.Parent}
                    return oldNamecall(args[1], args[2], dir, wp)
                end
                args[3] = (currentTargetPart.Position - args[2]).Unit * 1000
                return oldNamecall(unpack(args))
            end
        elseif (method == "ScreenPointToRay" or method == "ViewportPointToRay") and curMethod == method and self == cam then
            return Ray.new(cam.CFrame.Position, (currentTargetPart.Position - cam.CFrame.Position).Unit)
        end
    end
    return oldNamecall(...)
end))

oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, idx)
    if self == lp:GetMouse() and not checkcaller() and TrashGeneral.SilentAim.Enabled and TrashGeneral.SilentAim.Method == "Mouse.Hit/Target" and currentTargetPart then
        if idx:lower() == "hit" then return currentTargetPart.CFrame end
    end
    return oldIndex(self, idx)
end))

oldRayNew = hookfunction(Ray.new, newcclosure(function(origin, direction)
    if TrashGeneral.SilentAim.Enabled and TrashGeneral.SilentAim.Method == "Ray" and currentTargetPart and not checkcaller() and math.random() <= TrashGeneral.SilentAim.HitChance/100 then
        return oldRayNew(origin, (currentTargetPart.Position - origin).Unit * 1000)
    end
    return oldRayNew(origin, direction)
end))

local function disableAll()
    TrashGeneral.FlyEnabled = false; stopFlight()
    TrashGeneral.SpeedEnabled = false; local h = hum(); if h then h.WalkSpeed = 16 end
    TrashGeneral.HighJumpEnabled = false; h = hum(); if h then h.JumpPower = 50 end
    ESPManager.SetEnabled(false); toggleEnemyVis(false)
    stopRotate(); stopBunnyHop(); stopSuckAll(); stopLockPlayer()
    toggleAimbot(false); TrashGeneral.SilentAim.Enabled = false
    toggleInvis(false)
    if TrashGeneral.Threads.InfJump then TrashGeneral.Threads.InfJump:Disconnect() end
    if TrashGeneral.Threads.RandomRagdoll then task.cancel(TrashGeneral.Threads.RandomRagdoll) end
    if TrashGeneral.Threads.ReverseControl then TrashGeneral.Threads.ReverseControl:Disconnect() end
end

local cfg = WasUI:CreateFolder("TrashHub_Config")

local titleTags = {
    { text = "1.0", backgroundColor = Color3.fromRGB(0,152,211), textColor = Color3.fromRGB(255,255,255) },
}
local mainWindow = WasUI:CreateWindow("TrashHub 通用", nil, nil, nil, nil, titleTags)
mainWindow:SetMinimizedText("TrashHub")

local tabCharacters = mainWindow:AddTab("人物")
local tabEnvironment = mainWindow:AddTab("环境")
local tabAim = mainWindow:AddTab("瞄准")
local tabESP = mainWindow:AddTab("ESP")
local tabTeleport = mainWindow:AddTab("传送")
local tabOthers = mainWindow:AddTab("其他")
local tabEntertainment = mainWindow:AddTab("娱乐")
local tabConfig = mainWindow:AddTab("配置")

WasUI:CreateCategory(tabCharacters, "移动辅助")
Controls.FlightToggle = WasUI:CreateToggle(tabCharacters, TrashGeneral.FlyEnabled, function(s) TrashGeneral.FlyEnabled = s; if s then startFlight() else stopFlight() end end, "飞行")
WasUI:CreateSlider(tabCharacters, "飞行速度", 1, 10, TrashGeneral.FlySpeed, function(v) TrashGeneral.FlySpeed = v end)

Controls.SpeedToggle = WasUI:CreateToggle(tabCharacters, TrashGeneral.SpeedEnabled, function(s) TrashGeneral.SpeedEnabled = s; local h = hum(); if h then h.WalkSpeed = s and TrashGeneral.SpeedValue or 16 end end, "加速")
WasUI:CreateSlider(tabCharacters, "加速速度", 16, 200, TrashGeneral.SpeedValue, function(v) TrashGeneral.SpeedValue = v; if TrashGeneral.SpeedEnabled then local h = hum(); if h then h.WalkSpeed = v end end end)

Controls.HighJumpToggle = WasUI:CreateToggle(tabCharacters, TrashGeneral.HighJumpEnabled, function(s)
    TrashGeneral.HighJumpEnabled = s; local h = hum()
    if h then
        if s then
            h.JumpPower = TrashGeneral.JumpPower
            if not TrashGeneral.Threads.HighJump then TrashGeneral.Threads.HighJump = h.Jumping:Connect(function() h.JumpPower = TrashGeneral.JumpPower end) end
        else
            h.JumpPower = 50; if TrashGeneral.Threads.HighJump then TrashGeneral.Threads.HighJump:Disconnect(); TrashGeneral.Threads.HighJump = nil end
        end
    end
end, "高跳")
WasUI:CreateSlider(tabCharacters, "跳跃高度", 30, 200, TrashGeneral.JumpPower, function(v) TrashGeneral.JumpPower = v; if TrashGeneral.HighJumpEnabled then local h = hum(); if h then h.JumpPower = v end end end)

Controls.InfJumpToggle = WasUI:CreateToggle(tabCharacters, false, function(s)
    TrashGeneral.InfJump = s
    if s then
        TrashGeneral.Threads.InfJump = uis.JumpRequest:Connect(function()
            if TrashGeneral.InfJump then local h = hum(); if h and h:GetState() == Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
        end)
    else
        if TrashGeneral.Threads.InfJump then TrashGeneral.Threads.InfJump:Disconnect() end
    end
end, "无限跳跃")

WasUI:CreateCategory(tabCharacters, "防护")
Controls.AntiRagdoll = WasUI:CreateToggle(tabCharacters, TrashGeneral.AntiRagdoll, function(s) TrashGeneral.AntiRagdoll = s; if s then local h = hum(); if h then h.StateChanged:Connect(function(_, n) if n == Enum.HumanoidStateType.Ragdoll then h:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end end end, "反布娃娃")
Controls.AntiAFK = WasUI:CreateToggle(tabCharacters, TrashGeneral.AntiAFK, function(s)
    TrashGeneral.AntiAFK = s
    if s then TrashGeneral.Threads.AntiAFK = task.spawn(function() while TrashGeneral.AntiAFK do pcall(function() vu:Button2Down(Vector2.new(0,0), cam.CFrame); task.wait(1); vu:Button2Up(Vector2.new(0,0), cam.CFrame); task.wait(60) end) end end)
    else if TrashGeneral.Threads.AntiAFK then task.cancel(TrashGeneral.Threads.AntiAFK) end end
end, "反挂机")

WasUI:CreateCategory(tabCharacters, "隐身")
Controls.InvisToggle = WasUI:CreateToggle(tabCharacters, TrashGeneral.Invisibility.Enabled, toggleInvis, "启用隐身")
local invisDropdown = WasUI:CreateDropdown(tabCharacters, "隐身模式", {"Client","CFrame"}, TrashGeneral.Invisibility.Mode, function(v) TrashGeneral.Invisibility.Mode = v; if TrashGeneral.Invisibility.Enabled then stopInvis(); startInvis() end end)

WasUI:CreateCategory(tabEnvironment, "视觉增强")
WasUI:CreateToggle(tabEnvironment, TrashGeneral.NightVision, function(s) TrashGeneral.NightVision = s; lighting.Ambient = s and Color3.new(1,1,1) or Color3.new(0,0,0); lighting.Brightness = s and 2 or 0.5 end, "夜视")
WasUI:CreateToggle(tabEnvironment, TrashGeneral.RemoveShadows, function(s) TrashGeneral.RemoveShadows = s; lighting.GlobalShadows = not s end, "删除阴影")
WasUI:CreateButton(tabEnvironment, "删除纹理", function() pcall(function() for _, v in ipairs(ws:GetDescendants()) do if v:IsA("Part") or v:IsA("MeshPart") then v.Material = "SmoothPlastic" end end end) end)
WasUI:CreateButton(tabEnvironment, "删除天空盒", function() pcall(function() if lighting.Sky then lighting.Sky:Destroy() end end) end)

WasUI:CreateCategory(tabEnvironment, "时间调节")
local timeDropdown = WasUI:CreateDropdown(tabEnvironment, "修改时间", {"8:00","12:00","18:00","24:00"}, TrashGeneral.SelectedTime, function(v) TrashGeneral.SelectedTime = v end)
WasUI:CreateButton(tabEnvironment, "确认修改时间", function() local h = tonumber(TrashGeneral.SelectedTime:match("(%d+):")); if h then lighting.TimeOfDay = string.format("%02d:00:00", h) end end)

WasUI:CreateCategory(tabAim, "普通自瞄")
Controls.AimbotToggle = WasUI:CreateToggle(tabAim, TrashGeneral.Aimbot.Enabled, toggleAimbot, "自动瞄准")
Controls.FOVToggle = WasUI:CreateToggle(tabAim, TrashGeneral.Aimbot.ShowFOV, toggleFOV, "显示FOV圈")
WasUI:CreateSlider(tabAim, "FOV大小", 30, 500, TrashGeneral.Aimbot.FOVSize, function(v) TrashGeneral.Aimbot.FOVSize = v; if TrashGeneral.Aimbot.ShowFOV then createFOV() end end)
WasUI:CreateToggle(tabAim, TrashGeneral.Aimbot.CheckObstacles, function(s) TrashGeneral.Aimbot.CheckObstacles = s end, "掩体判断")
WasUI:CreateToggle(tabAim, TrashGeneral.Aimbot.Smooth, function(s) TrashGeneral.Aimbot.Smooth = s end, "平滑自瞄")
WasUI:CreateSlider(tabAim, "自瞄速度", 100, 500, TrashGeneral.Aimbot.Speed, function(v) TrashGeneral.Aimbot.Speed = v end)
WasUI:CreateSlider(tabAim, "自瞄距离", 100, 5000, TrashGeneral.Aimbot.Distance, function(v) TrashGeneral.Aimbot.Distance = v end)

WasUI:CreateCategory(tabAim, "敌人视觉辅助")
Controls.EnemyVisToggle = WasUI:CreateToggle(tabAim, TrashGeneral.EnemyVisual.Enabled, toggleEnemyVis, "启用")
WasUI:CreateSlider(tabAim, "Hitbox大小", 1, 20, TrashGeneral.EnemyVisual.Hitbox.Size, function(v) TrashGeneral.EnemyVisual.Hitbox.Size = v end)
WasUI:CreateSlider(tabAim, "Hitbox透明度", 0, 1, TrashGeneral.EnemyVisual.Hitbox.Transparency, function(v) TrashGeneral.EnemyVisual.Hitbox.Transparency = v end)

WasUI:CreateCategory(tabAim, "静默自瞄")
Controls.SilentAimToggle = WasUI:CreateToggle(tabAim, TrashGeneral.SilentAim.Enabled, function(s) TrashGeneral.SilentAim.Enabled = s end, "启用静默自瞄")
WasUI:CreateDropdown(tabAim, "目标种类", {"玩家","NPC","所有"}, TrashGeneral.SilentAim.TargetMode, function(v) TrashGeneral.SilentAim.TargetMode = v end)
WasUI:CreateDropdown(tabAim, "目标部位", {"Head","HumanoidRootPart"}, TrashGeneral.SilentAim.TargetPart, function(v) TrashGeneral.SilentAim.TargetPart = v end)
WasUI:CreateDropdown(tabAim, "优先模式", {"准星最近","距离最近","最低血量","最近的人(无FOV)"}, TrashGeneral.SilentAim.PriorityMode, function(v) TrashGeneral.SilentAim.PriorityMode = v end)
WasUI:CreateDropdown(tabAim, "静默方式", {"Raycast","FindPartOnRay","ScreenPointToRay","ViewportPointToRay","Ray","Mouse.Hit/Target"}, TrashGeneral.SilentAim.Method, function(v) TrashGeneral.SilentAim.Method = v end)
WasUI:CreateSlider(tabAim, "命中率", 0, 100, TrashGeneral.SilentAim.HitChance, function(v) TrashGeneral.SilentAim.HitChance = v end)
WasUI:CreateToggle(tabAim, TrashGeneral.SilentAim.VisibleCheck, function(s) TrashGeneral.SilentAim.VisibleCheck = s end, "可见性检查")
WasUI:CreateToggle(tabAim, TrashGeneral.SilentAim.Wallbang, function(s) TrashGeneral.SilentAim.Wallbang = s end, "穿墙")

WasUI:CreateCategory(tabESP, "基础控制")
Controls.ESPToggle = WasUI:CreateToggle(tabESP, TrashGeneral.ESP.Enabled, function(s) ESPManager.SetEnabled(s) end, "启用ESP")
WasUI:CreateSlider(tabESP, "最大距离", 50, 500, TrashGeneral.ESP.MaxDistance, function(v) TrashGeneral.ESP.MaxDistance = v end)

WasUI:CreateCategory(tabTeleport, "玩家传送")
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(playerNames, p.Name) end end
Controls.TeleportDropdown = WasUI:CreateDropdown(tabTeleport, "选择玩家", playerNames, "无", function(sel)
    for _, p in ipairs(Players:GetPlayers()) do if p.Name == sel then TrashGeneral.Teleport.TargetPlayer = p; break end end
end)
task.spawn(function() while task.wait(5) do local names = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(names, p.Name) end end; Controls.TeleportDropdown:UpdateOptions(names, Controls.TeleportDropdown.SelectedValue) end end)
WasUI:CreateButton(tabTeleport, "确认传送", function() if TrashGeneral.Teleport.TargetPlayer then teleportToPlayer(TrashGeneral.Teleport.TargetPlayer) else WasUI:Notify({Title="提示",Content="请选择玩家",Duration=2}) end end)
Controls.LockPlayerToggle = WasUI:CreateToggle(tabTeleport, false, function(s) TrashGeneral.Teleport.LockPlayerToMe = s; if s then startLockPlayer() else stopLockPlayer() end end, "锁定玩家到自己")
WasUI:CreateToggle(tabTeleport, TrashGeneral.Teleport.SmoothTeleport, function(s) TrashGeneral.Teleport.SmoothTeleport = s end, "平滑传送")
WasUI:CreateSlider(tabTeleport, "传送速度", 50, 500, TrashGeneral.Teleport.TweenSpeed, function(v) TrashGeneral.Teleport.TweenSpeed = v end)
Controls.SuckAllToggle = WasUI:CreateToggle(tabTeleport, TrashGeneral.Teleport.SuckAll, function(s) TrashGeneral.Teleport.SuckAll = s; if s then startSuckAll() else stopSuckAll() end end, "循环吸人")

WasUI:CreateCategory(tabOthers, "游戏信息")
WasUI:CreateButton(tabOthers, "复制PlaceID", function() if setclipboard then setclipboard(tostring(game.PlaceId)) end end)
WasUI:CreateButton(tabOthers, "复制JobID", function() if setclipboard then setclipboard(game.JobId) end end)

WasUI:CreateCategory(tabOthers, "服务器跳跃")
Controls.JobInput = WasUI:CreateTextInput(tabOthers, "输入目标JobID", "", function(v) TrashGeneral.JobIdToJoin = v end)
WasUI:CreateButton(tabOthers, "确认加入", function() if TrashGeneral.JobIdToJoin ~= "" then pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, TrashGeneral.JobIdToJoin, lp) end) end end)
WasUI:CreateButton(tabOthers, "切换服务器", function() pcall(function() ts:Teleport(game.PlaceId) end) end)

WasUI:CreateCategory(tabOthers, "实用设置")
Controls.GlobalChatToggle = WasUI:CreateToggle(tabOthers, true, function(s) pcall(function() game:GetService("TextChatService").ChatWindowConfiguration.Enabled = s end) end, "启用全局聊天")
Controls.NoPromptCDToggle = WasUI:CreateToggle(tabOthers, false, function(s) TrashGeneral.NoPromptCD = s; for _, obj in ipairs(ws:GetDescendants()) do if obj:IsA("ProximityPrompt") then obj.HoldDuration = s and 0 or 0.5 end end end, "交互无CD")

WasUI:CreateCategory(tabEntertainment, "旋转")
Controls.RotateToggle = WasUI:CreateToggle(tabEntertainment, TrashGeneral.Entertainment.Rotate.Enabled, function(s) TrashGeneral.Entertainment.Rotate.Enabled = s; if s then startRotate() else stopRotate() end end, "启用旋转")
WasUI:CreateSlider(tabEntertainment, "旋转速度", 360, 720, TrashGeneral.Entertainment.Rotate.Speed, function(v) TrashGeneral.Entertainment.Rotate.Speed = v end)

WasUI:CreateCategory(tabEntertainment, "兔子跳")
Controls.BunnyHopToggle = WasUI:CreateToggle(tabEntertainment, TrashGeneral.Entertainment.BunnyHop.Enabled, function(s) TrashGeneral.Entertainment.BunnyHop.Enabled = s; if s then startBunnyHop() else stopBunnyHop() end end, "启用兔子跳")
WasUI:CreateSlider(tabEntertainment, "加速倍率", 1, 5, TrashGeneral.Entertainment.BunnyHop.SpeedBoost, function(v) TrashGeneral.Entertainment.BunnyHop.SpeedBoost = v end)

WasUI:CreateCategory(tabEntertainment, "恶搞自己")
Controls.RandomRagdollToggle = WasUI:CreateToggle(tabEntertainment, false, function(s)
    TrashGeneral.Entertainment.RandomRagdoll = s
    if s then TrashGeneral.Threads.RandomRagdoll = task.spawn(function() while TrashGeneral.Entertainment.RandomRagdoll do local h = hum(); if h then h:ChangeState(Enum.HumanoidStateType.Ragdoll); task.wait(0.1); h:ChangeState(Enum.HumanoidStateType.GettingUp) end; task.wait(math.random(30,90)/10) end end)
    else if TrashGeneral.Threads.RandomRagdoll then task.cancel(TrashGeneral.Threads.RandomRagdoll) end end
end, "随机摔倒")
Controls.ReverseControlToggle = WasUI:CreateToggle(tabEntertainment, false, function(s)
    TrashGeneral.Entertainment.ReverseControl = s
    if s then TrashGeneral.Threads.ReverseControl = rs.Heartbeat:Connect(function() local h = hum(); if h then h.MoveDirection = -h.MoveDirection end end)
    else if TrashGeneral.Threads.ReverseControl then TrashGeneral.Threads.ReverseControl:Disconnect() end end
end, "反向控制")
Controls.IceSkatingToggle = WasUI:CreateToggle(tabEntertainment, false, function(s)
    TrashGeneral.Entertainment.IceSkating = s; local c = lp.Character
    if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CustomPhysicalProperties = s and PhysicalProperties.new(0,0,0,0,0) or nil end end end
end, "隐形滑板")

WasUI:CreateCategory(tabConfig, "全局控制")
WasUI:CreateButton(tabConfig, "关闭所有功能", disableAll)

task.spawn(function()
    rs.RenderStepped:Connect(function()
        if TrashGeneral.SpeedEnabled then local h = hum(); if h then h.WalkSpeed = TrashGeneral.SpeedValue end end
        if TrashGeneral.SilentAim.Enabled then currentTargetPart = getTarget() end
        aimLoop()
    end)
end)

task.spawn(function()
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
end)

WasUI:Notify({Title="TrashHub 通用", Content="加载成功", Duration=3})