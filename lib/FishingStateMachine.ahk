; The Machine managing the fishing state
class FishingStateMachine {
    __New(resetThreshhold := 20000) {
        this.resetThreshhold := resetThreshhold

        this.coreKeeperWindowWidth := 1920
        this.coreKeeperWindowHeight := 1080
        this.exclimationRectangleX1 := 926 
        this.exclimationRectangleY1 := 353 
        this.exclimationRectangleX2 := 1020 
        this.exclimationRectangleY2 := 474 
        
        this.exclimationColorDark :=  0xDE232A
        this.exclimationColorBright :=  0xE9C62C 

        ; TODO: Remove this code
        ; ----------------------------------------------------------------
        ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
        this.challengeRectangleX1   := 757 
        this.challengeRectangleY1   := 833 
        this.challengeRectangleX2   := 1163 
        this.challengeRectangleY2   := 871 
        this.challengeWaterColor1 := 0x1885D5
        this.challengeWaterColor2 := 0x104DB9
        this.challengeWaterColor3 := 0x143EAB
        this.challengeWaterColor4 := 0x142B5C
        this.challengeGrasColor1 := 0x0F5630
        this.challengeGrasColor2 := 0x0A6D27
        this.challengeFrameColor1 := 0xD29A7C
        this.challengeFrameColor2 := 0xB58047
        this.pullingFishColorDark := 0x5E1817
        this.pullingFishColorBright := 0xC52B04
        this.easingFishColorDark :=   0x814428
        this.easingFishColorBright := 0xE1A030   
        ; -----------------------------------------------------------------
        this.initState()
    }

    initState(){
        this.hit()
        this.setState(IdleState(this))
    }

    setState(state) {
        if(HasProp(this, "currentState")){
            previoustateName := this.currentState.__Class
        } else {
            previoustateName := "(no state)"
        }
        this.currentState := state
    }

    handleState(){
        if(this.currentState.getElapsedTime() > this.resetThreshhold){
            this.reset()
        } else {
            this.currentState.handle()
        }
    }

    reset() {
        this.initState()
    }

    hit(){
        if(HasProp(this, "fishingClickX") and HasProp(this, "fishingClickY")){
            Click(this.fishingClickX, this.fishingClickY, 1)
        }
    }

    setWindowBoundaries(windowWidth, windowHeight){
        this.windowWidth := windowWidth
        this.windowHeight := windowHeight
        this.fishingClickX := windowWidth * 0.8
        this.fishingClickY := windowHeight / 2

        ; Fit core keeper into window
        windowRelation := windowWidth / windowHeight
        coreKeeperWindowRelation := this.coreKeeperWindowWidth / this.coreKeeperWindowHeight
        blankX := 0
        blankY := 0
        scaleFactor := windowWidth / this.coreKeeperWindowWidth 
        if(windowRelation > coreKeeperWindowRelation) ; it got wider    
        {
            newCoreKeeperWindowWidth := this.coreKeeperWindowWidth / this.coreKeeperWindowHeight * windowHeight
            blankX := (windowWidth - newCoreKeeperWindowWidth) / 2 
            scaleFactor := newCoreKeeperWindowWidth / this.coreKeeperWindowWidth
        } else if(windowRelation < coreKeeperWindowRelation) ; it got higher 
        {
            newCoreKeeperWindowHeight := this.coreKeeperWindowHeight / this.coreKeeperWindowWidth * windowWidth
            blankY := (windowHeight - newCoreKeeperWindowHeight) / 2
            scaleFactor := newCoreKeeperWindowHeight / this.coreKeeperWindowHeight
        } 
        this.exclimationRectangleX1 := this.exclimationRectangleX1 * scaleFactor + blankX
        this.exclimationRectangleY1 := this.exclimationRectangleY1 * scaleFactor + blankY
        this.exclimationRectangleX2 := this.exclimationRectangleX2 * scaleFactor + blankX 
        this.exclimationRectangleY2 := this.exclimationRectangleY2 * scaleFactor + blankY

        ; TODO: Remove this code
        ; ----------------------------------------------------------------
        ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
        this.challengeRectangleX1 := this.challengeRectangleX1 * scaleFactor + blankX 
        this.challengeRectangleY1 := this.challengeRectangleY1 * scaleFactor + blankY 
        this.challengeRectangleX2 := this.challengeRectangleX2 * scaleFactor + blankX 
        this.challengeRectangleY2 := this.challengeRectangleY2 * scaleFactor + blankY 
        ; ----------------------------------------------------------------
    }

