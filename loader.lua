-- ============================================
-- 蛙Was脚本加载器 v3.0
-- 智能识别游戏并加载对应脚本
-- GitHub: https://github.com/WasKKal
-- ============================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- 配置文件
local CONFIG = {
    -- GitHub仓库配置
    GITHUB_USER = "WasKKal",
    GITHUB_REPO = "-",
    GITHUB_BRANCH = "main",
    
    -- 脚本文件映射
    SCRIPTS = {
        loader = "loader.lua",
        back_alley = "在后巷.lua",
        grass_cutting = "割草模拟器.lua"
    },
    
    -- 性能配置
    CACHE_ENABLED = true,
    CACHE_DURATION = 600, -- 10分钟缓存
    DEBUG_MODE = true,
    
    -- 游戏识别配置
    KNOWN_GAMES = {
        [133086043677134] = "grass_cutting",  -- 割草模拟器
        [11257760806] = "back_alley",         -- 在后巷模拟器
    }
}

-- 缓存系统
local cache = {}
local cacheTimestamps = {}

-- 日志系统
local Logger = {
    log = function(message, level)
        if not CONFIG.DEBUG_MODE then return end
        local timestamp = os.date("%H:%M:%S")
        local prefix = level == "warn" and "[⚠️] " or level == "error" and "[❌] " or "[ℹ️] "
        print(string.format("[%s] %s%s", timestamp, prefix, message))
    end
}

-- 构建GitHub URL
local function buildGitHubUrl(filename)
    return string.format("https://raw.githubusercontent.com/%s/%s/%s/%s",
        CONFIG.GITHUB_USER,
        CONFIG.GITHUB_REPO,
        CONFIG.GITHUB_BRANCH,
        filename
    )
end

-- 安全获取远程脚本
local function fetchScript(scriptName)
    local filename = CONFIG.SCRIPTS[scriptName]
    if not filename then
        Logger.log("未找到脚本: " .. scriptName, "error")
        return nil
    end
    
    local cacheKey = scriptName
    local url = buildGitHubUrl(filename)
    
    -- 检查缓存
    if CONFIG.CACHE_ENABLED and cache[cacheKey] and cacheTimestamps[cacheKey] then
        local timeDiff = os.time() - cacheTimestamps[cacheKey]
        if timeDiff < CONFIG.CACHE_DURATION then
            Logger.log("使用缓存的脚本: " .. scriptName)
            return cache[cacheKey]
        end
    end
    
    Logger.log("正在获取脚本: " .. scriptName .. " (" .. url .. ")")
    
    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    
    if success then
        -- 验证脚本内容
        if result and #result > 0 then
            -- 更新缓存
            if CONFIG.CACHE_ENABLED then
                cache[cacheKey] = result
                cacheTimestamps[cacheKey] = os.time()
            end
            Logger.log("脚本获取成功: " .. scriptName)
            return result
        else
            Logger.log("脚本内容为空: " .. scriptName, "error")
        end
    else
        Logger.log("获取脚本失败: " .. tostring(result), "error")
    end
    
    return nil
end

