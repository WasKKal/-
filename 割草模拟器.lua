local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local GrassCollectRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GrassCollect")
local UpgradeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Upgrade")
local UpgradeTreeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpgradeTree")

local isMobile = UserInputService.TouchEnabled

-- 检查是否已存在脚本界面，防止重复创建
if player:WaitForChild("PlayerGui"):FindFirstChild("AutoGrassFarmMobile") then
    player:WaitForChild("PlayerGui"):FindFirstChild("AutoGrassFarmMobile"):Destroy()
end

-- 创建界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoGrassFarmMobile"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- 可移动的显示/隐藏按钮
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 80, 0, 60)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "🌿"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 18
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Visible = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 22)
ToggleCorner.Parent = ToggleButton

-- 主菜单（调整高度）
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 500) -- 增加高度以适应新功能
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "垃圾中心 - 割草模拟器"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- 内容区域
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -12, 1, -40)
ContentFrame.Position = UDim2.new(0, 6, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

-- 选项卡
local TabButtons = {}
local TabFrames = {}

local tabs = {
    {Name = "收集", Icon = "💰"},
    {Name = "升级", Icon = "⬆️"},
    {Name = "设置", Icon = "⚙️"}
}

for i, tab in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tab.Name .. "Tab"
    TabButton.Size = UDim2.new(1/3, -3, 0, 28)
    TabButton.Position = UDim2.new((i-1)/3, 1, 0, 0)
    TabButton.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
    TabButton.Text = tab.Icon .. " " .. tab.Name
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 10
    TabButton.Parent = ContentFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 5)
    TabCorner.Parent = TabButton
    
    table.insert(TabButtons, TabButton)
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = tab.Name .. "Frame"
    TabFrame.Size = UDim2.new(1, 0, 1, -35)
    TabFrame.Position = UDim2.new(0, 0, 0, 33)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = i == 1
    TabFrame.Parent = ContentFrame
    
    table.insert(TabFrames, TabFrame)
    
    TabButton.MouseButton1Click:Connect(function()
        for j, frame in ipairs(TabFrames) do
            frame.Visible = j == i
            TabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
        end
    end)
end

-- 收集选项卡
local CollectFrame = TabFrames[1]

local collectTypes = {
    {Name = "普通", Value = "normal", Color = Color3.fromRGB(100, 200, 100)},
    {Name = "红宝石", Value = "ruby", Color = Color3.fromRGB(200, 60, 60)},
    {Name = "银", Value = "silver", Color = Color3.fromRGB(180, 180, 180)},
    {Name = "金", Value = "golden", Color = Color3.fromRGB(255, 215, 0)},
    {Name = "钻石", Value = "diamond", Color = Color3.fromRGB(100, 200, 255)}
}

local selectedCollectType = "golden"
local CollectTypeButtons = {}

for i, collectType in ipairs(collectTypes) do
    local TypeButton = Instance.new("TextButton")
    TypeButton.Name = collectType.Value .. "Button"
    TypeButton.Size = UDim2.new(0.48, 0, 0, 32)
    
    local col = (i-1) % 2
    local row = math.floor((i-1) / 2)
    TypeButton.Position = UDim2.new(col * 0.5, col * 4, 0, 5 + row * 37)
    
    TypeButton.BackgroundColor3 = selectedCollectType == collectType.Value and collectType.Color or Color3.fromRGB(60, 60, 60)
    TypeButton.Text = collectType.Name
    TypeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TypeButton.Font = Enum.Font.Gotham
    TypeButton.TextSize = 10
    TypeButton.Parent = CollectFrame
    
    local TypeCorner = Instance.new("UICorner")
    TypeCorner.CornerRadius = UDim.new(0, 5)
    TypeCorner.Parent = TypeButton
    
    TypeButton.MouseButton1Click:Connect(function()
        selectedCollectType = collectType.Value
        for j, button in ipairs(CollectTypeButtons) do
            if collectTypes[j].Value == selectedCollectType then
                button.BackgroundColor3 = collectTypes[j].Color
            else
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
    end)
    
    table.insert(CollectTypeButtons, TypeButton)
