
path = {}

function getPrevious (id)
	if id  < 1 then
		return #path
	else
		return id
	end
end

addEventHandler("onClientRender", root, function()
	for i,v in pairs(path) do
		local x,y,z = unpack(v)
		dxDrawLine3D ( x,y,z-2,x,y,z+2, tocolor ( 0, 0, 255, 230 ), 2)
		local xa,ya,za = unpack(path[getPrevious(i-1)])
		dxDrawLine3D ( x,y,z,xa,ya,za, tocolor ( 255, 0, 0, 230 ), 1)
	end
end)


function recordPath ()
	record = not record
	if not record then
		setClipboard(toJSON(path))
	end
end

addCommandHandler ( "record", recordPath )


function markPoints ( text )
	if record then
		local x,y,z = unpack(path[getPrevious(#path-1)] or {1,1,1})
		local xa,ya,za = getElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer)
		if getDistanceBetweenPoints3D(x,y,z,xa,ya,za) > 2 then
			table.insert(path,{getElementPosition(getPedOccupiedVehicle(localPlayer) or localPlayer)})
			print('Path marker',#path,'placed')
		end
	end
end

setTimer ( markPoints, 250, 0)