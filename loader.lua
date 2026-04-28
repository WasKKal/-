local PlaceId = game.PlaceId
local LOADER_KEY = "Trash_LOADER_" .. PlaceId
local SCRIPT_KEY = "Trash_SCRIPT_" .. PlaceId

if getgenv()[LOADER_KEY] then return end
getgenv()[LOADER_KEY] = true
if getgenv()[SCRIPT_KEY] then return end
getgenv()[SCRIPT_KEY] = true

local MarketplaceService = game:GetService("MarketplaceService")

local GAME_NAMES = {
    [11257760806] = "在后巷",
    [133086043677134] = "割草增量",
    [70960300100792] = "滴管增量",
    [115442728708640] = "滑翔翼逃生",
    [133379826754141] = "你更愿意,但它会发生",
    [537413528] = "造船寻宝",
    [79311273910901] = "刀片旋转",
    [98291788885415] = "终极+1大小",
    [129195078205390] = "火球训练",
    [2753915549] = "BloxFruits - Sea1",
    [4442272183] = "BloxFruits - Sea2",
    [79091703265657] = "BloxFruits - Sea2",
    [7449423635] = "BloxFruits - Sea3",
    [100117331123089] = "BloxFruits - Sea3",
    [155382109] = "大战51区",
    [130247632398296] = "动漫战斗模拟器",
    [3623096087] = "力量传奇",
    [6243946064] = "Trollge多重宇宙",
    [6839171747] = "Doors",
    [3956818381] = "忍者传奇",
    [3101667897] = "极速传奇",
    [10449761463] = "最强战场",
    [102181577519757] = "黑暗欺骗-Monkey",
    [125591428878906] = "黑暗欺骗-Girl",
    [131384651617456] = "无限提升",
    [122446657157717] = "狙击竞技场 - PC_Mobile",
    [83645629621104] = "被遗弃",
    [16434298947] = "泉州军区",
    [70876832253163] = "死亡轨迹",
    [15459962483] = "圆圈增量",
    [8908228901] = "鲨鱼咬2",
    [131623223084840] = "逃离海啸",
    [124955530864032] = "狙击竞技场 - Mobile",
    [90625015569871] = "狙击竞技场 - PC",
    [74244835465756] = "SAF2",
    [12196278347] = "炼油厂2",
    [103571191458177] = "挖掘训练",
    [88933961678687] = "超高速跑者",
    [18519254033] = "跳跃对决",
    [98927955463992] = "僵尸生存竞技场",
    [85558337864610] = "木筏101天生存",
    [96645548064314] = "捕捉与驯服",
    [116139828947259] = "在启示录中生存",
    [87018676608089] = "手枪竞技场",
    [101733180974837] = "公牛之战",
    [115511501544785] = "寻找巨型鱼",
    [8343259840] = "罪恶都市",
    [126509999114328] = "森林中的99夜",
    [139802517550914] = "海上100天",
    [76265039822282] = "琥珀警报",
    [80953732024525] = "在岛上生存"
}