end

-- 收集次数
local collectAmount = 1
local CollectAmountLabel = Instance.new("TextLabel")
CollectAmountLabel.Name = "CollectAmountLabel"
CollectAmountLabel.Size = UDim2.new(1, 0, 0, 18)
CollectAmountLabel.Position = UDim2.new(0, 0, 0, 115)
CollectAmountLabel.BackgroundTransparency = 1
CollectAmountLabel.Text = "收集次数: 1"
CollectAmountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CollectAmountLabel.Font = Enum.Font.Gotham
CollectAmountLabel.TextSize = 11
CollectAmountLabel.TextXAlignment = Enum.TextXAlignment.Left
CollectAmountLabel.Parent = CollectFrame

local AmountSlider = Instance.new("TextButton")
AmountSlider.Name = "AmountSlider"
AmountSlider.Size = UDim2.new(1, 0, 0, 14)
AmountSlider.Position = UDim2.new(0, 0, 0, 138)
AmountSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AmountSlider.Text = ""
AmountSlider.Parent = CollectFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 7)
SliderCorner.Parent = AmountSlider

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
SliderFill.Parent = AmountSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 7)
FillCorner.Parent = SliderFill

-- 快速次数按钮
local quickAmounts = {1, 5, 10, 25, 50}
local QuickAmountFrame = Instance.new("Frame")
QuickAmountFrame.Name = "QuickAmountFrame"
QuickAmountFrame.Size = UDim2.new(1, 0, 0, 28)
QuickAmountFrame.Position = UDim2.new(0, 0, 0, 157)
QuickAmountFrame.BackgroundTransparency = 1
QuickAmountFrame.Parent = CollectFrame

for i, amount in ipairs(quickAmounts) do
    local QuickButton = Instance.new("TextButton")
    QuickButton.Name = "Quick" .. amount
    QuickButton.Size = UDim2.new(0.19, -2, 1, 0)
    QuickButton.Position = UDim2.new((i-1)/5, 0, 0, 0)
    QuickButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    QuickButton.Text = tostring(amount)
    QuickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    QuickButton.Font = Enum.Font.Gotham
    QuickButton.TextSize = 9
    QuickButton.Parent = QuickAmountFrame
    
    local QuickCorner = Instance.new("UICorner")
    QuickCorner.CornerRadius = UDim.new(0, 3)
    QuickCorner.Parent = QuickButton
    
    QuickButton.MouseButton1Click:Connect(function()
        collectAmount = amount
        CollectAmountLabel.Text = "收集次数: " .. collectAmount
        SliderFill.Size = UDim2.new((collectAmount-1)/99, 0, 1, 0)
    end)
end

-- 收集按钮
local CollectButton = Instance.new("TextButton")
CollectButton.Name = "CollectButton"
CollectButton.Size = UDim2.new(1, 0, 0, 40)
CollectButton.Position = UDim2.new(0, 0, 0, 195)
CollectButton.BackgroundColor3 = Color3.fromRGB(70, 150, 70)
CollectButton.Text = "开始收集"
CollectButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollectButton.Font = Enum.Font.GothamBold
CollectButton.TextSize = 13
CollectButton.Parent = CollectFrame

local CollectCorner = Instance.new("UICorner")
CollectCorner.CornerRadius = UDim.new(0, 7)
CollectCorner.Parent = CollectButton

-- 升级选项卡 - 完全重新设计
local UpgradeFrame = TabFrames[2]

