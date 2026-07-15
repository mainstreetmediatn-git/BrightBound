function BrightBound_ProfileIdForSlot(slotIndex as Integer) as String
    if slotIndex < 0 or slotIndex > 4 then return ""
    return "learner_" + (slotIndex + 1).ToStr()
end function

function BrightBound_IsValidProfileId(profileId as String) as Boolean
    for i = 0 to 4
        if profileId = BrightBound_ProfileIdForSlot(i) then return true
    end for
    return false
end function

function BrightBound_ProfileKey(profileId as String) as String
    return "profile_" + profileId
end function

sub BrightBound_MigrateLegacyProfile()
    section = CreateObject("roRegistrySection", "BrightBound")
    firstProfileKey = BrightBound_ProfileKey("learner_1")
    if section.Exists(firstProfileKey) then return
    if not section.Exists("profile") then return

    legacy = ParseJson(section.Read("profile"))
    if legacy = invalid or type(legacy) <> "roAssociativeArray" then return

    legacy.profileId = "learner_1"
    if legacy.displayName = invalid or legacy.displayName = "" then legacy.displayName = "Explorer 1"
    legacy = BrightBound_EnsureProfileShape(legacy)
    section.Write(firstProfileKey, FormatJson(legacy))
    section.Write("active_profile_id", "learner_1")
    section.Flush()
end sub

function BrightBound_GetActiveProfileId() as String
    BrightBound_MigrateLegacyProfile()
    section = CreateObject("roRegistrySection", "BrightBound")
    if not section.Exists("active_profile_id") then return ""
    profileId = section.Read("active_profile_id")
    if not BrightBound_IsValidProfileId(profileId) then return ""
    return profileId
end function

function BrightBound_SetActiveProfileId(profileId as String) as Boolean
    if not BrightBound_IsValidProfileId(profileId) then return false
    section = CreateObject("roRegistrySection", "BrightBound")
    section.Write("active_profile_id", profileId)
    return section.Flush()
end function

function BrightBound_LoadProfile() as Object
    profileId = BrightBound_GetActiveProfileId()
    if profileId = "" then return invalid
    return BrightBound_LoadProfileById(profileId)
end function

function BrightBound_LoadProfileById(profileId as String) as Object
    BrightBound_MigrateLegacyProfile()
    if not BrightBound_IsValidProfileId(profileId) then return invalid

    section = CreateObject("roRegistrySection", "BrightBound")
    key = BrightBound_ProfileKey(profileId)
    if not section.Exists(key) then return invalid

    parsed = ParseJson(section.Read(key))
    if parsed = invalid or type(parsed) <> "roAssociativeArray" then return invalid
    if parsed.schemaVersion <> "1.0.0" then return invalid
    parsed.profileId = profileId
    return BrightBound_EnsureProfileShape(parsed)
end function

function BrightBound_CreateProfileForSlot(slotIndex as Integer) as Object
    profileId = BrightBound_ProfileIdForSlot(slotIndex)
    if profileId = "" then return invalid

    existing = BrightBound_LoadProfileById(profileId)
    if existing <> invalid then return existing

    profile = BrightBound_DefaultProfileFor(profileId, "Explorer " + (slotIndex + 1).ToStr())
    if not BrightBound_SaveProfile(profile) then return invalid
    return profile
end function

function BrightBound_CountDiscoveredConcepts(profile as Object) as Integer
    if profile = invalid or profile.evidence = invalid or profile.evidence.conceptsDiscovered = invalid then return 0
    total = 0
    for each conceptId in profile.evidence.conceptsDiscovered
        if profile.evidence.conceptsDiscovered[conceptId] = true then total = total + 1
    end for
    return total
end function

function BrightBound_CompanionStageName(stageId as String) as String
    if stageId = "pathfinder_polliwog" then return "Pathfinder Polliwog"
    if stageId = "curious_froglet" then return "Curious Froglet"
    if stageId = "wisdom_frog" then return "Wisdom Frog"
    if stageId = "ascended_frog" then return "Ascended Frog"
    return "Spark Tadpole"
end function

function BrightBound_ListProfileSummaries() as Object
    BrightBound_MigrateLegacyProfile()
    summaries = []
    for i = 0 to 4
        profileId = BrightBound_ProfileIdForSlot(i)
        profile = BrightBound_LoadProfileById(profileId)
        if profile = invalid
            summaries.Push({
                exists: false
                profileId: profileId
                displayName: ""
                companionName: "Spark Tadpole"
                ideasDiscovered: 0
                journeysCompleted: 0
            })
        else
            summaries.Push({
                exists: true
                profileId: profileId
                displayName: profile.displayName
                companionName: BrightBound_CompanionStageName(profile.companion.stageId)
                ideasDiscovered: BrightBound_CountDiscoveredConcepts(profile)
                journeysCompleted: profile.cosmos.journeysCompleted
            })
        end if
    end for
    return summaries
end function

