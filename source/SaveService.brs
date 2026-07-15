function BrightBound_LoadProfile() as Object
    defaults = BrightBound_DefaultProfile()
    section = CreateObject("roRegistrySection", "BrightBound")
    if not section.Exists("profile") then return defaults

    raw = section.Read("profile")
    parsed = ParseJson(raw)
    if parsed = invalid or type(parsed) <> "roAssociativeArray" then return defaults
    if parsed.schemaVersion <> "1.0.0" then return defaults
    return BrightBound_EnsureProfileShape(parsed)
end function

function BrightBound_EnsureProfileShape(profile as Object) as Object
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

    return profile
end function

function BrightBound_SaveProfile(profile as Object) as Boolean
    if profile = invalid then return false
    profile = BrightBound_EnsureProfileShape(profile)
    profile.updatedAt = CreateObject("roDateTime").ToISOString()
    section = CreateObject("roRegistrySection", "BrightBound")
    if section.Exists("profile") then section.Write("profile_backup", section.Read("profile"))
    section.Write("profile", FormatJson(profile))
    return section.Flush()
end function

function BrightBound_ResetProfile() as Object
    profile = BrightBound_DefaultProfile()
    BrightBound_SaveProfile(profile)
    return profile
end function

function BrightBound_DefaultProfile() as Object
    return {
        schemaVersion: "1.0.0"
        profileId: "local-learner-1"
        displayName: "Explorer"
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
