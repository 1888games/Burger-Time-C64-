.namespace PETER {


	.label MAX_PEPPER = 3

	PepperRemaining:	.byte 5
	PepperThrown:		.byte 0
	ThrowFrames:		.byte 29, 30, 32, 118
	PepperToShow:		.byte 0

	PepperX:			.fill MAX_PEPPER, 0
	PepperY:			.fill MAX_PEPPER, 0
	PepperTimer:		.fill MAX_PEPPER, 0
	PepperFrame:		.fill MAX_PEPPER, 0
	FrameOffset:		.fill MAX_PEPPER, 0

	XOffset:			.byte -14, 14, 0, 0
	YOffset:			.byte 0, 0, -16, 12
	StartFrame:			.byte 102, 106, 114, 110

	PrevState:			.byte 0
	PrevFrame:			.byte 0
	PrevEndFrame:		.byte 0
	PrevStartFrame:		.byte 0

	.label PepperFrames = 4

	.label PEPPER_WIDTH = 26
	.label PEPPER_HEIGHT = 22



	SetupPepper:     {

		lda #5
		sta PepperRemaining

		lda #0
		sta PepperThrown

		jsr DrawPepper

		rts

	}


	HandleThrow: {

		lda WALKERS.DelayTimer + PETER_SPRITE
		bne NotDone

		lda PrevFrame
		sta WALKERS.Frame + PETER_SPRITE

		lda PrevState
		sta WALKERS.State + PETER_SPRITE

		lda PrevEndFrame
		sta WALKERS.EndFrame + PETER_SPRITE

		lda PrevStartFrame
		sta WALKERS.StartFrame + PETER_SPRITE

	NotDone:




		rts
	}


	ThrowPepper: {

		lda PepperRemaining
		bne SomePepper


		sfx(SFX_MISFIRE)
		rts

	SomePepper:

		lda PepperThrown
		cmp #MAX_PEPPER
		beq Exit


		CanThrow:

			lda #255
			sta POPUP.Timer

			jsr FindFreeSlot

			inc PepperThrown

			sfx(SFX_THROW)

			jsr DecreasePepper

			ldy LastDirection

			//jsr RANDOM.Get
			//and #%00000011
			//tay

			lda XOffset, y
			clc
			adc WALKERS.PosX + PETER_SPRITE
			sta PepperX, x

			lda YOffset, y
			clc
			adc WALKERS.PosY + PETER_SPRITE
			sta PepperY, x

			lda WALKERS.State + PETER_SPRITE
			cmp #STATE_THROW
			beq DontBackup

			lda WALKERS.StartFrame + PETER_SPRITE
			sta PrevStartFrame

			lda WALKERS.EndFrame + PETER_SPRITE
			sta PrevEndFrame

			lda WALKERS.State + PETER_SPRITE
			sta PrevState

			lda WALKERS.Frame + PETER_SPRITE
			sta PrevFrame



		DontBackup:

			lda StartFrame, y
			sta FrameOffset, x

			lda #0
			sta PepperFrame, x 

			lda #PepperFrames
			sta PepperTimer, x

			jmp SetThrow

		Exit:



		rts
	}

	GetNextSpriteEntry: {



		ldx PepperToShow



		Loop:

			inx
			cpx PepperToShow
			beq Done

			cpx #MAX_PEPPER
			beq Wrap

			lda PepperX, x
			beq Loop

			jmp Done

			
		Wrap:

			ldx #255
			jmp Loop


		Done:

			stx PepperToShow



		rts
	}

	FindFreeSlot: {

		ldx #0

		Loop:

			lda PepperX, x
			beq Found

		EndLoop:

			inx
			cpx #MAX_PEPPER
			bcc Loop

		Found:

			rts


	}


	CheckEnemies: {


		ldy #0

		Loop:

			lda ENEMY.State, y
			bmi Done

			cmp #ENEMY.ENEMY_AI
			bne EndLoop

			jsr CheckEnemy

		EndLoop:

			iny
			cpy #ENEMY.MAX_ENEMIES
			bcc Loop


		Done:




		rts
	}


	CheckEnemy: {

		lda WALKERS.DelayTimer, y
		bne NoStun

		lda WALKERS.PosY, y
		sec
		sbc PepperY, x 
		clc
		adc #PEPPER_HEIGHT / 2
		cmp #PEPPER_HEIGHT
		bcs NoStun


		lda WALKERS.PosX, y
		sec
		sbc PepperX, x 
		clc
		adc #PEPPER_WIDTH / 2
		cmp #PEPPER_WIDTH
		bcs NoStun

		jsr ENEMY.MakePeppered


	NoStun:





		rts
	}

	ProcessPepper: {

		lda PepperTimer, x
		beq Ready

		dec PepperTimer, x
		rts

		Ready:

			lda PepperFrame, x
			clc
			adc #1
			cmp #4
			bcc Okay


		RemovePepper:

			lda #0
			sta PepperX, x

			dec PepperThrown

			rts


		Okay:

			sta PepperFrame, x

			lda #PepperFrames
			sta PepperTimer, x

			jsr CheckEnemies



		rts
	}

	UpdateSprite: {

		ldx PepperToShow

		lda PepperX, x
		beq Skip
		sta VIC.SPRITE_7_X

		lda PepperY, x
		sta VIC.SPRITE_7_Y

		lda #WHITE
		sta VIC.SPRITE_COLOR_7

		lda FrameOffset, x
		clc
		adc PepperFrame, x
		sta SPRITE_POINTERS + 7

		jmp GetNextSpriteEntry

		Skip:

		lda #120
		sta SPRITE_POINTERS + 7

		jsr GetNextSpriteEntry



		rts
	}

	UpdatePepper: {

		lda #120
		sta SPRITE_POINTERS + 7

		lda PepperThrown
		beq Exit


		ldx #0

		Loop:

			lda PepperX, x
			beq EndLoop

			jsr ProcessPepper

		EndLoop:

			inx
			cpx #MAX_PEPPER
			bcc Loop


		jmp UpdateSprite


		Exit:


		rts
	}

	DrawPepper: {


		lda #0
		sta ZP.Amount

		lda PepperRemaining
		cmp #10
		bcc OneDigit

		TwoDigits:

			inc ZP.Amount

			sec
			sbc #10
			cmp #10
			bcs TwoDigits

			clc
			adc #26
			sta SCREEN_RAM + 632

			lda ZP.Amount
			clc
			adc #26
			sta SCREEN_RAM + 631

			rts


		OneDigit:

			clc
			adc #26
			sta SCREEN_RAM + 632

			lda #0
			sta SCREEN_RAM + 631

			rts

	}

	DecreasePepper: {

		dec PepperRemaining

		jmp DrawPepper

	}

	IncreasePepper: {

		inc PepperRemaining

		lda PepperRemaining
		cmp #100
		bcc Okay

		lda #99
		sta PepperRemaining


	Okay:

		jmp DrawPepper


	}



}