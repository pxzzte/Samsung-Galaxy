-- Wizard UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local lp = game.Players.LocalPlayer

-- helper teleport
local function tp(cf)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = cf
    end
end

-- helper invoke
local function collect(args)
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages"):WaitForChild("Knit")
        :WaitForChild("Services"):WaitForChild("CollectibleService")
        :WaitForChild("RF"):WaitForChild("Collect")
    pcall(function()
        remote:InvokeServer(unpack(args))
    end)
end

-- positions (CFrame)
local positions = {
    CFrame.new(-54.040, 104.454, 469.482, -0.875110269, 9.74059304e-08, -0.483923525, 9.67963274e-08, 1, 2.6240647e-08, 0.483923525, -2.38785596e-08, -0.875110269),
    CFrame.new(-79.5975571, 100.734673, 522.244507, -0.851041913, 3.37455042e-08, -0.525097787, -4.3390993e-09, 1, 7.12976913e-08, 0.525097787, 6.29557775e-08, -0.851041913),
    CFrame.new(-216.509262, 100.734673, 573.694092, 1, -1.44622918e-08, 2.35162665e-13, 1.44622918e-08, 1, -1.26297426e-08, -2.34980031e-13, 1.26297426e-08, 1),
    CFrame.new(106.348709, 104.733131, 432.794159, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

-- lưu args nhập từ textbox
local argsList = {{},{},{},{}}

-- UI
local Window = Library:NewWindow("UGC Auto")
local Tab = Window:NewSection("Main")

-- Lobby button
Tab:CreateButton("Go To Lobby", function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Packages"):WaitForChild("Knit")
        :WaitForChild("Services"):WaitForChild("GameService")
        :WaitForChild("RF"):WaitForChild("GoToLobby")
    pcall(function() remote:InvokeServer() end)
end)

-- Part buttons + textbox
for i=1,4 do
    -- textbox để nhập args (dạng: uuid1,GalaxyStars,uuid2)
    Tab:CreateTextbox("Args for Part "..i, function(txt)
        local t = {}
        for v in string.gmatch(txt, "([^,]+)") do
            table.insert(t, v)
        end
        argsList[i] = t
    end)

    -- button dịch chuyển + invoke
    Tab:CreateButton("Go Part "..i, function()
        tp(positions[i])
        task.wait(0.3)
        if #argsList[i] > 0 then
            collect(argsList[i])
        else
            warn("Chưa nhập args cho Part "..i)
        end
    end)
end
