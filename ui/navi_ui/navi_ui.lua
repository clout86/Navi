-- lua deps for love2d
local Talkies = require("lib.talkies")
local Camera = require("lib.camera")

local camera = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

-- custom lua deps
 metasploit = require("lib.metasploit")
 authenticate = require("lib.auth")

 url = "http://localhost:55552/api/1.0"
 username = "pakemon"
 password = "pakemon"

-- Authenticate and get the token for msfrpcd
 token = authenticate(url, username, password)

 BettercapAPI = require("lib.BettercapAPI")
 api = require("lib.BettercapAPI"):new("localhost", 8081, "pakemon", "pakemon")



navi_ui = {}


-- Menu and selection variables
local selectedPlanetIndex = 1 -- Default selected planet index

local planetInfo = false
local currentTableIndex = 1
local currentItemIndex = 1
-- local nestedTables = {}  -- List of nested table names

local displayStartIndex = 1
-- local maxDisplayCount = 20
local maxDisplayCount = 100

local selectedOptionIndex = 1


-- Global variables

navi_ui.ship = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    speed = 200, -- pixels per second
    image = nil
}

function navi_ui.interact(dt)


    if love.keyboard.isDown('d') then
        camera:zoom(1 + 2 * dt) -- Zoom in
    elseif love.keyboard.isDown('c') then
        camera:zoom(1 - 2 * dt) -- Zoom out
    end
end

function  navi_ui.fetchLanStructure(api)
    local response = api:request("/api/session/lan", "GET")
    if response and response.hosts then
        return response.hosts -- Return all hosts
    end
    return nil
end
function  navi_ui.runActive(dataTable, currentPlanets)
    currentPlanets = currentPlanets or {} -- Fallback to an empty table if not provided

    local function buildLuaTable(dataTable)
        local hostTable = {}
        local semiMajorAxis = 50 -- Starting value for the first host
        local angle = 0
        local speed = .3
        local eccentricity = .5

        for _, hostData in ipairs(dataTable) do
            local host = nil

            -- Check if this host already exists in currentPlanets
            for _, currentPlanet in ipairs(currentPlanets) do
                if currentPlanet.mac == hostData.mac then
                    host = currentPlanet
                    break
                end
            end

            -- If host is not found in currentPlanets, create a new planet
            if not host then
                host = {}
                host.semiMajorAxis = semiMajorAxis
                host.angle = angle
                host.speed = speed
                host.eccentricity = eccentricity

                -- Update properties for the next host
                angle = math.random() * 360
                semiMajorAxis = semiMajorAxis + math.random(10, 35)
                if semiMajorAxis > 400 then
                    semiMajorAxis = math.ceil(math.random(250, 400))
                end
            end

            -- Assign or update host-specific data
            host.mac = hostData.mac
            host.hostname = hostData.hostname
            host.ipv4 = hostData.ipv4

            -- Processing satellites (ports)
            if not host.satellites then
                host.satellites = {}
            end

            if hostData.meta and hostData.meta.values and hostData.meta.values.ports then
                for portNumber, portData in pairs(hostData.meta.values.ports) do
                    local satelliteExists = false
                    for _, satellite in ipairs(host.satellites) do
                        if satellite.name == tostring(portNumber) then
                            satelliteExists = true
                            break
                        end
                    end
                    if not satelliteExists then
                        table.insert(host.satellites, {
                            name = tostring(portNumber),
                            angle = math.random() * 360,
                            distance = 25,
                            speed = 1
                        })
                    end
                end
            end

            -- Add the processed host to hostTable
            table.insert(hostTable, host)
        end

        return hostTable
    end

    return buildLuaTable(dataTable)
end





function  navi_ui.updatePlanets(currentPlanets)
    local hosts = navi_ui.fetchLanStructure(api)
    if hosts then
        -- Sort hosts by a unique and consistent attribute, e.g., MAC address 
        table.sort(hosts, function(a, b)
            return a.mac < b.mac
        end)
        planets = navi_ui.runActive(hosts, currentPlanets)
    end
