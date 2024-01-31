-- launcher.lua
local Navigator = require ('handylib') -- Replace with the path to the handy module

-- Variables
local cursorImage
local moveDelay = 0.2
local lastMoveTime = 0
local buttonWidth = 64
local buttonHeight = 64
local totalButtons = 3
local visibleButtonsCount = 2
local currentButtonIndex = 1
local startX, startY
local buttonList = {"reneButton", "captainButton", "vasButton"} -- Add more button names as needed
for k,v in ipairs(buttonList) do print(k,v)end
-- launcher table
launcher = {}

function launcher.load()
        Navigator = Navigator:new()

    local msfButton = love.graphics.newImage('assets/msfButton.png')
    local bettercapButton = love.graphics.newImage('assets/bettercapButton.png')
    local vasButton = love.graphics.newImage('assets/vasButton.png')


      -- Initialize the Navigator and load specific button images...
      local windowWidth, windowHeight = love.graphics.getDimensions()
      startX = windowWidth / 4 - buttonWidth / 2 - 140
      startY = windowHeight / 2 - (totalButtons * buttonHeight + (totalButtons - 1) * 10) / 2
  
      -- Correct button positions
      local buttonY1 = startY
      local buttonY2 = startY + buttonHeight + 10
  
      -- Add buttons in the same order as in buttonList
      Navigator:addButton("reneButton", "Rene", startX, buttonY1, {buttonWidth, buttonHeight}, msfButton, function() rena.dialog() end)
      Navigator:addButton("captainButton", "Captain", startX, buttonY2, {buttonWidth, buttonHeight}, bettercapButton, function() print("pressed Captain") end)
      Navigator:addButton("vasButton", "Malfina", startX, buttonY2, {buttonWidth, buttonHeight}, vasButton, function() print("pressed Malfina") end)
  

    -- Load the cursor image
    cursorImage = love.graphics.newImage('assets/pointer.png')
    if not cursorImage then
        error("Failed to load 'assets/pointer.png'")
    end

    -- Initialize the cursor to the first button
    Navigator.cursor = 1
end

function launcher.update(dt)
    lastMoveTime = lastMoveTime + dt

    if lastMoveTime >= moveDelay then
        if love.keyboard.isDown('down') then
            Navigator.cursor = math.min(Navigator.cursor + 1, totalButtons)
            lastMoveTime = 0
        elseif love.keyboard.isDown('up') then
            Navigator.cursor = math.max(Navigator.cursor - 1, 1)
            lastMoveTime = 0
        end
    end
end



function launcher.draw()
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white

    -- Draw only the visible buttons based on the currentButtonIndex
    for i = 1, visibleButtonsCount do
        local btnIndex = (currentButtonIndex + i - 1) % totalButtons
        btnIndex = (btnIndex == 0) and totalButtons or btnIndex -- Adjust for 0 index
        local buttonName = buttonList[btnIndex]
        local btn = Navigator:buttonExists(buttonName)
        if btn then
            local yPos = startY + (i - 1) * (buttonHeight + 10)
            love.graphics.draw(btn.image, btn.x, yPos)
            love.graphics.print(btn.text, btn.x + 20, yPos + 10)
        else
            print("Button not found:", buttonName)
        end
    end




    -- Draw cursor logic...
    local selectedButton = Navigator:buttonExists(buttonList[Navigator.cursor])
    if selectedButton then
        local cursorX = selectedButton.x + buttonWidth + 10 -- 10 pixels space from the right edge of the button
        local cursorY = (Navigator.cursor == currentButtonIndex) and startY or (startY + buttonHeight + 10)
        love.graphics.draw(cursorImage, cursorX, cursorY)
    else
        -- Debug: Draw a rectangle if the cursor position is not found
        local cursorDebugY = startY + (Navigator.cursor - 1) * (buttonHeight + 10)
        love.graphics.rectangle("line", startX + buttonWidth / 2 + 10, cursorDebugY, 20, 20) -- Small square as a cursor placeholder
    end
end


function launcher.keypressed(key)
    -- Navigation logic
    if key == 'up' then 
        Navigator.cursor = Navigator.cursor - 1
        if Navigator.cursor < 1 then
            Navigator.cursor = totalButtons
        end
        currentButtonIndex = Navigator.cursor
        lastMoveTime = 0
    elseif key == "down" then
        Navigator.cursor = Navigator.cursor + 1
        if Navigator.cursor > totalButtons then
            Navigator.cursor = 1
        end
        currentButtonIndex = Navigator.cursor
        lastMoveTime = 0
    end

    -- Button action triggering logic
    if key == 'a' then
        local buttonName = buttonList[Navigator.cursor]
        if buttonName then
            Navigator:callButtonName(buttonName)
        end
    end
end


-- function launcher.keypressed(key)

--     if key == 'up' then 
--         Navigator.cursor = Navigator.cursor - 1
--         if Navigator.cursor < 1 then
--             Navigator.cursor = totalButtons
--         end
--         currentButtonIndex = Navigator.cursor
--         lastMoveTime = 0
--     end

--     if key == "down" then
--         Navigator.cursor = Navigator.cursor + 1
--         if Navigator.cursor > totalButtons then
--             Navigator.cursor = 1
--         end
--         currentButtonIndex = Navigator.cursor
--         lastMoveTime = 0
--     end



--     if key == 'a' or key == 'b' then
--         local buttonName = buttonList[Navigator.cursor]
--         if buttonName then
--             Navigator:callButtonName(buttonName)
--         end
--     end
-- end


-- function launcher.keypressed(key)
--     if key == 'up' then 
--     end
--     if key == "down" then
--     end

    
--     if key == 'a' or key == 'b' then
--         local buttonName = buttonList[Navigator.cursor]
--         if buttonName then
--             Navigator:callButtonName(buttonName)
--         end
--     end
-- end


return launcher
