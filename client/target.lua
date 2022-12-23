local QBCore = exports['qb-core']:GetCoreObject()

-- start heist
exports['qb-target']:AddBoxZone("nxte-mrpd:startheist", vector3(-788.24, -1259.06, 6.77), 0.7, 2, {
	name = "nxte-mrpd:startheist",
	heading = 229.28,
	debugPoly = false,
	minZ = 4.8,
	maxZ = 7.2,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:startheist",
			icon = "fas fa-circle",
			label = "Start Heist",
		},
	},
	distance = 2.5
})

-- start hack
exports['qb-target']:AddBoxZone("nxte-mrpd:starthack", vector3(470.51, -1057.03, 31.28), 1.7, 2.9, {
	name = "nxte-mrpd:starthack",
	heading = 188,
	debugPoly = false,
	minZ = 28.5,
	maxZ = 30.5,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:hack",
			icon = "fas fa-circle",
			label = "Hack",
		},
	},
	distance = 2.5
})

-- start bomb
exports['qb-target']:AddBoxZone("nxte-mrpd:startbomb", vector3(477.17, -1082.16, 44.15), 4, 7, {
	name = "nxte-mrpd:startbomb",
	heading = 359.25,
	debugPoly = false,
	minZ = 42.5,
	maxZ = 45.5,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:bomb",
			icon = "fas fa-circle",
			label = "Place Bomb",
		},
	},
	distance = 2.5
})

-- Grab armory key
exports['qb-target']:AddBoxZone("nxte-mrpd:grabkey", vector3(452.33, -972.5, 32.28), 0.5, 0.25, {
	name = "nxte-mrpd:grabkey",
	heading = 182.54,
	debugPoly = false,
	minZ = 31.2,
	maxZ = 31.4,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:grabkey",
			icon = "fas fa-circle",
			label = "Look for key",
		},
	},
	distance = 2.5
})




-- Loot locker 1
exports['qb-target']:AddBoxZone("nxte-mrpd:loot1", vector3(455.9, -978.32, 32.45), 1, 1.5, {
	name = "nxte-mrpd:loot1",
	heading = 180,
	debugPoly = false,
	minZ = 29.8,
	maxZ = 33.5,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:loot1",
			icon = "fas fa-circle",
			label = "Search Locker",
		},
	},
	distance = 2.5
})


-- Loot locker 2
exports['qb-target']:AddBoxZone("nxte-mrpd:loot2", vector3(462.52, -981.1, 31.7), 1, 1.5, {
	name = "nxte-mrpd:loot2",
	heading = 88.78,
	debugPoly = false,
	minZ = 29.8,
	maxZ = 33.5,
}, {
	options = {
		{
            type = "client",
            event = "nxte-mrpd:client:loot2",
			icon = "fas fa-circle",
			label = "Search Locker",
		},
	},
	distance = 2.5
})