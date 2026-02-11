-- 蛙Was脚本加载器 v3.2 优化整合版
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- 配置区域
local CONFIG = {
    -- GitHub仓库配置
    GITHUB_USER = "WasKKal",
    GITHUB_REPO = "-",
    GITHUB_BRANCH = "main",
    
    -- 脚本文件映射表
    SCRIPTS = {
        loader = "loader.lua",
        back_alley = "在后巷.lua",
        grass_cutting = "割草模拟器.lua"
    },
    
    -- 缓存设置
    CACHE_ENABLED = true,
    CACHE_DURATION = 600, -- 10分钟缓存
    
    -- 调试模式
    DEBUG_MODE = true,
    
    -- 已知游戏ID映射（游戏ID → 脚本名称）
    KNOWN_GAMES = {
        [133086043677134] = "grass_cutting",  -- 割草模拟器
        [11257760806] = "back_alley",        -- 在后巷
    },
    
    -- 游戏名称关键词映射
    KEYWORDS = {
        grass_cutting = {"grass", "割草", "lawn", "mow", "草坪"},
        back_alley = {"后巷", "alley", "trash", "垃圾", "dumpster"},
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
    end,
    
    debug = function(message)
        if not CONFIG.DEBUG_MODE then return end
        local timestamp = os.date("%H:%M:%S")
        print(string.format("[%s] [🔍] %s", timestamp, message))
    end
}

-- 使用您提供的实际GitHub链接格式
local function buildGitHubUrl(filename)
    return string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s",
        CONFIG.GITHUB_USER, CONFIG.GITHUB_REPO, CONFIG.GITHUB_BRANCH, filename)
end

-- 从GitHub获取脚本
local function fetchScript(scriptName)
    local filename = CONFIG.SCRIPTS[scriptName]
    if not filename then
        Logger.log("未找到脚本配置: " .. scriptName, "error")
        return nil
    end

    local cacheKey = scriptName
    local url = buildGitHubUrl(filename)
    
    Logger.debug("尝试获取脚本: " .. scriptName)
    Logger.debug("完整URL: " .. url)

    -- 检查缓存
    if CONFIG.CACHE_ENABLED and cache[cacheKey] and cacheTimestamps[cacheKey] then
        local timeDiff = os.time() - cacheTimestamps[cacheKey]
        if timeDiff < CONFIG.CACHE_DURATION then
            Logger.log("使用缓存脚本: " .. scriptName)
            return cache[cacheKey]
        else
            Logger.debug("缓存过期: " .. scriptName)
        end
    end

    Logger.log("从GitHub下载脚本: " .. scriptName)

    local success, result = pcall(function()
        return HttpService:GetAsync(url, true)
    end)

    if success then
        if result and #result > 0 then
            -- 缓存脚本内容
            if CONFIG.CACHE_ENABLED then
                cache[cacheKey] = result
                cacheTimestamps[cacheKey] = os.time()
                Logger.debug("脚本已缓存: " .. scriptName)
            end
            Logger.log("脚本获取成功: " .. scriptName)
            return result
        else
            Logger.log("脚本内容为空: " .. scriptName, "error")
            return nil
        end
    else
        Logger.log("HTTP请求失败: " .. tostring(result), "error")
        return nil
    end
end

-- 游戏检测器
local GameDetector = {
    getGameInfo = function(self)
        local info = {
            placeId = game.PlaceId,
            jobId = game.JobId,
            isPrivate = game.PrivateServerId ~= "",
            playerCount = #Players:GetPlayers(),
        }

        local success, productInfo = pcall(function()
            return MarketplaceService:GetProductInfo(game.PlaceId)
        end)

        if success then
            info.name = productInfo.Name
            info.creator = productInfo.Creator.Name
        else
            info.name = "未知游戏"
            info.creator = "未知创作者"
        end
        
        return info
    end,

    detectGame = function(self)
        local info = self:getGameInfo()
        local pid = info.placeId
        
        Logger.log("检测游戏: " .. info.name .. " (ID: " .. pid .. ")")

        -- 步骤1：通过游戏ID精确匹配
        if CONFIG.KNOWN_GAMES[pid] then
            Logger.log("通过ID匹配到脚本: " .. CONFIG.KNOWN_GAMES[pid])
            return CONFIG.KNOWN_GAMES[pid], info
        end

        -- 步骤2：通过游戏名称关键词匹配
        local name = info.name:lower()
        for scriptName, keywords in pairs(CONFIG.KEYWORDS) do
            for _, keyword in ipairs(keywords) do
                if name:find(keyword:lower()) then
                    Logger.log("通过关键词匹配到脚本: " .. scriptName)
                    return scriptName, info
                end
            end
        end

        -- 步骤3：未知游戏
        Logger.log("未识别到游戏，显示选择菜单", "warn")
        return "unknown", info
    end
}

