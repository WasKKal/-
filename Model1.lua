local create = _G.__DeltaUI_create
local t = _G.__DeltaUI_t
local theme = _G.__DeltaUI_theme
local corner = function(radius, parent)
    local c = create("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
    c.Parent = parent
    return c
end
local stroke = function(color, thickness, parent)
    local s = create("UIStroke", {Color = color or Color3.fromRGB(60, 65, 80), Thickness = thickness or 1, Transparency = 0.4})
    s.Parent = parent
    return s
end

local screenGui = _G.__DeltaUI_screenGui
if not screenGui then
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.DisplayOrder == 999999 then
            screenGui = gui
            break
        end
    end
end
if not screenGui then
    warn("[Patch] screenGui not found, UI may not be loaded yet")
    return
end

local modalOverlay = nil
local modalCard = nil

for _, child in pairs(screenGui:GetChildren()) do
    if child:IsA("Frame") and child.ZIndex == 200 then
        modalOverlay = child
        break
    end
end

if modalOverlay then
    for _, child in pairs(modalOverlay:GetChildren()) do
        if child:IsA("Frame") and child.ZIndex == 201 then
            modalCard = child
            break
        end
    end
end

if not modalCard then
    warn("[Patch] modalCard not found")
    return
end

for _, child in pairs(modalCard:GetChildren()) do
    if child:IsA("Frame") and child.Position.Y.Offset == 282 then
        child:Destroy()
    end
end

modalCard.Size = UDim2.new(0, 340, 0, 340)

for _, child in pairs(modalCard:GetChildren()) do
    if child:IsA("Frame") and child.Position.Y.Offset == 164 then
        child.Size = UDim2.new(1, -40, 0, 110)
    end
end

for _, child in pairs(modalCard:GetChildren()) do
    if child:IsA("TextButton") and child.Position.Y.Scale == 1 then
        local conn = child.MouseButton1Click:Connect(function()
            local titleInput = nil
            local scriptInput = nil
            for _, c in pairs(modalCard:GetChildren()) do
                if c:IsA("Frame") then
                    for _, c2 in pairs(c:GetChildren()) do
                        if c2:IsA("TextBox") then
                            if c2.Text:find(t("title_placeholder")) then
                                titleInput = c2
                            elseif c2.Text:find(t("script_placeholder")) then
                                scriptInput = c2
                            end
                        end
                    end
                end
            end
            if not titleInput or not scriptInput then return end
            local title = titleInput.Text
            local scriptCode = scriptInput.Text
            if title == "" or title == t("title_placeholder") then return end
            if scriptCode == "" or scriptCode == t("script_placeholder") then return end
            _G.__DeltaUI_ensureFolder()
            writefile(_G.__DeltaUI_storeScriptFolder .. "/" .. title, scriptCode)
            modalOverlay.Visible = false
            _G.__DeltaUI_refreshScriptList(_G.__DeltaUI_searchInput.Text)
        end)
        break
    end
end

if _G.__DeltaUI_refreshScriptList then
    local oldRefresh = _G.__DeltaUI_refreshScriptList
    _G.__DeltaUI_refreshScriptList = function(filter)
        local saveFolder = _G.__DeltaUI_storeScriptFolder
        local files = listfiles(saveFolder) or {}
        if files then
            for _, filePath in ipairs(files) do
                local metaPath = filePath:gsub("%.lua$", ".meta.json")
                if isfile(metaPath) then
                    local metaTxt = readfile(metaPath)
                    if metaTxt then
                        local ok, meta = pcall(function()
                            return game:GetService("HttpService"):JSONDecode(metaTxt)
                        end)
                        if not ok then
                            warn("[Patch] Removed corrupted meta.json: " .. metaPath)
                            delfile(metaPath)
                        end
                    end
                end
            end
        end
        return oldRefresh(filter)
    end
end

task.spawn(function()
    while true do
        task.wait(3)
        local folder = "DeltaUI/Script"
        if isfolder(folder) then
            local files = listfiles(folder) or {}
            for _, fp in ipairs(files) do
                if fp:match("%.meta%.json$") then
                    local ok = pcall(function()
                        delfile(fp)
                    end)
                    if ok then
                        warn("[Patch] Auto-deleted corrupted meta: " .. fp)
                    end
                end
            end
        end
    end
end)

_G.__DeltaUI_AddLog("[Patch] Save dialog patched: removed servers input, fixed JSON parse, reduced height", "info")
