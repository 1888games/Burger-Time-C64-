.namespace ENEMY {

	WalkLeftStart:		.byte 40, 74, 60
	WalkRightStart:		.byte 42, 76, 62
	ClimbUpStart:		.byte 44, 78, 64
	NextState:			.byte 0
	ClimbDownStart:		.byte 38, 72, 58


	.label WALK_SPEED = 70
	.label CLIMB_SPEED = 35


	Function_LSB:	.byte <SetIdle, <SetWalkLeft, <SetWalkRight, <SetIdle, <SetClimbUp, <SetClimbDown
	Function_MSB:	.byte >SetIdle, >SetWalkLeft, >SetWalkRight, >SetIdle, >SetClimbUp, >SetClimbDown
	
	SetIdle: {


		rts
	}

	SetWalkLeft: {

		lda #0
		sta WALKERS.JerkNextFrame, x

		lda WALKERS.OnFloor, x
		beq Exit


		lda WALKERS.State, x
		cmp #STATE_WALK_LEFT
		bne NotAlreadyLeft

		jmp Exit

	NotAlreadyLeft:


		lda #STATE_WALK_LEFT
		sta WALKERS.State, x

		jsr ResetFrac


		lda Type ,x
		tay

		lda WalkLeftStart, y
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda WalkSpeed
		sta WALKERS.MoveSpeed, x

		

		jsr WALKERS.AttachToFloor

	Exit:

		
		rts


	}

	

	SetWalkRight: {

		lda #0
		sta WALKERS.JerkNextFrame, x

		lda WALKERS.OnFloor, x
		beq Exit


		lda WALKERS.State, x
		cmp #STATE_WALK_RIGHT
		bne NotAlreadyLeft

		jmp Exit

	NotAlreadyLeft:


		lda #STATE_WALK_RIGHT
		sta WALKERS.State, x

		jsr ResetFrac

		lda Type, x
		tay

		lda WalkRightStart, y
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda WalkSpeed
		sta WALKERS.MoveSpeed, x

		jsr WALKERS.AttachToFloor

	Exit:

		
		rts


	}


	ResetFrac: {

		lda #128
		sta WALKERS.PosY_Frac, x
		sta WALKERS.PosX_Frac, x

		rts

	}


	SetClimbDown: {

		lda WALKERS.State, x
		cmp #STATE_CLIMB_DOWN
		bne NotAlreadyLeft

		rts

	NotAlreadyLeft:	

		lda #0
		sta WALKERS.JerkNextFrame, x


		jsr ResetFrac

		lda #STATE_CLIMB_DOWN
		sta WALKERS.State, x


		lda Type, x
		tay

		lda ClimbDownStart, y
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda ClimbSpeed
		sta WALKERS.MoveSpeed, x

		//inc DidJoinLadder

		jsr WALKERS.AttachToLadder

		rts
	}

	SetClimbUp: {

		lda WALKERS.State, x
		cmp #STATE_CLIMB_UP
		bne NotAlreadyLeft

		rts

	NotAlreadyLeft:	

		lda #0
		sta WALKERS.JerkNextFrame, x


		jsr ResetFrac

		lda #STATE_CLIMB_UP
		sta WALKERS.State, x


		lda Type, x
		tay

		lda ClimbUpStart, y
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda ClimbSpeed
		sta WALKERS.MoveSpeed, x

		//inc DidJoinLadder

		jsr WALKERS.AttachToLadder

		rts

	}
	



}