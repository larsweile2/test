local request = http_request or request or HttpPost or syn.request
local url = "https://123demands.com/_next/data/C0OlgVHk5UcRPbBPtRDVM/Pet-Simulator-99-Values.json"
local jsonContent
local totalClientValue = 0
local totalPlayerValue = 0
local playerPetValues = {}
local clientPetValues = {}
local localPlayer = game:GetService("Players").LocalPlayer
local tradewindow = localPlayer.PlayerGui.TradeWindow
local playeritems = tradewindow.Frame.PlayerItems.Items
local clientitems = tradewindow.Frame.PlayerItems.Items
local clientDiamondsTextLabel = tradewindow.Frame.ClientDiamonds.Diamonds.Input
local playerDiamondsTextLabel = tradewindow.Frame.PlayerDiamonds.TextLabel
local previousPlayerGemValue = 0
local previousClientGemValue = 0

local function getValueFromURL(tbl, searchString, variant)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            getValueFromURL(value, searchString, variant)
        elseif type(value) == "string" then
            local findstring = string.find(value, searchString)
            if findstring then
				local shit = tbl["variant"]
				if string.find(shit, "shiny") then
					shit = string.gsub(shit, "shiny ", "shiny")
				end
				if shit == variant then
					gem_value = tbl["gem_value"]
					if gem_value == "N/A" then
						gem_value = 0
					end
				end
            end
        end
    end
	return gem_value or 0
end

function convertStringToNumber(str)
    local numPart, unit = str:match("([%d.]+)(%a)")
    local num = tonumber(numPart)
    local conversionFactors = {
		b = 1e9,
        m = 1e6,
        k = 1e3,
    }

    if conversionFactors[unit] then
        return num * conversionFactors[unit]
    else
        return nil
    end
end

local allPets = request({
    Url = url,
    Method = "GET"
})

if allPets.Success and allPets.Body then
    jsonContent = game.HttpService:JSONDecode(allPets.Body)
end


local function getPetFromURL(imageURL, hasShinePulse, isRainbow)
    local url = "https://www.roblox.com/library/" .. imageURL
	local variant = ""

    local response = request({
        Url = url,
        Method = "GET"
    })

    if response.Success then
        local title = response.Body:match("<title>(.-)%s- %- Roblox</title>")
        if title then
            if title:find("Images/") then
                title = title:gsub("Images/", "")
			end
			if title:find("(1)") then
				title = title:gsub(" %(1%)", "")
			end
			if title:find("(Golden)") then
                title = title:gsub(" %(Golden%)", "")
				variant = "golden"
            end
			if isRainbow then
				variant = "rainbow"
			end
			if hasShinePulse then
				variant = "shiny" .. variant
			end
			if variant == "" then
				variant = "normal"
			end
            return title, variant
        end
    end
    return nil
end

playeritems.ChildAdded:Connect(function(child)
    local item = child
    local icon = item.Icon.Image
    local imageURL = icon:match("://(.*)")
	local hasShinePulse = false
	local isRainbow = false
	
	if item:FindFirstChild("ShinePulse") then
		hasShinePulse = true
	end
	if item.Icon:FindFirstChild("RainbowIcon") then
		isRainbow = true
	end

    local title, variant = getPetFromURL(imageURL, hasShinePulse, isRainbow)
    if title then
        print("This is a:", title, "its variant is", variant)
		if jsonContent then
			local petValue = getValueFromURL(jsonContent, string.lower(title), variant)
			petValue = convertStringToNumber(petValue)
			print("Pet Value:", petValue)
			totalPlayerValue = totalPlayerValue + petValue
			playerPetValues[item] = petValue
			print("Total Player Value:", totalPlayerValue)
		end
    end
end)

playeritems.ChildRemoved:Connect(function(child)
	print("A pet has been removed from the trade")
	local petValue = playerPetValues[child] or 0
	totalPlayerValue = totalPlayerValue - petValue
	playerPetValues[child] = nil
	print("Total player value:", totalPlayerValue)
end)

local function updateTotalPlayerValue()
	local playerDiamondsValue = playerDiamondsTextLabel.Text
	if type(playerDiamondsValue) == "string" and string.find(playerDiamondsValue, ",") then
		playerDiamondsValue = playerDiamondsValue:gsub(",","")
	end
    playerDiamondsValue = tonumber(playerDiamondsValue) or 0
    totalPlayerValue = totalPlayerValue - previousPlayerGemValue + playerDiamondsValue
	previousPlayerGemValue = playerDiamondsValue
	return totalPlayerValue
end

playerDiamondsTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
    print("Total player value:", updateTotalPlayerValue())
end)


-- -------------


clientitems.ChildAdded:Connect(function(child)
    local item = child
    local icon = item.Icon.Image
    local imageURL = icon:match("://(.*)")
	local hasShinePulse = false
	local isRainbow = false
	
	if item:FindFirstChild("ShinePulse") then
		hasShinePulse = true
	end
	if item.Icon:FindFirstChild("RainbowIcon") then
		isRainbow = true
	end

    local title, variant = getPetFromURL(imageURL, hasShinePulse, isRainbow)
    if title then
        print("This is a:", title, "its variant is", variant)
		if jsonContent then
			local petValue = getValueFromURL(jsonContent, string.lower(title), variant)
			petValue = convertStringToNumber(petValue)
			print("Pet Value:", petValue)
			totalClientValue = totalClientValue + petValue
			clientPetValues[item] = petValue
			print("Total Client Value:", totalClientValue)
		end
    end
end)

clientitems.ChildRemoved:Connect(function(child)
	print("A pet has been removed from the trade")
	local petValue = clientPetValues[child] or 0
	totalClientValue = totalClientValue - petValue
	clientPetValues[child] = nil
	print("Total client value:", totalClientValue)
end)

local function updateTotalClientValue()
	local clientDiamondsValue = clientDiamondsTextLabel.Text
	if type(clientDiamondsValue) == "string" and string.find(clientDiamondsValue, ",") then
		clientDiamondsValue = clientDiamondsValue:gsub(",","")
	end
    clientDiamondsValue = tonumber(clientDiamondsValue) or 0
    totalClientValue = totalClientValue - previousClientGemValue + clientDiamondsValue
	previousClientGemValue = clientDiamondsValue
	return totalClientValue
end

clientDiamondsTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
    print("Total client value:", updateTotalClientValue())
end)
