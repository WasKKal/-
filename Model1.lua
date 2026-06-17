
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local v7 = Players.LocalPlayer
local screenGui = v7.PlayerGui:FindFirstChild("DeltaUI_Core")
if not screenGui then
    warn("[Patch] DeltaUI not found")
    return
end

local main = nil
for _, child in pairs(screenGui:GetChildren()) do
    if child:IsA("Frame") and child.Size == UDim2.new(1, 0, 1, 0) then
        main = child
        break
    end
end
if not main then return end

local rightToggleBar = nil
local wrapperFrame = nil
local statsRow = nil
local contentFrame = nil

for _, child in pairs(main:GetChildren()) do
    if child:IsA("TextButton") and child.Size.Y.Offset > 100 and child.ZIndex == 100 then
        rightToggleBar = child
    end
    if child:IsA("Frame") and child.ClipsDescendants and child.BackgroundTransparency == 1 then
        if child.Size == UDim2.new(1, -56, 1, -86) or child.Size == UDim2.new(0, 0, 1, -86) then
            wrapperFrame = child
        end
    end
    if child:IsA("Frame") and child.Size.Y.Offset == 26 and child.BackgroundTransparency == 1 then
        statsRow = child
    end
end

if wrapperFrame then
    for _, child in pairs(wrapperFrame:GetChildren()) do
        if child:IsA("Frame") and child.BackgroundTransparency < 1 and child.ZIndex == 2 then
            contentFrame = child
            break
        end
    end
end

if _G.__DeltaUI_statsConn then
    _G.__DeltaUI_statsConn:Disconnect()
end
_G.__DeltaUI_statsConn = RunService.Heartbeat:Connect(function()
    local perf = Stats:FindFirstChild("PerformanceStats")
    local ping = 0
    if perf and perf:FindFirstChild("Ping") then
        local ok, val = pcall(function() return math.floor(perf.Ping:GetValue()) end)
        if ok then ping = val end
    end
    local fps = 0
    local ok2, val2 = pcall(function() return math.floor(workspace:GetRealPhysicsFPS()) end)
    if ok2 then fps = val2 end
    local timeStr = os.date("%I:%M %p")

    if statsRow then
        for _, pill in pairs(statsRow:GetDescendants()) do
            if pill:IsA("TextLabel") then
                if pill.Name == "pingLabel" or pill.Text:match("%d+ ms$") then
                    pill.Text = tostring(ping) .. " ms"
                elseif pill.Name == "fpsLabel" or pill.Text:match("%d+ FPS$") then
                    pill.Text = tostring(fps) .. " FPS"
                elseif pill.Name == "timeLabel" then
                    pill.Text = timeStr
                end
            end
        end
    end
end)

if contentFrame then
    for _, page in pairs(contentFrame:GetChildren()) do
        if page:IsA("Frame") or page:IsA("ScrollingFrame") then
            for _, scroll in pairs(page:GetChildren()) do
                if scroll:IsA("ScrollingFrame") then
                    scroll.ClipsDescendants = true
                    if scroll.Position.Y.Offset < 52 then
                        scroll.Position = UDim2.new(scroll.Position.X.Scale, scroll.Position.X.Offset, 0, 52)
                        scroll.Size = UDim2.new(scroll.Size.X.Scale, scroll.Size.X.Offset, 1, -64)
                    end
                end
            end
        end
    end
end

if rightToggleBar and wrapperFrame and statsRow then
    if _G.__DeltaUI_toggleConn then
        _G.__DeltaUI_toggleConn:Disconnect()
    end

    local isCollapsed = false
    _G.__DeltaUI_toggleConn = rightToggleBar.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        if isCollapsed then
            TweenService:Create(wrapperFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, -86)}):Play()
            TweenService:Create(rightToggleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -2, 0, 78), Size = UDim2.new(0, 28, 1, -90)}):Play()
            for _, pill in pairs(statsRow:GetDescendants()) do
                if pill:IsA("Frame") and pill.BackgroundTransparency < 1 then
                    TweenService:Create(pill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    for _, lbl in pairs(pill:GetChildren()) do
                        if lbl:IsA("TextLabel") then
                            TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                        elseif lbl:IsA("ImageLabel") then
                            TweenService:Create(lbl, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                        end
                    end
                end
            end
        else
            TweenService:Create(wrapperFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -56, 1, -86)}):Play()
            TweenService:Create(rightToggleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -9, 0, 78), Size = UDim2.new(0, 36, 1, -90)}):Play()
            for _, pill in pairs(statsRow:GetDescendants()) do
                if pill:IsA("Frame") then
                    TweenService:Create(pill, TweenInfo.new(0.3), {BackgroundTransparency = 0.15}):Play()
                    for _, lbl in pairs(pill:GetChildren()) do
                        if lbl:IsA("TextLabel") then
                            TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
                        elseif lbl:IsA("ImageLabel") then
                            TweenService:Create(lbl, TweenInfo.new(0.3), {ImageTransparency = 0}):Play()
                        end
                    end
                end
            end
        end
    end)
