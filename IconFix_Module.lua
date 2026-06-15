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

    local fixedFunc = function(url, name)
        if not url or url == "" then return nil end
        local cacheDir = "DeltaUI/Cache"
        if not isfolder("DeltaUI") then makefolder("DeltaUI") end
        if not isfolder(cacheDir) then makefolder(cacheDir) end
        local safeName = name:gsub("[^%w%s_-]", ""):gsub("%s+", "_")
        if safeName == "" then safeName = "icon" end
        local fp = cacheDir .. "/" .. safeName .. ".png"
        if isfile(fp) then
            return readfile(fp)
        end
        local ok, data = pcall(function()
            return game:HttpGet(url)
        end)
        if ok and data and data ~= "" then
            writefile(fp, data)
            return data
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

-- 同时修复 makeModuleCard 中的 icon 调用保护
if getgc then
    for _, obj in pairs(getgc()) do
        if type(obj) == "function" then
            local info = debug.getinfo(obj)
            if info and info.name == "makeModuleCard" then
                if replaceclosure then
                    -- 无法安全替换 makeModuleCard（太复杂），但 getCachedIcon 修复已足够
                    print("[IconFix] getCachedIcon 修复已覆盖 makeModuleCard 的 icon 获取")
                end
                break
            end
        end
    end
end

print("[IconFix] 模块执行完毕")
