local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

if not PlayerGui then
    repeat wait() until Player:FindFirstChild("PlayerGui")
    PlayerGui = Player:WaitForChild("PlayerGui")
end

print("垃圾中心 v1.1 加载中...")

-- 物品列表
local allItems = {
    "scrap", "can", "nail", "sock", "cardboard",
    "bottle", "battery", "foil", "plastic", "paper",
    "cloth", "rock", "spring", "plank", "rotten",
    "tp", "spray", "penny", "quarter", "dirt",
    "worm", "lint", "butter", "gum"
}

print("物品: " .. #allItems .. " 种")

local isMobile = UserInputService.TouchEnabled
print("设备: " .. (isMobile and "手机" or "电脑"))

-- 创建界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TrashCenter"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 小按钮（折叠状态）- 修复拖拽问题
local MinimizedButton = Instance.new("TextButton")
MinimizedButton.Name = "MinimizedButton"
MinimizedButton.Size = UDim2.new(0, 75, 0, 75)
MinimizedButton.Position = UDim2.new(0, 20, 0.8, -37.5)
MinimizedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizedButton.BorderSizePixel = 3
MinimizedButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
MinimizedButton.Text = "💰"
MinimizedButton.TextColor3 = Color3.fromRGB(255, 215, 0)
MinimizedButton.TextSize = 28
MinimizedButton.Visible = true
MinimizedButton.ZIndex = 100  -- 提高层级
MinimizedButton.Parent = ScreenGui

-- 添加圆角
local MinimizedCorner = Instance.new("UICorner")
MinimizedCorner.CornerRadius = UDim.new(0, 12)
MinimizedCorner.Parent = MinimizedButton

-- 主菜单（展开状态）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.ZIndex = 90  -- 低于按钮
MainFrame.Parent = ScreenGui

-- 添加圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 黑色边框
local OuterFrame = Instance.new("Frame")
OuterFrame.Size = UDim2.new(1, 10, 1, 10)
OuterFrame.Position = UDim2.new(0, -5, 0, -5)
OuterFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OuterFrame.ZIndex = -1
OuterFrame.Parent = MainFrame

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0, 10)
OuterCorner.Parent = OuterFrame

local InnerFrame = Instance.new("Frame")
InnerFrame.Size = UDim2.new(1, 6, 1, 6)
InnerFrame.Position = UDim2.new(0, -3, 0, -3)
InnerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InnerFrame.ZIndex = -1
InnerFrame.Parent = OuterFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 8)
InnerCorner.Parent = InnerFrame

-- 标题栏（用于拖动）
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.Parent = MainFrame

-- 标题栏圆角
local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8, 0, 0)
TitleBarCorner.Parent = TitleBar

-- 标题
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "垃圾中心 - 在后巷"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- 公告按钮
local InfoButton = Instance.new("TextButton")
InfoButton.Name = "InfoButton"
InfoButton.Size = UDim2.new(0, 30, 0, 30)
InfoButton.Position = UDim2.new(1, -100, 0.5, -15)
InfoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 150)
InfoButton.Text = "i"
InfoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoButton.TextSize = 20
InfoButton.Font = Enum.Font.GothamBold
InfoButton.Parent = TitleBar

local InfoButtonCorner = Instance.new("UICorner")
InfoButtonCorner.CornerRadius = UDim.new(0, 6)
InfoButtonCorner.Parent = InfoButton

-- 折叠按钮
local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -65, 0.5, -15)
CollapseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CollapseButton.Text = "−"
CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseButton.TextSize = 24
CollapseButton.Font = Enum.Font.GothamBold
CollapseButton.Parent = TitleBar

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 6)
CollapseCorner.Parent = CollapseButton

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- 出售按钮
local SellButton = Instance.new("TextButton")
SellButton.Size = UDim2.new(0.9, 0, 0, 70)
SellButton.Position = UDim2.new(0.05, 0, 0.25, 0)
SellButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SellButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
SellButton.BorderSizePixel = 3
SellButton.Text = "一键出售所有物品"
SellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SellButton.TextSize = 18
SellButton.Font = Enum.Font.GothamBold
SellButton.Parent = MainFrame

local SellCorner = Instance.new("UICorner")
SellCorner.CornerRadius = UDim.new(0, 8)
SellCorner.Parent = SellButton

