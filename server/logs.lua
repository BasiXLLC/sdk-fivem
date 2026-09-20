--- Structured logs.
---
--- Buffered and flushed on a timer rather than sent one per call. A busy
--- roleplay server produces several log lines per player action; one HTTP
--- request each would spend more time on connections than on the game, and
--- would hit the per-key rate limit within a minute of a busy evening.

local LEVELS = { trace = 10, debug = 20, info = 30, warn = 40, error = 50, fatal = 60 }
local FLUSH_MS = 2000
local MAX_BUFFER = 400

local buffer = {}
local flushing = false

local function minimumLevel()
    return LEVELS[(GetConvar('basix_log_level', 'info')):lower()] or LEVELS.info
end

local function flush()
    if flushing or #buffer == 0 then return end
    if not BasiX.configured() then
        -- Drop rather than grow without limit. A server left unconfigured for
        -- a week must not accumulate a week of events in memory.
        buffer = {}
        return
    end

    flushing = true
    local batch = buffer
    buffer = {}

    BasiX.postJson('/api/v1/logs', {
        dataset = GetConvar('basix_dataset', 'default'),
        events = batch,
    }, function(err)
        flushing = false
        if err then
            -- Put them back only if there is room; otherwise the newest win.
            -- An unreachable API must not turn into unbounded memory.
            if #buffer + #batch <= MAX_BUFFER then
                for i = #batch, 1, -1 do table.insert(buffer, 1, batch[i]) end
            else
                print('^3[basix]^7 dropped ' .. #batch .. ' log events: ' .. tostring(err))
            end
        end
    end)
end

function BasiX.log(level, message, options)
    options = options or {}
    level = (level or 'info'):lower()

    if (LEVELS[level] or LEVELS.info) < minimumLevel() then return end
    if not message or message == '' then return end

    if #buffer >= MAX_BUFFER then
        -- Full: drop the oldest. Losing the start of a burst beats losing the
        -- end, because the end is what you are looking at when it breaks.
        table.remove(buffer, 1)
    end

    buffer[#buffer + 1] = {
        level = level,
        message = tostring(message),
        player = options.player and tostring(options.player) or nil,
        resource = options.resource or GetInvokingResource() or nil,
        metadata = options.metadata,
    }
end

CreateThread(function()
    while true do
        Wait(FLUSH_MS)
        flush()
    end
end)

-- Anything buffered when the resource stops would otherwise be lost, and a
-- crash is exactly when the last few lines matter most.
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then flush() end
end)