-- 脚本执行器（安全沙盒环境）
local ScriptExecutor = {
    execute = function(self, code, name, gameInfo)
        if not code then 
            Logger.log("脚本代码为空，无法执行", "error")
            return false 
        end

        Logger.log("正在执行脚本: " .. name)

        -- 创建安全的执行环境
        local env = {
            print = print, warn = warn, error = error,
            pcall = pcall, xpcall = xpcall,
            wait = task.wait, spawn = task.spawn,
            type = type, typeof = typeof, tostring = tostring, tonumber = tonumber,
            pairs = pairs, ipairs = ipairs, next = next,
            game = game, workspace = workspace, Players = Players,
            HttpService = HttpService, RunService = RunService,
            MarketplaceService = MarketplaceService,
            table = table, string = string, math = math,
            GAME_INFO = gameInfo
        }

        -- 禁止危险的函数
        env.getfenv = function() error("安全限制：禁止访问getfenv") end
        env.setfenv = function() error("安全限制：禁止访问setfenv") end
        env.loadstring = function() error("安全限制：禁止访问loadstring") end
        env.load = function() error("安全限制：禁止访问load") end

        -- 编译脚本
        local ok, fn = pcall(loadstring, code)
        if not ok or not fn then
            Logger.log("脚本编译失败: " .. tostring(fn), "error")
            return false
        end

        -- 设置环境
        setfenv(fn, env)

        -- 执行脚本
        local ok2, res2 = pcall(fn)
        if ok2 then
            Logger.log("脚本执行成功: " .. name)
            return true
        else
            Logger.log("脚本执行失败: " .. tostring(res2), "error")
            return false
        end
    end
}

-- 用户界面（当游戏未识别时显示）
local UserInterface = {}

-- 全局变量用于存储当前GUI
local currentGui = nil

function UserInterface:showGameMenu(gameInfo)
    Logger.log("显示游戏选择菜单")
    
    local plr = Players.LocalPlayer
    if not plr then
        Logger.log("无法获取本地玩家", "error")
        return
    end
    
    -- 如果已有GUI，先移除
    if currentGui then
        currentGui:Destroy()
        currentGui = nil
    end
    
    -- 创建界面
    local gui = Instance.new("ScreenGui")
    gui.Name = "WasScriptLoader"
    gui.ResetOnSpawn = false
    currentGui = gui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 280)
    frame.Position = UDim2.new(0.5, -175, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Parent = gui
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Text = "🐸 蛙Was脚本加载器"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    -- 游戏信息
    local infoText = Instance.new("TextLabel")
    infoText.Text = string.format("游戏: %s\nID: %d", gameInfo.name, gameInfo.placeId)
    infoText.Size = UDim2.new(0.9, 0, 0, 50)
    infoText.Position = UDim2.new(0.05, 0, 0, 50)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(200, 200, 220)
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 14
    infoText.TextWrapped = true
    infoText.Parent = frame
    
    -- 脚本按钮列表
    local btnList = {
        {"grass_cutting", "🌿 割草模拟器", Color3.fromRGB(80, 180, 100)},
        {"back_alley", "🗑️ 在后巷", Color3.fromRGB(180, 100, 80)},
        {"loader", "🔄 重新加载", Color3.fromRGB(100, 100, 180)}
    }
    
    -- 定义执行脚本并移除菜单的函数
    local function executeAndRemoveMenu(scriptName)
        Logger.log("用户选择了: " .. scriptName)
        
        -- 立即移除菜单
        if gui and gui.Parent then
            gui:Destroy()
            currentGui = nil
            Logger.log("菜单已移除")
        end
        
        -- 获取并执行脚本
        task.spawn(function()
            local code = fetchScript(scriptName)
            if code then
                ScriptExecutor:execute(code, scriptName, gameInfo)
            else
                warn("无法加载脚本: " .. scriptName)
            end
        end)
    end
    
    for i, v in ipairs(btnList) do
        local btn = Instance.new("TextButton")
        btn.Name = v[1]
        btn.Text = v[2]
        btn.Size = UDim2.new(0.8, 0, 0, 35)
        btn.Position = UDim2.new(0.1, 0, 0, 110 + (i - 1) * 40)
        btn.BackgroundColor3 = v[3]
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            executeAndRemoveMenu(v[1])
        end)
    end
    
    -- 关闭按钮
    local close = Instance.new("TextButton")
    close.Text = "❌ 关闭"
    close.Size = UDim2.new(0.3, 0, 0, 30)
    close.Position = UDim2.new(0.35, 0, 0, 240)
    close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = frame
    close.MouseButton1Click:Connect(function() 
        Logger.log("用户关闭了菜单")
        gui:Destroy()
        currentGui = nil
    end)
    
    -- 显示界面
    gui.Parent = plr:WaitForChild("PlayerGui")
    Logger.log("游戏选择菜单已显示")
end

-- 主函数
local function main()
    Logger.log("=== 蛙Was脚本加载器 v3.2 ===")
    Logger.log("开始检测游戏...")
    
    local gameType, gameInfo = GameDetector:detectGame()
    
    if gameType == "unknown" then
        -- 未知游戏：显示选择菜单
        Logger.log("游戏未识别，显示选择菜单")
        UserInterface:showGameMenu(gameInfo)
    else
        -- 已知游戏：自动加载对应脚本，不显示菜单
        Logger.log("游戏已识别，自动加载脚本: " .. gameType)
        local code = fetchScript(gameType)
        if code then
            local success = ScriptExecutor:execute(code, gameType, gameInfo)
            if not success then
                Logger.log("脚本执行失败，显示菜单", "warn")
                UserInterface:showGameMenu(gameInfo)
            end
        else
            Logger.log("无法获取脚本，显示菜单", "error")
            UserInterface:showGameMenu(gameInfo)
        end
    end
    
    Logger.log("=== 加载器运行完成 ===")
end

-- 安全启动
local ok, err = pcall(main)
if not ok then
    warn("[❌] 加载器崩溃: " .. tostring(err))
end
