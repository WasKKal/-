local function applyFix()
    local targetFunc = _G.__DeltaUI_ShowNotification

    if not targetFunc then
        if not getgc then
            warn("[NotificationFix] 当前执行器不支持 getgc，且未找到全局引用")
            return
        end
        for _, obj in pairs(getgc()) do
            if type(obj) == "function" then
                local info = debug.getinfo(obj)
                if info and info.name == "ShowNotification" then
                    targetFunc = obj
                    break
                end
            end
        end
    end

    if not targetFunc then
        warn("[NotificationFix] 未找到 ShowNotification 函数，请确保主 UI 已加载")
        return
    end

    local fixedFunc = function(message, duration, clickCallback)
        duration = duration or 1
        local notificationQueue = {}
        local notificationActive = false
        table.insert(notificationQueue, {msg = message, dur = duration, click = clickCallback})
        if notificationActive then return end
        task.spawn(function()
            while #notificationQueue > 0 do
                notificationActive = true
                local notif = table.remove(notificationQueue, 1)
                local notifFrame = Instance.new("Frame")
                notifFrame.AnchorPoint = Vector2.new(0.5, 0)
                notifFrame.Position = UDim2.new(0.5, 0, 0, -60)
                notifFrame.Size = UDim2.new(0, 0, 0, 40)
                notifFrame.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
                notifFrame.BackgroundTransparency = 0.1
                notifFrame.BorderSizePixel = 0
                notifFrame.ZIndex = 500
                notifFrame.Active = notif.click and true or false
                notifFrame.ClipsDescendants = true
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 10)
                corner.Parent = notifFrame
                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(50, 55, 70)
                stroke.Thickness = 1
                stroke.Transparency = 0.4
                stroke.Parent = notifFrame
                notifFrame.Parent = game:GetService("CoreGui")
                local notifText = Instance.new("TextLabel")
                notifText.Size = UDim2.new(1, 0, 1, -4)
                notifText.Position = UDim2.new(0, 0, 0, 0)
                notifText.BackgroundTransparency = 1
                notifText.Text = notif.msg
                notifText.TextColor3 = Color3.fromRGB(230, 232, 240)
                notifText.TextSize = 12
                notifText.Font = Enum.Font.SourceSansBold
                notifText.TextXAlignment = Enum.TextXAlignment.Center
                notifText.TextYAlignment = Enum.TextYAlignment.Center
                notifText.ZIndex = 501
                notifText.Parent = notifFrame
                local notifProgress = Instance.new("Frame")
                notifProgress.AnchorPoint = Vector2.new(0, 1)
                notifProgress.Position = UDim2.new(0, 0, 1, 0)
                notifProgress.Size = UDim2.new(1, 0, 0, 3)
                notifProgress.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
                notifProgress.BackgroundTransparency = 0.3
                notifProgress.BorderSizePixel = 0
                notifProgress.ZIndex = 502
                local pCorner = Instance.new("UICorner")
                pCorner.CornerRadius = UDim.new(0, 2)
                pCorner.Parent = notifProgress
                notifProgress.Parent = notifFrame
                game:GetService("TweenService"):Create(notifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 12)}):Play()
                game:GetService("TweenService"):Create(notifFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, math.min(400, notifText.TextBounds.X + 40), 0, 40)}):Play()
                task.wait(0.35)
                game:GetService("TweenService"):Create(notifProgress, TweenInfo.new(notif.dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
                task.wait(notif.dur)
                game:GetService("TweenService"):Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -60)}):Play()
                game:GetService("TweenService"):Create(notifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                game:GetService("TweenService"):Create(notifText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                game:GetService("TweenService"):Create(notifProgress, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.3)
                notifFrame:Destroy()
            end
            notificationActive = false
        end)
    end

    if replaceclosure then
        replaceclosure(targetFunc, fixedFunc)
        print("[NotificationFix] 已通过 replaceclosure 修复")
    elseif hookfunction then
        hookfunction(targetFunc, fixedFunc)
        print("[NotificationFix] 已通过 hookfunction 修复")
    else
        warn("[NotificationFix] 当前执行器不支持 replaceclosure/hookfunction")
    end
end

applyFix()
print("[NotificationFix] 补丁执行完毕")
