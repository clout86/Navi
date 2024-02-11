-- local OptionsMenu = require("OptionsMenu")
GridMenu = {}

-- Grid Menu Configuration
local allExploits = {} -- Store all exploit infos here
local menuItems = {} -- Items for the current page

local totalPages
local selectedItem = 1
local itemsPerPage = 18
local currentPage = 1
local rows = 6
local cols = 3
local cellWidth = 100
local cellHeight = 50

-- Load exploits from a file
function GridMenu.loadGrimoire(filename)
    if love.filesystem.getInfo(filename) then
        for line in love.filesystem.lines(filename) do
            local name, module_type, full_module_name = line:match("([^,]+),([^,]+),([^,]+)")
            table.insert(allExploits, {
                name = name,
                module_type = module_type,
                full_module_name = full_module_name
            })
        end
    end
    totalPages = math.ceil(#allExploits / itemsPerPage)
end

function GridMenu.populateMenuItems()
    local startItem = (currentPage - 1) * itemsPerPage + 1
    local endItem = math.min(startItem + itemsPerPage - 1, #allExploits)
    menuItems = {}
    for i = startItem, endItem do
        table.insert(menuItems, allExploits[i])
    end
end

function GridMenu.getSelectedItem()
    return menuItems[selectedItem]
end

function GridMenu.getMenuItems()
    print("MENUITEMS ", menuItems)
    for k, v in pairs(menuItems) do
        print(k, v)
    end
    return menuItems
end

function GridMenu.toggleGridVisibility()
    isGridVisible = not isGridVisible
end

function GridMenu.showGrid()
    isGridVisible = true
end

function GridMenu.hideGrid()
    isGridVisible = false
end

-- Grid Navigation Functions
function GridMenu.navigateGridRight()
    if selectedItem < #menuItems then
        selectedItem = selectedItem + 1
    elseif currentPage < totalPages then
        currentPage = currentPage + 1
        selectedItem = 1
        GridMenu.populateMenuItems() -- Repopulate menu items for the new page
    end
end

function GridMenu.navigateGridLeft()
    -- 
    if selectedItem > 1 then
        selectedItem = selectedItem - 1
    elseif currentPage > 1 then
        currentPage = currentPage - 1
        selectedItem = itemsPerPage -- Set to the last item of the previous page
        GridMenu.populateMenuItems() -- Repopulate menu items for the new page
    end
end

function GridMenu.navigateGridDown()
    local potentialNextItem = selectedItem + cols
    -- Check if the potential next item is still on the current page
    if potentialNextItem <= #menuItems then
        selectedItem = potentialNextItem
    end
    -- If the potential next item would go past the end of the list, loop back to the top
    if potentialNextItem > itemsPerPage then
        selectedItem = selectedItem - itemsPerPage
    end
end

function GridMenu.navigateGridUp()
    local potentialPrevItem = selectedItem - cols
    -- Check if the potential previous item is still on the current page
    if potentialPrevItem >= 1 then
        selectedItem = potentialPrevItem
    end
    -- If the potential previous item would go before the start of the list, loop to the bottom
    if potentialPrevItem < 1 then
        selectedItem = selectedItem + itemsPerPage
        if selectedItem > #menuItems then
            selectedItem = #menuItems
        end
    end
end

function GridMenu.getColumnOfSelectedItem(selectedItem, cols)
    return (selectedItem - 1) % cols + 1
end

function GridMenu.getNextPage(currentPage, itemsPerPage)
    local newPage = currentPage + 1
    local newSelectedItem = (newPage - 1) * itemsPerPage + 1
    return newPage, newSelectedItem
end

function GridMenu.resetToFirstPage()
    return 1, 1
end

function GridMenu.getPreviousPage(currentPage, itemsPerPage, cols)
    local newPage = currentPage - 1
    local newSelectedItem = newPage * itemsPerPage - (cols - 1)
    return newPage, newSelectedItem
end

function GridMenu.resetToLastPage(totalPages, totalItems, cols)
    local newPage = totalPages
    local newSelectedItem = totalItems - (cols - 1)
    return newPage, newSelectedItem
end

function GridMenu.isItemInCurrentPage(itemIndex, currentPage, itemsPerPage, totalItems)
    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, totalItems)
    return itemIndex >= startIndex and itemIndex <= endIndex
end

 

-- Grid Drawing Function
function GridMenu.drawGrid(startX, startY, rows, cols, cellWidth, cellHeight)

    local starX = startX or 400
    local startY = startY or 400
    local rows = rows or 6
    local cols = cols or 3
    local cellWidth = cellWidth or 100
    local cellHeight = cellHeight or 50

    if not isGridVisible then
        return
    end
    -- Determine the number of items in the last row for proper centering
    local itemsInLastRow = #menuItems % cols
    if itemsInLastRow == 0 and #menuItems > 0 then
        itemsInLastRow = cols -- If the last row is full, we use the maximum number of columns
    end

    -- Use the provided startX and startY as the starting position for the grid
    local gridStartX = startX
    local gridStartY = startY
    for i, item in ipairs(menuItems) do
        local col = ((i - 1) % cols) + 1
        local row = math.floor((i - 1) / cols) + 1
        local x = gridStartX + (col - 1) * cellWidth
        local y = gridStartY + (row - 1) * cellHeight

        love.graphics.setColor(i == selectedItem and {1, 0, 0} or {0, 1, 1, 0.85})
        love.graphics.rectangle("fill", x, y, cellWidth, cellHeight)

        -- Set the scissor to clip text within the button's area
        love.graphics.setScissor(x, y, cellWidth, cellHeight)

        -- Set the color for the text
        love.graphics.setColor(i == selectedItem and {0, 0, 0} or {0, 0, 0})

        -- Print the item's name
        love.graphics.print(item.name, x + 10, y + cellHeight / 2 - 7)

        -- Disable the scissor after drawing the text
        love.graphics.setScissor()
    end

    love.graphics.setColor(1, 1, 1)
end


return GridMenu

