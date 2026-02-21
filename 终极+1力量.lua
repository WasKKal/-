local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- 路径常量
local NET_FOLDER = ReplicatedStorage:WaitForChild("Libraries"):WaitForChild("Net")
local REQUEST_BUY_FUNCTION = NET_FOLDER:WaitForChild("RF/request_buy")

-- 传送点坐标（后三个高度+20）
local TELEPORT_POINTS = {
    Vector3.new(-448.9599, 128, 1466.94519),
    Vector3.new(-466.071045, 130, 1466.80457),
    Vector3.new(-491.93866, 132, 1470.03101),
    Vector3.new(-520.313965, 136, 1473.6814),
    Vector3.new(-547.591492, 140, 1475.44714),
    Vector3.new(-582.592468, 145, 1478.35046),
    Vector3.new(-621.629883, 169.358414, 1481.0592),
    Vector3.new(-641.552429, 146.168434, 1445.68774)
}

-- 超大的力量数值（40个9）
local POWER_AMOUNT = 9999999999999999999999999999999999999999

-- 变量区
local isAutoPowerEnabled = false
local autoPowerConnection = nil
local teleporting = false
local lastPowerTime = 0

-- 默认保存位置
local savedFloatPos = UDim2.new(0.5, -25, 0.5, -25)

-- 获取角色函数
local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- 获取人类oid和根部件
local function getHumanoidAndRoot()
    local char = getCharacter()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return humanoid, root
end

-- 传送函数
local function teleportTo(position, duration)
    local _, root = getHumanoidAndRoot()
    if not root then return false end
    
    local tweenInfo = TweenInfo.new(
        duration or 0.5,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )
    
    local goal = {CFrame = CFrame.new(position)}
    local tween = TweenService:Create(root, tweenInfo, goal)
    tween:Play()
    
    return true
end

-- 获取力量函数（使用超大的POWER_AMOUNT）
local function getPower(amount)
    amount = amount or POWER_AMOUNT  -- 使用超大的默认值
    local args = {
        "Upgrade",
        {
            Price = 1,
            Currency = "Wins",
            Amount = amount
        }
    }
    
    print("⚡ 尝试获取力量... 数值长度:", #tostring(amount))  -- 调试输出，显示数值长度
    local success, result = pcall(function()
        return REQUEST_BUY_FUNCTION:InvokeServer(unpack(args))
    end)
    
    if success then
        print("✅ 力量获取成功")
    else
        print("❌ 力量获取失败:", result)
    end
    
    return success, result
end

-- 创建滑动开关函数
local function createToggle(parent, title, yPos, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -40, 0, 35)
    toggleFrame.Position = UDim2.new(0, 20, 0, yPos)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    -- 标题
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0, 150, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleFrame
    
    -- 开关背景
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -15)
    toggleBg.BackgroundColor3 = defaultState and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = toggleFrame
    
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(1, 0)
    toggleBgCorner.Parent = toggleBg
    
    -- 开关滑块
    local toggleSlider = Instance.new("Frame")
    toggleSlider.Size = UDim2.new(0, 26, 0, 26)
    toggleSlider.Position = defaultState and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
    toggleSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleSlider.BorderSizePixel = 0
    toggleSlider.Parent = toggleBg
    
    local toggleSliderCorner = Instance.new("UICorner")
    toggleSliderCorner.CornerRadius = UDim.new(1, 0)
    toggleSliderCorner.Parent = toggleSlider
    
    -- 开关按钮
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleBg
    
    -- 状态文字
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 40, 1, 0)
    statusLabel.Position = defaultState and UDim2.new(0, 5, 0, 0) or UDim2.new(0, 15, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = defaultState and "ON" or "OFF"
    statusLabel.TextColor3 = defaultState and Color3.new(0.7, 0.7, 0.7) or Color3.new(0.9, 0.9, 0.9)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = defaultState and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    statusLabel.Parent = toggleBg
    
    -- 开关状态
    local state = defaultState
    
    -- 开关点击事件
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        -- 动画效果
        local targetPos = state and UDim2.new(1, -28, 0.5, -13) or UDim2.new(0, 2, 0.5, -13)
        local targetColor = state and Color3.new(0.2, 0.6, 0.2) or Color3.new(0.3, 0.3, 0.3)
        
        -- 滑块动画
        local sliderTween = TweenService:Create(toggleSlider, 
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = targetPos}
        )
        sliderTween:Play()
        
        -- 背景颜色动画
        local bgTween = TweenService:Create(toggleBg,
            TweenInfo.new(0.2),
            {BackgroundColor3 = targetColor}
        )
        bgTween:Play()
        
        -- 文字动画
        statusLabel.Text = state and "ON" or "OFF"
        statusLabel.TextXAlignment = state and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        statusLabel.Position = state and UDim2.new(0, 5, 0, 0) or UDim2.new(0, 15, 0, 0)
        statusLabel.TextColor3 = state and Color3.new(0.7, 0.7, 0.7) or Color3.new(0.9, 0.9, 0.9)
        
        if callback then
            callback(state)
        end
    end)
    
    return {
        getState = function() return state end,
        setState = function(newState)
            if newState == state then return end
            toggleButton.MouseButton1Click:Fire()
        end
    }
