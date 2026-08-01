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
        m.shipSpecsText.text = craft.name + Chr(10) + Chr(10) + "CLASS  " + UCase(craft.type) + Chr(10) + "SPEED  " + craft.speed.ToStr() + " / 10" + Chr(10) + "HANDLING  " + UCase(craft.handling)
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

    planetNames = []
    if galaxy.planets <> invalid
        for each planet in galaxy.planets
            planetNames.Push(planet.name)
        end for
    end if
    if planetNames.Count() > 0
        m.planetaryManifestList.text = planetNames.Join("  •  ")
    else
        m.planetaryManifestList.text = "No destinations are mapped yet."
    end if

    events = BrightBound_GetUpcomingEvents(galaxy)
    if events.Count() > 0
        nextEvent = events[0]
        eventLabel = nextEvent.title
        if nextEvent.fictional = true then eventLabel = eventLabel + " (Fictional)"
        m.eventTickerText.text = "NEXT EVENT  " + nextEvent.date + "  •  " + eventLabel
    else
        m.eventTickerText.text = "No upcoming events in this route catalog."
    end if
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