-- 状态文本
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(0.9, 0, 0, 25)
StatusText.Position = UDim2.new(0.05, 0, 0.7, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "点击出售" .. #allItems .. "种物品"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 14
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = MainFrame

-- 公告页面
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Size = UDim2.new(0, 320, 0, 280)
InfoFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
InfoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoFrame.Visible = false
InfoFrame.ZIndex = 90
InfoFrame.Parent = ScreenGui

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoFrame

-- 公告边框
local InfoOuter = Instance.new("Frame")
InfoOuter.Size = UDim2.new(1, 10, 1, 10)
InfoOuter.Position = UDim2.new(0, -5, 0, -5)
InfoOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoOuter.ZIndex = -1
InfoOuter.Parent = InfoFrame

local InfoOuterCorner = Instance.new("UICorner")
InfoOuterCorner.CornerRadius = UDim.new(0, 10)
InfoOuterCorner.Parent = InfoOuter

local InfoInner = Instance.new("Frame")
InfoInner.Size = UDim2.new(1, 6, 1, 6)
InfoInner.Position = UDim2.new(0, -3, 0, -3)
InfoInner.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoInner.ZIndex = -1
InfoInner.Parent = InfoOuter

local InfoInnerCorner = Instance.new("UICorner")
InfoInnerCorner.CornerRadius = UDim.new(0, 8)
InfoInnerCorner.Parent = InfoInner

-- 公告标题栏（用于拖动）
local InfoTitle = Instance.new("Frame")
InfoTitle.Size = UDim2.new(1, 0, 0, 40)
InfoTitle.Position = UDim2.new(0, 0, 0, 0)
InfoTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.Parent = InfoFrame

local InfoTitleCorner = Instance.new("UICorner")
InfoTitleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
InfoTitleCorner.Parent = InfoTitle

-- 公告标题文字
local InfoTitleText = Instance.new("TextLabel")
InfoTitleText.Size = UDim2.new(1, -70, 1, 0)
InfoTitleText.Position = UDim2.new(0, 10, 0, 0)
InfoTitleText.BackgroundTransparency = 1
InfoTitleText.Text = "公告"
InfoTitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitleText.TextSize = 20
InfoTitleText.Font = Enum.Font.GothamBold
InfoTitleText.TextXAlignment = Enum.TextXAlignment.Left
InfoTitleText.Parent = InfoTitle

-- 关闭公告按钮
local InfoCloseButton = Instance.new("TextButton")
InfoCloseButton.Size = UDim2.new(0, 30, 0, 30)
InfoCloseButton.Position = UDim2.new(1, -35, 0.5, -15)
InfoCloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
InfoCloseButton.Text = "X"
InfoCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoCloseButton.TextSize = 18
InfoCloseButton.Font = Enum.Font.GothamBold
InfoCloseButton.Parent = InfoTitle

local InfoCloseCorner = Instance.new("UICorner")
InfoCloseCorner.CornerRadius = UDim.new(0, 6)
InfoCloseCorner.Parent = InfoCloseButton

-- 公告内容滚动框
local InfoScroll = Instance.new("ScrollingFrame")
InfoScroll.Size = UDim2.new(1, -20, 1, -60)
InfoScroll.Position = UDim2.new(0, 10, 0, 50)
InfoScroll.BackgroundTransparency = 1
InfoScroll.BorderSizePixel = 0
InfoScroll.CanvasSize = UDim2.new(0, 0, 0, 400)
InfoScroll.ScrollBarThickness = 6

-- 公告内容
local InfoContent = Instance.new("TextLabel")
InfoContent.Size = UDim2.new(1, 0, 0, 400)
InfoContent.Position = UDim2.new(0, 0, 0, 0)
InfoContent.BackgroundTransparency = 1
InfoContent.Text = [[
版本: 1.1
作者: 蛙
本脚本由DeepSeek修复与检查功能

--- 垃圾中心使用说明 ---

功能:
• 一键出售24种物品
• 手机/电脑双端适配
• 折叠菜单节省空间

操作:
手机:
• 点击💰展开菜单
• 长按💰直接出售
• 点击"i"查看公告
• 拖动标题栏移动窗口

电脑:
• F9: 切换菜单
• 右键Shift: 快速出售
• ESC: 折叠菜单

更新日志:
v1.2 - 修复版本
• 修复触摸拖动问题
• 防止视角跟随移动
• 优化界面响应

技术支持:
如有问题请联系作者
]]
InfoContent.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoContent.TextSize = 14
InfoContent.Font = Enum.Font.Gotham
InfoContent.TextXAlignment = Enum.TextXAlignment.Left
InfoContent.TextYAlignment = Enum.TextYAlignment.Top
InfoContent.TextWrapped = true
InfoContent.Parent = InfoScroll

InfoScroll.Parent = InfoFrame

-- 按钮效果
if not isMobile then
    local function setupHover(button, normal, hover)
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hover
        end)
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = normal
        end)
    end
    
    setupHover(CollapseButton, Color3.fromRGB(60,60,60), Color3.fromRGB(80,80,80))
    setupHover(CloseButton, Color3.fromRGB(200,50,50), Color3.fromRGB(220,70,70))
    setupHover(InfoButton, Color3.fromRGB(60,60,150), Color3.fromRGB(80,80,180))
    setupHover(SellButton, Color3.fromRGB(40,40,40), Color3.fromRGB(50,50,50))
    setupHover(InfoCloseButton, Color3.fromRGB(200,50,50), Color3.fromRGB(220,70,70))
    setupHover(MinimizedButton, Color3.fromRGB(40,40,40), Color3.fromRGB(60,60,60))
