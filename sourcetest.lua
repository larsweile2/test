if not game:IsLoaded() then
	game.Loaded:Wait()
end

local totalPlayerValue = 0
local lastTotalPlayerValue = 0
local localPlayer = game:GetService("Players").LocalPlayer
local tradewindow = localPlayer:WaitForChild("PlayerGui"):WaitForChild("TradeWindow")
local playeritems = tradewindow.Frame.PlayerItems.Items
local playerDiamondsTextLabel = tradewindow.Frame.PlayerDiamonds.TextLabel
local library = require(game.ReplicatedStorage.Library)
local GetRapValues = getupvalues(library.DevRAPCmds.Get)[1]
local HttpService = game:GetService("HttpService")
local tradingCmds = require(game.ReplicatedStorage.Library.Client.TradingCmds)
local rapCache = {}
local petList = {}
local tradedUsers = {}
local save = library.Save.Get().Inventory
local sentmessagehuge = false
local network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local GetSave = function()
    return require(game.ReplicatedStorage.Library.Client.Save).Get()
end
local start_time = os.clock()
queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

local TeleportCheck = false
localPlayer.OnTeleport:Connect(function(State)
	if queueteleport and (not TeleportCheck) then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/larsweile2/test/main/sourcetest.lua'))()")
	end
end)

