.namespace PETER {


	.label FramesPerStance = 13


	Frames:		.byte 17, 31
	ArmsUp:		.byte 0


	SetWin: {

		inc GAME.LevelComplete

		lda #15
		sta FlailCounter

		lda #1
		sta ArmsUp

		jsr SwitchFrame

		lda #0
		sta MAIN.PlayFaster

		lda #MUSIC_COMPLETE
		jsr sid.init

		rts
	}


	SwitchFrame: {

		lda ArmsUp
		eor #%00000001
		sta ArmsUp
		tay

		lda Frames, y
		sta WALKERS.Frame + PETER_SPRITE

		lda #FramesPerStance
		sta DeadTimer

		rts
	}

	HandleWin: {

		lda DeadTimer
		beq Ready

		dec DeadTimer
		rts

		Ready:

			dec FlailCounter
			bpl NotDone

			sei
			ldx #$FF
			txs
			

    		jmp GAME.NextLevel


		NotDone:

			jsr SwitchFrame




		rts

	}



}