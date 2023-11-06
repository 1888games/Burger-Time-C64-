.namespace ENEMY {


	DeadTimer:		.fill MAX_ENEMIES, 0

	StartFrames:	.byte 50, 80, 66
	ScoreFrames:	.byte 89, 91, 90
	

	.label FrameTime = 5


	MakeDead: {

		lda #0
		sta WALKERS.DeadStatus, x

		lda ENEMY.Type, x
		tay

		lda StartFrames, y
		sta WALKERS.Frame, x
		sta WALKERS.StartFrame, x

		lda #FrameTime
		sta DeadTimer, x

		sfx(SFX_CRUSH)

		// TODO:SFX


		rts
	}

	HandleDead: {


		inc WALKERS.DelayTimer, x
		tay

		CheckFrameTimer:
		
			lda DeadTimer, x
			beq Ready

			dec DeadTimer, x
			rts

		Ready:

			iny
			tya
			sta WALKERS.DeadStatus, x

			cpy #4
			bcc NoRespawn
			beq ShowScore

		Respawn:

			jsr WALKERS.ResetState

			jsr RespawnEnemy

			ldx ZP.X2

			lda #100
			sta WALKERS.DelayTimer, x

			lda VIC.SPRITE_MULTICOLOR
			ora VIC.MSB_On + 1, x
			sta VIC.SPRITE_MULTICOLOR

			rts

		ShowScore:

		
			lda ENEMY.Type, x
			sta ZP.CharID
			clc
			adc #1
			jsr SCORE.AddScoreType

			ldy ZP.CharID
			lda ScoreFrames, y
			sta WALKERS.Frame, x

			lda VIC.SPRITE_MULTICOLOR
			and VIC.MSB_Off + 1, x
			sta VIC.SPRITE_MULTICOLOR

			lda #WHITE
			sta Colour, x

			lda #40
			sta DeadTimer, x

			rts

			// TODO: Show and award score

		NoRespawn:

			inc WALKERS.Frame, x

			lda #FrameTime
			sta DeadTimer, x

			rts


	}

	Respawn: {











	}



}