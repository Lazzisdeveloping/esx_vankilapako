# esx_vankilapako
• Vankilapako scripti FiveM roolipeliin tiedosto on supportattu esx-qalle-jail:in kanssa

• Eka Scripti jonka julkaisen
• Credits https://github.com/AshdeuzoFR/esx_holdup

!!! REQUIREMENTS !!!

• https://github.com/qalle-git/esx-qalle-jail

!!! ASENTAMINEN !!!

• Drag & Drop Files

• Lisää pari snipettiä esx-qalle-jailii

• esx-qalle-jail/client/client.lua

```
RegisterNetEvent("esx-qalle-jail:openUnJailMenu")
AddEventHandler("esx-qalle-jail:openUnJailMenu", function()
	OpenUnJailMenu()
end)
```
• esx-qalle-jail/client/client.lua
```
function OpenUnJailMenu()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'jail_prison_menu',
		{
			title    = "Vankila",
			align    = 'right',
			elements = {
				{ label = "Vankilan tietokanta", value = "unjail_player" }
			},
		},

	function(data, menu)

		local action = data.current.value

		if action == "unjail_player" then

			local elements = {}

			ESX.TriggerServerCallback("esx-qalle-jail:retrieveJailedPlayers", function(playerArray)

				if #playerArray == 0 then
					ESX.ShowNotification("Vankilassa ei ole ketään!")
					return
				end

				for i = 1, #playerArray, 1 do
					table.insert(elements, {label = "Vanki: " .. playerArray[i].name .. " | Aika: " .. playerArray[i].jailTime .. " Minuuttia", value = playerArray[i].identifier })
				end

				ESX.UI.Menu.Open(
					'default', GetCurrentResourceName(), 'jail_unjail_menu',
					{
						title = "Vankilan tietokanta",
						align = "center",
						elements = elements
					},
				function(data2, menu2)

					local action = data2.current.value

					TriggerServerEvent("esx-qalle-jail:unJailPlayer", action)

					menu2.close()

				end, function(data2, menu2)
					menu2.close()
				end)
			end)

		end

	end, function(data, menu)
		menu.close()
	end)	
end