    areWindowBoundriesSet(){
        return HasProp(this, "windowWidth") and HasProp(this, "windowHeight") and HasProp(this, "fishingClickX") and HasProp(this, "fishingClickY")
    }
}

; The way your current state looks like while you are fishing
class FishingStateMachineState {
    __New(context) {
        this.context := context
        this.startTime := A_TickCount
    }

    ; Sets the context's state
    changeState(state){
        this.context.setState(state)
    }

    ; Needs to be implemented in subclasses
    handle(){
    }

    ; Get's elapsed time in ms
    getElapsedTime(){
        elapsedTime := A_TickCount - this.startTime
        return A_TickCount - this.startTime
    }
    
    ; Checks for the exclimation mark when something hooks
    isSomethingOnTheHook(){
        rectangleHasDarkerColor := PixelSearch(&empty, &empty, this.exclimationRectangleX1, this.exclimationRectangleY1, this.exclimationRectangleX2, this.exclimationRectangleY2, this.exclimationColorBright,4)
        rectangleHasBrighterColor := PixelSearch(&empty, &empty, this.exclimationRectangleX1, this.exclimationRectangleY1, this.exclimationRectangleX2, this.exclimationRectangleY2, this.exclimationColorBright,4)
        somethingIsOnTheHook := rectangleHasDarkerColor and rectangleHasBrighterColor
        return somethingIsOnTheHook
    }
    
    
    ; TODO: Remove this code
    ; ----------------------------------------------------------------
    ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
    ; Checks for fish challenge windows
    isFishChallenging(){ 
        rectangleHasWaterColor1 := PixelSearch(&rhwc1x,&rhwc1y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeWaterColor1,3)
        rectangleHasWaterColor2 := PixelSearch(&rhwc2x,&rhwc2y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeWaterColor2,3)
        rectangleHasGrasColor1:= PixelSearch(&rhgc1x,&rhgc1y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeGrasColor1,3)
        rectangleHasGrasColor2:= PixelSearch(&rhgc2x,&rhgc2y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeGrasColor2,3)
        rectangleHasFrameColor1:= PixelSearch(&rhfc1x,&rhfc1y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeFrameColor1,3)
        rectangleHasFrameColor2:= PixelSearch(&rhfc2x,&rhfc2y,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.challengeFrameColor2,3)
        fishIsChallenging := rectangleHasWaterColor1 and rectangleHasWaterColor2 and rectangleHasGrasColor1 and rectangleHasGrasColor2 and rectangleHasFrameColor1 and rectangleHasFrameColor2
        return fishIsChallenging
    }
    
    ; Checks if the fish's pulling colors can be found 
    isFishPulling(){
        rectangleHasDarkerColor := PixelSearch(&empty,&empty,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.pullingFishColorDark,4)
        rectangleHasBrighterColor := PixelSearch(&empty,&empty,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.pullingFishColorBright,4)
        fishIsPulling := rectangleHasDarkerColor and rectangleHasBrighterColor
        return fishIsPulling
    }
    
    ; Checks if the fish's easing colors can be found 
    isFishEasing(){
        rectangleHasDarkerColor := PixelSearch(&empty,&empty,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.easingFishColorDark,3)
        rectangleHasBrighterColor := PixelSearch(&empty,&empty,this.challengeRectangleX1,this.challengeRectangleY1,this.challengeRectangleX2,this.challengeRectangleY2,this.easingFishColorBright,3)
        fishIsEasing := rectangleHasDarkerColor and rectangleHasBrighterColor
        return fishIsEasing
    }
    ; ----------------------------------------------------------------
    
