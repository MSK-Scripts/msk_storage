fx_version 'cerulean'
games { 'gta5' }

author 'Musiker15 - MSK Scripts'
name 'msk_storage'
description 'Storage System'
version '1.1.0'

lua54 'yes'

escrow_ignore {
	'config.lua',
	'translation.lua',

    'integration/*.lua',

    -- 'client/*.lua',
    -- 'server/*.lua',
}

shared_script {
    '@es_extended/imports.lua',
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
	'es_extended',
    'oxmysql',
    'msk_core'
}