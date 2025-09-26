-- Wizard UI + Loop Invoke Helper
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

-- Notify helper
local function log(txt)
	pcall(function()
		StarterGui:SetCore("SendNotification",{Title="UGC Helper",Text=txt,Duration=3})
	end)
	print("[UGC Helper] "..txt)
end

-- Teleport
local function tpTo(part)
	if not (lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")) then return end
	lp.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
end

-- Get parts
local parts = {
	workspace.Lobby.Collectibles:GetChildren()[5], -- part1
	workspace.Lobby.Collectibles:GetChildren()[4], -- part2
	workspace.Lobby.Collectibles:GetChildren()[2], -- part3
	workspace.Lobby.Collectibles:GetChildren()[3], -- part4
}

-- Store function names typed
local funcs = {"","","",""}

-- Build UI
local Window = Library:NewWindow("UGC Helper")
local Tab = Window:NewSection("Loop Invoker")

for i=1,4 do
	Tab:CreateTextbox("Function "..i, function(text)
		funcs[i] = text
		log("Set Func"..i.." = "..text)
	end)
	Tab:CreateButton("Test Invoke "..i, function()
		if funcs[i]=="" then log("No function name in box "..i) return end
		local rf = game.ReplicatedStorage:FindFirstChild(funcs[i], true)
		if rf and rf:IsA("RemoteFunction") then
			tpTo(parts[i])
			pcall(function() rf:InvokeServer() end)
			log("Invoked "..funcs[i].." at Part"..i)
		else
			log("RemoteFunction not found: "..funcs[i])
		end
	end)
end

-- Main Loop button
local looping = false
Tab:CreateButton("Start Loop 1→2→3→4", function()
	if looping then 
		looping=false 
		log("Loop stopped") 
		return 
	end
	looping = true
	log("Loop started")
	task.spawn(function()
		while looping do
			for i=1,4 do
				if not looping then break end
				if funcs[i]~="" and parts[i] then
					tpTo(parts[i])
					local rf = game.ReplicatedStorage:FindFirstChild(funcs[i], true)
					if rf and rf:IsA("RemoteFunction") then
						pcall(function() rf:InvokeServer() end)
						log("Loop invoked "..funcs[i].." at "..i)
					else
						log("Func"..i.." not found: "..funcs[i])
					end
				end
				task.wait(0.5) -- nhỏ delay tránh crash
			end
		end
	end)
end)
