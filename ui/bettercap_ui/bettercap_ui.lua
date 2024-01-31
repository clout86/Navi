local bettercap_ui = {}
local Talkies = require("lib.talkies")
local BettercapAPI = require("lib.BettercapAPI")
local api = BettercapAPI:new("localhost", 8081, "pakemon", "pakemon")
local cptImage = love.graphics.newImage("assets/captain.png")  -- Ensure this is a loaded image, not a path string

-- Function to trigger the dialogue
function bettercap_ui.showMenu()
    local options = {
        {"Net Probe On", function() bettercap_ui.net_probe_on() end},
        {"Net Probe Off", function() bettercap_ui.net_probe_off() end},
        {"Syn Scan", function() bettercap_ui.syn_scan(selectedPlanet.ipv4) end},
        {"Stop Syn Scan", function() bettercap_ui.syn_scan_stop() end}
    }

    Talkies.say("Select an Option", "", {
        image = cptImage,
        options = options,
        onselect = function(dialog, index)
            options[index][2]()  -- Execute the function associated with the option
        end
    })
end


-- Define the interact function for bettercap_ui
function bettercap_ui.interact(dt)
    -- Interaction logic for BETTERCAP_MENU_STATE
    if Talkies.isOpen() then
        if love.keyboard.isDown('up') then
            Talkies.prevOption()
        elseif love.keyboard.isDown('down') then
            Talkies.nextOption()
        elseif love.keyboard.isDown('a') or love.keyboard.isDown('return') then
            Talkies.onAction()
        end
    end
end

-- Define the draw function for bettercap_ui
function bettercap_ui.draw()
 
end

function bettercap_ui.net_probe_on()
    local command = '{"cmd": "net.probe on"}'
    local success, commandResponse = pcall(api.postCommand, api, "/api/session", command)
    -- Handle success or failure
end

function bettercap_ui.net_probe_off()
    local command = '{"cmd": "net.probe off"}'
    local success, commandResponse = pcall(api.postCommand, api, "/api/session", command)
    -- Handle success or failure
end

function bettercap_ui.syn_scan(ipAddress)
    local command = string.format('{"cmd": "syn.scan %s"}', ipAddress)
    local success, commandResponse = pcall(api.postCommand, api, "/api/session", command)
    -- Handle success or failure
end

function bettercap_ui.syn_scan_stop()
    local command = '{"cmd": "syn.scan stop"}'
    local success, commandResponse = pcall(api.postCommand, api, "/api/session", command)
    -- Handle success or failure
end

-- Return the module as an element for the uiElements table
return bettercap_ui
