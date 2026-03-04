-- 加载WindUI库
local WindUI = (function()
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/tnine-n9/tnine-public/refs/heads/main/wind%20ui%E6%BA%90%E7%A0%81.lua", true))()
    end)
    if success then
        return result
    else
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/tnine-n9/tnine-public/main/wind%20ui%E6%BA%90%E7%A0%81.lua", true))()
    end
end)()

local Window = WindUI:CreateWindow({
    Title = "<font color='#ffaa00'>QW </font>无限提升模拟器",
    Author = "Was",
    Folder = "UnlimitedBoostQW",
    Size = UDim2.fromOffset(280, 480),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 100,
    ScrollBarEnabled = true,
    Background = "https://chaton-images.s3.us-east-2.amazonaws.com/o7hkoAxrjanwZ1BaDWuAXj6cJ0VNtkTTtHBjBfG6HpiuD4X1jR6X9V6PJmpGsCMV_1920x1080x683842.jpeg",
    BackgroundImageTransparency = 0.5,
})

Window:EditOpenButton({
    Title = "<font color='#ffaa00'>QW </font><font color='#ffffff'>Hub</font>",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 2.5,
    Color = ColorSequence.new(Color3.fromHex("#ffaa00"), Color3.fromHex("#ffdd44")),
    Draggable = true,
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

getgenv().SpeedEnabled = getgenv().SpeedEnabled or false
getgenv().FlyEnabled = getgenv().FlyEnabled or false
getgenv().SpeedMultiplier = getgenv().SpeedMultiplier or 2
getgenv().NoCdEnabled = getgenv().NoCdEnabled or false
getgenv().UnlockFreePasses = getgenv().UnlockFreePasses or false
getgenv().AutoSellEnabled = getgenv().AutoSellEnabled or false

getgenv().speedThread = nil
getgenv().flyThread = nil
getgenv().noCdThread = nil
getgenv().freePassThread = nil
getgenv().autoSellThread = nil

local DEFAULT_WALKSPEED = 16

-- 传送坐标
local TELEPORT_POINTS = {
    {name = "1M区域", pos = Vector3.new(431.824097, 7700, -9198.71191)},
    {name = "1Qa区域", pos = Vector3.new(-855.989563, 7700, -5630.15234)},
    {name = "1Ud区域", pos = Vector3.new(665.773254, 7700, -2080.26489)},
    {name = "1Qid区域", pos = Vector3.new(-253.345215, 7700, 3090.95068)},
    {name = "1Ttg区域", pos = Vector3.new(-1050.72705, 7700, 9373.91797)}
}

local function getSellRemote()
    return ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Sell")
end

local function toggleSpeed(state)
    getgenv().SpeedEnabled = state
    if state then
        if getgenv().speedThread then task.cancel(getgenv().speedThread) end
        getgenv().speedThread = task.spawn(function()
            while getgenv().SpeedEnabled do
                local char = Player.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = DEFAULT_WALKSPEED * getgenv().SpeedMultiplier
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        if getgenv().speedThread then
            task.cancel(getgenv().speedThread)
            getgenv().speedThread = nil
        end
        local char = Player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = DEFAULT_WALKSPEED
            end
        end
    end
end

local function toggleFly(state)
    getgenv().FlyEnabled = state
    if state then
        if getgenv().flyThread then task.cancel(getgenv().flyThread) end
        getgenv().flyThread = task.spawn(function()
            local controlModule = Player.PlayerScripts and Player.PlayerScripts:FindFirstChild('PlayerModule')
            if not controlModule then return end
            controlModule = require(controlModule:WaitForChild("ControlModule"))
            
            local char = Player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            local hrp = char.HumanoidRootPart
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "VelocityHandler"
            bv.Parent = hrp
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            local bg = Instance.new("BodyGyro")
            bg.Name = "GyroHandler"
            bg.Parent = hrp
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 1000
            bg.D = 50
            
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = true end
            
            while getgenv().FlyEnabled do
                local currentChar = Player.Character
                local currentHrp = currentChar and currentChar:FindFirstChild("HumanoidRootPart")
                if currentChar and currentHrp and currentHrp:FindFirstChild("VelocityHandler") and currentHrp:FindFirstChild("GyroHandler") then
                    currentHrp.GyroHandler.CFrame = Camera.CFrame
                    
                    local direction = controlModule:GetMoveVector()
                    local actualSpeed = 50 * getgenv().SpeedMultiplier
                    
                    currentHrp.VelocityHandler.Velocity = Vector3.new()
                    if direction.X ~= 0 then
                        currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity + Camera.CFrame.RightVector * (direction.X * actualSpeed)
                    end
                    if direction.Z ~= 0 then
                        currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity - Camera.CFrame.LookVector * (direction.Z * actualSpeed)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity + Vector3.new(0, actualSpeed/2, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        currentHrp.VelocityHandler.Velocity = currentHrp.VelocityHandler.Velocity - Vector3.new(0, actualSpeed/2, 0)
                    end
                end
                task.wait()
            end
            
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
        end)
    else
        if getgenv().flyThread then
            task.cancel(getgenv().flyThread)
            getgenv().flyThread = nil
        end
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end
end

local function toggleNoCd(state)
    getgenv().NoCdEnabled = state
    if state then
        if getgenv().noCdThread then task.cancel(getgenv().noCdThread) end
        getgenv().noCdThread = task.spawn(function()
            while getgenv().NoCdEnabled do
                if Player.cd then
                    if type(Player.cd) == "number" then
                        Player.cd = 0
                    elseif Player.cd:IsA("NumberValue") then
                        Player.cd.Value = 0
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        if getgenv().noCdThread then
            task.cancel(getgenv().noCdThread)
            getgenv().noCdThread = nil
        end
    end
end

local function toggleFreePasses(state)
    getgenv().UnlockFreePasses = state
    if state then
        if getgenv().freePassThread then task.cancel(getgenv().freePassThread) end
        getgenv().freePassThread = task.spawn(function()
            while getgenv().UnlockFreePasses do
                local freePasses = Player:FindFirstChild("FreeGamepasses")
                if freePasses then
                    for _, child in ipairs(freePasses:GetChildren()) do
                        if child:IsA("BoolValue") then
                            child.Value = true
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    else
        if getgenv().freePassThread then
            task.cancel(getgenv().freePassThread)
            getgenv().freePassThread = nil
        end
    end
end

local function toggleAutoSell(state)
    getgenv().AutoSellEnabled = state
    if state then
        if getgenv().autoSellThread then task.cancel(getgenv().autoSellThread) end
        getgenv().autoSellThread = task.spawn(function()
            while getgenv().AutoSellEnabled do
                pcall(function()
                    local sellRemote = getSellRemote()
                    if sellRemote then
                        sellRemote:FireServer()
                    end
                end)
                task.wait(0.3)
            end
        end)
    else
        if getgenv().autoSellThread then
            task.cancel(getgenv().autoSellThread)
            getgenv().autoSellThread = nil
        end
    end
end

local function teleportTo(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
        return true
    end
    return false
end

local function updateSpeedMultiplier(value)
    getgenv().SpeedMultiplier = value
    if getgenv().SpeedEnabled then
        toggleSpeed(false)
        toggleSpeed(true)
    end
    if getgenv().FlyEnabled then
        toggleFly(false)
        toggleFly(true)
    end
end

Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- 基础功能选项卡
local BasicTab = Window:Tab({ Title = "基础", Icon = "home" })

BasicTab:Section({ Title = "移动增强", Opened = true })

BasicTab:Toggle({
    Title = "加速",
    Icon = "zap",
    Value = getgenv().SpeedEnabled,
    Callback = toggleSpeed
})

BasicTab:Toggle({
    Title = "飞行",
    Icon = "plane",
    Value = getgenv().FlyEnabled,
    Callback = toggleFly
})

BasicTab:Divider()

BasicTab:Slider({
    Title = "速度倍率",
    Value = { Min = 1, Max = 10, Default = getgenv().SpeedMultiplier },
    Step = 0.5,
    Callback = updateSpeedMultiplier
})

-- 特色功能选项卡
local FeatureTab = Window:Tab({ Title = "特色", Icon = "zap" })

FeatureTab:Section({ Title = "冷却管理", Opened = true })

FeatureTab:Toggle({
    Title = "无冷却",
    Icon = "clock",
    Value = getgenv().NoCdEnabled,
    Callback = toggleNoCd
})

FeatureTab:Divider()

FeatureTab:Section({ Title = "免费通行证", Opened = true })

FeatureTab:Toggle({
    Title = "解锁免费通行证",
    Icon = "key",
    Value = getgenv().UnlockFreePasses,
    Callback = toggleFreePasses
})

FeatureTab:Divider()

FeatureTab:Section({ Title = "自动出售", Opened = true })

FeatureTab:Paragraph({
    Title = "出售设置",
    Desc = "间隔: 0.3秒",
    Image = "shopping-cart",
    ImageSize = 20
})

FeatureTab:Toggle({
    Title = "自动出售",
    Icon = "dollar-sign",
    Value = getgenv().AutoSellEnabled,
    Callback = toggleAutoSell
})

FeatureTab:Button({
    Title = "手动出售一次",
    Icon = "shopping-cart",
    Callback = function()
        pcall(function()
            local sellRemote = getSellRemote()
            if sellRemote then
                sellRemote:FireServer()
                WindUI:Notify({
                    Title = "出售",
                    Content = "已发送出售请求",
                    Duration = 1
                })
            else
                WindUI:Notify({
                    Title = "出售",
                    Content = "未找到出售远程事件",
                    Duration = 2
                })
            end
        end)
    end
})

-- 传送选项卡
local TeleportTab = Window:Tab({ Title = "传送", Icon = "map-pin" })

TeleportTab:Section({ Title = "区域传送", Opened = true })

for _, point in ipairs(TELEPORT_POINTS) do
    TeleportTab:Button({
        Title = point.name,
        Icon = "map-pin",
        Callback = function()
            if teleportTo(point.pos) then
                WindUI:Notify({
                    Title = "传送",
                    Content = "已传送至 " .. point.name,
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "传送",
                    Content = "传送失败",
                    Duration = 2
                })
            end
        end
    })
end

TeleportTab:Paragraph({
    Title = "说明",
    Desc = "所有区域高度均为 7700",
    Image = "info",
    ImageSize = 16,
    Color = "Blue"
})

-- 数据修改选项卡
local DataTab = Window:Tab({ Title = "数据", Icon = "database" })

DataTab:Paragraph({
    Title = "⚠️ 提示",
    Desc = "仅修改数据,没有实际效果",
    Image = "alert-triangle",
    ImageSize = 20,
    Color = "Orange"
})

DataTab:Divider()

local dataFields = {
    {name = "Coins", display = "金币"},
    {name = "Size", display = "大小"},
    {name = "RobuxSpent", display = "消费"},
    {name = "Speed", display = "速度"},
    {name = "WeatherTokens", display = "天气代币"},
    {name = "TimePlayed", display = "游玩时间"}
}

local inputBoxes = {}
local inputValues = {}

for _, field in ipairs(dataFields) do
    local input = DataTab:Input({
        Title = field.display,
        Placeholder = "输入数值",
        Callback = function(value)
            inputValues[field.name] = value
        end
    })
    inputBoxes[field.name] = input
    
    DataTab:Button({
        Title = "确认修改",
        Icon = "check",
        Callback = function()
            local newValue = tonumber(inputValues[field.name])
            if newValue and Player[field.name] ~= nil then
                if type(Player[field.name]) == "number" then
                    Player[field.name] = newValue
                elseif Player[field.name]:IsA("NumberValue") then
                    Player[field.name].Value = newValue
                end
                
                if inputBoxes[field.name] and inputBoxes[field.name].SetText then
                    inputBoxes[field.name]:SetText("")
                end
                inputValues[field.name] = ""
                
                WindUI:Notify({
                    Title = field.display,
                    Content = "已设置为 " .. newValue,
                    Duration = 1
                })
            end
        end
    })
    
    DataTab:Divider()
end

-- 关于选项卡
local AboutTab = Window:Tab({ Title = "关于", Icon = "info" })

AboutTab:Section({ Title = "关于", Opened = true })

AboutTab:Paragraph({
    Title = "QW 无限提升模拟器",
    Desc = "版本: 1.4.0\n作者: Was",
    Image = "award",
    ImageSize = 32,
    Color = "Orange"
})

Window:OnClose(function()
    getgenv().SpeedEnabled = false
    getgenv().FlyEnabled = false
    getgenv().NoCdEnabled = false
    getgenv().UnlockFreePasses = false
    getgenv().AutoSellEnabled = false
    
    if getgenv().speedThread then task.cancel(getgenv().speedThread) end
    if getgenv().flyThread then task.cancel(getgenv().flyThread) end
    if getgenv().noCdThread then task.cancel(getgenv().noCdThread) end
    if getgenv().freePassThread then task.cancel(getgenv().freePassThread) end
    if getgenv().autoSellThread then task.cancel(getgenv().autoSellThread) end
    
    local char = Player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = DEFAULT_WALKSPEED end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp:FindFirstChild("VelocityHandler") then hrp.VelocityHandler:Destroy() end
            if hrp:FindFirstChild("GyroHandler") then hrp.GyroHandler:Destroy() end
        end
    end
end)

WindUI:Notify({
    Title = "QW 无限提升模拟器",
    Content = "加载成功",
    Duration = 3
})
