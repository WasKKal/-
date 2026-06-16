local function applyFix()
    local targetFunc = _G.__DeltaUI_getCachedIcon
    if not targetFunc then
        warn("[IconFix] 未找到 _G.__DeltaUI_getCachedIcon，请确保主 UI 已加载")
        return
    end

    local cacheDir = "DeltaUI/Cache"
    local function ensureCache()
        if not isfolder("DeltaUI") then makefolder("DeltaUI") end
        if not isfolder(cacheDir) then makefolder(cacheDir) end
    end

    local function toBase64(data)
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        return ((data:gsub('.', function(x)
            local r, b = '', x:byte()
            for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
            return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if #x < 6 then return '' end
            local c = 0
            for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
            return b:sub(c + 1, c + 1)
        end) .. ({ '', '==', '=' })[#data % 3 + 1])
    end

    local fixedFunc = function(url, name)
        if not url or url == "" then return nil end
        ensureCache()
        local safeName = name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
        if safeName == "" then safeName = "icon" end
        local fp = cacheDir .. "/" .. safeName .. ".png"
        if isfile(fp) then
            if getcustomasset then
                return getcustomasset(fp)
            end
            local data = readfile(fp)
            if data then
                return "data:image/png;base64," .. toBase64(data)
            end
            return url
        end
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and data ~= "" then
            writefile(fp, data)
            if getcustomasset then
                return getcustomasset(fp)
            end
            return "data:image/png;base64," .. toBase64(data)
        end
        return nil
    end

    if replaceclosure then
        replaceclosure(targetFunc, fixedFunc)
        print("[IconFix] 已通过 replaceclosure 修复")
    elseif hookfunction then
        hookfunction(targetFunc, fixedFunc)
        print("[IconFix] 已通过 hookfunction 修复")
    else
        warn("[IconFix] 当前执行器不支持 replaceclosure/hookfunction")
    end
end

applyFix()
print("[IconFix] 补丁执行完毕")
