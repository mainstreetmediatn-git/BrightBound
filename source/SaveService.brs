function BrightBound_LoadProfile() as Object
    defaults = BrightBound_DefaultProfile()
    section = CreateObject("roRegistrySection", "BrightBound")
    if not section.Exists("profile") then return defaults

    raw = section.Read("profile")
    parsed = ParseJson(raw)
    if parsed = invalid or type(parsed) <> "roAssociativeArray" then return defaults
    if parsed.schemaVersion <> "1.0.0" then return defaults
    return parsed
end function

function BrightBound_SaveProfile(profile as Object) as Boolean
    if profile = invalid then return false
    profile.updatedAt = CreateObject("roDateTime").ToISOString()
    section = CreateObject("roRegistrySection", "BrightBound")
    section.Write("profile_backup", section.Read("profile"))
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
        settings: {
            audioMuted: false
            captionsEnabled: true
            reducedMotion: false
        }
    }
end function