-- 折叠选项1 - 区域1
local Area1Button = Instance.new("TextButton")
Area1Button.Name = "Area1Button"
Area1Button.Size = UDim2.new(1, 0, 0, 35)
Area1Button.Position = UDim2.new(0, 0, 0, 5)
Area1Button.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
Area1Button.Text = "▶ 区域1"
Area1Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Area1Button.Font = Enum.Font.GothamBold
Area1Button.TextSize = 12
Area1Button.TextXAlignment = Enum.TextXAlignment.Left
Area1Button.Parent = UpgradeFrame

local Area1Corner = Instance.new("UICorner")
Area1Corner.CornerRadius = UDim.new(0, 6)
Area1Corner.Parent = Area1Button

local Area1Content = Instance.new("Frame")
Area1Content.Name = "Area1Content"
Area1Content.Size = UDim2.new(1, -10, 0, 120)
Area1Content.Position = UDim2.new(0, 5, 0, 45)
Area1Content.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Area1Content.Visible = false
Area1Content.Parent = UpgradeFrame

local Area1ContentCorner = Instance.new("UICorner")
Area1ContentCorner.CornerRadius = UDim.new(0, 6)
Area1ContentCorner.Parent = Area1Content

-- 区域1的子选项
local area1Options = {
    {Name = "生成速率", Value = "SpawnRate1"},
    {Name = "草的数量", Value = "GrassAmount"},
    {Name = "草的价值", Value = "GrassValue"}
}

local selectedArea1Option = "SpawnRate1"
local Area1OptionButtons = {}

for i, option in ipairs(area1Options) do
    local OptionButton = Instance.new("TextButton")
    OptionButton.Name = "Area1_" .. option.Value .. "Button"
    OptionButton.Size = UDim2.new(1, -10, 0, 30)
    OptionButton.Position = UDim2.new(0, 5, 0, 5 + (i-1)*35)
    OptionButton.BackgroundColor3 = selectedArea1Option == option.Value and Color3.fromRGB(70, 110, 180) or Color3.fromRGB(60, 60, 60)
    OptionButton.Text = option.Name
    OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OptionButton.Font = Enum.Font.Gotham
    OptionButton.TextSize = 10
    OptionButton.Parent = Area1Content
    
    local OptionCorner = Instance.new("UICorner")
    OptionCorner.CornerRadius = UDim.new(0, 5)
    OptionCorner.Parent = OptionButton
    
    OptionButton.MouseButton1Click:Connect(function()
        selectedArea1Option = option.Value
        for j, button in ipairs(Area1OptionButtons) do
            if area1Options[j].Value == selectedArea1Option then
                button.BackgroundColor3 = Color3.fromRGB(70, 110, 180)
            else
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
        updateStatus("已选择: " .. option.Name, Color3.fromRGB(200, 200, 255))
    end)
    
    table.insert(Area1OptionButtons, OptionButton)
end

-- 折叠选项2 - 区域2
local Area2Button = Instance.new("TextButton")
Area2Button.Name = "Area2Button"
Area2Button.Size = UDim2.new(1, 0, 0, 35)
Area2Button.Position = UDim2.new(0, 0, 0, 45) -- 初始位置
Area2Button.BackgroundColor3 = Color3.fromRGB(120, 80, 200)
Area2Button.Text = "▶ 区域2"
Area2Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Area2Button.Font = Enum.Font.GothamBold
Area2Button.TextSize = 12
Area2Button.TextXAlignment = Enum.TextXAlignment.Left
Area2Button.Parent = UpgradeFrame

local Area2Corner = Instance.new("UICorner")
Area2Corner.CornerRadius = UDim.new(0, 6)
Area2Corner.Parent = Area2Button

local Area2Content = Instance.new("Frame")
Area2Content.Name = "Area2Content"
Area2Content.Size = UDim2.new(1, -10, 0, 200)
Area2Content.Position = UDim2.new(0, 5, 0, 85)
Area2Content.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Area2Content.Visible = false
Area2Content.Parent = UpgradeFrame

local Area2ContentCorner = Instance.new("UICorner")
Area2ContentCorner.CornerRadius = UDim.new(0, 6)
Area2ContentCorner.Parent = Area2Content

