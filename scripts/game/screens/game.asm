.namespace GAME {




	CurrentLevel:		.byte 0
	MusicTimer:			.byte 110
	Started:			.byte 0
	LevelComplete:			.byte 0
	MapLevel:			.byte 0
	Restarting:			.byte 0


	Start: {


		lda #0
		sta CurrentLevel
		sta ENEMY.LevelID
		sta MapLevel
	
		lda #0
		sta Started
		sta MAIN.GameMode
		sta LevelComplete
		sta MAIN.PlayFaster
		sta Restarting

		lda #100
		sta MusicTimer

		jsr ResetSprites

		jsr MAIN.SetupVIC
		jsr PETER.NewGame
		jsr ENEMY.NewGame
		
		jsr NewLevel
		jsr SCORE.Reset
		jsr BONUS.NewGame

		lda #MUSIC_START
		jsr sid.init

		jmp Show

	}


	ResetSprites: {

		lda #0

		sta VIC.SPRITE_0_X
		sta VIC.SPRITE_1_X
		sta VIC.SPRITE_2_X
		sta VIC.SPRITE_3_X
		sta VIC.SPRITE_4_X
		sta VIC.SPRITE_5_X
		sta VIC.SPRITE_6_X
		sta VIC.SPRITE_7_X




		rts
	}

	NextLevel: {

		cli 
		
		lda #0
		sta MAIN.GameMode
		sta Started

		inc CurrentLevel

		lda MapLevel
		clc
		adc #1
		cmp #6
		bcc Okay

		lda #0

	Okay:	

		sta MapLevel

		jsr MAIN.SetupVIC
		jsr ENEMY.NextLevel
		jsr NewLevel
		jsr BONUS.NewLevel
		jsr PETER.IncreasePepper

		lda #100
		sta MusicTimer



		lda #MUSIC_START
		jsr sid.init


		jmp Show
	}


	Show: {

		TurnOffScreen()

		lda #1
		sta MAIN.GameMode

		jsr SetColours

		lda MapLevel
		jsr MAPLOADER.DrawMap

		jsr SCORE.Draw

		lda #RED
		sta VIC.COLOR_RAM + 151

		jsr BackupMap

		jsr PETER.Spawn
		jsr PETER.DrawPepper
		jsr PETER.DrawLives
		jsr LEVEL.Draw

		lda #127
		sta VIC.SPRITE_MULTICOLOR

		lda #0
		sta VIC.SPRITE_MSB
		sta ZP.FrameCounter
		sta LevelComplete


		lda Started
		beq NewLevel2

		jsr BURGER.ReloadLevel
		jmp Skip

	NewLevel2:

		jsr BURGER.SetupLevel

	Skip:

		lda #1
		sta MAIN.GameMode
		sta Started

		lda #0
		sta Restarting

		TurnOnScreen()

		//jsr BONUS.SpawnBonus

	
		
		jmp Loop
	}



	Restart: {


		jsr MAIN.SetupVIC
		jsr NewLevel

		lda #1
		sta MusicTimer
		sta Restarting


		jmp Show



	}

	BackupMap: {

	
		ldx #250
		lda #0

		Loop:


			lda SCREEN_RAM - 1, x
			sta SCREEN_BACKUP - 1, x

			lda SCREEN_RAM + 249, x
			sta SCREEN_BACKUP + 249, x

			lda SCREEN_RAM + 499, x
			sta SCREEN_BACKUP + 499, x

			lda SCREEN_RAM + 725, x
			sta SCREEN_BACKUP + 725, x

			lda VIC.COLOR_RAM - 1, x
			and #%00001111
			sta COLOUR_BACKUP - 1, x

			lda VIC.COLOR_RAM + 249, x
			and #%00001111
			sta COLOUR_BACKUP + 249, x

			lda VIC.COLOR_RAM + 499, x
			and #%00001111
			sta COLOUR_BACKUP + 499, x

			lda VIC.COLOR_RAM + 725, x
			and #%00001111
			sta COLOUR_BACKUP + 725, x

			dex
			bne Loop


		rts	

	}


	NewLevel: {

		lda #0
		sta VIC.SPRITE_ENABLE
		sta LevelComplete

		jsr WALKERS.SetupLevel
		jsr ENEMY.SetupLevel





		rts
	}


	NewLevelMusic: {

		lda #MUSIC_START
		jsr sid.init


		lda #250
		sta MusicTimer

		rts


	}



	SetColours: {

	
		lda #BLACK
		sta VIC.BORDER_COLOR
		sta VIC.BACKGROUND_COLOR

		lda #ORANGE
		sta VIC.EXTENDED_BG_COLOR_1

		lda #GRAY
		sta VIC.EXTENDED_BG_COLOR_2


		lda #ORANGE
		sta VIC.SPRITE_MULTICOLOR_1

		lda #GREEN
		sta VIC.SPRITE_MULTICOLOR_2

		
	 
		rts

	}


	Loop: {


		jsr MAIN.WaitForIRQ

		//jsr PLEXOR.Sort

		//Set VIC BANK 3, last two bits = 00
		lda VIC.BANK_SELECT
		and #%11111100
		//sta VIC.BANK_SELECT

		lda IRQ.SidTimer
		bpl FrameUpdate



		lda ZP.FrameCounter
		clc
		adc #1
		cmp #6
		bne NoSkip

		lda #0
		sta ZP.FrameCounter

		jmp NoUpdate

		NoSkip:

		sta ZP.FrameCounter

		FrameUpdate:

			lda Restarting
			bne NoUpdate

			jsr MusicUpdate
			jsr PETER.FrameUpdate

			jsr BURGER.FrameUpdate
			jsr WALKERS.FrameUpdate
			jsr ENEMY.FrameUpdate


			jsr SCORE.FrameUpdate
			jsr POPUP.FrameUpdate
			jsr BONUS.FrameUpdate

		NoUpdate:

			* = * "MAin Loop end"
			jmp Loop

	}

	MusicUpdate: {

		lda WALKERS.DeadStatus + PETER_SPRITE
		bpl Finish

		lda LevelComplete
		bne Finish

		lda MusicTimer
		beq Finish


		lda ZP.Counter
		and #%00000001
		beq Finish

		dec MusicTimer
		bne Finish


		lda #1
		sta MAIN.PlayFaster

		lda #MUSIC_MAIN
		jsr sid.init


		Finish:

		rts


	}

	CheckPALDouble: {


		lda IRQ.SidTimer
		bpl NoExtraUpdate

		lda ZP.FrameCounter
		cmp #5
		bne NoExtraUpdate

		lda #255
		sta ZP.FrameCounter

		//jsr sid.play

		jmp Loop.FrameUpdate

	NoExtraUpdate:

		inc ZP.FrameCounter

		jmp Loop
	}
}