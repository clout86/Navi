-- Message Window Function with Title Bar
local MessageWindow = {}

function MessageWindow.new(x, y, width, height, title)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
        title = title or "", -- Default title is empty
        text = "",
        font = love.graphics.getFont(), -- Default font
        titleBarHeight = 30 -- Height of the title bar
    }
end

function MessageWindow.setText(window, text)
    window.text = text
end

function MessageWindow.draw(window)
    -- Draw title bar
    love.graphics.setColor(0, 1, 1) -- Cyan color for the title bar
    love.graphics.rectangle("fill", window.x, window.y, window.width, window.titleBarHeight)

    -- Draw title text
    love.graphics.setColor(0, 0, 0) -- Black color for the title text
    love.graphics.print(window.title, window.x + 10, window.y + (window.titleBarHeight - window.font:getHeight()) / 2)

    -- Draw message window background
    love.graphics.setColor(1, 1, 1) -- White color for the background
    love.graphics.rectangle("fill", window.x, window.y + window.titleBarHeight, window.width, window.height - window.titleBarHeight)

    -- Draw message text
    love.graphics.setColor(0, 0, 0) -- Black color for the text
    love.graphics.printf(window.text, window.font, window.x, window.y + window.titleBarHeight, window.width)
end

return MessageWindow

-- Usage Example
-- local myWindow = MessageWindow.new(100, 100, 300, 150, "Window Title") -- x, y, width, height, title
-- MessageWindow.setText(myWindow, "This is a test message. It should wrap within the window size.")

-- function love.draw()
--     MessageWindow.draw(myWindow)
-- end