-- 区域2的子选项
local UpgradeTreeButton = Instance.new("TextButton")
UpgradeTreeButton.Name = "UpgradeTreeButton"
UpgradeTreeButton.Size = UDim2.new(1, -10, 0, 40)
UpgradeTreeButton.Position = UDim2.new(0, 5, 0, 5)
UpgradeTreeButton.BackgroundColor3 = Color3.fromRGB(180, 100, 100)
UpgradeTreeButton.Text = "购买所有升级树"
UpgradeTreeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UpgradeTreeButton.Font = Enum.Font.GothamBold
UpgradeTreeButton.TextSize = 12
UpgradeTreeButton.Parent = Area2Content

local UpgradeTreeCorner = Instance.new("UICorner")
UpgradeTreeCorner.CornerRadius = UDim.new(0, 6)
UpgradeTreeCorner.Parent = UpgradeTreeButton

-- 提示文本
local TreeWarningLabel = Instance.new("TextLabel")
TreeWarningLabel.Name = "TreeWarningLabel"
TreeWarningLabel.Size = UDim2.new(1, -10, 0, 50)
TreeWarningLabel.Position = UDim2.new(0, 5, 0, 50)
TreeWarningLabel.BackgroundTransparency = 1
TreeWarningLabel.Text = "提示: 请确保你的钱足够"
TreeWarningLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
TreeWarningLabel.Font = Enum.Font.Gotham
TreeWarningLabel.TextSize = 10
TreeWarningLabel.TextWrapped = true
TreeWarningLabel.Parent = Area2Content

-- 执行按钮
local ExecuteButton = Instance.new("TextButton")
ExecuteButton.Name = "ExecuteButton"
ExecuteButton.Size = UDim2.new(1, 0, 0, 40)
ExecuteButton.Position = UDim2.new(0, 0, 0, 170)
ExecuteButton.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
ExecuteButton.Text = "执行"
ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteButton.Font = Enum.Font.GothamBold
ExecuteButton.TextSize = 13
ExecuteButton.Parent = UpgradeFrame

local ExecuteCorner = Instance.new("UICorner")
ExecuteCorner.CornerRadius = UDim.new(0, 7)
ExecuteCorner.Parent = ExecuteButton

-- 区域1展开/收起功能
local area1Expanded = false
Area1Button.MouseButton1Click:Connect(function()
    area1Expanded = not area1Expanded
    Area1Content.Visible = area1Expanded
    
    if area1Expanded then
        Area1Button.Text = "▼ 区域1"
        Area2Button.Position = UDim2.new(0, 0, 0, 170) -- 区域1展开时下移
        ExecuteButton.Position = UDim2.new(0, 0, 0, 295) -- 执行按钮下移
    else
        Area1Button.Text = "▶ 区域1"
        Area2Button.Position = UDim2.new(0, 0, 0, 45) -- 区域1收起时上移
        ExecuteButton.Position = UDim2.new(0, 0, 0, 170) -- 执行按钮上移
    end
end)

-- 区域2展开/收起功能
local area2Expanded = false
Area2Button.MouseButton1Click:Connect(function()
    area2Expanded = not area2Expanded
    Area2Content.Visible = area2Expanded
    
    if area2Expanded then
        Area2Button.Text = "▼ 区域2"
    else
        Area2Button.Text = "▶ 区域2"
    end
end)

-- 设置选项卡
local SettingsFrame = TabFrames[3]

-- 公告区域
local AnnouncementFrame = Instance.new("Frame")
AnnouncementFrame.Name = "AnnouncementFrame"
AnnouncementFrame.Size = UDim2.new(1, 0, 0, 100)
AnnouncementFrame.Position = UDim2.new(0, 0, 0, 10)
AnnouncementFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
AnnouncementFrame.Parent = SettingsFrame

