.namespace ENEMY {


	.label LadderChance = 72



	AI: {

		lda #0

		sta ProcessAI, x

		lda WALKERS.State, x
		sta NextState
		cmp #STATE_CLIMB_IDLE
		bcc IsWalking

	OnLadder:

		jmp LadderAI

	IsWalking:

		jmp WalkingAI

	}


	* = * "Walking AI"

	WalkingAI: {	


		lda WALKERS.OffsetX, x
		cmp #6
		bne NoIntersection

		lda WALKERS.State, x
		cmp #STATE_WALK_LEFT
		beq WalkingLeft


	WalkingRight:

		lda WALKERS.BlockedRight, x
		beq CheckLadders

		lda #STATE_WALK_LEFT
		sta NextState

		jmp CheckLadders


	WalkingLeft:	

		lda WALKERS.BlockedLeft, x
		beq CheckLadders

		lda #STATE_WALK_RIGHT
		sta NextState

	CheckLadders:

		
		jsr CheckGoUpLadder
		jsr CheckGoDownLadder

	
	NoIntersection:

		jmp ApplyNextState

	}

	ApplyNextState: {

		lda NextState
		cmp WALKERS.State, x
		beq Exit

		tay
		lda Function_LSB, y
		sta ZP.FunctionAddress

		lda Function_MSB, y
		sta ZP.FunctionAddress + 1

		jmp (ZP.FunctionAddress)

		Exit:



		rts
	}


	LadderAI: {

		lda WALKERS.OnFloor, x
		beq NoIntersection

		lda WALKERS.OffsetY, x
		cmp #1
		bcc NoIntersection

		cmp #4
		bcs NoIntersection

		lda WALKERS.State, x
		cmp #STATE_CLIMB_UP
		beq ClimbingUp



	ClimbingDown:


		lda WALKERS.LadderBelow, x
		bne CanContinueDown

		lda #STATE_CLIMB_UP
		sta NextState

	

	CanContinueDown:

		jmp ChooseWalkDirection

		lda WALKERS.CharY, x
		cmp WALKERS.CharY + PETER_SPRITE
		bcs ChooseWalkDirection
		//beq ChooseWalkDirection

		rts

	ClimbingUp:


		lda WALKERS.OverLadder, x
		bne CanContinueUp

		lda #STATE_CLIMB_DOWN
		sta NextState

	CanContinueUp:

		jmp ChooseWalkDirection

		lda WALKERS.CharY, x
		cmp WALKERS.CharY + PETER_SPRITE
		bcc ChooseWalkDirection
		beq ChooseWalkDirection

		rts


	ChooseWalkDirection:


		lda WALKERS.CharX, x
		cmp WALKERS.CharX + PETER_SPRITE
		bcc GoRight


	GoLeft:

		lda WALKERS.BlockedLeft, x
		bne NoIntersection

		lda #STATE_WALK_LEFT
		sta NextState

		jmp ApplyNextState

	GoRight:

		lda WALKERS.BlockedRight, x
		bne NoIntersection

		lda #STATE_WALK_RIGHT
		sta NextState

		

	NoIntersection:

		jmp ApplyNextState


		rts
	}


	CheckGoUpLadder: {

		lda WALKERS.OverLadder, x
		beq DontGoUp


		lda WALKERS.CharY, x
		cmp WALKERS.CharY + PETER_SPRITE
		bcc DontGoUp
		beq CheckRandom

	DoClimb:

		lda #STATE_CLIMB_UP
		sta NextState
		rts

	CheckRandom:

		jsr RANDOM.Get
		cmp #LadderChance
		bcc DoClimb

	DontGoUp:


		rts
	}




	CheckGoDownLadder: {

		lda WALKERS.LadderBelow, x
		beq DontGoDown


		lda WALKERS.CharY + PETER_SPRITE
		cmp WALKERS.CharY, x
		bcc DontGoDown
		beq CheckRandom

	DoClimb:

		lda #STATE_CLIMB_DOWN
		sta NextState
		rts

	CheckRandom:

		jsr RANDOM.Get
		cmp #LadderChance
		bcc DoClimb

	DontGoDown:


		rts
	}



}