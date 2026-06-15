local function applyFix()
    if not getgc then
        warn("[IconFix] 当前执行器不支持 getgc，无法自动热修复")
        warn("[IconFix] 请手动使用修复后的 DeltaUI 主脚本重新加载")
        return
    end

    local targetFunc = nil
    for _, obj in pairs(getgc()) do
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info and info.name == "getCachedIcon" then
                targetFunc = obj
                break
            end
        end
    end

    if not targetFunc then
        warn("[IconFix] 未找到 getCachedIcon 函数，DeltaUI 可能未加载")
        return
    end

    local cacheFolder = "DeltaUI/Cache"
    local function ensureCacheFolder()
        if not isfolder("DeltaUI") then makefolder("DeltaUI") end
        if not isfolder(cacheFolder) then makefolder(cacheFolder) end
    end

    local fixedFunc = function(url, name)
        if not url or url == "" then return nil end
        ensureCacheFolder()
        local safeName = name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
        if safeName == "" then safeName = "icon" end
        local fp = cacheFolder .. "/" .. safeName .. ".png"
        if isfile(fp) then
            return url
        end
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and data ~= "" then
            writefile(fp, data)
            return url
        end
        return nil
    end

    if replaceclosure then
        replaceclosure(targetFunc, fixedFunc)
        print("[IconFix] 已通过 replaceclosure 修复 getCachedIcon")
    elseif hookfunction then
        hookfunction(targetFunc, fixedFunc)
        print("[IconFix] 已通过 hookfunction 修复 getCachedIcon")
    else
        warn("[IconFix] 当前执行器不支持 replaceclosure/hookfunction")
        warn("[IconFix] 请手动使用修复后的 DeltaUI 主脚本重新加载")
    end
end

applyFix()
print("[IconFix] 模块执行完毕")
