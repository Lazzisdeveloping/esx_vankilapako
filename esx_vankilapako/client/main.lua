local holdingUp = false
local jail = ""
local blipRobbery = nil
ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_vankilapako:currentlyRobbing')
AddEventHandler('esx_vankilapako:currentlyRobbing', function(currentjail)
	holdingUp, jail = true, currentjail
end)

RegisterNetEvent('esx_vankilapako:killBlip')
AddEventHandler('esx_vankilapako:killBlip', function()
	RemoveBlip(blipRobbery)
end)

RegisterNetEvent('esx_vankilapako:setBlip')
AddEventHandler('esx_vankilapako:setBlip', function(sijainti)
	blipRobbery = AddBlipForCoord(sijainti.x, sijainti.y, sijainti.z)

	ESX.ShowAdvancedNotification('H??lytys', '~r~Vankila', "", "CHAR_CALL911", 1)
	PlaySound(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", 0, 0, 1)
	SetBlipSprite(blipRobbery, 161)
	SetBlipScale(blipRobbery, 2.0)
	SetBlipColour(blipRobbery, 1)

	PulseBlip(blipRobbery)
end)

RegisterNetEvent('esx_vankilapako:tooFar')
AddEventHandler('esx_vankilapako:tooFar', function()
	holdingUp, jail = false, ''
	ESX.ShowNotification(_U('robbery_cancelled'))
end)

RegisterNetEvent('esx_vankilapako:robberyComplete')
AddEventHandler('esx_vankilapako:robberyComplete', function(award)
	ClearPedTasks(GetPlayerPed(-1))
	TriggerEvent("esx-qalle-jail:openUnJailMenu")
	holdingUp, jail = false, ''
end)

RegisterNetEvent('esx_vankilapako:anim')
AddEventHandler('esx_vankilapako:anim', function()
	local ped = PlayerPedId()
	TaskStartScenarioInPlace(PlayerPedId(), "PROP_HUMAN_BUM_BIN", 0, true)
end)

RegisterNetEvent('esx_vankilapako:startTimer')
AddEventHandler('esx_vankilapako:startTimer', function()
	local timer = jails[jail].aika

	Citizen.CreateThread(function()
		while timer > 0 and holdingUp do
			Citizen.Wait(1000)

			if timer > 0 then
				timer = timer - 1
			end
		end
	end)

	Citizen.CreateThread(function()
		while holdingUp do
			Citizen.Wait(0)
			drawTxt(0.66, 1.44, 1.0, 1.0, 0.4, _U('robbery_timer', timer), 255, 255, 255, 255)
		end
	end)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)

		for k,v in pairs(jails) do
			local jailPos = v.sijainti
			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, jailPos.x, jailPos.y, jailPos.z)

			if distance < Config.Marker.DrawDistance then
				if not holdingUp then
					DrawMarker(Config.Marker.Type, jailPos.x, jailPos.y, jailPos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, false, false, false)

					if distance < 0.5 then
						ESX.ShowHelpNotification(_U('press_to_rob', v.nameOfjail))

						if IsControlJustReleased(0, Keys['E']) then
							if IsPedArmed(PlayerPedId(), 4) then
								TriggerServerEvent('esx_vankilapako:robberyStarted', k)

							else
								ClearPedTasks(ped)
								ESX.ShowNotification(_U('no_threat'))
							end
						end
					end
				end
			end
		end

		if holdingUp then
			local jailPos = jails[jail].sijainti
			if Vdist(playerPos.x, playerPos.y, playerPos.z, jailPos.x, jailPos.y, jailPos.z) > Config.MaxDistance then
				TriggerServerEvent('esx_vankilapako:tooFar', jail)
			end
		end
	end
end)
