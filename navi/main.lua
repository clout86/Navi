Talkies = require("lib.talkies")
Camera = require("lib.camera")
camera = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

-- custom lua deps
metasploit = require("lib.metasploit")
authenticate = require("lib.auth")
navi_ui = require("ui.navi_ui.navi_ui")
bettercap_ui = require("ui.bettercap_ui.bettercap_ui")

local GridMenu = require("GridMenu")
local OptionsMenu = require("OptionsMenu")
local launcher = require("launcher")
local interact = require("Interact")

url = "http://localhost:55552/api/1.0"
username = "pakemon"
password = "pakemon"

-- Authenticate and get the token for msfrpcd
token = authenticate(url, username, password)

BettercapAPI = require("lib.BettercapAPI")
api = require("lib.BettercapAPI"):new("localhost", 8081, "pakemon", "pakemon")

uiElements = {}
planets = {}

------------------
local useDatabase = false
local useActive = true
local runActive

local module_info

-- Pagination variables
local moduleInfoLinesPerPage = 20 -- Set the number of lines you want to display per page
local currentModuleInfoPage = 1
local totalModuleInfoPages = 1

-- UI state variables
local selectedOptionIndex = 1
local scrollOffset = 0
local maxOptionsOnScreen = 10
-- Helper function to get the number of options for navigation purposes

local networkDataTimer = 0
local networkDataFetchInterval = 5 -- Fetch data every 5 seconds

-- Variables to maintain the UI state
local focusedIndex = 1 -- Default focus on the first UI element

-- Menu and selection variables
local selectedPlanetIndex = 1 -- Default selected planet index

local planetInfo = false
local currentTableIndex = 1
local currentItemIndex = 1

local displayStartIndex = 1
local maxDisplayCount = 100

local selectedOptionIndex = 1

keysPressed = {}

function love.keypressed(key)
    keysPressed[key] = true
end

function love.keyreleased(key)
    keysPressed[key] = false
end

-- This function will create a nested table from the given table t
function walk_table(t, depth)
    local result = {}
    depth = depth or 0

    -- Avoid going too deep into nested tables
    if depth > 5 then
        return "..."
    end

    for k, v in pairs(t) do
        if type(v) == "table" then
            -- Recursively process nested tables
            result[k] = walk_table(v, depth + 1)
        else
            -- Directly assign non-table values
            result[k] = v
        end
    end
    return result
end

function loadModules(directory)
    local files = love.filesystem.getDirectoryItems(directory)
    for _, file in ipairs(files) do
        local folderPath = directory .. file
        if love.filesystem.getInfo(folderPath, "directory") then
            -- The module name is the same as the folder name
            local modulePath = folderPath .. "/" .. file
            if love.filesystem.getInfo(modulePath .. ".lua") then
                print("Loading module:", modulePath) -- Debug print
                local uiModule = require(modulePath)
                --  table.insert(uiElements, uiModule)
            end
        end
    end
end

function love.load()
    isLanVisible = true
    GridMenu.loadGrimoire("exploit_names.txt")
    GridMenu.populateMenuItems()

    launcher.load()

    loadModules("ui/")

    navi_ui.ship = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        speed = 200, -- pixels per second
        image = nil
    }

    navi_ui.ui_data = {
        name = "",
        description = "",
        references = {},
        options = {}
    }

    -- for editing options return. 
    navi_ui.ui_data.editing = {
        active = false,
        type = nil,
        key = nil
    }

    networkDataTimer = 0
    networkDataFetchInterval = 5

    -- Initialize or integrate UI elements 
    isOrbiting = true

    -- login to bettercap and walk the lan
    local hosts = navi_ui.fetchLanStructure(api)
    if hosts then
        planets = navi_ui.runActive(hosts, currentPlanets)
    end
    -- Load the sprite/background
    sunSprite = love.graphics.newImage("assets/sun.png")
    planetSprite = love.graphics.newImage("assets/planet.png")
    background = love.graphics.newImage("assets/background.png")
    navi_ui.ship.image = love.graphics.newImage("assets/ship.png")
    -- music 
    music = love.audio.newSource("assets/music.mp3", "stream")

    -- Define the sun's position
    sunX, sunY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

    -- -- Adjust sun placement because i'm lazy and suck at maths
    sunX = sunX + 240 -- this should be more dynamic playcement like above
    sunY = sunY - 140

    -- Initialize selected planet index
    selectedPlanetIndex = 1

    planetInfo = true
    bettercap_ui.showMenu()
    rena.dialog()

