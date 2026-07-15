sub Init()
    m.missionTitle = m.top.FindNode("missionTitle")
    m.missionStatus = m.top.FindNode("missionStatus")
    m.ship = m.top.FindNode("ship")
    m.prompt = m.top.FindNode("prompt")
    m.beacons = [m.top.FindNode("beacon0"), m.top.FindNode("beacon1"), m.top.FindNode("beacon2")]
    m.beaconLabels = [m.top.FindNode("beaconLabel0"), m.top.FindNode("beaconLabel1"), m.top.FindNode("beaconLabel2")]
    m.laneXs = [380, 915, 1440]
    m.selectedLane = 1
    m.collected = [false, false, false]
    m.questions = [
        { prompt: "Beacon 1: What is 2 + 2? Press LEFT for 4 or RIGHT for 5.", correctSide: "left" },
        { prompt: "Beacon 2: Which planet is our home? Press LEFT for Earth or RIGHT for Mars.", correctSide: "left" },
        { prompt: "Beacon 3: A frog begins life in water. Press LEFT for true or RIGHT for false.", correctSide: "left" }
    ]
    m.awaitingAnswer = false
    m.activeBeacon = -1
    RenderFlight()
    m.top.SetFocus(true)
end sub

sub OnJourneyConfigChanged()
    RenderFlight()
end sub

sub RenderFlight()
    config = m.top.journeyConfig
    shipName = "BrightBound craft"
    galaxyName = "the learning stars"
    if config <> invalid
        if config.shipName <> invalid then shipName = config.shipName
        if config.galaxyName <> invalid then galaxyName = config.galaxyName
    end if
    m.missionTitle.text = shipName + " - Journey to " + galaxyName
    m.missionStatus.text = "Knowledge beacons collected: " + CollectedCount().ToStr() + " / 3"
    m.ship.translation = [m.laneXs[m.selectedLane], 690]
    if not m.awaitingAnswer
        m.prompt.text = "Steer beneath a glowing beacon and press OK to scan it."
    end if

    for i = 0 to 2
        if m.collected[i]
            m.beacons[i].color = "0x4B6070FF"
            m.beaconLabels[i].color = "0xD7E2EAFF"
        else
            m.beacons[i].color = "0xFFE68AFF"
            m.beaconLabels[i].color = "0x07111FFF"
        end if
    end for
end sub

function CollectedCount() as Integer
    total = 0
    for each collectedItem in m.collected
        if collectedItem then total = total + 1
    end for
    return total
end function

sub StartBeaconQuestion()
    if m.collected[m.selectedLane]
        m.prompt.text = "That beacon is already part of your knowledge map. Choose another."
        return
    end if
    m.activeBeacon = m.selectedLane
    m.awaitingAnswer = true
    m.prompt.text = m.questions[m.activeBeacon].prompt
end sub

sub SubmitBeaconAnswer(side as String)
    if not m.awaitingAnswer then return
    questionItem = m.questions[m.activeBeacon]
    if side = questionItem.correctSide
        m.collected[m.activeBeacon] = true
        m.awaitingAnswer = false
        m.prompt.text = "Beacon secured! Your companion recorded the discovery."
        if CollectedCount() = 3
            CompleteJourney()
        else
            RenderFlight()
        end if
    else
        m.prompt.text = "That signal did not match. Try the other direction."
    end if
end sub

sub CompleteJourney()
    config = m.top.journeyConfig
    result = {
        completed: true
        beaconsCollected: 3
        shipId: ""
        galaxyId: ""
    }
    if config <> invalid
        if config.shipId <> invalid then result.shipId = config.shipId
        if config.galaxyId <> invalid then result.galaxyId = config.galaxyId
    end if
    m.missionStatus.text = "Journey complete - all knowledge beacons secured!"
    m.prompt.text = "Press OK to return to your pond with the discoveries."
    m.top.journeyCompleted = result
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if CollectedCount() = 3
        if key = "OK"
            m.top.closeRequested = true
            return true
        end if
        return true
    end if

    if m.awaitingAnswer
        if key = "left" or key = "right"
            SubmitBeaconAnswer(key)
            return true
        else if key = "back"
            m.awaitingAnswer = false
            m.prompt.text = "Scan cancelled. Choose a beacon when ready."
            return true
        end if
        return true
    end if

    if key = "left"
        m.selectedLane = m.selectedLane - 1
        if m.selectedLane < 0 then m.selectedLane = 0
        RenderFlight()
        return true
    else if key = "right"
        m.selectedLane = m.selectedLane + 1
        if m.selectedLane > 2 then m.selectedLane = 2
        RenderFlight()
        return true
    else if key = "OK"
        StartBeaconQuestion()
        return true
    else if key = "back"
        m.top.closeRequested = true
        return true
    end if

    return false
end function