function BrightBound_EnsureProfileShape(profile as Object) as Object
    if profile.profileId = invalid then profile.profileId = "learner_1"
    if profile.displayName = invalid or profile.displayName = "" then profile.displayName = "Explorer"
    if profile.ageBand = invalid then profile.ageBand = "6-8"
    if profile.learnerTitle = invalid then profile.learnerTitle = "Discoverer"

    if profile.companion = invalid then profile.companion = {}
    if profile.companion.speciesId = invalid then profile.companion.speciesId = "frog"
    if profile.companion.stageId = invalid then profile.companion.stageId = "spark_tadpole"
    if profile.companion.stageIndex = invalid then profile.companion.stageIndex = 1
    if profile.companion.pendingEvolutionId = invalid then profile.companion.pendingEvolutionId = ""
    if profile.companion.completedEvolutionIds = invalid then profile.companion.completedEvolutionIds = []

    if profile.evidence = invalid then profile.evidence = {}
    if profile.evidence.interactions = invalid then profile.evidence.interactions = 0
    if profile.evidence.independentCorrect = invalid then profile.evidence.independentCorrect = 0
    if profile.evidence.correctedMistakes = invalid then profile.evidence.correctedMistakes = 0
    if profile.evidence.conceptsDiscovered = invalid then profile.evidence.conceptsDiscovered = {}

    if profile.cosmos = invalid then profile.cosmos = {}
    if profile.cosmos.journeysCompleted = invalid then profile.cosmos.journeysCompleted = 0
    if profile.cosmos.knowledgeBeaconsCollected = invalid then profile.cosmos.knowledgeBeaconsCollected = 0
    if profile.cosmos.visitedGalaxyIds = invalid then profile.cosmos.visitedGalaxyIds = []
    if profile.cosmos.usedShipIds = invalid then profile.cosmos.usedShipIds = []
    if profile.cosmos.completedMissionIds = invalid then profile.cosmos.completedMissionIds = []
    if profile.cosmos.completedBeaconIds = invalid then profile.cosmos.completedBeaconIds = []
    if profile.cosmos.lastSelectedShipId = invalid then profile.cosmos.lastSelectedShipId = ""
    if profile.cosmos.lastSelectedGalaxyId = invalid then profile.cosmos.lastSelectedGalaxyId = ""
    if profile.cosmos.activeMissionCheckpoint = invalid then profile.cosmos.activeMissionCheckpoint = invalid

    if profile.settings = invalid then profile.settings = {}
    if profile.settings.audioMuted = invalid then profile.settings.audioMuted = false
    if profile.settings.captionsEnabled = invalid then profile.settings.captionsEnabled = true
    if profile.settings.reducedMotion = invalid then profile.settings.reducedMotion = false

    return profile
end function

function BrightBound_SaveProfile(profile as Object) as Boolean
    if profile = invalid then return false
    profile = BrightBound_EnsureProfileShape(profile)
    if not BrightBound_IsValidProfileId(profile.profileId) then return false

    profile.updatedAt = CreateObject("roDateTime").ToISOString()
    section = CreateObject("roRegistrySection", "BrightBound")
    key = BrightBound_ProfileKey(profile.profileId)
    backupKey = key + "_backup"
    if section.Exists(key) then section.Write(backupKey, section.Read(key))
    section.Write(key, FormatJson(profile))
    section.Write("active_profile_id", profile.profileId)
    return section.Flush()
end function

function BrightBound_ResetProfile() as Object
    profileId = BrightBound_GetActiveProfileId()
    if profileId = "" then profileId = "learner_1"
    existing = BrightBound_LoadProfileById(profileId)
    displayName = "Explorer"
    if existing <> invalid then displayName = existing.displayName
    profile = BrightBound_DefaultProfileFor(profileId, displayName)
    BrightBound_SaveProfile(profile)
    return profile
end function

function BrightBound_DefaultProfile() as Object
    return BrightBound_DefaultProfileFor("learner_1", "Explorer 1")
end function

function BrightBound_DefaultProfileFor(profileId as String, displayName as String) as Object
    return {
        schemaVersion: "1.0.0"
        profileId: profileId
        displayName: displayName
        ageBand: "6-8"
        learnerTitle: "Discoverer"
        updatedAt: ""
        companion: {
            speciesId: "frog"
            stageId: "spark_tadpole"
            stageIndex: 1
            pendingEvolutionId: ""
            completedEvolutionIds: []
        }
        evidence: {
            interactions: 0
            independentCorrect: 0
            correctedMistakes: 0
            conceptsDiscovered: {}
        }
        cosmos: {
            journeysCompleted: 0
            knowledgeBeaconsCollected: 0
            visitedGalaxyIds: []
            usedShipIds: []
            completedMissionIds: []
            completedBeaconIds: []
            lastSelectedShipId: ""
            lastSelectedGalaxyId: ""
            activeMissionCheckpoint: invalid
        }
        settings: {
            audioMuted: false
            captionsEnabled: true
            reducedMotion: false
        }
    }
end function
