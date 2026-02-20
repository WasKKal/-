local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 路径常量
local EVENTS_FOLDER = ReplicatedStorage:WaitForChild("ReplicatedStorageHolders"):WaitForChild("Events")
local ADD_XP_EVENT = EVENTS_FOLDER:WaitForChild("AddXP")
local ADD_COINS_EVENT = EVENTS_FOLDER:WaitForChild("AddCoins")
local UPGRADE_STAT_EVENT = EVENTS_FOLDER:WaitForChild("UpgradeStat")
local UPGRADE_CAP_EVENT = EVENTS_FOLDER:WaitForChild("UpgradeCap")

-- 固定数量
local XP_AMOUNT = 100000
local COINS_AMOUNT = 1000000

-- 重复次数变量
local repeatCount = 1
local isRepeating = true  -- 默认开启

-- GUI保存位置
local savedFloatPos = UDim2.new(0.5, -25, 0.5, -25)
local savedMenuPos = UDim2.new(0, 10, 0, 10)

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

-- 创建滑块函数（加大滑块按钮）
local function createSlider(parent, title, yPos, min, max, defaultValue, callback)
    -- 标题
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 20)
    titleLabel.Position = UDim2.new(0, 10, 0, yPos)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = parent
    
    -- 数值显示
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, yPos)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = parent
    
    -- 滑块轨道
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -30, 0, 6)  -- 轨道加粗到6像素
    sliderBg.Position = UDim2.new(0, 15, 0, yPos + 25)
    sliderBg.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    -- 滑块按钮（加大到22x22）
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 22, 0, 22)  -- 从16x16加大到22x22
    sliderButton.Position = UDim2.new((defaultValue - min) / (max - min), -11, 0, -8)  -- 调整偏移
    sliderButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.Parent = sliderBg
    
    local sliderButtonCorner = Instance.new("UICorner")
    sliderButtonCorner.CornerRadius = UDim.new(1, 0)
    sliderButtonCorner.Parent = sliderButton
    
    -- 滑块拖动逻辑
    local dragging = false
    
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            input.Handled = true
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local sliderPos = sliderBg.AbsolutePosition
            local sliderSize = sliderBg.AbsoluteSize.X
            
            local relativeX = math.clamp(mousePos.X - sliderPos.X, 0, sliderSize)
            local percent = relativeX / sliderSize
            local value = math.floor(min + (max - min) * percent)
            
            sliderButton.Position = UDim2.new(percent, -11, 0, -8)  -- 调整偏移
            valueLabel.Text = tostring(value)
            
            if callback then
                callback(value)
            end
            
            input.Handled = true
        end
    end)
    
    return {
        setValue = function(value)
            local percent = (value - min) / (max - min)
            sliderButton.Position = UDim2.new(percent, -11, 0, -8)
            valueLabel.Text = tostring(value)
        end,
        getValue = function()
            return tonumber(valueLabel.Text)
        end
    }
end

