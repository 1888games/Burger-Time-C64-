.namespace SCORING {


	RowStart:		.byte 3, 7, 10, 15, 19, 24
	CharNum:		.byte 120, 40, 40, 28, 40, 40, 40
	RowColour:		.byte RED, WHITE, WHITE, WHITE, WHITE, RED


	Mode:			.byte 0
	Timer:			.byte 0		


	SpriteFrames:	.byte 86, 87, 88, 17
	SpriteColour:	.byte WHITE, WHITE, RED, WHITE
	SpriteX:		.byte 94, 125, 158, 118
	SpriteY:		.byte 154, 154, 154, 196
							


	Show: {


		TurnOffScreen()

		jsr GAME.SetColours

		jsr SwitchCharset

		lda #8
		jsr MAPLOADER.DrawMap

		jsr ColourRows
		jsr SetSprites
		
		lda #BLACK
		sta VIC.BORDER_COLOR

		TurnOnScreen()

		lda #0
		sta VIC.SPRITE_MSB

		lda #255
		sta VIC.SPRITE_ENABLE

		lda #127
		sta VIC.SPRITE_MULTICOLOR

		lda #240
		sta Timer

		lda #YELLOW + 8
		sta VIC.COLOR_RAM + (9 * 40) + 21
		sta VIC.COLOR_RAM + (9 * 40) + 22
		sta VIC.COLOR_RAM + (9 * 40) + 23
		sta VIC.COLOR_RAM + (9 * 40) + 24

		
		
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

		jmp CAST.Show

	}


	SetSprites: {

		ldx #0
		ldy #0

		Loop:

			lda SpriteFrames, x
			sta SPRITE_POINTERS, x

			lda SpriteX, x
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