local AnnouncementCorner = Instance.new("UICorner")
AnnouncementCorner.CornerRadius = UDim.new(0, 6)
AnnouncementCorner.Parent = AnnouncementFrame

-- 公告标题
local AnnouncementTitle = Instance.new("TextLabel")
AnnouncementTitle.Name = "AnnouncementTitle"
AnnouncementTitle.Size = UDim2.new(1, -10, 0, 20)
AnnouncementTitle.Position = UDim2.new(0, 5, 0, 5)
AnnouncementTitle.BackgroundTransparency = 1
AnnouncementTitle.Text = "📢 脚本公告"
AnnouncementTitle.TextColor3 = Color3.fromRGB(255, 255, 150)
AnnouncementTitle.Font = Enum.Font.GothamBold
AnnouncementTitle.TextSize = 12
AnnouncementTitle.TextXAlignment = Enum.TextXAlignment.Left
AnnouncementTitle.Parent = AnnouncementFrame

-- 公告内容
local AnnouncementContent = Instance.new("TextLabel")
AnnouncementContent.Name = "AnnouncementContent"
AnnouncementContent.Size = UDim2.new(1, -10, 0, 70)
AnnouncementContent.Position = UDim2.new(0, 5, 0, 25)
AnnouncementContent.BackgroundTransparency = 1
AnnouncementContent.Text = "1.当前版本: 1.0\n2.作者: 蛙Was\n3.本脚本由DeepSeek\n  辅助修复与生成"
AnnouncementContent.TextColor3 = Color3.fromRGB(200, 200, 255)
AnnouncementContent.Font = Enum.Font.Gotham
AnnouncementContent.TextSize = 10
AnnouncementContent.TextXAlignment = Enum.TextXAlignment.Left
AnnouncementContent.TextYAlignment = Enum.TextYAlignment.Top
AnnouncementContent.TextWrapped = true
AnnouncementContent.Parent = AnnouncementFrame

-- 自动收集开关
local autoCollecting = false
local autoCollectSpeed = 1.0

local AutoCollectLabel = Instance.new("TextLabel")
AutoCollectLabel.Name = "AutoCollectLabel"
AutoCollectLabel.Size = UDim2.new(0.6, 0, 0, 20)
AutoCollectLabel.Position = UDim2.new(0, 0, 0, 120)
AutoCollectLabel.BackgroundTransparency = 1
AutoCollectLabel.Text = "自动收集:"
AutoCollectLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
AutoCollectLabel.Font = Enum.Font.Gotham
AutoCollectLabel.TextSize = 11
AutoCollectLabel.TextXAlignment = Enum.TextXAlignment.Left
AutoCollectLabel.Parent = SettingsFrame

local AutoCollectToggle = Instance.new("TextButton")
AutoCollectToggle.Name = "AutoCollectToggle"
AutoCollectToggle.Size = UDim2.new(0, 45, 0, 22)
AutoCollectToggle.Position = UDim2.new(1, -50, 0, 120)
AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
AutoCollectToggle.Text = "开启"
AutoCollectToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoCollectToggle.Font = Enum.Font.Gotham
AutoCollectToggle.TextSize = 10
AutoCollectToggle.Parent = SettingsFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 5)
ToggleCorner.Parent = AutoCollectToggle

-- 自动收集速度滑动条
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 18)
SpeedLabel.Position = UDim2.new(0, 0, 0, 155)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "收集速度: 1.0秒"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SettingsFrame

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(1, 0, 0, 14)
SpeedSlider.Position = UDim2.new(0, 0, 0, 178)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedSlider.Text = ""
SpeedSlider.Parent = SettingsFrame

local SpeedSliderCorner = Instance.new("UICorner")
SpeedSliderCorner.CornerRadius = UDim.new(0, 7)
SpeedSliderCorner.Parent = SpeedSlider

