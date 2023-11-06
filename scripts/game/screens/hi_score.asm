.namespace HISCORE {


	.label VIEW = 0
	.label ENTER = 1

	.label TIMEOUT = 240

	RowStart:		.byte 3, 9, 12, 14, 16, 18, 20, 24
	CharNum:		.byte 120, 40, 40, 40, 40, 40, 40, 40
	RowColour:		.byte RED, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, RED


	Timer:			.byte 0				

	Screen:				.byte 0
	Colour:				.byte 1

	StartIndexes:		.byte 0

	Rows:				.byte 8, 11, 14, 17, 20

	NameAddresses:		.word SCREEN_RAM + 335, SCREEN_RAM + 455, SCREEN_RAM + 575, SCREEN_RAM + 695, SCREEN_RAM + 815
	ScoreAddresses:		.word SCREEN_RAM + 344, SCREEN_RAM + 464, SCREEN_RAM + 584, SCREEN_RAM + 704, SCREEN_RAM + 824

	TextRows:			.byte 12, 14, 16, 18, 20
	Scores:	.byte 0, 0, 0, 0
	TextIDs:	.byte 49, 50, 51

	.label NumberColumn = 3
	.label ScoreColumn = 15
	.label NameColumn = 13
	.label HeaderRow = 13
	.label Top5Row = 11

	* = * "Position"
	PlayerPosition:	.byte 0
	InitialPosition:	.byte 0
	AddColumns:		.byte 6, 0
	AddColumn:		.byte 0
	AddRows:		.byte 251, 0
	AddRow:			.byte 0

	Mode:		.byte 0
	Cooldown:	.byte 0

	PositionLookup:	.byte 0, 3, 6, 9, 12



	Show: {


		TurnOffScreen()

		jsr GAME.SetColours

		jsr SwitchCharset

		lda #7
		
		jsr MAPLOADER.DrawMap

		jsr ColourRows
		
		lda #BLACK
		sta VIC.BORDER_COLOR

		TurnOnScreen()

		lda #0
		sta VIC.SPRITE_MSB
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR
		sta MAIN.GameMode

		lda Mode
		bne EditMode

		lda #TIMEOUT
		sta Timer

		jsr PopulateTable

	EditMode:


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
			cpx #8
			bcc RowLoop


		rts
	}


	Loop: {

		jsr MAIN.WaitForIRQ

		//jmp Loop


		lda Mode
		beq ViewMode


	Edit:

		jmp Loop


	ViewMode:

		jsr MAIN.CheckStart
		
		lda Timer
		beq Ready

		dec Timer
		jmp Loop

	Ready:

		jmp SCORING.Show

	}

	PopulateTable: {


	//	jsr PopulateHeader

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID

		Names:

		ldx #0

		Loop:

			lda #WHITE
			sta ZP.Colour

			stx ZP.StoredXReg
			cpx PlayerPosition
			bne NotPlayer

			lda #WHITE
			sta ZP.Colour

			NotPlayer:

			lda TextRows, x
			clc
			adc AddRow
			tay 

			lda #NameColumn
			clc
			adc AddColumn
			tax

			jsr PLOT.GetCharacter

			ldx ZP.StartID
			lda FirstInitials, x

			ldy #0
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			lda SecondInitials, x

			iny
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			lda ThirdInitials, x

			iny
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			inc ZP.StartID

			ldx ZP.StoredXReg
			inx
			cpx #5
			bcc Loop


		Score:

		ldx Screen
		lda StartIndexes, x
		sta ZP.StartID


		ldx #0

		Loop2:

			stx ZP.StoredXReg

			lda #WHITE
			sta ZP.Colour

			cpx PlayerPosition
			bne NotPlayer2

			lda #WHITE
			sta ZP.Colour

			NotPlayer2:

			lda TextRows, x
			clc
			adc AddRow
			tay 

			lda #ScoreColumn
			clc
			adc AddColumn
			tax

			jsr PLOT.GetCharacter

			ldx ZP.StartID

			lda MillByte, x
			sta Scores + 3

			lda HiByte, x
			sta Scores + 2

			lda MedByte, x
			sta Scores + 1

			lda LowByte, x
			sta Scores

			jsr DrawScore

			inc ZP.StartID


		Place:

			ldx ZP.StoredXReg

			lda TextRows, x
			clc
			adc AddRow
			sta TextRow

			lda #NumberColumn
			clc
			adc AddColumn
			sta TextColumn

			ldx ZP.Colour
			lda #TEXT.NUM_START
			clc
			adc ZP.StoredXReg

			//jsr TEXT.Draw

			ldx ZP.StoredXReg
			inx
			cpx #5
			bcc Loop2



		rts
	}

	DrawScore:{

		ldy #7	// screen offset, right most digit
		ldx #ZERO	// score byte index

		lda #4
		sta ZP.EndID

		lda Scores + 3, x
		bne ScoreLoop

		dec ZP.EndID

		lda Scores + 2, x
		bne ScoreLoop

		dec ZP.EndID

		lda Scores + 1, x
		bne ScoreLoop

		dec ZP.EndID


		InMills:

		ScoreLoop:

			lda Scores, x
			pha
			and #$0f	// keep lower nibble
			jsr PlotDigit
			pla
			lsr
			lsr
			lsr	
			lsr // shift right to get higher lower nibble
	NextSet:
			inx 
			cpx ZP.EndID
			bne NoCheck

			cmp #0
			beq Finish

		NoCheck:

			jsr PlotDigit

			cpx ZP.EndID
			beq Finish

			jmp ScoreLoop


		PlotDigit: {

			clc
			adc #TEXT.NUM_START
			sta (ZP.ScreenAddress), y

			lda ZP.Colour
			sta (ZP.ColourAddress), y

			dey
			rts


		}

		Finish:

		rts

	}

}