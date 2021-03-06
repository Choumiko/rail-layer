require "settings"

local lastRailPosition = {x = 0, y = 0}
local lastBigPolePosition = {x = 0, y = 0}
local lastCheckPole = {x = 0, y = 0}
local signalCount = 0

local railDirection = 0
local wantedDirection = 0
local needDiagonal = false

local straightRail = 0
local curvedRail = 0
local bigElectricPole = 0
local railSignal = 0

local playerInfo = {}

local function posAdd(pos, x, y)
    return {x = pos.x + x, y = pos.y + y}
end

polePlacement.data = {
    {x = 2, y = 0},
    {x = 1.5, y = 1.5},
    {x = 0, y = 2},
    {x = 1.5, y = 1.5},

    {x = 2, y = 0},
    {x = 1.5, y = 1.5},
    {x = 0, y = 2},
    {x = 1.5, y = 1.5}
}
polePlacement.dir = {
    {x = 1, y = 1},
    {x = 1, y = -1},
    {x = 1, y = -1},
    {x = -1, y = -1},

    {x = -1, y = 1},
    {x = -1, y = 1},
    {x = 1, y = 1},
    {x = 1, y = 1}
}

for i = 1, 8, 1 do
    polePlacement.data[i].x = (polePlacement.data[i].x + polePlacement.distance) * polePlacement.side * polePlacement.dir[i].x
    polePlacement.data[i].y = (polePlacement.data[i].y + polePlacement.distance) * polePlacement.side * polePlacement.dir[i].y
end

