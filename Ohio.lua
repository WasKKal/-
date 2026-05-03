local WasUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/WasUI-For-Roblox/main/WasUI.lua", true))()

local titleTags = {
    { text = "lyy源码", backgroundColor = Color3.fromRGB(255, 80, 80), textColor = Color3.fromRGB(255, 255, 255) },
    { text = "Was", backgroundColor = Color3.fromRGB(0, 152, 211), textColor = Color3.fromRGB(255, 255, 255) }
}

local mainWindow = WasUI:CreateWindow("TrashHub-Ohio", nil, nil, nil, true, titleTags)

local tabCombat = mainWindow:AddTab("战斗")
local tabAuto = mainWindow:AddTab("自动")
local tabFind = mainWindow:AddTab("寻找")
local tabCounter = mainWindow:AddTab("反制")
local tabBypass = mainWindow:AddTab("绕过")
local tabWeapon = mainWindow:AddTab("武器")
local tabVisual = mainWindow:AddTab("视觉")
local tabMovement = mainWindow:AddTab("移动")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TS = game:GetService("TweenService")
local DB = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Devv = require(ReplicatedStorage.devv)
local Remote = require(ReplicatedStorage.devv.client.Helpers.remotes.Signal)
local Inventory = Devv.load("v3item").inventory
local guid = Devv.load("GUID")
local FireServer = Remote.FireServer
local InvokeServer = Remote.InvokeServer

getgenv().tpDistance = 5

local targetPlayers = {}
local lastAttack = 0
local avoidPosition = Vector3.new(-23.943367, 53.9272232, -40.3150673)
local avoidRadius = 100
local isBlinkActive = false
local originalPosition = nil
local blinkStartTime = 0

local function createTrace(targetPos)
    local root = LP.Character and LP.Character.PrimaryPart
    if not root then return end
    local S = root.Position + Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
    local mag = (targetPos - S).Magnitude
    local P = Instance.new("Part")
    P.Name, P.Anchored, P.CanCollide, P.CastShadow = "Trace", true, false, false
    P.Material, P.Color, P.Size = Enum.Material.Neon, Color3.fromHSV(tick() % 1, 0.8, 1), Vector3.new(0.15, 0.15, mag)
    P.CFrame = CFrame.lookAt(S, targetPos) * CFrame.new(0, 0, -mag/2)
    P.Parent = Workspace
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://5633695679"
    sound.Parent = P
    sound:Play()
    DB:AddItem(sound, 1)
    TS:Create(P, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0, 0, mag)}):Play()
    DB:AddItem(P, 1)
end

local function throw()
    if getgenv().fbsx == "Gun Kill" then
        local inv = require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)
        local gun = inv.getFromName("Raygun")
        if not gun then
            Remote.InvokeServer("attemptPurchase", "Raygun")
            task.wait(0.3)
            gun = inv.getFromName("Raygun")
        end
        if gun then
            Remote.FireServer("equip", gun.guid)
        end
        return
    end

    Remote.InvokeServer("attemptPurchase", getgenv().fbsx)
    local blade
    for _, v in pairs(Inventory.items) do
        if v.name == getgenv().fbsx then
            blade = v.guid
            break
        end
    end
    task.wait(0.1)
    Remote.FireServer("equip", blade)
    task.wait(0.1)
    local _, id = Remote.InvokeServer("throwSticky", guid(), getgenv().fbsx, blade, Vector3.zero, Vector3.zero)
    getgenv().bladeid = id
end

local initialList = {"ALL"}
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(initialList, p.Name) end
end

local playerDropdown = WasUI:CreateDropdown(tabCombat, "目标玩家", initialList, {"ALL"}, function(selected)
    targetPlayers = selected or {"ALL"}
end, true, "target_players")

WasUI:CreateDropdown(tabCombat, "击杀方式", {"Ninja Star", "Tomahawk", "Banana Peel", "Snowball", "Gun Kill"}, "Ninja Star", function(selected)
    getgenv().fbsx = selected
end, false, "kill_method")

local aurablade = false
WasUI:CreateToggle(tabCombat, false, function(state)
    aurablade = state
    if state then throw() end
end, "自动击杀", nil, "auto_kill")

WasUI:CreateToggle(tabCombat, false, function(state)
    isBlinkActive = state
    if not state then originalPosition = nil end
end, "闪现", nil, "blink")

local tpplayfb = false
WasUI:CreateToggle(tabCombat, false, function(state)
    tpplayfb = state
end, "TP玩家", nil, "tp_player")

WasUI:CreateSlider(tabCombat, "距离", 1, 20, 5, function(v) getgenv().tpDistance = v end, "tp_distance")

