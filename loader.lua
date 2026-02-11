-- ============================================
-- 智能游戏脚本加载器 v2.0
-- 自动识别游戏并加载对应脚本
-- ============================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- 配置信息
local CONFIG = {
    SCRIPT_BASE_URL = "https://raw.githubusercontent.com/YourUsername/ScriptHub/main/", -- 替换为你的脚本仓库URL
    DEBUG_MODE = true,
    CACHE_SCRIPTS = true,
    CACHE_DURATION = 300 -- 缓存时间（秒）
}

-- 本地缓存
local scriptCache = {}
local lastCacheTime = {}

-- 打印调试信息
local function log(message, level)
    if not CONFIG.DEBUG_MODE then return end
    local prefix = level == "warn" and "[⚠️] " or level == "error" and "[❌] " or "[ℹ️] "
    print(prefix .. message)
end

-- 游戏识别器
local GameIdentifier = {
    -- 已知游戏数据库（优先检查）
    knownGames = {
        [133086043677134] = "grass_cutting",  -- 垃圾中心 - 割草模拟器
        [11257760806] = "back_alley",        -- 生活在后巷模拟器
        -- 可以继续添加更多游戏...
    },
    
    -- 游戏名称关键词映射
    nameKeywords = {
        ["grass"] = "grass_cutting",
        ["割草"] = "grass_cutting",
        ["垃圾中心"] = "grass_cutting",
        ["后巷"] = "back_alley",
        ["back alley"] = "back_alley",
        ["trash"] = "back_alley",
    },
    
    -- 远程事件特征
    remoteFeatures = {
        grass_cutting = {
            "Remotes/GrassCollect",
            "Remotes/Upgrade",
            "Remotes/UpgradeTree"
        },
        back_alley = {
            "Events/SellTrash"
        }
    },
    
    -- 获取当前游戏信息
    getCurrentGameInfo = function(self)
        local gameId = game.PlaceId
        local info = {
            id = gameId,
            jobId = game.JobId,
            isPrivate = game.PrivateServerId ~= "",
            playerCount = #Players:GetPlayers()
        }
        
        -- 尝试获取游戏名称
        local success, productInfo = pcall(function()
            return MarketplaceService:GetProductInfo(gameId)
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
    
    -- 识别游戏类型
    identifyGame = function(self)
        local gameInfo = self:getCurrentGameInfo()
        local gameId = gameInfo.id
        
        log("正在识别游戏... ID: " .. gameId .. " | 名称: " .. gameInfo.name)
        
        -- 方法1: 通过已知ID识别
        if self.knownGames[gameId] then
            log("通过已知ID识别为: " .. self.knownGames[gameId])
            return self.knownGames[gameId], gameInfo
        end
        
        -- 方法2: 通过名称关键词识别
        local gameName = gameInfo.name:lower()
        for keyword, scriptType in pairs(self.nameKeywords) do
            if string.find(gameName, keyword:lower()) then
                log("通过名称关键词识别为: " .. scriptType)
                return scriptType, gameInfo
            end
        end
        
        -- 方法3: 通过远程事件特征识别
        for scriptType, remotes in pairs(self.remoteFeatures) do
            local allFound = true
            for _, remotePath in ipairs(remotes) do
                local pathParts = string.split(remotePath, "/")
                local current = game
                for _, part in ipairs(pathParts) do
                    current = current:FindFirstChild(part)
                    if not current then
                        allFound = false
                        break
                    end
                end
                if not allFound then break end
            end
            if allFound then
                log("通过远程事件特征识别为: " .. scriptType)
                return scriptType, gameInfo
            end
        end
        
        -- 方法4: 通过API获取更多信息
        local success, apiInfo = pcall(function()
            local url = "https://games.roblox.com/v1/games?placeIds=" .. gameId
            local response = HttpService:GetAsync(url, true)
            local data = HttpService:JSONDecode(response)
            return data
        end)
        
        if success and apiInfo.data and #apiInfo.data > 0 then
            local detailedInfo = apiInfo.data[1]
            gameInfo.name = detailedInfo.name
            gameInfo.description = detailedInfo.description
            log("通过API获取到游戏详情: " .. detailedInfo.name)
            
            -- 再次尝试关键词匹配
            for keyword, scriptType in pairs(self.nameKeywords) do
                if string.find(detailedInfo.name:lower(), keyword:lower()) then
                    log("通过API名称识别为: " .. scriptType)
                    return scriptType, gameInfo
                end
            end
        end
        
        log("无法识别游戏类型", "warn")
        return "unknown", gameInfo
    end
}

-- 脚本加载器
local ScriptLoader = {
    -- 从远程获取脚本
    fetchScript = function(self, scriptType)
        local cacheKey = scriptType .. "_" .. os.date("%Y%m%d%H")
        
        -- 检查缓存
        if CONFIG.CACHE_SCRIPTS and scriptCache[cacheKey] and lastCacheTime[cacheKey] then
            local timeSinceLastCache = os.time() - lastCacheTime[cacheKey]
            if timeSinceLastCache < CONFIG.CACHE_DURATION then
                log("使用缓存的脚本: " .. scriptType)
                return scriptCache[cacheKey]
            end
        end
        
        local scriptUrl = CONFIG.SCRIPT_BASE_URL .. scriptType .. ".lua"
        log("正在从远程获取脚本: " .. scriptUrl)
        
        local success, script = pcall(function()
            return HttpService:GetAsync(scriptUrl, true)
        end)
        
        if success then
            if CONFIG.CACHE_SCRIPTS then
                scriptCache[cacheKey] = script
                lastCacheTime[cacheKey] = os.time()
            end
            log("脚本获取成功")
            return script
        else
            log("脚本获取失败: " .. tostring(script), "error")
            return nil
        end
    end,
    
    -- 安全执行脚本
    executeScript = function(self, scriptContent, scriptType, gameInfo)
        if not scriptContent then
            log("脚本内容为空，无法执行", "error")
            return false
        end
        
        log("正在执行 " .. scriptType .. " 脚本...")
        
        -- 添加脚本信息到环境
        local env = {
            _GAME_INFO = gameInfo,
            _SCRIPT_TYPE = scriptType,
            _DEBUG_MODE = CONFIG.DEBUG_MODE
        }
        
        -- 创建安全的执行环境
        local function safeLoad()
            local fn, err = loadstring(scriptContent)
            if not fn then
                error("编译错误: " .. tostring(err))
            end
            
            -- 设置环境
            setfenv(fn, setmetatable(env, {__index = getfenv()}))
            
            -- 执行脚本
            return fn()
        end
        
        local success, result = pcall(safeLoad)
        
        if success then
            log("脚本执行成功: " .. scriptType)
            return true
        else
            log("脚本执行失败: " .. tostring(result), "error")
            return false
        end
    end,
    
    -- 显示游戏选择菜单
    showGameSelection = function(self, gameInfo)
        local player = Players.LocalPlayer
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GameSelector"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = player:WaitForChild("PlayerGui")
        
        -- 主框架
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 300)
        frame.Position = UDim2.new(0.5, -175, 0.5, -150)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
        frame.Parent = screenGui
        
        -- 标题
        local title = Instance.new("TextLabel")
        title.Text = "🎮 脚本选择器"
        title.Size = UDim2.new(1, 0, 0, 50)
        title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 20
        title.Parent = frame
        
        -- 游戏信息
        local infoText = Instance.new("TextLabel")
        infoText.Text = "当前游戏: " .. gameInfo.name .. "\nID: " .. gameInfo.id
        infoText.Size = UDim2.new(1, -20, 0, 60)
        infoText.Position = UDim2.new(0, 10, 0, 60)
        infoText.BackgroundTransparency = 1
        infoText.TextColor3 = Color3.fromRGB(200, 200, 255)
        infoText.Font = Enum.Font.Gotham
        infoText.TextSize = 14
        infoText.TextWrapped = true
        infoText.TextYAlignment = Enum.TextYAlignment.Top
        infoText.Parent = frame
        
        -- 脚本选项
        local scripts = {
            {"grass_cutting", "🌿 割草模拟器脚本", Color3.fromRGB(80, 180, 100)},
            {"back_alley", "🗑️ 后巷模拟器脚本", Color3.fromRGB(180, 100, 80)},
            {"custom", "🔧 自定义脚本", Color3.fromRGB(100, 100, 180)}
        }
        
        for i, scriptInfo in ipairs(scripts) do
            local button = Instance.new("TextButton")
            button.Name = scriptInfo[1]
            button.Text = scriptInfo[2]
            button.Size = UDim2.new(0.8, 0, 0, 40)
            button.Position = UDim2.new(0.1, 0, 0, 140 + (i-1)*50)
            button.BackgroundColor3 = scriptInfo[3]
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.Font = Enum.Font.GothamBold
            button.TextSize = 14
            button.Parent = frame
            
            button.MouseButton1Click:Connect(function()
                screenGui:Destroy()
                self:loadSelectedScript(scriptInfo[1], gameInfo)
            end)
        end
        
        -- 关闭按钮
        local closeButton = Instance.new("TextButton")
        closeButton.Text = "关闭"
        closeButton.Size = UDim2.new(0.3, 0, 0, 30)
        closeButton.Position = UDim2.new(0.35, 0, 0, 260)
        closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.Font = Enum.Font.Gotham
        closeButton.TextSize = 12
        closeButton.Parent = frame
        
        closeButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
        end)
    end,
    
    -- 加载选中的脚本
    loadSelectedScript = function(self, scriptType, gameInfo)
        local scriptContent = self:fetchScript(scriptType)
        if scriptContent then
            self:executeScript(scriptContent, scriptType, gameInfo)
        else
            log("无法加载脚本: " .. scriptType, "error")
        end
    end
}

-- 主函数
local function main()
    log("=== 智能脚本加载器启动 ===")
    
    -- 识别游戏
    local gameType, gameInfo = GameIdentifier:identifyGame()
    
    if gameType == "unknown" then
        log("游戏类型未知，显示选择菜单", "warn")
        ScriptLoader:showGameSelection(gameInfo)
    else
        -- 自动加载对应脚本
        ScriptLoader:loadSelectedScript(gameType, gameInfo)
    end
end

-- 启动加载器
local success, err = pcall(main)
if not success then
    warn("脚本加载器启动失败: " .. tostring(err))
end