local interact = {}

function interact.planetNavigation(key)
    if key == ('up') then
        navi_ui.planetSelectUp()

    end
    if key == ('down') then
        navi_ui.planetSelectDown()

    end
    if key == ('a') then
        navi_ui.toggleDisplayDetails()
        currentFocusStateIndex = 5 -- switch to launcher after selecting planet

    end
    if key == ('b') then
        currentFocusStateIndex = 1 
    end
end

function interact.gridNavigation(key)

    if key == ('up') then
        GridMenu.navigateGridUp()

    end
    if key == ('down') then
        GridMenu.navigateGridDown()

    end
    if key == ('left') then
        GridMenu.navigateGridLeft()

    end
    if key == ('right') then
        GridMenu.navigateGridRight()

    end
    if key == ('a') then
        OptionsMenu.showOptions()
        OptionsMenu.loadModuleInfo()
        currentFocusStateIndex = 3

    end
end

return interact