end

if _G.__DeltaUI_loadInstalledModules then
    loadInstalledModules = _G.__DeltaUI_loadInstalledModules
end

_G.__DeltaUI_loadInstalledModules = function()
    installedModules = {}
    ensureModelFolder()
    local files = listfiles(modelFolder) or {}
    if files then
        for _, fp in ipairs(files) do
            if fp:match("%.json$") then
                local txt = readfile(fp)
                if txt then
                    local data = HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
    ensurePatchFolder()
    local pfiles = listfiles(patchFolder) or {}
    if pfiles then
        for _, fp in ipairs(pfiles) do
            if fp:match("%.json$") then
                local txt = readfile(fp)
                if txt then
                    local data = HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
    ensureStoreFolder()
    local sfiles = listfiles(storeScriptFolder) or {}
    if sfiles then
        for _, fp in ipairs(sfiles) do
            if fp:match("%.json$") then
                local txt = readfile(fp)
                if txt then
                    local data = HttpService:JSONDecode(txt)
                    if type(data) == "table" and data.name then
                        installedModules[data.name] = data
                    end
                end
            end
        end
    end
end
loadInstalledModules = _G.__DeltaUI_loadInstalledModules

if _G.__DeltaUI_refreshCloudList then
    refreshCloudList = _G.__DeltaUI_refreshCloudList
end

