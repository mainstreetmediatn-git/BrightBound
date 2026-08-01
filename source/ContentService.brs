function BrightBound_LoadJsonArray(path as String, key as String) as Object
    raw = ReadAsciiFile(path)
    if raw = invalid or raw = "" then return []
    parsed = ParseJson(raw)
    if parsed = invalid or type(parsed) <> "roAssociativeArray" then return []
    if parsed[key] = invalid or type(parsed[key]) <> "roArray" then return []
    return parsed[key]
end function

function BrightBound_LoadSpacecrafts() as Object
    return BrightBound_LoadJsonArray("pkg:/data/space_models.json", "spacecrafts")
end function

function BrightBound_LoadGalaxies() as Object
    return BrightBound_LoadJsonArray("pkg:/data/galaxies.json", "galaxies")
end function

function BrightBound_GetUpcomingEvents(galaxy as Object) as Object
    if galaxy = invalid or galaxy.events = invalid then return []
    now = CreateObject("roDateTime")
    today = now.ToISOString().Left(10)
    upcoming = []
    for each eventItem in galaxy.events
        if eventItem.date >= today then upcoming.Push(eventItem)
    end for
    return upcoming
end function
