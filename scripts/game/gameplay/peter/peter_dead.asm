.namespace PETER {


	.label NUMBER_FLAILS = 12

	DeadFrames:		.byte 31, 33, 34, 35, 36, 37
	DeadTimes:		.byte 4, 24, 5, 6, 4, 4

	FlailCounter:	.byte 0
	DeadTimer:		.byte 0




	MakeDead: {

		lda #0
		sta WALKERS.DeadStatus + PETER_SPRITE
		sta FlailCounter

		lda DeadTimes
		sta DeadTimer

		lda #0
		sta MAIN.PlayFaster

		lda #MUSIC_SILENT
		jsr sid.init

		rts


	}

	HandleDead: {

		inc WALKERS.DelayTimer, x
		tay

		CheckFrameTimer:
		
			lda DeadTimer
			beq Ready

			dec DeadTimer
			rts

		Ready:

			iny
			sty WALKERS.DeadStatus + PETER_SPRITE

			cpy #2
			bne NoTriggerMusic

			lda #0
			sta MAIN.PlayFaster

			lda #MUSIC_DEAD
			jsr sid.init

		NoTriggerMusic:

			cpy #6
			bcc NoRespawnCheck

			lda FlailCounter
			cmp #6
			beq ExtraFlail
			cmp #NUMBER_FLAILS
			bcc NoRespawn

			pla
			pla

			jmp DecreaseLives
			

		ExtraFlail:

			lda #10
			sta DeadTimer

			ldy #4
			sty WALKERS.DeadStatus + PETER_SPRITE

			lda DeadFrames + 4
			sta WALKERS.Frame + PETER_SPRITE

			inc FlailCounter

			rts

		NoRespawn:

			ldy #4
			sty WALKERS.DeadStatus + PETER_SPRITE

			inc FlailCounter

		NoRespawnCheck:

			lda DeadFrames, y
			sta WALKERS.Frame + PETER_SPRITE

			lda DeadTimes, y
			sta DeadTimer

			rts

	}



	
}