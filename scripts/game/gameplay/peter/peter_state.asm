.namespace PETER {



	SetIdle: {

		ldx #PETER_SPRITE

		lda #STATE_IDLE
		sta WALKERS.State, x

		lda #FRAME_IDLE

		sta WALKERS.StartFrame, x
		sta WALKERS.EndFrame, x
		sta WALKERS.Frame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x



		rts
	}

	ResetFrac: {

		lda #128
		sta WALKERS.PosY_Frac, x
		sta WALKERS.PosX_Frac, x

		rts

	}

	
	SetThrow: {

		ldx #PETER_SPRITE

		lda WALKERS.State, x
		cmp #STATE_THROW
		bne NotAlreadyLeft

		rts

	NotAlreadyLeft:

		lda #STATE_THROW
		sta WALKERS.State, x

		ldy LastDirection
		lda ThrowFrames, y
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x
		sta WALKERS.EndFrame, x

		lda #5
		sta WALKERS.DelayTimer, x

		rts
	}	


	SetWalkLeft: {

		ldx #PETER_SPRITE

		lda #0
		sta WALKERS.JerkNextFrame, x

		lda WALKERS.OnFloor, x
		beq Exit


		lda WALKERS.State, x
		cmp #STATE_WALK_LEFT
		bne NotAlreadyLeft

		rts

	NotAlreadyLeft:


		lda #STATE_WALK_LEFT
		sta WALKERS.State, x

		jsr ResetFrac

		lda #FRAME_WALK_LEFT
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #2
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_PING_UP
		sta WALKERS.FrameMode, x

		lda #WALK_SPEED
		sta WALKERS.MoveSpeed, x

		jsr WALKERS.AttachToFloor

	Exit:

		
		rts


	}


	

	SetWalkRight: {

		ldx #PETER_SPRITE

		lda #0
		sta WALKERS.JerkNextFrame, x


		lda WALKERS.OnFloor, x
		beq Exit

		lda WALKERS.State, x
		cmp #STATE_WALK_RIGHT
		bne NotAlreadyRight

		rts

	NotAlreadyRight:


		lda WALKERS.OffsetY, x
		clc
		adc #NUM_CHAR
		//sta SCREEN_RAM + 38

		
		jsr ResetFrac

		lda #STATE_WALK_RIGHT
		sta WALKERS.State, x

		lda #FRAME_WALK_RIGHT
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #2
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_PING_UP
		sta WALKERS.FrameMode, x

		lda #WALK_SPEED
		sta WALKERS.MoveSpeed, x

		jsr WALKERS.AttachToFloor

	Exit:

		rts


	}



	SetClimbIdleUp: {

		jsr SetClimbIdle

		lda #FRAME_CLIMB_UP_IDLE
		sta WALKERS.StartFrame, x
		sta WALKERS.EndFrame, x
		sta WALKERS.Frame, x



		rts
	}


	SetClimbIdleDown: {

		jsr SetClimbIdle

		lda #FRAME_CLIMB_DOWN_IDLE
		sta WALKERS.StartFrame, x
		sta WALKERS.EndFrame, x
		sta WALKERS.Frame, x



		rts
	}

	SetClimbIdle: {


		ldx #PETER_SPRITE

		lda #0
		sta WALKERS.JerkNextFrame, x

		lda WALKERS.State, x
		cmp #STATE_CLIMB_IDLE
		beq NoIdle

		lda #STATE_CLIMB_IDLE
		sta WALKERS.State, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		NoIdle:

		rts
	}



	SetClimbUp: {


		ldx #PETER_SPRITE

		lda WALKERS.State, x
		cmp #STATE_CLIMB_UP
		bne NotAlreadyLeft

		rts

	NotAlreadyLeft:	

		lda #0
		sta WALKERS.JerkNextFrame, x

		lda #2
		sta LastDirection


		jsr ResetFrac

		lda #STATE_CLIMB_UP
		sta WALKERS.State, x

		lda #FRAME_CLIMB_UP
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda #CLIMB_SPEED
		sta WALKERS.MoveSpeed, x

		inc DidJoinLadder

		jsr WALKERS.AttachToLadder

		rts

	}


	SetClimbDown: {


		ldx #PETER_SPRITE

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

		lda #3
		sta LastDirection


		lda #FRAME_CLIMB_DOWN
		sta WALKERS.StartFrame, x
		sta WALKERS.Frame, x

		clc
		adc #1
		sta WALKERS.EndFrame, x

		inc DidJoinLadder

		lda #FRAME_MODE_NORMAL
		sta WALKERS.FrameMode, x

		lda #CLIMB_SPEED
		sta WALKERS.MoveSpeed, x

		jsr WALKERS.AttachToLadder


		rts

	}



	


}