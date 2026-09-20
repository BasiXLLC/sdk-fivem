--- Uploads.
---
--- Two routes, and the resource picks for you:
---
---   * a presigned URL when the bytes are on a PLAYER's machine, so they
---     travel from that player straight to storage and never cross your
---     server's uplink — which is the thing a 200-slot server is short of;
---   * a direct multipart POST when the bytes are already here.
---
--- Either way the key stays on the server. It is never sent to a client.

--- Asks for a short-lived upload URL a client can use without credentials.
function BasiX.presign(options, cb)
    options = options or {}
    BasiX.postJson('/api/v3/file/presigned-url', {
        type = options.type or 'image',
        path = BasiX.destination(options.folder),
    }, function(err, body)
        if err then return cb(err, nil) end
        local url = body and (body.presignedUrl or (body.data and body.data.presignedUrl))
        if not url then return cb('no upload URL in the response', nil) end
        cb(nil, url)
    end)
end

--- Uploads bytes that are already on the server.
---
--- `data` is a base64 string or a data URI; both are accepted, because
--- screenshot-basic hands you one and most other things hand you the other.
function BasiX.upload(options, cb)
    options = options or {}
    cb = cb or function() end

    if not options.data then return cb('nothing to upload', nil) end

    BasiX.postJson('/api/v3/file/base64', {
        base64 = options.data,
        filename = options.name,
        path = BasiX.destination(options.folder),
        metadata = options.metadata and json.encode(options.metadata) or nil,
        retentionExempt = options.keep and true or nil,
    }, function(err, body)
        if err then return cb(err, nil) end
        -- The response carries the URL at the top level and under `data`;
        -- reading both means this keeps working whichever one is populated.
        local url = body and (body.url or (body.data and body.data.url))
        if not url then return cb('no URL in the response', nil) end
        cb(nil, {
            url = url,
            id = body.id or (body.data and body.data.id),
            path = body.path,
            size = body.size,
        })
    end)
end
