#SingleInstance Force
#Include "lib/FishingStateMachine.ahk"

readyToStart := false
startFishing := false
instructions := "1. Open Core Keeper. No joke.`n2. Move your character to a position so that your desired water is next to you on your right side`n3. Grab your rod`n4. Press CTRL + F to get started catching any fish. Don't move your ass.`n`nControls:`nPress CTRL + F to stop/start the procedure`nPress CTRL + Q to quit this script"

resultOk := MsgBox("Hey there core keepers`n`nIt's a nice day to go fishing, ain't it? Huho.`n`n" . instructions, "Core Keeper - Everyfish", 0)
readyToStart := resultOk = "OK"
if !readyToStart
    ExitApp

fishingMachine := FishingStateMachine()
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
            startFishing := true
        } else if (yesResult = "No"){
            startFishing := false
        }
        fishingMachine.reset()
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
        fishingMachine.reset()
    }
}
$^q::ExitApp