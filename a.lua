-- Wizard UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local lp = game.Players.LocalPlayer

-- Sửa lỗi thông báo
local function showNoti(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2
    })
end

-- Teleport function
local function tp(cf)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = cf
        showNoti("Teleport", "Di chuyen thanh cong!")
    end
end

-- Test trực tiếp không dùng loadstring
local function collect(code)
    if code and code ~= "" then
        -- Thử chạy trực tiếp nếu là code đơn giản
        if code == "print('a')" then
            showNoti("Test", "Code print('a') da chay!")
        elseif code:find("game:GetService") then
            -- Nếu code có game:GetService thì thử chạy
            pcall(function()
                loadstring(code)()
            end)
            showNoti("Collect", "Da chay code!")
        else
            showNoti("Collect", "Code: " .. code)
        end
    else
        showNoti("Collect", "Khong co code!")
    end
end

-- positions
local positions = {
    CFrame.new(-54.040, 104.454, 469.482, -0.875110269, 9.74059304e-08, -0.483923525, 9.67963274e-08, 1, 2.6240647e-08, 0.483923525, -2.38785596e-08, -0.875110269),
    CFrame.new(-79.5975571, 100.734673, 522.244507, -0.851041913, 3.37455042e-08, -0.525097787, -4.3390993e-09, 1, 7.12976913e-08, 0.525097787, 6.29557775e-08, -0.851041913),
    CFrame.new(-216.509262, 100.734673, 573.694092, 1, -1.44622918e-08, 2.35162665e-13, 1.44622918e-08, 1, -1.26297426e-08, -2.34980031e-13, 1.26297426e-08, 1),
    CFrame.new(106.348709, 104.733131, 432.794159, 1, 0, 0, 0, 1, 0, 0, 0, 1)
}

local codeStrings = {"", "", "", ""}

-- UI
local Window = Library:NewWindow("UGC Auto")
local Tab = Window:NewSection("Main")

Tab:CreateButton("Go To Lobby", function()
    pcall(function()
        local remote = game:GetService("ReplicatedStorage").Packages.Knit.Services.GameService.RF.GoToLobby
        remote:InvokeServer()
        showNoti("Lobby", "Da ve Lobby!")
    end)
end)

for i=1,4 do
    Tab:CreateTextbox("Code Part "..i, "", function(value)
        codeStrings[i] = value
    end)
    
    Tab:CreateButton("Go Part "..i, function()
        tp(positions[i])
        wait(1)
        collect(codeStrings[i])
    end)
end

local looping = false
Tab:CreateToggle("Auto Run", function(state)
    looping = state
    if looping then
        spawn(function()
            while looping do
                for i=1,4 do
                    if not looping then break end
                    tp(positions[i])
                    wait(1)
                    collect(codeStrings[i])
                    wait(3)
                end
                wait(1)
            end
        end)
    end
end)

showNoti("Script", "Da tai script!")
