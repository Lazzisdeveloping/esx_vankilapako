Config = {}
Config.Locale = 'fi'

Config.Marker = {
	r = 250, g = 0, b = 0, a = 100,  
	x = 1.0, y = 1.0, z = 1.5,       
	DrawDistance = 15.0, Type = 1    
}

Config.boliisia = 5 --Monta poliisia tarvitaan aloitukseen
Config.eijaksaoottaa    = 100 -- kauan joutuu odottamaan uutta hakkerointi yritystä [sekunteina]

Config.MaxDistance    = 1  

Stores = {
	["Vankila"] = {
		position = { x = 1831.36, y = 2603.34, z = 45.89 },
		secondsRemaining = 200, --hakkeroinnin pituus [sekunteina]
		lastRobbed = 0
	},

}
