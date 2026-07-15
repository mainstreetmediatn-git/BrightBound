sub Init()
    m.pondGroup = m.top.FindNode("pondGroup")
    m.quizGroup = m.top.FindNode("quizGroup")
    m.evolutionGroup = m.top.FindNode("evolutionGroup")
    m.launchTerminal = m.top.FindNode("launchTerminal")
    m.status = m.top.FindNode("status")
    m.companionLabel = m.top.FindNode("companionLabel")
    m.question = m.top.FindNode("question")
    m.answerA = m.top.FindNode("answerA")
    m.answerB = m.top.FindNode("answerB")
    m.feedback = m.top.FindNode("feedback")
    m.focusBox = m.top.FindNode("focusBox")
    m.evolutionFade = m.top.FindNode("evolutionFade")
    m.launchTerminal.ObserveField("closeRequested", "OnLaunchTerminalClose")

    m.questions = [
        { conceptId: "add_1", prompt: "1 + 2 = ?", answers: ["3", "4"], correct: 0 },
        { conceptId: "add_2", prompt: "2 + 3 = ?", answers: ["4", "5"], correct: 1 },
        { conceptId: "add_3", prompt: "4 + 1 = ?", answers: ["5", "6"], correct: 0 },
        { conceptId: "add_1", prompt: "3 + 1 = ?", answers: ["4", "5"], correct: 0 },
        { conceptId: "add_2", prompt: "2 + 4 = ?", answers: ["6", "7"], correct: 0 },
        { conceptId: "add_3", prompt: "5 + 2 = ?", answers: ["6", "7"], correct: 1 }
    ]

    m.profile = BrightBound_LoadProfile()
    m.screenName = "pond"
    m.questionIndex = 0
    m.selectedAnswer = 0
    m.hadIncorrectAttempt = false
    RenderPond()
    m.top.SetFocus(true)
end sub

sub RenderPond()
    m.pondGroup.visible = true
    m.quizGroup.visible = false
    m.evolutionGroup.visible = false
    m.launchTerminal.visible = false
    stageName = "Spark Tadpole"
    if m.profile.companion.stageId = "pathfinder_polliwog" then stageName = "Pathfinder Polliwog"
    m.companionLabel.text = stageName
    m.status.text = m.profile.displayName + " - " + m.profile.learnerTitle + " | Ideas discovered: " + BrightBound_ConceptCount(m.profile).ToStr()
    m.top.SetFocus(true)
end sub

sub OpenLaunchTerminal()
    m.screenName = "launch"
    m.pondGroup.visible = false
    m.quizGroup.visible = false
    m.evolutionGroup.visible = false
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

sub StartQuiz()
    m.screenName = "quiz"
    m.pondGroup.visible = false
    m.quizGroup.visible = true
    m.feedback.text = ""
    ShowQuestion()
end sub

sub ShowQuestion()
    q = m.questions[m.questionIndex mod m.questions.Count()]
    m.question.text = q.prompt
    m.answerA.text = q.answers[0]
    m.answerB.text = q.answers[1]
    m.selectedAnswer = 0
    m.hadIncorrectAttempt = false
    UpdateAnswerFocus()
end sub

sub UpdateAnswerFocus()
    if m.selectedAnswer = 0
        m.focusBox.translation = [400, 450]
    else
        m.focusBox.translation = [1000, 450]
    end if
end sub

sub SubmitAnswer()
    q = m.questions[m.questionIndex mod m.questions.Count()]
    isCorrect = m.selectedAnswer = q.correct
    if isCorrect
        m.profile = BrightBound_RecordAnswer(m.profile, q.conceptId, true, false, m.hadIncorrectAttempt)
        m.feedback.text = "You figured it out!"
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
        m.feedback.text = "Not yet. Try the other answer - your tadpole is learning with you."
    end if
end sub

sub BeginEvolution()
    m.screenName = "evolution"
    m.quizGroup.visible = false
    m.evolutionGroup.visible = true
    m.evolutionFade.control = "start"
end sub

sub FinishEvolution()
    m.profile = BrightBound_CompleteFirstRipple(m.profile)
    BrightBound_SaveProfile(m.profile)
    m.screenName = "pond"
    RenderPond()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.screenName = "pond"
        if key = "OK"
            StartQuiz()
            return true
        else if key = "down"
            OpenLaunchTerminal()
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
    else if m.screenName = "launch"
        return false
    end if

    return false
end function
