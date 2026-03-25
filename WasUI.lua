--[[
    WasUI - 轻量级直角风格 UI 库（增强版）
    特性：
    - 窗口背景支持 URL 图片或纯色
    - 按钮/开关长按生成浮动快捷键按钮（与主 UI 分离）
    - 主题切换（亮色/暗色）
    - 控件：按钮、开关、滑块、输入框、下拉菜单、颜色选择器、段落文本
    - 配置管理器（保存用户设置）
    - 选项卡内支持左右分栏布局（TwoColumn）
    - 拖动时阻止事件传递到游戏世界
    - MacOS 风格窗口控制点（红黄绿）
    - iOS 风格开关
    - 开关状态悬浮显示在屏幕右上角
    - 图标库支持（内置常用图标，支持 URL）
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ==================== 辅助函数 ====================
local function Tween(obj, duration, properties, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, dir)
    local tween = TweenService:Create(obj, info, properties)
    tween:Play()
    return tween
end

local function SafeCallback(func, ...)
    if type(func) == "function" then
        local ok, err = pcall(func, ...)
        if not ok then
            warn("[WasUI] Callback error: " .. tostring(err))
        end
    end
end

-- 长按检测器
local LongPressDetector = {}
LongPressDetector.__index = LongPressDetector

function LongPressDetector.new(instance, duration, onLongPress)
    local self = setmetatable({}, LongPressDetector)
    self.instance = instance
    self.duration = duration or 0.5
    self.onLongPress = onLongPress
    self.pressing = false
    self.timer = nil

    local function startTimer()
        self.timer = task.delay(self.duration, function()
            if self.pressing then
                self.onLongPress()
                self:stop()
            end
        end)
    end

    instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.pressing = true
            startTimer()
        end
    end)

    instance.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:stop()
        end
    end)

    function self:stop()
        self.pressing = false
        if self.timer then
            task.cancel(self.timer)
            self.timer = nil
        end
    end

    return self
end

-- ==================== 配置管理器 ====================
local ConfigManager = {}
ConfigManager.Folder = "WasUI_Config"
ConfigManager.Path = ConfigManager.Folder .. "/"
ConfigManager.Configs = {}

function ConfigManager.Init(folder)
    if folder then ConfigManager.Folder = folder end
    ConfigManager.Path = ConfigManager.Folder .. "/"
    if isfolder and not isfolder(ConfigManager.Path) then
        makefolder(ConfigManager.Path)
    end
end

function ConfigManager.NewConfig(name, autoLoad)
    local path = ConfigManager.Path .. name .. ".json"
    local config = {
        Name = name,
        Path = path,
        Data = {},
        AutoLoad = autoLoad or false,
    }
    function config:Save()
        if writefile then
            local json = HttpService:JSONEncode(self.Data)
            writefile(self.Path, json)
        end
    end
    function config:Load()
        if isfile and isfile(self.Path) then
            local ok, data = pcall(function()
                local content = readfile(self.Path)
                return HttpService:JSONDecode(content)
            end)
            if ok then
                self.Data = data
            else
                warn("[WasUI] Failed to load config: " .. tostring(data))
            end
        end
    end
    function config:Set(key, value)
        self.Data[key] = value
        self:Save()
    end
    function config:Get(key, default)
        return self.Data[key] ~= nil and self.Data[key] or default
    end
    if autoLoad then
        config:Load()
    end
    ConfigManager.Configs[name] = config
    return config
end

function ConfigManager.GetConfig(name)
    return ConfigManager.Configs[name]
end

function ConfigManager.DeleteConfig(name)
    local config = ConfigManager.Configs[name]
    if config and isfile and isfile(config.Path) then
        delfile(config.Path)
        ConfigManager.Configs[name] = nil
        return true
    end
    return false
end

function ConfigManager.ListConfigs()
    local list = {}
    if listfiles then
        for _, file in ipairs(listfiles(ConfigManager.Path)) do
            local name = file:match("([^/\\]+)%.json$")
            if name then
                table.insert(list, name)
            end
        end
    end
    return list
end

-- ==================== 主题系统 ====================
local Theme = {
    Current = "Light",
    Themes = {
        Light = {
            Background = Color3.fromRGB(240, 240, 240),
            Surface = Color3.fromRGB(255, 255, 255),
            Primary = Color3.fromRGB(0, 120, 215),
            PrimaryHover = Color3.fromRGB(0, 100, 200),
            PrimaryPressed = Color3.fromRGB(0, 80, 160),
            Text = Color3.fromRGB(0, 0, 0),
            TextSecondary = Color3.fromRGB(100, 100, 100),
            Border = Color3.fromRGB(200, 200, 200),
            Disabled = Color3.fromRGB(150, 150, 150),
            TabBackground = Color3.fromRGB(220, 220, 220),
        },
        Dark = {
            Background = Color3.fromRGB(30, 30, 30),
            Surface = Color3.fromRGB(45, 45, 45),
            Primary = Color3.fromRGB(0, 150, 200),
            PrimaryHover = Color3.fromRGB(0, 130, 180),
            PrimaryPressed = Color3.fromRGB(0, 110, 160),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(180, 180, 180),
            Border = Color3.fromRGB(70, 70, 70),
            Disabled = Color3.fromRGB(100, 100, 100),
            TabBackground = Color3.fromRGB(38, 38, 38),
        },
    }
}

function Theme.GetColor(key)
    return Theme.Themes[Theme.Current][key] or Theme.Themes.Light[key]
end

function Theme.SetTheme(name)
    if Theme.Themes[name] then
        Theme.Current = name
        return true
    end
    return false
end