end

function  navi_ui.planetSelectDown(direction)
    selectedPlanetIndex = selectedPlanetIndex + 1
    if selectedPlanetIndex > #planets then
        selectedPlanetIndex = 1
    end
end
function  navi_ui.planetSelectUp()
    selectedPlanetIndex = selectedPlanetIndex - 1
    if selectedPlanetIndex < 1 then
        selectedPlanetIndex = #planets
    end
end

function  navi_ui.updatePlanetSelection(direction)
    selectedPlanetIndex = selectedPlanetIndex + direction
    if selectedPlanetIndex > #planets then
        selectedPlanetIndex = 1 -- Cycle back to the first planet
    elseif selectedPlanetIndex < 1 then
        selectedPlanetIndex = #planets -- Cycle to the last planet
    end
end

function  navi_ui.updateSelectedPlanet()
    if planets and #planets > 0 and selectedPlanetIndex <= #planets then
        selectedPlanet = planets[selectedPlanetIndex]
        -- Populate nestedTables based on selectedPlanet
        nestedTables = {} -- Reset nestedTables
        if selectedPlanet.meta and selectedPlanet.meta.values then
            for key, _ in pairs(selectedPlanet.meta.values) do
                table.insert(nestedTables, key)
            end
        end
    else
        selectedPlanet = nil
    end
end

function  navi_ui.findPlanetByIP(ipAddress)
    for _, planet in ipairs(planets) do
        if planet.ipv4 == ipAddress then
            return planet

        end
    end
    return nil
end

function  navi_ui.getPlanetCoordinates(ipAddress)
    for _, planet in ipairs(planets) do
        if planet.ipv4 == ipAddress then
            local x, y = navi_ui.calculateEllipticalOrbit(planet.semiMajorAxis, planet.eccentricity, planet.angle, 335)
            return sunX + x, sunY + y
        end
    end
    return nil, nil -- IP address not found among planets
end


function  navi_ui.toggleDisplayDetails()
    planetInfo = not planetInfo
end


-- use to manage how many planets are displayed in orbit 
function  navi_ui.togglePlanetDisplay()
    if maxDisplayCount ~= #planets then
        -- Save current state for toggling back
        prevMaxDisplayCount = maxDisplayCount
        prevDisplayStartIndex = displayStartIndex

        -- Set to display all planets
        maxDisplayCount = #planets
        displayStartIndex = 1
    else
        -- Restore previous state
        maxDisplayCount = prevMaxDisplayCount or 6
        displayStartIndex = prevDisplayStartIndex or 1
    end
end

---- maybe stuff for on orbit rail menu cycles
local angleShiftPerCycle = 5000 -- Defines how much the angle changes per cycle
function  navi_ui.cyclePlanets(direction)
    local angleShift = direction * angleShiftPerCycle
    for _, planet in ipairs(planets) do
        planet.angle = (planet.angle + angleShift) % 360
    end
end

-- function that defines orbit
function  navi_ui.calculateEllipticalOrbit(semiMajorAxis, eccentricity, angle, tiltAngle)
    local semiMinorAxis = semiMajorAxis * math.sqrt(1 - eccentricity ^ 2)
    local r = semiMajorAxis * (1 - eccentricity ^ 2) / (1 + eccentricity * math.cos(angle))
    local x = r * math.cos(angle)
    local y = r * math.sin(angle) * (semiMinorAxis / semiMajorAxis)

    -- Apply rotation for the tilt
    local tiltRadian = math.rad(tiltAngle)
    local rotatedX = x * math.cos(tiltRadian) - y * math.sin(tiltRadian)
    local rotatedY = x * math.sin(tiltRadian) + y * math.cos(tiltRadian)

    return rotatedX, rotatedY -- x and y coods 
end

