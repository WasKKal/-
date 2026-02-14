local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedGliderGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui or Player:WaitForChild("PlayerGui")
ScreenGui.IgnoreGuiInset = true

local colors = {
    bg = Color3.fromRGB(25, 25, 35),
    darker = Color3.fromRGB(20, 20, 30),
    accent = Color3.fromRGB(64, 158, 255),
    success = Color3.fromRGB(64, 200, 100),
    warning = Color3.fromRGB(255, 170, 0),
    text = Color3.fromRGB(255, 255, 255),
    subText = Color3.fromRGB(180, 180, 180),
    close = Color3.fromRGB(220, 40, 40)
}

local function vibrate()
    pcall(function()
        UserInputService:SetVibration(Enum.VibrationMotor.Medium, 0.05)
    end)
end

local function fireRemote(name, ...)
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(name, true)
    if remote then
        remote:FireServer(...)
        return true
    end
    return false
end

local POINTS = {
    CFrame.new(-5781.66406, 1442.27222, 14638.9414, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    CFrame.new(9, 9, -62.5000038, 0, 0, -1, 0, 1, 0, 1, 0, 0)
}

local teleportActive = false
local teleportDelay = 0.5
local currentPoint = 1
local teleportConnection = nil

local function teleportToCurrentPoint()
    local character = Player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = POINTS[currentPoint]
        currentPoint = currentPoint == 1 and 2 or 1
    end
end

local function startTeleportLoop()
    if teleportConnection then
        teleportConnection:Disconnect()
    end
    
    teleportActive = true
    currentPoint = 1
    
    teleportConnection = RunService.Heartbeat:Connect(function()
        if teleportActive then
            teleportToCurrentPoint()
            task.wait(teleportDelay)
        end
    end)
end

local function stopTeleportLoop()
    teleportActive = false
    if teleportConnection then
        teleportConnection:Disconnect()
        teleportConnection = nil
    end
end

local function makeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        local viewportSize = ScreenGui.AbsoluteSize
        local frameSize = targetFrame.AbsoluteSize
        local maxX = viewportSize.X - frameSize.X
        local maxY = viewportSize.Y - frameSize.Y
        
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, 0, maxX),
            0, math.clamp(newPos.Y.Offset, 0, maxY)
        )
        
        targetFrame.Position = newPos
    end

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if UserInputService.TouchEnabled then
                input:Capture()
            end
            
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            vibrate()
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- 右上角隐藏按钮
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 40, 0, 40)
HideButton.Position = UDim2.new(1, -50, 0, 10)
HideButton.BackgroundColor3 = colors.accent
HideButton.Text = "⚡"
HideButton.TextColor3 = colors.text
HideButton.TextSize = 20
HideButton.Font = Enum.Font.GothamBold
HideButton.BorderSizePixel = 0
HideButton.Visible = true
HideButton.Parent = ScreenGui
HideButton.Active = true
HideButton.Selectable = false

local HideButtonCorner = Instance.new("UICorner")
HideButtonCorner.CornerRadius = UDim.new(0, 8)
HideButtonCorner.Parent = HideButton

-- 主框架
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 320)  -- 加宽加长防止溢出
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -160)  -- 居中显示
MainFrame.BackgroundColor3 = colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
MainFrame.Selectable = false
MainFrame.Visible = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = colors.darker
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
TitleBar.Active = true
TitleBar.Selectable = false

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "垃圾中心 - +1速度滑翔翼逃生"
TitleText.TextColor3 = colors.text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = colors.close
CloseButton.Text = "X"
CloseButton.TextColor3 = colors.text
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

HideButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    vibrate()
end)

