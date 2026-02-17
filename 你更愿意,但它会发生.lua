local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 远程调用路径
local remotePath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Networker"):WaitForChild("_remotes"):WaitForChild("StageService"):WaitForChild("RemoteFunction")

-- 按钮数据：显示名称、参数列表（共12个功能，新增拯救朋友和拯救67）
local BUTTONS = {
    { name = "变的更高", args = {"finishStage", "Stage2", "BE_WAY_TOO_TALL"} },
    { name = "变的更矮", args = {"finishStage", "Stage2", "BE_TOO_SHORT"} },
    { name = "穿上芭蕾舞裙", args = {"finishStage", "Stage3", "WEAR_A_TUTU"} },
    { name = "变成一颗蛋", args = {"finishStage", "Stage3", "BE_AN_EGG"} },
    { name = "拯救婴儿", args = {"finishStage", "Stage4", "SAVE_THE_BABIES"} },
    { name = "拯救曲奇饼干", args = {"finishStage", "Stage4", "SAVE_THE_COOKIE"} },
    { name = "得到5个robux乞丐", args = {"finishStage", "Stage5", "FIVE_ROBUX_BEGGARS"} },
    { name = "得到1个robux乞丐", args = {"finishStage", "Stage5", "ONE_ROBUX_BEGGARS"} },
    { name = "得到汉堡包", args = {"finishStage", "Stage6", "BURGIR"} },
    { name = "得到薯条", args = {"finishStage", "Stage6", "FRIEZ"} },
    { name = "拯救朋友", args = {"finishStage", "Stage7", "SAVE_THE_FRIENDS"} },
    { name = "拯救67", args = {"finishStage", "Stage7", "SAVE_THE_67"} }
}

-- GUI保存位置
local savedFloatPos = UDim2.new(0.5, -25, 0.5, -25)
local savedMenuPos = UDim2.new(0, 10, 0, 10)

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function createGUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("WYRButItHappensGUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WYRButItHappensGUI"
    screenGui.Parent = PlayerGui

    -- 主框架（高度370）
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 240, 0, 370)
    frame.Position = savedMenuPos
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
    titleLabel.Text = "垃圾中心 - 你更愿意,但它会发生"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleBar

    -- 搜索框
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 0, 30)
    searchBox.Position = UDim2.new(0, 10, 0, 40)
    searchBox.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderText = "搜索功能..."
    searchBox.PlaceholderColor3 = Color3.new(0.6, 0.6, 0.6)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.ClearTextOnFocus = false
    searchBox.BorderSizePixel = 0
    searchBox.Text = ""
    searchBox.Parent = frame

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox

    -- 滚动区域（高度280）
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -20, 0, 280)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 80)
    scrollingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.ScrollBarImageColor3 = Color3.new(0.5, 0.5, 0.5)
    scrollingFrame.Parent = frame

    -- 按钮容器
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, 0, 0, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = scrollingFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = buttonContainer

    -- 创建所有按钮并存储
    local buttons = {}
    for i, btnData in ipairs(BUTTONS) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.BackgroundColor3 = Color3.new(0.1, 0.5, 0.8)
        btn.Text = btnData.name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = buttonContainer

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            local args = btnData.args
            local success, result = pcall(function()
                return remotePath:InvokeServer(unpack(args))
            end)
            if success then
                print("成功执行: " .. btnData.name)
            else
                warn("执行失败: " .. btnData.name, result)
            end
        end)

        table.insert(buttons, { button = btn, name = btnData.name, data = btnData })
    end

    -- 更新CanvasSize
    local function updateCanvasSize()
        local contentHeight = listLayout.AbsoluteContentSize.Y
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight + 10)
    end

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    task.wait()
    updateCanvasSize()

    -- 搜索功能
    searchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            local searchText = searchBox.Text:lower()
            for _, item in ipairs(buttons) do
                item.button.Parent = nil
            end

            local matched = {}
            for _, item in ipairs(buttons) do
                if #searchText == 0 or item.name:lower():find(searchText, 1, true) then
                    table.insert(matched, item.button)
                end
            end

            for _, btn in ipairs(matched) do
                btn.Parent = buttonContainer
            end
        end
    end)

    -- 悬浮球
    local floatButton = Instance.new("TextButton")
    floatButton.Size = UDim2.new(0, 50, 0, 50)
    floatButton.Position = savedFloatPos
    floatButton.BackgroundColor3 = Color3.new(0.2, 0.6, 1)
    floatButton.Text = "⚙️"
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

    -- 主菜单拖动
    local dragging, dragInput, dragStart, startPos
    local function updateSavedMenuPos() savedMenuPos = frame.Position end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Handled = true
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    updateSavedMenuPos()
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragInput = input
                input.Handled = true
            end
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            savedMenuPos = frame.Position
            input.Handled = true
        end
    end)
end

Player:WaitForChild("PlayerGui")
createGUI()

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    createGUI()
end)

print("脚本已加载 | Made by Was")
