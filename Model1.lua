return function(core)
    local create = core.create
    local corner = core.corner
    local stroke = core.stroke
    local theme = core.theme
    local t = core.t
    local GetIcon = core.GetIcon
    local contentFrame = core.contentFrame
    local settingsScroll = core.settingsScroll
    local makeSettingRow = core.makeSettingRow
    local makeToggle = core.makeToggle
    local makeDropdown = core.makeDropdown
    local makeActionButton = core.makeActionButton
    local AddLog = core.AddLog
    local saveConfig = core.saveConfig
    local loadConfig = core.loadConfig
    local registerTranslation = core.registerTranslation

    -- 注册翻译条目（仅当主 UI 中不存在时才会插入）
    registerTranslation("custom_speed", {
        en = "Super Speed",
        zh = "超级速度",
        ko = "초고속",
        ja = "スーパースピード"
    })
    registerTranslation("custom_speed_desc", {
        en = "Multiply your walk speed by 2x",
        zh = "将行走速度乘以 2 倍",
        ko = "이동 속도를 2배로 증가",
        ja = "歩行速度を2倍にする"
    })
    registerTranslation("custom_jump", {
        en = "Super Jump",
        zh = "超级跳跃",
        ko = "초고점프",
        ja = "スーパージャンプ"
    })
    registerTranslation("custom_jump_desc", {
        en = "Multiply your jump power by 3x",
        zh = "将跳跃力乘以 3 倍",
        ko = "점프력을 3배로 증가",
        ja = "ジャンプ力を3倍にする"
    })
    registerTranslation("custom_mode", {
        en = "Movement Mode",
        zh = "移动模式",
        ko = "이동 모드",
        ja = "移動モード"
    })
    registerTranslation("custom_mode_desc", {
        en = "Select preferred movement enhancement mode",
        zh = "选择首选的移动增强模式",
        ko = "선호하는 이동 강화 모드 선택",
        ja = "優先移動強化モードを選択"
    })

    local v7 = game:GetService("Players").LocalPlayer
    local v5 = game:GetService("RunService")

    local speedEnabled = false
    local jumpEnabled = false
    local speedConnection = nil
    local jumpConnection = nil

    local function applySpeed(char)
        if speedConnection then
            speedConnection:Disconnect()
        end
        speedConnection = v5.RenderStepped:Connect(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 32
            end
        end)
    end

    local function applyJump(char)
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        jumpConnection = v5.RenderStepped:Connect(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = 150
            end
        end)
    end

    if settingsScroll then
        local speedRow = makeSettingRow("custom_speed", "custom_speed_desc", 18)
        local _, getSpeedState = makeToggle(speedRow, false, function(state)
            speedEnabled = state
            if state then
                local char = v7.Character
                if char then
                    applySpeed(char)
                end
                AddLog("[Super Speed] Enabled", "info")
            else
                if speedConnection then
                    speedConnection:Disconnect()
                    speedConnection = nil
                end
                local char = v7.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                    end
                end
                AddLog("[Super Speed] Disabled", "info")
            end
        end, "custom_speed")
        speedRow.Parent = settingsScroll

        local jumpRow = makeSettingRow("custom_jump", "custom_jump_desc", 19)
        local _, getJumpState = makeToggle(jumpRow, false, function(state)
            jumpEnabled = state
            if state then
                local char = v7.Character
                if char then
                    applyJump(char)
                end
                AddLog("[Super Jump] Enabled", "info")
            else
                if jumpConnection then
                    jumpConnection:Disconnect()
                    jumpConnection = nil
                end
                local char = v7.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.JumpPower = 50
                    end
                end
                AddLog("[Super Jump] Disabled", "info")
            end
        end, "custom_jump")
        jumpRow.Parent = settingsScroll

        local modeRow = makeSettingRow("custom_mode", "custom_mode_desc", 20)
        makeDropdown(modeRow, {"Balanced", "Aggressive", "Stealth"}, 1, function(val)
            AddLog("[Movement Mode] Set to " .. val, "info")
        end, "custom_mode")
        modeRow.Parent = settingsScroll
    end

    v7.CharacterAdded:Connect(function(char)
        if speedEnabled then
            applySpeed(char)
        end
        if jumpEnabled then
            applyJump(char)
        end
    end)
end
