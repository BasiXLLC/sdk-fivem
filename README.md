# BasiX for FiveM — image hosting, screenshot upload and logs

The official [BasiX](https://basix.agency/?utm_source=github&utm_medium=referral&utm_campaign=sdk-fivem) resource for FiveM servers. Upload player screenshots, clips and any file from the server side, get a permanent CDN link back, and send structured logs you can search in your dashboard.

- **Screenshot upload** through `screenshot-basic`, with the key kept on the server.
- **Media hosting**: images, videos and audio on links that don't expire, unlike Discord attachment links.
- **Logs** with levels, players and metadata, filterable per player.
- **Player-only hosted sites** for `ui_page` (NUI) served from BasiX.
- **Drop-in migration** from Fivemanage and Fivemerr: same endpoints, same response shape.

Free tier, bandwidth never billed. Docs: [basix.agency/docs](https://basix.agency/docs?utm_source=github&utm_medium=referral&utm_campaign=sdk-fivem)

## Install

1. Download `basix.zip` from the [latest release](https://github.com/BasiXLLC/sdk-fivem/releases/latest) and unzip it in `resources/`.
2. Add your key to `server.cfg`:

```cfg
set basix_key "bx_live_yourkeyhere"
ensure screenshot-basic
ensure basix
```

Create the key in your [client area](https://basix.agency/?utm_source=github&utm_medium=referral&utm_campaign=sdk-fivem). Use an **upload-scoped** key: it works on
every plan including the free one, and it cannot delete anything — which is
what you want in a file that lives in a resource folder.

3. Check it from the server console:

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

-- A presigned URL, for a client to upload directly without seeing your key.
exports.basix:presign({ type = 'image', folder = 'phone' }, cb)

-- A structured log line.
exports.basix:log('warn', 'Suspicious money add', {
    player = GetPlayerIdentifier(source, 0),
    metadata = { amount = 999999 },
})

-- Shorthands: info, warn, error, debug.
exports.basix:info('Player joined', { player = GetPlayerIdentifier(source, 0) })
```

Every call is server-side. The key never reaches a client.

## Hosted sites

Point a resource at a site hosted on BasiX:

```lua
ui_page 'https://your-site.sites.basix.agency/'
```

When the site is player-only, this resource allows each player's IP while they are connected and removes it when they leave. Anyone else opening the address gets `403 Access denied`.

## LB Phone, screenshot-basic, screencapture

These scripts can upload to BasiX directly. Step-by-step setup for each one:
[basix.agency/docs/integrations](https://basix.agency/docs/integrations?utm_source=github&utm_medium=referral&utm_campaign=sdk-fivem)

## Migrating from Fivemanage or Fivemerr

Point your scripts here instead — the endpoints and the response shape are the same.
See [the comparison](https://basix.agency/compare/fivemanage?utm_source=github&utm_medium=referral&utm_campaign=sdk-fivem) and the migration guides in the integrations docs.

## Convars

| Convar | Default | |
|---|---|---|
| `basix_key` | — | required |
| `basix_folder` | `` | prefix for every upload |
| `basix_dataset` | `default` | log stream name |
| `basix_log_level` | `info` | minimum level actually sent |
| `basix_sites` | `true` | allow connected players' IPs on player-only sites |
| `basix_endpoint` | `https://upload.basix.agency` | for testing only |

## License

MIT
