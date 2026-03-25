--[[
    WasUI - 轻量级直角风格 UI 库（修复版）
    特性：
    - 窗口背景支持 URL 图片或纯色
    - 按钮/开关长按生成浮动快捷键按钮（与主 UI 分离）
    - 主题切换（亮色/暗色）
    - 控件：按钮、开关、滑块、输入框、下拉菜单、颜色选择器、段落文本
    - 配置管理器（保存用户设置）
    - 拖动时阻止事件传递到游戏世界
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== 辅助函数 ====================
local function Tween(obj, duration, properties)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
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

-- ==================== 窗口类 ====================
local Window = {}
Window.__index = Window

function Window:Create(data)
    local self = setmetatable({}, Window)
    self.Title = data.Title or "Window"
    self.Size = data.Size or UDim2.new(0, 600, 0, 400)
    self.MinSize = data.MinSize or Vector2.new(400, 300)
    self.MaxSize = data.MaxSize or Vector2.new(1000, 800)
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

    -- 创建 ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WasUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = screenGui

    -- 主窗口 Frame
    self.Main = Instance.new("Frame")
    self.Main.Size = self.Size
    self.Main.Position = self.Position
    self.Main.BackgroundColor3 = Theme.GetColor("Background")
    self.Main.BorderSizePixel = 1
    self.Main.BorderColor3 = Theme.GetColor("Border")
    self.Main.ClipsDescendants = true
    self.Main.Active = true  -- 允许接收输入
    self.Main.Parent = screenGui

    -- 背景图片/颜色处理
    local backgroundImg = nil
    if data.Background then
        if type(data.Background) == "string" and data.Background:match("^https?://") then
            backgroundImg = Instance.new("ImageLabel")
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

    -- 标题栏（用于拖拽）
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Theme.GetColor("Surface")
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Active = true
    self.TitleBar.Parent = self.Main

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 5, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = Theme.GetColor("Text")
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Font = Enum.Font.SourceSansBold
    self.TitleLabel.TextSize = 14
    self.TitleLabel.Parent = self.TitleBar

    -- 关闭按钮
    if self.Closable then
        self.CloseBtn = Instance.new("TextButton")
        self.CloseBtn.Size = UDim2.new(0, 30, 1, 0)
        self.CloseBtn.Position = UDim2.new(1, -30, 0, 0)
        self.CloseBtn.BackgroundColor3 = Theme.GetColor("Surface")
        self.CloseBtn.Text = "✕"
        self.CloseBtn.TextColor3 = Theme.GetColor("Text")
        self.CloseBtn.Font = Enum.Font.SourceSansBold
        self.CloseBtn.TextSize = 16
        self.CloseBtn.BorderSizePixel = 0
        self.CloseBtn.Parent = self.TitleBar
        self.CloseBtn.MouseButton1Click:Connect(function()
            self:Close()
        end)
    end

    -- 标签页容器
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(1, 0, 1, -30)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundTransparency = 1
    self.TabContainer.Parent = self.Main

    -- 标签页按钮区域
    self.TabBar = Instance.new("Frame")
    self.TabBar.Size = UDim2.new(1, 0, 0, 30)
    self.TabBar.BackgroundColor3 = Theme.GetColor("Surface")
    self.TabBar.BorderSizePixel = 0
    self.TabBar.Parent = self.TabContainer

    -- 内容区域
    self.ContentArea = Instance.new("Frame")
    self.ContentArea.Size = UDim2.new(1, 0, 1, -30)
    self.ContentArea.Position = UDim2.new(0, 0, 0, 30)
    self.ContentArea.BackgroundTransparency = 1
    self.ContentArea.Parent = self.TabContainer

    -- 滚动区域
    self.ScrollFrame = Instance.new("ScrollingFrame")
    self.ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ScrollFrame.BackgroundTransparency = 1
    self.ScrollFrame.BorderSizePixel = 0
    self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.ScrollFrame.ScrollBarThickness = 6
    self.ScrollFrame.ScrollBarImageTransparency = 0.5
    self.ScrollFrame.Parent = self.ContentArea

    self.UIList = Instance.new("UIListLayout")
    self.UIList.Padding = UDim.new(0, 10)
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
                input:StopPropagation()  -- 阻止事件传递到游戏世界
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

    -- 创建浮动快捷键按钮的容器（独立于主窗口）
    self.ShortcutContainer = Instance.new("Frame")
    self.ShortcutContainer.Size = UDim2.new(0, 200, 0, 0)
    self.ShortcutContainer.Position = UDim2.new(1, -210, 0, 10)
    self.ShortcutContainer.BackgroundTransparency = 1
    self.ShortcutContainer.ZIndex = 10
    self.ShortcutContainer.Parent = screenGui

    local shortcutList = Instance.new("UIListLayout")
    shortcutList.Padding = UDim.new(0, 5)
    shortcutList.SortOrder = Enum.SortOrder.LayoutOrder
    shortcutList.Parent = self.ShortcutContainer

    function self:AddShortcutButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 180, 0, 30)
        btn.BackgroundColor3 = Theme.GetColor("Primary")
        btn.Text = "⚡ " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = self.ShortcutContainer
        btn.MouseButton1Click:Connect(callback)

        btn.MouseEnter:Connect(function()
            Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("PrimaryHover") })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, 0.1, { BackgroundColor3 = Theme.GetColor("Primary") })
        end)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 20, 1, 0)
        closeBtn.Position = UDim2.new(1, -20, 0, 0)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 12
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = btn
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
        if self.CloseBtn then
            self.CloseBtn.BackgroundColor3 = Theme.GetColor("Surface")
            self.CloseBtn.TextColor3 = Theme.GetColor("Text")
        end
        self.TabBar.BackgroundColor3 = Theme.GetColor("Surface")
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

        -- 标签按钮（确保是 TextButton 实例）
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundColor3 = Theme.GetColor("Surface")
        btn.Text = name
        btn.TextColor3 = Theme.GetColor("Text")
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = self.TabBar
        btn.MouseButton1Click:Connect(function()
            self:SelectTab(tab)
        end)

        tab.Button = btn  -- 保存为按钮实例

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 10)
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
            btn.Size = UDim2.new(1, -20, 0, 35)
            btn.Position = UDim2.new(0, 10, 0, 0)
            btn.BackgroundColor3 = Theme.GetColor("Primary")
            btn.Text = opts.Text or "Button"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.BorderSizePixel = 0
            btn.Parent = tab.Frame

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

            -- 长按生成快捷键按钮
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

        -- 开关控件
        function tab:Toggle(opts)
            local toggle = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 35)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Toggle"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.Parent = container

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 50, 0, 25)
            btn.Position = UDim2.new(1, -55, 0.5, -12.5)
            btn.BackgroundColor3 = Theme.GetColor("Primary")
            btn.Text = opts.Value and "ON" or "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.Parent = container

            local value = opts.Value or false
            local callback = opts.Callback or function() end

            function toggle:Set(v)
                value = v
                btn.Text = value and "ON" or "OFF"
                btn.BackgroundColor3 = value and Theme.GetColor("Primary") or Theme.GetColor("Disabled")
                SafeCallback(callback, value)
            end

            btn.MouseButton1Click:Connect(function()
                toggle:Set(not value)
            end)

            -- 长按生成快捷键按钮（开关的快捷键会切换状态）
            LongPressDetector.new(btn, 0.5, function()
                local shortcutName = "开关: " .. (opts.Text or "Toggle")
                self:AddShortcutButton(shortcutName, function()
                    toggle:Set(not value)
                end)
            end)

            function toggle:UpdateTheme()
                label.TextColor3 = Theme.GetColor("Text")
                btn.BackgroundColor3 = value and Theme.GetColor("Primary") or Theme.GetColor("Disabled")
            end

            toggle:Set(value)
            tab:AddElement(toggle)
            return toggle
        end

        -- 滑块控件
        function tab:Slider(opts)
            local slider = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 50)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Slider"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.Parent = container

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -55, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(opts.Default or 0)
            valueLabel.TextColor3 = Theme.GetColor("TextSecondary")
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 12
            valueLabel.Parent = container

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 4)
            track.Position = UDim2.new(0, 10, 0, 30)
            track.BackgroundColor3 = Theme.GetColor("Border")
            track.BorderSizePixel = 0
            track.Parent = container

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Theme.GetColor("Primary")
            fill.BorderSizePixel = 0
            fill.Parent = track

            local handle = Instance.new("Frame")
            handle.Size = UDim2.new(0, 12, 0, 12)
            handle.Position = UDim2.new(0, -6, 0.5, -6)
            handle.BackgroundColor3 = Theme.GetColor("Primary")
            handle.BorderSizePixel = 1
            handle.BorderColor3 = Theme.GetColor("Surface")
            handle.Parent = track

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

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = input.Position.X - track.AbsolutePosition.X
                    local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                    local newVal = min + (max - min) * percent
                    slider:Set(newVal)
                    input:StopPropagation()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
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

        -- 输入框控件
        function tab:Input(opts)
            local input = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 40)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Input"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.Parent = container

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 0, 25)
            box.Position = UDim2.new(0, 0, 0, 20)
            box.BackgroundColor3 = Theme.GetColor("Surface")
            box.Text = opts.Value or ""
            box.PlaceholderText = opts.Placeholder or ""
            box.TextColor3 = Theme.GetColor("Text")
            box.Font = Enum.Font.SourceSans
            box.TextSize = 14
            box.BorderSizePixel = 1
            box.BorderColor3 = Theme.GetColor("Border")
            box.Parent = container

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

        -- 下拉菜单控件
        function tab:Dropdown(opts)
            local dropdown = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 40)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Dropdown"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.Parent = container

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 25)
            btn.Position = UDim2.new(0, 0, 0, 20)
            btn.BackgroundColor3 = Theme.GetColor("Surface")
            btn.Text = opts.Default or ""
            btn.TextColor3 = Theme.GetColor("Text")
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Theme.GetColor("Border")
            btn.Parent = container

            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.Position = UDim2.new(0, 0, 0, 25)
            dropdownFrame.BackgroundColor3 = Theme.GetColor("Surface")
            dropdownFrame.BorderSizePixel = 1
            dropdownFrame.BorderColor3 = Theme.GetColor("Border")
            dropdownFrame.Visible = false
            dropdownFrame.Parent = container

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
                    optBtn.Size = UDim2.new(1, 0, 0, 30)
                    optBtn.BackgroundColor3 = Theme.GetColor("Surface")
                    optBtn.Text = opt
                    optBtn.TextColor3 = Theme.GetColor("Text")
                    optBtn.Font = Enum.Font.SourceSans
                    optBtn.TextSize = 14
                    optBtn.BorderSizePixel = 0
                    optBtn.Parent = dropdownFrame
                    optBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        btn.Text = opt
                        dropdownFrame.Visible = false
                        SafeCallback(callback, opt)
                    end)
                end
                dropdownFrame.Size = UDim2.new(1, 0, 0, #options * 30)
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

        -- 颜色选择器（简化版）
        function tab:Colorpicker(opts)
            local picker = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 40)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.Parent = tab.Frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 0, 20)
            label.Position = UDim2.new(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = opts.Text or "Color"
            label.TextColor3 = Theme.GetColor("Text")
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Font = Enum.Font.SourceSans
            label.TextSize = 14
            label.Parent = container

            local colorBtn = Instance.new("TextButton")
            colorBtn.Size = UDim2.new(0, 30, 0, 25)
            colorBtn.Position = UDim2.new(1, -35, 0, 20)
            colorBtn.BackgroundColor3 = opts.Default or Color3.new(1, 1, 1)
            colorBtn.BorderSizePixel = 1
            colorBtn.BorderColor3 = Theme.GetColor("Border")
            colorBtn.Parent = container

            local color = opts.Default or Color3.new(1, 1, 1)
            local callback = opts.Callback or function() end

            function picker:SetColor(c)
                color = c
                colorBtn.BackgroundColor3 = c
                SafeCallback(callback, c)
            end

            -- 简易颜色选择器对话框（略，保持简单）
            colorBtn.MouseButton1Click:Connect(function()
                local dialog = Instance.new("Frame")
                dialog.Size = UDim2.new(0, 200, 0, 150)
                dialog.Position = UDim2.new(0.5, -100, 0.5, -75)
                dialog.BackgroundColor3 = Theme.GetColor("Surface")
                dialog.BorderSizePixel = 1
                dialog.BorderColor3 = Theme.GetColor("Border")
                dialog.Parent = self.Main

                local rSlider, gSlider, bSlider
                local function updateColor()
                    local r = rSlider:GetValue() / 255
                    local g = gSlider:GetValue() / 255
                    local b = bSlider:GetValue() / 255
                    picker:SetColor(Color3.new(r, g, b))
                end

                local function addSlider(text, default)
                    local cont = Instance.new("Frame")
                    cont.Size = UDim2.new(1, -20, 0, 30)
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
                    lbl.TextSize = 12
                    lbl.Parent = cont

                    local sliderObj = {}
                    local track = Instance.new("Frame")
                    track.Size = UDim2.new(1, -50, 0, 4)
                    track.Position = UDim2.new(0, 25, 0.5, -2)
                    track.BackgroundColor3 = Theme.GetColor("Border")
                    track.BorderSizePixel = 0
                    track.Parent = cont

                    local fill = Instance.new("Frame")
                    fill.Size = UDim2.new(0, 0, 1, 0)
                    fill.BackgroundColor3 = Theme.GetColor("Primary")
                    fill.BorderSizePixel = 0
                    fill.Parent = track

                    local handle = Instance.new("Frame")
                    handle.Size = UDim2.new(0, 8, 0, 8)
                    handle.Position = UDim2.new(0, -4, 0.5, -4)
                    handle.BackgroundColor3 = Theme.GetColor("Primary")
                    handle.BorderSizePixel = 1
                    handle.BorderColor3 = Theme.GetColor("Surface")
                    handle.Parent = track

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
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local pos = input.Position.X - track.AbsolutePosition.X
                            local percent = math.clamp(pos / track.AbsoluteSize.X, 0, 1)
                            local newVal = math.floor(percent * 255 + 0.5)
                            sliderObj:Set(newVal)
                            updateColor()
                            input:StopPropagation()
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
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
                closeBtn.Size = UDim2.new(0, 60, 0, 25)
                closeBtn.Position = UDim2.new(1, -70, 1, -35)
                closeBtn.BackgroundColor3 = Theme.GetColor("Primary")
                closeBtn.Text = "OK"
                closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                closeBtn.Font = Enum.Font.SourceSans
                closeBtn.TextSize = 14
                closeBtn.BorderSizePixel = 0
                closeBtn.Parent = dialog
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

        -- 段落文本控件（用于显示文字）
        function tab:Paragraph(opts)
            local para = {}
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -20, 0, 0)
            container.Position = UDim2.new(0, 10, 0, 0)
            container.BackgroundTransparency = 1
            container.AutomaticSize = Enum.AutomaticSize.Y
            container.Parent = tab.Frame

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 0, 0)
            text.BackgroundTransparency = 1
            text.Text = opts.Text or ""
            text.TextColor3 = Theme.GetColor("Text")
            text.Font = Enum.Font.SourceSans
            text.TextSize = 14
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
                desc.TextSize = 12
                desc.TextWrapped = true
                desc.TextXAlignment = Enum.TextXAlignment.Left
                desc.AutomaticSize = Enum.AutomaticSize.Y
                desc.Parent = container
                local list = Instance.new("UIListLayout")
                list.Padding = UDim.new(0, 5)
                list.SortOrder = Enum.SortOrder.LayoutOrder
                list.Parent = container
            end

            function para:SetText(newText)
                text.Text = newText
            end
            function para:SetDesc(newDesc)
                -- 简单实现：若没有 desc 则创建，否则更新
                local desc = container:FindFirstChildOfClass("TextLabel")
                if not desc and newDesc then
                    desc = Instance.new("TextLabel")
                    desc.Size = UDim2.new(1, 0, 0, 0)
                    desc.BackgroundTransparency = 1
                    desc.Text = newDesc
                    desc.TextColor3 = Theme.GetColor("TextSecondary")
                    desc.Font = Enum.Font.SourceSans
                    desc.TextSize = 12
                    desc.TextWrapped = true
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                    desc.AutomaticSize = Enum.AutomaticSize.Y
                    desc.Parent = container
                    local list = Instance.new("UIListLayout")
                    list.Padding = UDim.new(0, 5)
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

        function tab:Divider()
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -20, 0, 1)
            line.Position = UDim2.new(0, 10, 0, 0)
            line.BackgroundColor3 = Theme.GetColor("Border")
            line.BorderSizePixel = 0
            line.Parent = tab.Frame
        end

        function tab:Space(height)
            local space = Instance.new("Frame")
            space.Size = UDim2.new(1, -20, 0, height or 10)
            space.BackgroundTransparency = 1
            space.Parent = tab.Frame
        end

        -- 更新滚动画布
        local function updateCanvas()
            self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self.UIList.AbsoluteContentSize.Y + 10)
        end
        self.UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        updateCanvas()

        table.insert(self.Tabs, tab)
        if not self.CurrentTab then
            self:SelectTab(tab)
        end
        return tab
    end

    -- 安全的 SelectTab 实现
    function self:SelectTab(tab)
        if self.CurrentTab == tab then return end
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = (t == tab)
            -- 确保 t.Button 是有效的 TextButton 实例
            if type(t.Button) == "userdata" and t.Button:IsA("TextButton") then
                t.Button.BackgroundColor3 = (t == tab) and Theme.GetColor("Primary") or Theme.GetColor("Surface")
                t.Button.TextColor3 = (t == tab) and Color3.fromRGB(255, 255, 255) or Theme.GetColor("Text")
            else
                warn("[WasUI] Invalid tab button for tab:", t.Name)
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

return WasUI