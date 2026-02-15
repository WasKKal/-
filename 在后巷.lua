local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 传送点坐标
local TELEPORT_POSITIONS = {
    backalley = CFrame.new(12.6739998, 7, -54.512001),
    dump      = CFrame.new(126.671417, 7, -244.65538),
    street    = CFrame.new(476.21228, 34, -166.603027),
    shop      = CFrame.new(-123.315865, 4, -151.743851)
}

-- GUI保存位置
local savedFloatPos = UDim2.new(0.5, -25, 0.5, -25)
local savedMenuPos = UDim2.new(0, 10, 0, 10)

local function getCharacter()
    return Player.Character or Player.CharacterAdded:Wait()
end

local function createGUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local existing = PlayerGui:FindFirstChild("TeleportSellGUI")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TeleportSellGUI"
    screenGui.Parent = PlayerGui

    -- 主框架
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 265)
    frame.Position = savedMenuPos
    frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = frame

    -- 标题
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
    titleLabel.Text = "垃圾中心 - 在后巷模拟器"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = titleBar

    -- 传送按钮（后巷）
    local teleportBack = Instance.new("TextButton")
    teleportBack.Size = UDim2.new(0, 180, 0, 40)
    teleportBack.Position = UDim2.new(0, 10, 0, 35)
    teleportBack.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    teleportBack.Text = "后巷"
    teleportBack.TextColor3 = Color3.new(1, 1, 1)
    teleportBack.Font = Enum.Font.GothamBold
    teleportBack.TextSize = 16
    teleportBack.BorderSizePixel = 0
    teleportBack.Parent = frame

    -- 传送按钮（垃圾场）
    local teleportDump = Instance.new("TextButton")
    teleportDump.Size = UDim2.new(0, 180, 0, 40)
    teleportDump.Position = UDim2.new(0, 10, 0, 80)
    teleportDump.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    teleportDump.Text = "垃圾场"
    teleportDump.TextColor3 = Color3.new(1, 1, 1)
    teleportDump.Font = Enum.Font.GothamBold
    teleportDump.TextSize = 16
    teleportDump.BorderSizePixel = 0
    teleportDump.Parent = frame

    -- 传送按钮（街道）
    local teleportStreet = Instance.new("TextButton")
    teleportStreet.Size = UDim2.new(0, 180, 0, 40)
    teleportStreet.Position = UDim2.new(0, 10, 0, 125)
    teleportStreet.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    teleportStreet.Text = "街道"
    teleportStreet.TextColor3 = Color3.new(1, 1, 1)
    teleportStreet.Font = Enum.Font.GothamBold
    teleportStreet.TextSize = 16
    teleportStreet.BorderSizePixel = 0
    teleportStreet.Parent = frame

    -- 传送按钮（商店）
    local teleportShop = Instance.new("TextButton")
    teleportShop.Size = UDim2.new(0, 180, 0, 40)
    teleportShop.Position = UDim2.new(0, 10, 0, 170)
    teleportShop.BackgroundColor3 = Color3.new(0.1, 0.6, 0.1)
    teleportShop.Text = "商店"
    teleportShop.TextColor3 = Color3.new(1, 1, 1)
    teleportShop.Font = Enum.Font.GothamBold
    teleportShop.TextSize = 16
    teleportShop.BorderSizePixel = 0
    teleportShop.Parent = frame

    -- 出售按钮
    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0, 180, 0, 40)
    sellButton.Position = UDim2.new(0, 10, 0, 215)
    sellButton.BackgroundColor3 = Color3.new(0.8, 0.5, 0.1)
    sellButton.Text = "一键出售所有垃圾"
    sellButton.TextColor3 = Color3.new(1, 1, 1)
    sellButton.Font = Enum.Font.GothamBold
    sellButton.TextSize = 16
    sellButton.BorderSizePixel = 0
    sellButton.Parent = frame

    -- 为所有按钮添加圆角
    for _, btn in ipairs({teleportBack, teleportDump, teleportStreet, teleportShop, sellButton}) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = btn
    end

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

    -- 悬浮球拖动（阻止事件穿透）
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

    -- 主菜单拖动（阻止事件穿透）
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

    -- 传送功能
    teleportBack.MouseButton1Click:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = TELEPORT_POSITIONS.backalley
        end
    end)

    teleportDump.MouseButton1Click:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = TELEPORT_POSITIONS.dump
        end
    end)

    teleportStreet.MouseButton1Click:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = TELEPORT_POSITIONS.street
        end
    end)

    teleportShop.MouseButton1Click:Connect(function()
        local char = getCharacter()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = TELEPORT_POSITIONS.shop
        end
    end)

    -- 一键出售
    sellButton.MouseButton1Click:Connect(function()
        -- 完整物品列表
        local allItems = {
            "can", "nail", "cardboard", "foil", "plastic", "lightbulb", "paper", "scrap", "sock", "bottle", "battery", "cloth", "rock", "spring", "plank", "rotten", "tp", "spray", "penny", "quarter", "dirt", "worm", "lint", "butter", "gum", "ancienttv", "metal", "rusty", "pipe", "pumpkin", "motherboard", "goldring", "monitor", "vintage", "bigcoal", "tincan", "creditcard", "reindeer", "rottencheese", "elf", "torncloth", "dove", "chocolates", "usedcheeto", "golddoublo", "toiletpaper", "emptyspray", "liberty2014", "liberty", "heart", "comicbook", "hat", "crocs", "log", "brick", "fish", "brokenradio", "phone", "shoe", "tradingcard", "brokenlightbulb", "poop", "watch", "goldtooth", "twig", "wig", "rottenbeef", "pants", "harddrive", "glassshard", "wires", "mcburger"
        }

        -- 分割函数：将列表分成每块最多25个
        local function splitIntoChunks(list, chunkSize)
            local chunks = {}
            for i = 1, #list, chunkSize do
                local endIndex = math.min(i + chunkSize - 1, #list)
                table.insert(chunks, { table.unpack(list, i, endIndex) })
            end
            return chunks
        end

        local chunks = splitIntoChunks(allItems, 25)
        local sellEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("SellTrash")

        for i, chunk in ipairs(chunks) do
            local args = { chunk }  -- 构造与原始格式一致的数据包
            sellEvent:FireServer(unpack(args))
            print(string.format("已发送第 %d 块出售请求（%d 个物品）", i, #chunk))
            task.wait(0.1)  -- 短暂延迟避免服务器压力
        end

        print("所有物品出售请求发送完成，总物品数：" .. #allItems)
    end)
end

Player:WaitForChild("PlayerGui")
createGUI()

Player.CharacterAdded:Connect(function()
    task.wait(0.5)
    createGUI()
end)

print("脚本已加载")
