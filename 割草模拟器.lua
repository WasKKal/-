-- 蛙Was脚本加载器 v4.1 精准匹配版
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- 配置区域
local CONFIG = {
    DEBUG_MODE = true,
    
    -- GitHub仓库配置
    GITHUB_USER = "WasKKal",
    GITHUB_REPO = "-",
    GITHUB_BRANCH = "main",
    
    -- 游戏ID与脚本文件映射（精确匹配）
    GAME_SCRIPTS = {
        -- 格式: [游戏ID] = "脚本文件名.lua"
        [133086043677134] = "割草模拟器.lua",  -- 割草模拟器
        [11257760806] = "在后巷.lua",        -- 在后巷
        -- 可在此处添加更多游戏
        -- [游戏ID] = "脚本文件名.lua",
    },
    
    -- 游戏名称精确匹配（避免误匹配）
    EXACT_NAME_MATCH = {
        -- 格式: ["游戏完整名称"] = "脚本文件名.lua"
        ["割草模拟器"] = "割草模拟器.lua",
        ["Grass Cutting Simulator"] = "割草模拟器.lua",
        ["在后巷"] = "在后巷.lua",
        ["Back Alley"] = "在后巷.lua",
        -- 可在此处添加更多精确名称匹配
        -- ["完整游戏名称"] = "脚本文件名.lua",
    },
    
    -- 严格的关键词匹配（包含完整单词检测）
    STRICT_KEYWORDS = {
        -- 格式: {"关键词1", "关键词2"} = "脚本文件名.lua"
        -- 割草模拟器相关（更严格的匹配）
        {"grass cutting", "割草模拟器", "lawn mowing"} = "割草模拟器.lua",
        
        -- 在后巷相关
        {"在后巷", "back alley", "trash collecting"} = "在后巷.lua",
        -- 可在此处添加更多关键词组
    }
}

-- 日志函数
local function log(message, level)
    if not CONFIG.DEBUG_MODE then return end
    local prefix = level == "warn" and "[⚠️] " or level == "error" and "[❌] " or "[ℹ️] "
    print(prefix .. message)
end

-- 构建GitHub URL
local function buildGitHubUrl(filename)
    return string.format("https://raw.githubusercontent.com/%s/%s/refs/heads/%s/%s",
        CONFIG.GITHUB_USER, CONFIG.GITHUB_REPO, CONFIG.GITHUB_BRANCH, filename)
end

-- 构建loadstring代码
local function buildLoadstringCode(filename)
    local url = buildGitHubUrl(filename)
    local loadstringCode = string.format('loadstring(game:HttpGet("%s", true))()', url)
    
    log("生成loadstring代码: " .. loadstringCode)
    return loadstringCode
end

-- 获取游戏信息
local function getGameInfo()
    local placeId = game.PlaceId
    local name = "未知游戏"
    
    local success, productInfo = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    
    if success then
        name = productInfo.Name
    end
    
    return {
        placeId = placeId,
        name = name,
        originalName = name, -- 保留原始名称
        lowerName = name:lower(), -- 小写版本用于匹配
        playerCount = #Players:GetPlayers()
    }
end

-- 检查是否包含完整单词（避免部分匹配）
local function containsWholeWord(text, word)
    local pattern = "%f[%a]" .. word:lower() .. "%f[%A]"
    return text:find(pattern) ~= nil
end

