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

-- UI
local Window = Library:NewWindow("UGC Runner")
local Tab = Window:NewSection("Actions")

-- Nút GoToLobby
Tab:CreateButton("Go To Lobby", function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages"):WaitForChild("Knit")
        :WaitForChild("Services"):WaitForChild("GameService")
        :WaitForChild("RF"):WaitForChild("GoToLobby")

    pcall(function()
        remote:InvokeServer()
    end)
end)

-- Nút cho Part 1
Tab:CreateButton("Part 1", function()
    local part = getPart(5) -- theo yêu cầu: part1 = [5]
    tp(part)
    local remote = game.ReplicatedStorage:FindFirstChild("YourRemoteHere", true)
    if remote then
        if remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer() end)
        elseif remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer() end)
        end
    end
end)

-- Nút cho Part 2
Tab:CreateButton("Part 2", function()
    local part = getPart(4) -- part2 = [4]
    tp(part)
    local remote = game.ReplicatedStorage:FindFirstChild("YourRemoteHere", true)
    if remote then
        if remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer() end)
        elseif remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer() end)
        end
    end
end)

-- Nút cho Part 3
Tab:CreateButton("Part 3", function()
    local part = getPart(2) -- part3 = [2]
    tp(part)
    local remote = game.ReplicatedStorage:FindFirstChild("YourRemoteHere", true)
    if remote then
        if remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer() end)
        elseif remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer() end)
        end
    end
end)
