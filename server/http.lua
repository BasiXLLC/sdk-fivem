--- Shared HTTP plumbing.
---
--- One place that knows the endpoint, the key and how this server talks to
--- BasiX, so the three callers below cannot drift apart on retries, headers
--- or error shapes.

BasiX = BasiX or {}

local function convar(name, fallback)
    local value = GetConvar(name, fallback or '')
    if value == '' then return fallback end
    return value
end

function BasiX.endpoint()
    return (convar('basix_endpoint', 'https://upload.basix.agency')):gsub('/+$', '')
end

function BasiX.key()
    return convar('basix_key', '')
end

function BasiX.folder()
    return (convar('basix_folder', '')):gsub('^/+', ''):gsub('/+$', '')
end

--- Is the resource usable at all?
---
--- Checked on every call rather than once at boot: a server operator who sets
--- the convar and does `refresh` without restarting should not have to work
--- out why nothing happens.
function BasiX.configured()
    local key = BasiX.key()
    return key ~= '' and key:sub(1, 8) == 'bx_live_'
end

--- POSTs JSON and hands back a decoded body.
---
--- Retries on a 5xx and on a transport failure, never on a 4xx: a refused
--- request is refused for a reason, and repeating it just moves the same
--- error later. Three attempts with a widening pause, because the common
--- failure here is a momentary blip rather than a broken server.
function BasiX.postJson(path, body, cb, attempt)
    attempt = attempt or 1

    if not BasiX.configured() then
        return cb('basix_key is not set in server.cfg', nil)
    end

    PerformHttpRequest(BasiX.endpoint() .. path, function(status, text)
        if status >= 200 and status < 300 then
            local ok, decoded = pcall(json.decode, text)
            return cb(nil, ok and decoded or nil)
        end

        if status >= 500 or status == 0 then
            if attempt < 3 then
                SetTimeout(attempt * 750, function()
                    BasiX.postJson(path, body, cb, attempt + 1)
                end)
                return
            end
        end

        -- The API answers with the same text under `error` and `message`, so
        -- either is safe to read; the code is what a caller should branch on.
        local ok, decoded = pcall(json.decode, text or '')
        local message = ok and decoded and (decoded.error or decoded.message) or nil
        cb(message or ('HTTP ' .. tostring(status)), ok and decoded or nil)
    end, 'POST', json.encode(body), {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bearer ' .. BasiX.key(),
    })
end

--- Joins the configured prefix to a per-call folder.
--- Spaces and capitals are fine: the server repairs them.
function BasiX.destination(folder)
    local base = BasiX.folder()
    folder = folder and folder:gsub('^/+', ''):gsub('/+$', '') or ''
    if base ~= '' and folder ~= '' then return base .. '/' .. folder .. '/' end
    if base ~= '' then return base .. '/' end
    if folder ~= '' then return folder .. '/' end
    return nil
end
