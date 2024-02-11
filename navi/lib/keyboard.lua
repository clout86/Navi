-- keyboard.lua
local keyboard = {
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
    currentIndex = 1,
    inputText = "",
    inputPosition = 1,
    boxWidth = 175,
    boxHeight = 30,
}

function keyboard.updateCharacterIndex(direction)
    if direction == "up" then
        keyboard.currentIndex = keyboard.currentIndex - 1
        if keyboard.currentIndex < 1 then
            keyboard.currentIndex = #keyboard.characters
        end
    elseif direction == "down" then
        keyboard.currentIndex = keyboard.currentIndex + 1
        if keyboard.currentIndex > #keyboard.characters then
            keyboard.currentIndex = 1
        end
    end
end

function keyboard.insertCharacter()
    local char = keyboard.characters:sub(keyboard.currentIndex, keyboard.currentIndex)
    keyboard.inputText = string.sub(keyboard.inputText, 1, keyboard.inputPosition - 1) ..
                         char ..
                         string.sub(keyboard.inputText, keyboard.inputPosition)
    keyboard.inputPosition = math.min(#keyboard.inputText + 1, keyboard.inputPosition + 1)
end

function keyboard.backspace()
    if keyboard.inputPosition > 1 then
        keyboard.inputText = string.sub(keyboard.inputText, 1, keyboard.inputPosition - 2) ..
                             string.sub(keyboard.inputText, keyboard.inputPosition)
        keyboard.inputPosition = math.max(1, keyboard.inputPosition - 1)
    end
end

function keyboard.handleInput(key)
    if key == "up" then
        keyboard.updateCharacterIndex("up")
    elseif key == "down" then
        keyboard.updateCharacterIndex("down")
    elseif key == "a" then
        keyboard.insertCharacter()
    elseif key == "b" then
        keyboard.backspace()
    end
end




function keyboard.draw(x, y)
    -- Draw the input box at the specified position
    love.graphics.setColor(0,0,0, .7)
    love.graphics.rectangle("fill", x, y, keyboard.boxWidth, keyboard.boxHeight)
    love.graphics.setColor(1,1,1)
    -- Calculate text width up to the input position
    local textUpToCursor = keyboard.inputText:sub(1, keyboard.inputPosition - 1)
    local cursorX = x + 5 + love.graphics.getFont():getWidth(textUpToCursor)

    -- Draw the input text before the cursor
    love.graphics.print(textUpToCursor, x + 5, y + 5)

    -- Get the next character and calculate its width
    local nextChar = keyboard.characters:sub(keyboard.currentIndex, keyboard.currentIndex)
    local nextCharWidth = love.graphics.getFont():getWidth(nextChar)

    -- Draw the input text after the cursor
    local textAfterCursor = keyboard.inputText:sub(keyboard.inputPosition)
    love.graphics.print(textAfterCursor, cursorX + nextCharWidth, y + 5)

    -- Draw the next character to be inserted at the cursor position (as the cursor)
    love.graphics.print(nextChar, cursorX, y + 5)
end

return keyboard

