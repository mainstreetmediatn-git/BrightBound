sub Init()
    m.pondGroup = m.top.FindNode("pondGroup")
    m.quizGroup = m.top.FindNode("quizGroup")
    m.evolutionGroup = m.top.FindNode("evolutionGroup")
    m.launchTerminal = m.top.FindNode("launchTerminal")
    m.flightScreen = m.top.FindNode("flightScreen")
    m.profileSelection = m.top.FindNode("profileSelection")
    m.status = m.top.FindNode("status")
    m.profileTitle = m.top.FindNode("profileTitle")
    m.ideasValue = m.top.FindNode("ideasValue")
    m.journeysValue = m.top.FindNode("journeysValue")
    m.companionLabel = m.top.FindNode("companionLabel")
    m.question = m.top.FindNode("question")
    m.quizStep = m.top.FindNode("quizStep")
    m.conceptChip = m.top.FindNode("conceptChip")
    m.answerA = m.top.FindNode("answerA")
    m.answerB = m.top.FindNode("answerB")
    m.feedback = m.top.FindNode("feedback")
    m.focusBox = m.top.FindNode("focusBox")

    m.profileSelection.ObserveField("selectedProfileId", "OnProfileSelected")
    m.launchTerminal.ObserveField("closeRequested", "OnLaunchTerminalClose")
    m.launchTerminal.ObserveField("launchRequested", "OnLaunchRequested")
    m.flightScreen.ObserveField("checkpointUpdated", "OnCheckpointUpdated")
    m.flightScreen.ObserveField("journeyCompleted", "OnJourneyCompleted")
    m.flightScreen.ObserveField("closeRequested", "OnFlightClose")

    m.questions = [
        { conceptId: "add_1", prompt: "1 + 2 = ?", answers: ["3", "4"], correct: 0 },
        { conceptId: "add_2", prompt: "2 + 3 = ?", answers: ["4", "5"], correct: 1 },
        { conceptId: "add_3", prompt: "4 + 1 = ?", answers: ["5", "6"], correct: 0 },
        { conceptId: "add_1", prompt: "3 + 1 = ?", answers: ["4", "5"], correct: 0 },
        { conceptId: "add_2", prompt: "2 + 4 = ?", answers: ["6", "7"], correct: 0 },
        { conceptId: "add_3", prompt: "5 + 2 = ?", answers: ["6", "7"], correct: 1 }
    ]

    m.profile = invalid
    m.screenName = "profiles"
    m.questionIndex = 0
    m.selectedAnswer = 0
    m.hadIncorrectAttempt = false
    m.flightWasCompleted = false
    m.profileRefreshNonce = 1
    ShowProfileSelection()
end sub

sub HideAllScreens()
    m.pondGroup.visible = false
    m.quizGroup.visible = false
    m.evolutionGroup.visible = false
    m.launchTerminal.visible = false
    m.flightScreen.visible = false
    m.profileSelection.visible = false
end sub

sub ShowProfileSelection()
    if m.profile <> invalid then BrightBound_SaveProfile(m.profile)
    HideAllScreens()
    m.screenName = "profiles"
    m.profile = invalid
    m.profileRefreshNonce = m.profileRefreshNonce + 1
    m.profileSelection.refreshNonce = m.profileRefreshNonce
    m.profileSelection.visible = true
    m.profileSelection.SetFocus(true)
end sub

sub OnProfileSelected()
    profileId = m.profileSelection.selectedProfileId
    if profileId = invalid or profileId = "" then return

    selectedProfile = BrightBound_LoadProfileById(profileId)
    if selectedProfile = invalid then return

    BrightBound_SetActiveProfileId(profileId)
    m.profile = selectedProfile
    m.questionIndex = 0
    m.selectedAnswer = 0
    m.hadIncorrectAttempt = false
    m.flightWasCompleted = false

    if m.profile.companion.pendingEvolutionId = "frog_first_ripple"
        BeginEvolution()
    else
        RenderPond()
    end if
end sub