-- 游戏识别器
local GameDetector = {
    -- 获取游戏信息
    getGameInfo = function(self)
        local info = {
            placeId = game.PlaceId,
            jobId = game.JobId,
            isPrivate = game.PrivateServerId ~= "",
            playerCount = #Players:GetPlayers()
        }
        
        -- 获取游戏名称
        local success, productInfo = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)
        
        if success then
            info.name = productInfo.Name
            info.description = productInfo.Description
            info.creator = productInfo.Creator.Name
        else
            info.name = "未知游戏"
        end
        
        return info
    end,
    
    -- 检测游戏类型
    detectGame = function(self)
        local gameInfo = self:getGameInfo()
        local placeId = gameInfo.placeId
        
        Logger.log("正在检测游戏...")
        Logger.log("游戏ID: " .. placeId)
        Logger.log("游戏名称: " .. gameInfo.name)
        
        -- 方法1：通过已知ID识别
        if CONFIG.KNOWN_GAMES[placeId] then
            local scriptType = CONFIG.KNOWN_GAMES[placeId]
            Logger.log("通过已知ID识别为: " .. scriptType)
            return scriptType, gameInfo
        end
        
        -- 方法2：通过名称关键词识别
        local gameName = gameInfo.name:lower()
        
        -- 割草模拟器关键词
        local grassKeywords = {"grass", "割草", "lawn", "mow", "gras", "草坪"}
        for _, keyword in ipairs(grassKeywords) do
            if string.find(gameName, keyword:lower()) then
                Logger.log("通过名称关键词识别为: grass_cutting")
                return "grass_cutting", gameInfo
            end
        end
        
        -- 在后巷模拟器关键词
        local alleyKeywords = {"后巷", "back alley", "alley", "trash", "垃圾", "street"}
        for _, keyword in ipairs(alleyKeywords) do
            if string.find(gameName, keyword:lower()) then
                Logger.log("通过名称关键词识别为: back_alley")
                return "back_alley", gameInfo
            end
        end
        
        -- 方法3：通过远程事件识别
        if self:checkRemotes("Remotes/GrassCollect") and 
           self:checkRemotes("Remotes/Upgrade") then
            Logger.log("通过远程事件识别为: grass_cutting")
            return "grass_cutting", gameInfo
        end
        
        if self:checkRemotes("Events/SellTrash") then
            Logger.log("通过远程事件识别为: back_alley")
            return "back_alley", gameInfo
        end
        
        Logger.log("无法识别游戏类型", "warn")
        return "unknown", gameInfo
    end,
    
    -- 检查远程事件是否存在
    checkRemotes = function(self, path)
        local parts = string.split(path, "/")
        local current = game
        
        for _, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then
                return false
            end
        end
        
        return true
    end
}

-- 脚本执行器
local ScriptExecutor = {
    -- 安全执行脚本
    execute = function(self, scriptContent, scriptName, gameInfo)
        if not scriptContent then
            Logger.log("脚本内容为空: " .. scriptName, "error")
            return false
        end
        
        Logger.log("正在执行脚本: " .. scriptName)
        
        -- 创建安全执行环境
        local sandbox = self:createSandbox(gameInfo)
        
        -- 安全加载函数
        local function safeLoad()
            local fn, err = loadstring(scriptContent)
            if not fn then
                error("编译错误: " .. tostring(err))
            end
            
            -- 设置沙箱环境
            setfenv(fn, sandbox)
            
            -- 执行脚本
            return fn()
        end
        
        local success, result = pcall(safeLoad)
        
        if success then
            Logger.log("脚本执行成功: " .. scriptName)
            return true
        else
            Logger.log("脚本执行失败: " .. tostring(result), "error")
            return false
        end
    end,
    
    -- 创建沙箱环境
    createSandbox = function(self, gameInfo)
        local sandbox = {
            -- 基本函数
            print = print,
            warn = warn,
            error = error,
            pcall = pcall,
            wait = wait,
            spawn = spawn,
            
            -- 类型检查
            type = type,
            typeof = typeof,
            tostring = tostring,
            tonumber = tonumber,
            
            -- 迭代器
            pairs = pairs,
            ipairs = ipairs,
            next = next,
            
            -- 游戏服务
            game = game,
            workspace = workspace,
            Players = Players,
            
            -- 脚本信息
            _SCRIPT_INFO = {
                name = gameInfo.name,
                placeId = gameInfo.placeId,
                playerCount = gameInfo.playerCount,
                timestamp = os.time()
            }
        }
        
        -- 受限的table函数
        sandbox.table = {
            insert = table.insert,
            remove = table.remove,
            concat = table.concat,
            sort = table.sort,
            find = table.find,
            unpack = table.unpack
        }
        
        -- 受限的string函数
        sandbox.string = {
            sub = string.sub,
            find = string.find,
            match = string.match,
            gsub = string.gsub,
            format = string.format,
            lower = string.lower,
            upper = string.upper,
            rep = string.rep,
            split = string.split
        }
        
        -- 受限的math函数
        sandbox.math = {
            floor = math.floor,
            ceil = math.ceil,
            random = math.random,
            max = math.max,
            min = math.min,
            abs = math.abs,
            clamp = math.clamp
        }
        
        -- 屏蔽危险函数
        local blockedFunctions = {
            "getfenv", "setfenv", "loadstring", "load", "require",
            "getreg", "getgc", "getinstances", "getnilinstances",
            "writefile", "readfile", "delfile", "listfiles",
            "hookfunction", "newcclosure", "clonefunction",
            "setclipboard", "getclipboard"
        }
        
        for _, funcName in ipairs(blockedFunctions) do
            sandbox[funcName] = function()
                error("访问被阻止的函数: " .. funcName)
            end
        end
        
        return sandbox
    end
}