end

function netTimer(dt)
    networkDataTimer = networkDataTimer + dt

    if networkDataTimer >= networkDataFetchInterval then
        local hosts = navi_ui.fetchLanStructure(api)
        if hosts then
            local currentAngles = {}
            local currentPlanets = {} -- Initialize currentPlanets

            for i, planet in ipairs(planets) do
                table.insert(currentPlanets, planet) -- Copy current planets state
                currentAngles[i] = planet.angle
            end
            navi_ui.updatePlanets(currentPlanets) -- Pass currentPlanets to updatePlanets function
            navi_ui.updateSelectedPlanet()
        end
        networkDataTimer = 0 -- Reset the timer
    end
end
local FocusStates = {"SHIP_NAVI", "PLANET_NAVI", "OPTIONS_NAVI", "GRID_NAVI", "LAUNCHER", "TALKIES"}

currentFocusStateIndex = 1
currentFocusState = "SHIP_NAVI"

function love.update(dt)


    launcher.update(dt)
    --  DEBUG STUFF
   -- require("lib.lovebird").update()
    -- require("lurker").update()
    --  END DEBUG STUFF
    Talkies.update(dt)
    netTimer(dt)
    -- if not music:isPlaying() then
    --     --  love.audio.play( music )
    -- end
    navi_ui.shipDeadzone()


    if currentFocusStateIndex == 1 then
        if love.keyboard.isDown('up') then
            navi_ui.ship.y = navi_ui.ship.y - navi_ui.ship.speed * dt
        end
        if love.keyboard.isDown('down') then
            navi_ui.ship.y = navi_ui.ship.y + navi_ui.ship.speed * dt
        end
        if love.keyboard.isDown('left') then
            navi_ui.ship.x = navi_ui.ship.x - navi_ui.ship.speed * dt
        end
        if love.keyboard.isDown('right') then
            navi_ui.ship.x = navi_ui.ship.x + navi_ui.ship.speed * dt
        end
        if love.keyboard.isDown('a') then
            currentFocusStateIndex = 2
        end

        

    end

    navi_ui.interact(dt)  -- zoom in all states
    -- if false orbit stops
    if isOrbiting then
        -- Update the planets' angles
        for i, planet in ipairs(planets) do
            planet.angle = planet.angle + planet.speed * dt
        end

        for _, planet in ipairs(planets) do
            for _, satellite in ipairs(planet.satellites) do
                satellite.angle = satellite.angle + satellite.speed * dt
            end
        end
    end

end

function love.keypressed(key)
    -- Handling state switching
    if key == 'q' then
        currentFocusStateIndex = (currentFocusStateIndex - 2) % #FocusStates + 1
        print("CFSI ", currentFocusStateIndex)
    elseif key == 'e' then
        currentFocusStateIndex = currentFocusStateIndex % #FocusStates + 1
        print("CFSI ", currentFocusStateIndex)

    end

    -- Update the current focus state based on index
    local currentFocusState = FocusStates[currentFocusStateIndex]

    -- Call the appropriate function from the interact module based on the focus state

    if currentFocusStateIndex == 2 then
        interact.planetNavigation(key)
    elseif currentFocusStateIndex == 3 then

       OptionsMenu.optionsNavigation(key)
    elseif currentFocusStateIndex == 4 then
        interact.gridNavigation(key)
    elseif currentFocusStateIndex == 5 then
        launcher.keypressed(key)
    elseif currentFocusStateIndex == 6 then
        if key == 'up' then
            Talkies.prevOption()
        elseif key == 'down' then
            Talkies.nextOption()
        elseif key == 'a' then
            Talkies.onAction()        
        elseif key == 'b' then
            Talkies.clearMessages()
            currentFocusStateIndex = 5
    end
end
end

-- In your draw function, highlight the focused UI element
function love.draw()
    love.graphics.draw(background)


    launcher.draw()
    navi_ui.draw()
    Talkies.draw()
    OptionsMenu.drawOptions()
    GridMenu.drawGrid(400, 50)

end