local SpeedSliderFill = Instance.new("Frame")
SpeedSliderFill.Name = "SpeedSliderFill"
SpeedSliderFill.Size = UDim2.new(0.1, 0, 1, 0)
SpeedSliderFill.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
SpeedSliderFill.Parent = SpeedSlider

local SpeedFillCorner = Instance.new("UICorner")
SpeedFillCorner.CornerRadius = UDim.new(0, 7)
SpeedFillCorner.Parent = SpeedSliderFill

-- 快速速度按钮
local quickSpeeds = {0.5, 1.0, 2.0, 5.0}
local QuickSpeedFrame = Instance.new("Frame")
QuickSpeedFrame.Name = "QuickSpeedFrame"
QuickSpeedFrame.Size = UDim2.new(1, 0, 0, 26)
QuickSpeedFrame.Position = UDim2.new(0, 0, 0, 197)
QuickSpeedFrame.BackgroundTransparency = 1
QuickSpeedFrame.Parent = SettingsFrame

for i, speed in ipairs(quickSpeeds) do
    local SpeedButton = Instance.new("TextButton")
    SpeedButton.Name = "Speed" .. speed
    SpeedButton.Size = UDim2.new(0.24, -2, 1, 0)
    SpeedButton.Position = UDim2.new((i-1)/4, 0, 0, 0)
    SpeedButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    SpeedButton.Text = speed .. "s"
    SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedButton.Font = Enum.Font.Gotham
    SpeedButton.TextSize = 9
    SpeedButton.Parent = QuickSpeedFrame
    
    local SpeedButtonCorner = Instance.new("UICorner")
    SpeedButtonCorner.CornerRadius = UDim.new(0, 3)
    SpeedButtonCorner.Parent = SpeedButton
    
    SpeedButton.MouseButton1Click:Connect(function()
        autoCollectSpeed = speed
        SpeedLabel.Text = "收集速度: " .. speed .. "秒"
        SpeedSliderFill.Size = UDim2.new(math.clamp((speed-0.1)/9.9, 0, 1), 0, 1, 0)
    end)
end

-- 关闭脚本按钮
local CloseScriptButton = Instance.new("TextButton")
CloseScriptButton.Name = "CloseScriptButton"
CloseScriptButton.Size = UDim2.new(1, 0, 0, 35)
CloseScriptButton.Position = UDim2.new(0, 0, 0, 235)
CloseScriptButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseScriptButton.Text = "关闭脚本"
CloseScriptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseScriptButton.Font = Enum.Font.GothamBold
CloseScriptButton.TextSize = 13
CloseScriptButton.Parent = SettingsFrame

local CloseScriptCorner = Instance.new("UICorner")
CloseScriptCorner.CornerRadius = UDim.new(0, 7)
CloseScriptCorner.Parent = CloseScriptButton

-- 警告文本
local WarningLabel = Instance.new("TextLabel")
WarningLabel.Name = "WarningLabel"
WarningLabel.Size = UDim2.new(1, 0, 0, 35)
WarningLabel.Position = UDim2.new(0, 0, 0, 275)
WarningLabel.BackgroundTransparency = 1
WarningLabel.Text = "警告: 关闭脚本将移除所有界面并停止自动收集"
WarningLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
WarningLabel.Font = Enum.Font.Gotham
WarningLabel.TextSize = 10
WarningLabel.TextWrapped = true
WarningLabel.Parent = SettingsFrame

-- 状态显示
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -12, 0, 22)
StatusLabel.Position = UDim2.new(0, 6, 1, -28)
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.Text = "就绪"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 10
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 5)
StatusCorner.Parent = StatusLabel

-- 功能函数
local function updateStatus(message, color)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 200)
end

local function collectGrass(type, amount)
    local args = {
        normal = 0,
        ruby = 0,
        silver = 0,
        golden = 0,
        diamond = 0
    }
    
    args[type] = amount
    
    local success, result = pcall(function()
        GrassCollectRemote:FireServer(args)
    end)
    
    if success then
        updateStatus("收集成功", Color3.fromRGB(100, 255, 100))
        return true
    else
        updateStatus("收集失败", Color3.fromRGB(255, 100, 100))
        return false
    end
