.namespace PETER {


	FireCooldown:		.byte 0

	Control: {


	

		ldx #PETER_SPRITE



		CheckIdle:

			lda WALKERS.State, x
			cmp #STATE_IDLE
			bne NotIdle

			jmp HandleIdle

		NotIdle:

			cmp #STATE_WALK_LEFT
			bne NotWalkLeft

			jmp HandleWalkLeft

		NotWalkLeft:

			cmp #STATE_WALK_RIGHT
			bne NotWalkRight

			jmp HandleWalkRight

		NotWalkRight:

			cmp #STATE_CLIMB_UP
			bne NotClimbUp

			jmp HandleClimbUp

		NotClimbUp:

			cmp #STATE_CLIMB_DOWN
			bne NotClimbDown

			jmp HandleClimbDown

		NotClimbDown:

			cmp #STATE_CLIMB_IDLE
			bne NotClimbIdle

			jmp HandleClimbIdle

		NotClimbIdle:

			cmp #STATE_THROW
			bne NotThrow

			jmp HandleThrow

		NotThrow:
			

		rts


	}



	CheckFire: {


		lda FireCooldown
		beq Ready

		dec FireCooldown
		rts

	Ready:
	
	
		lda INPUT.JOY_FIRE_NOW + 1
		beq NoFire

		jsr ThrowPepper


		lda #5
		sta FireCooldown



		NoFire:





		rts
	}

	FreezePlayer: {

		lda #128
		sta WALKERS.PosX_Frac, x
		sta WALKERS.PosY_Frac, x

		rts
	}


	HandleClimbIdle: {


		jsr WALKERS.AttachToLadder

		lda INPUT.JOY_UP_NOW + 1
		beq NotUp
		
		lda #3
		sta LastDirection


		jsr SetClimbUp
		jmp HandleClimbUp


		NotUp:

		lda INPUT.JOY_DOWN_NOW + 1
		beq NotDown

		lda #3
		sta LastDirection

		jsr SetClimbDown
		jmp HandleClimbDown

		NotDown:

		lda WALKERS.Frame, x
		cmp #FRAME_CLIMB_UP_IDLE
		beq HandleUp

		jmp HandleClimbDown

		HandleUp:

		jmp HandleClimbUp







		rts
	}

	HandleClimbUp: {

			jsr WALKERS.AttachToLadder

		CheckLeft:

			lda INPUT.JOY_LEFT_NOW + 1
			beq NotLeft

			lda #0
			sta LastDirection

			lda WALKERS.OnFloor, x
			beq NotJoinFloor

			jsr SetWalkLeft
			jmp HandleWalkLeft

		NotJoinFloor:

			jmp FreezePlayer

		NotLeft:

			lda INPUT.JOY_RIGHT_NOW + 1
			beq CheckUp

			lda #1
			sta LastDirection


			lda WALKERS.OnFloor, x
			beq NotJoinFloor

			jsr SetWalkRight
			jmp HandleWalkRight


		CheckUp:

			lda INPUT.JOY_UP_NOW + 1
			beq NotUp

		Up:	

			lda WALKERS.OverLadder, x
			bne Exit

			lda #2
			sta LastDirection


			lda WALKERS.OffsetY, x
			cmp #3
			bcs Exit

			jmp FreezePlayer

		NotUp:

			lda INPUT.JOY_DOWN_NOW + 1
			beq NotDown

		Down:

			lda #3
			sta LastDirection



			jmp SetClimbDown



		NotDown:

			jsr SetClimbIdleUp

		Exit:


		rts
	}


	HandleClimbDown: {

			jsr WALKERS.AttachToLadder

		CheckLeft:

			lda INPUT.JOY_LEFT_NOW + 1
			beq NotLeft

			lda #0
			sta LastDirection



			lda WALKERS.OnFloor, x
			beq NotJoinFloor

			jsr SetWalkLeft
			jmp HandleWalkLeft

		NotJoinFloor:

			jmp FreezePlayer

		NotLeft:

			lda INPUT.JOY_RIGHT_NOW + 1
			beq CheckUp

			lda #1
			sta LastDirection



			lda WALKERS.OnFloor, x
			beq NotJoinFloor

			jsr SetWalkRight
			jmp HandleWalkRight


		CheckUp:

			lda INPUT.JOY_UP_NOW + 1
			beq NotUp

		Up:	

			lda #2
			sta LastDirection

			jmp SetClimbUp

		NotUp:

			lda INPUT.JOY_DOWN_NOW + 1
			beq NotDown

		Down:	

			lda #3
			sta LastDirection

			jsr SetClimbDown

			lda WALKERS.LadderBelow, x
			bne Exit

			lda WALKERS.OffsetY, x
			cmp #2
			bcc Exit

			jmp FreezePlayer

		NotDown:

			jsr SetClimbIdleDown

		Exit:


		rts
	}

	HandleWalkRight: {


			

		CheckUp:

			lda INPUT.JOY_UP_NOW + 1
			beq NotUp

			lda #2
			sta LastDirection

			lda WALKERS.OverLadder, x
			beq NotUpLadder

			jmp SetClimbUp

		NotUpLadder:

			jmp FreezePlayer

		NotUp:

			lda INPUT.JOY_DOWN_NOW + 1
			beq CheckLeft

			lda #3
			sta LastDirection

			lda WALKERS.LadderBelow, x
			beq NotDownLadder

			jmp SetClimbDown

		NotDownLadder:

			jmp FreezePlayer


		CheckLeft:

			lda INPUT.JOY_LEFT_NOW + 1
			beq NotLeft

		Left:		

			lda #0
			sta LastDirection

			jsr SetWalkLeft

			lda WALKERS.BlockedLeft, x
			beq Exit

			jmp FreezePlayer

		NotLeft:

			lda INPUT.JOY_RIGHT_NOW + 1
			beq NotRight

		Right:	

			lda #1
			sta LastDirection

			lda WALKERS.BlockedRight, x
			beq Exit

			jmp FreezePlayer

		NotRight:

			jsr SetIdle

		Exit:


		rts
	}

	HandleWalkLeft: {

		CheckUp:

			lda INPUT.JOY_UP_NOW + 1
			beq NotUp

			lda #2
			sta LastDirection

			lda WALKERS.OverLadder, x
			beq NotUpLadder

			jmp SetClimbUp

		NotUpLadder:

			jmp FreezePlayer

		NotUp:

			lda INPUT.JOY_DOWN_NOW + 1
			beq CheckLeft

			lda #3
			sta LastDirection

			lda WALKERS.LadderBelow, x
			beq NotDownLadder

			jmp SetClimbDown

		NotDownLadder:

			jmp FreezePlayer


		CheckLeft:

			lda INPUT.JOY_LEFT_NOW + 1
			beq NotLeft

		Left:	

			lda #0
			sta LastDirection

			lda WALKERS.BlockedLeft, x
			beq Exit

			jmp FreezePlayer

		NotLeft:

			lda INPUT.JOY_RIGHT_NOW + 1
			beq NotRight

		Right:

			lda #1
			sta LastDirection

			jsr SetWalkRight

			lda WALKERS.BlockedRight, x
			beq Exit

			jmp FreezePlayer

		NotRight:

			jsr SetIdle

		Exit:


		rts
	}

	HandleIdle: {

		CheckUp:

			lda INPUT.JOY_UP_NOW + 1
			beq NotUp

			lda #2
			sta LastDirection

			lda WALKERS.OverLadder, x
			beq NotUpLadder

			jmp SetClimbUp

		NotUpLadder:

			jmp FreezePlayer

		NotUp:

			lda INPUT.JOY_DOWN_NOW + 1
			beq CheckLeft

			lda #3
			sta LastDirection

			lda WALKERS.LadderBelow, x
			beq NotDownLadder

			jmp SetClimbDown

		NotDownLadder:

			jmp FreezePlayer


		CheckLeft:

			lda INPUT.JOY_LEFT_NOW + 1
			beq NotLeft

		Left:		

			lda #0
			sta LastDirection

			jsr SetWalkLeft

			lda WALKERS.BlockedLeft, x
			beq Exit

			jmp FreezePlayer

		NotLeft:

			lda INPUT.JOY_RIGHT_NOW + 1
			beq NotRight

		Right:

			lda #1
			sta LastDirection

			jsr SetWalkRight

			lda WALKERS.BlockedRight, x
			beq Exit

			jmp FreezePlayer

		NotRight:

			jsr SetIdle

		Exit:

		rts
	}

	GoUp: {

		CheckIfClimbing:

			lda WALKERS.Climbing, x
			beq NotClimbingYet


	AlreadyClimbing:



	NotClimbingYet:


		lda WALKERS.OverLadder, x
		beq Finish


		jmp SetClimbUp


		Finish:


		
		rts
	}


}