-- ==================== 图标库 ====================
local IconLibrary = {
    -- 内置简单图标（名称映射到 URL）
    ["close"] = "rbxassetid://1234567890",   -- 占位，实际可替换
    ["minimize"] = "rbxassetid://1234567891",
    ["maximize"] = "rbxassetid://1234567892",
    ["check"] = "rbxassetid://1234567893",
    ["chevron-down"] = "rbxassetid://1234567894",
    ["circle"] = "rbxassetid://1234567895",
    -- 可扩展更多
}

function WasUI:GetIcon(name)
    local icon = IconLibrary[name]
    if icon then return icon end
    -- 如果 name 是 URL，直接返回
    if type(name) == "string" and name:match("^https?://") then
        return name
    end
    return nil
end

-- ==================== 开关状态管理器（右上角悬浮显示）====================
local StatusManager = {}
StatusManager.EnabledStatuses = {}  -- { toggleName = { text, color } }
StatusManager.Container = nil

function StatusManager.Init(parentGui)
    if StatusManager.Container then return end
    StatusManager.Container = Instance.new("Frame")
    StatusManager.Container.Size = UDim2.new(0, 200, 0, 0)
    StatusManager.Container.Position = UDim2.new(1, -210, 0, 10)
    StatusManager.Container.BackgroundTransparency = 1
    StatusManager.Container.ZIndex = 10
    StatusManager.Container.Parent = parentGui

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = StatusManager.Container
end

function StatusManager.AddStatus(name, text, color)
    -- 如果已存在，更新
    local existing = StatusManager.EnabledStatuses[name]
    if existing then
        existing.Text = text
        existing.Color = color
        if existing.Label then
            existing.Label.Text = text
            existing.Label.TextColor3 = color
        end
        return
    end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 180, 0, 24)
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.BackgroundTransparency = 0.7
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = color
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = StatusManager.Container

    -- 添加圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label

    StatusManager.EnabledStatuses[name] = {
        Label = label,
        Text = text,
        Color = color,
    }
end

function StatusManager.RemoveStatus(name)
    local status = StatusManager.EnabledStatuses[name]
    if status and status.Label then
        status.Label:Destroy()
    end
    StatusManager.EnabledStatuses[name] = nil
end

function StatusManager.UpdateStatus(name, text, color)
    local status = StatusManager.EnabledStatuses[name]
    if status then
        status.Text = text
        status.Color = color
        if status.Label then
            status.Label.Text = text
            status.Label.TextColor3 = color
        end
    end
end

-- ==================== 窗口类 ====================
local Window = {}
Window.__index = Window