    fishingClickX => this.context.fishingClickX
    fishingClickY => this.context.fishingClickY
    exclimationRectangleX1 => this.context.exclimationRectangleX1
    exclimationRectangleY1 => this.context.exclimationRectangleY1
    exclimationRectangleX2 => this.context.exclimationRectangleX2
    exclimationRectangleY2 => this.context.exclimationRectangleY2
    exclimationColorDark => this.context.exclimationColorDark
    exclimationColorBright => this.context.exclimationColorBright

    
    ; TODO: Remove dead code
    ; ----------------------------------------------------------------
    ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
    challengeRectangleX1 => this.context.challengeRectangleX1
    challengeRectangleY1 => this.context.challengeRectangleY1
    challengeRectangleX2 => this.context.challengeRectangleX2
    challengeRectangleY2 => this.context.challengeRectangleY2
    challengeWaterColor1 => this.context.challengeWaterColor1
    challengeWaterColor2 => this.context.challengeWaterColor2
    challengeGrasColor1 => this.context.challengeGrasColor1
    challengeGrasColor2 => this.context.challengeGrasColor2
    challengeFrameColor1 => this.context.challengeFrameColor1
    challengeFrameColor2 => this.context.challengeFrameColor2
    pullingFishColorDark => this.context.pullingFishColorDark
    pullingFishColorBright => this.context.pullingFishColorBright
    easingFishColorDark => this.context.easingFishColorDark
    easingFishColorBright => this.context.easingFishColorBright
    ; ----------------------------------------------------------------
}


; State implementations

; Standing next to the water on your right side with the rod in your hand
class IdleState extends FishingStateMachineState {
    handle(){
        this.startFishing()
    }

    startFishing(){
        this.castOut()
        this.changeState(FishingState(this.context))
    }

    castOut(){
        Click("Down Right", this.fishingClickX, this.fishingClickY)
        Sleep(200)
        Click("Up Right", this.fishingClickX, this.fishingClickY)
    }
}

; The rod was cast and you wait
class FishingState extends FishingStateMachineState {
    __New(context) {
        super.__New(context)
        this.initialExclamationVisible := true
    }

    handle(){
        if(this.isSomethingOnTheHook() & !this.initialExclamationVisible){
            this.catchIt()
            
            ; TODO: Remove dead code
            ; ----------------------------------------------------------------
            ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
            if(this.isFishChallenging()){
                this.challengeStarted()
            } else {
                this.itemCatched() ; <---------- stays
            }
            ; ----------------------------------------------------------------
        } else if(!this.isSomethingOnTheHook() && this.initialExclamationVisible) {
            this.initialExclamationVisible := false
        }
    }

    catchIt(){
        Click("Right", this.fishingClickX, this.fishingClickY)
        ; Wait or animation to finish
        Sleep(300)
    }

    itemCatched(){
        this.changeState(IdleState(this.context))
    }

    
    ; TODO: Remove dead code
    ; ----------------------------------------------------------------
    ; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
    challengeStarted(){
        this.changeState(ChallengeState(this.context))
    }
    ; ----------------------------------------------------------------
}

; TODO: Remove dead code
; ----------------------------------------------------------------
; This seems to be dead, if fish challenge stays removed as of 0.9.9.9-f366
; A fish is caressing your hook
class ChallengeState extends FishingStateMachineState {
    __New(context) {
        super.__New(context)
        this.isClickingDown := false
    }

    handle(){
        if(this.isFishChallenging()){
            if(this.isFishPulling()){
                this.ease()
            } else if(this.isFishEasing()) {
                this.pull()
            }
        } else {
            this.ease()
            this.fishCatched()
        }
    }

    pull(){
        if(!this.isClickingDown){
            Click("Down Right", this.fishingClickX, this.fishingClickY)
            this.isClickingDown := true
        }
    }

    ease(){
        if(this.isClickingDown){
            Click("Up Right", this.fishingClickX, this.fishingClickY)
            this.isClickingDown := false
        }
    }

    fishCatched(){
        ; Wait fo animation to finish
        sleep(300)
        this.changeState(IdleState(this.context))
    }
}
; ----------------------------------------------------------------
