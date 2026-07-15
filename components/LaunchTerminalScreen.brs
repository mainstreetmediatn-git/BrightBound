sub Init()
    m.shipSpecsText = m.top.FindNode("shipSpecsText")
    m.galaxyTitle = m.top.FindNode("galaxyTitle")
    m.galaxyDesc = m.top.FindNode("galaxyDesc")
    m.planetaryManifestList = m.top.FindNode("planetaryManifestList")
    m.eventTickerText = m.top.FindNode("eventTickerText")
    m.spacecrafts = BrightBound_LoadSpacecrafts()
    m.galaxies = BrightBound_LoadGalaxies()
    m.selectedShipIdx = 0
    m.selectedGalaxyIdx = 0
    RenderTerminalView()
    m.top.SetFocus(true)
end sub

sub RenderTerminalView()
    if m.spacecrafts.Count() = 0
        m.shipSpecsText.text = "No spacecraft data is available."
    else
        craft = m.spacecrafts[m.selectedShipIdx]
        m.shipSpecsText.text = "Model: " + craft.name + Chr(10) + Chr(10) + "Drive: " + UCase(craft.type) + Chr(10) + "Speed: " + craft.speed.ToStr() + "/10" + Chr(10) + "Handling: " + craft.handling
    end if

    if m.galaxies.Count() = 0
        m.galaxyTitle.text = "No galaxy data"
        m.galaxyDesc.text = ""
        m.planetaryManifestList.text = ""
        m.eventTickerText.text = ""
        return
    end if

    galaxy = m.galaxies[m.selectedGalaxyIdx]
    m.galaxyTitle.text = galaxy.name
    m.galaxyDesc.text = galaxy.description

    manifestText = ""
    for each planet in galaxy.planets
        moonNames = "None"
        if planet.moons.Count() > 0 then moonNames = planet.moons.Join(", ")
        manifestText = manifestText + planet.name + " - " + planet.type + " - Moons: " + moonNames + Chr(10)
    end for
    m.planetaryManifestList.text = manifestText

    eventsText = ""
    events = BrightBound_GetUpcomingEvents(galaxy)
    for each eventItem in events
        label = eventItem.title
        if eventItem.fictional = true then label = label + " (Fictional)"
        eventsText = eventsText + eventItem.date + " - " + label + Chr(10)
    end for
    if eventsText = "" then eventsText = "No upcoming events in this catalog."
    m.eventTickerText.text = eventsText
end sub

function WrapIndex(value as Integer, count as Integer) as Integer
    if count <= 0 then return 0
    while value < 0
        value = value + count
    end while
    return value mod count
end function

sub RequestLaunch()
    if m.spacecrafts.Count() = 0 or m.galaxies.Count() = 0
        m.eventTickerText.text = "A spacecraft and galaxy are required before launch."
        return
    end if
    craft = m.spacecrafts[m.selectedShipIdx]
    galaxy = m.galaxies[m.selectedGalaxyIdx]
    m.top.launchRequested = {
        shipId: craft.id
        shipName: craft.name
        galaxyId: galaxy.id
        galaxyName: galaxy.name
    }
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "left" and m.spacecrafts.Count() > 0
        m.selectedShipIdx = WrapIndex(m.selectedShipIdx - 1, m.spacecrafts.Count())
        RenderTerminalView()
        return true
    else if key = "right" and m.spacecrafts.Count() > 0
        m.selectedShipIdx = WrapIndex(m.selectedShipIdx + 1, m.spacecrafts.Count())
        RenderTerminalView()
        return true
    else if key = "up" and m.galaxies.Count() > 0
        m.selectedGalaxyIdx = WrapIndex(m.selectedGalaxyIdx - 1, m.galaxies.Count())
        RenderTerminalView()
        return true
    else if key = "down" and m.galaxies.Count() > 0
        m.selectedGalaxyIdx = WrapIndex(m.selectedGalaxyIdx + 1, m.galaxies.Count())
        RenderTerminalView()
        return true
    else if key = "OK"
        RequestLaunch()
        return true
    else if key = "back"
        m.top.closeRequested = true
        return true
    end if
    return false
end function
