function prepPed (player)
	local ped = createPed ( 0, 0,0,0,0,true )
	warpPedIntoVehicle(ped,getPedOccupiedVehicle(player))
	
	triggerClientEvent ( player, "prepPed", player, ped)
	print('Ped prepped')
end


addCommandHandler ( "prepPed", prepPed )