_G.__DeltaUI_refreshCloudList = function(filter, manageMode)
    local placeholder = t("search_cloud_placeholder")
    if filter == placeholder then filter = "" end
    if cloudRefreshLock then
        pendingCloudRefresh = {filter = filter or "", manageMode = manageMode}
        return
    end
    cloudRefreshLock = true

    for _, child in pairs(cloudScroll:GetChildren()) do
        if not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local idx = 0
    if manageMode then
        loadInstalledModules()
        local seen = {}
        for name, item in pairs(installedModules) do
            if not seen[item.name] then
                seen[item.name] = true
                local matchesFilter = not filter or filter == "" or item.name:lower():find(filter:lower()) or (item.Desc and item.Desc:lower():find(filter:lower()))
                if not matchesFilter and item.Servers and type(item.Servers) == "table" then
                    for _, server in ipairs(item.Servers) do
                        if tostring(server):lower():find(filter:lower()) then
                            matchesFilter = true
                            break
                        end
                    end
                end
                if matchesFilter then
                    idx = idx + 1
                    local card = makeModuleCard(item, idx, true)
                    card.Parent = cloudScroll
                    card.BackgroundTransparency = 1
                    card.Size = UDim2.new(0, 180, 0, 140)
                    TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15, Size = UDim2.new(0, 180, 0, 140)}):Play()
                end
            end
        end
        if idx == 0 then
            local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("no_installed_packages"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
            emptyLabel.Parent = cloudScroll
            TweenService:Create(emptyLabel, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        end
    else
        local ok, raw = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/main/model.json")
        end)
        if not ok or not raw or raw == "" then
            AddLog("[Cloud] Failed to fetch module list: " .. tostring(raw), "error")
            cloudRefreshLock = false
            if pendingCloudRefresh then
                local req = pendingCloudRefresh
                pendingCloudRefresh = nil
                refreshCloudList(req.filter, req.manageMode)
            end
            return
        end
        local ok2, list = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not ok2 or not list or type(list) ~= "table" then
            AddLog("[Cloud] JSON parse error: " .. tostring(list), "error")
            cloudRefreshLock = false
            if pendingCloudRefresh then
                local req = pendingCloudRefresh
                pendingCloudRefresh = nil
                refreshCloudList(req.filter, req.manageMode)
            end
            return
        end
        if list.UIVersion then
            checkUiVersion(list.UIVersion)
        end
        local items = {}
        if list.modules and type(list.modules) == "table" then
            items = list.modules
        elseif list[1] then
            items = list
        else
            items = {list}
        end
        local remotePatchNames = {}
        for _, item in ipairs(items) do
            if type(item) == "table" and item.name and item.Type ~= "Model" then
                if item.Type == "Patch" then
                    remotePatchNames[item.name] = true
                    if not installedModules[item.name] then
                        ShowNotification(t("patch_available") .. ": " .. item.name, 3)
                    end
                end
                local shouldSkip = (item.Type == "Patch" and installedModules[item.name] and not manageMode)
                if not shouldSkip then
                    local matchesFilter = not filter or filter == "" or item.name:lower():find(filter:lower()) or (item.Desc and item.Desc:lower():find(filter:lower()))
                    if not matchesFilter and item.Servers and type(item.Servers) == "table" then
                        for _, server in ipairs(item.Servers) do
                            if tostring(server):lower():find(filter:lower()) then
                                matchesFilter = true
                                break
                            end
                        end
                    end
                    if matchesFilter then
                        idx = idx + 1
                        local card = makeModuleCard(item, idx, false)
                        card.Parent = cloudScroll
                        card.BackgroundTransparency = 1
                        card.Size = UDim2.new(0, 180, 0, 140)
                        TweenService:Create(card, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15, Size = UDim2.new(0, 180, 0, 140)}):Play()
                    end
                end
            end
        end
        if idx == 0 then
            local emptyLabel = create("TextLabel", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = t("no_packages_available"), TextColor3 = theme.textDim, TextSize = 14, Font = Enum.Font.SourceSansBold, ZIndex = 4})
            emptyLabel.Parent = cloudScroll
            TweenService:Create(emptyLabel, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
        end
        if cloudScroll and cloudGrid then
            task.defer(function()
                cloudScroll.CanvasSize = UDim2.new(0, 0, 0, cloudGrid.AbsoluteContentSize.Y + 16)
            end)
        end
    end
    cloudRefreshLock = false
    if pendingCloudRefresh then
        local req = pendingCloudRefresh
        pendingCloudRefresh = nil
        refreshCloudList(req.filter, req.manageMode)
    end
end
refreshCloudList = _G.__DeltaUI_refreshCloudList

if _G.__DeltaUI_switchPage then
    switchPage = _G.__DeltaUI_switchPage
end

_G.__DeltaUI_switchPage = function(pageName)
    for _, child in pairs(screenGui:GetChildren()) do
        if child:IsA("Frame") and child.ZIndex == 999 then
            child:Destroy()
        end
    end
    for _, dd in ipairs(_G.__DeltaUI_dropdowns or {}) do
        if dd.close then dd.close() end
    end
    if pageName == currentPage then return end
    currentPage = pageName
    for _, page in pairs(pages) do
        page.Visible = false
    end
    if pages[pageName] then
        pages[pageName].Visible = true
    end
    bottomBar.Visible = (pageName == "house")
    animateIndicator(navButtons[pageName])
    if pageName == "package" then
        local currentManageMode = cloudManageMode
        task.spawn(function()
            task.wait(0.3)
            if refreshCloudList then
                refreshCloudList(cloudSearchInput.Text, currentManageMode)
            end
        end)
    end
end
switchPage = _G.__DeltaUI_switchPage

if _G.__DeltaUI_removeStoreScript then
    removeStoreScript = _G.__DeltaUI_removeStoreScript
end

_G.__DeltaUI_removeStoreScript = function(name)
    ensureStoreFolder()
    local safeName = name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
    if safeName == "" then safeName = "untitled" end
    local fp = storeScriptFolder .. "/" .. safeName .. ".json"
    if isfile(fp) then
        delfile(fp)
    end
    installedModules[name] = nil
    refreshScriptList(searchInput.Text)
end
removeStoreScript = _G.__DeltaUI_removeStoreScript

if _G.__DeltaUI_addStoreScriptToGamepad then
    addStoreScriptToGamepad = _G.__DeltaUI_addStoreScriptToGamepad
end

_G.__DeltaUI_addStoreScriptToGamepad = function(item)
    ensureStoreFolder()
    local safeName = item.name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
    if safeName == "" then safeName = "untitled" end
    local meta = {
        name = item.name,
        Type = "Script",
        Desc = item.Desc,
        Url = item.Url,
        Version = item.Version,
        fromStore = true,
        Servers = item.Servers
    }
    local json = HttpService:JSONEncode(meta)
    writefile(storeScriptFolder .. "/" .. safeName .. ".json", json)
    installedModules[item.name] = meta
    refreshScriptList(searchInput.Text)
end
addStoreScriptToGamepad = _G.__DeltaUI_addStoreScriptToGamepad

if contentFrame then
    for _, page in pairs(contentFrame:GetChildren()) do
        if page.Name == "house" or page.Name == "editorPage" then
            for _, child in pairs(page:GetChildren()) do
                if child:IsA("Frame") and child.Name == "tabBar" then
                    child.Position = UDim2.new(0, 24, 0, 8)
                    child.Size = UDim2.new(1, -36, 0, 30)
                    for _, layout in pairs(child:GetChildren()) do
                        if layout:IsA("UIListLayout") then
                            layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                        end
                    end
                end
            end
        end
    end
end

if statsRow then
    for _, child in pairs(statsRow:GetChildren()) do
        if child:IsA("Frame") and child.AnchorPoint.X == 1 then
            child.Position = UDim2.new(1, -12, 0, 0)
        end
    end
end

print("[Patch] DeltaUI Layout & Stats Patch v1.0.0 loaded successfully")
