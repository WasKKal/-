local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 传送坐标列表（造船寻宝路线）
local WAYPOINTS = {
    CFrame.new(-51.5656433, 65.0000458, 1369.09009),
    CFrame.new(-51.5656433, 65.0000458, 2139.09009),
    CFrame.new(-51.5656433, 65.0000458, 2909.09009),
    CFrame.new(-51.5656433, 65.0000458, 3679.09009),
    CFrame.new(-51.5656433, 65.0000458, 4449.08984),
    CFrame.new(-51.5656433, 65.0000458, 5219.08984),
    CFrame.new(-51.5656433, 65.0000458, 5989.08984),
    CFrame.new(-51.5656433, 65.0000458, 6759.08984),
    CFrame.new(-51.5656433, 65.0000458, 7529.08984),
    CFrame.new(-51.5656433, 65.0000458, 8299.08984),
    CFrame.new(-50.7249107, -365, 9456.28906)  -- 终点
}

-- 悬浮球保存位置
local savedFloatPos = UDim2.new(0.5, -25, 0.5, -25)

-- 默认步行速度
local DEFAULT_WALKSPEED = 16
local currentSpeed = DEFAULT_WALKSPEED
local speedRange = {min = 16, max = 100}
local speedEnabled = true

-- 滑块拖动变量
local draggingSlider = false
local dragOffset = 0

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function setCharacterSpeed(speed)
    if not speedEnabled then
        speed = DEFAULT_WALKSPEED
    end
    local character = Player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = speed
            end)
        end
    end
end

