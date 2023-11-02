fx_version 'cerulean'
game 'gta5'

description 'Kuma-BusJob'
version '1.2.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
    '@ox_lib/init.lua',
    'locales.lua'
}

client_scripts {
    'client/tes.lua',
    'client/main.lua'
}

server_script 'server/main.lua'

lua54 'yes'
