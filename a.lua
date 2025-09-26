-- Wizard UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local lp = game.Players.LocalPlayer

-- helper: lấy part
local function getPart(idx)
    local coll = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Collectibles")
    if coll then
        return coll:GetChildren()[idx]
    end
end

-- helper: teleport
local function tp(part)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and part then
        lp.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
    end
end

-- lưu input
local funcs = {"","","",""}
local parts = {1,1,1,1}

-- UI
local Window = Library:NewWindow("UGC Auto Runner")
local Tab = Window:NewSection("Sequence")

for i=1,4 do
    Tab:CreateTextbox("Function "..i, function(txt)
        funcs[i] = txt
    end)
    Tab:CreateTextbox("Part Index "..i, function(txt)
        parts[i] = tonumber(txt) or 1
    end)
    Tab:CreateButton("Test Invoke "..i, function()
        local part = getPart(parts[i])
        tp(part)
        task.wait(0.3)
        local remote = game.ReplicatedStorage:FindFirstChild(funcs[i], true)
        if remote and remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer() end)
        elseif remote and remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer() end)
        else
            warn("Không tìm thấy Remote: "..funcs[i])
        end
    end)
end

-- Toggle chạy loop
local looping = false
Tab:CreateToggle("Run Sequence Loop", function(state)
    looping = state
    if looping then
        task.spawn(function()
            while looping do
                for i=1,4 do
                    local part = getPart(parts[i])
                    tp(part)
                    task.wait(0.3)
                    local remote = game.ReplicatedStorage:FindFirstChild(funcs[i], true)
                    if remote and remote:IsA("RemoteFunction") then
                        pcall(function() remote:InvokeServer() end)
                    elseif remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                    task.wait(0.5)
                end
            end
        end)
    end
end)
