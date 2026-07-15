sub Init()
    m.missionTitle = m.top.FindNode("missionTitle")
    m.missionStatus = m.top.FindNode("missionStatus")
    m.ship = m.top.FindNode("ship")
    m.prompt = m.top.FindNode("prompt")
    m.companionReaction = m.top.FindNode("companionReaction")
    m.summaryGroup = m.top.FindNode("summaryGroup")
    m.summaryText = m.top.FindNode("summaryText")
    m.summaryReaction = m.top.FindNode("summaryReaction")
    m.beacons = [m.top.FindNode("beacon0"), m.top.FindNode("beacon1"), m.top.FindNode("beacon2")]
    m.beaconLabels = [m.top.FindNode("beaconLabel0"), m.top.FindNode("beaconLabel1"), m.top.FindNode("beaconLabel2")]
    m.laneXs = [380, 915, 1440]
    m.selectedLane = 1
    m.collected = [false, false, false]
    m.questions = [
        { beaconId: "beacon_addition_2_plus_2", conceptId: "addition_within_10", prompt: "Beacon 1: What is 2 + 2? Press LEFT for 4 or RIGHT for 5.", correctSide: "left" },
        { beaconId: "beacon_earth_home", conceptId: "earth_is_home_planet", prompt: "Beacon 2: Which planet is our home? Press LEFT for Earth or RIGHT for Mars.", correctSide: "left" },
        { beaconId: "beacon_frog_water_lifecycle", conceptId: "frog_lifecycle_water", prompt: "Beacon 3: A frog begins life in water. Press LEFT for true or RIGHT for false.", correctSide: "left" }
    ]
    m.awaitingAnswer = false
    m.activeBeacon = -1
    m.mistakesCorrected = 0
    m.incorrectAttempts = 0
    m.summaryVisible = false
    m.missionId = "mission_milky_way_first_path"
    RenderFlight()
    m.top.SetFocus(true)
end sub

sub OnJourneyConfigChanged()
    config = m.top.journeyConfig
    if config <> invalid and config.galaxyId = "astraea_prime"
        m.missionId = "mission_astraea_first_path"
    else
        m.missionId = "mission_milky_way_first_path"
    end if
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
    m.missionStatus.text = "Knowledge beacons found: " + CollectedCount().ToStr() + " / 3"
    m.ship.translation = [m.laneXs[m.selectedLane], 690]
    if not m.awaitingAnswer and not m.summaryVisible
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

function CollectedBeaconIds() as Object
    ids = []
    for i = 0 to m.questions.Count() - 1
        if m.collected[i] then ids.Push(m.questions[i].beaconId)
    end for
    return ids
end function

sub EmitCheckpoint()
    config = m.top.journeyConfig
    checkpoint = {
        missionId: m.missionId
        selectedLane: m.selectedLane
        completedBeaconIds: CollectedBeaconIds()
        mistakesCorrected: m.mistakesCorrected
        incorrectAttempts: m.incorrectAttempts
        shipId: ""
        galaxyId: ""
    }
    if config <> invalid
        if config.shipId <> invalid then checkpoint.shipId = config.shipId
        if config.galaxyId <> invalid then checkpoint.galaxyId = config.galaxyId
    end if
    m.top.checkpointUpdated = checkpoint
end sub

sub StartBeaconQuestion()
    if m.collected[m.selectedLane]
        m.prompt.text = "You already found this beacon. Let’s explore another one."
        m.companionReaction.text = "Your companion remembers this discovery."
        return
    end if
    m.activeBeacon = m.selectedLane
    m.awaitingAnswer = true
    m.prompt.text = m.questions[m.activeBeacon].prompt
    m.companionReaction.text = "We can solve this together."
end sub

sub SubmitBeaconAnswer(side as String)
    if not m.awaitingAnswer then return
    questionItem = m.questions[m.activeBeacon]
    if side = questionItem.correctSide
        if m.incorrectAttempts > 0 then m.mistakesCorrected = m.mistakesCorrected + 1
        m.collected[m.activeBeacon] = true
        m.awaitingAnswer = false
        m.incorrectAttempts = 0
        m.prompt.text = "Beacon found! That idea is part of your star map now."
        m.companionReaction.text = "We found it! Great thinking."
        EmitCheckpoint()
        if CollectedCount() = 3
            CompleteJourney()
        else
            RenderFlight()
        end if
    else
        m.incorrectAttempts = m.incorrectAttempts + 1
        m.prompt.text = "Almost. Try the other answer."
        m.companionReaction.text = "That’s okay. Let’s try that signal again."
    end if
end sub

sub CompleteJourney()
    config = m.top.journeyConfig
    result = {
        completed: true
        missionId: m.missionId
        beaconIds: CollectedBeaconIds()
        beaconsCollected: 3
        ideasDiscovered: 3
        mistakesCorrected: m.mistakesCorrected
        shipId: ""
        galaxyId: ""
        galaxyName: "New destination"
    }
    if config <> invalid
        if config.shipId <> invalid then result.shipId = config.shipId
        if config.galaxyId <> invalid then result.galaxyId = config.galaxyId
        if config.galaxyName <> invalid then result.galaxyName = config.galaxyName
    end if

    m.summaryVisible = true
    m.summaryGroup.visible = true
    m.missionStatus.text = "Journey complete"
    m.prompt.text = ""
    m.companionReaction.text = ""
    m.summaryText.text = "Beacons found: 3" + Chr(10) + Chr(10) + "Ideas discovered: 3" + Chr(10) + Chr(10) + "Mistakes corrected: " + m.mistakesCorrected.ToStr() + Chr(10) + Chr(10) + "New galaxy visited: " + result.galaxyName
    m.summaryReaction.text = "We made it together. Look how much you discovered!"
    m.top.journeyCompleted = result
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.summaryVisible
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
            m.incorrectAttempts = 0
            m.prompt.text = "Scan cancelled. Choose a beacon when you’re ready."
            m.companionReaction.text = "We can come back whenever you’re ready."
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
        EmitCheckpoint()
        m.top.closeRequested = true
        return true
    end if

    return false
end function
