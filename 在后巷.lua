local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

if not PlayerGui then
    repeat wait() until Player:FindFirstChild("PlayerGui")
    PlayerGui = Player:WaitForChild("PlayerGui")
end

print("垃圾中心 v1.4 加载中...")

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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = PlayerGui

-- 小按钮（折叠状态）- 修复拖拽问题
local MinimizedButton = Instance.new("TextButton")
MinimizedButton.Name = "MinimizedButton"
MinimizedButton.Size = UDim2.new(0, 75, 0, 75)
MinimizedButton.Position = UDim2.new(0, 20, 0.8, -37.5)
MinimizedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizedButton.BorderSizePixel = 3
MinimizedButton.BorderColor3 = Color3.fromRGB(255, 215, 0)
MinimizedButton.Text = "💰"
MinimizedButton.TextColor3 = Color3.fromRGB(255, 215, 0)
MinimizedButton.TextSize = 28
MinimizedButton.Visible = true
MinimizedButton.ZIndex = 1000
MinimizedButton.Parent = ScreenGui

-- 添加圆角
local MinimizedCorner = Instance.new("UICorner")
MinimizedCorner.CornerRadius = UDim.new(0, 12)
MinimizedCorner.Parent = MinimizedButton

-- 主菜单（展开状态）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.ZIndex = 900
MainFrame.Parent = ScreenGui

-- 添加圆角
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- 黑色边框（作为主背景，确保内容可见）
local OuterFrame = Instance.new("Frame")
OuterFrame.Size = UDim2.new(1, 0, 1, 0)
OuterFrame.Position = UDim2.new(0, 0, 0, 0)
OuterFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OuterFrame.ZIndex = 1
OuterFrame.Parent = MainFrame

local OuterCorner = Instance.new("UICorner")
OuterCorner.CornerRadius = UDim.new(0, 8)
OuterCorner.Parent = OuterFrame

-- 内部边框装饰
local BorderFrame = Instance.new("Frame")
BorderFrame.Size = UDim2.new(1, 4, 1, 4)
BorderFrame.Position = UDim2.new(0, -2, 0, -2)
BorderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BorderFrame.ZIndex = 0
BorderFrame.Parent = MainFrame

local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 10)
BorderCorner.Parent = BorderFrame

-- 标题栏（用于拖动）
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
TitleBar.ZIndex = 902
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
Title.ZIndex = 903
Title.Parent = TitleBar

-- 公告按钮
local InfoButton = Instance.new("TextButton")
InfoButton.Name = "InfoButton"
InfoButton.Size = UDim2.new(0, 30, 0, 30)
InfoButton.Position = UDim2.new(1, -100, 0.5, -15)
InfoButton.BackgroundColor3 = Color3.fromRGB(70, 70, 180)
InfoButton.Text = "i"
InfoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoButton.TextSize = 20
InfoButton.Font = Enum.Font.GothamBold
InfoButton.ZIndex = 904
InfoButton.Parent = TitleBar

local InfoButtonCorner = Instance.new("UICorner")
InfoButtonCorner.CornerRadius = UDim.new(0, 6)
InfoButtonCorner.Parent = InfoButton

-- 折叠按钮
local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -65, 0.5, -15)
CollapseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
CollapseButton.Text = "−"
CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseButton.TextSize = 24
CollapseButton.Font = Enum.Font.GothamBold
CollapseButton.ZIndex = 904
CollapseButton.Parent = TitleBar

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 6)
CollapseCorner.Parent = CollapseButton

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.ZIndex = 904
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- 内容区域
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -60)
ContentFrame.Position = UDim2.new(0, 10, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ZIndex = 902
ContentFrame.Parent = MainFrame

-- 出售按钮
local SellButton = Instance.new("TextButton")
SellButton.Size = UDim2.new(1, 0, 0, 80)
SellButton.Position = UDim2.new(0, 0, 0, 10)
SellButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
SellButton.BorderColor3 = Color3.fromRGB(100, 200, 100)
SellButton.BorderSizePixel = 3
SellButton.Text = "一键出售所有物品"
SellButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SellButton.TextSize = 20
SellButton.Font = Enum.Font.GothamBold
SellButton.ZIndex = 905
SellButton.Parent = ContentFrame

local SellCorner = Instance.new("UICorner")
SellCorner.CornerRadius = UDim.new(0, 8)
SellCorner.Parent = SellButton

-- 状态文本
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 30)
StatusText.Position = UDim2.new(0, 0, 0, 100)
StatusText.BackgroundTransparency = 1
StatusText.Text = "点击出售" .. #allItems .. "种物品"
StatusText.TextColor3 = Color3.fromRGB(220, 220, 220)
StatusText.TextSize = 16
StatusText.Font = Enum.Font.Gotham
StatusText.ZIndex = 905
StatusText.Parent = ContentFrame