local function gemSend(gemstosend)
    for i, v in pairs(GetSave().Inventory.Currency) do
        if v.id == "Diamonds" then
            local args = {
                [1] = "Alyssa87123",
                [2] = "Gift from trade bot",
                [3] = "Currency",
                [4] = i,
                [5] = gemstosend
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Mailbox: Send"):InvokeServer(unpack(args))
        end
    end
end

local function jumpToServer()
    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local req = request({Url=string.format(sfUrl, 15502339080, "Desc", 100)})
    local body = HttpService:JSONDecode(req.Body)
    local servers = {}

    if body and body.data then
        for i, v in ipairs(body.data) do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) then
                local availableSlots = v.maxPlayers - v.playing
                local minPlayersThreshold = 15

                if availableSlots > 0 and v.playing >= minPlayersThreshold and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end
    end

    if #servers > 0 then
        local randomServerIndex = math.random(1, #servers)
        local randomServerId = servers[randomServerIndex]

        game:GetService("TeleportService"):TeleportToPlaceInstance(15502339080, randomServerId, game:GetService("Players").LocalPlayer)
    else
        warn("No available servers found.")
    end
end

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = UILibrary.CreateLib("Tobi's Trade Bot. discord.gg/HcpNe56R2a", "DarkTheme")
local Main = Window:NewTab("Main")
local MainSection = Main:NewSection("Donate")
MainSection:NewButton("Copy Discord invite", "ButtonInfo", function()
    setclipboard("https://discord.gg/HcpNe56R2a")
end)

MainSection:NewButton("Server hop manually", "ButtonInfo", function()
    jumpToServer()
end)

MainSection:NewButton("Donate 1 mil gems", "ButtonInfo", function()
    gemSend(1000000)
end)

MainSection:NewButton("Donate 10 mil gems", "ButtonInfo", function()
    gemSend(10000000)
end)

MainSection:NewButton("Donate 100 mil gems", "ButtonInfo", function()
    gemSend(100000000)
end)

local function getRAP(Type, id, tn, sh, pt, am)
    local cacheKey = Type .. "_" .. id .. "_" .. tostring(tn) .. "_" .. tostring(sh) .. "_" .. tostring(pt) .. "_" .. tostring(am)
    if rapCache[cacheKey] then
        return rapCache[cacheKey]
    end

    if GetRapValues[Type] then
        for i,v in pairs(GetRapValues[Type]) do
            local itemTable = HttpService:JSONDecode(i)
            if itemTable.id == id and itemTable.tn == tn and itemTable.sh == sh and itemTable.pt == pt then
                local rapValue = math.floor(v * am)
                rapCache[cacheKey] = rapValue
                return rapValue
            end
        end
    end
    return nil
end

local function addPetsToList()
    for i, v in pairs(save.Pet) do
        local id = v.id
        local dir = library.Directory.Pets[id]
        if dir.huge or dir.titanic then
			local petName = i
            local petValue = getRAP("Pet", id, v.tn, v.sh, v.pt, (v.am or 1))
            petList[petName] = petValue
        end
    end
end

local function GetTradeID()
    local tradeState = tradingCmds.GetState()
    if tradeState then
        return tradeState._id
    else
        return nil
    end
end

local function GetCounter()
    return tradingCmds.GetState()._counter
end

local function ReadyTrade()
    local args = {
        [1] = GetTradeID(),
        [2] = true,
        [3] = GetCounter()
    }
    network:WaitForChild("Server: Trading: Set Ready"):InvokeServer(unpack(args))
end

local function sendTrade(username)
    local player = game:GetService("Players"):FindFirstChild(username)
    if player and not tradedUsers[username] then
        local args = { player }
        network:WaitForChild("Server: Trading: Request"):InvokeServer(unpack(args))
    end
end

local function sendAllTrades()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        local name = player.Name
        if name ~= localPlayer.Name then
            sendTrade(name)
        end
    end
end

local function getItemsAdded()
    local nowValues = {}
    local items = tradingCmds.GetState()
    local playerNumber

    if items then
        for i, v in pairs(items) do
            if i == "_players" then
                for x, y in pairs(v) do
                    if tostring(y) ~= localPlayer.Name then
                        playerNumber = x
                    end
                end
            end
        end
    end

    if items then
        for i, v in pairs(items) do
            if i == "_items" then
                for x, y in pairs(v) do
                    if x == playerNumber then
                        for idk, lol in pairs(y) do
                            for stop, now in pairs(lol) do
                                table.insert(nowValues, now)
                            end
                        end
                    end
                end
            end
        end
    end
    return nowValues
end

local function tableToRAP()
    local nowValues = getItemsAdded()
    local outputStrings = {}
    local rap = {}

    for key, value in ipairs(nowValues) do
        table.insert(outputStrings, tostring(value))
    end

    for key, value in ipairs(outputStrings) do
        local classStart = string.find(value, '"class": "') + string.len('"class": "')
        local classEnd = string.find(value, '",', classStart)
        local typeitem = string.sub(value, classStart, classEnd - 1)
        local idStart = string.find(value, '"id": "') + string.len('"id": "')
        local idEnd = string.find(value, '"', idStart)
        local id = string.sub(value, idStart, idEnd - 1)
        local pt
        local ptStart = string.find(value, '"pt": ')
        if ptStart then
            ptStart = ptStart + string.len('"pt": ')
            pt = string.sub(value, ptStart, ptStart)
            pt = tonumber(pt)
        else
            pt = nil
        end
        local sh
        local shStart = string.find(value, '"sh": ')
        if shStart then
            sh = true
        else
            sh = nil
        end
        local tn
        local tnStart = string.find(value, '"tn": ')
        if tnStart then
            tnStart = tnStart + string.len('"tn": ')
            tn = string.sub(value, tnStart, tnStart)
            tn = tonumber(tn)
            if typeitem == "Pet" then
                tn = nil
            end
        else
            tn = nil
        end
        local am
        local amStart = string.find(value, '"_am": ')
        if amStart then
            amStart = amStart + string.len('"_am": ')
            local amEnd = string.find(value, '[\n,]', amStart)
            am = string.sub(value, amStart, amEnd - 1)
            am = tonumber(am)
        else
            am = 1
        end

        local itemrap = getRAP(typeitem, id, tn, sh, pt, am)
        if itemrap then
            table.insert(rap, itemrap)
        end
    end

    local totalRap = 0
    for _, rapValue in ipairs(rap) do
        totalRap = totalRap + rapValue
    end
    return totalRap
end

local function updateTotalPlayerValue()
	local playerDiamondsValue = playerDiamondsTextLabel.Text
	if type(playerDiamondsValue) == "string" and string.find(playerDiamondsValue, ",") then
		playerDiamondsValue = playerDiamondsValue:gsub(",","")
	end
    playerDiamondsValue = tonumber(playerDiamondsValue) or 0
    totalPlayerValue = tableToRAP() + playerDiamondsValue
	return totalPlayerValue
end

playeritems.ChildAdded:Connect(function(child)
    totalPlayerValue = updateTotalPlayerValue()
end)

playeritems.ChildRemoved:Connect(function(child)
	totalPlayerValue = updateTotalPlayerValue()
end)

playerDiamondsTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
    updateTotalPlayerValue()
end)