function navi_ui.calculateOrbitPoints(semiMajorAxis, eccentricity, tiltAngle, numPoints)
    numPoints = numPoints or 100 -- Default number of points
    local points = {}
    for i = 0, numPoints - 1 do
        local angle = (i / numPoints) * 2 * math.pi
        local x, y = navi_ui.calculateEllipticalOrbit(semiMajorAxis, eccentricity, angle, tiltAngle)
        table.insert(points, x + sunX)
        table.insert(points, y + sunY)
    end
    return points
end

function  navi_ui.shipDeadzone()
    -- Camera follow logic
    local screen_width = love.graphics.getWidth()
    local screen_height = love.graphics.getHeight()
    -- Define the deadzone as 10% of the screen from the edge
    local deadzone_x = screen_width * .05
    local deadzone_y = screen_height * .05

    local player_x, player_y = navi_ui.ship.x, navi_ui.ship.y -- Player's position
    local cam_x, cam_y = camera:position() -- Camera's current position

    -- Calculate the distance of the player from the center of the screen
    local dist_x = math.abs((cam_x + screen_width / 2) - player_x)
    local dist_y = math.abs((cam_y + screen_height / 2) - player_y)

    -- Check if the player is within the deadzone
    if dist_x > screen_width / 2 - deadzone_x or dist_y > screen_height / 2 - deadzone_y then
        camera:lockPosition(player_x, player_y, camera.smooth.damped(5))
    end
end

function  navi_ui.detailsBox(selectedPlanet)
    if not selectedPlanet then
        return
    end

    local boxWidth, boxHeight = 300, 150
    local boxX, boxY = 10, 10 -- Top left corner of the box

    -- Set colors and draw the box
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight)
    love.graphics.setColor(1, 1, 1) -- White color for text and images

    -- Text details
    local textX = boxX + 10
    local textY = boxY + 10
    local textDetails = "Planet Details:\n"
    textDetails = textDetails .. "Name: " .. tostring(selectedPlanet.hostname) .. "\n"
    textDetails = textDetails .. "IP: " .. tostring(selectedPlanet.ipv4) .. "\n"
    love.graphics.print(textDetails, textX, textY)

    -- Calculate the position for the planet image within the box
    local planetImageScale = 0.3 -- Adjust scale as needed
    local imageWidth = planetSprite:getWidth() * planetImageScale
    local imageHeight = planetSprite:getHeight() * planetImageScale
    local imageX = boxX + boxWidth - imageWidth - 30 -- 30 pixels padding from the right edge of the box
    local imageY = boxY + (boxHeight - imageHeight) / 2 -- Vertically centered

    -- Draw the planet sprite
    love.graphics.draw(planetSprite, imageX, imageY, 0, planetImageScale, planetImageScale)

    -- Draw satellites orbiting the planet
    local satelliteScale = 3 -- Scale for satellites
    for _, satellite in ipairs(selectedPlanet.satellites) do
        local satelliteX, satelliteY = navi_ui.calculateEllipticalOrbit(satellite.distance * planetImageScale, 0,
            satellite.angle, 0)
        satelliteX, satelliteY = imageX + imageWidth / 2 + satelliteX, imageY + imageHeight / 2 + satelliteY

        -- Ensure satellites are drawn within the box
        if satelliteX >= boxX and satelliteX <= (boxX + boxWidth) and satelliteY >= boxY and satelliteY <=
            (boxY + boxHeight) then
            love.graphics.setColor(0, 255, 255) -- Color for satellites
            love.graphics.circle("fill", satelliteX, satelliteY, 5 * satelliteScale) -- Adjust size as needed
            love.graphics.setColor(1, 1, 1) -- Reset color
        end
    end

    -- Draw line from box to the planet's screen position
    local planetWorldX, planetWorldY = navi_ui.calculateEllipticalOrbit(selectedPlanet.semiMajorAxis,
        selectedPlanet.eccentricity, selectedPlanet.angle, 335)
    planetWorldX, planetWorldY = sunX + planetWorldX, sunY + planetWorldY

    -- Convert the world coordinates to screen coordinates using the camera
    local screenPlanetX, screenPlanetY = camera:cameraCoords(planetWorldX, planetWorldY)

    -- Draw a line from the bottom of the box to the actual planet's position on the screen
    love.graphics.line(boxX + boxWidth / 2, boxY + boxHeight, screenPlanetX, screenPlanetY)
