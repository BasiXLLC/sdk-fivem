# basix

Upload screenshots, clips and structured logs from your FiveM server.

## Install

1. Drop this folder in `resources/`.
2. Add your key to `server.cfg`:

```cfg
set basix_key "bx_live_yourkeyhere"
ensure basix
```

Create the key in your client area. Use an **upload-scoped** key: it works on
every plan including the free one, and it cannot delete anything — which is
what you want in a file that lives in a resource folder.

3. Check it:

```
/basix test
```

## Use it

```lua
-- A player's screen, uploaded, URL back.
exports.basix:screenshot(source, { folder = 'reports' }, function(err, file)
    if err then return print('^1[basix]^7 ' .. err) end
    print(file.url)
end)

-- Anything already on disk or in memory.
exports.basix:upload({ data = bytes, name = 'clip.mp4', folder = 'clips' }, cb)

-- A structured log line.
exports.basix:log('warn', 'Suspicious money add', {
    player = GetPlayerIdentifier(source, 0),
    metadata = { amount = 999999 },
})
```

Every call is server-side. The key never reaches a client.

## Migrating

Already using another provider? Point it here instead — the endpoints and the
response shape are the same. See `basix.agency/docs/integrations`.

## Convars

| Convar | Default | |
|---|---|---|
| `basix_key` | — | required |
| `basix_folder` | `` | prefix for every upload |
| `basix_dataset` | `default` | log stream name |
| `basix_log_level` | `info` | minimum level actually sent |
| `basix_endpoint` | `https://upload.basix.agency` | for testing only |