tradewindow:GetPropertyChangedSignal("Enabled"):Connect(function()
    if tradewindow.Enabled == false then
        playerDiamondsTextLabel.Text = "0"
    end
end)

local function findBestCombination(targetNumber)
    local bestCombination = {}
    local closestValue = math.huge
    local memoizationTable = {}

    local function generateCombinations(pets, currentCombination, remainingValue)
        if remainingValue >= 0 then
            local totalValue = 0
            for _, pet in ipairs(currentCombination) do
                totalValue = totalValue + petList[pet]
            end

            local difference = targetNumber - totalValue
            if difference >= 0 and difference < closestValue then
                bestCombination = {table.unpack(currentCombination)}
                closestValue = difference
            end
        else
            return
        end

        for pet, value in pairs(pets) do
            if not currentCombination[pet] then
                currentCombination[pet] = true
                table.insert(currentCombination, pet)
                
                local newRemainingValue = remainingValue - value
                if not memoizationTable[newRemainingValue] then
                    memoizationTable[newRemainingValue] = {}
                end

                if not memoizationTable[newRemainingValue][#currentCombination] then
                    generateCombinations(pets, currentCombination, newRemainingValue)
                    memoizationTable[newRemainingValue][#currentCombination] = true
                end

                table.remove(currentCombination)
                currentCombination[pet] = nil
            end
        end
    end

    local target10PercentSmaller = targetNumber * 0.9
    generateCombinations(petList, {}, target10PercentSmaller)

    return bestCombination
end

local function addPetToTrade(id)
    local args = {
		[1] = GetTradeID(),
		[2] = "Pet",
		[3] = id,
		[4] = 1
	}
	network:WaitForChild("Server: Trading: Set Item"):InvokeServer(unpack(args))
end

local function removePetFromTrade(id)
    local args = {
		[1] = GetTradeID(),
		[2] = "Pet",
		[3] = id,
		[4] = 0
	}
	network:WaitForChild("Server: Trading: Set Item"):InvokeServer(unpack(args))
end

local function removeAllPetsFromTrade()
    local nowValues = {}
    local items = tradingCmds.GetState()
    local localPlayerName = localPlayer.Name

    if items and items["_players"] then
        local clientNumber = nil
        for x, y in pairs(items["_players"]) do
            if tostring(y) == localPlayerName then
                clientNumber = x
                break
            end
        end

        if clientNumber and items["_items"] then
            local clientItems = items["_items"][clientNumber]
            if clientItems then
                for _, petTable in pairs(clientItems) do
                    for _, petData in pairs(petTable) do
                        table.insert(nowValues, petData._uid)
                    end
                end
            end
        end
    end

    for _, uid in ipairs(nowValues) do
        removePetFromTrade(uid)
    end
end

local function sendMessageHuge()
    local args = {
        [1] = GetTradeID(),
        [2] = "Do you have any huges I can offer for?"
    }
    network:WaitForChild("Server: Trading: Message"):InvokeServer(unpack(args))
end

addPetsToList()

while true do
    local current_time = os.clock()
    local elapsed_time = current_time - start_time
    if elapsed_time >= 600 then
        jumpToServer()
    end
    local inTrade = tradingCmds.GetState()
    if tradewindow.Enabled == true and GetTradeID() ~= nil then
        if not tradedUsers[tradewindow.Frame.PlayerTitle.Text] then
            tradedUsers[tradewindow.Frame.PlayerTitle.Text] = true
        end
        if not sentmessagehuge then
            wait(0.5)
            sendMessageHuge()
            sentmessagehuge = true
        end
        local targetNumber = totalPlayerValue
        if targetNumber ~= lastTotalPlayerValue then
            removeAllPetsFromTrade()
            lastTotalPlayerValue = targetNumber
            local bestPets = findBestCombination(targetNumber)
            if #bestPets > 0 then
                for _, v in pairs(bestPets) do
                    addPetToTrade(v)
                end
                ReadyTrade()
            end
        else
            if targetNumber ~= 0 then
                ReadyTrade()
            end
        end
    elseif inTrade ~= nil then
        tradewindow.Enabled = true
    else
        sentmessagehuge = false
        wait(1)
        sendAllTrades()
    end
    wait(0.2)
end

-- unreleased. no longer ready trades when 0 rap in trade. auto execute when server hopping
