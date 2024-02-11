-- Description: Handy library for Love2D
-- A library that allows you to create and manage buttons and other GUI elements easily
--[[

- Buttons

     Methods:

        - addButton(name, text, x, y, size, image, callback)
        - removeButton(name)
        - checkButton(x, y)
        - buttonExists(name)
        - callButtonName(name)
        - callButtonIndex(index)

    Logic:

    A 400x240 navigation table is created, as well as a buttons table.
    The navigation table is used to check if a button exists at a certain position.
    The buttons table is used to store the button data.

    The buttons have a name, a text (the one appearing in the GUI itself), an image and a callback function
    that is called when the button is pressed.

    Every button occupies a certain area in the navigation table, based on the starting position
    and the size of the button. A 20x20 button at position 100,200 would occupy 20x20 cells in
    the navigation table starting from 100,200 to 120,220.

    Using the classic Love2D callback functions, is possible to check if a button is pressed, clicked,
    hovered, released and so on.

    Thanks to the cursor property it is also possible to navigate through the buttons using the dpad
    by increasing or decreasing the cursor value and using the callButtonIndex method.
    This is useful to enable a non-touch navigation system (or an hybrid one).

    Example:

    This snippet shows how to add a button to the GUI from any script that includes
    handylib.

        local addButton = function (name, text, image, callback, x, y)
            if not handy:buttonExists(name) then
                local testButtonImage = love.graphics.newImage(Program.Attributes.AssetsFolder .. image)
                local size_x = testButtonImage:getWidth()
                local size_y = testButtonImage:getHeight()
                handy:addButton(name, text, x, y, {size_x, size_y}, testButtonImage,
                                callback)
                local textPosition = {x + handy.buttons[name].size[1]/3, y + handy.buttons[name].size[2]/4}
                love.graphics.draw(handy.buttons[name].image, x, y)
                love.graphics.print(handy.buttons[name].text, textPosition[1], textPosition[2])
                return true
            end
            return false
        end

--]]

local handy = {
    cursor = 0,
    navigation = {},
    buttons = {}
}

-- ANCHOR Initializes the class first
function handy:new ()
        -- Creates the class instance
        local inst = {}
        setmetatable(inst, self)
        self.__index = self
        -- Creates a 400x240 navigation table
        for i = 1, 400 do
            self.navigation[i] = {}
            for j = 1, 240 do
                self.navigation[i][j] = nil
            end
        end
        -- Returns the class instance
        return inst
end

-- Derived classes
function handy:addButton(name, text, x, y, size, image, callback) -- Add a button to the navigation table
    -- Setting X
    for i = x, x + size[1] do
        -- Setting Y
        for j = y, y + size[2] do -- Assigning button name to the navigation table
            self.navigation[i][j] = name
        end
    end
    -- Adding button to the buttons table
    self.buttons[name] = {
        text = text,
        image = image,
        callback = callback,
        x = x,
        y = y,
        size = size
    }
end

function handy:removeButton(name) -- Allows to remove a button from the navigation table
    -- Checking if the button exists in the buttons table
    if self.buttons[name] ~= nil then
        local x = self.buttons[name].x
        local y = self.buttons[name].y
        local size = self.buttons[name].size
        -- Checking if the button exists in the navigation table and removing it
        -- Setting X
        for i = x, x + size[1] do
            -- Setting Y
            for j = y, y + size[2] do -- Assigning button name to the navigation table
                if self.navigation[i][j] == name then
                    self.navigation[i][j] = nil
                end
            end
        end
    end
end

function handy:checkButton(x, y) -- Allows to check if a button exists at cohordinates and returns its callback
    -- Checking if the button exists in the navigation table
    if self.navigation[x][y] ~= nil then
        -- Checking if the button exists in the buttons table
        if self.buttons[self.navigation[x][y]] ~= nil then
            -- Returning the callback
            print("Button found at " .. x .. ", " .. y .. " (" .. self.navigation[x][y] .. ")" )
            return self.buttons[self.navigation[x][y]].callback()
        end
    end
    return nil
end

function handy:buttonExists(name) -- Returns a button if it exists in the buttons table
    if self.buttons[name] ~= nil then
        return self.buttons[name]
    end
    return false
end

function handy:callButtonName(name) -- Allows to call a button by its name
    if self.buttons[name] ~= nil then
        self.buttons[name].callback()
        return true
    else
        print("[navigation] Button " .. name .. " not found")
        return false
    end
end

function handy:callButtonIndex(index) -- Allows to call a button in the button table
    print("[navigation] Calling button at index " .. index)
    -- Converting index to name
    local buttonName = ""
    for i in pairs(self.buttons) do
        if index == 1 then
            buttonName = i
            break
        end
        index = index - 1
    end
    -- Calling the button if it exists
    if buttonName ~= "" then
        print("[navigation] Calling button " .. buttonName)
        self.buttons[buttonName].callback()
        return true
    else
        print("[navigation] Button not found")
        return false
    end
end

-- !SECTION Navigation prototypes

-- Returns the handy object
local Navigator = handy:new()
return Navigator