-- 用户界面
local UserInterface = {
    -- 显示游戏选择菜单
    showGameMenu = function(self, gameInfo)
        local player = Players.LocalPlayer
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "WasScriptLoader"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")
        
        -- 主框架
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 280)
        frame.Position = UDim2.new(0.5, -175, 0.5, -140)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
        frame.BorderSizePixel = 2
        frame.Parent = screenGui
        
        -- 标题
        local title = Instance.new("TextLabel")
        title.Text = " 垃圾中心脚本加载器"
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.Parent = frame
        
        -- 游戏信息
        local infoFrame = Instance.new("Frame")
        infoFrame.Size = UDim2.new(1, -20, 0, 70)
        infoFrame.Position = UDim2.new(0, 10, 0, 50)
        infoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        infoFrame.Parent = frame
        
        local gameNameLabel = Instance.new("TextLabel")
        gameNameLabel.Text = "🎮 " .. gameInfo.name
        gameNameLabel.Size = UDim2.new(1, -10, 0, 30)
        gameNameLabel.Position = UDim2.new(0, 5, 0, 5)
        gameNameLabel.BackgroundTransparency = 1
        gameNameLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
        gameNameLabel.Font = Enum.Font.GothamBold
        gameNameLabel.TextSize = 14
        gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        gameNameLabel.Parent = infoFrame
        
        local gameIdLabel = Instance.new("TextLabel")
        gameIdLabel.Text = "🆔 ID: " .. gameInfo.placeId
        gameIdLabel.Size = UDim2.new(1, -10, 0, 20)
        gameIdLabel.Position = UDim2.new(0, 5, 0, 35)
        gameIdLabel.BackgroundTransparency = 1
        gameIdLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        gameIdLabel.Font = Enum.Font.Gotham
        gameIdLabel.TextSize = 12
        gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left
        gameIdLabel.Parent = infoFrame
        
        -- 脚本选项
        local scripts = {
            {"grass_cutting", "🌿 割草模拟器", Color3.fromRGB(80, 180, 100)},
            {"back_alley", "🗑️ 在后巷", Color3.fromRGB(180, 100, 80)},
            {"loader", "📦 重新加载", Color3.fromRGB(100, 100, 180)}
        }
        
        for i, scriptInfo in ipairs(scripts) do
            local button = Instance.new("TextButton")
            button.Name = scriptInfo[1]
            button.Text = scriptInfo[2]
            button.Size = UDim2.new(0.8, 0, 0, 35)
            button.Position = UDim2.new(0.1, 0, 0, 130 + (i-1)*40)
            button.BackgroundColor3 = scriptInfo[3]
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamBold
            button.TextSize = 14
            button.Parent = frame
            
            button.MouseButton1Click:Connect(function()
                screenGui:Destroy()
                self:onScriptSelected(scriptInfo[1])
            end)
        end
        
        -- 关闭按钮
        local closeButton = Instance.new("TextButton")
        closeButton.Text = "关闭"
        closeButton.Size = UDim2.new(0.3, 0, 0, 30)
        closeButton.Position = UDim2.new(0.35, 0, 0, 240)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Font = Enum.Font.Gotham
        closeButton.TextSize = 12
        closeButton.Parent = frame
        
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
    end,
    
    -- 脚本选择回调
    onScriptSelected = function(self, scriptName)
        local scriptContent = fetchScript(scriptName)
        if scriptContent then
            local gameInfo = GameDetector:getGameInfo()
            ScriptExecutor:execute(scriptContent, scriptName, gameInfo)
        else
            Logger.log("无法加载选中的脚本: " .. scriptName, "error")
        end
    end,
    
    -- 显示加载动画
    showLoading = function(self, message)
        local player = Players.LocalPlayer
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "LoadingScreen"
        screenGui.Parent = player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 100)
        frame.Position = UDim2.new(0.5, -100, 0.5, -50)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
        frame.Parent = screenGui
        
        local label = Instance.new("TextLabel")
        label.Text = message or "正在加载..."
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 10)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame
        
        local dots = Instance.new("TextLabel")
        dots.Text = "..."
        dots.Size = UDim2.new(1, 0, 0, 30)
        dots.Position = UDim2.new(0, 0, 0, 40)
        dots.BackgroundTransparency = 1
        dots.TextColor3 = Color3.fromRGB(200, 200, 255)
        dots.Font = Enum.Font.GothamBold
        dots.TextSize = 20
        dots.Parent = frame
        
        -- 动画效果
        local dotCount = 0
        game:GetService("RunService").Heartbeat:Connect(function()
            dotCount = (dotCount + 1) % 4
            dots.Text = string.rep(".", dotCount)
        end)
        
        return screenGui
    end
}