local function createGUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("ShipTreasureGUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ShipTreasureGUI"
    screenGui.Parent = PlayerGui

    -- 主框架（固定在屏幕中心）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 300)
    frame.Position = UDim2.new(0.5, -120, 0.5, -150)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 8)
    titleBarCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "垃圾中心 - 造船寻宝"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleBar

    -- 警告文本
    local warningLabel = Instance.new("TextLabel")
    warningLabel.Size = UDim2.new(1, -20, 0, 40)
    warningLabel.Position = UDim2.new(0, 10, 0, 40)
    warningLabel.BackgroundTransparency = 1
    warningLabel.Text = "请先造好船点击起航后再执行此功能"
    warningLabel.TextColor3 = Color3.new(1, 0.8, 0.2)
    warningLabel.Font = Enum.Font.GothamSemibold
    warningLabel.TextSize = 12
    warningLabel.TextWrapped = true
    warningLabel.TextXAlignment = Enum.TextXAlignment.Center
    warningLabel.Parent = frame

    -- 加速开关
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 100, 0, 25)
    toggleButton.Position = UDim2.new(0, 70, 0, 85)
    toggleButton.BackgroundColor3 = speedEnabled and Color3.new(0, 0.8, 0) or Color3.new(0.5, 0.5, 0.5)
    toggleButton.Text = speedEnabled and "加速 ON" or "加速 OFF"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = frame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton

    -- 速度标签
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0, 80, 0, 20)
    speedLabel.Position = UDim2.new(0, 10, 0, 120)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "角色速度"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 14
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = frame

    local speedValueLabel = Instance.new("TextLabel")
    speedValueLabel.Size = UDim2.new(0, 50, 0, 20)
    speedValueLabel.Position = UDim2.new(0, 170, 0, 120)
    speedValueLabel.BackgroundTransparency = 1
    speedValueLabel.Text = tostring(currentSpeed)
    speedValueLabel.TextColor3 = speedEnabled and Color3.new(0, 1, 0) or Color3.new(0.6, 0.6, 0.6)
    speedValueLabel.Font = Enum.Font.GothamBold
    speedValueLabel.TextSize = 14
    speedValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    speedValueLabel.Parent = frame

    -- 滑动条轨道
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, 180, 0, 6)
    sliderBg.Position = UDim2.new(0, 30, 0, 150)
    sliderBg.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 3)
    sliderBgCorner.Parent = sliderBg

    -- 滑块（尺寸加大到35x35，增大点击范围）
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 35, 0, 35)  -- 加大
    local maxTrack = 180 - 35  -- 轨道剩余可移动空间
    local initialPosX = (currentSpeed - speedRange.min) / (speedRange.max - speedRange.min) * maxTrack
    sliderButton.Position = UDim2.new(0, 30 + initialPosX, 0, 136)  -- Y对齐轨道中心 (150+3-17.5=135.5 → 136)
    sliderButton.BackgroundColor3 = Color3.new(0.2, 0.8, 1)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Active = speedEnabled
    sliderButton.Parent = frame

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)  -- 圆形
    sliderCorner.Parent = sliderButton

    -- 一键胜利按钮
    local winButton = Instance.new("TextButton")
    winButton.Size = UDim2.new(0, 180, 0, 40)
    winButton.Position = UDim2.new(0, 30, 0, 180)
    winButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    winButton.Text = "一键胜利"
    winButton.TextColor3 = Color3.new(1, 1, 1)
    winButton.Font = Enum.Font.GothamBold
    winButton.TextSize = 16
    winButton.BorderSizePixel = 0
    winButton.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = winButton

    -- 提示标签
    local successLabel = Instance.new("TextLabel")
    successLabel.Size = UDim2.new(1, -20, 0, 30)
    successLabel.Position = UDim2.new(0, 10, 0, 230)
    successLabel.BackgroundTransparency = 1
    successLabel.Text = ""
    successLabel.TextColor3 = Color3.new(0, 1, 0)
    successLabel.Font = Enum.Font.GothamBold
    successLabel.TextSize = 16
    successLabel.TextXAlignment = Enum.TextXAlignment.Center
    successLabel.Parent = frame

    -- 滑块拖动逻辑（带偏移量，支持左右拖动）
    local function updateSpeedFromSlider()
        if not speedEnabled then return end
        local absX = sliderButton.AbsolutePosition.X
        local bgAbsPos = sliderBg.AbsolutePosition.X
        local relativeX = math.clamp(absX - bgAbsPos, 0, maxTrack)
        local speed = speedRange.min + (relativeX / maxTrack) * (speedRange.max - speedRange.min)
        speed = math.floor(speed + 0.5)
        speed = math.clamp(speed, speedRange.min, speedRange.max)
        currentSpeed = speed
        speedValueLabel.Text = tostring(speed)
        setCharacterSpeed(speed)
    end

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if speedEnabled then
                draggingSlider = true
                dragOffset = input.Position.X - sliderButton.AbsolutePosition.X
                input.Handled = true
            end
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingSlider = false
                end
            end)
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local bgAbsPos = sliderBg.AbsolutePosition.X
            local newLeft = input.Position.X - dragOffset - bgAbsPos
            newLeft = math.clamp(newLeft, 0, maxTrack)
            sliderButton.Position = UDim2.new(0, 30 + newLeft, 0, 136)  -- Y保持不变
            updateSpeedFromSlider()
            input.Handled = true
        end
    end)

    -- 开关点击
    toggleButton.MouseButton1Click:Connect(function()
        speedEnabled = not speedEnabled
        toggleButton.BackgroundColor3 = speedEnabled and Color3.new(0, 0.8, 0) or Color3.new(0.5, 0.5, 0.5)
        toggleButton.Text = speedEnabled and "加速 ON" or "加速 OFF"
        speedValueLabel.TextColor3 = speedEnabled and Color3.new(0, 1, 0) or Color3.new(0.6, 0.6, 0.6)
        sliderButton.Active = speedEnabled
        if not speedEnabled then
            setCharacterSpeed(DEFAULT_WALKSPEED)
        else
            setCharacterSpeed(currentSpeed)
        end
    end)

    setCharacterSpeed(currentSpeed)

    -- 一键胜利
    local running = false
    winButton.MouseButton1Click:Connect(function()
        if running then return end
        running = true
        successLabel.Text = ""

        local character = getCharacter()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            warn("找不到 HumanoidRootPart")
            running = false
            return
        end

        for i, cf in ipairs(WAYPOINTS) do
            humanoidRootPart.CFrame = cf
            if i < #WAYPOINTS then
                task.wait(0.35)
            end
        end

        successLabel.Text = "成功✅"
        running = false
    end)

    -- 悬浮球
    local floatButton = Instance.new("TextButton")
    floatButton.Size = UDim2.new(0, 50, 0, 50)
    floatButton.Position = savedFloatPos
    floatButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    floatButton.Text = "🚢"
    floatButton.TextColor3 = Color3.new(1, 1, 1)
    floatButton.Font = Enum.Font.GothamBold
    floatButton.TextSize = 24
    floatButton.BorderSizePixel = 0
    floatButton.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatButton

    -- 悬浮球拖动
    local floatDragging, floatDragInput, floatDragStart, floatStartPos
    local function updateSavedFloatPos() savedFloatPos = floatButton.Position end

    floatButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = true
            floatDragStart = input.Position
            floatStartPos = floatButton.Position
            input.Handled = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    floatDragging = false
                    updateSavedFloatPos()
                end
            end)
        end
    end)

    floatButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if floatDragging then
                floatDragInput = input
                input.Handled = true
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == floatDragInput and floatDragging then
            local delta = input.Position - floatDragStart
            floatButton.Position = UDim2.new(floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X, floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y)
            savedFloatPos = floatButton.Position
            input.Handled = true
        end
    end)

    -- 悬浮球点击切换菜单
    floatButton.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

Player:WaitForChild("PlayerGui")
createGUI()

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    createGUI()
end)

print("脚本已加载 | 菜单固定在屏幕中心 | 悬浮球可拖动 | 滑块圆点已加大（35x35）| 可左右拖动")