-- 精准检测并获取对应脚本
local function detectAndGetScript()
    local gameInfo = getGameInfo()
    local placeId = gameInfo.placeId
    local gameName = gameInfo.originalName
    local gameNameLower = gameInfo.lowerName
    
    log("检测游戏: 《" .. gameName .. "》 (ID: " .. placeId .. ")")
    
    -- 1. 优先通过游戏ID精确匹配（最可靠）
    if CONFIG.GAME_SCRIPTS[placeId] then
        local filename = CONFIG.GAME_SCRIPTS[placeId]
        log("✓ 通过游戏ID精确匹配到脚本: " .. filename)
        return buildLoadstringCode(filename)
    end
    
    -- 2. 通过游戏名称精确匹配
    if CONFIG.EXACT_NAME_MATCH[gameName] then
        local filename = CONFIG.EXACT_NAME_MATCH[gameName]
        log("✓ 通过游戏名称精确匹配到脚本: " .. filename)
        return buildLoadstringCode(filename)
    end
    
    -- 3. 严格的单词匹配（避免误匹配）
    for keywords, filename in pairs(CONFIG.STRICT_KEYWORDS) do
        for _, keyword in ipairs(keywords) do
            -- 检查是否包含完整的关键词
            if containsWholeWord(gameNameLower, keyword:lower()) then
                log("✓ 通过关键词 '" .. keyword .. "' 匹配到脚本: " .. filename)
                return buildLoadstringCode(filename)
            end
        end
    end
    
    -- 4. 额外检查：常见误匹配排除
    -- "Grass Incremental Simulator" 不应该匹配到割草脚本
    if gameNameLower:find("incremental") and gameNameLower:find("grass") then
        log("检测到 Grass Incremental Simulator，跳过匹配（避免误判）", "warn")
        return nil
    end
    
    -- 5. 宽泛匹配（最后手段，仅在没有更精确匹配时使用）
    -- 注意：这里要非常小心，避免误匹配
    
    -- 未匹配到任何脚本
    log("✗ 未找到匹配的脚本", "warn")
    return nil
end

-- 显示选择菜单（当未检测到对应脚本时）
local function showScriptMenu()
    log("显示脚本选择菜单")
    
    local plr = Players.LocalPlayer
    if not plr then
        log("无法获取本地玩家", "error")
        return
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ScriptLoader"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0.5, -160, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderColor3 = Color3.fromRGB(60, 60, 80)
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "请选择要运行的脚本"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    -- 当前游戏信息
    local gameInfo = getGameInfo()
    local infoText = Instance.new("TextLabel")
    infoText.Text = "当前游戏: " .. gameInfo.name
    infoText.Size = UDim2.new(1, -20, 0, 40)
    infoText.Position = UDim2.new(0, 10, 0, 45)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(200, 200, 220)
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 14
    infoText.TextWrapped = true
    infoText.Parent = frame
    
    -- 脚本按钮
    local scripts = {
        {"在后巷.lua", "🗑️ 在后巷脚本", Color3.fromRGB(180, 100, 80)},
        {"割草模拟器.lua", "🌿 割草模拟器脚本", Color3.fromRGB(80, 180, 100)},
    }
    
    for i, scriptInfo in ipairs(scripts) do
        local btn = Instance.new("TextButton")
        btn.Text = scriptInfo[2]
        btn.Size = UDim2.new(0.85, 0, 0, 35)
        btn.Position = UDim2.new(0.075, 0, 0.3 + (i-1)*0.25, 0)
        btn.BackgroundColor3 = scriptInfo[3]
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            -- 移除菜单
            gui:Destroy()
            
            -- 执行选择的脚本
            local loadstringCode = buildLoadstringCode(scriptInfo[1])
            if loadstringCode then
                log("用户选择执行脚本: " .. scriptInfo[1])
                local success, result = pcall(function()
                    return loadstring(loadstringCode)()
                end)
                
                if not success then
                    warn("脚本执行失败: " .. tostring(result))
                end
            end
        end)
    end
    
    local close = Instance.new("TextButton")
    close.Text = "关闭菜单"
    close.Size = UDim2.new(0.4, 0, 0, 30)
    close.Position = UDim2.new(0.3, 0, 0.85, 0)
    close.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = frame
    close.MouseButton1Click:Connect(function() 
        log("用户关闭了菜单")
        gui:Destroy() 
    end)
    
    gui.Parent = plr:WaitForChild("PlayerGui")
end

-- 主函数
local function main()
    log("=== 蛙Was脚本加载器 v4.1 ===")
    
    -- 检测并获取对应的loadstring代码
    local loadstringCode = detectAndGetScript()
    
    if loadstringCode then
        -- 直接执行检测到的脚本
        log("检测到匹配的脚本，正在执行...")
        local success, result = pcall(function()
            return loadstring(loadstringCode)()
        end)
        
        if success then
            log("脚本执行成功 ✓")
        else
            log("脚本执行失败: " .. tostring(result), "error")
            showScriptMenu()
        end
    else
        -- 显示选择菜单
        log("未检测到对应脚本，显示选择菜单")
        showScriptMenu()
    end
    
    log("=== 加载器完成 ===")
end

-- 安全启动
local success, err = pcall(main)
if not success then
    warn("[❌] 加载器错误: " .. tostring(err))
end