makeDraggable(TitleBar, MainFrame)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -40)
Content.Position = UDim2.new(0, 10, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- 公告
local AnnouncementLabel = Instance.new("TextLabel")
AnnouncementLabel.Size = UDim2.new(1, 0, 0, 25)
AnnouncementLabel.Position = UDim2.new(0, 0, 0, 0)
AnnouncementLabel.BackgroundTransparency = 1
AnnouncementLabel.Text = "📢 v1.0.1 - 右上角隐藏脚本"
AnnouncementLabel.TextColor3 = colors.subText
AnnouncementLabel.Font = Enum.Font.Gotham
AnnouncementLabel.TextSize = 12
AnnouncementLabel.TextXAlignment = Enum.TextXAlignment.Left
AnnouncementLabel.Parent = Content

local GiveXPButton = Instance.new("TextButton")
GiveXPButton.Size = UDim2.new(1, 0, 0, 35)
GiveXPButton.Position = UDim2.new(0, 0, 0, 35)
GiveXPButton.BackgroundColor3 = colors.accent
GiveXPButton.Text = "🎁 给予 1000万 经验"
GiveXPButton.TextColor3 = colors.text
GiveXPButton.Font = Enum.Font.GothamBold
GiveXPButton.TextSize = 14
GiveXPButton.BorderSizePixel = 0
GiveXPButton.Parent = Content

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = GiveXPButton

local LevelUpButton = Instance.new("TextButton")
LevelUpButton.Size = UDim2.new(1, 0, 0, 35)
LevelUpButton.Position = UDim2.new(0, 0, 0, 80)
LevelUpButton.BackgroundColor3 = colors.success
LevelUpButton.Text = "⬆️ 等级提升"
LevelUpButton.TextColor3 = colors.text
LevelUpButton.Font = Enum.Font.GothamBold
LevelUpButton.TextSize = 14
LevelUpButton.BorderSizePixel = 0
LevelUpButton.Parent = Content

local ButtonCorner2 = Instance.new("UICorner")
ButtonCorner2.CornerRadius = UDim.new(0, 8)
ButtonCorner2.Parent = LevelUpButton

local TeleportToggle = Instance.new("TextButton")
TeleportToggle.Size = UDim2.new(1, 0, 0, 35)
TeleportToggle.Position = UDim2.new(0, 0, 0, 125)
TeleportToggle.BackgroundColor3 = colors.warning
TeleportToggle.Text = "🔄 自动胜利: 关闭"
TeleportToggle.TextColor3 = colors.text
TeleportToggle.Font = Enum.Font.GothamBold
TeleportToggle.TextSize = 14
TeleportToggle.BorderSizePixel = 0
TeleportToggle.Parent = Content

local TeleportCorner = Instance.new("UICorner")
TeleportCorner.CornerRadius = UDim.new(0, 8)
TeleportCorner.Parent = TeleportToggle

local DelayInfo = Instance.new("TextLabel")
DelayInfo.Size = UDim2.new(1, 0, 0, 25)
DelayInfo.Position = UDim2.new(0, 0, 0, 170)
DelayInfo.BackgroundTransparency = 1
DelayInfo.Text = "⏱️ 传送间隔: 20ms (固定)"
DelayInfo.TextColor3 = colors.text
DelayInfo.Font = Enum.Font.Gotham
DelayInfo.TextSize = 13
DelayInfo.Parent = Content

local Point1Info = Instance.new("TextLabel")
Point1Info.Size = UDim2.new(1, 0, 0, 20)
Point1Info.Position = UDim2.new(0, 0, 0, 200)
Point1Info.BackgroundTransparency = 1
Point1Info.Text = "📍 点1: 胜利坐标"
Point1Info.TextColor3 = colors.subText
Point1Info.Font = Enum.Font.Gotham
Point1Info.TextSize = 12
Point1Info.TextXAlignment = Enum.TextXAlignment.Left
Point1Info.Parent = Content

local Point2Info = Instance.new("TextLabel")
Point2Info.Size = UDim2.new(1, 0, 0, 20)
Point2Info.Position = UDim2.new(0, 0, 0, 220)
Point2Info.BackgroundTransparency = 1
Point2Info.Text = "📍 点2: 起始坐标"
Point2Info.TextColor3 = colors.subText
Point2Info.Font = Enum.Font.Gotham
Point2Info.TextSize = 12
Point2Info.TextXAlignment = Enum.TextXAlignment.Left
Point2Info.Parent = Content

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 250)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "就绪"
StatusLabel.TextColor3 = colors.subText
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.Parent = Content

GiveXPButton.MouseButton1Click:Connect(function()
    local success = fireRemote("GiveXP", 10000000)
    StatusLabel.Text = success and "✅ 1000万经验已给予" or "❌ 失败: GiveXP不存在"
    vibrate()
end)

LevelUpButton.MouseButton1Click:Connect(function()
    local success = fireRemote("LevelUp")
    StatusLabel.Text = success and "✅ 等级已提升" or "❌ 失败: LevelUp不存在"
    vibrate()
end)

TeleportToggle.MouseButton1Click:Connect(function()
    teleportActive = not teleportActive
    
    if teleportActive then
        TeleportToggle.Text = "🔄 自动胜利: 开启"
        TeleportToggle.BackgroundColor3 = colors.success
        startTeleportLoop()
        StatusLabel.Text = "✅ 循环传送已开启 (500ms)"
    else
        TeleportToggle.Text = "🔄 自动胜利: 关闭"
        TeleportToggle.BackgroundColor3 = colors.warning
        stopTeleportLoop()
        StatusLabel.Text = "⏹️ 自动胜利已关闭"
    end
    vibrate()
end)