-- 公告页面
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Size = UDim2.new(0, 340, 0, 300)
InfoFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
InfoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoFrame.Visible = false
InfoFrame.ZIndex = 900
InfoFrame.Parent = ScreenGui

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoFrame

-- 公告背景
local InfoBackground = Instance.new("Frame")
InfoBackground.Size = UDim2.new(1, 0, 1, 0)
InfoBackground.Position = UDim2.new(0, 0, 0, 0)
InfoBackground.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
InfoBackground.ZIndex = 901
InfoBackground.Parent = InfoFrame

local InfoBackgroundCorner = Instance.new("UICorner")
InfoBackgroundCorner.CornerRadius = UDim.new(0, 8)
InfoBackgroundCorner.Parent = InfoBackground

-- 公告边框装饰
local InfoBorder = Instance.new("Frame")
InfoBorder.Size = UDim2.new(1, 4, 1, 4)
InfoBorder.Position = UDim2.new(0, -2, 0, -2)
InfoBorder.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
InfoBorder.ZIndex = 900
InfoBorder.Parent = InfoFrame

local InfoBorderCorner = Instance.new("UICorner")
InfoBorderCorner.CornerRadius = UDim.new(0, 10)
InfoBorderCorner.Parent = InfoBorder

-- 公告标题栏（用于拖动） - 修复：确保可以触摸
local InfoTitle = Instance.new("Frame")
InfoTitle.Size = UDim2.new(1, 0, 0, 40)
InfoTitle.Position = UDim2.new(0, 0, 0, 0)
InfoTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 60)
InfoTitle.ZIndex = 902
InfoTitle.Active = true  -- 添加这个！
InfoTitle.Parent = InfoFrame

local InfoTitleCorner = Instance.new("UICorner")
InfoTitleCorner.CornerRadius = UDim.new(0, 8, 0, 0)
InfoTitleCorner.Parent = InfoTitle

-- 公告标题文字
local InfoTitleText = Instance.new("TextLabel")
InfoTitleText.Size = UDim2.new(1, -70, 1, 0)
InfoTitleText.Position = UDim2.new(0, 10, 0, 0)
InfoTitleText.BackgroundTransparency = 1
InfoTitleText.Text = "📢 公告"
InfoTitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitleText.TextSize = 20
InfoTitleText.Font = Enum.Font.GothamBold
InfoTitleText.TextXAlignment = Enum.TextXAlignment.Left
InfoTitleText.ZIndex = 903
InfoTitleText.Parent = InfoTitle

-- 关闭公告按钮
local InfoCloseButton = Instance.new("TextButton")
InfoCloseButton.Size = UDim2.new(0, 30, 0, 30)
InfoCloseButton.Position = UDim2.new(1, -35, 0.5, -15)
InfoCloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
InfoCloseButton.Text = "X"
InfoCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoCloseButton.TextSize = 18
InfoCloseButton.Font = Enum.Font.GothamBold
InfoCloseButton.ZIndex = 904
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
InfoScroll.ScrollBarThickness = 8
InfoScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
InfoScroll.ZIndex = 905
InfoScroll.Parent = InfoFrame

