.namespace GAME_OVER {

	Timer:		.byte 0

	Text:		.byte 7, 1, 13, 5, 32, 15, 22, 5, 18

	.label Time = 10

	LettersDrawn:	.byte 0

	Show: {

		cli
		
		TurnOffScreen()
		
		lda #0
		sta VIC.SPRITE_MSB
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR
		sta VIC.BORDER_COLOR
		sta LettersDrawn
		sta MAIN.GameMode
		sta GAME.Started

		jsr MAIN.SetupVIC
		jsr READY.SwitchCharset

		jsr UTILITY.ClearScreen

		ldy #12
		ldx #15

		jsr PLOT.GetCharacter

		TurnOnScreen()

		lda #Time
		sta Timer

		jmp Loop


	}




	Loop: {

		jsr MAIN.WaitForIRQ

		lda Timer
		beq Ready

		dec Timer
		jmp Loop


	Ready:

		ldy LettersDrawn
		cpy #9
		beq NextScreen

		lda Text, y
		sta (ZP.ScreenAddress), y

		lda #WHITE
		sta (ZP.ColourAddress), y

		iny
		sty LettersDrawn
		cpy #9
		bcc NextLetter

		lda #60
		sta Timer
		jmp Loop

	NextLetter:

		lda #Time
		sta Timer
		jmp Loop

	NextScreen:

		jsr ENTER_NAME.Check

		jmp HISCORE.Show


	}

}