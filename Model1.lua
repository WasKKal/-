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
    local AddLog = core.AddLog
    local saveConfig = core.saveConfig
    local loadConfig = core.loadConfig

    local v7 = game:GetService("Players").LocalPlayer
    local v5 = game:GetService("RunService")

    local antiFallEnabled = false
    local antiFallConnection = nil
    local noclipEnabled = false
    local noclipConnection = nil

    local function restoreAntiFall(char)
        if antiFallConnection then
            antiFallConnection:Disconnect()
        end
        antiFallConnection = v5.RenderStepped:Connect(function()
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.FloorMaterial == Enum.Material.Air then
                local vel = hrp.Velocity
                if vel.Y < -50 then
                    hrp.Velocity = Vector3.new(vel.X, -10, vel.Z)
                end
            end
        end)
    end

    local function restoreNoclip(char)
        if noclipConnection then
            noclipConnection:Disconnect()
        end
        noclipConnection = v5.Stepped:Connect(function()
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end

    if settingsScroll then
        local fallRow = makeSettingRow("anti_fall", "anti_fall_desc", 16)
        local _, getAntiFallState = makeToggle(fallRow, false, function(state)
            antiFallEnabled = state
            if state then
                local char = v7.Character
                if char then
                    restoreAntiFall(char)
                end
                AddLog("[Anti-Fall] Enabled", "info")
            else
                if antiFallConnection then
                    antiFallConnection:Disconnect()
                    antiFallConnection = nil
                end
                AddLog("[Anti-Fall] Disabled", "info")
            end
        end, "anti_fall")
        fallRow.Parent = settingsScroll

        local noclipRow = makeSettingRow("noclip", "noclip_desc", 17)
        local _, getNoclipState = makeToggle(noclipRow, false, function(state)
            noclipEnabled = state
            if state then
                local char = v7.Character
                if char then
                    restoreNoclip(char)
                end
                AddLog("[Noclip] Enabled", "info")
            else
                if noclipConnection then
                    noclipConnection:Disconnect()
                    noclipConnection = nil
                end
                local char = v7.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
                AddLog("[Noclip] Disabled", "info")
            end
        end, "noclip")
        noclipRow.Parent = settingsScroll
    end

    v7.CharacterAdded:Connect(function(char)
        if antiFallEnabled then
            restoreAntiFall(char)
        end
        if noclipEnabled then
            restoreNoclip(char)
        end
    end)
end
