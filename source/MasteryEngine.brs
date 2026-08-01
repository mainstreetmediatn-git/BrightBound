function BrightBound_RecordAnswer(profile as Object, conceptId as String, isCorrect as Boolean, usedHint as Boolean, wasRetry as Boolean) as Object
    profile.evidence.interactions = profile.evidence.interactions + 1
    profile.evidence.conceptsDiscovered[conceptId] = true

    if isCorrect and not usedHint
        profile.evidence.independentCorrect = profile.evidence.independentCorrect + 1
    end if

    if isCorrect and wasRetry
        profile.evidence.correctedMistakes = profile.evidence.correctedMistakes + 1
    end if

    return profile
end function

function BrightBound_ConceptCount(profile as Object) as Integer
    count = 0
    for each key in profile.evidence.conceptsDiscovered
        if profile.evidence.conceptsDiscovered[key] = true then count = count + 1
    end for
    return count
end function

function BrightBound_IsFirstRippleReady(profile as Object) as Boolean
    if profile.companion.stageId <> "spark_tadpole" then return false
    if profile.evidence.interactions < 5 then return false
    if profile.evidence.independentCorrect < 1 then return false
    if profile.evidence.correctedMistakes < 1 then return false
    if BrightBound_ConceptCount(profile) < 3 then return false

    for each completedId in profile.companion.completedEvolutionIds
        if completedId = "frog_first_ripple" then return false
    end for
    return true
end function

function BrightBound_CompleteFirstRipple(profile as Object) as Object
    if profile.companion.stageId = "pathfinder_polliwog" then return profile
    profile.companion.stageId = "pathfinder_polliwog"
    profile.companion.stageIndex = 2
    profile.companion.pendingEvolutionId = ""
    profile.companion.completedEvolutionIds.Push("frog_first_ripple")
    profile.learnerTitle = "Pathfinder"
    return profile
end function