local function createGUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("BladeSpinGUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BladeSpinGUI"
    screenGui.Parent = PlayerGui

    -- 主框架（略微调高以确保全部显示）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 490)  -- 从500减到490，更紧凑
    frame.Position = UDim2.new(0.5, -150, 0.5, -245)
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
    titleLabel.Text = "垃圾中心 - 刀片旋转"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleBar

    -- 公告栏（高度略微减小）
    local announceFrame = Instance.new("Frame")
    announceFrame.Size = UDim2.new(1, -20, 0, 55)  -- 从60减到55
    announceFrame.Position = UDim2.new(0, 10, 0, 35)  -- 从40上移到35
    announceFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    announceFrame.BorderSizePixel = 0
    announceFrame.Parent = frame

    local announceCorner = Instance.new("UICorner")
    announceCorner.CornerRadius = UDim.new(0, 6)
    announceCorner.Parent = announceFrame

    local announceLabel = Instance.new("TextLabel")
    announceLabel.Size = UDim2.new(1, -10, 1, -10)
    announceLabel.Position = UDim2.new(0, 5, 0, 5)
    announceLabel.BackgroundTransparency = 1
    announceLabel.Text = "🔪 刀片旋转 v1.0.0\n请先进入游戏再执行功能"
    announceLabel.TextColor3 = Color3.new(1, 0.8, 0.2)
    announceLabel.Font = Enum.Font.GothamBold
    announceLabel.TextSize = 15  -- 略微减小字号
    announceLabel.TextXAlignment = Enum.TextXAlignment.Center
    announceLabel.TextYAlignment = Enum.TextYAlignment.Center
    announceLabel.LineHeight = 1.4  -- 减小行高
    announceLabel.Parent = announceFrame

    -- 经验值按钮
    local xpButton = Instance.new("TextButton")
    xpButton.Size = UDim2.new(0, 260, 0, 38)  -- 高度从40减到38
    xpButton.Position = UDim2.new(0, 20, 0, 100)  -- 从115上移到100
    xpButton.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    xpButton.Text = "⚡ 给予十万经验值"
    xpButton.TextColor3 = Color3.new(1, 1, 1)
    xpButton.Font = Enum.Font.GothamBold
    xpButton.TextSize = 15  -- 略微减小字号
    xpButton.BorderSizePixel = 0
    xpButton.Parent = frame

    local xpCorner = Instance.new("UICorner")
    xpCorner.CornerRadius = UDim.new(0, 6)
    xpCorner.Parent = xpButton

    -- 硬币按钮
    local coinButton = Instance.new("TextButton")
    coinButton.Size = UDim2.new(0, 260, 0, 38)
    coinButton.Position = UDim2.new(0, 20, 0, 145)  -- 从165上移到145
    coinButton.BackgroundColor3 = Color3.new(0.8, 0.5, 0.1)
    coinButton.Text = "💰 给予一百万硬币"
    coinButton.TextColor3 = Color3.new(1, 1, 1)
    coinButton.Font = Enum.Font.GothamBold
    coinButton.TextSize = 15
    coinButton.BorderSizePixel = 0
    coinButton.Parent = frame

    local coinCorner = Instance.new("UICorner")
    coinCorner.CornerRadius = UDim.new(0, 6)
    coinCorner.Parent = coinButton

    -- 分割线1
    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(1, -40, 0, 1)
    line1.Position = UDim2.new(0, 20, 0, 190)  -- 从215上移到190
    line1.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    line1.BorderSizePixel = 0
    line1.Parent = frame

    -- 一键满级(局内属性)
    local maxButton = Instance.new("TextButton")
    maxButton.Size = UDim2.new(0, 260, 0, 38)
    maxButton.Position = UDim2.new(0, 20, 0, 200)  -- 从225上移到200
    maxButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.6)
    maxButton.Text = "⚡ 一键满级(局内属性)"
    maxButton.TextColor3 = Color3.new(1, 1, 1)
    maxButton.Font = Enum.Font.GothamBold
    maxButton.TextSize = 15
    maxButton.BorderSizePixel = 0
    maxButton.Parent = frame

    local maxCorner = Instance.new("UICorner")
    maxCorner.CornerRadius = UDim.new(0, 6)
    maxCorner.Parent = maxButton

    -- 一键满级(局外属性)
    local maxCapButton = Instance.new("TextButton")
    maxCapButton.Size = UDim2.new(0, 260, 0, 38)
    maxCapButton.Position = UDim2.new(0, 20, 0, 245)  -- 从275上移到245
    maxCapButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.6)
    maxCapButton.Text = "🌟 一键满级(局外属性)"
    maxCapButton.TextColor3 = Color3.new(1, 1, 1)
    maxCapButton.Font = Enum.Font.GothamBold
    maxCapButton.TextSize = 15
    maxCapButton.BorderSizePixel = 0
    maxCapButton.Parent = frame

    local maxCapCorner = Instance.new("UICorner")
    maxCapCorner.CornerRadius = UDim.new(0, 6)
    maxCapCorner.Parent = maxCapButton

    -- 分割线2
    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(1, -40, 0, 1)
    line2.Position = UDim2.new(0, 20, 0, 290)  -- 从325上移到290
    line2.BackgroundColor3 = Color3.new(0.4, 0.4, 0.4)
    line2.BorderSizePixel = 0
    line2.Parent = frame

    -- 重复次数滑块 (位置上调)
    local slider = createSlider(frame, "重复次数 (1-100)", 300, 1, 100, 1, function(value)  -- 从335上移到300
        repeatCount = value
    end)

    -- 重复开关（修改文字）
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -40, 0, 30)
    toggleFrame.Position = UDim2.new(0, 20, 0, 355)  -- 从390上移到355
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = frame

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0, 70, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = "重复给予:"
    toggleLabel.TextColor3 = Color3.new(1, 1, 1)
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 14
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 70, 1, 0)  -- 宽度从50加大到70以适应文字
    toggleButton.Position = UDim2.new(0, 75, 0, 0)
    toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)  -- 默认绿色
    toggleButton.Text = "已开启"  -- 改为"已开启"
    toggleButton.TextColor3 = Color3.new(0.3, 1, 0.3)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton

    -- 开关点击事件（修改文字）
    toggleButton.MouseButton1Click:Connect(function()
        isRepeating = not isRepeating
        if isRepeating then
            toggleButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
            toggleButton.Text = "已开启"
            toggleButton.TextColor3 = Color3.new(0.3, 1, 0.3)
        else
            toggleButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            toggleButton.Text = "已关闭"
            toggleButton.TextColor3 = Color3.new(1, 0.3, 0.3)
        end
    end)

    -- 提示标签
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 40)
    statusLabel.Position = UDim2.new(0, 10, 0, 390)  -- 从425上移到390
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "点击按钮发送\n当前模式: 重复(1次)"
    statusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.TextYAlignment = Enum.TextYAlignment.Center
    statusLabel.LineHeight = 1.5
    statusLabel.Parent = frame

    -- 更新状态显示
    local function updateStatus(text, isSuccess)
        if isSuccess then
            statusLabel.Text = text .. "\n当前模式: " .. (isRepeating and ("重复(" .. repeatCount .. "次)" ) or "单次")
            statusLabel.TextColor3 = Color3.new(0, 1, 0)
        else
            statusLabel.Text = text .. "\n当前模式: " .. (isRepeating and ("重复(" .. repeatCount .. "次)" ) or "单次")
            statusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
    end

    -- 执行重复发送的函数
    local function sendRepeatedly(sendFunc, typeName, customCount)
        local count = customCount or (isRepeating and repeatCount or 1)
        for i = 1, count do
            local success, err = pcall(sendFunc)
            if not success then
                updateStatus("❌ 第" .. i .. "次发送失败: " .. tostring(err), false)
                return false
            end
            task.wait(0.1)
        end
        return true
    end

    -- 按钮点击事件
    xpButton.MouseButton1Click:Connect(function()
        local success = sendRepeatedly(
            function() ADD_XP_EVENT:FireServer(XP_AMOUNT) end,
            "十万经验值"
        )
        if success then
            updateStatus("✅ 已发送" .. (isRepeating and (" " .. repeatCount .. "次") or "") .. "十万经验值", true)
        end
    end)

    coinButton.MouseButton1Click:Connect(function()
        local success = sendRepeatedly(
            function() ADD_COINS_EVENT:FireServer(COINS_AMOUNT) end,
            "一百万硬币"
        )
        if success then
            updateStatus("✅ 已发送" .. (isRepeating and (" " .. repeatCount .. "次") or "") .. "一百万硬币", true)
        end
    end)

    -- 一键满级(局内属性)
    maxButton.MouseButton1Click:Connect(function()
        updateStatus("⚡ 开始执行局内属性满级...", true)
        
        task.spawn(function()
            -- SpinSpeed 5次
            for i = 1, 5 do
                local success, err = pcall(function()
                    UPGRADE_STAT_EVENT:FireServer("SpinSpeed")
                end)
                if not success then
                    updateStatus("❌ SpinSpeed第" .. i .. "次失败", false)
                    return
                end
                task.wait(0.1)
            end
            
            -- AmountOfBlades 3次
            for i = 1, 3 do
                local success, err = pcall(function()
                    UPGRADE_STAT_EVENT:FireServer("AmountOfBlades")
                end)
                if not success then
                    updateStatus("❌ AmountOfBlades第" .. i .. "次失败", false)
                    return
                end
                task.wait(0.1)
            end
            
            updateStatus("✅ 局内属性满级完成！", true)
        end)
    end)

    -- 一键满级(局外属性)
    maxCapButton.MouseButton1Click:Connect(function()
        updateStatus("🌟 开始执行局外属性满级...", true)
        
        task.spawn(function()
            -- 属性列表（每个重复10次）
            local capStats = {
                "AmountOfBlades",
                "AmountOfBlades",  -- 第二个AmountOfBlades
                "Damage",
                "HP",
                "CoinBoost",
                "Movement"
            }
            
            for _, stat in ipairs(capStats) do
                for i = 1, 10 do  -- 每个属性重复10次
                    local success, err = pcall(function()
                        UPGRADE_CAP_EVENT:FireServer(stat)
                    end)
                    if not success then
                        updateStatus("❌ " .. stat .. "第" .. i .. "次失败", false)
                        return
                    end
                    task.wait(0.1)
                end
            end
            
            updateStatus("✅ 局外属性满级完成！（共60次升级）", true)
        end)
    end)

    -- 悬浮球
    local floatButton = Instance.new("TextButton")
    floatButton.Size = UDim2.new(0, 50, 0, 50)
    floatButton.Position = savedFloatPos
    floatButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    floatButton.Text = "🔪"
    floatButton.TextColor3 = Color3.new(1, 1, 1)
    floatButton.Font = Enum.Font.GothamBold
    floatButton.TextSize = 24
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

-- 初始状态显示
local function updateInitialStatus()
    print("✅ 垃圾中心 - 刀片旋转 v1.0.0 已加载")
    print("   请先进入游戏再执行功能")
    print("   ⚡ 经验值: 10万 | 💰 硬币: 100万")
    print("   🔪 重复模式: 已开启(默认)")
end

Player:WaitForChild("PlayerGui")
createGUI()
updateInitialStatus()

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    createGUI()
end)
