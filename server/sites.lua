local SYNC_MS = 60000

local function enabled()
    return BasiX.configured() and GetConvar('basix_sites', 'true') ~= 'false'
end

local function playerIp(src)
    local identifier = GetPlayerIdentifierByType(src, 'ip')
    local ip = identifier and identifier:gsub('^ip:', '') or GetPlayerEndpoint(src)
    if not ip or ip == '' then return nil end
    return (ip:gsub('^(%d+%.%d+%.%d+%.%d+):%d+$', '%1'))
end

local function connectedIps(except)
    local ips, seen = {}, {}
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        if src ~= except then
            local ip = playerIp(src)
            if ip and not seen[ip] then
                seen[ip] = true
                ips[#ips + 1] = ip
            end
        end
    end
    return ips, seen
end

local function send(body)
    if not enabled() then return end
    BasiX.postJson('/api/v1/sites/access', body, function(err)
        if err then print(('^3[basix] site access: %s^0'):format(err)) end
    end)
end

AddEventHandler('playerConnecting', function()
    local ip = playerIp(source)
    if ip then send({ grant = { ip } }) end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local ip = playerIp(src)
    if not ip then return end
    local _, still = connectedIps(src)
    if not still[ip] then send({ revoke = { ip } }) end
end)

CreateThread(function()
    while true do
        local ips = connectedIps(nil)
        send({ sync = ips })
        Wait(SYNC_MS)
    end
end)