sub RenderPond()
    if m.profile = invalid
        ShowProfileSelection()
        return
    end if

    HideAllScreens()
    m.screenName = "pond"
    m.pondGroup.visible = true
    stageName = BrightBound_CompanionStageName(m.profile.companion.stageId)
    ideasCount = BrightBound_ConceptCount(m.profile)
    journeyCount = m.profile.cosmos.journeysCompleted

    m.profileTitle.text = m.profile.displayName
    m.status.text = m.profile.learnerTitle + "  •  " + stageName
    m.ideasValue.text = ideasCount.ToStr()
    m.journeysValue.text = "JOURNEYS  " + journeyCount.ToStr()
    m.companionLabel.text = stageName
    m.top.SetFocus(true)
end sub

sub OpenLaunchTerminal()
    if m.profile = invalid then return
    HideAllScreens()
    m.screenName = "launch"
    m.launchTerminal.closeRequested = false
    m.launchTerminal.visible = true
    m.launchTerminal.SetFocus(true)
end sub

sub OnLaunchTerminalClose()
    if m.launchTerminal.closeRequested
        m.screenName = "pond"
        RenderPond()
    end if
end sub

sub OnLaunchRequested()
    if m.profile = invalid then return
    config = m.launchTerminal.launchRequested
    if config = invalid then return

    m.profile = BrightBound_EnsureProfileShape(m.profile)
    if config.shipId <> invalid then m.profile.cosmos.lastSelectedShipId = config.shipId
    if config.galaxyId <> invalid then m.profile.cosmos.lastSelectedGalaxyId = config.galaxyId
    m.profile.cosmos.activeMissionCheckpoint = {
        missionId: ""
        shipId: m.profile.cosmos.lastSelectedShipId
        galaxyId: m.profile.cosmos.lastSelectedGalaxyId
        completedBeaconIds: []
        mistakesCorrected: 0
    }
    BrightBound_SaveProfile(m.profile)

    HideAllScreens()
    m.screenName = "flight"
    m.flightWasCompleted = false
    m.flightScreen.closeRequested = false
    m.flightScreen.journeyCompleted = invalid
    m.flightScreen.journeyConfig = config
    m.flightScreen.visible = true
    m.flightScreen.SetFocus(true)
end sub

function ArrayHasValue(items as Object, target as String) as Boolean
    if items = invalid then return false
    for each item in items
        if item = target then return true
    end for
    return false
end function

sub AddUniqueValues(target as Object, additions as Object)
    if target = invalid or additions = invalid then return
    for each value in additions
        if not ArrayHasValue(target, value) then target.Push(value)
    end for
end sub

sub OnCheckpointUpdated()
    if m.profile = invalid then return
    checkpoint = m.flightScreen.checkpointUpdated
    if checkpoint = invalid then return

    m.profile = BrightBound_EnsureProfileShape(m.profile)
    m.profile.cosmos.activeMissionCheckpoint = checkpoint
    if checkpoint.shipId <> invalid and checkpoint.shipId <> "" then m.profile.cosmos.lastSelectedShipId = checkpoint.shipId
    if checkpoint.galaxyId <> invalid and checkpoint.galaxyId <> "" then m.profile.cosmos.lastSelectedGalaxyId = checkpoint.galaxyId
    if checkpoint.completedBeaconIds <> invalid then AddUniqueValues(m.profile.cosmos.completedBeaconIds, checkpoint.completedBeaconIds)
    BrightBound_SaveProfile(m.profile)
end sub

sub OnJourneyCompleted()
    if m.profile = invalid then return
    result = m.flightScreen.journeyCompleted
    if result = invalid or result.completed <> true or m.flightWasCompleted then return

    m.flightWasCompleted = true
    m.profile = BrightBound_EnsureProfileShape(m.profile)

    isFirstMissionCompletion = true
    if result.missionId <> invalid and result.missionId <> ""
        if ArrayHasValue(m.profile.cosmos.completedMissionIds, result.missionId)
            isFirstMissionCompletion = false
        else
            m.profile.cosmos.completedMissionIds.Push(result.missionId)
        end if
    end if

    if isFirstMissionCompletion
        m.profile.cosmos.journeysCompleted = m.profile.cosmos.journeysCompleted + 1
        m.profile.cosmos.knowledgeBeaconsCollected = m.profile.cosmos.knowledgeBeaconsCollected + result.beaconsCollected
    end if

    if result.beaconIds <> invalid then AddUniqueValues(m.profile.cosmos.completedBeaconIds, result.beaconIds)
    if result.galaxyId <> invalid and result.galaxyId <> "" and not ArrayHasValue(m.profile.cosmos.visitedGalaxyIds, result.galaxyId)
        m.profile.cosmos.visitedGalaxyIds.Push(result.galaxyId)
    end if
    if result.shipId <> invalid and result.shipId <> "" and not ArrayHasValue(m.profile.cosmos.usedShipIds, result.shipId)
        m.profile.cosmos.usedShipIds.Push(result.shipId)
    end if

    if result.shipId <> invalid then m.profile.cosmos.lastSelectedShipId = result.shipId
    if result.galaxyId <> invalid then m.profile.cosmos.lastSelectedGalaxyId = result.galaxyId
    m.profile.cosmos.activeMissionCheckpoint = invalid
    BrightBound_SaveProfile(m.profile)
