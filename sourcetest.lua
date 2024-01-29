local request = http_request or request or HttpPost or syn.request
local url = "https://123demands.com/_next/data/C0OlgVHk5UcRPbBPtRDVM/Pet-Simulator-99-Values.json"

local function searchTableForString(tbl, searchString)
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            searchTableForString(value, searchString)
        elseif type(value) == "string" then
            local gemValue = string.find(value, searchString)
            if gemValue then
                print("Key:", key)
                print("Value:", value)
            end
        end
    end
end

local allPets = request({
    Url = url,
    Method = "GET"
})

if allPets.Success and allPets.Body then
    local jsonContent = game.HttpService:JSONDecode(allPets.Body)
else
    print("Failed to retrieve data from the URL")
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

local localPlayer = game:GetService("Players").LocalPlayer
local tradewindow = localPlayer.PlayerGui.TradeWindow
local playeritems = tradewindow.Frame.PlayerItems.Items

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
			searchTableForString(jsonContent, string.lower(title))
		else
			print("JSON content is nil")
		end
    end
end)
