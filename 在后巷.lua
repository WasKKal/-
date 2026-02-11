local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

if not PlayerGui then
    repeat wait() until Player:FindFirstChild("PlayerGui")
    PlayerGui = Player:WaitForChild("PlayerGui")
end

print("垃圾中心 v1.0 加载中...")

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

-- 小按钮（折叠状态）
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

-- 边框
local Border1 = Instance.new("Frame")
Border1.Size = UDim2.new(1, 8, 1, 8)
Border1.Position = UDim2.new(0, -4, 0, -4)
Border1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Border1.BorderSizePixel = 0
Border1.ZIndex = -1
Border1.Parent = MinimizedButton

MinimizedButton.Parent = ScreenGui

-- 主菜单（展开状态）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false

-- 黑色边框
local OuterFrame = Instance.new("Frame")
OuterFrame.Size = UDim2.new(1, 10, 1, 10)
OuterFrame.Position = UDim2.new(0, -5, 0, -5)
OuterFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OuterFrame.ZIndex = -1
OuterFrame.Parent = MainFrame

local InnerFrame = Instance.new("Frame")
InnerFrame.Size = UDim2.new(1, 6, 1, 6)
InnerFrame.Position = UDim2.new(0, -3, 0, -3)
InnerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InnerFrame.ZIndex = -1
InnerFrame.Parent = OuterFrame

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitleBar.Parent = MainFrame

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

MainFrame.Parent = ScreenGui

-- 公告页面
local InfoFrame = Instance.new("Frame")
InfoFrame.Name = "InfoFrame"
InfoFrame.Size = UDim2.new(0, 320, 0, 280)
InfoFrame.Position = UDim2.new(0.5, -160, 0.5, -140)
InfoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
InfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InfoFrame.Visible = false

-- 公告边框
local InfoOuter = Instance.new("Frame")
InfoOuter.Size = UDim2.new(1, 10, 1, 10)
InfoOuter.Position = UDim2.new(0, -5, 0, -5)
InfoOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoOuter.ZIndex = -1
InfoOuter.Parent = InfoFrame

local InfoInner = Instance.new("Frame")
InfoInner.Size = UDim2.new(1, 6, 1, 6)
InfoInner.Position = UDim2.new(0, -3, 0, -3)
InfoInner.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoInner.ZIndex = -1
InfoInner.Parent = InfoOuter

-- 公告标题
local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, 0, 0, 40)
InfoTitle.Position = UDim2.new(0, 0, 0, 0)
InfoTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
InfoTitle.Text = "公告"
InfoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoTitle.TextSize = 20
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.Parent = InfoFrame

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
版本: 1.0
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

电脑:
• F9: 切换菜单
• 右键Shift: 快速出售
• ESC: 折叠菜单

更新日志:
v1.1 - 修复版本
• 基本出售功能
• 手机适配
• 公告系统

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
InfoFrame.Parent = ScreenGui

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

-- 移动端长按出售
if isMobile then
    local pressTime = 0
    MinimizedButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            pressTime = tick()
        end
    end)
    
    MinimizedButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            if tick() - pressTime > 0.8 then
                sellItems()
            end
        end
    end)
end

-- 移动端拖动
if isMobile then
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.TouchMoved:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function()
        dragging = false
    end)
end

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

print("在后巷 v1.1 加载完成")
print("作者: 蛙 | DeepSeek修复")