end

-- 升级树购买函数
local function purchaseAllUpgradeTrees()
    updateStatus("开始购买所有升级树...", Color3.fromRGB(255, 255, 100))
    
    -- 购买所有12个升级树
    local treeType = 1
    local successCount = 0
    
    for treeNumber = 1, 12 do
        local args = {
            {
                treeType = treeType,
                treeNumber = treeNumber
            }
        }
        
        local success, result = pcall(function()
            UpgradeTreeRemote:FireServer(unpack(args))
        end)
        
        if success then
            successCount = successCount + 1
            updateStatus("购买树 " .. treeNumber .. "/12 成功", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("购买树 " .. treeNumber .. "/12 失败", Color3.fromRGB(255, 100, 100))
        end
        
        wait(0.2) -- 延迟以防止请求过快
    end
    
    updateStatus("完成购买 " .. successCount .. "/12 个升级树", Color3.fromRGB(100, 255, 100))
    return successCount
end

-- 执行普通升级函数
local function performUpgrade()
    -- 根据选择的升级类型设置参数（使用示例数据）
    local upgradeData = {
        currencyName = "Grass",
        autoBuy = false,
        amount = 1, -- 默认值
        max = 1, -- 默认值
        upgradeValue = selectedArea1Option,
        cost = 100 -- 默认值
    }
    
    -- 使用正确的嵌套结构
    local args = {
        {
            upgradeData
        }
    }
    
    local success, result = pcall(function()
        UpgradeRemote:FireServer(unpack(args))
    end)
    
    if success then
        updateStatus("升级成功", Color3.fromRGB(100, 255, 100))
        return true
    else
        updateStatus("升级失败: " .. tostring(result), Color3.fromRGB(255, 100, 100))
        return false
    end
end

-- 滑块交互
local dragging = false
local speedDragging = false

AmountSlider.MouseButton1Down:Connect(function()
    dragging = true
end)

SpeedSlider.MouseButton1Down:Connect(function()
    speedDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        speedDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local sliderPos = AmountSlider.AbsolutePosition
        local sliderSize = AmountSlider.AbsoluteSize
        local mousePos = input.Position
        
        if mousePos.X >= sliderPos.X and mousePos.X <= sliderPos.X + sliderSize.X then
            local relativeX = mousePos.X - sliderPos.X
            local percentage = math.clamp(relativeX / sliderSize.X, 0, 1)
            
            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            collectAmount = math.floor(1 + percentage * 99)
            CollectAmountLabel.Text = "收集次数: " .. collectAmount
        end
    end
    
    if speedDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local sliderPos = SpeedSlider.AbsolutePosition
        local sliderSize = SpeedSlider.AbsoluteSize
        local mousePos = input.Position
        
        if mousePos.X >= sliderPos.X and mousePos.X <= sliderPos.X + sliderSize.X then
            local relativeX = mousePos.X - sliderPos.X
            local percentage = math.clamp(relativeX / sliderSize.X, 0, 1)
            
            SpeedSliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            autoCollectSpeed = math.floor((percentage * 9.9 + 0.1) * 10) / 10
            SpeedLabel.Text = "收集速度: " .. string.format("%.1f", autoCollectSpeed) .. "秒"
        end
    end
end)

-- 按钮事件
AutoCollectToggle.MouseButton1Click:Connect(function()
    autoCollecting = not autoCollecting
    
    if autoCollecting then
        AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
        AutoCollectToggle.Text = "停止"
        updateStatus("自动收集开启", Color3.fromRGB(100, 255, 100))
        
        spawn(function()
            while autoCollecting do
                collectGrass(selectedCollectType, 1)
                wait(autoCollectSpeed)
            end
        end)
    else
        AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        AutoCollectToggle.Text = "开启"
        updateStatus("自动收集关闭", Color3.fromRGB(200, 200, 200))
    end
end)

CollectButton.MouseButton1Click:Connect(function()
    updateStatus("正在收集...", Color3.fromRGB(255, 255, 100))
    
    spawn(function()
        for i = 1, collectAmount do
            collectGrass(selectedCollectType, 1)
            wait(0.1)
        end
    end)
end)

-- 执行按钮事件
ExecuteButton.MouseButton1Click:Connect(function()
    -- 检查哪个区域被选中并执行相应的操作
    if area2Expanded then
        -- 执行升级树购买
        purchaseAllUpgradeTrees()
    else
        -- 执行普通升级
        updateStatus("正在升级...", Color3.fromRGB(255, 255, 100))
        performUpgrade()
    end
end)

-- 升级树按钮事件
UpgradeTreeButton.MouseButton1Click:Connect(function()
    updateStatus("正在购买所有升级树...", Color3.fromRGB(255, 255, 100))
    purchaseAllUpgradeTrees()
end)

-- 关闭脚本函数
local function closeScript()
    -- 停止自动收集
    autoCollecting = false
    if AutoCollectToggle then
        AutoCollectToggle.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        AutoCollectToggle.Text = "开启"
    end
    
    -- 移除所有界面
    if ScreenGui then
        ScreenGui:Destroy()
    end
end

-- 关闭脚本按钮事件
CloseScriptButton.MouseButton1Click:Connect(function()
    updateStatus("正在关闭脚本...", Color3.fromRGB(255, 150, 150))
    closeScript()
end)

-- 修复菜单显示/隐藏问题
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    
    if MainFrame.Visible then
        local buttonPos = ToggleButton.AbsolutePosition
        local buttonSize = ToggleButton.AbsoluteSize
        local screenSize = workspace.CurrentCamera.ViewportSize
        
        local targetX, targetY
        
        if buttonPos.X < screenSize.X / 2 then
            targetX = buttonPos.X + buttonSize.X + 10
        else
            targetX = buttonPos.X - 310
        end
        
        targetY = buttonPos.Y
        
        targetX = math.clamp(targetX, 10, screenSize.X - 310)
        targetY = math.clamp(targetY, 10, screenSize.Y - 510)
        
        MainFrame.Position = UDim2.new(0, targetX, 0, targetY)
        updateStatus("菜单已打开", Color3.fromRGB(100, 200, 255))
    else
        updateStatus("菜单已关闭", Color3.fromRGB(200, 200, 200))
    end
end)

