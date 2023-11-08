.namespace ENEMY { 


	PepperStage:	.fill MAX_ENEMIES, 0
	PepperTimer:	.fill MAX_ENEMIES, 0
	OldColour:		.fill MAX_ENEMIES, 0

	HandleStunned: {


		lda WALKERS.DelayTimer, x
		bne Exit


	Rejoin:

		lda #ENEMY_AI
		sta State, x

		lda OldColour, x
		sta Colour, x

		jsr WALKERS.CalculateOffsets


		jmp HandleLost.SkipCheck

		Exit:


		rts
	}

	PepX:	.byte 0
	PepY:	.byte 0

	CheckOthers: {

		ldx #0

		Loop:

			stx ZP.X

			lda State, x
			cmp #ENEMY_PEPPERED
			bne EndLoop

			lda #50
			sta PepperTimer, x

			lda #0
			sta PepperStage, x

			lda ENEMY.Type, x
			tax

			lda StunFrame, x
			clc
			adc #1
			ldx ZP.X
			sta WALKERS.Frame, x

		EndLoop:

			inx
			cpx #MAX_ENEMIES
			bcc Loop


		rts
	}

	MakePeppered: {

		lda State, y
		cmp #ENEMY_AI
		beq CanPepper

		cmp #ENEMY_PEPPERED
		beq CanPepper

		rts

	CanPepper:

		stx ZP.Y2

		lda ENEMY.Type, y
		tax

		lda StunFrame, x
		clc
		adc #1
		sta WALKERS.Frame, y
	
		lda #50
		sta PepperTimer, y


		lda #0
		sta PepperStage, y

		lda #1
		sta WALKERS.DelayTimer, y


		lda State, y
		cmp #ENEMY_PEPPERED
		beq AlreadyPeppered

		lda ENEMY.Colour, y
		sta OldColour, y

		lda #WHITE
		sta ENEMY.Colour, y



		lda #ENEMY_PEPPERED
		sta State, y

	AlreadyPeppered:

		//jsr CheckOthers
		
		ldx ZP.Y2
		// TODO:SFX

	NoPepper:
	
		rts
	}


	HandlePeppered: {

		inc WALKERS.DelayTimer, x

		CheckFrameTimer:
		
			lda PepperTimer, x
			beq Ready

			dec PepperTimer, x
			rts

		Ready:
	
			lda WALKERS.Frame, x
			eor #%00000001
			sta WALKERS.Frame, x
			
			lda PepperStage, x
			clc
			adc #1
			sta PepperStage, x
			cmp #8
			bcc Okay

		Revive:

			lda #ENEMY_AI
			sta State, x

			lda WALKERS.StartFrame, x
			sta WALKERS.Frame, x

			lda #0
			sta WALKERS.DelayTimer, x

			lda OldColour, x
			sta Colour, x

			rts

		Okay:


			lda #16
			sta PepperTimer, x

		rts
	}

}