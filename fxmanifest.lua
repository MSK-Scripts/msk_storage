fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_storage'
description 'Storage System'
version '1.3.0'

lua54 'yes'

shared_script {
    -- @es_extended/imports.lua is gone: every framework call goes through
    -- msk_core, and importing ESX here made the resource refuse to start on a
    -- server without it.
    '@msk_core/import.lua',
    'config.lua',
    'translation.lua'
}

client_scripts {
	'client/**/*.*',
    'integration/client_integration.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/**/*.*',
    'integration/server_integration.lua'
}

ui_page 'html/index.html'

files {
	"html/**/*.*"
}

dependencies {
    'oxmysql',
    'msk_core'
}
