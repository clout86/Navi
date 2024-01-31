-- DropdownMenu.lua
local DropdownMenu = {}

function DropdownMenu.load(enums, x, y, width, height)
    DropdownMenu.enums = enums or {}

    DropdownMenu.menu = {
        x = x or 100,
        y = y or 100,
        width = width or 200,
        height = height or 20,
        isOpen = true,
        selectedItem = 1
    }
end
function DropdownMenu.draw()
    local menu = DropdownMenu.menu
    local enums = DropdownMenu.enums

    -- Draw the selected item
    love.graphics.rectangle("fill", menu.x, menu.y, menu.width, menu.height)
    love.graphics.setColor(0, 0, 0)
    if enums[menu.selectedItem] then
        love.graphics.print(enums[menu.selectedItem], menu.x + 5, menu.y + 5)
    end
    love.graphics.setColor(1, 1, 1)

    -- Draw the menu items if the menu is open
    if menu.isOpen then
        local itemsToShow = 5 -- Number of items to show in the dropdown
        local startItem = math.max(menu.selectedItem - math.floor(itemsToShow / 2), 1)
        local endItem = math.min(startItem + itemsToShow - 1, #enums)

        for i = startItem, endItem do
            local enum = enums[i]
            love.graphics.rectangle("line", menu.x, menu.y + (i - startItem + 1) * menu.height, menu.width, menu.height)
            love.graphics.print(enum, menu.x + 5, menu.y + (i - startItem + 1) * menu.height + 5)
        end
    end
end



function DropdownMenu.keypressed(key)
    local menu = DropdownMenu.menu
    local enums = DropdownMenu.enums

    if key == "up" then
        if menu.isOpen then
            menu.selectedItem = math.max(1, menu.selectedItem - 1)
        end
    elseif key == "down" then
        if menu.isOpen then
            menu.selectedItem = math.min(#enums, menu.selectedItem + 1)
        end
    elseif key == "a" then
        menu.isOpen = not menu.isOpen  -- Toggle the menu open state
    elseif key == "b" and menu.isOpen then
        menu.isOpen = false
    end
end

return DropdownMenu
