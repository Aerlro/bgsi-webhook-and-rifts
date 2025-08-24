local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Webhook-ul tău
local WEBHOOK_URL = "https://discord.com/api/webhooks/1407847455902662768/xWn94IDXW-ExWhJ0JGX5GF9Uefa9vOAzea2qNMJKVMbKq9yXE9ZHiLxFNX_dpft_XB1S"

-- Modulul Pets
local petsModule = require(ReplicatedStorage.Shared.Data.Pets)
local secretBountyUtil = require(ReplicatedStorage.Shared.Utils.Stats:WaitForChild("SecretBountyUtil"))

-- Funcție pentru obținerea asset-ului de imagine al petului (varianta Normal)
local function getPetImageLink(petName)
    local petEntry = petsModule[petName]
    if not petEntry or not petEntry.Images then return nil end
    local assetStr = petEntry.Images["Normal"]
    local assetId = assetStr and assetStr:match("%d+")
    return assetId and ("https://ps99.biggamesapi.io/image/" .. assetId) or nil
end

-- Funcție pentru formatat numere cu virgule
local function formatNumber(n)
    local str = tostring(math.floor(n))
    return str:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

-- Funcție pentru afișat șansa ca "1 in X"
local function formatChance(chance)
    if not chance or chance <= 0 then
        return "N/A"
    end
    local inv = math.floor((1 / chance) * 100 + 0.5)
    return "1 in " .. formatNumber(inv)
end

-- Obține bounty actual
local function getBounty()
    return secretBountyUtil:Get()
end

-- Trimite embed la Discord
local function sendBountyEmbed()
    local current = getBounty()
    local chanceFormatted = formatChance(current.Chance)
    local petImage = getPetImageLink(current.Name)

    -- Timpul următorului bounty (00:00 UTC = 03:00 România)
    local now = os.time()
    local tomorrowMidnightUTC = os.time(os.date("!*t", now))
    tomorrowMidnightUTC = tomorrowMidnightUTC - (tomorrowMidnightUTC % 86400) + 86400

    local embed = {
        title = "🎯 Secret Bounty",
        color = 16777215,
        fields = {
            { name = "Pet", value = current.Name, inline = true },
            { name = "Egg", value = current.Egg, inline = true },
            { name = "Chance", value = chanceFormatted, inline = true },
            { name = "Next", value = string.format("<t:%d:R>", tomorrowMidnightUTC), inline = false }
        },
        image = { url = petImage or "" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", now)
    }

    local payload = HttpService:JSONEncode({ embeds = { embed } })

    http_request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = payload
    })
end

-- === La pornire trimite embed-ul imediat
sendBountyEmbed()

-- === Apoi calculează cât timp e până la ora 03:00 România (00:00 UTC)
while true do
    local now = os.time()
    local utcNow = os.date("!*t", now)

    -- calculăm următorul 00:00 UTC
    local nextMidnightUTC = os.time({
        year = utcNow.year,
        month = utcNow.month,
        day = utcNow.day,
        hour = 0,
        min = 0,
        sec = 0
    })
    if nextMidnightUTC <= now then
        nextMidnightUTC = nextMidnightUTC + 86400
    end

    local secondsToWait = nextMidnightUTC - now
    task.wait(secondsToWait)

    -- Trimite fix la 03:00 România
    sendBountyEmbed()

    -- După aceea, rulează la fiecare 24h
    while true do
        task.wait(86400)
        sendBountyEmbed()
    end
end
