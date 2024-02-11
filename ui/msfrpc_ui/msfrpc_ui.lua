rena = {}

-- for dialog
local Talkies = require("lib.talkies")

-- for msfrpcd
local metasploit = require("lib.metasploit")
local authenticate = require("lib.auth")

-- input handlers
local DropdownMenu = require("lib.DropdownMenu")
local keyboard = require("lib.keyboard")


   -- Load the image if needed
renaImage = love.graphics.newImage("assets/rena.png") 


function rena.getPreparedOptions()
    local preparedOptions = {}
    for key, option in pairs(ui_option_data.options) do
        -- Exclude options with nil values
        if option.value ~= nil then
            -- Directly assign the value to the key without type conversion
            preparedOptions[key] = option.value
        end
    end
    return preparedOptions
end


-- Function to execute a selected module with configured options
function rena.executeModule()
    local url = url or "http://localhost:55552/api/1.0"
    local username = username or "pakemon"
    local password = password or "pakemon"
    local token = authenticate(url, username, password)
    local selectedItem = GridMenu.getSelectedItem()
    local module_type = OptionsMenu.trim(selectedItem.module_type) -- trim is bug from input. 
    local module_name = OptionsMenu.trim(selectedItem.full_module_name)
    local options = rena.getPreparedOptions()
    local module_type = module_type or "exploit"   
    local loot = metasploit.module_execute(url, token, module_type, module_name, options)
end

function rena.updateTalkieMsfOptionDesc()
    local currentOption = OptionsMenu.getCurrentOptions() 
    local description = currentOption.desc or "No description available"
    Talkies.clearMessages()
    rena.updateTalkiesDialog("Option Description", description, renaImage)
end

function rena.updateTalkiesDialog(title, items, image)
    -- Use the refactored tableToString function to handle the conversion
    local content = OptionsMenu.tableToString(items)
    Talkies.say(title, content, {
        image = image or renaImage or nil
    })
end

--- when you select a dialog option, the text response should display in the messageBox not the talkie dialog.
local selectedTalkiesOptionIndex = 1
function rena.dialog()

    OptionsMenu.loadModuleInfo()

    -- Define dialogue options with corresponding functions --
    local dialogueOptions = {{"View Exploits", function()
        GridMenu.toggleGridVisibility()
        currentFocusStateIndex = 4

    end}, {"Exploit Options", function()
        OptionsMenu.loadModuleInfo()
        OptionsMenu.showOptions()
        currentFocusStateIndex = 3

    end}, {"Execute Module", function()
        rena.executeModule()

    end}, {"View Author", function()
        local authorText = OptionsMenu.tableToString(module_info.authors or {})
        rena.updateTalkiesDialog("Author", authorText or {})

    end}, {"View References", function()
        local referencesText = OptionsMenu.tableToString(module_info.references or {})
        rena.updateTalkiesDialog("References", referencesText)
         
    end}, {"View Platform", function()
        local platformText = OptionsMenu.tableToString(module_info.platform or {})
        rena.updateTalkiesDialog("Platform", platformText or "N/A") 
    end} -- more options 
    }

 
    -- Extract the option titles for display
    local formattedOptions = {}
    for _, option in ipairs(dialogueOptions) do
        table.insert(formattedOptions, option[1])
    end

    -- Ensure the selectedTalkiesOptionIndex is reset every time the dialogue is shown

    selectedTalkiesOptionIndex = 1

    function showOptionsDialogue() 

        Talkies.say("Rena", "Select an option:", {
            image = renaImage,
            options = dialogueOptions,
            onselect = function()
                -- Handle option selection
                dialogueOptions[selectedOption][2]()
            end
        })
    end

    Talkies.say("Rena: " .. module_info.name, module_info.description, {
        image = renaImage,
        oncomplete = function()
            -- Trigger the next dialog with options once the first dialog completes
            showOptionsDialogue()
        end

    })
end

return rena