local GAME_SCRIPTS = {
    [11257760806] = {"在后巷", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%9C%A8%E5%90%8E%E5%B7%B7.lua"},
    [133086043677134] = {"割草增量", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%89%B2%E8%8D%89%E5%A2%9E%E9%87%8F.lua"},
    [70960300100792] = {"滴管增量", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%BB%B4%E7%AE%A1%E5%A2%9E%E9%87%8F.lua"},
    [115442728708640] = {"滑翔翼逃生", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%BB%91%E7%BF%94%E7%BF%BC%E9%80%83%E7%94%9F.lua"},
    [133379826754141] = {"你更愿意,但它会发生", "https://raw.githubusercontent.com/WasKKal/-/main/%E4%BD%A0%E6%9B%B4%E6%84%BF%E6%84%8F%2C%E4%BD%86%E5%AE%83%E4%BC%9A%E5%8F%91%E7%94%9F.lua"},
    [537413528] = {"造船寻宝", "https://raw.githubusercontent.com/WasKKal/-/main/%E9%80%A0%E8%88%B9%E5%AF%BB%E5%AE%9D.lua"},
    [79311273910901] = {"刀片旋转", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%88%80%E7%89%87%E6%97%8B%E8%BD%AC.lua"},
    [98291788885415] = {"终极+1大小", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%BB%88%E6%9E%81%2B1%E5%A4%A7%E5%B0%8F.lua"},
    [129195078205390] = {"火球训练", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%81%AB%E7%90%83%E8%AE%AD%E7%BB%83.lua"},
    [2753915549] = {"BloxFruits - Sea1", "https://raw.githubusercontent.com/WasKKal/-/main/BloxFruits.lua"},
    [4442272183] = {"BloxFruits - Sea2", "https://raw.githubusercontent.com/WasKKal/-/main/BloxFruits.lua"},
    [79091703265657] = {"BloxFruits - Sea2", "https://raw.githubusercontent.com/WasKKal/-/main/BloxFruits.lua"},
    [7449423635] = {"BloxFruits - Sea3", "https://raw.githubusercontent.com/WasKKal/-/main/BloxFruits.lua"},
    [100117331123089] = {"BloxFruits - Sea3", "https://raw.githubusercontent.com/WasKKal/-/main/BloxFruits.lua"},
    [155382109] = {"大战51区", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%A4%A7%E6%88%9851%E5%8C%BA.lua"},
    [130247632398296] = {"动漫战斗模拟器", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%8A%A8%E6%BC%AB%E6%88%98%E6%96%97%E6%A8%A1%E6%8B%9F%E5%99%A8.lua"},
    [3623096087] = {"力量传奇", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%8A%9B%E9%87%8F%E4%BC%A0%E5%A5%87.lua"},
    [6243946064] = {"Trollge多重宇宙", "https://raw.githubusercontent.com/WasKKal/-/main/Trollge%E5%A4%9A%E9%87%8D%E5%AE%87%E5%AE%99.lua"},
    [6839171747] = {"Doors", "https://raw.githubusercontent.com/WasKKal/-/main/Doors.lua"},
    [3956818381] = {"忍者传奇", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%BF%8D%E8%80%85%E4%BC%A0%E5%A5%87.lua"},
    [3101667897] = {"极速传奇", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%9E%81%E9%80%9F%E4%BC%A0%E5%A5%87.lua"},
    [10449761463] = {"最强战场", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%9C%80%E5%BC%BA%E6%88%98%E5%9C%BA.lua"},
    [102181577519757] = {"黑暗欺骗-Monkey", "https://raw.githubusercontent.com/WasKKal/-/main/%E9%BB%91%E6%9A%97%E6%AC%BA%E9%AA%97.lua"},
    [125591428878906] = {"黑暗欺骗-Girl", "https://raw.githubusercontent.com/WasKKal/-/main/%E9%BB%91%E6%9A%97%E6%AC%BA%E9%AA%97.lua"},
    [131384651617456] = {"无限提升", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%97%A0%E9%99%90%E6%8F%90%E5%8D%87.lua"},
    [122446657157717] = {"狙击竞技场 - PC_Mobile", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%8B%99%E5%87%BB%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"},
    [83645629621104] = {"被遗弃", "https://raw.githubusercontent.com/WasKKal/-/main/%E8%A2%AB%E9%81%97%E5%BC%83.lua"},
    [16434298947] = {"泉州军区", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%B3%89%E5%B7%9E%E5%86%9B%E5%8C%BA.lua"},
    [70876832253163] = {"死亡轨迹", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%AD%BB%E4%BA%A1%E8%BD%A8%E8%BF%B9.lua"},
    [15459962483] = {"圆圈增量", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%9C%86%E5%9C%88%E5%A2%9E%E9%87%8F.lua"},
    [8908228901] = {"鲨鱼咬2", "https://raw.githubusercontent.com/WasKKal/-/main/%E9%B2%A8%E9%B1%BC%E5%92%AC2.lua"},
    [131623223084840] = {"逃离海啸", "https://raw.githubusercontent.com/WasKKal/-/main/%E9%80%83%E7%A6%BB%E6%B5%B7%E5%95%B8.lua"},
    [124955530864032] = {"狙击竞技场 - Mobile", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%8B%99%E5%87%BB%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"},
    [90625015569871] = {"狙击竞技场 - PC", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%8B%99%E5%87%BB%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"},
    [74244835465756] = {"SAF2", "https://raw.githubusercontent.com/WasKKal/-/main/SAF2.lua"},
    [12196278347] = {"炼油厂2", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%82%BC%E6%B2%B9%E5%8E%822.lua"},
    [103571191458177] = {"挖掘训练", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%8C%96%E6%8E%98%E8%AE%AD%E7%BB%83.lua"},
    [88933961678687] = {"超高速跑者", "https://raw.githubusercontent.com/WasKKal/-/main/%E8%B6%85%E9%AB%98%E9%80%9F%E8%B7%91%E8%80%85.lua"},
    [18519254033] = {"跳跃对决", "https://raw.githubusercontent.com/WasKKal/-/main/%E8%B7%B3%E8%B7%83%E5%AF%B9%E5%86%B3.lua"},
    [98927955463992] = {"僵尸生存竞技场", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%83%B5%E5%B0%B8%E7%94%9F%E5%AD%98%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"},
    [85558337864610] = {"木筏101天生存", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%9C%A8%E7%AD%8F101%E5%A4%A9%E7%94%9F%E5%AD%98.lua"},
    [96645548064314] = {"捕捉与驯服", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%8D%95%E6%8D%89%E4%B8%8E%E9%A9%AF%E6%9C%8D.lua"},
    [116139828947259] = {"在启示录中生存", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%90%AF%E7%A4%BA%E5%BD%95%E7%94%9F%E5%AD%98.lua"},
    [87018676608089] = {"手枪竞技场", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%89%8B%E6%9E%AA%E7%AB%9E%E6%8A%80%E5%9C%BA.lua"},
    [101733180974837] = {"公牛之战", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%85%AC%E7%89%9B%E4%B9%8B%E6%88%98.lua"},
    [115511501544785] = {"寻找巨型鱼", "https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/%E5%AF%BB%E6%89%BE%E5%B7%A8%E5%9E%8B%E9%B1%BC.lua"},
    [8343259840] = {"罪恶都市", "https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/CrimCity.lua"},
    [126509999114328] = {"森林中的99夜", "https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/%E6%A3%AE%E6%9E%9799%E5%A4%9C.lua"},
    [139802517550914] = {"海上100天", "https://raw.githubusercontent.com/WasKKal/-/main/%E6%B5%B7%E4%B8%8A100%E5%A4%A9.lua"},
    [76265039822282] = {"琥珀警报", "https://raw.githubusercontent.com/WasKKal/-/main/%E7%90%A5%E7%8F%80%E8%AD%A6%E6%8A%A5.lua"},
    [80953732024525] = {"在岛上生存", "https://raw.githubusercontent.com/WasKKal/-/main/%E5%9C%A8%E5%B2%9B%E4%B8%8A%E7%94%9F%E5%AD%98.lua"}
}

local FOLDERS_TO_DELETE = {
    "Workspace/BloxFruitsQW", "Workspace/DarkDeceptionQW", "Workspace/SniperArenaQW", "Workspace/StrengthLegendQW",
    "Workspace/ToughestBattlefieldQW", "Workspace/UnlimitedBoostQW", "Workspace/ForsakenQW", "Workspace/QW_QuanZhou",
    "Workspace/QuanZhouQW", "Workspace/GunArenaQW", "Workspace/QW_DeadRails", "Workspace/WindUI/BloxFruitsQW",
    "Workspace/WindUI/DarkDeceptionQW", "Workspace/WindUI/SniperArenaQW", "Workspace/WindUI/StrengthLegendQW",
    "Workspace/WindUI/ToughestBattlefieldQW", "Workspace/WindUI/UnlimitedBoostQW", "Workspace/WindUI/UnlimitedBoxing",
    "Workspace/WindUI/ForsakenQW", "Workspace/WindUI/QW_QuanZhou", "Workspace/WindUI/QuanZhouQW", "Workspace/WindUI/GunArenaQW",
    "Workspace/WindUI/QW_DeadRails", "Workspace/QWCircleInfinite", "Workspace/WindUI/QWCircleInfinite", "Workspace/QWSharkBite2",
    "Workspace/WindUI/QWSharkBite2", "Workspace/QWFireballTrain", "Workspace/WindUI/QWFireballTrain", "Workspace/QW_Abandoned",
    "Workspace/WindUI/QW_Abandoned"
}

local function copyToClipboard(text)
    pcall(function()
        if syn and syn.write_clipboard then
            syn.write_clipboard(text)
        elseif setclipboard then
            setclipboard(text)
        end
    end)
end

local function deleteFolder(folderPath)
    pcall(function()
        local obj = game:GetService("Workspace"):FindFirstChild(folderPath:match("Workspace/(.*)"), true)
        if obj then obj:Destroy() end
        if type(delfolder) == "function" then
            delfolder(folderPath)
        elseif syn and syn.io and type(syn.io.remove) == "function" then
            syn.io.remove(folderPath)
        end
    end)
end

local function lerpColor(c1, c2, t)
    return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t)
end

local function getGameIcon(placeId)
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    if success and info and info.IconImageAssetId then
        return "rbxassetid://" .. tostring(info.IconImageAssetId)
    end
    return ""
end

local function createSimpleTopUI()
    pcall(function()
        if game.CoreGui:FindFirstChild("Trash_SimpleTopUI") then
            game.CoreGui.Trash_SimpleTopUI:Destroy()
        end
    end)

    local gui = Instance.new("ScreenGui")
    gui.Name = "Trash_SimpleTopUI"
    gui.Parent = game.CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(1, -210, 0, 5)
    frame.BackgroundTransparency = 0.1
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 22)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "脚本是否已加载"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local tip = Instance.new("TextLabel")
    tip.Size = UDim2.new(1, -10, 0, 16)
    tip.Position = UDim2.new(0, 5, 0, 20)
    tip.BackgroundTransparency = 1
    tip.Text = "若已加载 请忽略此弹窗(8)"
    tip.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    tip.TextSize = 11
    tip.Font = Enum.Font.Gotham
    tip.TextXAlignment = Enum.TextXAlignment.Left
    tip.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 22)
    btn.Position = UDim2.new(1, -75, 0, 9)
    btn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    btn.Text = "加载"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        pcall(function() if gui then gui:Destroy() end end)
        local scriptData = GAME_SCRIPTS[PlaceId]
        if scriptData and scriptData[2] then
            local url = scriptData[2]
            local success, result = pcall(function()
                local content = game:HttpGet(url)
                if not content or content == "" then
                    error("脚本内容为空")
                end
                return loadstring(content)
            end)
            if success and result then
                pcall(result)
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trash 加载错误",
                    Text = "脚本获取失败: " .. tostring(result),
                    Duration = 3
                })
            end
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Trash",
                Text = "当前游戏暂未适配",
                Duration = 2
            })
        end
    end)

    task.spawn(function()
        local remaining = 8
        while remaining > 0 and gui and gui.Parent do
            tip.Text = "若已加载 请忽略此弹窗(" .. remaining .. ")"
            task.wait(1)
            remaining = remaining - 1
        end
        pcall(function() if gui then gui:Destroy() end end)
    end)
end

local function createManualSearchUI()
    if game.CoreGui:FindFirstChild("TrashManualSearchUI") then
        game.CoreGui.TrashManualSearchUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "TrashManualSearchUI"
    gui.Parent = game.CoreGui
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 99999
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 340)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -170)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "这是一个AiUi by DeepSeek"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 4)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        local ts = game:GetService("TweenService")
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        ts:Create(mainFrame, ti, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        task.wait(0.3)
        gui:Destroy()
    end)
    
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(frameStart.X.Scale, frameStart.X.Offset + delta.X, frameStart.Y.Scale, frameStart.Y.Offset + delta.Y)
        end
    end)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 24)
    infoLabel.Position = UDim2.new(0, 10, 0, 44)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "输入游戏名称（支持模糊搜索）："
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 12
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = mainFrame
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -70, 0, 30)
    searchBox.Position = UDim2.new(0, 10, 0, 72)
    searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    searchBox.Text = ""
    searchBox.PlaceholderText = "例如：BloxFruits / 狙击竞技场"
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 12
    searchBox.Font = Enum.Font.Gotham
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = mainFrame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 6)
    searchCorner.Parent = searchBox
    
    local searchBtn = Instance.new("TextButton")
    searchBtn.Size = UDim2.new(0, 50, 0, 30)
    searchBtn.Position = UDim2.new(1, -60, 0, 72)
    searchBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    searchBtn.Text = "搜索"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextSize = 12
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = searchBtn
    
    local resultFrame = Instance.new("Frame")
    resultFrame.Size = UDim2.new(1, -20, 0, 170)
    resultFrame.Position = UDim2.new(0, 10, 0, 115)
    resultFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    resultFrame.BackgroundTransparency = 0.5
    resultFrame.BorderSizePixel = 0
    resultFrame.Parent = mainFrame
    
    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 8)
    resultCorner.Parent = resultFrame
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.BorderSizePixel = 0
    scrollingFrame.ScrollBarThickness = 6
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingFrame.Parent = resultFrame
    scrollingFrame.Active = true  -- 确保可以滚动和点击
    
    local resultList = Instance.new("UIListLayout")
    resultList.Parent = scrollingFrame
    resultList.SortOrder = Enum.SortOrder.LayoutOrder
    resultList.Padding = UDim.new(0, 4)
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 295)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextXAlignment = Enum.TextXAlignment.Center
    statusLabel.Parent = mainFrame
    
    local function clearResults()
        for _, child in ipairs(scrollingFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function loadScriptFromUrl(url, scriptName, searchGui)
        statusLabel.Text = "正在加载 " .. scriptName .. " ..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        local success, err = pcall(function()
            local content = game:HttpGet(url, 5)
            if not content or content == "" then error("脚本内容为空") end
            local func = loadstring(content)
            if not func then error("loadstring 失败，语法错误") end
            local execOk, execMsg = pcall(func)
            if not execOk then error("脚本执行错误: " .. tostring(execMsg)) end
        end)
        
        if success then
            statusLabel.Text = "加载成功！"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trash 手动加载",
                    Text = scriptName .. " 已成功执行",
                    Duration = 3
                })
            end)
            task.wait(0.5)
            if searchGui then searchGui:Destroy() end
            createSimpleTopUI()
        else
            statusLabel.Text = "失败: " .. tostring(err):sub(1, 60)
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    local function updateResults()
        local query = searchBox.Text:lower()
        clearResults()
        
        if query == "" then
            statusLabel.Text = ""
            return
        end
        
        local matches = {}
        for placeId, data in pairs(GAME_SCRIPTS) do
            local gameName = data[1]:lower()
            if gameName:find(query, 1, true) or query:find(gameName, 1, true) then
                table.insert(matches, {placeId = placeId, name = data[1], url = data[2]})
            end
        end
        
        if #matches == 0 then
            statusLabel.Text = "未找到匹配的游戏，请尝试其他关键词"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        statusLabel.Text = "找到 " .. #matches .. " 个结果，点击加载"
        statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        for _, match in ipairs(matches) do
            local resultItem = Instance.new("TextButton")  -- 改为TextButton，更容易点击
            resultItem.Size = UDim2.new(1, -10, 0, 36)
            resultItem.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            resultItem.Text = ""
            resultItem.AutoButtonColor = false
            resultItem.Parent = scrollingFrame
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 6)
            itemCorner.Parent = resultItem
            
            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.Position = UDim2.new(0, 4, 0.5, -14)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://0"
            icon.Parent = resultItem
            
            local iconCorner = Instance.new("UICorner")
            iconCorner.CornerRadius = UDim.new(0, 6)
            iconCorner.Parent = icon
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -40, 1, 0)
            nameLabel.Position = UDim2.new(0, 40, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = match.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = resultItem
            
            resultItem.MouseButton1Click:Connect(function()
                loadScriptFromUrl(match.url, match.name, gui)
            end)
            
            resultItem.MouseEnter:Connect(function()
                resultItem.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            end)
            
            resultItem.MouseLeave:Connect(function()
                resultItem.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end)
            
            task.spawn(function()
                local iconUrl = getGameIcon(match.placeId)
                if iconUrl ~= "" then
                    icon.Image = iconUrl
                end
            end)
        end
    end
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(updateResults)
    searchBtn.MouseButton1Click:Connect(updateResults)
    
    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    task.wait()
    ts:Create(mainFrame, ti, {Size = UDim2.new(0, 420, 0, 340), Position = UDim2.new(0.5, -210, 0.5, -170)}):Play()
end

local LoadingAnimation = {}
LoadingAnimation.__index = LoadingAnimation

function LoadingAnimation.new()
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("TrashLoadingScreen")
        if old then old:Destroy() end
    end)

    local self = setmetatable({}, LoadingAnimation)
    local lighting = game:GetService("Lighting")
    self.originalBrightness = lighting.Brightness
    self.originalAmbient = lighting.Ambient
    self.originalOutdoorAmbient = lighting.OutdoorAmbient

    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "TrashLoadingScreen"
    self.gui.Parent = game:GetService("CoreGui")
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.DisplayOrder = 999999
    self.gui.ResetOnSpawn = false
    self.gui.IgnoreGuiInset = true

    self.triggered30 = false
    self.triggered90 = false
    self.triggered91 = false
    self.colorCycleActive = false
    self.colorCycleTween = nil
    self.heartbeatConn = nil
    self.rainbowBars = nil
    self.isTimeout = false
    self.startTime = tick()

    self:_createUI()
    self:_darkenScreen()
    self:_createRainbowEffect()
    self:_createColorBackground()
    self:_checkTimeout()

    return self
end

function LoadingAnimation:_checkTimeout()
    task.spawn(function()
        while self.gui and self.gui.Parent and not self.triggered30 do
            task.wait(0.1)
            if tick() - self.startTime >= 5 and not self.triggered30 then
                self.isTimeout = true
                if self.title then
                    self.title.TextColor3 = Color3.fromRGB(255, 0, 0)
                    task.wait(0.5)
                    self.title.Text = "已超时,点此跳过"
                    self.title.MouseButton1Click:Connect(function()
                        self:fadeOutAndDestroy()
                    end)
                end
                break
            end
        end
    end)
end

function LoadingAnimation:_createUI()
    self.bg = Instance.new("Frame")
    self.bg.Name = "bg"
    self.bg.Size = UDim2.new(1, 0, 1, 0)
    self.bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.bg.BackgroundTransparency = 0.3
    self.bg.BorderSizePixel = 0
    self.bg.Parent = self.gui

    local container = Instance.new("Frame")
    container.Name = "centerContainer"
    container.Size = UDim2.new(0, 500, 0, 260)
    container.Position = UDim2.new(0.5, -250, 0.5, -130)
    container.BackgroundTransparency = 1
    container.Parent = self.gui

    self.title = Instance.new("TextLabel")
    self.title.Name = "titleLabel"
    self.title.Size = UDim2.new(1, 0, 0, 60)
    self.title.Position = UDim2.new(0, 0, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Text = "TrashHub"
    self.title.TextColor3 = Color3.fromRGB(255, 200, 100)
    self.title.TextStrokeTransparency = 0
    self.title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.title.Font = Enum.Font.GothamBold
    self.title.TextSize = 48
    self.title.TextXAlignment = Enum.TextXAlignment.Center
    self.title.TextYAlignment = Enum.TextYAlignment.Center
    self.title.Parent = container

    self.status = Instance.new("TextLabel")
    self.status.Name = "statusLabel"
    self.status.Size = UDim2.new(1, 0, 0, 30)
    self.status.Position = UDim2.new(0, 0, 0, 65)
    self.status.BackgroundTransparency = 1
    self.status.Text = "正在初始化中…"
    self.status.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.status.TextStrokeTransparency = 0.3
    self.status.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.status.Font = Enum.Font.Gotham
    self.status.TextSize = 18
    self.status.TextXAlignment = Enum.TextXAlignment.Center
    self.status.Parent = container

    self.filesLabel = Instance.new("TextLabel")
    self.filesLabel.Name = "filesLabel"
    self.filesLabel.Size = UDim2.new(1, -20, 0, 18)
    self.filesLabel.Position = UDim2.new(0, 10, 0, 100)
    self.filesLabel.BackgroundTransparency = 1
    self.filesLabel.Text = "正在删除文件:"
    self.filesLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    self.filesLabel.TextStrokeTransparency = 0.6
    self.filesLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.filesLabel.Font = Enum.Font.Gotham
    self.filesLabel.TextSize = 13
    self.filesLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.filesLabel.Parent = container

    self.currentFile = Instance.new("TextLabel")
    self.currentFile.Name = "currentFileLabel"
    self.currentFile.Size = UDim2.new(1, -20, 0, 18)
    self.currentFile.Position = UDim2.new(0, 10, 0, 118)
    self.currentFile.BackgroundTransparency = 1
    self.currentFile.Text = ""
    self.currentFile.TextColor3 = Color3.fromRGB(255, 200, 100)
    self.currentFile.TextStrokeTransparency = 0.5
    self.currentFile.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.currentFile.Font = Enum.Font.Gotham
    self.currentFile.TextSize = 13
    self.currentFile.TextXAlignment = Enum.TextXAlignment.Center
    self.currentFile.Parent = container

    self.downloadInfo = Instance.new("TextLabel")
    self.downloadInfo.Name = "downloadInfoLabel"
    self.downloadInfo.Size = UDim2.new(1, -20, 0, 18)
    self.downloadInfo.Position = UDim2.new(0, 10, 0, 100)
    self.downloadInfo.BackgroundTransparency = 1
    self.downloadInfo.Text = ""
    self.downloadInfo.TextColor3 = Color3.fromRGB(255, 200, 100)
    self.downloadInfo.TextStrokeTransparency = 0.5
    self.downloadInfo.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.downloadInfo.Font = Enum.Font.Gotham
    self.downloadInfo.TextSize = 13
    self.downloadInfo.TextXAlignment = Enum.TextXAlignment.Center
    self.downloadInfo.Visible = false
    self.downloadInfo.Parent = container

    local progressBg = Instance.new("Frame")
    progressBg.Name = "progressBg"
    progressBg.Size = UDim2.new(1, -40, 0, 20)
    progressBg.Position = UDim2.new(0, 20, 0, 145)
    progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 10)
    bgCorner.Parent = progressBg
    self.progressBg = progressBg

    self.progressFill = Instance.new("Frame")
    self.progressFill.Name = "progressFill"
    self.progressFill.Size = UDim2.new(0, 0, 1, 0)
    self.progressFill.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    self.progressFill.BorderSizePixel = 0
    self.progressFill.Parent = progressBg

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = self.progressFill

    self.percent = Instance.new("TextLabel")
    self.percent.Name = "percentLabel"
    self.percent.Size = UDim2.new(0, 60, 0, 20)
    self.percent.Position = UDim2.new(0.5, -30, 0, 170)
    self.percent.BackgroundTransparency = 1
    self.percent.Text = "0%"
    self.percent.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.percent.TextStrokeTransparency = 0.3
    self.percent.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.percent.Font = Enum.Font.GothamBold
    self.percent.TextSize = 16
    self.percent.TextXAlignment = Enum.TextXAlignment.Center
    self.percent.Parent = container
end

function LoadingAnimation:_createColorBackground()
    self.colorBackground = Instance.new("Frame")
    self.colorBackground.Name = "ColorBackground"
    self.colorBackground.Size = UDim2.new(1, 0, 1, 0)
    self.colorBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.colorBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    self.colorBackground.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    self.colorBackground.BackgroundTransparency = 1
    self.colorBackground.BorderSizePixel = 0
    self.colorBackground.ZIndex = 1
    self.colorBackground.Parent = self.gui
end

function LoadingAnimation:_createRainbowEffect()
    local effectContainer = Instance.new("Frame")
    effectContainer.Name = "RainbowEffect"
    effectContainer.Size = UDim2.new(1, 0, 1, 0)
    effectContainer.BackgroundTransparency = 1
    effectContainer.ZIndex = 2
    effectContainer.Parent = self.gui

    local barLength = 55
    local barsPerEdge = 200
    local speed = 0.8
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(128, 0, 128)
    }
    local bars = {}

    local function createBarWithAnimation(edgeIdx, i)
        local isHorizontal = (edgeIdx == 1 or edgeIdx == 3)
        local isBottom = (edgeIdx == 1)
        local isTop = (edgeIdx == 3)
        local isRight = (edgeIdx == 2)
        local isLeft = (edgeIdx == 4)

        local bar = Instance.new("Frame")
        bar.Name = string.format("Bar_%d_%d", edgeIdx, i)
        bar.BorderSizePixel = 0
        bar.ZIndex = 2
        bar.BackgroundTransparency = 1
        bar.Parent = effectContainer

        if isHorizontal then
            bar.Size = UDim2.new(1 / barsPerEdge, 0, 0, barLength)
            if isBottom then
                bar.AnchorPoint = Vector2.new(0.5, 1)
                bar.Position = UDim2.new((i - 0.5) / barsPerEdge, 0, 1, 0)
            else
                bar.AnchorPoint = Vector2.new(0.5, 0)
                bar.Position = UDim2.new((i - 0.5) / barsPerEdge, 0, 0, 0)
            end
        else
            bar.Size = UDim2.new(0, barLength, 1 / barsPerEdge, 0)
            if isRight then
                bar.AnchorPoint = Vector2.new(1, 0.5)
                bar.Position = UDim2.new(1, 0, (i - 0.5) / barsPerEdge, 0)
            else
                bar.AnchorPoint = Vector2.new(0, 0.5)
                bar.Position = UDim2.new(0, 0, (i - 0.5) / barsPerEdge, 0)
            end
        end

        local gradient = Instance.new("UIGradient")
        if edgeIdx == 1 then
            gradient.Rotation = 270
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        elseif edgeIdx == 2 then
            gradient.Rotation = 180
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        elseif edgeIdx == 3 then
            gradient.Rotation = 90
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        else
            gradient.Rotation = 0
            gradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
        end
        gradient.Parent = bar

        local t_global = edgeIdx == 1 and (i - 0.5) / (barsPerEdge * 4)
            or edgeIdx == 2 and (barsPerEdge + i - 0.5) / (barsPerEdge * 4)
            or edgeIdx == 3 and (2 * barsPerEdge + i - 0.5) / (barsPerEdge * 4)
            or (3 * barsPerEdge + i - 0.5) / (barsPerEdge * 4)

        table.insert(bars, {bar = bar, t_global = t_global, isHorizontal = isHorizontal})

        local targetSize = isHorizontal and UDim2.new(1 / barsPerEdge, 0, 0, barLength) or UDim2.new(0, barLength, 1 / barsPerEdge, 0)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        game:GetService("TweenService"):Create(bar, tweenInfo, {Size = targetSize}):Play()
        game:GetService("TweenService"):Create(bar, tweenInfo, {BackgroundTransparency = 0}):Play()
    end

    for edgeIdx = 1, 4 do
        for i = 1, barsPerEdge do
            createBarWithAnimation(edgeIdx, i)
        end
    end

    self.rainbowBars = bars
    local startTime = tick()

    self.heartbeatConn = game:GetService("RunService").Heartbeat:Connect(function()
        local elapsed = (tick() - startTime) * speed
        local offset = elapsed % 1
        for _, data in ipairs(bars) do
            local currentT = data.t_global - offset
            if currentT < 0 then currentT = currentT + 1 end
            local seg = math.floor(currentT * #colors) + 1
            local pos = (currentT * #colors) % 1
            local c1 = colors[seg]
            local c2 = colors[seg % #colors + 1]
            data.bar.BackgroundColor3 = lerpColor(c1, c2, pos)
        end
    end)
end

function LoadingAnimation:_darkenScreen()
    local lighting = game:GetService("Lighting")
    for i = 1, 30 do
        local p = i / 30
        lighting.Brightness = self.originalBrightness - (self.originalBrightness - 0.4) * p
        lighting.Ambient = Color3.new(
            self.originalAmbient.R - (self.originalAmbient.R - 0.4) * p,
            self.originalAmbient.G - (self.originalAmbient.G - 0.4) * p,
            self.originalAmbient.B - (self.originalAmbient.B - 0.4) * p
        )
        lighting.OutdoorAmbient = Color3.new(
            self.originalOutdoorAmbient.R - (self.originalOutdoorAmbient.R - 0.4) * p,
            self.originalOutdoorAmbient.G - (self.originalOutdoorAmbient.G - 0.4) * p,
            self.originalOutdoorAmbient.B - (self.originalOutdoorAmbient.B - 0.4) * p
        )
        task.wait(0.01)
    end
    lighting.Brightness = 0.4
    lighting.Ambient = Color3.new(0.4, 0.4, 0.4)
    lighting.OutdoorAmbient = Color3.new(0.4, 0.4, 0.4)
end

function LoadingAnimation:updateProgress(percent, statusText, detailText, showDeleteUI)
    if not self.gui or not self.gui.Parent then return false end
    if statusText then self.status.Text = statusText end

    local isDeleteMode = showDeleteUI == true
    if self.filesLabel then self.filesLabel.Visible = isDeleteMode end
    if self.currentFile then self.currentFile.Visible = isDeleteMode end
    if self.downloadInfo then self.downloadInfo.Visible = not isDeleteMode end

    if detailText then
        if isDeleteMode then
            if self.currentFile then self.currentFile.Text = detailText end
        else
            if self.downloadInfo then self.downloadInfo.Text = detailText end
        end
    end

    if self.progressFill and type(percent) == "number" then
        self.progressFill:TweenSize(UDim2.new(percent / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.3, true)
    end
    if self.percent then
        self.percent.Text = math.floor(percent) .. "%"
    end

    if percent >= 30 and not self.triggered30 then
        self.triggered30 = true
        if self.colorBackground then
            self.colorBackground.BackgroundTransparency = 0.9
        end
        self:_startColorCycle()
    end

    if percent >= 90 and not self.triggered90 then
        self.triggered90 = true
        self:stopColorCycle()
        if self.colorBackground then
            local ts = game:GetService("TweenService")
            ts:Create(self.colorBackground, TweenInfo.new(1, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(0, 255, 0),
                BackgroundTransparency = 1,
                Size = UDim2.new(2, 0, 2, 0)
            }):Play()
        end
    end

    if percent >= 91 and not self.triggered91 then
        self.triggered91 = true
        if self.colorCycleTween then self.colorCycleTween:Cancel() end
        if self.colorBackground then
            self.colorBackground.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            self.colorBackground.BackgroundTransparency = 0
            self.colorBackground.Size = UDim2.new(1, 0, 1, 0)

            local ts = game:GetService("TweenService")
            ts:Create(self.colorBackground, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1,
                Size = UDim2.new(2, 0, 2, 0)
            }):Play()
        end

        if self.rainbowBars then
            local ts = game:GetService("TweenService")
            for _, d in ipairs(self.rainbowBars) do
                local bar = d.bar
                if bar then
                    local tar = d.isHorizontal and UDim2.new(bar.Size.X.Scale, bar.Size.X.Offset, 0, 0) or UDim2.new(0, 0, bar.Size.Y.Scale, bar.Size.Y.Offset)
                    ts:Create(bar, TweenInfo.new(0.8), {Size = tar, BackgroundTransparency = 1}):Play()
                end
            end
        end

        if self.heartbeatConn then
            pcall(function() self.heartbeatConn:Disconnect() end)
        end
    end

    return true
end

function LoadingAnimation:_startColorCycle()
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(128, 0, 128)
    }
    local idx = 1
    local ts = game:GetService("TweenService")

    local function nextC()
        if not self.colorCycleActive then return end
        local tar = colors[idx]
        idx = idx % #colors + 1
        if self.colorBackground then
            self.colorCycleTween = ts:Create(self.colorBackground, TweenInfo.new(0.5), {BackgroundColor3 = tar})
            self.colorCycleTween.Completed:Connect(nextC)
            self.colorCycleTween:Play()
        end
    end

    self.colorCycleActive = true
    nextC()
end

function LoadingAnimation:stopColorCycle()
    self.colorCycleActive = false
    if self.colorCycleTween then
        self.colorCycleTween:Cancel()
    end
end

function LoadingAnimation:fadeOutDeleteUI()
    if not self.filesLabel or not self.currentFile then return end
    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(0.3)
    ts:Create(self.filesLabel, ti, {TextTransparency = 1}):Play()
    ts:Create(self.currentFile, ti, {TextTransparency = 1}):Play()
    task.wait(0.3)
    self.filesLabel.Visible = false
    self.currentFile.Visible = false
    self.filesLabel.TextTransparency = 0
    self.currentFile.TextTransparency = 0
end

function LoadingAnimation:setTitleWithAnimation(newTitle)
    if not self.title then return end
    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(0.4)
    ts:Create(self.title, ti, {TextTransparency = 1}):Play()
    task.wait(0.4)
    self.title.Text = newTitle
    ts:Create(self.title, ti, {TextTransparency = 0}):Play()
    task.wait(0.4)
end

function LoadingAnimation:fadeOutAndDestroy()
    if not self.gui then return end
    self:stopColorCycle()

    pcall(function()
        if self.heartbeatConn then
            self.heartbeatConn:Disconnect()
        end
    end)

    local elements = {
        self.title, self.status, self.filesLabel, self.currentFile,
        self.downloadInfo, self.percent, self.progressFill, self.progressBg,
        self.bg, self.colorBackground
    }

    for i = 1, 30 do
        local p = i / 30
        for _, e in ipairs(elements) do
            if e then
                if e == self.bg or e == self.progressBg then
                    if e:IsA("Frame") then
                        e.BackgroundTransparency = 0.3 + p * 0.7
                    end
                elseif e:IsA("TextLabel") then
                    e.TextTransparency = p
                elseif e == self.progressFill or e == self.colorBackground then
                    if e:IsA("Frame") then
                        e.BackgroundTransparency = p
                    end
                end
            end
        end
        task.wait(0.01)
    end

    local lighting = game:GetService("Lighting")
    for i = 1, 30 do
        local p = i / 30
        lighting.Brightness = 0.4 + (self.originalBrightness - 0.4) * p
        lighting.Ambient = Color3.new(
            0.4 + (self.originalAmbient.R - 0.4) * p,
            0.4 + (self.originalAmbient.G - 0.4) * p,
            0.4 + (self.originalAmbient.B - 0.4) * p
        )
        lighting.OutdoorAmbient = Color3.new(
            0.4 + (self.originalOutdoorAmbient.R - 0.4) * p,
            0.4 + (self.originalOutdoorAmbient.G - 0.4) * p,
            0.4 + (self.originalOutdoorAmbient.B - 0.4) * p
        )
        task.wait(0.01)
    end

    lighting.Brightness = self.originalBrightness
    lighting.Ambient = self.originalAmbient
    lighting.OutdoorAmbient = self.originalOutdoorAmbient

    self.gui:Destroy()
end

LoadingAnimation.destroy = LoadingAnimation.fadeOutAndDestroy

task.spawn(function()
    local loader = LoadingAnimation.new()
    loader:updateProgress(10, "正在清理旧文件…", "", true)

    for i, path in ipairs(FOLDERS_TO_DELETE) do
        loader:updateProgress(10 + (i / #FOLDERS_TO_DELETE) * 20, "清理残留文件…", path, true)
        deleteFolder(path)
        task.wait(0.05)
    end
    loader:fadeOutDeleteUI()
    
    loader:updateProgress(40, "检测游戏服务器…", GAME_NAMES[PlaceId] or "未支持的服务器", false)
    task.wait(0.5)

    local scriptData = GAME_SCRIPTS[PlaceId]
    if scriptData then
        loader:updateProgress(60, "加载脚本中…", scriptData[1], false)
        task.wait(0.5)

        local success, err = pcall(function()
            local url = scriptData[2]
            local content = game:HttpGet(url)
            if not content or content == "" then
                error("脚本内容为空")
            end
            local func = loadstring(content)
            if not func then
                error("脚本编译失败")
            end
            func()
        end)

        if success then
            loader:updateProgress(100, "加载完成！", "已注入：" .. scriptData[1], false)
        else
            loader:updateProgress(85, "执行失败", tostring(err), false)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "加载失败",
                Text = tostring(err),
                Duration = 3
            })
        end

        task.wait(0.8)
        loader:fadeOutAndDestroy()
        createSimpleTopUI()
    else
        loader:updateProgress(80, "未适配此游戏", "即将关闭", false)
        task.wait(1)
        loader:fadeOutAndDestroy()
        createManualSearchUI()
    end
end)