-- 公告内容
local InfoContent = Instance.new("TextLabel")
InfoContent.Size = UDim2.new(1, -5, 0, 400)
InfoContent.Position = UDim2.new(0, 5, 0, 5)
InfoContent.BackgroundTransparency = 1
InfoContent.Text = [[
版本: 1.4
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
• 长按💰拖动按钮
• 点击"i"查看公告
• 拖动标题栏移动窗口

电脑:
• F9: 切换菜单
• 右键Shift: 快速出售
• ESC: 折叠菜单

更新日志:
v1.4 - 修复版本
• 修复公告窗口拖动
• 修复悬浮窗按钮消失
• 优化触摸交互

技术支持:
如有问题请联系作者
]]
InfoContent.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoContent.TextSize = 14
InfoContent.Font = Enum.Font.Gotham
InfoContent.TextXAlignment = Enum.TextXAlignment.Left
InfoContent.TextYAlignment = Enum.TextYAlignment.Top
InfoContent.TextWrapped = true
InfoContent.ZIndex = 906
InfoContent.Parent = InfoScroll

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
    
    setupHover(CollapseButton, Color3.fromRGB(80,80,80), Color3.fromRGB(100,100,100))
    setupHover(CloseButton, Color3.fromRGB(220,60,60), Color3.fromRGB(240,80,80))
    setupHover(InfoButton, Color3.fromRGB(70,70,180), Color3.fromRGB(90,90,200))
    setupHover(SellButton, Color3.fromRGB(50,120,50), Color3.fromRGB(60,140,60))
    setupHover(InfoCloseButton, Color3.fromRGB(220,60,60), Color3.fromRGB(240,80,80))
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
        SellButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        StatusText.Text = "点击出售" .. #allItems .. "种物品"
        StatusText.TextColor3 = Color3.fromRGB(220, 220, 220)
    else
        SellButton.Text = "✗ 出售失败"
        SellButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        StatusText.Text = "错误: " .. tostring(err)
        StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        
        wait(2)
        
        SellButton.Text = "一键出售所有物品"
        SellButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
        StatusText.Text = "点击出售" .. #allItems .. "种物品"
        StatusText.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end

-- 折叠菜单 - 修复：隐藏时显示悬浮窗按钮
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

-- 显示公告 - 修复：不隐藏悬浮窗按钮
local function showInfo()
    InfoFrame.Visible = true
    MainFrame.Visible = false
    MinimizedButton.Visible = false  -- 公告显示时也隐藏悬浮窗按钮
end

-- 隐藏公告 - 修复：返回主菜单
local function hideInfo()
    InfoFrame.Visible = false
    MainFrame.Visible = true
    MinimizedButton.Visible = false  -- 主菜单显示时隐藏悬浮窗按钮
end

-- 按钮事件
CollapseButton.MouseButton1Click:Connect(collapseMenu)
CloseButton.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
    print("脚本已关闭")
end)
SellButton.MouseButton1Click:Connect(sellItems)
MinimizedButton.MouseButton1Click:Connect(expandMenu)
InfoButton.MouseButton1Click:Connect(showInfo)
InfoCloseButton.MouseButton1Click:Connect(hideInfo)

-- 修复：小按钮的拖动功能 - 简化版本
MinimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local startPos = input.Position
        local startTime = tick()
        
        -- 等待判断是点击还是拖动
        wait(0.2)
        
        -- 如果还在按住，则开始拖动
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) then
            -- 开始拖动
            while UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch) do
                local currentPos = UserInputService:GetMouseLocation()
                local delta = currentPos - startPos
                
                MinimizedButton.Position = UDim2.new(
                    0, MinimizedButton.Position.X.Offset + delta.X,
                    0, MinimizedButton.Position.Y.Offset + delta.Y
                )
                
                startPos = currentPos
                wait()
            end
        else
            -- 点击，展开菜单
            expandMenu()
        end
    end
end)

-- 移动端拖动 - 修复公告窗口拖动
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
        input:Capture()
    end
end)

-- 公告窗口拖动 - 修复：确保InfoTitle可以接收触摸
InfoTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        infoDragging = true
        infoDragStart = input.Position
        infoStartPos = InfoFrame.Position
        input:Capture()
        print("公告窗口开始拖动")
    end
end)

-- 拖动处理
UserInputService.InputChanged:Connect(function(input)
    if mainDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - mainDragStart
        MainFrame.Position = UDim2.new(
            0, mainStartPos.X.Offset + delta.X,
            0, mainStartPos.Y.Offset + delta.Y
        )
    end
    
    if infoDragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - infoDragStart
        InfoFrame.Position = UDim2.new(
            0, infoStartPos.X.Offset + delta.X,
            0, infoStartPos.Y.Offset + delta.Y
        )
        print("公告窗口拖动中...")
    end
end)

-- 结束拖动
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        mainDragging = false
        infoDragging = false
        print("拖动结束")
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

print("在后巷 v1.4 加载完成")
print("作者: 蛙 | DeepSeek修复")
