--- Client-side capture.
---
--- The client never sees the API key. It receives a short-lived upload URL,
--- posts the bytes to it, and the URL dies on first use — so a player who
--- reads it out of memory gets one upload into a folder the server chose,
--- and nothing else.

RegisterNetEvent('basix:capture', function(token, options)
    options = options or {}

    exports['screenshot-basic']:requestScreenshotUpload(token, 'file', {
        encoding = options.encoding or 'jpg',
        quality = options.quality or 0.85,
    }, function(response)
        local ok, decoded = pcall(json.decode, response)
        TriggerServerEvent('basix:captured', options.ref, ok and decoded or nil)
    end)
end)
