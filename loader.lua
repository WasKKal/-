local PlaceId = game.PlaceId

-- 获取当前游戏名称函数
local function getGameName()
    local success, result = pcall(function()
        -- 从市场服务获取游戏信息
        local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(PlaceId)
        if gameInfo and gameInfo.Name then
            return gameInfo.Name
        end
    end)
    
    if success and result then
        return result
    else
        -- 如果获取失败，返回PlaceId
        return "ID: " .. PlaceId
    end
end

-- 未匹配时调用错误菜单函数
local function showErrorUI()
    -- 防止重复创建
    if game:GetService("CoreGui"):FindFirstChild("QWHubLoader") then
        return
    end

    -- 获取游戏名称
    local gameName = getGameName()

    -- 创建ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "QWHubLoader"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false

    -- 主背景
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 220)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "QW Hub 加载器"
    titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame

    -- 错误信息
    local errorLabel = Instance.new("TextLabel")
    errorLabel.Size = UDim2.new(1, 0, 0, 30)
    errorLabel.Position = UDim2.new(0, 0, 0, 70)
    errorLabel.BackgroundTransparency = 1
    errorLabel.Text = "加载失败 - 当前服务器不受支持"
    errorLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    errorLabel.TextScaled = true
    errorLabel.Font = Enum.Font.Gotham
    errorLabel.Parent = mainFrame

    -- 当前服务器PlaceId
    local serverInfoLabel = Instance.new("TextLabel")
    serverInfoLabel.Size = UDim2.new(1, 0, 0, 25)
    serverInfoLabel.Position = UDim2.new(0, 0, 0, 100)
    serverInfoLabel.BackgroundTransparency = 1
    serverInfoLabel.Text = "当前服务器: " .. gameName
    serverInfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    serverInfoLabel.TextScaled = true
    serverInfoLabel.Font = Enum.Font.Gotham
    serverInfoLabel.Parent = mainFrame

    -- 状态提示标签
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 135)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Visible = false
    statusLabel.Parent = mainFrame

    -- 按钮容器
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(1, -40, 0, 50)
    buttonContainer.Position = UDim2.new(0, 20, 1, -70)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = mainFrame

    -- 重新加载
    local reloadButton = Instance.new("TextButton")
    reloadButton.Size = UDim2.new(0.45, 0, 1, 0)
    reloadButton.Position = UDim2.new(0, 0, 0, 0)
    reloadButton.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
    reloadButton.Text = "重新加载"
    reloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    reloadButton.TextScaled = true
    reloadButton.Font = Enum.Font.GothamBold
    reloadButton.BorderSizePixel = 0
    reloadButton.Parent = buttonContainer

    -- 关闭
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.45, 0, 1, 0)
    closeButton.Position = UDim2.new(0.55, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
    closeButton.Text = "关闭菜单"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.BorderSizePixel = 0
    closeButton.Parent = buttonContainer

    local btnCorner1 = Instance.new("UICorner")
    btnCorner1.CornerRadius = UDim.new(0, 5)
    btnCorner1.Parent = reloadButton

    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 5)
    btnCorner2.Parent = closeButton

    -- 按钮
    reloadButton.MouseButton1Click:Connect(function()
        -- 隐藏按钮和文字
        reloadButton.Visible = false
        closeButton.Visible = false
        errorLabel.Visible = false
        serverInfoLabel.Visible = false
        
        -- 提示
        statusLabel.Visible = true
        statusLabel.Text = "重载中"
        
        -- 0.5秒后删除UI
        task.wait(0.5)
        screenGui:Destroy()
        task.wait(0.5)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/loader.lua"))()
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

-- PlaceId 检测
-- 在后巷
if PlaceId == 11257760806 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/在后巷.lua"))()
-- 割草增量模拟器
elseif PlaceId == 133086043677134 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/割草增量.lua"))()
-- 滴管增量,未混淆
elseif PlaceId == 70960300100792 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/滴管增量.lua"))()
-- +1速度滑翔翼逃生
elseif PlaceId == 115442728708640 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/滑翔翼逃生.lua"))()
-- 你更愿意
elseif PlaceId == 133379826754141 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/你更愿意,但它会发生.lua"))()
-- 造船寻宝
elseif PlaceId == 537413528 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/造船寻宝.lua"))()
-- 刀片旋转
elseif PlaceId == 79311273910901 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/刀片旋转.lua"))()
-- 终极+1大小
elseif PlaceId == 98291788885415 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/终极+1大小.lua"))()
-- 火球训练
elseif PlaceId == 129195078205390 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/火球训练.lua"))()
-- BloxFruits
elseif PlaceId == 2753915549 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/BloxFruits.lua"))()
-- 大战51区
elseif PlaceId == 155382109 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/大战51区.lua"))()
-- 动漫战斗模拟器INF
elseif PlaceId == 13024763239829 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/动漫战斗模拟器.lua"))()
-- 力量传奇
elseif PlaceId == 3623096087 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/力量传奇.lua"))()
-- Trollge多重宇宙
elseif PlaceId == 6243946064 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/Trollge多重宇宙.lua"))()
-- Doors
elseif PlaceId == 6839171747 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/Doors.lua"))()
-- 忍者传奇
elseif PlaceId == 3956818381 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/忍者传奇.lua"))()
-- 极速传奇
elseif PlaceId == 3101667897 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/极速传奇.lua"))()
-- 最坚强的战场
elseif PlaceId == 10449761463 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/最强战场.lua"))()
-- 黑暗欺骗
elseif PlaceId == 102181577519757 or PlaceId == 125591428878906 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/黑暗欺骗.lua"))()
-- 未匹配到支持服务器
else
    showErrorUI()
end

-- QW Hub用户你好,如果你想参考功能思路,请联系我,我会将部分功能与思路发送给您,感谢使用QWscript
-- MyQQcode:1763356884,QQGroupchatcode:1085475284