function Window:Create(data)
    local self = setmetatable({}, Window)
    self.Title = data.Title or "Window"
    self.Size = data.Size or UDim2.new(0, 520, 0, 400)
    self.MinSize = data.MinSize or Vector2.new(400, 300)
    self.MaxSize = data.MaxSize or Vector2.new(800, 600)
    self.Position = data.Position or UDim2.new(0.5, 0, 0.5, 0)
    self.Draggable = data.Draggable ~= false
    self.Closable = data.Closable ~= false
    self.Folder = data.Folder or "WasUI"
    self.ConfigManager = ConfigManager
    self.Theme = Theme
    self.Tabs = {}
    self.CurrentTab = nil
    self.Elements = {}
    self.Visible = true
    self.ShortcutButtons = {}
    self.Minimized = false

    -- 创建 ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WasUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = screenGui

    -- 初始化状态管理器
    StatusManager.Init(screenGui)

    -- 主窗口 Frame
    self.Main = Instance.new("Frame")
    self.Main.Size = self.Size
    self.Main.Position = self.Position
    self.Main.BackgroundColor3 = Theme.GetColor("Background")
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Active = true
    self.Main.Parent = screenGui

    -- 窗口圆角
    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 12)
    windowCorner.Parent = self.Main

    -- 背景图片/颜色处理
    if data.Background then
        if type(data.Background) == "string" and data.Background:match("^https?://") then
            local backgroundImg = Instance.new("ImageLabel")
            backgroundImg.Size = UDim2.new(1, 0, 1, 0)
            backgroundImg.BackgroundTransparency = 1
            backgroundImg.Image = data.Background
            backgroundImg.ScaleType = Enum.ScaleType.Crop
            backgroundImg.ZIndex = 0
            backgroundImg.Parent = self.Main
            backgroundImg:WaitForChild("ImageLoaded", 5)
        elseif type(data.Background) == "Color3" then
            self.Main.BackgroundColor3 = data.Background
        end
    end

    -- 标题栏（MacOS风格）
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Theme.GetColor("Surface")
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Active = true
    self.TitleBar.Parent = self.Main

    -- 标题栏圆角（只上边）
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = self.TitleBar
    -- 需要裁剪左上和右上圆角，但简单处理整个标题栏也有圆角也可以

    -- MacOS 三色圆点
    local dotsContainer = Instance.new("Frame")
    dotsContainer.Size = UDim2.new(0, 70, 1, 0)
    dotsContainer.Position = UDim2.new(0, 12, 0, 0)
    dotsContainer.BackgroundTransparency = 1
    dotsContainer.Parent = self.TitleBar

    local redDot = Instance.new("TextButton")
    redDot.Size = UDim2.new(0, 12, 0, 12)
    redDot.Position = UDim2.new(0, 0, 0.5, -6)
    redDot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    redDot.Text = ""
    redDot.BorderSizePixel = 0
    redDot.Parent = dotsContainer
    local redCorner = Instance.new("UICorner")
    redCorner.CornerRadius = UDim.new(1, 0)
    redCorner.Parent = redDot

    local yellowDot = Instance.new("TextButton")
    yellowDot.Size = UDim2.new(0, 12, 0, 12)
    yellowDot.Position = UDim2.new(0, 18, 0.5, -6)
    yellowDot.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    yellowDot.Text = ""
    yellowDot.BorderSizePixel = 0
    yellowDot.Parent = dotsContainer
    local yellowCorner = Instance.new("UICorner")
    yellowCorner.CornerRadius = UDim.new(1, 0)
    yellowCorner.Parent = yellowDot

    local greenDot = Instance.new("TextButton")
    greenDot.Size = UDim2.new(0, 12, 0, 12)
    greenDot.Position = UDim2.new(0, 36, 0.5, -6)
    greenDot.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    greenDot.Text = ""
    greenDot.BorderSizePixel = 0
    greenDot.Parent = dotsContainer
    local greenCorner = Instance.new("UICorner")
    greenCorner.CornerRadius = UDim.new(1, 0)
    greenCorner.Parent = greenDot

    -- 窗口标题
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 70, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme.GetColor("Text")
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Parent = self.TitleBar

    -- 窗口控制按钮功能
    redDot.MouseButton1Click:Connect(function()
        self:Close()
    end)
    yellowDot.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    greenDot.MouseButton1Click:Connect(function()
        self:ToggleFullscreen()
    end)

    -- 标签页容器
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, 0, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Main

    -- 标签页按钮区域（与内容区分）
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 32)
    self.TabBar.BackgroundColor3 = Theme.GetColor("TabBackground")
    self.TabBar.BorderSizePixel = 0
    self.TabBar.Parent = self.TabContainer

    -- 分割线（可选）
    local tabDivider = Instance.new("Frame")
    tabDivider.Size = UDim2.new(1, 0, 0, 1)
    tabDivider.Position = UDim2.new(0, 0, 0, 32)
    tabDivider.BackgroundColor3 = Theme.GetColor("Border")
    tabDivider.BorderSizePixel = 0
    tabDivider.Parent = self.TabContainer

    -- 内容区域
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, 0, 1, -33)
    self.ContentArea.Position = UDim2.new(0, 0, 0, 33)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.TabContainer

    -- 滚动区域（仅垂直滚动）
    self.ScrollFrame = Instance.new("ScrollingFrame")
    self.ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollFrame.BackgroundTransparency = 1
    self.ScrollFrame.BorderSizePixel = 0
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ScrollFrame.ScrollBarThickness = 6
    self.ScrollFrame.ScrollBarImageTransparency = 0.5
    self.ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    self.ScrollFrame.Parent = self.ContentArea

    self.UIList = Instance.new("UIListLayout")
    self.UIList.Padding = UDim.new(0, 8)
    self.UIList.SortOrder = Enum.SortOrder.LayoutOrder
    self.UIList.Parent = self.ScrollFrame

    -- 拖拽功能（阻止事件传递）
    if self.Draggable then
        local dragging = false
        local dragStart, startPos
        self.TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = self.Main.Position
                input:StopPropagation()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                self.Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
                input:StopPropagation()
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- 创建浮动快捷键按钮的容器
    self.ShortcutContainer = Instance.new("Frame")
    self.ShortcutContainer.Size = UDim2.new(0, 180, 0, 0)
    self.ShortcutContainer.Position = UDim2.new(1, -190, 0, 10)
    self.ShortcutContainer.BackgroundTransparency = 1
    self.ShortcutContainer.ZIndex = 10
    self.ShortcutContainer.Parent = screenGui

    local shortcutList = Instance.new("UIListLayout")
    shortcutList.Padding = UDim.new(0, 4)
    shortcutList.SortOrder = Enum.SortOrder.LayoutOrder
    shortcutList.Parent = self.ShortcutContainer

    function self:AddShortcutButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 170, 0, 26)
        btn.BackgroundColor3 = Theme.GetColor("Primary")
        btn.Text = "⚡ " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 11
        btn.BorderSizePixel = 0
        btn.Parent = self.ShortcutContainer
        btn.MouseButton1Click:Connect(callback)

        -- 圆角
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("PrimaryHover") })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("Primary") })
        end)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 18, 1, 0)
        closeBtn.Position = UDim2.new(1, -18, 0, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 10
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = btn
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 4)
        closeCorner.Parent = closeBtn
        closeBtn.MouseButton1Click:Connect(function()
            btn:Destroy()
        end)

        table.insert(self.ShortcutButtons, btn)
        return btn
    end

    -- 响应主题变化
    function self:UpdateTheme()
        self.Main.BackgroundColor3 = Theme.GetColor("Background")
        self.TitleBar.BackgroundColor3 = Theme.GetColor("Surface")
        self.TitleLabel.TextColor3 = Theme.GetColor("Text")
        self.TabBar.BackgroundColor3 = Theme.GetColor("TabBackground")
        tabDivider.BackgroundColor3 = Theme.GetColor("Border")
        for _, tab in ipairs(self.Tabs) do
            tab:UpdateTheme()
        end
        for _, elem in ipairs(self.Elements) do
            if elem.UpdateTheme then elem:UpdateTheme() end
        end
        for _, btn in ipairs(self.ShortcutButtons) do
            btn.BackgroundColor3 = Theme.GetColor("Primary")
        end
    end

    -- 窗口方法
    function self:SetTheme(name)
        if Theme.SetTheme(name) then
            self:UpdateTheme()
        end
    end

    function self:Close()
        self.Visible = false
        self.Main.Visible = false
    end

    function self:Minimize()
        if not self.Minimized then
            self.Main.Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 30)
            self.Minimized = true
        else
            self.Main.Size = self.Size
            self.Minimized = false
        end
    end

    function self:ToggleFullscreen()
        -- 简化：切换全屏状态（可扩展为全屏/窗口切换）
        if self.Main.Size == self.Size then
            self.Main.Size = UDim2.new(1, 0, 1, 0)
        else
            self.Main.Size = self.Size
        end
    end

    function self:Show()
        self.Visible = true
        self.Main.Visible = true
    end

    function self:Destroy()
        self.Gui:Destroy()
    end

    function self:Tab(name)
        local tab = {}
        tab.Name = name
        tab.Window = self
        tab.Elements = {}
        tab.Frame = Instance.new("Frame")
        tab.Frame.Size = UDim2.new(1, 0, 1, 0)
        tab.Frame.BackgroundTransparency = 1
        tab.Frame.Visible = false
        tab.Frame.Parent = self.ScrollFrame

        -- 标签按钮
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = Theme.GetColor("Surface")
        btn.Text = name
        btn.TextColor3 = Theme.GetColor("Text")
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = self.TabBar
        btn.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        -- 按钮圆角（只上角）
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        tab.Button = btn

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = tab.Frame

        function tab:AddElement(element)
            table.insert(self.Elements, element)
            element.Parent = tab.Frame
            table.insert(self.Window.Elements, element)
        end

        function tab:UpdateTheme()
            btn.BackgroundColor3 = Theme.GetColor("Surface")
            btn.TextColor3 = Theme.GetColor("Text")
            for _, elem in ipairs(self.Elements) do
                if elem.UpdateTheme then elem:UpdateTheme() end
            end
        end

        -- ========== 控件定义 ==========
        -- 按钮控件
        function tab:Button(opts)
            local btnObj = {}
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -16, 0, 28)
            btn.Position = UDim2.new(0, 8, 0, 0)
            btn.BackgroundColor3 = Theme.GetColor("Primary")
            btn.Text = opts.Text or "Button"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.Parent = tab.Frame

            local callback = opts.Callback or function() end
            btn.MouseButton1Click:Connect(function()
                SafeCallback(callback)
            end)

            -- 圆角
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn

            btn.MouseEnter:Connect(function()
                Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("PrimaryHover") })
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("Primary") })
            end)

            LongPressDetector.new(btn, 0.5, function()
                local shortcutName = "按钮: " .. (opts.Text or "Button")
                self:AddShortcutButton(shortcutName, callback)
            end)

            function btnObj:SetText(text)
                btn.Text = text
            end
            function btnObj:UpdateTheme()
                btn.BackgroundColor3 = Theme.GetColor("Primary")
            end
            tab:AddElement(btnObj)
            return btnObj
        end

        -- iOS风格开关控件
        function tab:Toggle(opts)
            local toggle = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 32)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -80, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Toggle"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.Parent = container

            -- iOS 开关背景
            local switchBg = Instance.new("Frame")
            switchBg.Size = UDim2.new(0, 51, 0, 31)
            switchBg.Position = UDim2.new(1, -56, 0.5, -15.5)
            switchBg.BackgroundColor3 = Theme.GetColor("Disabled")
            switchBg.BorderSizePixel = 0
            switchBg.Parent = container
            local switchCorner = Instance.new("UICorner")
            switchCorner.CornerRadius = UDim.new(0, 16)
            switchCorner.Parent = switchBg

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 27, 0, 27)
            thumb.Position = UDim2.new(0, 2, 0.5, -13.5)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.BorderSizePixel = 0
            thumb.Parent = switchBg
            local thumbCorner = Instance.new("UICorner")
            thumbCorner.CornerRadius = UDim.new(1, 0)
            thumbCorner.Parent = thumb

            local value = opts.Value or false
            local callback = opts.Callback or function() end
            local statusName = opts.Text or "Toggle"
            local statusColor = Theme.GetColor("Primary")

            function toggle:Set(v)
                value = v
                local targetColor = value and Theme.GetColor("Primary") or Theme.GetColor("Disabled")
                local targetPos = value and UDim2.new(0, 22, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
                Tween(switchBg, 0.2, { BackgroundColor3 = targetColor })
                Tween(thumb, 0.2, { Position = targetPos })

                SafeCallback(callback, value)

                -- 更新右上角状态显示
                if value then
                    StatusManager.AddStatus(statusName, statusName .. ": 开启", statusColor)
                else
                    StatusManager.RemoveStatus(statusName)
                end
            end

            -- 点击切换
            switchBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle:Set(not value)
                    input:StopPropagation()
                end
            end)

            -- 长按生成快捷键
            LongPressDetector.new(switchBg, 0.5, function()
                local shortcutName = "开关: " .. statusName
                self:AddShortcutButton(shortcutName, function()
                    toggle:Set(not value)
                end)
            end)

            function toggle:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                switchBg.BackgroundColor3 = value and Theme.GetColor("Primary") or Theme.GetColor("Disabled")
                statusColor = Theme.GetColor("Primary")
                if value then
                    StatusManager.UpdateStatus(statusName, statusName .. ": 开启", statusColor)
                end
            end

            toggle:Set(value)
            tab:AddElement(toggle)
            return toggle
        end

        -- 滑块控件（修复并添加圆角）
        function tab:Slider(opts)
            local slider = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 46)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Slider"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.Parent = container

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 45, 0, 18)
            valueLabel.Position = UDim2.new(1, -50, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(opts.Default or 0)
            valueLabel.TextColor3 = Theme.GetColor("TextSecondary")
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 12
            valueLabel.Parent = container

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 4)
            track.Position = UDim2.new(0, 10, 0, 26)
            track.BackgroundColor3 = Theme.GetColor("Border")
            track.BorderSizePixel = 0
            track.Parent = container
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(0, 2)
            trackCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Theme.GetColor("Primary")
            fill.BorderSizePixel = 0
            fill.Parent = track
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(0, 2)
            fillCorner.Parent = fill

            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 12, 0, 12)
            handle.Position = UDim2.new(0, -6, 0.5, -6)
            handle.BackgroundColor3 = Theme.GetColor("Primary")
            handle.BorderSizePixel = 1
            handle.BorderColor3 = Theme.GetColor("Surface")
            handle.Parent = track
            local handleCorner = Instance.new("UICorner")
            handleCorner.CornerRadius = UDim.new(1, 0)
            handleCorner.Parent = handle

            local min = opts.Min or 0
            local max = opts.Max or 100
            local step = opts.Step or 1
            local value = opts.Default or min
            local dragging = false
            local callback = opts.Callback or function() end

            local function updateDisplay(val)
                local percent = (val - min) / (max - min)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                handle.Position = UDim2.new(percent, -6, 0.5, -6)
                valueLabel.Text = tostring(val)
            end

            function slider:Set(val)
                val = math.clamp(val, min, max)
                val = math.floor(val / step + 0.5) * step
                value = val
                updateDisplay(value)
                SafeCallback(callback, value)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local pos = input.Position.X - track.AbsolutePosition.X
                    local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                    local newVal = min + (max - min) * percent
                    slider:Set(newVal)
                    input:StopPropagation()
                end
            end)

            handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    input:StopPropagation()
                end
            end)

            local moveConn
            moveConn = UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position.X - track.AbsolutePosition.X
                    local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                    local newVal = min + (max - min) * percent
                    slider:Set(newVal)
                    input:StopPropagation()
                end
            end)

            local endConn
            endConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            slider:Set(value)
            function slider:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                valueLabel.TextColor3 = Theme.GetColor("TextSecondary")
                track.BackgroundColor3 = Theme.GetColor("Border")
                fill.BackgroundColor3 = Theme.GetColor("Primary")
                handle.BackgroundColor3 = Theme.GetColor("Primary")
                handle.BorderColor3 = Theme.GetColor("Surface")
            end
            tab:AddElement(slider)
            return slider
        end

        -- 输入框控件（圆角）
        function tab:Input(opts)
            local input = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 38)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Input"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.Parent = container

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 0, 24)
            box.Position = UDim2.new(0, 0, 0, 18)
            box.BackgroundColor3 = Theme.GetColor("Surface")
            box.Text = opts.Value or ""
            box.PlaceholderText = opts.Placeholder or ""
            box.TextColor3 = Theme.GetColor("Text")
            box.Font = Enum.Font.SourceSans
            box.TextSize = 12
            box.BorderSizePixel = 1
            box.BorderColor3 = Theme.GetColor("Border")
            box.Parent = container
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = box

            local callback = opts.Callback or function() end
            box.FocusLost:Connect(function()
                SafeCallback(callback, box.Text)
            end)

            function input:Set(text)
                box.Text = text
            end
            function input:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                box.BackgroundColor3 = Theme.GetColor("Surface")
                box.TextColor3 = Theme.GetColor("Text")
                box.BorderColor3 = Theme.GetColor("Border")
            end
            tab:AddElement(input)
            return input
        end

        -- 下拉菜单（圆角）
        function tab:Dropdown(opts)
            local dropdown = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 38)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 18)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Dropdown"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.Parent = container

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.Position = UDim2.new(0, 0, 0, 18)
            btn.BackgroundColor3 = Theme.GetColor("Surface")
            btn.Text = opts.Default or ""
            btn.TextColor3 = Theme.GetColor("Text")
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 12
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Theme.GetColor("Border")
            btn.Parent = container
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.Position = UDim2.new(0, 0, 0, 24)
            dropdownFrame.BackgroundColor3 = Theme.GetColor("Surface")
            dropdownFrame.BorderSizePixel = 1
            dropdownFrame.BorderColor3 = Theme.GetColor("Border")
            dropdownFrame.Visible = false
            dropdownFrame.Parent = container
            local dropCorner = Instance.new("UICorner")
            dropCorner.CornerRadius = UDim.new(0, 6)
            dropCorner.Parent = dropdownFrame

            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 2)
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = dropdownFrame

            local options = opts.Values or {}
            local selected = opts.Default or options[1]
            local callback = opts.Callback or function() end

            function dropdown:UpdateList()
                for _, child in ipairs(dropdownFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, opt in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 26)
                    optBtn.BackgroundColor3 = Theme.GetColor("Surface")
                    optBtn.Text = opt
                    optBtn.TextColor3 = Theme.GetColor("Text")
                    optBtn.Font = Enum.Font.SourceSans
                    optBtn.TextSize = 12
                    optBtn.BorderSizePixel = 0
                    optBtn.Parent = dropdownFrame
                    local optCorner = Instance.new("UICorner")
                    optCorner.CornerRadius = UDim.new(0, 4)
                    optCorner.Parent = optBtn
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        btn.Text = opt
                        dropdownFrame.Visible = false
                        SafeCallback(callback, opt)
                    end)
                end
                dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 26)
            end

            btn.MouseButton1Click:Connect(function()
                dropdownFrame.Visible = not dropdownFrame.Visible
            end)

            dropdown:UpdateList()
            function dropdown:Select(value)
                selected = value
                btn.Text = value
                dropdownFrame.Visible = false
                SafeCallback(callback, value)
            end
            function dropdown:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                btn.BackgroundColor3 = Theme.GetColor("Surface")
                btn.TextColor3 = Theme.GetColor("Text")
                btn.BorderColor3 = Theme.GetColor("Border")
                dropdownFrame.BackgroundColor3 = Theme.GetColor("Surface")
                dropdownFrame.BorderColor3 = Theme.GetColor("Border")
                for _, optBtn in ipairs(dropdownFrame:GetChildren()) do
                    if optBtn:IsA("TextButton") then
                        optBtn.BackgroundColor3 = Theme.GetColor("Surface")
                        optBtn.TextColor3 = Theme.GetColor("Text")
                    end
                end
            end
            tab:AddElement(dropdown)
            return dropdown
        end

        -- 颜色选择器（圆角）
        function tab:Colorpicker(opts)
            local picker = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 38)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 0, 18)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Color"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 13
            label.Parent = container

            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 30, 0, 24)
            colorBtn.Position = UDim2.new(1, -35, 0, 18)
            colorBtn.BackgroundColor3 = opts.Default or Color3.new(1, 1, 1)
            colorBtn.BorderSizePixel = 1
            colorBtn.BorderColor3 = Theme.GetColor("Border")
            colorBtn.Parent = container
            local colorCorner = Instance.new("UICorner")
            colorCorner.CornerRadius = UDim.new(0, 6)
            colorCorner.Parent = colorBtn

            local color = opts.Default or Color3.new(1, 1, 1)
            local callback = opts.Callback or function() end

            function picker:SetColor(c)
                color = c
                colorBtn.BackgroundColor3 = c
                SafeCallback(callback, c)
            end

            colorBtn.MouseButton1Click:Connect(function()
                local dialog = Instance.new("Frame")
                dialog.Size = UDim2.new(0, 200, 0, 150)
                dialog.Position = UDim2.new(0.5, -100, 0.5, -75)
                dialog.BackgroundColor3 = Theme.GetColor("Surface")
                dialog.BorderSizePixel = 1
                dialog.BorderColor3 = Theme.GetColor("Border")
                dialog.Parent = self.Main
                local dialogCorner = Instance.new("UICorner")
                dialogCorner.CornerRadius = UDim.new(0, 8)
                dialogCorner.Parent = dialog

                local rSlider, gSlider, bSlider
                local function updateColor()
                    local r = rSlider:GetValue() / 255
                    local g = gSlider:GetValue() / 255
                    local b = bSlider:GetValue() / 255
                    picker:SetColor(Color3.new(r, g, b))
                end

                local function addSlider(text, default)
                    local cont = Instance.new("Frame")
                    cont.Size = UDim2.new(1, -20, 0, 28)
                    cont.Position = UDim2.new(0, 10, 0, 0)
                    cont.BackgroundTransparency = 1
                    cont.Parent = dialog

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(0, 20, 1, 0)
                    lbl.Position = UDim2.new(0, 0, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = text
                    lbl.TextColor3 = Theme.GetColor("Text")
                    lbl.Font = Enum.Font.SourceSans
                    lbl.TextSize = 11
                    lbl.Parent = cont

                    local sliderObj = {}
                    local track = Instance.new("Frame")
                    track.Size = UDim2.new(1, -50, 0, 4)
                    track.Position = UDim2.new(0, 25, 0.5, -2)
                    track.BackgroundColor3 = Theme.GetColor("Border")
                    track.BorderSizePixel = 0
                    track.Parent = cont
                    local trackCorner = Instance.new("UICorner")
                    trackCorner.CornerRadius = UDim.new(0, 2)
                    trackCorner.Parent = track

                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = Theme.GetColor("Primary")
                    fill.BorderSizePixel = 0
                    fill.Parent = track
                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(0, 2)
                    fillCorner.Parent = fill

                    local handle = Instance.new("Frame")
                    handle.Size = UDim2.new(0, 8, 0, 8)
                    handle.Position = UDim2.new(0, -4, 0.5, -4)
                    handle.BackgroundColor3 = Theme.GetColor("Primary")
                    handle.BorderSizePixel = 1
                    handle.BorderColor3 = Theme.GetColor("Surface")
                    handle.Parent = track
                    local handleCorner = Instance.new("UICorner")
                    handleCorner.CornerRadius = UDim.new(1, 0)
                    handleCorner.Parent = handle

                    local val = default
                    function sliderObj:Set(v)
                        val = v
                        local percent = v / 255
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        handle.Position = UDim2.new(percent, -4, 0.5, -4)
                    end
                    function sliderObj:GetValue()
                        return val
                    end
                    local dragging = false
                    track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            local pos = input.Position.X - track.AbsolutePosition.X
                            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                            local newVal = math.floor(percent * 255 + 0.5)
                            sliderObj:Set(newVal)
                            updateColor()
                            input:StopPropagation()
                        end
                    end)
                    handle.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            input:StopPropagation()
                        end
                    end)
                    local moveConn
                    moveConn = UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pos = input.Position.X - track.AbsolutePosition.X
                            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                            local newVal = math.floor(percent * 255 + 0.5)
                            sliderObj:Set(newVal)
                            updateColor()
                            input:StopPropagation()
                        end
                    end)
                    local endConn
                    endConn = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    sliderObj:Set(default)
                    return sliderObj
                end

                rSlider = addSlider("R", color.R * 255)
                gSlider = addSlider("G", color.G * 255)
                bSlider = addSlider("B", color.B * 255)

                local closeBtn = Instance.new("TextButton")
                closeBtn.Size = UDim2.new(0, 60, 0, 24)
                closeBtn.Position = UDim2.new(1, -70, 1, -32)
                closeBtn.BackgroundColor3 = Theme.GetColor("Primary")
                closeBtn.Text = "OK"
                closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                closeBtn.Font = Enum.Font.SourceSans
                closeBtn.TextSize = 12
                closeBtn.BorderSizePixel = 0
                closeBtn.Parent = dialog
                local closeCorner = Instance.new("UICorner")
                closeCorner.CornerRadius = UDim.new(0, 6)
                closeCorner.Parent = closeBtn
                closeBtn.MouseButton1Click:Connect(function()
                    dialog:Destroy()
                end)
            end)

            function picker:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                colorBtn.BorderColor3 = Theme.GetColor("Border")
            end
            tab:AddElement(picker)
            return picker
        end

        -- 段落文本控件（圆角）
        function tab:Paragraph(opts)
            local para = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -16, 0, 0)
            container.Position = UDim2.new(0, 8, 0, 0)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Parent = tab.Frame

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = opts.Text or ""
            text.TextColor3 = Theme.GetColor("Text")
            text.Font = Enum.Font.SourceSans
            text.TextSize = 13
            text.TextWrapped = true
            text.TextXAlignment = Enum.TextXAlignment.Left
            text.AutomaticSize = Enum.AutomaticSize.Y
            text.Parent = container

            if opts.Desc then
                local desc = Instance.new("TextLabel")
                desc.Size = UDim2.new(1, 0, 0, 0)
                desc.BackgroundTransparency = 1
                desc.Text = opts.Desc
                desc.TextColor3 = Theme.GetColor("TextSecondary")
                desc.Font = Enum.Font.SourceSans
                desc.TextSize = 11
                desc.TextWrapped = true
                desc.TextXAlignment = Enum.TextXAlignment.Left
                desc.AutomaticSize = Enum.AutomaticSize.Y
                desc.Parent = container
                local list = Instance.new("UIListLayout")
                list.Padding = UDim.new(0, 4)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Parent = container
            end

            function para:SetText(newText)
                text.Text = newText
            end
            function para:SetDesc(newDesc)
                local desc = container:FindFirstChildOfClass("TextLabel")
                if not desc and newDesc then
                    desc = Instance.new("TextLabel")
                    desc.Size = UDim2.new(1, 0, 0, 0)
                    desc.BackgroundTransparency = 1
                    desc.Text = newDesc
                    desc.TextColor3 = Theme.GetColor("TextSecondary")
                    desc.Font = Enum.Font.SourceSans
                    desc.TextSize = 11
                    desc.TextWrapped = true
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                    desc.AutomaticSize = Enum.AutomaticSize.Y
                    desc.Parent = container
                    local list = Instance.new("UIListLayout")
                    list.Padding = UDim.new(0, 4)
                    list.SortOrder = Enum.SortOrder.LayoutOrder
                    list.Parent = container
                elseif desc then
                    desc.Text = newDesc or ""
                end
            end
            function para:UpdateTheme()
                text.TextColor3 = Theme.GetColor("Text")
                local desc = container:FindFirstChildOfClass("TextLabel")
                if desc then
                    desc.TextColor3 = Theme.GetColor("TextSecondary")
                end
            end
            tab:AddElement(para)
            return para
        end

        -- 分隔线
        function tab:Divider()
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -16, 0, 1)
            line.Position = UDim2.new(0, 8, 0, 0)
            line.BackgroundColor3 = Theme.GetColor("Border")
            line.BorderSizePixel = 0
            line.Parent = tab.Frame
        end

        -- 间距
        function tab:Space(height)
            local space = Instance.new("Frame")
            space.Size = UDim2.new(1, -16, 0, height or 8)
            space.BackgroundTransparency = 1
            space.Parent = tab.Frame
        end

        -- 左右分栏布局（独立滚动修复版）
        function tab:CreateTwoColumn()
            local left = Instance.new("Frame")
            left.Size = UDim2.new(0.5, -4, 1, 0)
            left.Position = UDim2.new(0, 0, 0, 0)
            left.BackgroundColor3 = Theme.GetColor("Surface")
            left.BorderSizePixel = 1
            left.BorderColor3 = Theme.GetColor("Border")
            left.Parent = tab.Frame
            local leftCorner = Instance.new("UICorner")
            leftCorner.CornerRadius = UDim.new(0, 6)
            leftCorner.Parent = left

            local right = Instance.new("Frame")
            right.Size = UDim2.new(0.5, -4, 1, 0)
            right.Position = UDim2.new(0.5, 4, 0, 0)
            right.BackgroundColor3 = Theme.GetColor("Surface")
            right.BorderSizePixel = 1
            right.BorderColor3 = Theme.GetColor("Border")
            right.Parent = tab.Frame
            local rightCorner = Instance.new("UICorner")
            rightCorner.CornerRadius = UDim.new(0, 6)
            rightCorner.Parent = right

            local leftScroll = Instance.new("ScrollingFrame")
            leftScroll.Size = UDim2.new(1, 0, 1, 0)
            leftScroll.BackgroundTransparency = 1
            leftScroll.BorderSizePixel = 0
            leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            leftScroll.ScrollBarThickness = 4
            leftScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            leftScroll.Parent = left

            local leftList = Instance.new("UIListLayout")
            leftList.Padding = UDim.new(0, 6)
            leftList.SortOrder = Enum.SortOrder.LayoutOrder
            leftList.Parent = leftScroll

            local rightScroll = Instance.new("ScrollingFrame")
            rightScroll.Size = UDim2.new(1, 0, 1, 0)
            rightScroll.BackgroundTransparency = 1
            rightScroll.BorderSizePixel = 0
            rightScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            rightScroll.ScrollBarThickness = 4
            rightScroll.ScrollingDirection = Enum.ScrollingDirection.Y
            rightScroll.Parent = right

            local rightList = Instance.new("UIListLayout")
            rightList.Padding = UDim.new(0, 6)
            rightList.SortOrder = Enum.SortOrder.LayoutOrder
            rightList.Parent = rightScroll

            local function updateLeftCanvas()
                leftScroll.CanvasSize = UDim2.new(0, 0, 0, leftList.AbsoluteContentSize.Y + 6)
            end
            local function updateRightCanvas()
                rightScroll.CanvasSize = UDim2.new(0, 0, 0, rightList.AbsoluteContentSize.Y + 6)
            end
            leftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateLeftCanvas)
            rightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateRightCanvas)
            updateLeftCanvas()
            updateRightCanvas()

            -- 确保每个区域独立滚动：通过设置 ScrollFrame 的 Active 属性，并阻止事件穿透
            leftScroll.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    input:StopPropagation()
                end
            end)
            rightScroll.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    input:StopPropagation()
                end
            end)

            local function createContainerAPI(containerScroll, containerList)
                local api = {}
                function api:Button(opts)
                    local btnObj = {}
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -12, 0, 28)
                    btn.Position = UDim2.new(0, 6, 0, 0)
                    btn.BackgroundColor3 = Theme.GetColor("Primary")
                    btn.Text = opts.Text or "Button"
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Font = Enum.Font.SourceSans
                    btn.TextSize = 12
                    btn.BorderSizePixel = 0
                    btn.Parent = containerScroll
                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 8)
                    btnCorner.Parent = btn

                    local callback = opts.Callback or function() end
                    btn.MouseButton1Click:Connect(function()
                        SafeCallback(callback)
                    end)
                    btn.MouseEnter:Connect(function()
                        Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("PrimaryHover") })
                    end)
                    btn.MouseLeave:Connect(function()
                        Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("Primary") })
                    end)
                    function btnObj:SetText(text)
                        btn.Text = text
                    end
                    function btnObj:UpdateTheme()
                        btn.BackgroundColor3 = Theme.GetColor("Primary")
                    end
                    return btnObj
                end
                function api:Toggle(opts)
                    local toggle = {}
                    local container = Instance.new("Frame")
                    container.Size = UDim2.new(1, -12, 0, 30)
                    container.Position = UDim2.new(0, 6, 0, 0)
                    container.BackgroundTransparency = 1
                    container.Parent = containerScroll

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, -70, 1, 0)
                    label.Position = UDim2.new(0, 4, 0, 0)
                    label.BackgroundTransparency = 1
                    label.Text = opts.Text or "Toggle"
                    label.TextColor3 = Theme.GetColor("Text")
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Font = Enum.Font.SourceSans
                    label.TextSize = 12
                    label.Parent = container

                    local switchBg = Instance.new("Frame")
                    switchBg.Size = UDim2.new(0, 46, 0, 28)
                    switchBg.Position = UDim2.new(1, -50, 0.5, -14)
                    switchBg.BackgroundColor3 = Theme.GetColor("Disabled")
                    switchBg.BorderSizePixel = 0
                    switchBg.Parent = container
                    local switchCorner = Instance.new("UICorner")
                    switchCorner.CornerRadius = UDim.new(0, 14)
                    switchCorner.Parent = switchBg

                    local thumb = Instance.new("Frame")
                    thumb.Size = UDim2.new(0, 24, 0, 24)
                    thumb.Position = UDim2.new(0, 2, 0.5, -12)
                    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    thumb.BorderSizePixel = 0
                    thumb.Parent = switchBg
                    local thumbCorner = Instance.new("UICorner")
                    thumbCorner.CornerRadius = UDim.new(1, 0)
                    thumbCorner.Parent = thumb

                    local value = opts.Value or false
                    local callback = opts.Callback or function() end

                    function toggle:Set(v)
                        value = v
                        local targetColor = value and Theme.GetColor("Primary") or Theme.GetColor("Disabled")
                        local targetPos = value and UDim2.new(0, 20, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
                        Tween(switchBg, 0.2, { BackgroundColor3 = targetColor })
                        Tween(thumb, 0.2, { Position = targetPos })
                        SafeCallback(callback, value)
                    end
                    switchBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            toggle:Set(not value)
                            input:StopPropagation()
                        end
                    end)
                    toggle:Set(value)
                    return toggle
                end
                -- 其他控件可按需添加（Slider, Input, Dropdown, Colorpicker, Paragraph）
                return api
            end

            local leftAPI = createContainerAPI(leftScroll, leftList)
            local rightAPI = createContainerAPI(rightScroll, rightList)

            return { left = leftAPI, right = rightAPI }
        end

        -- 更新滚动画布
        local function updateCanvas()
            self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.UIList.AbsoluteContentSize.Y + 8)
        end
        self.UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        updateCanvas()

        table.insert(self.Tabs, tab)
        if not self.CurrentTab then
            self:SelectTab(tab)
        end
        return tab
    end

    -- 安全的 SelectTab
    function self:SelectTab(tab)
        if self.CurrentTab == tab then return end
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = (t == tab)
            if type(t.Button) == "userdata" and t.Button:IsA("TextButton") then
                t.Button.BackgroundColor3 = (t == tab) and Theme.GetColor("Primary") or Theme.GetColor("Surface")
                t.Button.TextColor3 = (t == tab) and Color3.fromRGB(255, 255, 255) or Theme.GetColor("Text")
            end
        end
        self.CurrentTab = tab
    end

    return self
end

-- ==================== 库入口 ====================
local WasUI = {}
WasUI.Window = Window
WasUI.ConfigManager = ConfigManager
WasUI.Theme = Theme
WasUI.Icon = function(name) return WasUI:GetIcon(name) end

function WasUI:CreateWindow(data)
    return self.Window:Create(data)
end

function WasUI:SetTheme(name)
    return self.Theme.SetTheme(name)
end

function WasUI:GetTheme()
    return self.Theme.Current
end

function WasUI:InitConfig(folder)
    self.ConfigManager.Init(folder)
end

function WasUI:GetIcon(name)
    return IconLibrary[name] or name
end

return WasUI