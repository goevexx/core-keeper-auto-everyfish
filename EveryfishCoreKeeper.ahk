#SingleInstance Force
#Include "lib/FishingStateMachine.ahk"
#Include "lib/log4ahk/log4ahk.ahk"

; ########## OPTIONS ##########

; ## Log ##
; Logging might impact this' scripts performance depending on which configuration you use
;
; Save log
saveLog := false
; If saveLog is true, log to filename
filename := A_Now . "-everyfish.log"
; How deep should your log inform you:
; - Use TRACE to better find errors 
; - Use DEBUG to developement 
; - --> Use INFO to simple usage and data analysis 
; - Use ERROR or even FATAL to just show what's going wrong 
logLvl := LogLevel.INFO

; #############################

readyToStart := false
startFishing := false
instructions := "1. Open Core Keeper. No joke.`n2. Move your character to a position so that your desired water is next to you on your right side`n3. Grab your rod`n4. Press CTRL + F to get started catching any fish. Don't move your ass.`n`nControls:`nPress CTRL + F to stop/start the procedure`nPress CTRL + Q to quit this script"

resultOk := MsgBox("Hey there core keepers`n`nIt's a nice day to go fishing, ain't it? Huho.`n`n" . instructions, "Core Keeper - Everyfish", 0)
readyToStart := resultOk = "OK"
if !readyToStart
    ExitApp

logger := Log4ahk("[%V] #%M# %m", logLvl)
logger.appenders.push(Log4ahk.AppenderFile(filename))
logger.shouldLog := saveLog
fishingMachine := FishingStateMachine(logger)
Loop {
    if (!startFishing) {
        continue
    }

    If !WinExist("Core Keeper") {
        MsgBox("Core Keeper is not open. You need to obey:`n`n" . instructions, "Everyfish - Core Keeper not open", "OK")
        startFishing := false
        fishingMachine.reset()
        continue
    }
    If !WinActive("Core Keeper") {
        yesResult := MsgBox("Core Keeper needs to be your active window.`n`nWait, let me activate it...", "Everyfish - Core Keeper not active", "YesNo")
        if (yesResult = "Yes"){
            WinActivate("Core Keeper")
            setMachinesWindowBoundries()
        } else if (yesResult = "No"){
            startFishing := false
            fishingMachine.reset()
        }
        continue
    } else if (!fishingMachine.areWindowBoundriesSet()){
        setMachinesWindowBoundries()
    }

    fishingMachine.handleState()
}

setMachinesWindowBoundries(){
    global fishingMachine
    WinGetPos(&WinX, &WinY, &WinW, &WinH)
    fishingMachine.setWindowBoundaries(WinW, WinH)
}

$^f::{
    global
    if(readyToStart) {
        startFishing := !startFishing
        if(startFishing){
            logger.info("Start fishing procedure")
        } else {
            logger.info("Stop fishing procedure")
        }
        fishingMachine.reset()
    }
}
$^q::ExitApp