local rob = false
local robbers = {}
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_traphouse:tooFar')
AddEventHandler('esx_traphouse:tooFar', function(currentTrap)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Traps[currentTrap].nameOfTrap))
			TriggerClientEvent('esx_traphouse:killBlip', xPlayers[i])
	end

	if robbers[_source] then
		TriggerClientEvent('esx_traphouse:tooFar', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', Traps[currentTrap].nameOfTrap))
	end
end)

RegisterServerEvent('esx_traphouse:dead')
AddEventHandler('esx_traphouse:dead', function(currentTrap)
	local _source = source
	local xPlayers = ESX.GetPlayers()
	rob = false

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_cancelled_at', Traps[currentTrap].nameOfTrap))
			TriggerClientEvent('esx_traphouse:killBlip', xPlayers[i])
	end

	if robbers[_source] then
		TriggerClientEvent('esx_traphouse:playerDead', _source)
		robbers[_source] = nil
		TriggerClientEvent('esx:showNotification', _source, _U('robbery_cancelled_at', Traps[currentTrap].nameOfTrap))
	end
end)

RegisterServerEvent('esx_traphouse:robberyStarted')
AddEventHandler('esx_traphouse:robberyStarted', function(currentTrap)
	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()

	if Traps[currentTrap] then
		local Trap = Traps[currentTrap]

		if (os.time() - Trap.lastRobbed) < Config.TimerBeforeNewRob and Trap.lastRobbed ~= 0 then
			TriggerClientEvent('esx:showNotification', _source, _U('recently_robbed', Config.TimerBeforeNewRob - (os.time() - Trap.lastRobbed)))
			return
		end

		local cops = 0
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			if xPlayer.job.name == 'police' then
				cops = cops + 1
			end
		end

		if not rob then
			if cops >= Config.PoliceNumberRequired then
				rob = true

				for i=1, #xPlayers, 1 do
					local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
						TriggerClientEvent('esx:showNotification', xPlayers[i], _U('rob_in_prog', Trap.nameOfTrap))
						TriggerClientEvent('esx_traphouse:setBlip', xPlayers[i], Traps[currentTrap].position)
				end

				TriggerClientEvent('esx:showNotification', _source, _U('started_to_rob', Trap.nameOfTrap))
				TriggerClientEvent('esx:showNotification', _source, _U('alarm_triggered'))

				TriggerClientEvent('esx_traphouse:currentlyRobbing', _source, currentTrap)
				TriggerClientEvent('esx_traphouse:startTimer', _source)

				Traps[currentTrap].lastRobbed = os.time()
				robbers[_source] = currentTrap

				SetTimeout(Trap.secondsRemaining * 1000, function()
					if robbers[_source] then
						rob = false
						if xPlayer then
							TriggerClientEvent('esx_traphouse:robberyComplete', _source, Trap.reward)
							-- Money rewards.
							if Config.GiveBlackMoney then
								xPlayer.addAccountMoney('black_money', Trap.reward)
							else
								xPlayer.addMoney(Trap.reward)
							end
							-- Drug system rewards
							local chance = math.random(1, 3)
							if chance == 1 then 
								xPlayer.addInventoryItem("methburn",1)
							elseif chance == 2 then
								xPlayer.addInventoryItem("cokeburn",1)
							elseif chance == 3 then
								xPlayer.addInventoryItem("weedburn",1)
							end
							xPlayer.addInventoryItem("meth1g",math.random(1,5))
							xPlayer.addInventoryItem("coke1g",math.random(1,5))
							xPlayer.addInventoryItem("weed4g",math.random(1,7))
							xPlayer.addInventoryItem("joint2g",math.random(2,5))

							local xPlayers, xPlayer = ESX.GetPlayers(), nil
							for i=1, #xPlayers, 1 do
								xPlayer = ESX.GetPlayerFromId(xPlayers[i])
									TriggerClientEvent('esx:showNotification', xPlayers[i], _U('robbery_complete_at', Trap.nameOfTrap))
									TriggerClientEvent('esx_traphouse:killBlip', xPlayers[i])
							end
						end
					end
				end)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('min_police', Config.PoliceNumberRequired))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, _U('robbery_already'))
		end
	end
end)
