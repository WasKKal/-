-- 垃圾中心 - 滴管增量 v1.0.0
-- 开发者：蛙Was

local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local settings = {
    autoClick = false,
    clickRate = 0.1,
    multiClick = 1,
    vibration = true,
    safeMode = true,
}

local dropperRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DropperClick")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "垃圾中心_滴管增量"
screenGui.DisplayOrder = 999
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 220)
mainFrame.Position = UDim2.new(0.5, -160, 0.8, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "垃圾中心 - 滴管增量  v1.0.0"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local tabBar = Instance.new("Frame")
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabBar.BackgroundTransparency = 0.2
tabBar.BorderSizePixel = 0
tabBar.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 10)
tabLayout.Parent = tabBar

local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -90)
contentFrame.Position = UDim2.new(0, 10, 0, 85)
contentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
contentFrame.BackgroundTransparency = 0.3
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = contentFrame

-- 自动点击
local clickConnection = nil

local function startAutoClick()
    if clickConnection then clickConnection:Disconnect() end
    clickConnection = runService.Heartbeat:Connect(function()
        if settings.autoClick then
            task.wait(settings.clickRate)
            dropperRemote:FireServer()
        end
    end)
end

local function stopAutoClick()
    if clickConnection then
        clickConnection:Disconnect()
        clickConnection = nil
    end
end

-- UI控件
function createToggle(title, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.BackgroundTransparency = 1
    container.Parent = nil
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 26)
    toggleBtn.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBtn.BackgroundColor3 = defaultValue and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(80, 80, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = ""
    toggleBtn.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn
    
    local toggleText = Instance.new("TextLabel")
    toggleText.Size = UDim2.new(1, 0, 1, 0)
    toggleText.BackgroundTransparency = 1
    toggleText.Text = defaultValue and "开" or "关"
    toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleText.Font = Enum.Font.GothamBold
    toggleText.TextSize = 14
    toggleText.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        local newState = not (toggleBtn.BackgroundColor3 == Color3.fromRGB(70, 200, 100))
        toggleBtn.BackgroundColor3 = newState and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(80, 80, 100)
        toggleText.Text = newState and "开" or "关"
        callback(newState)
    end)
    
    return container
end

function createSlider(title, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 50)
    container.BackgroundTransparency = 1
    container.Parent = nil
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. math.floor(default)
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = container
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 20)
    sliderFrame.Position = UDim2.new(0, 10, 0, 25)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderFrame.BackgroundTransparency = 0.5
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(70, 200, 150)
    fillBar.BorderSizePixel = 0
    fillBar.Parent = sliderFrame
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fillBar
    
    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 40, 1, 0)
    valueText.Position = UDim2.new(1, -45, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = math.floor(default)
    valueText.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 14
    valueText.Parent = sliderFrame
    
    local dragging = false
    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderFrame.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = input.Position
                local relative = pos.X - sliderFrame.AbsolutePosition.X
                local percent = math.clamp(relative / sliderFrame.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * percent)
                
                fillBar.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = title .. ": " .. value
                valueText.Text = value
                callback(value)
            end
        end
    end)
    
    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return container
end

function createButton(title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.BorderSizePixel = 0
    btn.Text = title
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = nil
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 页面1
local page1 = Instance.new("ScrollingFrame")
page1.Name = "基础功能"
page1.Size = UDim2.new(1, 0, 1, 0)
page1.BackgroundTransparency = 1
page1.BorderSizePixel = 0
page1.ScrollBarThickness = 4
page1.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
page1.AutomaticCanvasSize = Enum.AutomaticSize.Y
page1.Parent = contentFrame

local layout1 = Instance.new("UIListLayout")
layout1.Padding = UDim.new(0, 12)
layout1.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout1.VerticalAlignment = Enum.VerticalAlignment.Top
layout1.Parent = page1

local autoClickToggle = createToggle("自动滴管", settings.autoClick, function(value)
    settings.autoClick = value
    if value then startAutoClick() else stopAutoClick() end
end)
autoClickToggle.Parent = page1

local rateSlider = createSlider("点击间隔(ms)", 30, 500, settings.clickRate * 1000, function(value)
    settings.clickRate = value / 1000
end)
rateSlider.Parent = page1

local multiSlider = createSlider("连击次数", 1, 10, settings.multiClick, function(value)
    settings.multiClick = math.floor(value)
end)
multiSlider.Parent = page1

local testBtn = createButton("手动滴管测试", function()
    dropperRemote:FireServer()
end)
testBtn.Parent = page1

-- 页面2
local page2 = Instance.new("ScrollingFrame")
page2.Name = "高级设置"
page2.Size = UDim2.new(1, 0, 1, 0)
page2.BackgroundTransparency = 1
page2.BorderSizePixel = 0
page2.ScrollBarThickness = 4
page2.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
page2.AutomaticCanvasSize = Enum.AutomaticSize.Y
page2.Parent = contentFrame
page2.Visible = false

local layout2 = Instance.new("UIListLayout")
layout2.Padding = UDim.new(0, 12)
layout2.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout2.VerticalAlignment = Enum.VerticalAlignment.Top
layout2.Parent = page2

local vibToggle = createToggle("触摸振动", settings.vibration, function(value)
    settings.vibration = value
end)
vibToggle.Parent = page2

local safeToggle = createToggle("边界限制", settings.safeMode, function(value)
    settings.safeMode = value
end)
safeToggle.Parent = page2

local resetPosBtn = createButton("重置窗口位置", function()
    mainFrame.Position = UDim2.new(0.5, -160, 0.8, -110)
end)
resetPosBtn.Parent = page2

-- 标签页切换
local tab1Btn = Instance.new("TextButton")
tab1Btn.Size = UDim2.new(0, 100, 0, 30)
tab1Btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
tab1Btn.BorderSizePixel = 0
tab1Btn.Text = "基础功能"
tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
tab1Btn.Font = Enum.Font.GothamBold
tab1Btn.TextSize = 14
tab1Btn.Parent = tabBar

local tab1Corner = Instance.new("UICorner")
tab1Corner.CornerRadius = UDim.new(0, 6)
tab1Corner.Parent = tab1Btn

local tab2Btn = Instance.new("TextButton")
tab2Btn.Size = UDim2.new(0, 100, 0, 30)
tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
tab2Btn.BorderSizePixel = 0
tab2Btn.Text = "高级设置"
tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 220)
tab2Btn.Font = Enum.Font.GothamBold
tab2Btn.TextSize = 14
tab2Btn.Parent = tabBar

local tab2Corner = Instance.new("UICorner")
tab2Corner.CornerRadius = UDim.new(0, 6)
tab2Corner.Parent = tab2Btn

tab1Btn.MouseButton1Click:Connect(function()
    page1.Visible = true
    page2.Visible = false
    tab1Btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 220)
end)

tab2Btn.MouseButton1Click:Connect(function()
    page1.Visible = false
    page2.Visible = true
    tab2Btn.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    tab1Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab1Btn.TextColor3 = Color3.fromRGB(200, 200, 220)
end)

print("垃圾中心 - 滴管增量 v1.0.0 已加载")