end

-- 出售功能
local function sellItems()
    local args = {allItems}
    
    StatusText.Text = "出售中..."
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    
    local success, err = pcall(function()
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SellTrash"):FireServer(unpack(args))
    end)
    
    if success then
        SellButton.Text = "✓ 出售成功!"
        SellButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        StatusText.Text = "成功出售" .. #allItems .. "种物品"
        StatusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        wait(2)
        
        SellButton.Text = "一键出售所有物品"
        SellButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        StatusText.Text = "点击出售" .. #allItems .. "种物品"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        SellButton.Text = "✗ 出售失败"
        SellButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        StatusText.Text = "错误: " .. tostring(err)
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        wait(2)
        
        SellButton.Text = "一键出售所有物品"
        SellButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        StatusText.Text = "点击出售" .. #allItems .. "种物品"
        StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- 折叠菜单
local function collapseMenu()
    MainFrame.Visible = false
    InfoFrame.Visible = false
    MinimizedButton.Visible = true
end

-- 展开菜单
local function expandMenu()
    MinimizedButton.Visible = false
    MainFrame.Visible = true
end

-- 显示公告
local function showInfo()
    InfoFrame.Visible = true
    MainFrame.Visible = false
end

-- 隐藏公告
local function hideInfo()
    InfoFrame.Visible = false
    MainFrame.Visible = true
end

-- 按钮事件
CollapseButton.MouseButton1Click:Connect(collapseMenu)
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
SellButton.MouseButton1Click:Connect(sellItems)
MinimizedButton.MouseButton1Click:Connect(expandMenu)
InfoButton.MouseButton1Click:Connect(showInfo)
InfoCloseButton.MouseButton1Click:Connect(hideInfo)

-- 修复：小按钮的拖动功能（不干扰点击）
local minimizedDragging = false
local minimizedDragStart, minimizedStartPos

MinimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        minimizedDragging = false
        minimizedDragStart = input.Position
        minimizedStartPos = MinimizedButton.Position
        
        -- 开始计时，区分点击和拖动
        local startTime = tick()
        local button = MinimizedButton
        
        -- 等待短暂时间判断是否是拖动
        task.wait(0.1)
        
        if minimizedDragging == false then
            -- 不是拖动，开始长按计时
            local pressTime = 0
            
            -- 长按出售（2秒）
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) do
                pressTime = tick() - startTime
                if pressTime > 0.8 then
                    -- 长按超过0.8秒，开始拖动
                    minimizedDragging = true
                    break
                end
                task.wait()
            end
            
            if not minimizedDragging and pressTime > 0 then
                -- 短按，展开菜单
                expandMenu()
            end
        end
    end
end)

-- 移动端拖动（不干扰Roblox视角）
local mainDragging = false
local mainDragStart, mainStartPos
local infoDragging = false
local infoDragStart, infoStartPos

-- 主窗口拖动
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = MainFrame.Position
        
        -- 阻止事件传递，防止Roblox视角移动
        input:Capture()
    end
end)

-- 公告窗口拖动
InfoTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        infoDragging = true
        infoDragStart = input.Position
        infoStartPos = InfoFrame.Position
        
        -- 阻止事件传递，防止Roblox视角移动
        input:Capture()
    end
end)

