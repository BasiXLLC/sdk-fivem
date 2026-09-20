fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'basix'
author 'BasiX Agency'
description 'Upload screenshots, clips and logs to BasiX from your server.'
version '1.0.0'
repository 'https://github.com/basix-agency/basix'

server_scripts {
    'server/http.lua',
    'server/upload.lua',
    'server/logs.lua',
    'server/exports.lua',
    'server/commands.lua',
}

client_scripts {
    'client/capture.lua',
}

-- Optional. Present on most servers already; the resource degrades to
-- server-side uploads when it is missing rather than failing to start.
dependencies {
    '/server:7290',
}
