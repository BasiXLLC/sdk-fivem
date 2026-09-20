--- The public surface.
---
--- Named for what they do rather than after anyone else's SDK. A migration
--- guide is a page; a function name is a permanent decision, and borrowing a
--- competitor's is the kind of thing that is cheap on day one and awkward for
--- as long as the resource exists.

local pending = {}

--- Captures a player's screen and uploads it.
---
--- The bytes go from that player straight to storage: they never cross this
--- server's uplink, which is the resource this is actually short of. The key
--- stays here.
function BasiX.screenshot(source, options, cb)
    options = options or {}
    cb = cb or function() end

    if GetResourceState('screenshot-basic') ~= 'started' then
        return cb('screenshot-basic is not running', nil)
    end

    BasiX.presign({ type = 'image', folder = options.folder }, function(err, url)
        if err then return cb(err, nil) end

        local ref = tostring(math.random(1, 1e9)) .. '-' .. tostring(source)
        pending[ref] = cb

        -- A player who disconnects mid-capture never answers. Without this
        -- the callback is held for ever and the caller waits for ever.
        SetTimeout(30000, function()
            if pending[ref] then
                pending[ref] = nil
                cb('the player did not answer in time', nil)
            end
        end)

        TriggerClientEvent('basix:capture', source, url, {
            ref = ref,
            encoding = options.encoding,
            quality = options.quality,
        })
    end)
end

RegisterNetEvent('basix:captured', function(ref, body)
    local cb = pending[ref]
    if not cb then return end
    pending[ref] = nil

    local url = body and (body.url or (body.data and body.data.url))
    if not url then return cb('the upload failed', nil) end
    cb(nil, { url = url, id = body.id or (body.data and body.data.id), path = body.path })
end)

exports('screenshot', BasiX.screenshot)
exports('upload', BasiX.upload)
exports('presign', BasiX.presign)
exports('log', BasiX.log)

--- Sugar, because these four are most of the real usage.
exports('info', function(message, options) BasiX.log('info', message, options) end)
exports('warn', function(message, options) BasiX.log('warn', message, options) end)
exports('error', function(message, options) BasiX.log('error', message, options) end)
exports('debug', function(message, options) BasiX.log('debug', message, options) end)