-- 小按钮拖动
MinimizedButton.InputChanged:Connect(function(input)
    if minimizedDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - minimizedDragStart
        MinimizedButton.Position = UDim2.new(
            minimizedStartPos.X.Scale, 
            minimizedStartPos.X.Offset + delta.X,
            minimizedStartPos.Y.Scale, 
            minimizedStartPos.Y.Offset + delta.Y
        )
        
        -- 边界检查（可选）
        local pos = MinimizedButton.AbsolutePosition
        local size = MinimizedButton.AbsoluteSize
        local screenSize = workspace.CurrentCamera.ViewportSize
        
        if pos.X < 0 then
            MinimizedButton.Position = UDim2.new(0, 0, MinimizedButton.Position.Y.Scale, MinimizedButton.Position.Y.Offset)
        elseif pos.X + size.X > screenSize.X then
            MinimizedButton.Position = UDim2.new(0, screenSize.X - size.X, MinimizedButton.Position.Y.Scale, MinimizedButton.Position.Y.Offset)
        end
        
        if pos.Y < 0 then
            MinimizedButton.Position = UDim2.new(MinimizedButton.Position.X.Scale, MinimizedButton.Position.X.Offset, 0, 0)
        elseif pos.Y + size.Y > screenSize.Y then
            MinimizedButton.Position = UDim2.new(MinimizedButton.Position.X.Scale, MinimizedButton.Position.X.Offset, 0, screenSize.Y - size.Y)
        end
    end
end)

-- 主窗口拖动
UserInputService.InputChanged:Connect(function(input)
    if mainDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - mainDragStart
        MainFrame.Position = UDim2.new(
            mainStartPos.X.Scale, 
            mainStartPos.X.Offset + delta.X,
            mainStartPos.Y.Scale, 
            mainStartPos.Y.Offset + delta.Y
        )
        
        -- 边界检查（可选）
        local pos = MainFrame.AbsolutePosition
        local size = MainFrame.AbsoluteSize
        local screenSize = workspace.CurrentCamera.ViewportSize
        
        if pos.X < 10 then
            MainFrame.Position = UDim2.new(0, 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)
        elseif pos.X + size.X > screenSize.X - 10 then
            MainFrame.Position = UDim2.new(0, screenSize.X - size.X - 10, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset)
        end
        
        if pos.Y < 10 then
            MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, 10)
        elseif pos.Y + size.Y > screenSize.Y - 10 then
            MainFrame.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, 0, screenSize.Y - size.Y - 10)
        end
    end
    
    if infoDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - infoDragStart
        InfoFrame.Position = UDim2.new(
            infoStartPos.X.Scale, 
            infoStartPos.X.Offset + delta.X,
            infoStartPos.Y.Scale, 
            infoStartPos.Y.Offset + delta.Y
        )
        
        -- 边界检查（可选）
        local pos = InfoFrame.AbsolutePosition
        local size = InfoFrame.AbsoluteSize
        local screenSize = workspace.CurrentCamera.ViewportSize
        
        if pos.X < 10 then
            InfoFrame.Position = UDim2.new(0, 10, InfoFrame.Position.Y.Scale, InfoFrame.Position.Y.Offset)
        elseif pos.X + size.X > screenSize.X - 10 then
            InfoFrame.Position = UDim2.new(0, screenSize.X - size.X - 10, InfoFrame.Position.Y.Scale, InfoFrame.Position.Y.Offset)
        end
        
        if pos.Y < 10 then
            InfoFrame.Position = UDim2.new(InfoFrame.Position.X.Scale, InfoFrame.Position.X.Offset, 0, 10)
        elseif pos.Y + size.Y > screenSize.Y - 10 then
            InfoFrame.Position = UDim2.new(InfoFrame.Position.X.Scale, InfoFrame.Position.X.Offset, 0, screenSize.Y - size.Y - 10)
        end
    end
end)

-- 结束拖动
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
        infoDragging = false
        minimizedDragging = false
    end
end)

-- 键盘快捷键
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F9 then
            if MainFrame.Visible or InfoFrame.Visible then
                collapseMenu()
            else
                expandMenu()
            end
        elseif input.KeyCode == Enum.KeyCode.RightShift then
            local args = {allItems}
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SellTrash"):FireServer(unpack(args))
            end)
        elseif input.KeyCode == Enum.KeyCode.Escape then
            if InfoFrame.Visible then
                hideInfo()
            elseif MainFrame.Visible then
                collapseMenu()
            end
        end
    end
end)

print("在后巷 v1.2 加载完成")
print("作者: 蛙 | DeepSeek修复")