-- 主函数
local function main()
    Logger.log("=== 蛙Was脚本加载器启动 ===")
    Logger.log("版本: 3.0")
    Logger.log("GitHub: https://github.com/WasKKal")
    
    -- 显示加载动画
    local loadingUI = UserInterface:showLoading("正在检测游戏...")
    
    -- 检测游戏
    local gameType, gameInfo = GameDetector:detectGame()
    
    -- 移除加载动画
    if loadingUI then
        loadingUI:Destroy()
    end
    
    if gameType == "unknown" then
        Logger.log("游戏类型未知，显示选择菜单", "warn")
        UserInterface:showGameMenu(gameInfo)
    else
        Logger.log("自动识别为: " .. gameType)
        
        -- 获取对应脚本
        local scriptContent = fetchScript(gameType)
        if scriptContent then
            -- 执行脚本
            ScriptExecutor:execute(scriptContent, gameType, gameInfo)
        else
            Logger.log("无法获取脚本，显示选择菜单", "error")
            UserInterface:showGameMenu(gameInfo)
        end
    end
end

-- 错误处理
local function safeMain()
    local success, err = pcall(main)
    if not success then
        Logger.log("加载器启动失败: " .. tostring(err), "error")
        
        -- 显示错误信息
        local player = Players.LocalPlayer
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ErrorScreen"
        screenGui.Parent = player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 150)
        frame.Position = UDim2.new(0.5, -150, 0.5, -75)
        frame.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        frame.BorderColor3 = Color3.fromRGB(80, 60, 60)
        frame.Parent = screenGui
        
        local title = Instance.new("TextLabel")
        title.Text = "❌ 加载器错误"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
        title.TextColor3 = Color3.fromRGB(255, 200, 200)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.Parent = frame
        
        local errorMsg = Instance.new("TextLabel")
        errorMsg.Text = "错误信息:\n" .. tostring(err)
        errorMsg.Size = UDim2.new(1, -20, 0, 80)
        errorMsg.Position = UDim2.new(0, 10, 0, 40)
        errorMsg.BackgroundTransparency = 1
        errorMsg.TextColor3 = Color3.fromRGB(255, 150, 150)
        errorMsg.Font = Enum.Font.Gotham
        errorMsg.TextSize = 12
        errorMsg.TextWrapped = true
        errorMsg.TextYAlignment = Enum.TextYAlignment.Top
        errorMsg.Parent = frame
        
        local closeButton = Instance.new("TextButton")
        closeButton.Text = "关闭"
        closeButton.Size = UDim2.new(0.3, 0, 0, 25)
        closeButton.Position = UDim2.new(0.35, 0, 0, 120)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Font = Enum.Font.Gotham
        closeButton.TextSize = 12
        closeButton.Parent = frame
        
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
    end
end

-- 启动加载器
safeMain()