local autovest = false
WasUI:CreateToggle(tabCombat, false, function(state) autovest = state end, "自动护甲", nil, "autovest")
local autohealth = false
WasUI:CreateToggle(tabCombat, false, function(state) autohealth = state end, "自动回血", nil, "autohealth")
local autokz = false
WasUI:CreateToggle(tabCombat, false, function(state) autokz = state end, "自动口罩", nil, "autokz")
local callphone = false
WasUI:CreateToggle(tabCombat, false, function(state) callphone = state end, "电话骚扰", nil, "callphone")
local Auarcuff = false
WasUI:CreateToggle(tabCombat, false, function(state) Auarcuff = state end, "逮捕光环", nil, "arrest_aura")

local childrenCache = {}
local itemMap = {}
local function updateCache()
    local folder = Workspace.Game.Entities:FindFirstChild("ItemPickup")
    if not folder then return end
    childrenCache = folder:GetChildren()
    itemMap = {}
    for _, model in pairs(childrenCache) do
        for _, v in pairs(model:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local e = v:FindFirstChildOfClass("ProximityPrompt")
                if e and e.ObjectText then
                    itemMap[e.ObjectText] = {
                        part = v,
                        prompt = e
                    }
                end
            end
        end
    end
end
updateCache()
if Workspace.Game.Entities:FindFirstChild("ItemPickup") then
    Workspace.Game.Entities.ItemPickup.ChildAdded:Connect(updateCache)
    Workspace.Game.Entities.ItemPickup.ChildRemoved:Connect(updateCache)
end

local function Autoitem(itemName)
    local itemData = itemMap[itemName]
    if itemData then
        LP.Character:FindFirstChild("HumanoidRootPart").CFrame = itemData.part.CFrame
        itemData.prompt.RequiresLineOfSight = false
        itemData.prompt.HoldDuration = 0
        fireproximityprompt(itemData.prompt)
        return true
    end
    return false
end

local FromATM = false
local busy = false
local FromBank = false
local autobx = false
local autozbd = false
local zbtick = 0
local sell = false
local remls = false
local autouse = false

WasUI:CreateCategory(tabAuto, "自动功能")
WasUI:CreateToggle(tabAuto, false, function(state) FromATM = state end, "自动摧毁ATM", nil, "auto_atm")
WasUI:CreateToggle(tabAuto, false, function(state) FromBank = state end, "自动偷盗银行", nil, "auto_bank")
WasUI:CreateToggle(tabAuto, false, function(state) autobx = state end, "自动打开保险", nil, "auto_chest")
WasUI:CreateToggle(tabAuto, false, function(state) autozbd = state end, "自动珠宝店", nil, "auto_jewelry")
WasUI:CreateToggle(tabAuto, false, function(state) sell = state end, "自动售卖", nil, "auto_sell")
WasUI:CreateToggle(tabAuto, false, function(state) remls = state end, "自动移除垃圾", nil, "auto_remove")
WasUI:CreateToggle(tabAuto, false, function(state) autouse = state end, "自动使用消耗品", nil, "auto_use")

local autoxywp = false
local autoblock = false
local automoss = false
local automoney = false
local autoptbs = false
local autoxybs = false
local card = false
local FromBalloon = false

WasUI:CreateCategory(tabFind, "寻找物品")
WasUI:CreateToggle(tabFind, false, function(state) autoxywp = state end, "自动寻找稀有物品", nil, "find_rare")
WasUI:CreateToggle(tabFind, false, function(state) autoblock = state end, "自动寻找幸运方块", nil, "find_luckyblock")
WasUI:CreateToggle(tabFind, false, function(state) automoss = state end, "自动寻找礼物", nil, "find_present")
WasUI:CreateToggle(tabFind, false, function(state) automoney = state end, "自动寻找印钞机", nil, "find_printer")
WasUI:CreateToggle(tabFind, false, function(state) autoptbs = state end, "自动寻找普通宝石", nil, "find_gem")
WasUI:CreateToggle(tabFind, false, function(state) autoxybs = state end, "自动寻找稀有宝石", nil, "find_raregem")
WasUI:CreateToggle(tabFind, false, function(state) card = state end, "自动寻找红卡", nil, "find_redcard")
WasUI:CreateToggle(tabFind, false, function(state) FromBalloon = state end, "自动寻找气球", nil, "find_balloon")

WasUI:CreateCategory(tabCounter, "反制与工具")
WasUI:CreateButton(tabCounter, "重进当前服务器", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)

local fakemoney = 0
local openfake = false
WasUI:CreateTextInput(tabCounter, "弹窗提醒内容", "", function(v) getgenv().make = v end, "toast_msg")
WasUI:CreateTextInput(tabCounter, "弹窗提醒时长(秒)", "", function(v) getgenv().makes = v end, "toast_dur")
WasUI:CreateButton(tabCounter, "开启弹窗", function()
    local reqload = require(ReplicatedStorage.devv).load
    local makeToast = reqload("makeToast")
    makeToast(getgenv().make, "rainbow", tonumber(getgenv().makes) or 5)
end)

WasUI:CreateButton(tabCounter, "通话禁音", function()
    FireServer("setAirplaneMode", true)
    LP:SetAttribute("isAirplaneMode", true)
end)

WasUI:CreateButton(tabCounter, "不允许战斗中", function()
    local combatModule = require(ReplicatedStorage.devv.client.Helpers.ui.combatIndicator)
    if hookfunction then
        hookfunction(combatModule.isInCombat, function() return false end)
        hookfunction(combatModule.enterCombat, function() end)
    end
end)

WasUI:CreateButton(tabCounter, "不允许被抓取", function()
    local GrabHandler = require(ReplicatedStorage.devv.client.Handlers.GrabHandler)
    local orig = GrabHandler.CheckValid
    GrabHandler.CheckValid = function(p28, p29, p30)
        if p29 == LP then return false end
        return orig(p28, p29, p30)
    end
    local origGrab = GrabHandler.Grab
    GrabHandler.Grab = function(p54, p55)
        if p55 == LP then return end
        return origGrab(p54, p55)
    end
end)

WasUI:CreateButton(tabCounter, "清除树叶", function()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part.Name == "Leaves" and part:IsA("MeshPart") then part:Destroy() end
    end
end)

WasUI:CreateButton(tabCounter, "反坐下", function()
    local function antiSit(char)
        local hum = char:WaitForChild("Humanoid")
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:GetPropertyChangedSignal("Sit"):Connect(function()
            if hum.Sit then hum.Sit = false end
        end)
        hum.Sit = false
    end
    if LP.Character then antiSit(LP.Character) end
    LP.CharacterAdded:Connect(antiSit)
end)

local AntiDoll = false
WasUI:CreateToggle(tabCounter, false, function(state) AntiDoll = state end, "反布娃娃", nil, "anti_ragdoll")

WasUI:CreateCategory(tabBypass, "绕过功能")
WasUI:CreateTextInput(tabBypass, "伪装金钱数量", "", function(v) fakemoney = tonumber(v) end, "fake_money")
WasUI:CreateToggle(tabBypass, false, function(state)
    openfake = state
end, "开启伪装", nil, "fake_money_toggle")

WasUI:CreateSlider(tabBypass, "物品栏数量", 6, 12, 9, function(value)
    require(ReplicatedStorage.devv.client.Objects.v3item.modules.inventory).numSlots = value
end, "inv_slots")

WasUI:CreateButton(tabBypass, "解锁移动经销商", function()
    local Signal = Remote
    local Purchase = Signal.InvokeServer
    Signal.InvokeServer = function(self, ...)
        if self == "attemptPurchase" then
            return Purchase(self, select(1,...), false, select(3,...))
        elseif self == "attemptPurchaseAmmo" then
            return Purchase(self, select(1,...), false, select(3,...))
        end
        return Purchase(self, ...)
    end
    LP:SetAttribute("mobileDealer", true)
    local mobileDealer = require(ReplicatedStorage.devv.shared.Indicies.mobileDealer)
    for cat, items in pairs(mobileDealer) do
        for _, item in ipairs(items) do item.stock = 12e12 end
    end
    table.insert(mobileDealer.Gun, {itemName="Acid Gun", stock=12e12})
end)

WasUI:CreateButton(tabBypass, "解锁全皮肤", function()
    local skinsModule = require(ReplicatedStorage.devv.client.Helpers.ui.screens.CaseMenu.Skins)
    local load = require(ReplicatedStorage.devv).load
    local state = load("state")
    hookfunction(skinsModule.AttemptEquip, function(self, itemName, skinName)
        if self:IsSkinEquipped(itemName, skinName) then return end
        state.data.equippedSkins[itemName] = skinName
        load("v3item").inventory.unequipAll()
        load("v3item").inventory.skinUpdate(itemName, skinName)
        self:_setEquipped(itemName, skinName)
        return true
    end)
    local skins = load("skins")
    for skinName in pairs(skins.skinData) do
        for _, itemName in pairs(skins.compatabilities.Generic) do
            state.data.ownedSkins[itemName] = state.data.ownedSkins[itemName] or {}
            state.data.ownedSkins[itemName][skinName] = 1
        end
    end
end)

WasUI:CreateButton(tabBypass, "解锁高级表情", function()
    for _, v in pairs(LP.PlayerGui.Emotes.Frame.ScrollingFrame:GetDescendants()) do
        if v.Name == "Locked" then v.Visible = false end
    end
end)

WasUI:CreateButton(tabBypass, "绕过火&酸伤害", function()
    local fire = ReplicatedStorage.devv.remoteStorage:FindFirstChild("fireHit")
    local acid = ReplicatedStorage.devv.remoteStorage:FindFirstChild("acidHit")
    if fire then fire:Destroy() end
    if acid then acid:Destroy() end
end)

WasUI:CreateCategory(tabWeapon, "Ragebot")
local ragebot = false
local ragebotInterval = 0.1
local ragebotLastFire = 0

WasUI:CreateToggle(tabWeapon, false, function(state)
    ragebot = state
end, "开启Ragebot", nil, "ragebot_toggle")

WasUI:CreateSlider(tabWeapon, "射速 (秒)", 0.01, 1, 0.1, function(value)
    ragebotInterval = value
end, "ragebot_speed")

local function getClosestEnemy()
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local rootPos = char.HumanoidRootPart.Position
    local closest, minDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local d = (rootPos - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                    closest = p
                end
            end
        end
    end
    return closest
end

local function getGunFromInventory()
    for _, v in pairs(Inventory.items) do
        if v.type == "Gun" then
            return v.guid, v
        end
    end
    return nil
end

WasUI:CreateButton(tabWeapon, "全枪无后座", function()
    for _, p in pairs(game:GetDescendants()) do
        if p:IsA("ParticleEmitter") then p:Destroy() end
    end
    game.DescendantAdded:Connect(function(d) if d:IsA("ParticleEmitter") then d:Destroy() end end)
    local invTable = Inventory.items
    for k, v in pairs(invTable) do
        if v.type == "Gun" then v.recoilAdd = 0; v.maxRecoil = 0; v.recoilDiminishFactor = 0; v.recoilFastDiminishFactor = 0 end
    end
    local gunTemplates = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun
    for _, v in pairs(gunTemplates:GetChildren()) do
        if v:IsA("ModuleScript") then
            local t = require(v)
            t.recoilAdd = 0; t.maxRecoil = 0; t.recoilDiminishFactor = 0; t.recoilFastDiminishFactor = 0
        end
    end
end)

WasUI:CreateButton(tabWeapon, "全枪据点", function()
    local invTable = Inventory.items
    for k, v in pairs(invTable) do
        if v.type == "Gun" then v.baseSpread = 0; v.baseAimSpread = 0; v.spread = 0; v.aimSpread = 0 end
    end
    local gunTemplates = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun
    for _, v in pairs(gunTemplates:GetChildren()) do
        if v:IsA("ModuleScript") then
            local t = require(v)
            t.baseSpread = 0; t.baseAimSpread = 0
        end
    end
end)

WasUI:CreateButton(tabWeapon, "全枪射速", function()
    local invTable = Inventory.items
    for k, v in pairs(invTable) do
        if v.type == "Gun" then v.fireDebounce = 0 end
    end
    local gunTemplates = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun
    for _, v in pairs(gunTemplates:GetChildren()) do
        if v:IsA("ModuleScript") then
            require(v).fireDebounce = 0
        end
    end
end)

WasUI:CreateButton(tabWeapon, "全枪瞬击", function()
    local invTable = Inventory.items
    for k, v in pairs(invTable) do
        if v.type == "Gun" then v.speedMax = 9999; v.speedDropoff = 0; v.projectileLifetime = 9999 end
    end
    local gunTemplates = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun
    for _, v in pairs(gunTemplates:GetChildren()) do
        if v:IsA("ModuleScript") then
            local t = require(v)
            t.speedMax = 9999; t.speedDropoff = 0; t.projectileLifetime = 9999
        end
    end
end)

WasUI:CreateButton(tabWeapon, "快速换弹", function()
    local invTable = Inventory.items
    for k, v in pairs(invTable) do
        if v.type == "Gun" then v.reloadTime = 0 end
    end
    local gunTemplates = ReplicatedStorage.devv.shared.Indicies.v3items.bin.Gun
    for _, v in pairs(gunTemplates:GetChildren()) do
        if v:IsA("ModuleScript") then
            require(v).reloadTime = 0
        end
    end
end)

local playerESP = {}
local playerESPEnabled = false

local function clearPlayerESP()
    for _, v in pairs(playerESP) do
        if v.Highlight then v.Highlight:Destroy() end
        if v.Billboard then v.Billboard:Destroy() end
    end
    playerESP = {}
end

local function updatePlayerESP()
    if not playerESPEnabled then
        clearPlayerESP()
        return
    end
    local existing = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                existing[p] = true
                if not playerESP[p] then
                    local highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Adornee = p.Character
                    highlight.Parent = p.Character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 200, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Adornee = head
                    billboard.Parent = head
                    billboard.MaxDistance = 200

                    local label = Instance.new("TextLabel")
                    label.BackgroundTransparency = 1
                    label.Text = p.Name
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextStrokeTransparency = 0
                    label.TextSize = 14
                    label.Size = UDim2.fromScale(1, 1)
                    label.Parent = billboard

                    playerESP[p] = { Highlight = highlight, Billboard = billboard }
                end
            end
        end
    end
    for p, _ in pairs(playerESP) do
        if not existing[p] then
            if playerESP[p].Highlight then playerESP[p].Highlight:Destroy() end
            if playerESP[p].Billboard then playerESP[p].Billboard:Destroy() end
            playerESP[p] = nil
        end
    end
    local cam = Workspace.CurrentCamera
    if cam then
        for p, esp in pairs(playerESP) do
            if p.Character and p.Character:FindFirstChild("Head") then
                local dist = (cam.CFrame.Position - p.Character.Head.Position).Magnitude
                local scale = math.clamp(30 / (dist + 5), 0.5, 2)
                esp.Billboard.Size = UDim2.new(0, 200 * scale, 0, 30 * scale)
            end
        end
    end
end

WasUI:CreateCategory(tabVisual, "玩家绘制")
WasUI:CreateToggle(tabVisual, false, function(state)
    playerESPEnabled = state
    if not state then clearPlayerESP() end
end, "玩家绘制", nil, "player_esp")

local cfSpeed = 50
local cfLoop = nil
local lockedY = nil
local levitateEnabled = false
local flyEnabled = false

local function stopCFly()
    if cfLoop then
        cfLoop:Disconnect()
        cfLoop = nil
    end
    local char = LP.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if humanoid then humanoid.PlatformStand = false end
        if head then head.Anchored = false end
    end
end

local function startCFly()
    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local head = char:WaitForChild("Head")
    if not humanoid or not head then return end
    humanoid.PlatformStand = true
    head.Anchored = true
    if levitateEnabled then
        lockedY = head.Position.Y
    end
    if cfLoop then cfLoop:Disconnect() end
    cfLoop = RunService.Heartbeat:Connect(function(dt)
        char = LP.Character
        if not char then stopCFly(); return end
        humanoid = char:FindFirstChildOfClass("Humanoid")
        head = char:FindFirstChild("Head")
        if not humanoid or not head then stopCFly(); return end
        local moveDir = humanoid.MoveDirection
        if moveDir.Magnitude < 0.01 then return end
        local delta = cfSpeed * dt
        local headCF = head.CFrame
        local camCF = workspace.CurrentCamera.CFrame
        local camOffset = headCF:ToObjectSpace(camCF).Position
        camCF = camCF * CFrame.new(-camOffset.X, -camOffset.Y, -camOffset.Z + 1)
        local camPos = camCF.Position
        local headPos = headCF.Position
        local objVelocity = CFrame.new(camPos, Vector3.new(headPos.X, camPos.Y, headPos.Z)):VectorToObjectSpace(moveDir * delta)
        local newCF = CFrame.new(headPos) * (camCF - camPos) * CFrame.new(objVelocity)
        if levitateEnabled and lockedY then
            newCF = CFrame.new(newCF.X, lockedY, newCF.Z) * newCF.Rotation
        end
        head.CFrame = newCF
    end)
end

WasUI:CreateCategory(tabMovement, "飞行")
WasUI:CreateToggle(tabMovement, false, function(state)
    flyEnabled = state
    if state then
        startCFly()
    else
        stopCFly()
    end
end, "飞行", nil, "fly_toggle")

WasUI:CreateToggle(tabMovement, false, function(state)
    levitateEnabled = state
    if state then
        local head = LP.Character and LP.Character:FindFirstChild("Head")
        if head then lockedY = head.Position.Y end
    end
end, "平飞(禁止下降)", nil, "levitate_toggle")

WasUI:CreateSlider(tabMovement, "飞行速度", 1, 200, 50, function(value)
    cfSpeed = value
end, "fly_speed")

local lockSpeedEnabled = false
local lockSpeedValue = 16
WasUI:CreateCategory(tabMovement, "锁定速度")
WasUI:CreateToggle(tabMovement, false, function(state)
    lockSpeedEnabled = state
end, "锁定速度", nil, "lock_speed_toggle")

WasUI:CreateSlider(tabMovement, "速度值", 10, 200, 16, function(value)
    lockSpeedValue = value
end, "lock_speed_value")

local mt = getrawmetatable(game)
local oldIndex = nil
setreadonly(mt, false)
local function hookIndex(t, k)
    if t:IsA("Attachment") then
        if k == "ParticleEmitter" or k == "Flash" then
            return nil
        end
    end
    return oldIndex(t, k)
end
oldIndex = hookfunction(mt.__index, hookIndex)
setreadonly(mt, true)

TextChatService.ChatWindowConfiguration.Enabled = true
local banned = ReplicatedStorage:FindFirstChild("devv"):FindFirstChild("remoteStorage"):FindFirstChild("makeExplosion")
if banned then banned:Destroy() end

RunService.Heartbeat:Connect(function(dt)
    if aurablade or tpplayfb or isBlinkActive then
        local target, dist = nil, math.huge
        local myChar = LP.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local myRoot = myChar.HumanoidRootPart
            for _, v in pairs(Players:GetPlayers()) do
                local isTarget = (#targetPlayers == 0) or table.find(targetPlayers, "ALL") or table.find(targetPlayers, v.Name)
                if not isTarget then continue end
                if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 and not v.Character:FindFirstChildOfClass("ForceField") and not LP:IsFriendsWith(v.UserId) then
                    local targetPos = v.Character.HumanoidRootPart.Position
                    local avoidDist = (targetPos - avoidPosition).Magnitude
                    if avoidDist <= avoidRadius then continue end
                    local mag = (myRoot.Position - targetPos).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v.Character.Head
                    end
                end
            end
            if target then
                local targetPos = target.Position
                local avoidDist = (targetPos - avoidPosition).Magnitude
                local dir = (myRoot.Position - targetPos) * Vector3.new(1,0,1)
                local dirNorm = dir.Magnitude > 0 and dir.Unit or Vector3.new(1,0,0)
                local newPos = targetPos + dirNorm * getgenv().tpDistance

                if tpplayfb and avoidDist > avoidRadius then
                    myRoot.CFrame = CFrame.new(newPos)
                end

                if aurablade or isBlinkActive then
                    local currentTime = tick()
                    local attackInterval = isBlinkActive and 0 or 0.1
                    local attackDist = (myRoot.Position - targetPos).Magnitude

                    if currentTime - lastAttack >= attackInterval and (getgenv().fbsx == "Gun Kill" or attackDist <= 200) and avoidDist > avoidRadius then
                        if isBlinkActive then
                            if not originalPosition then
                                originalPosition = myRoot.Position
                                myRoot.CFrame = CFrame.new(1000, 1000, 1000)
                                blinkStartTime = currentTime
                                return
                            elseif currentTime - blinkStartTime >= math.random(1, 3) then
                                myRoot.CFrame = CFrame.new(newPos)
                                if getgenv().fbsx == "Gun Kill" then
                                    local item = Devv.load("v3item").GetEquipped(LP)
                                    if item and item.type == "Gun" then
                                        lastAttack = currentTime
                                        if item.ammoManager and item.ammoManager.ammo > 0 then
                                            local g = guid()
                                            createTrace(targetPos)
                                            FireServer("replicateProjectiles", item.guid, {{g, target.CFrame}}, item.firemode)
                                            FireServer("projectileHit", g, "player", {
                                                hitSize = target.Size,
                                                hitPart = target,
                                                pos = targetPos,
                                                hitPlayerId = Players:GetPlayerFromCharacter(target.Parent).UserId
                                            })
                                            item.ammoManager.ammo = item.ammoManager.ammo - 1
                                        else
                                            InvokeServer("attemptPurchaseAmmo", item.name)
                                            FireServer("reload", item.guid)
                                        end
                                    end
                                elseif getgenv().bladeid then
                                    lastAttack = currentTime
                                    createTrace(targetPos)
                                    InvokeServer("hitSticky", getgenv().bladeid, target, target.CFrame, target.CFrame)
                                end
                                task.wait(0.05)
                                myRoot.CFrame = CFrame.new(originalPosition)
                                originalPosition = nil
                                isBlinkActive = false
                            end
                        else
                            if getgenv().fbsx == "Gun Kill" then
                                local item = Devv.load("v3item").GetEquipped(LP)
                                if item and item.type == "Gun" then
                                    lastAttack = currentTime
                                    if item.ammoManager and item.ammoManager.ammo > 0 then
                                        local g = guid()
                                        createTrace(targetPos)
                                        FireServer("replicateProjectiles", item.guid, {{g, target.CFrame}}, item.firemode)
                                        FireServer("projectileHit", g, "player", {
                                            hitSize = target.Size,
                                            hitPart = target,
                                            pos = targetPos,
                                            hitPlayerId = Players:GetPlayerFromCharacter(target.Parent).UserId
                                        })
                                        item.ammoManager.ammo = item.ammoManager.ammo - 1
                                    else
                                        InvokeServer("attemptPurchaseAmmo", item.name)
                                        FireServer("reload", item.guid)
                                    end
                                end
                            elseif getgenv().bladeid then
                                lastAttack = currentTime
                                createTrace(targetPos)
                                InvokeServer("hitSticky", getgenv().bladeid, target, target.CFrame, target.CFrame)
                            end
                        end
                    end
                end
            end
        end
    end

    if ragebot then
        local now = tick()
        if now - ragebotLastFire >= ragebotInterval then
            ragebotLastFire = now
            local enemy = getClosestEnemy()
            if enemy and enemy.Character then
                local head = enemy.Character:FindFirstChild("Head")
                if head then
                    local gunGuid, gunData = getGunFromInventory()
                    if gunGuid then
                        local equipped = Devv.load("v3item").GetEquipped(LP)
                        if not equipped or equipped.guid ~= gunGuid then
                            FireServer("equip", gunGuid)
                            task.wait(0.05)
                        end
                        local item = Devv.load("v3item").GetEquipped(LP)
                        if item and item.type == "Gun" then
                            if item.ammoManager and item.ammoManager.ammo <= 0 then
                                InvokeServer("attemptPurchaseAmmo", item.name)
                                FireServer("reload", item.guid)
                                task.wait(0.1)
                            end
                            if item.ammoManager.ammo > 0 then
                                local g = guid()
                                pcall(function()
                                    FireServer("replicateProjectiles", gunGuid, {{g, head.CFrame}}, item.firemode)
                                    FireServer("projectileHit", g, "player", {
                                        hitSize = head.Size,
                                        hitPart = head,
                                        pos = head.Position,
                                        hitPlayerId = enemy.UserId
                                    })
                                end)
                            end
                        end
                    end
                end
            end
        end
    end

    if FromATM and not busy then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist, target = math.huge, nil
            for _, v in pairs(Workspace.ATMs:GetChildren()) do
                if v:IsA("Model") and (v:GetAttribute("health") or 0) > 0 then
                    local d = (hrp.Position - v:GetPivot().Position).Magnitude
                    if d < dist then dist, target = d, v end
                end
            end
            if target then
                busy = true
                hrp.CFrame = (target:GetPivot() + Vector3.new(0, -3, 0)) * CFrame.Angles(1.57079632679, 0, 0)
                task.spawn(function()
                    task.wait(0.2)
                    target:SetAttribute("health", 0)
                    target:SetAttribute("isDestroyed", true)
                    task.wait(1)
                    busy = false
                end)
            end
        end
    end

    if FromBank then
        local Robbery = Workspace:FindFirstChild("BankRobbery")
        if Robbery then
            local Vault = Robbery:FindFirstChild("VaultDoor")
            local VPos = Vault and (Vault:IsA("Model") and Vault:GetPivot().Position or Vault.Position)
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root and VPos and (VPos - Vector3.new(1123.70703125, 13.76093578338623, -353.52301025390625)).Magnitude < 0.5 then
                if tick() >= (getgenv().NextThrow or 0) then
                    getgenv().NextThrow = tick() + 5
                    root.CFrame = CFrame.new(1123.54749, 8.31286526, -364.052216)
                    local TNT
                    for _, v in pairs(Inventory.items) do
                        if v.name == "TNT" then TNT = v.guid break end
                    end
                    if not TNT then
                        InvokeServer("attemptPurchase", "TNT")
                    else
                        local direction = (VPos - root.Position).Unit
                        FireServer("equip", TNT)
                        FireServer("throwItem", TNT, direction, Vector3.new(1124.0853271484, 5.3128666877747, -357.68710327148))
                        FireServer("removeItem", TNT)
                    end
                end
            else
                local Cash = Robbery:FindFirstChild("BankCash")
                local Main = Cash and Cash:FindFirstChild("Main")
                local Att = Main and Main:FindFirstChild("Attachment")
                local Prompt = Att and Att:FindFirstChild("ProximityPrompt")
                if Prompt and Prompt.Enabled and root then
                    root.CFrame = CFrame.new(1110.40369, 2, -325.485962)
                    FireServer("stealBankCash")
                end
            end
        end
    end

    if autobx then
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root and tick() - (getgenv()._lastChest or 0) > 0.3 then
            getgenv()._lastChest = tick()
            local chestTypes = {"SmallChest", "LargeChest", "SmallSafe", "MediumSafe", "LargeSafe", "JewelSafe", "GoldJewelSafe"}
            for _, chestType in pairs(chestTypes) do
                local chestFolder = Workspace.Game.Entities:FindFirstChild(chestType)
                if chestFolder then
                    for _, chest in pairs(chestFolder:GetChildren()) do
                        if chest.PrimaryPart then
                            local prompt = chest:FindFirstChild("ProximityPrompt", true)
                            if prompt and prompt.Enabled then
                                root.CFrame = chest.PrimaryPart.CFrame * CFrame.new(0, 3, 0)
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end
    end

    if autozbd and tick() - zbtick >= 0.3 then
        zbtick = tick()
        local cases = Workspace:FindFirstChild("GemRobbery"):FindFirstChild("JewelryCases")
        if cases then
            for _, descendant in pairs(cases:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") and descendant.ActionText == "Steal" and descendant.Enabled then
                    descendant.HoldDuration = 0
                    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(descendant.Parent.Position)
                        fireproximityprompt(descendant)
                    end
                end
            end
        end
    end

    if autouse then
        for i, v in pairs(Inventory.items) do
            if v.type == "Consumable" and v.subtype ~= "vest" and v.subtype ~= "food" and v.name ~= "Lockpick" then
                FireServer("equip", v.guid)
                FireServer("useConsumable", v.guid)
                FireServer("removeItem", v.guid)
            end
        end
    end
    if autohealth then
        InvokeServer("attemptPurchase", "Bandage")
        for _, v in pairs(Inventory.items) do
            if v.name == "Bandage" then
                local character = LP.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health ~= 0 and humanoid.Health < humanoid.MaxHealth then
                    FireServer("equip", v.guid)
                    FireServer("useConsumable", v.guid)
                    FireServer("removeItem", v.guid)
                end
                break
            end
        end
    end
    if autovest then
        InvokeServer("attemptPurchase", "Light Vest")
        for _, v in pairs(Inventory.items) do
            if v.subtype == "vest" then
                local armor = LP:GetAttribute("armor")
                if armor == nil or armor <= 0 then
                    FireServer("equip", v.guid)
                    FireServer("useConsumable", v.guid)
                    FireServer("removeItem", v.guid)
                end
                break
            end
        end
    end
    if sell then
        for i, v in pairs(Inventory.items) do
            if (v.type == "Holdable" and v.subtype == "gem" and v.sellPrice < 5000) or (v.subtype == "valuable") or (v.type == "Gun" and v.cost < 3999 and v.name ~= "Raygun") then
                FireServer("equip", v.guid)
                FireServer("sellItem", v.guid)
            end
        end
    end
    if remls then
        for i, v in pairs(Inventory.items) do
            if (v.type == "Consumable" and v.subtype == "food" and v.name ~= "Bandage") or (v.type == "Throwable" and v.cost < 500 and v.name ~= "Ninja Star" and v.name ~= "Tomahawk") or (v.type == "Melee" and v.cost > 100) then
                FireServer("removeItem", v.guid)
            end
        end
    end
    if autokz and tick() - (getgenv().lastCheck or 0) >= 2 then
        getgenv().lastCheck = tick()
        if not LP.Character:FindFirstChild("Black Bandana") then
            local kzid = nil
            for _, v in pairs(Inventory.items) do
                if v.name == "Black Bandana" then kzid = v.guid break end
            end
            if not kzid then InvokeServer("attemptPurchase", "Black Bandana") end
            if kzid then FireServer("equip", kzid); FireServer("wearMask", kzid) end
        end
    end
    if callphone and tick() - (getgenv().lastCall or 0) >= 0.5 then
        getgenv().lastCall = tick()
        for _, p in Players:GetPlayers() do
            if p ~= LP then
                task.spawn(function()
                    local ok, id = InvokeServer("attemptCall", p.UserId)
                    if ok then FireServer("sendPhoneAction", id, "hangup") end
                end)
            end
        end
    end
    if Auarcuff then
        local Handcuffs = nil
        for _, v in pairs(Inventory.items) do
            if v.name == "Handcuffs" then Handcuffs = v.guid break end
        end
        if not Handcuffs then
            InvokeServer("attemptPurchase", "Handcuffs")
        else
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local hum = player.Character:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 and hum.Health < 5 then
                            if (root.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 30 then
                                if not require(ReplicatedStorage.devv).load("ClientReplicator").Get(player, "cuffed") then
                                    FireServer("equip", Handcuffs)
                                    FireServer("cuffPlayer", player)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if autoxywp then
        Autoitem("Blue Candy Cane"); Autoitem("Suitcase Nuke"); Autoitem("Nuke Launcher")
        Autoitem("Easter Basket"); Autoitem("Gold Cup"); Autoitem("Gold Crown")
        Autoitem("Treasure Map"); Autoitem("Spectral Scythe")
    end
    if autoblock then
        Autoitem("Green Lucky Block"); Autoitem("Orange Lucky Block"); Autoitem("Purple Lucky Block")
    end
    if automoss then
        Autoitem("Medium Present"); Autoitem("Large Present")
    end
    if automoney then Autoitem("Money Printer") end
    if autoptbs then
        Autoitem("Amethyst"); Autoitem("Sapphire"); Autoitem("Emerald"); Autoitem("Topaz"); Autoitem("Ruby")
    end
    if autoxybs then
        Autoitem("Diamond"); Autoitem("Void Gem"); Autoitem("Dark Matter Gem"); Autoitem("Rollie")
        Autoitem("Gold Crown"); Autoitem("Gold Cup"); Autoitem("Pearl Necklace")
    end
    if card then
        local hasCard = false
        for _, v in pairs(Inventory.items) do
            if v.name == "Military Armory Keycard" then hasCard = true break end
        end
        if not hasCard then Autoitem("Military Armory Keycard") end
    end
    if FromBalloon then
        for _, v in pairs(ReplicatedStorage.devv.shared.Indicies.v3items.bin.Holdable:GetChildren()) do
            if v:IsA("ModuleScript") and require(v).holdableType == "Balloon" and require(v).name ~= "Balloon" then
                Autoitem(v.Name)
            end
        end
    end

    if AntiDoll then
        if LP:GetAttribute("isRagdoll") then
            FireServer("setRagdoll", false)
            require(ReplicatedStorage.devv).load("ClientReplicator").Set(LP, "ragdolled", false)
            LP:SetAttribute("isRagdoll", false)
        end
    end

    if openfake and fakemoney then
        local moneyDisplay = require(ReplicatedStorage.devv).load("moneyDisplay")
        moneyDisplay.current = fakemoney
        moneyDisplay.tweenTo = fakemoney
        local eq = Devv.load("v3item").inventory.getEquipped()
        if eq and eq.name == "Wallet" then eq.controller:updateMoney(fakemoney) end
    end

    if lockSpeedEnabled then
        local char = LP.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = lockSpeedValue
        end
    end

    updatePlayerESP()
end)

local isVisible = true
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        isVisible = not isVisible
        mainWindow:SetVisible(isVisible)
    end
end)

WasUI:Notify({Title = "TrashHub", Content = "加载完成", Duration = 3})