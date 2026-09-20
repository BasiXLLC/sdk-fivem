--- `/basix test`
---
--- Exists because the first question after installing anything is "did that
--- work", and the honest answer needs a round trip. It uploads a one-pixel
--- image and prints the URL, so a wrong key, a typo in the endpoint and a
--- firewall all produce different, readable failures instead of silence.

local PIXEL =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=='

RegisterCommand('basix', function(source, args)
    -- Console only: this prints a URL and touches the account's quota.
    if source ~= 0 then return end

    if args[1] ~= 'test' then
        print('^3[basix]^7 usage: basix test')
        return
    end

    if not BasiX.configured() then
        print('^1[basix]^7 basix_key is missing or malformed in server.cfg.')
        print('       set basix_key "bx_live_..."   (create one in your client area)')
        return
    end

    print('^7[basix] uploading a test image to ' .. BasiX.endpoint() .. ' ...')
    BasiX.upload({ data = PIXEL, name = 'basix-test.png', folder = 'basix-test' }, function(err, file)
        if err then
            print('^1[basix]^7 failed: ' .. tostring(err))
            return
        end
        print('^2[basix]^7 working. ' .. file.url)
        print('       Delete it from your client area whenever you like.')
    end)
end, true)

CreateThread(function()
    Wait(2000)
    if not BasiX.configured() then
        print('^3[basix]^7 no basix_key set — uploads and logs are disabled.')
        print('       set basix_key "bx_live_..." in server.cfg, then: /basix test')
    end
end)
