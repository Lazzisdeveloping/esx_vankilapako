local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_vankilapako:tooFar')
AddEventHandler('esx_vankilapako:tooFar', function(currentjail)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', jails[currentjail].nameOfjail))
			TriggerClientEvent('esx_vankilapako:killBlip', xPlayers[i])
		end
	end

	if robbers[_source] then
		TriggerClientEvent('esx_vankilapako:tooFar', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', jails[currentjail].nameOfjail))
	end
end)

RegisterServerEvent('esx_vankilapako:robberyStarted')
AddEventHandler('esx_vankilapako:robberyStarted', function(currentjail)
	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if jails[currentjail] then
		local jail = jails[currentjail]

		if (os.time() - jail.ronklattu) < Config.eijaksaoottaa and jail.ronklattu ~= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('recently_hacked', Config.eijaksaoottaa - (os.time() - jail.ronklattu)))
			return
		end

		local cops = 0
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
				cops = cops + 1
			end
		end

		if not rob then
			if xPlayer.getInventoryItem('hakkerointilaite').count >= 1 then
				if cops >= Config.boliisia then

				rob = true

				xPlayer.removeInventoryItem('hakkerointilaite', 1)

				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
						TriggerClientEvent('esx_vankilapako:setBlip', xPlayers[i], jails[currentjail].sijainti)
					end
				end

				TriggerClientEvent('esx:showNotification', _source, _U('started_to_rob', jail.nameOfjail))
				TriggerClientEvent('esx:showNotification', _source, _U('alarm_triggered'))
				TriggerClientEvent('esx_vankilapako:anim', _source)
				
				TriggerClientEvent('esx_vankilapako:currentlyRobbing', _source, currentjail)
				TriggerClientEvent('esx_vankilapako:startTimer', _source)
				
				jails[currentjail].ronklattu = os.time()
				robbers[_source] = currentjail

				SetTimeout(jail.aika * 1000, function()
					if robbers[_source] then
						rob = false
						if xPlayer then
							TriggerClientEvent('esx_vankilapako:robberyComplete', _source)
							
							local xPlayers, xPlayer = ESX.GetPlayers(), nil
							for i=1, #xPlayers, 1 do
								xPlayer = ESX.GetPlayerFromId(xPlayers[i])

								if xPlayer.job.name == 'police' or xPlayer.job.name == 'sheriff' then
									TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', jail.nameOfjail))
									TriggerClientEvent('esx_vankilapako:killBlip', xPlayers[i])
								end
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('min_police', Config.boliisia))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, ('Sinulla ei ole ~r~hakkerointilaitetta'))
		end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