local curves={
    {raildirection = 2, wanteddirection = 3, curvedir = 6, xoffset = -3.0, yoffset =  1.0, xmove = -7.5, ymove =  4.5, corner = 1, cornerx = -6.5, cornery =  3.5, cornerr = 7},
    {raildirection = 2, wanteddirection = 1, curvedir = 7, xoffset = -3.0, yoffset = -1.0, xmove = -6.5, ymove = -3.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
    {raildirection = 6, wanteddirection = 5, curvedir = 3, xoffset =  3.0, yoffset =  1.0, xmove =  7.5, ymove =  4.5, corner = 1, cornerx =  6.5, cornery =  3.5, cornerr = 5},
    {raildirection = 6, wanteddirection = 7, curvedir = 2, xoffset =  3.0, yoffset = -1.0, xmove =  6.5, ymove = -3.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},

    {raildirection = 0, wanteddirection = 1, curvedir = 0, xoffset = -1.0, yoffset = -3.0, xmove = -4.5, ymove = -7.5, corner = 1, cornerx = -3.5, cornery = -6.5, cornerr = 5},
    {raildirection = 0, wanteddirection = 7, curvedir = 1, xoffset =  1.0, yoffset = -3.0, xmove =  4.5, ymove = -7.5, corner = 1, cornerx =  3.5, cornery = -6.5, cornerr = 3},
    {raildirection = 4, wanteddirection = 3, curvedir = 5, xoffset = -1.0, yoffset =  3.0, xmove = -3.5, ymove =  6.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
    {raildirection = 4, wanteddirection = 5, curvedir = 4, xoffset =  1.0, yoffset =  3.0, xmove =  3.5, ymove =  6.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},

    {raildirection = 1, wanteddirection = 2, curvedir = 3, xoffset = -2.5, yoffset = -1.5, xmove = -7.5, ymove = -2.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
    {raildirection = 1, wanteddirection = 0, curvedir = 4, xoffset = -2.5, yoffset = -3.5, xmove = -3.5, ymove = -8.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 1},
    {raildirection = 5, wanteddirection = 4, curvedir = 0, xoffset =  1.5, yoffset =  2.5, xmove =  2.5, ymove =  7.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 5},
    {raildirection = 5, wanteddirection = 6, curvedir = 7, xoffset =  3.5, yoffset =  2.5, xmove =  8.5, ymove =  3.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 5},

    {raildirection = 3, wanteddirection = 4, curvedir = 1, xoffset = -1.5, yoffset =  2.5, xmove = -2.5, ymove =  7.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
    {raildirection = 3, wanteddirection = 2, curvedir = 2, xoffset = -3.5, yoffset =  2.5, xmove = -8.5, ymove =  3.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 3},
    {raildirection = 7, wanteddirection = 6, curvedir = 6, xoffset =  2.5, yoffset = -1.5, xmove =  7.5, ymove = -2.5, corner = 0, cornerx =  0.0, cornery =  0.0, cornerr = 0},
    {raildirection = 7, wanteddirection = 0, curvedir = 5, xoffset =  2.5, yoffset = -3.5, xmove =  3.5, ymove = -8.5, corner = 1, cornerx =  0.0, cornery =  0.0, cornerr = 3}
}

local treeRemoveForCurved = {
    {{x = -1, y = -3}, {x = -1, y = -1}, {x =  0, y = -1}, {x =  1, y = 1}, {x =  0, y = 1}, {x =  1, y = 3}},
    {{x =  1, y = -4}, {x =  1, y = -2}, {x =  0, y = -1}, {x =  0, y = 1}, {x = -1, y = 1}, {x = -1, y = 3}},
    {{x =  3, y = -1}, {x =  1, y = -1}, {x =  1, y =  0}, {x = -1, y = 0}, {x = -1, y = 1}, {x = -3, y = 1}},
    {{x = -3, y = -1}, {x = -1, y = -1}, {x = -1, y =  0}, {x =  1, y = 0}, {x =  1, y = 1}, {x =  3, y = 1}}
}

local function check_tech(player)
    if (player.force.technologies["automated-rail-transportation"].researched) then
        player.force.technologies["automated-rail-transportation"].researched = false
        player.force.technologies["automated-rail-transportation"].researched = true
        player.force.recipes["rail-layer"].enabled = true
    end
end

game.oninit(function()
    for index, player in pairs(game.players) do
        check_tech(player)
    end
end)

game.onload(function()
    for index, player in pairs(game.players) do
        check_tech(player)
    end
end)

local function update_cargo(train)
    straightRail = 0
    curvedRail = 0
    bigElectricPole = 0
    railSignal = 0
    local wagon = train.carriages
    for _, entity in ipairs(wagon) do
        if (entity.type == "cargo-wagon") then
            local inv = entity.getinventory(1)
            straightRail = straightRail + inv.getitemcount("straight-rail")
            curvedRail = curvedRail + inv.getitemcount("curved-rail")
            bigElectricPole = bigElectricPole + inv.getitemcount("big-electric-pole")
            railSignal = railSignal + inv.getitemcount("rail-signal")
        end
    end
    --game.player.print("Straight = " .. straightRail .. " curved = " .. curvedRail .. " bigPole = " .. bigElectricPole)
end

local function addItem(train, itemName, count)
    local wagon = train.carriages
    for _, entity in ipairs(wagon) do
        if (entity.type == "cargo-wagon") then
            if (entity.getinventory(1).caninsert({name = itemName, count = count})) then
                entity.getinventory(1).insert({name = itemName, count = count})
                return
            end
        end
    end
    local position = game.findnoncollidingposition("item-on-ground", game.player.character.vehicle.position, 100, 0.5)
    game.createentity{name = "item-on-ground", position = position, stack = {name = itemName, count = 1}}
end

local function removeTrees(train, X, Y)
    local area = {{X - 1.5, Y - 1.5}, {X + 1.5, Y + 1.5}}
    for _, entity in ipairs(game.findentitiesfiltered{area = area, type = "tree"}) do
        -- game.player.print("Removing "..entity.name.." @("..entity.position.x..","..entity.position.y..").")
        addItem(train, "raw-wood", 1)
        entity.die()
    end
    if removeStone then
        for _, entity in ipairs(game.findentitiesfiltered{area = area, name = "stone-rock"}) do
            -- game.player.print("Removing "..entity.name.." @("..entity.position.x..","..entity.position.y..").")
            entity.die()
        end
    end
end

local function removeFromTrain(train, itemName)
    if godmode then return end
    local wagons = train.carriages
    for _, entity in ipairs(wagons) do
        if (entity.type == "cargo-wagon") then
            local inv = entity.getinventory(1).getcontents()
            if inv[itemName] then
                entity.getinventory(1).remove({name = itemName, count = 1})
                return
            end
        end
    end
end

local function placeSignal(train, X, Y, railDirection)
    local signalPoint = {x = X, y = Y}
    local signalDirection = 0

    if railDirection == 0 then
        signalPoint.x = X + 1.5
        signalPoint.y = Y + 0.5
        signalDirection = 4
    elseif railDirection == 1 then
        signalPoint.x = X + 1
        signalPoint.y = Y - 1
        signalDirection = 3
    elseif railDirection == 2 then
        signalPoint.x = X + 0.5
        signalPoint.y = Y - 1.5
        signalDirection = 2
    elseif railDirection == 3 then
        signalPoint.x = X - 1.5
        signalPoint.y = Y - 1.5
        signalDirection = 1
    elseif railDirection == 4 then
        signalPoint.x = X - 1.5
        signalPoint.y = Y - 0.5
        signalDirection = 0
    elseif railDirection == 5 then
        signalPoint.x = X - 1
        signalPoint.y = Y + 1
        signalDirection = 7
    elseif railDirection == 6 then
        signalPoint.x = X - 0.5
        signalPoint.y = Y + 1.5
        signalDirection = 6
    elseif railDirection == 7 then
        signalPoint.x = X + 1
        signalPoint.y = Y + 1
        signalDirection = 5
    end
    removeTrees(train, signalPoint.x, signalPoint.y)
    local canplace = game.canplaceentity{name = "rail-signal", position = {signalPoint.x, signalPoint.y}, direction = signalDirection}
    if canplace then
        game.createentity{name = "rail-signal", position = {signalPoint.x, signalPoint.y}, direction = signalDirection, force = game.forces.player}
        removeFromTrain(train, "rail-signal")
        railSignal = railSignal - 1
        return true
    else
        --game.player.print("error: railsignal@"..signalPoint.x.."/"..signalPoint.y.." dir "..signalDirection)
        return false
    end
end

local function placeRail(train, X, Y, railDirection, railType)
    local signalDirection = railDirection
    if (railType == "straight-rail") then
        -- fix for 0.10.12 as direction of diagonal track different for placed entity and direction asked in createentity
        if railDirection % 2 == 1 then
            railDirection = (railDirection + 2 * (railDirection % 2)) % 8
        end
        removeTrees(train, X, Y)
    end
    if (railType == "curved-rail") then
        local index = railDirection % 4 + 1
        for i = 1,6 do
            removeTrees(train, X + treeRemoveForCurved[index][i].x, Y + treeRemoveForCurved[index][i].y)
        end
    end
    -- game.player.print(X.."/"..Y.." dir "..railDirection)
    local canplace = game.canplaceentity{name = railType, position = {X, Y}, direction = railDirection}
    if canplace then
        game.createentity{name = railType, position = {X, Y}, direction = railDirection, force = game.forces.player}
        --game.createentity{name = "ghost", position = {X, Y}, innername = railType, direction = railDirection, force = game.player.force}
        removeFromTrain(train, railType)
        if (railType == "straight-rail") then
            --game.player.print("# "..signalCount)
            if railSignal >  1 and signalCount >= signalPlacement.distance then
                if placeSignal(train, X, Y, signalDirection) then
                    signalCount = 0
                end
            else
                signalCount = signalCount + 1
            end
            straightRail = straightRail - 1
        elseif (railType == "curved-rail") then
            curvedRail = curvedRail - 1
        end
        return true
    end
    return false
end

local function placePole(train, lastRail)
    local polePoint = {x = lastRail.x, y = lastRail.y}
    removeTrees(train, polePoint.x, polePoint.y)
    local canplace = game.canplaceentity{name = "big-electric-pole", position = {polePoint.x, polePoint.y}}
    if canplace then
        game.createentity{name = "big-electric-pole", position = {polePoint.x, polePoint.y}, force = game.forces.player}
        removeFromTrain(train, "big-electric-pole")
        --game.player.print("last rail position x = " .. lastRail.x .. " y = " .. lastRail.y)
        --game.player.print("Pole position x = " .. polePoint.x .. " y = " .. polePoint.y)
        bigElectricPole = bigElectricPole - 1
        return true
    else
        --game.player.print("Can`t place POLE!!!! x = " .. polePoint.x .. " y = " .. polePoint.y)
    end
    return false
end

local function distance(point1, point2)
    local diffX = point1.x - point2.x
    local diffY = point1.y - point2.y
    return diffX * diffX + diffY * diffY
end

local function railLying(player, index)
    local train = player.character.vehicle.train

    if game.tick % 60 == 0 then
        update_cargo(train)
    end

    local playerPosition = player.character.vehicle.position
    -- Player.print("Player position x = " .. playerPosition.x .. " y = " .. playerPosition.y)
    -- Player.print("Want direction = " .. wantedDirection)
    -- Player.print("Train direction = " .. trainDirection)
    if #playerInfo > 0 and playerInfo[index].active then
        local d = math.abs(lastRailPosition.x - playerPosition.x) + math.abs(lastRailPosition.y - playerPosition.y)
        if d < 15 then
            local cursor = player.screen2realposition(player.cursorposition)
            local ax = math.abs(playerPosition.x - cursor.x)
            local ay = math.abs(playerPosition.y - cursor.y)
            local railDirection = playerInfo[index].railDirection

            if (ax > ay * 2) then
                if (cursor.x - playerPosition.x > 0) then
                    wantedDirection = 6
                else
                    wantedDirection = 2
                end
            elseif (ay > ax * 2) then
                if (cursor.y - playerPosition.y > 0) then
                    wantedDirection = 4
                else
                    wantedDirection = 0
                end
            elseif (cursor.x - playerPosition.x > 0) then
                if (cursor.y - playerPosition.y > 0) then
                    wantedDirection = 5
                else
                    wantedDirection = 7
                end
            elseif (cursor.y - playerPosition.y > 0) then
                wantedDirection = 3
            else
                wantedDirection = 1
            end
            --game.player.print("Want go to " .. wantedDirection)
            --game.player.print("Go to " .. railDirection)
            if (bigElectricPole > 0) then
                local tmp = {x = lastCheckPole.x, y = lastCheckPole.y}
                lastCheckPole.x = lastRailPosition.x + polePlacement.data[railDirection+1].x
                lastCheckPole.y = lastRailPosition.y + polePlacement.data[railDirection+1].y
                local poleDistance = distance(lastBigPolePosition, lastCheckPole)
                --game.player.print("poleDistance = " .. poleDistance)
                if  poleDistance > 900 then
                    --game.player.print("lastCheck = " .. lastCheckPole.x)
                    --game.player.print("tmp = " .. tmp.x)
                    placePole(train, tmp)
                    lastBigPolePosition.x = tmp.x
                    lastBigPolePosition.y = tmp.y
                end
             end
            if (wantedDirection == railDirection) then
                if (straightRail > 1) then
                    -- horizontal or vertical
                    --game.player.print("Rail " .. lastRailPosition.x .. " y = " .. lastRailPosition.y .. "direction = " .. railDirection)
                    placeRail(train, lastRailPosition.x, lastRailPosition.y, railDirection, "straight-rail")
                    if (railDirection == 0) then
                        lastRailPosition = posAdd(lastRailPosition, 0, -2)
                    elseif (railDirection == 1) then
                        lastRailPosition = posAdd(lastRailPosition, -1, -1)
                        needDiagonal = not needDiagonal
                    elseif (railDirection == 2) then
                        lastRailPosition = posAdd(lastRailPosition, -2, 0)
                    elseif (railDirection == 3) then
                        lastRailPosition = posAdd(lastRailPosition, -1, 1)
                        needDiagonal = not needDiagonal
                    elseif (railDirection == 4) then
                        lastRailPosition = posAdd(lastRailPosition, 0, 2)
                    elseif (railDirection == 5) then
                        lastRailPosition = posAdd(lastRailPosition, 1, 1)
                        needDiagonal = not needDiagonal
                    elseif (railDirection == 6) then
                        lastRailPosition = posAdd(lastRailPosition, 2, 0)
                    elseif (railDirection == 7) then
                        lastRailPosition = posAdd(lastRailPosition, 1, -1)
                        needDiagonal = not needDiagonal
                    end
                end
            else
                if ((curvedRail > 0) and (straightRail > 0)) then
                    if needDiagonal then
                        placeRail(train, lastRailPosition.x, lastRailPosition.y, railDirection, "straight-rail")
                        if (railDirection == 1) then
                            lastRailPosition = posAdd(lastRailPosition, -1, -1)
                        elseif (railDirection == 3) then
                            lastRailPosition = posAdd(lastRailPosition, -1, 1)
                        elseif (railDirection == 5) then
                            lastRailPosition = posAdd(lastRailPosition, 1, 1)
                        elseif (railDirection == 7) then
                            lastRailPosition = posAdd(lastRailPosition, 1, -1)
                        end
                    end
                    for i = 1, 16, 1 do
                        if (railDirection == curves[i].raildirection) and (wantedDirection == curves[i].wanteddirection) then
                            --game.player.print("Curves rail #" .. i .. "x = " .. lastRailPosition.x + curves[i].xoffset .. " y = " .. lastRailPosition.y + curves[i].yoffset)
                            local success = false
                            success = placeRail(train, lastRailPosition.x + curves[i].xoffset, lastRailPosition.y + curves[i].yoffset, curves[i].curvedir, "curved-rail")
                            if ((curves[i].corner == 1) and success) then
                                placeRail(train, lastRailPosition.x + curves[i].cornerx, lastRailPosition.y + curves[i].cornery, curves[i].cornerr, "straight-rail")
                            end
                            playerInfo[index].railDirection = wantedDirection
                            lastRailPosition.x = lastRailPosition.x + curves[i].xmove
                            lastRailPosition.y = lastRailPosition.y + curves[i].ymove
                            needDiagonal = false
                            break
                        end
                    end
                end
            end
            --game.player.print("Next position x = " .. lastRailPosition.x .. " y = " .. lastRailPosition.y)
        end
    else
        local trainDirection = math.abs(math.floor(player.character.vehicle.orientation * 8 + 0.5) - 8) % 8
        local isHaveRail = false
        local railFindArea = {{playerPosition.x - 0.5, playerPosition.y - 0.5}, {playerPosition.x + 0.5, playerPosition.y + 0.5}}
        local poleFindArea = {{playerPosition.x - 30, playerPosition.y - 30}, {playerPosition.x + 30, playerPosition.y + 30}}
        local foundRail = false
        --Player.print("Player position x = " .. playerPosition.x .. " y = " .. playerPosition.y)
        for _, entity in ipairs(game.findentitiesfiltered{area = railFindArea, type = "rail"}) do
            --Player.print("Found rail " .. entity.name .. " x = " .. entity.position.x .. " y = " .. entity.position.y)
            if (entity.name == "straight-rail") then
                --Player.print("railDirection = " .. entity.direction)
                if (entity.direction % 4 == trainDirection % 4) then
                    lastRailPosition = entity.position
                    if (trainDirection % 2 == 0) then
                        lastRailPosition = entity.position
                    else
                        local x = math.floor(playerPosition.x)
                        local y = math.floor(playerPosition.y)
                        if x % 2 == 0 and y % 2 == 1 then
                            lastRailPosition.x = x + 0.5
                            lastRailPosition.y = y + 0.5
                        elseif x % 2 == 1 and y % 2 == 0 then
                            lastRailPosition.x = x - 0.5
                            lastRailPosition.y = y - 0.5
                        elseif x % 2 == 1 and y % 2 == 1 then
                            lastRailPosition.x = x + 0.5
                            lastRailPosition.y = y + 0.5
                        else
                            lastRailPosition.x = x + 1.5
                            lastRailPosition.y = y - 0.5
                        end
                    end
                    if #playerInfo > 0 then
                        playerInfo[index].railDirection = trainDirection
                        foundRail = true
                        needDiagonal = false
                        break
                    else
                        break
                    end
                end
            elseif (entity.name == "curved-rail") then
                -- TODO
                lastRailPosition = entity.position
                -- railDirection = ??
                foundRail = true
            end
        end
        local distanceForPole
        local minDistance = 99999
        local foundPole = false
        for _, entity in ipairs(game.findentitiesfiltered{area = poleFindArea, name = "big-electric-pole"}) do
            distanceForPole = distance(entity.position, playerPosition)
            if (minDistance > distanceForPole) then
                lastBigPolePosition = entity.position
                lastCheckPole.x = lastBigPolePosition.x
                lastCheckPole.y = lastBigPolePosition.y
                minDistance = distanceForPole
                foundPole = true
                -- Player.print("Found Pole!!")
            end
        end
        if (not foundPole) then
            -- Player.print("Initial Pole!!")
            lastBigPolePosition = posAdd(lastRailPosition, -50, -50)
            lastCheckPole = posAdd(lastRailPosition, polePlacement.data[trainDirection+1].x, polePlacement.data[trainDirection+1].y)
        end
        --Player.print("trainDirection = " .. trainDirection)
        --Player.print("last rail x = " .. lastRailPosition.x .. " y = " .. lastRailPosition.y)
        if #playerInfo > 0 then
            playerInfo[index].active = foundRail
        end
    end
end

game.onevent(defines.events.ontick, function(event)
    for index, player in pairs(game.players) do
        if game.player.character and game.player.character.name ~= "fatcontroller" and game.player.character.vehicle and game.player.character.vehicle.name == "rail-layer" then
            railLying(player, index)
        else
            playerInfo[index] = {active = false, railDirection = nil}
        end
    end
end)