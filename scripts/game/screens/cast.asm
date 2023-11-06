.namespace CAST {


	.label YStart = 42
	.label SpriteX = 116


	RowStart:		.byte 3, 9, 13, 16, 19, 24
	CharNum:		.byte 120, 40, 40, 40, 40, 40
	RowColour:		.byte RED, WHITE, WHITE, WHITE, WHITE, RED


	SpriteFrames:	.byte 19, 38, 60, 74
	SpriteColour:	.byte WHITE, RED, WHITE, WHITE

	SpriteY:		.byte YStart + (9 * 8)
					.byte YStart + (13 * 8)
					.byte YStart + (16 * 8)
					.byte YStart + (19 * 8)
					
	Timer:			.byte 0

	Show: {


		TurnOffScreen()

		jsr GAME.SetColours

		jsr SwitchCharset

		lda #6
		sta MAIN.Debounce
		jsr MAPLOADER.DrawMap

		jsr ColourRows
		jsr SetSprites

		lda #BLACK
		sta VIC.BORDER_COLOR

		TurnOnScreen()


		lda #255
		sta VIC.SPRITE_ENABLE

		lda #127
		sta VIC.SPRITE_MULTICOLOR

		lda #0
		sta VIC.SPRITE_MSB

		lda #240
		sta Timer


		jmp Loop




	}


	SwitchCharset: {

		lda #%00001010
		sta VIC.MEMORY_SETUP

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2

	
		rts
	}


	ColourRows: {


		ldx #0

		RowLoop:

			stx ZP.X

			lda RowColour, x
			sta ZP.Colour

			lda CharNum, x
			sta ZP.Amount

			lda RowStart, x
			tay

			ldx #0

			jsr PLOT.GetCharacter

			ldy #0

		CharLoop:


			lda ZP.Colour
			sta (ZP.ColourAddress), y

			iny
			cpy ZP.Amount
			bcc CharLoop

			ldx ZP.X
			inx
			cpx #6
			bcc RowLoop


		rts
	}


	Loop: {


		jsr MAIN.WaitForIRQ

		jsr SetSprites

		jsr MAIN.CheckStart

		lda Timer
		beq Ready

		dec Timer
		jmp Loop

	Ready:

		jmp HISCORE.Show


	}


	SetSprites: {

		ldx #0
		ldy #0

		Loop:

			lda SpriteFrames, x
			sta SPRITE_POINTERS, x

			lda #SpriteX
			sta VIC.SPRITE_0_X, y

			lda SpriteY, x
			sta VIC.SPRITE_0_Y, y

			lda SpriteColour, x
			sta VIC.SPRITE_COLOR_0, x

			inx
			iny
			iny
			cpx #4
			bcc Loop







		rts
	}
}