end



function navi_ui.toggleLanVisibility()
    isLanVisible = not isLanVisible
end

function navi_ui.showLan()
    isLanVisible = true
end

function navi_ui.hideLan()
    isLanVisible = false
end

function  navi_ui.drawLan()
    if not isLanVisible then
        return
    end
    -- Draw static ellipse for opbit line
    love.graphics.setColor(0, 255, 255)
    local endIndex = math.min(displayStartIndex + maxDisplayCount - 1, #planets)
    for i = displayStartIndex, endIndex do
        local planet = planets[i]
        local x, y = navi_ui.calculateEllipticalOrbit(planet.semiMajorAxis, planet.eccentricity, 0, 335)
        love.graphics.ellipse("line", sunX, sunY, x, y)
    end

    -- Draw the sun centered
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(sunSprite, sunX - sunSprite:getWidth() * 0.1 / 2, sunY - sunSprite:getHeight() * 0.1 / 2, 0, 0.1,
        0.1)

    -- Draw planets and satellites
    for i = displayStartIndex, endIndex do
        local planet = planets[i]
        local planetX, planetY = navi_ui.calculateEllipticalOrbit(planet.semiMajorAxis, planet.eccentricity, planet.angle, 335)

        -- Draw the planet sprite centered on its orbit position
        love.graphics.draw(planetSprite, sunX + planetX - planetSprite:getWidth() * 0.1 / 2,
            sunY + planetY - planetSprite:getHeight() * 0.1 / 2, 0, 0.1, 0.1)

        -- Text placement for hostname to follow planet's orbit (no changes)
        local textX = sunX + planetX - planetSprite:getWidth() * 0.1 / 2
        local textY = sunY + planetY - planetSprite:getHeight() * 0.1 / 2
        love.graphics.print(planet.hostname, textX, textY)

        -- Draw ports as satellites on planets
        for _, satellite in ipairs(planet.satellites) do
            local satelliteX, satelliteY = navi_ui.calculateEllipticalOrbit(satellite.distance, 0, satellite.angle, 0)
            satelliteX, satelliteY = satelliteX + planetX, satelliteY + planetY
            love.graphics.setColor(0, 255, 255)
            love.graphics.circle("fill", sunX + satelliteX, sunY + satelliteY, 5)
            love.graphics.setColor(1, 1, 1)
        end

    end
end


function navi_ui.draw()
 
    camera:attach()
    navi_ui.drawLan()
    love.graphics.draw(navi_ui.ship.image, navi_ui.ship.x, navi_ui.ship.y)

    camera:detach()
    if #planets == 0 then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        local rectX = (screenWidth - 420) / 2 -- Center the rectangle
        local rectY = screenHeight * 0.1 -- 10% from the top
        local rectWidth = 420
        local rectHeight = 50
        love.graphics.setColor(0, 255, 255, 0.7) -- abstract this box for general messageBox
        love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight, 10, 10)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", rectX, rectY, rectWidth, rectHeight, 10, 10)

        love.graphics.printf("Searching for hosts", 0, rectY + 18, screenWidth, "center")
    end
    -- PLANET_DETAILS_STATE: Display details of the selected planet
    if gameState == PLANET_DETAILS_STATE and planets and selectedPlanetIndex and planets[selectedPlanetIndex] then
        local selectedPlanet = planets[selectedPlanetIndex]
        navi_ui.detailsBox(selectedPlanet)
    end
    -- for k,v in ipairs(planets) do print("PANETS: ", k, v) end

    love.graphics.setColor(1, 1, 1) -- set color to white
    love.graphics.setBackgroundColor(0.16, 0.16, 0.16) -- dark grey background


end



return navi_ui

