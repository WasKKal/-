-- 自动识别直装版 · 检测到服务器直接运行脚本
local PlaceId = game.PlaceId

-- 在后巷
if PlaceId == 11257760806 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/%E5%9C%A8%E5%90%8E%E5%B7%B7.lua"))()
-- 割草模拟器
elseif PlaceId == 133086043677134 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/-/refs/heads/main/%E5%89%B2%E8%8D%89%E6%A8%A1%E6%8B%9F%E5%99%A8.lua"))()
end
