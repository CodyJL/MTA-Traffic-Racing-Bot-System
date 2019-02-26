

local path = fromJSON(path)

peds = {}
pTable = {}

function getPrevious (id)
	if id  < 1 then
		return #path
	else
		return id
	end
end

function fixRotation (rot)
	if rot > 180 then
		return rot - 360
	elseif rot < -180 then
		return rot + 360
	else
		return rot
	end
end

local incerment = {10,25,65}

local screenWidth, screenHeight = guiGetScreenSize ( )

addEventHandler("onClientRender", root, function()

	for i,v in pairs(path) do
		local x,y,z = unpack(v)
		dxDrawLine3D ( x,y,z-2,x,y,z+2, tocolor ( 0, 0, 255, 230 ), 2)
		local xa,ya,za = unpack(path[getPrevious(i-1)])
		dxDrawLine3D ( x,y,z,xa,ya,za, tocolor ( 255, 0, 0, 230 ), 1)
	end
		
		
	for i,Ped in pairs(peds) do
		pTable[Ped] = {}
		pTable[Ped]['Offset'] = {}
		
		local vehicle = getPedOccupiedVehicle(Ped or localPlayer) or localPlayer
		
		for i = 1,3 do
			pTable[Ped]['Offset'][i] = {closest = nil,distance = 1000}
			local xa,ya,za = getPositionFromElementOffset(vehicle,0,(incerment[i]),0)
			pTable[Ped]['Offset'][i].position = {xa,ya,za}
		end
		
		for i,v in pairs(path) do
			local x,y,z = unpack(v)
			local xa,ya,za = unpack(path[getPrevious(i-1)])
			
			for i = 1,3 do
				local xA,yA,zA = unpack(pTable[Ped]['Offset'][i].position)
				local dis,xb,yb,zb = getDistanceBetweenPointAndSegment3D(xA,yA,zA,x,y,z,xa,ya,za)
				if dis < pTable[Ped]['Offset'][i].distance then
					pTable[Ped]['Offset'][i].distance = dis
					pTable[Ped]['Offset'][i].closest = {xb,yb,zb}
				end
			end
		end
		if pTable[Ped]['Offset'][1].closest then
			
			for i = 1,3 do
				local x,y,z = unpack(pTable[Ped]['Offset'][i].closest)
				dxDrawLine3D ( x,y,z-2,x,y,z+2, tocolor ( (i>0 and 255 or 0), (i>1 and 255 or 0), (i>2 and 255 or 0), 230 ), 2)
			end
			
			local vx,vy,vz = getElementPosition(vehicle)
			local vrx,vry,vrz = getElementRotation(vehicle)
			
			local x,y = unpack(pTable[Ped]['Offset'][1].closest)
			pTable[Ped].turn = -fixRotation(vrz-findRotation( vx,vy,x,y ))
			local xa,ya = unpack(pTable[Ped]['Offset'][2].closest)
			pTable[Ped].turn2 = -fixRotation(vrz-findRotation( x,y,xa,ya ))
			local xb,yb = unpack(pTable[Ped]['Offset'][3].closest)
			pTable[Ped].turn3 = -fixRotation(vrz-findRotation( xa,ya,xb,yb ))*2
			
			
			local tA1 = math.abs(pTable[Ped].turn)
			local tA2 = math.abs(pTable[Ped].turn2)
			
			local a3 = (math.abs(pTable[Ped].turn3))
			
			local tA3 = (math.abs(pTable[Ped].turn3))
			
			local tA3 = (a3 > 45) and tA3 or 0
			
			local change = tA1*10
			dxDrawText ( (math.floor(tA1*10)/10)..'S°', 44, screenHeight - 41, screenWidth, screenHeight, tocolor ( 255, 255-change, 255-change, 255 ), 1.02, "pricedown" )
			 
			local change2 = tA2*10
			dxDrawText ( (math.floor(tA2*10)/10)..'M°', (screenWidth/1.2), screenHeight - 41, screenWidth, screenHeight, tocolor ( 255, 255-change2, 255-change2, 255 ), 1.02, "pricedown" )
			
			local change3 = tA3*10
			dxDrawText ( (math.floor(tA3*10)/10)..'F°', (screenWidth/1.2), screenHeight - 61, screenWidth, screenHeight, tocolor ( 255, 255-change3, 255-change3, 255 ), 1.02, "pricedown" )
			

			
			local turnAngle = math.max(math.min(pTable[Ped].turn,10),-10)
			
			local total = (tA1+tA2+tA3)*2.5
			
			local limit = (tA2>45) and 25 or ((tA3 > 100) and 50 or 67)
			
			local cornerSpeed = math.max(150-total,limit)
				
			pTable[Ped].speed = 1
			pTable[Ped].brake = 0
				
			local difference = ((getElementSpeed(vehicle, 2) - cornerSpeed)/cornerSpeed)/4
					

			pTable[Ped].speed = -math.max(math.min(difference*10,1),-1)

			if pTable[Ped].speed < 0 then
				pTable[Ped].brake = (-pTable[Ped].speed)
				pTable[Ped].speed = 0
			end
				
			dxDrawText ( (math.floor(turnAngle*18))..'°', (screenWidth/2), screenHeight - 41, (screenWidth/2), screenHeight, tocolor ( 255, 255, 255, 255 ), 1.02, "pricedown" )
			dxDrawText ( math.floor(pTable[Ped].speed*100)..'%', (screenWidth/2), screenHeight - 61, (screenWidth/2), screenHeight, tocolor ( 0, 0, 255, 255 ), 1.02, "pricedown" )
			dxDrawText ( math.floor(pTable[Ped].brake*100)..'%', (screenWidth/2), screenHeight - 81, (screenWidth/2), screenHeight, tocolor ( 255, 0, 0, 255 ), 1.02, "pricedown" )
				
			dxDrawText ( math.floor(getElementSpeed(vehicle, 2))..'|'..math.floor(cornerSpeed), (screenWidth/2), 81, (screenWidth/2), screenHeight, tocolor ( 255, 0, 255, 255 ), 1.02, "pricedown" )
				
			if Ped then	
				if Go then
					setPedAnalogControlState (Ped,"accelerate",pTable[Ped].speed) 
					setPedAnalogControlState (Ped,"handbrake",pTable[Ped].brake*2) 
					setPedAnalogControlState (Ped,"brake_reverse",pTable[Ped].brake*0.8) 
				else
					setPedAnalogControlState (Ped,"accelerate",0) 
					setPedAnalogControlState (Ped,"handbrake",1) 
					setPedAnalogControlState (Ped,"brake_reverse",0) 
				end
				
				if turnAngle > 0 then
					setPedAnalogControlState (Ped,"vehicle_right",0)
					setPedAnalogControlState (Ped,"vehicle_left",(turnAngle/10)) 
				else
					setPedAnalogControlState (Ped,"vehicle_left",0)
					setPedAnalogControlState (Ped,"vehicle_right",-(turnAngle/10))
				end
			end
		end
	end
end)

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    local theElementType = getElementType(theElement);
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    assert(theElementType == "player" or theElementType == "ped" or theElementType == "object" or theElementType == "vehicle" or theElementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle expected, got " .. theElementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end


function findRotation( x1, y1, x2, y2 ) 
    local t = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
    return t < 0 and t + 360 or t
end


function clientPrep (ped)
	print('Client ready')
	table.insert(peds,ped)
end


addEvent( "prepPed", true )
addEventHandler( "prepPed", localPlayer, clientPrep )

function goPed (player)
	Go = not Go
end


addCommandHandler ( "goPed", goPed )



function getDistanceBetweenPointAndSegment3D (pointX, pointY, pointZ, x1, y1, z1, x2, y2, z2)

	local A = pointX - x1 
	local B = pointY - y1
	local C = pointZ - z1

	local D = x2 - x1
	local E = y2 - y1
	local F = z2 - z1

	local point = A * D + B * E + C * F
	local lenSquare = D * D + E * E + F * F
	local parameter = point / lenSquare
 
	local shortestX
	local shortestY
	local shortestZ
 
	if parameter < 0 then
		shortestX = x1
    	shortestY = y1
		shortestZ = z1
	elseif parameter > 1 then
		shortestX = x2
		shortestY = y2
		shortestZ = z2

	else
		shortestX = x1 + parameter * D
		shortestY = y1 + parameter * E
		shortestZ = z1 + parameter * F
	end

	local distance = getDistanceBetweenPoints3D(pointX, pointY,pointZ, shortestX, shortestY,shortestZ)
 
	return distance,shortestX, shortestY,shortestZ
end


function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                            
end

