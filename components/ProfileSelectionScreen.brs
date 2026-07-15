sub Init()
    m.profileFocus = m.top.FindNode("profileFocus")
    m.profileNames = [
        m.top.FindNode("profileName0")
        m.top.FindNode("profileName1")
        m.top.FindNode("profileName2")
        m.top.FindNode("profileName3")
        m.top.FindNode("profileName4")
    ]
    m.profileMeta = [
        m.top.FindNode("profileMeta0")
        m.top.FindNode("profileMeta1")
        m.top.FindNode("profileMeta2")
        m.top.FindNode("profileMeta3")
        m.top.FindNode("profileMeta4")
    ]
    m.selectedIndex = 0
    RefreshProfiles()
    m.top.SetFocus(true)
end sub

sub OnRefreshRequested()
    RefreshProfiles()
end sub

sub RefreshProfiles()
    m.slots = BrightBound_ListProfileSummaries()
    for i = 0 to 4
        slot = m.slots[i]
        if slot.exists
            m.profileNames[i].text = slot.displayName
            m.profileMeta[i].text = slot.companionName + "  |  Ideas: " + slot.ideasDiscovered.ToStr() + "  |  Journeys: " + slot.journeysCompleted.ToStr()
        else
            m.profileNames[i].text = "Create New Explorer"
            m.profileMeta[i].text = "Empty profile slot " + (i + 1).ToStr()
        end if
    end for
    UpdateFocus()
end sub

sub UpdateFocus()
    focusY = 285 + (m.selectedIndex * 120)
    m.profileFocus.translation = [300, focusY]
end sub

sub SelectCurrentProfile()
    slot = m.slots[m.selectedIndex]
    profileId = slot.profileId
    if not slot.exists
        created = BrightBound_CreateProfileForSlot(m.selectedIndex)
        if created = invalid then return
        profileId = created.profileId
    end if
    BrightBound_SetActiveProfileId(profileId)
    m.top.selectedProfileId = profileId
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "up"
        m.selectedIndex = m.selectedIndex - 1
        if m.selectedIndex < 0 then m.selectedIndex = 4
        UpdateFocus()
        return true
    else if key = "down"
        m.selectedIndex = m.selectedIndex + 1
        if m.selectedIndex > 4 then m.selectedIndex = 0
        UpdateFocus()
        return true
    else if key = "OK"
        SelectCurrentProfile()
        return true
    end if

    return false
end function
