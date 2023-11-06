.label STATE_IDLE = 0
.label STATE_WALK_LEFT = 1
.label STATE_WALK_RIGHT = 2
.label STATE_CLIMB_IDLE = 3 
.label STATE_CLIMB_UP = 4
.label STATE_CLIMB_DOWN = 5
.label STATE_THROW = 6


.label DIRECTION_LEFT = 0
.label DIRECTION_RIGHT = 1
.label DIRECTION_UP = 2
.label DIRECTION_DOWN = 3

.label FRAME_MODE_NORMAL = 0
.label FRAME_MODE_PING_UP = 1
.label FRAME_MODE_PING_DOWN = 2


.namespace WALKERS {


	#import "game/gameplay/walker/walker_collisions.asm"
	#import "game/gameplay/walker/walker_move.asm"

	.label MAX_WALKERS = 7

	* = * "Pos X"

	PosX:			.fill MAX_WALKERS, 0
	PosX_Frac:		.fill MAX_WALKERS, 0

	* = * "Pos Y"
	PosY:			.fill MAX_WALKERS, 0
	PosY_Frac:		.fill MAX_WALKERS, 0

	* = * "Char X"
	CharX:			.fill MAX_WALKERS, 0
					.byte 0
	CharY:			.fill MAX_WALKERS, 0

	OffsetX:		.fill MAX_WALKERS, 0
	OffsetY:		.fill MAX_WALKERS, 0


	CanExitLadder:	.fill MAX_WALKERS, 0
	Frame:			.fill MAX_WALKERS, 0
	StartFrame:		.fill MAX_WALKERS, 0
	EndFrame:		.fill MAX_WALKERS, 0
	FrameMode:		.fill MAX_WALKERS, 0
	MoveSpeed:		.fill MAX_WALKERS, 0

	* = * "Walker State"

	State:			.fill MAX_WALKERS, STATE_IDLE
	Direction:		.fill MAX_WALKERS, 0

	BlockedLeft:	.fill MAX_WALKERS, 0

	* = * "Blocked right"
	BlockedRight:	.fill MAX_WALKERS, 0
	OverLadder:		.fill MAX_WALKERS, 0
	LadderSide:		.fill MAX_WALKERS, 0
	OnFloor:		.fill MAX_WALKERS, 0
	JerkNextFrame:	.fill MAX_WALKERS, 0
	LadderBelow:	.fill MAX_WALKERS, 0
	Climbing:		.fill MAX_WALKERS, 0
	Character:		.fill MAX_WALKERS, 0

	* = * "Delay Timer"
	DelayTimer:		.fill MAX_WALKERS, 0
	OffsetNextFrame: .fill MAX_WALKERS, 0
	DeadStatus:		.fill MAX_WALKERS, 0


	ResetState:		{

		lda #0
		sta State, x
		sta BlockedLeft, x
		sta BlockedRight, x
		sta OverLadder, x
		sta OnFloor, x
		sta JerkNextFrame, x
		sta LadderBelow, x
		sta Climbing, x
		sta CanExitLadder, x
		sta OffsetNextFrame, x
		sta DelayTimer, x
		sta Frame, x
		sta MoveSpeed, x
		sta OffsetY, x
		sta OffsetX, x

		lda #255
		sta DeadStatus, x
		


		rts


	}



	ResetAll: {

		ldx #0

		Loop:

			jsr ResetState

			inx
			cpx #MAX_WALKERS
			bcc Loop

		rts


	}


	SetupLevel: {

		jsr ResetAll

		rts
	}

	NextFrame: {

		// x = walker ID



			cpx #PETER_SPRITE
			beq IsPeter
//	
			jsr CalculateOffsets.IsPeter
			jsr CheckCollisions

			lda #1
			sta OffsetNextFrame, x

		IsPeter:

			lda #1
			sta JerkNextFrame, x

		CheckFrameMode:

			lda FrameMode, x
			cmp #FRAME_MODE_PING_DOWN
			bcc IncreaseFrame

		DecreaseFrame:

			dec Frame, x
			lda Frame, x
			cmp StartFrame, x
			bcs Exit

		SetUp:

			lda #FRAME_MODE_PING_UP
			sta FrameMode, x

			lda StartFrame, x
			clc
			adc #1
			sta Frame, x
			rts

		IncreaseFrame:

			inc Frame, x



			lda Frame, x
			cmp EndFrame, x
			bcc Exit
			beq Exit


			lda FrameMode, x
			beq BackTo0

		Reverse:

			lda #FRAME_MODE_PING_DOWN
			sta FrameMode, x

			dec Frame, x
			dec Frame, x

			rts


		BackTo0:

			lda StartFrame, x
			sta Frame, x


		Exit:





		rts
	}


	FrameUpdate: {

		lda GAME.LevelComplete
		bne Exit

		lda DeadStatus + PETER_SPRITE
		bmi NotDead


		rts
		
		NotDead:



		ldx #0

		Loop:

			stx ZP.WalkerID


			lda State, x
			bmi EndLoop
			beq EndLoop

			jsr CalculateOffsets
			jsr Move
			
			ldx ZP.WalkerID

		EndLoop:

			inx
			cpx #7
			bcc Loop

		Exit:

		lda #255
		sta VIC.SPRITE_ENABLE


		rts
	}


	CalculateOffsets: {

		cpx #PETER_SPRITE
		beq IsPeter

		lda OffsetNextFrame, x
		beq Exit

		lda #0
		sta OffsetNextFrame, x

		lda #1
		sta ENEMY.ProcessAI, x
		


	IsPeter:

		//txa
		//sta $d020

		lda PosX, x
		sec
		sbc #1
		lsr
		lsr
		lsr
		sta CharX, x
		asl
		asl
		asl
		sta ZP.Amount


		lda PosX, x
		sec
		sbc #24
		lsr
		lsr
		lsr
		clc
		sta CharX, x

		lda PosX, x
		sec
		sbc #1
		sec
		sbc ZP.Amount
		sta OffsetX, x

		lda PosY, x
		clc
		adc #2
		lsr
		lsr
		lsr
		sta CharY, x
		asl
		asl
		asl
		sta ZP.Amount

		lda CharY, x
		sec
		sbc #4
		sta CharY, x

		lda PosY, x
		clc
		adc #2
		sec
		sbc ZP.Amount
		sta OffsetY, x

		////lda #DARK_GRAY
	//	sta $d020

	Exit:


		rts
	}



	AttachToFloor: {

		cpx #PETER_SPRITE
		beq NotEnemy

		lda ENEMY.State, x
		cmp #ENEMY.ENEMY_WAIT_SPAWN
		beq Exit

	NotEnemy:




		lda WALKERS.OffsetY, x
		cmp #3
		bcs MoveUp


		MoveDown:

			lda #2
			sec
			sbc WALKERS.OffsetY, x
			clc
			adc WALKERS.PosY, x
			sta WALKERS.PosY, x
			rts

		MoveUp:

			sec
			sbc #2
			jsr Reverse
			clc
			adc WALKERS.PosY, x
			sta WALKERS.PosY, x
			rts

		Exit:

		rts
	}

	
	Reverse: {

		eor #%11111111
		clc
		adc #1

		rts
	}


	AttachToLadder: {

			lda WALKERS.OffsetX, x
			cmp #6
			beq NoAdjustX

			cmp #0
			beq AdjustLeft

			cmp #4
			beq AdjustRight

			cmp #2
			bne NotSplit


			lda WALKERS.LadderSide, x
			bne AdjustLeft2

		AdjustRight2:

			lda WALKERS.PosX, x
			clc
			adc #4
			sta WALKERS.PosX, x

			rts


		AdjustLeft2:	

			lda WALKERS.PosX, x
			sec
			sbc #4
			sta WALKERS.PosX, x

		NotSplit:

			rts

		AdjustRight:

			sec
			sbc #2
			clc
			adc WALKERS.PosX, x
			sta WALKERS.PosX, x

			rts

		AdjustLeft:

			clc
			adc #2
			jsr WALKERS.Reverse

			clc
			adc WALKERS.PosX, x
			sta WALKERS.PosX, x

		
		NoAdjustX:

			rts




		}




	

}