-- 简化边界检查
local function keepInBounds(frame)
    spawn(function()
        while frame and frame.Parent do
            wait(1)
            
            if frame.Visible then
                local absPos = frame.AbsolutePosition
                local absSize = frame.AbsoluteSize
                local screenSize = workspace.CurrentCamera.ViewportSize
                
                local needReposition = false
                local newX = absPos.X
                local newY = absPos.Y
                
                if absPos.X < 10 then
                    newX = 10
                    needReposition = true
                elseif absPos.X + absSize.X > screenSize.X - 10 then
                    newX = screenSize.X - absSize.X - 10
                    needReposition = true
                end
                
                if absPos.Y < 10 then
                    newY = 10
                    needReposition = true
                elseif absPos.Y + absSize.Y > screenSize.Y - 10 then
                    newY = screenSize.Y - absSize.Y - 10
                    needReposition = true
                end
                
                if needReposition then
                    frame.Position = UDim2.new(0, newX, 0, newY)
                end
            end
        end
    end)
end

-- 初始化
updateStatus("脚本已加载", Color3.fromRGB(100, 200, 255))

-- 启动边界检查
keepInBounds(ToggleButton)
keepInBounds(MainFrame)

-- 为移动设备优化
if isMobile then
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.TextSize = 20
    ToggleCorner.CornerRadius = UDim.new(0, 25)
end
