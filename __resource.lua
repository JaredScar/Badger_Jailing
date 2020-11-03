resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

description 'Badger_Jailing by Badger'

version '1.0'

client_scripts {
	'config.lua',
	'client.lua',
}
server_scripts {
	'config.lua',
	"server.lua",
}

file 'players.json'