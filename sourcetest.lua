local request = http_request or request or HttpPost or syn.request
local url = "https://123demands.com/_next/data/C0OlgVHk5UcRPbBPtRDVM/Pet-Simulator-99-Values.json"
local jsonContent
local totalPlayerValue = 0
local playerPetValues = {}
local localPlayer = game:GetService("Players").LocalPlayer
local tradewindow = localPlayer.PlayerGui.TradeWindow
local playeritems = tradewindow.Frame.PlayerItems.Items
local playerDiamondsTextLabel = tradewindow.Frame.PlayerDiamonds.TextLabel
local previousPlayerGemValue = 0

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
		if jsonContent then
			local petValue = getValueFromURL(jsonContent, string.lower(title), variant)
			petValue = convertStringToNumber(petValue)
			totalPlayerValue = totalPlayerValue + petValue
			playerPetValues[item] = petValue
		end
    end
end)

playeritems.ChildRemoved:Connect(function(child)
	local petValue = playerPetValues[child] or 0
	totalPlayerValue = totalPlayerValue - petValue
	playerPetValues[child] = nil
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
    updateTotalPlayerValue()
end)

local player = game.Players.LocalPlayer
local playerGui = player.PlayerGui
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
local textBox = Instance.new("TextBox")
textBox.Name = "TotalPlayerValueTextBox"
textBox.Size = UDim2.new(0, 200, 0, 50)
textBox.Position = UDim2.new(1, -220, 1, -70)
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.BorderSizePixel = 2
textBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
textBox.TextScaled = true
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.Text = "Total Player Value: 0"
textBox.Parent = screenGui
textBox.TextEditable = false

local function updateTotalPlayerValueUI()
    local formattedValue = tostring(totalPlayerValue)
    local parts = {}

    while #formattedValue > 3 do
        table.insert(parts, 1, formattedValue:sub(-3))
        formattedValue = formattedValue:sub(1, -4)
    end

    table.insert(parts, 1, formattedValue)
    textBox.Text = "Total Player Value: " .. table.concat(parts, ",")
end

updateTotalPlayerValueUI()
game:GetService("RunService").Heartbeat:Connect(updateTotalPlayerValueUI)

local UserInputService = game:GetService("UserInputService")
local dragging
local dragInput
local dragStart
local startPos

textBox.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = textBox.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

textBox.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        textBox.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