end

local function createGUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("UltimateSizeGUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltimateSizeGUI"
    screenGui.Parent = PlayerGui

    -- 主框架
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 320)
    frame.Position = UDim2.new(0.5, -175, 0.5, -160)
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 12)
    frameCorner.Parent = frame

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame

    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 12)
    titleBarCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "垃圾中心 - 终极每秒+1大小"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleBar

    -- 公告栏
    local announceFrame = Instance.new("Frame")
    announceFrame.Size = UDim2.new(1, -20, 0, 50)
    announceFrame.Position = UDim2.new(0, 10, 0, 50)
    announceFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    announceFrame.BorderSizePixel = 0
    announceFrame.Parent = frame

    local announceCorner = Instance.new("UICorner")
    announceCorner.CornerRadius = UDim.new(0, 8)
    announceCorner.Parent = announceFrame

    local announceLabel = Instance.new("TextLabel")
    announceLabel.Size = UDim2.new(1, -10, 1, -10)
    announceLabel.Position = UDim2.new(0, 5, 0, 5)
    announceLabel.BackgroundTransparency = 1
    announceLabel.Text = "⚡ 终极每秒+1大小\n初始版本 - Made by Was"
    announceLabel.TextColor3 = Color3.new(1, 0.8, 0.2)
    announceLabel.Font = Enum.Font.GothamBold
    announceLabel.TextSize = 15
    announceLabel.TextXAlignment = Enum.TextXAlignment.Center
    announceLabel.TextYAlignment = Enum.TextYAlignment.Center
    announceLabel.LineHeight = 1.4
    announceLabel.Parent = announceFrame

    -- 自动获取力量开关
    local powerToggle = createToggle(frame, "⚡ 自动获取力量 (20ms)", 115, false, function(state)
        isAutoPowerEnabled = state
        print("自动获取力量状态变更为:", state)
        
        if state then
            statusLabel.Text = "自动获取力量已开启 (20ms间隔)"
            statusLabel.TextColor3 = Color3.new(0.2, 0.6, 0.2)
            
            -- 关闭旧连接
            if autoPowerConnection then
                autoPowerConnection:Disconnect()
                autoPowerConnection = nil
            end
            
            -- 立即执行一次
            task.spawn(function()
                print("⚡ 首次自动获取力量")
                getPower()
            end)
            
            -- 20ms间隔自动获取
            lastPowerTime = tick()
            autoPowerConnection = RunService.Heartbeat:Connect(function()
                if isAutoPowerEnabled then
                    local currentTime = tick()
                    if currentTime - lastPowerTime >= 0.02 then
                        lastPowerTime = currentTime
                        task.spawn(function()
                            getPower()
                        end)
                    end
                end
            end)
            
        else
            -- 关闭自动获取
            if autoPowerConnection then
                autoPowerConnection:Disconnect()
                autoPowerConnection = nil
            end
            statusLabel.Text = "自动获取力量已关闭"
            statusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
        end
    end)

    -- 手动获取力量按钮
    local manualPowerButton = Instance.new("TextButton")
    manualPowerButton.Size = UDim2.new(0, 300, 0, 45)
    manualPowerButton.Position = UDim2.new(0, 25, 0, 160)
    manualPowerButton.BackgroundColor3 = Color3.new(0.2, 0.5, 0.8)
    manualPowerButton.Text = "⚡ 手动获取力量（最大值）"
    manualPowerButton.TextColor3 = Color3.new(1, 1, 1)
    manualPowerButton.Font = Enum.Font.GothamBold
    manualPowerButton.TextSize = 16
    manualPowerButton.BorderSizePixel = 0
    manualPowerButton.Parent = frame

    local manualCorner = Instance.new("UICorner")
    manualCorner.CornerRadius = UDim.new(0, 8)
    manualCorner.Parent = manualPowerButton

    -- 一键胜利按钮
    local winButton = Instance.new("TextButton")
    winButton.Size = UDim2.new(0, 300, 0, 50)
    winButton.Position = UDim2.new(0, 25, 0, 215)
    winButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
    winButton.Text = "🏆 一键胜利"
    winButton.TextColor3 = Color3.new(1, 1, 1)
    winButton.Font = Enum.Font.GothamBold
    winButton.TextSize = 18
    winButton.BorderSizePixel = 0
    winButton.Parent = frame

    local winCorner = Instance.new("UICorner")
    winCorner.CornerRadius = UDim.new(0, 8)
    winCorner.Parent = winButton

    -- 状态标签
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 40)
    statusLabel.Position = UDim2.new(0, 10, 0, 275)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "就绪"
    statusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 14
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.Parent = frame

    -- 按钮点击事件
    manualPowerButton.MouseButton1Click:Connect(function()
        statusLabel.Text = "⚡ 正在获取力量..."
        statusLabel.TextColor3 = Color3.new(1, 1, 0)
        
        local success = getPower()
        if success then
            statusLabel.Text = "✅ 力量获取成功！"
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
        else
            statusLabel.Text = "❌ 力量获取失败"
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end)

    -- 一键胜利
    winButton.MouseButton1Click:Connect(function()
        if teleporting then
            statusLabel.Text = "⏳ 已经在传送中，请稍候..."
            return
        end
        
        teleporting = true
        statusLabel.Text = "🏆 开始传送..."
        statusLabel.TextColor3 = Color3.new(1, 1, 0)
        
        task.spawn(function()
            local totalPoints = #TELEPORT_POINTS
            
            for i, point in ipairs(TELEPORT_POINTS) do
                local success = teleportTo(point, 0.4)
                
                if success then
                    statusLabel.Text = string.format("🏆 传送中 (%d/%d)", i, totalPoints)
                    task.wait(0.2)
                else
                    statusLabel.Text = "❌ 传送失败，找不到角色"
                    statusLabel.TextColor3 = Color3.new(1, 0, 0)
                    teleporting = false
                    return
                end
            end
            
            statusLabel.Text = "✅ 一键胜利完成！"
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
            teleporting = false
        end)
    end)

    -- 悬浮球
    local floatButton = Instance.new("TextButton")
    floatButton.Size = UDim2.new(0, 55, 0, 55)
    floatButton.Position = savedFloatPos
    floatButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    floatButton.Text = "📏"
    floatButton.TextColor3 = Color3.new(1, 1, 1)
    floatButton.Font = Enum.Font.GothamBold
    floatButton.TextSize = 28
    floatButton.BorderSizePixel = 0
    floatButton.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(1, 0)
    floatCorner.Parent = floatButton

    -- 悬浮球拖动
    local floatDragging = false
    local floatDragInput, floatDragStart, floatStartPos
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
            floatButton.Position = UDim2.new(
                floatStartPos.X.Scale, 
                floatStartPos.X.Offset + delta.X, 
                floatStartPos.Y.Scale, 
                floatStartPos.Y.Offset + delta.Y
            )
            savedFloatPos = floatButton.Position
            input.Handled = true
        end
    end)

    -- 悬浮球点击切换菜单
    floatButton.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)
end

-- 初始化
Player:WaitForChild("PlayerGui")
createGUI()

-- 重生保护
Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    createGUI()
end)

print("✅ 垃圾中心 - 终极每秒+1大小 v1.0.0 已加载")
print("   初始版本 - Made by Was")
print("   ⚡ 自动获取力量 (20ms间隔) - 数值: 40个9")
print("   📏 后三个传送点高度+20 | OFF文字左移优化")
