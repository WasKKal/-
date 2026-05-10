local LOADER_KEY = "TRASH_LOADER_SIMPLE"
local SCRIPT_KEY = "TRASH_SCRIPT_GL"
if getgenv()[LOADER_KEY] then return end
getgenv()[LOADER_KEY] = true
if getgenv()[SCRIPT_KEY] then return end
getgenv()[SCRIPT_KEY] = true
local SCRIPT_URL = "https://raw.githubusercontent.com/WasKKal/-/main/GL.lua"
local function lerpColor(c1,c2,t)return Color3.new(c1.R+(c2.R-c1.R)*t,c1.G+(c2.G-c1.G)*t,c1.B+(c2.B-c1.B)*t)end
local LoadingAnimation = {}
LoadingAnimation.__index = LoadingAnimation
function LoadingAnimation.new()
pcall(function()local old=game:GetService("CoreGui"):FindFirstChild("TrashLoadingScreen")if old then old:Destroy()end end)
local self=setmetatable({},LoadingAnimation)
local lighting=game:GetService("Lighting")
self.originalBrightness=lighting.Brightness
self.originalAmbient=lighting.Ambient
self.originalOutdoorAmbient=lighting.OutdoorAmbient
self.gui=Instance.new("ScreenGui")
self.gui.Name="TrashLoadingScreen"
self.gui.Parent=game:GetService("CoreGui")
self.gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
self.gui.DisplayOrder=999999
self.gui.ResetOnSpawn=false
self.gui.IgnoreGuiInset=true
self.triggered30=false
self.triggered90=false
self.triggered91=false
self.colorCycleActive=false
self.colorCycleTween=nil
self.heartbeatConn=nil
self.rainbowBars=nil
self.isTimeout=false
self.startTime=tick()
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
if tick()-self.startTime>=5 and not self.triggered30 then
self.isTimeout=true
if self.title then
self.title.TextColor3=Color3.fromRGB(255,0,0)
task.wait(0.5)
self.title.Text="已超时,点此跳过"
self.title.MouseButton1Click:Connect(function()self:fadeOutAndDestroy()end)
end
break
end
end
end)
end
function LoadingAnimation:_createUI()
self.bg=Instance.new("Frame")
self.bg.Name="bg"
self.bg.Size=UDim2.new(1,0,1,0)
self.bg.BackgroundColor3=Color3.fromRGB(0,0,0)
self.bg.BackgroundTransparency=0.3
self.bg.BorderSizePixel=0
self.bg.Parent=self.gui
local container=Instance.new("Frame")
container.Name="centerContainer"
container.Size=UDim2.new(0,500,0,260)
container.Position=UDim2.new(0.5,-250,0.5,-130)
container.BackgroundTransparency=1
container.Parent=self.gui
self.title=Instance.new("TextLabel")
self.title.Name="titleLabel"
self.title.Size=UDim2.new(1,0,0,60)
self.title.Position=UDim2.new(0,0,0,0)
self.title.BackgroundTransparency=1
self.title.Text="Trash Hub"
self.title.TextColor3=Color3.fromRGB(255,200,100)
self.title.TextStrokeTransparency=0
self.title.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.title.Font=Enum.Font.GothamBold
self.title.TextSize=48
self.title.TextXAlignment=Enum.TextXAlignment.Center
self.title.TextYAlignment=Enum.TextYAlignment.Center
self.title.Parent=container
self.status=Instance.new("TextLabel")
self.status.Name="statusLabel"
self.status.Size=UDim2.new(1,0,0,30)
self.status.Position=UDim2.new(0,0,0,65)
self.status.BackgroundTransparency=1
self.status.Text="正在初始化中…"
self.status.TextColor3=Color3.fromRGB(255,255,25)
self.status.TextStrokeTransparency=0.3
self.status.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.status.Font=Enum.Font.Gotham
self.status.TextSize=18
self.status.TextXAlignment=Enum.TextXAlignment.Center
self.status.Parent=container
self.filesLabel=Instance.new("TextLabel")
self.filesLabel.Name="filesLabel"
self.filesLabel.Size=UDim2.new(1,-20,0,18)
self.filesLabel.Position=UDim2.new(0,10,0,100)
self.filesLabel.BackgroundTransparency=1
self.filesLabel.Text="正在加载脚本…"
self.filesLabel.TextColor3=Color3.fromRGB(180,180,180)
self.filesLabel.TextStrokeTransparency=0.6
self.filesLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.filesLabel.Font=Enum.Font.Gotham
self.filesLabel.TextSize=13
self.filesLabel.TextXAlignment=Enum.TextXAlignment.Center
self.filesLabel.Parent=container
self.currentFile=Instance.new("TextLabel")
self.currentFile.Name="currentFileLabel"
self.currentFile.Size=UDim2.new(1,-20,0,18)
self.currentFile.Position=UDim2.new(0,10,0,118)
self.currentFile.BackgroundTransparency=1
self.currentFile.Text="脚本资源"
self.currentFile.TextColor3=Color3.fromRGB(255,200,100)
self.currentFile.TextStrokeTransparency=0.5
self.currentFile.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.currentFile.Font=Enum.Font.Gotham
self.currentFile.TextSize=13
self.currentFile.TextXAlignment=Enum.TextXAlignment.Center
self.currentFile.Parent=container
self.downloadInfo=Instance.new("TextLabel")
self.downloadInfo.Name="downloadInfoLabel"
self.downloadInfo.Size=UDim2.new(1,-20,0,18)
self.downloadInfo.Position=UDim2.new(0,10,0,100)
self.downloadInfo.BackgroundTransparency=1
self.downloadInfo.Text=""
self.downloadInfo.TextColor3=Color3.fromRGB(255,200,100)
self.downloadInfo.TextStrokeTransparency=0.5
self.downloadInfo.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.downloadInfo.Font=Enum.Font.Gotham
self.downloadInfo.TextSize=13
self.downloadInfo.TextXAlignment=Enum.TextXAlignment.Center
self.downloadInfo.Visible=false
self.downloadInfo.Parent=container
local progressBg=Instance.new("Frame")
progressBg.Name="progressBg"
progressBg.Size=UDim2.new(1,-40,0,20)
progressBg.Position=UDim2.new(0,20,0,145)
progressBg.BackgroundColor3=Color3.fromRGB(60,60,60)
progressBg.BorderSizePixel=0
progressBg.Parent=container
local bgCorner=Instance.new("UICorner")
bgCorner.CornerRadius=UDim.new(0,10)
bgCorner.Parent=progressBg
self.progressBg=progressBg
self.progressFill=Instance.new("Frame")
self.progressFill.Name="progressFill"
self.progressFill.Size=UDim2.new(0,0,1,0)
self.progressFill.BackgroundColor3=Color3.fromRGB(255,200,100)
self.progressFill.BorderSizePixel=0
self.progressFill.Parent=progressBg
local fillCorner=Instance.new("UICorner")
fillCorner.CornerRadius=UDim.new(0,10)
fillCorner.Parent=self.progressFill
self.percent=Instance.new("TextLabel")
self.percent.Name="percentLabel"
self.percent.Size=UDim2.new(0,60,0,20)
self.percent.Position=UDim2.new(0.5,-30,0,170)
self.percent.BackgroundTransparency=1
self.percent.Text="0%"
self.percent.TextColor3=Color3.fromRGB(255,255,255)
self.percent.TextStrokeTransparency=0.3
self.percent.TextStrokeColor3=Color3.fromRGB(0,0,0)
self.percent.Font=Enum.Font.GothamBold
self.percent.TextSize=16
self.percent.TextXAlignment=Enum.TextXAlignment.Center
self.percent.Parent=container
end
function LoadingAnimation:_createColorBackground()
self.colorBackground=Instance.new("Frame")
self.colorBackground.Name="ColorBackground"
self.colorBackground.Size=UDim2.new(1,0,1,0)
self.colorBackground.Position=UDim2.new(0.5,0,0.5,0)
self.colorBackground.AnchorPoint=Vector2.new(0.5,0.5)
self.colorBackground.BackgroundColor3=Color3.fromRGB(255,0,0)
self.colorBackground.BackgroundTransparency=1
self.colorBackground.BorderSizePixel=0
self.colorBackground.ZIndex=1
self.colorBackground.Parent=self.gui
end
function LoadingAnimation:_createRainbowEffect()
local effectContainer=Instance.new("Frame")
effectContainer.Name="RainbowEffect"
effectContainer.Size=UDim2.new(1,0,1,0)
effectContainer.BackgroundTransparency=1
effectContainer.ZIndex=2
effectContainer.Parent=self.gui
local barLength=50
local barsPerEdge=200
local speed=0.8
local colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,165,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(128,0,128)}
local bars={}
local function createBarWithAnimation(edgeIdx,i)
local isHorizontal=edgeIdx==1 or edgeIdx==3
local isBottom=edgeIdx==1
local isTop=edgeIdx==3
local isRight=edgeIdx==2
local isLeft=edgeIdx==4
local bar=Instance.new("Frame")
bar.Name=string.format("Bar_%d_%d",edgeIdx,i)
bar.BorderSizePixel=0
bar.ZIndex=2
bar.BackgroundTransparency=1
bar.Parent=effectContainer
if isHorizontal then
bar.Size=UDim2.new(1/barsPerEdge,0,0,0)
bar.AnchorPoint=isBottom and Vector2.new(0.5,1)or Vector2.new(0.5,0)
bar.Position=isBottom and UDim2.new((i-0.5)/barsPerEdge,0,1,0)or UDim2.new((i-0.5)/barsPerEdge,0,0,0)
else
bar.Size=UDim2.new(0,0,1/barsPerEdge,0)
bar.AnchorPoint=isRight and Vector2.new(1,0.5)or Vector2.new(0,0.5)
bar.Position=isRight and UDim2.new(1,0,(i-0.5)/barsPerEdge,0)or UDim2.new(0,0,(i-0.5)/barsPerEdge,0)
end
local gradient=Instance.new("UIGradient")
if edgeIdx==1 then
gradient.Rotation=270
gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
elseif edgeIdx==2 then
gradient.Rotation=180
gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
elseif edgeIdx==3 then
gradient.Rotation=90
gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
else
gradient.Rotation=0
gradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
end
gradient.Parent=bar
local t_global=edgeIdx==1 and(i-0.5)/(barsPerEdge*4)or edgeIdx==2 and(barsPerEdge+i-0.5)/(barsPerEdge*4)or edgeIdx==3 and(2*barsPerEdge+i-0.5)/(barsPerEdge*4)or(3*barsPerEdge+i-0.5)/(barsPerEdge*4)
table.insert(bars,{bar=bar,t_global=t_global,isHorizontal=isHorizontal})
local targetSize=isHorizontal and UDim2.new(1/barsPerEdge,0,0,barLength)or UDim2.new(0,barLength,1/barsPerEdge,0)
local tweenInfo=TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
game:GetService("TweenService"):Create(bar,tweenInfo,{Size=targetSize}):Play()
game:GetService("TweenService"):Create(bar,tweenInfo,{BackgroundTransparency=0}):Play()
end
for edgeIdx=1,4 do
for i=1,barsPerEdge do
createBarWithAnimation(edgeIdx,i)
end
end
self.rainbowBars=bars
local startTime=tick()
self.heartbeatConn=game:GetService("RunService").Heartbeat:Connect(function()
local elapsed=(tick()-startTime)*speed
local offset=elapsed%1
for _,data in ipairs(bars)do
local currentT=data.t_global-offset
if currentT<0 then currentT=currentT+1 end
local seg=math.floor(currentT*#colors)+1
local pos=(currentT*#colors)%1
local c1=colors[seg]
local c2=colors[seg%#colors+1]
data.bar.BackgroundColor3=lerpColor(c1,c2,pos)
end
end)
end
function LoadingAnimation:_darkenScreen()
local lighting=game:GetService("Lighting")
for i=1,30 do
local p=i/30
lighting.Brightness=self.originalBrightness-(self.originalBrightness-0.4)*p
lighting.Ambient=Color3.new(self.originalAmbient.R-(self.originalAmbient.R-0.4)*p,self.originalAmbient.G-(self.originalAmbient.G-0.4)*p,self.originalAmbient.B-(self.originalAmbient.B-0.4)*p)
lighting.OutdoorAmbient=Color3.new(self.originalOutdoorAmbient.R-(self.originalOutdoorAmbient.R-0.4)*p,self.originalOutdoorAmbient.G-(self.originalOutdoorAmbient.G-0.4)*p,self.originalOutdoorAmbient.B-(self.originalOutdoorAmbient.B-0.4)*p)
task.wait(0.01)
end
lighting.Brightness=0.4
lighting.Ambient=Color3.new(0.4,0.4,0.4)
lighting.OutdoorAmbient=Color3.new(0.4,0.4,0.4)
end
function LoadingAnimation:updateProgress(percent,statusText,detailText,showDeleteUI)
if not self.gui or not self.gui.Parent then return false end
if statusText then self.status.Text=statusText end
local isDeleteMode=showDeleteUI==true
if self.filesLabel then self.filesLabel.Visible=isDeleteMode end
if self.currentFile then self.currentFile.Visible=isDeleteMode end
if self.downloadInfo then self.downloadInfo.Visible=not isDeleteMode end
if detailText then
if isDeleteMode then
if self.currentFile then self.currentFile.Text=detailText end
else
if self.downloadInfo then self.downloadInfo.Text=detailText end
end
end
if self.progressFill and type(percent)=="number"then
self.progressFill:TweenSize(UDim2.new(percent/100,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.3,true)
end
if self.percent then
self.percent.Text=math.floor(percent).."%"
end
if percent>=30 and not self.triggered30 then
self.triggered30=true
if self.colorBackground then
self.colorBackground.BackgroundTransparency=0.9
end
self:_startColorCycle()
end
if percent>=90 and not self.triggered90 then
self.triggered90=true
self:stopColorCycle()
if self.colorBackground then
local ts=game:GetService("TweenService")
ts:Create(self.colorBackground,TweenInfo.new(1,Enum.EasingStyle.Quad),{BackgroundColor3=Color3.fromRGB(0,255,0),BackgroundTransparency=1,Size=UDim2.new(2,0,2,0)}):Play()
end
end
if percent>=91 and not self.triggered91 then
self.triggered91=true
if self.colorCycleTween then self.colorCycleTween:Cancel()end
if self.colorBackground then
self.colorBackground.BackgroundColor3=Color3.fromRGB(255,0,0)
self.colorBackground.BackgroundTransparency=0
self.colorBackground.Size=UDim2.new(1,0,1,0)
local ts=game:GetService("TweenService")
ts:Create(self.colorBackground,TweenInfo.new(0.8,Enum.EasingStyle.Quad),{BackgroundTransparency=1,Size=UDim2.new(2,0,2,0)}):Play()
end
if self.rainbowBars then
local ts=game:GetService("TweenService")
for _,d in ipairs(self.rainbowBars)do
local bar=d.bar
if bar then
local tar=d.isHorizontal and UDim2.new(bar.Size.X.Scale,bar.Size.X.Offset,0,0)or UDim2.new(0,0,bar.Size.Y.Scale,bar.Size.Y.Offset)
ts:Create(bar,TweenInfo.new(0.8),{Size=tar,BackgroundTransparency=1}):Play()
end
end
end
if self.heartbeatConn then
pcall(function()self.heartbeatConn:Disconnect()end)
end
end
return true
end
function LoadingAnimation:_startColorCycle()
local colors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,165,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(128,0,128)}
local idx=1
local ts=game:GetService("TweenService")
local function nextC()
if not self.colorCycleActive then return end
local tar=colors[idx]
idx=idx%#colors+1
if self.colorBackground then
self.colorCycleTween=ts:Create(self.colorBackground,TweenInfo.new(0.5),{BackgroundColor3=tar})
self.colorCycleTween.Completed:Connect(nextC)
self.colorCycleTween:Play()
end
end
self.colorCycleActive=true
nextC()
end
function LoadingAnimation:stopColorCycle()
self.colorCycleActive=false
if self.colorCycleTween then
self.colorCycleTween:Cancel()
end
end
function LoadingAnimation:fadeOutDeleteUI()
if not self.filesLabel or not self.currentFile then return end
local ts=game:GetService("TweenService")
local ti=TweenInfo.new(0.3)
ts:Create(self.filesLabel,ti,{TextTransparency=1}):Play()
ts:Create(self.currentFile,ti,{TextTransparency=1}):Play()
task.wait(0.3)
self.filesLabel.Visible=false
self.currentFile.Visible=false
self.filesLabel.TextTransparency=0
self.currentFile.TextTransparency=0
end
function LoadingAnimation:setTitleWithAnimation(newTitle)
if not self.title then return end
local ts=game:GetService("TweenService")
local ti=TweenInfo.new(0.4)
ts:Create(self.title,ti,{TextTransparency=1}):Play()
task.wait(0.4)
self.title.Text=newTitle
ts:Create(self.title,ti,{TextTransparency=0}):Play()
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
local elements={self.title,self.status,self.filesLabel,self.currentFile,self.downloadInfo,self.percent,self.progressFill,self.progressBg,self.bg,self.colorBackground}
for i=1,30 do
local p=i/30
for _,e in ipairs(elements)do
if e then
if e==self.bg or e==self.progressBg then
if e:IsA("Frame")then
e.BackgroundTransparency=0.3+p*0.7
end
elseif e:IsA("TextLabel")then
e.TextTransparency=p
elseif e==self.progressFill or e==self.colorBackground then
if e:IsA("Frame")then
e.BackgroundTransparency=p
end
end
end
end
task.wait(0.01)
end
local lighting=game:GetService("Lighting")
for i=1,30 do
local p=i/30
lighting.Brightness=0.4+(self.originalBrightness-0.4)*p
lighting.Ambient=Color3.new(0.4+(self.originalAmbient.R-0.4)*p,0.4+(self.originalAmbient.G-0.4)*p,0.4+(self.originalAmbient.B-0.4)*p)
lighting.OutdoorAmbient=Color3.new(0.4+(self.originalOutdoorAmbient.R-0.4)*p,0.4+(self.originalOutdoorAmbient.G-0.4)*p,0.4+(self.originalOutdoorAmbient.B-0.4)*p)
task.wait(0.01)
end
lighting.Brightness=self.originalBrightness
lighting.Ambient=self.originalAmbient
lighting.OutdoorAmbient=self.originalOutdoorAmbient
self.gui:Destroy()
end
LoadingAnimation.destroy=LoadingAnimation.fadeOutAndDestroy
task.spawn(function()
local loader=LoadingAnimation.new()
loader:updateProgress(30,"正在加载脚本…","脚本资源",true)
task.wait(0.5)
loader:updateProgress(60,"获取脚本内容…","正在加载",true)
task.wait(0.5)
local success,err=pcall(function()
local content=game:HttpGet(SCRIPT_URL)
if not content or content==""then error("脚本内容为空")end
local func=loadstring(content)
if not func then error("脚本编译失败")end
func()
end)
if success then
loader:updateProgress(100,"加载完成！","脚本已注入",false)
else
loader:updateProgress(85,"执行失败",tostring(err),false)
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification",{Title="加载失败",Text=tostring(err),Duration=3})
end)
end
task.wait(0.8)
loader:fadeOutAndDestroy()
end)