end sub

sub OnFlightClose()
    if not m.flightScreen.closeRequested then return
    if m.flightWasCompleted
        m.screenName = "pond"
        RenderPond()
    else
        OpenLaunchTerminal()
    end if
end sub

sub StartQuiz()
    if m.profile = invalid then return
    HideAllScreens()
    m.screenName = "quiz"
    m.quizGroup.visible = true
    m.feedback.text = "Choose the answer that feels right."
    ShowQuestion()
end sub

sub ShowQuestion()
    questionCount = m.questions.Count()
    displayIndex = (m.questionIndex mod questionCount) + 1
    q = m.questions[m.questionIndex mod questionCount]
    m.quizStep.text = "QUESTION " + displayIndex.ToStr() + " OF " + questionCount.ToStr()
    m.conceptChip.text = "ADDITION  •  STAR PATH"
    m.question.text = q.prompt
    m.answerA.text = q.answers[0]
    m.answerB.text = q.answers[1]
    m.selectedAnswer = 0
    m.hadIncorrectAttempt = false
    UpdateAnswerFocus()
end sub

sub UpdateAnswerFocus()
    if m.selectedAnswer = 0
        m.focusBox.translation = [310, 515]
    else
        m.focusBox.translation = [1010, 515]
    end if
end sub

sub SubmitAnswer()
    if m.profile = invalid then return
    q = m.questions[m.questionIndex mod m.questions.Count()]
    isCorrect = m.selectedAnswer = q.correct
    if isCorrect
        m.profile = BrightBound_RecordAnswer(m.profile, q.conceptId, true, false, m.hadIncorrectAttempt)
        m.feedback.text = "You found it! A new star joined your map."
        BrightBound_SaveProfile(m.profile)
        m.questionIndex = m.questionIndex + 1

        if BrightBound_IsFirstRippleReady(m.profile)
            m.profile.companion.pendingEvolutionId = "frog_first_ripple"
            BrightBound_SaveProfile(m.profile)
            BeginEvolution()
        else
            ShowQuestion()
        end if
    else
        m.profile = BrightBound_RecordAnswer(m.profile, q.conceptId, false, false, false)
        m.hadIncorrectAttempt = true
        m.feedback.text = "Almost! Your companion believes in you—try the other star."
        BrightBound_SaveProfile(m.profile)
    end if
end sub

sub BeginEvolution()
    if m.profile = invalid then return
    HideAllScreens()
    m.screenName = "evolution"
    m.evolutionGroup.opacity = 1
    m.evolutionGroup.visible = true
    m.top.SetFocus(true)
end sub

sub FinishEvolution()
    if m.profile = invalid then return
    m.profile = BrightBound_CompleteFirstRipple(m.profile)
    BrightBound_SaveProfile(m.profile)
    m.screenName = "pond"
    RenderPond()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.screenName = "profiles"
        return false
    else if m.screenName = "pond"
        if key = "OK"
            StartQuiz()
            return true
        else if key = "down"
            OpenLaunchTerminal()
            return true
        else if key = "back"
            ShowProfileSelection()
            return true
        end if
    else if m.screenName = "quiz"
        if key = "left"
            m.selectedAnswer = 0
            UpdateAnswerFocus()
            return true
        else if key = "right"
            m.selectedAnswer = 1
            UpdateAnswerFocus()
            return true
        else if key = "OK"
            SubmitAnswer()
            return true
        else if key = "back"
            m.screenName = "pond"
            RenderPond()
            return true
        end if
    else if m.screenName = "evolution"
        if key = "OK"
            FinishEvolution()
            return true
        end if
        return true
    else if m.screenName = "launch" or m.screenName = "flight"
        return false
    end if

    return false
end function
