.namespace ENTER_NAME {

	.label VIEW = 0
	.label ENTER = 1

	.label TIMEOUT = 240

	RowStart:		.byte 0, 3, 6, 9, 13, 15, 17, 19, 21, 23
	CharNum:		.byte 40, 40, 40, 40, 40, 40, 40, 40, 40, 40
	RowColour:		.byte WHITE, WHITE, WHITE, WHITE, RED, RED, RED, RED, RED, RED


	Timer:			.byte 0				

	Screen:				.byte 0
	Colour:				.byte 1

	StartIndexes:		.byte 0

	Rows:				.byte 7, 10, 13, 16, 19

	NameAddresses:		.word SCREEN_RAM + 295, SCREEN_RAM + 415, SCREEN_RAM + 535, SCREEN_RAM + 655, SCREEN_RAM + 775
	ScoreAddresses:		.word SCREEN_RAM + 304, SCREEN_RAM + 424, SCREEN_RAM + 544, SCREEN_RAM + 664, SCREEN_RAM + 784

	TextRows:			.byte 15, 17, 19, 21, 23
	Scores:				.byte 0, 0, 0, 0
	TextIDs:	.byte 49, 50, 51
	Cooldown:		.byte 0
	Waving:		.byte 17, 31

	.label NumberColumn = 3
	.label ScoreColumn = 18
	.label NameColumn = 13
	.label HeaderRow = 12
	.label Top5Row = 10

	* = * "Position"
	PlayerPosition:	.byte 0
	InitialPosition:	.byte 0
	AddColumns:		.byte 6, 0
	AddColumn:		.byte 0
	AddRows:		.byte 251, 0
	AddRow:			.byte 0

	Mode:		.byte 0

	PositionLookup:	.byte 0, 3, 6, 9, 12


	CurrentIndex:		.byte 0
	TargetIndex:		.byte 0
	TargetX:			.byte 0
	TargetY:			.byte 0
	CurrentX:			.byte 0
	CurrentY:			.byte 0
	CurrentFrame:		.byte 0
	FrameTimer:			.byte 0

	.label StartX = 98
	.label StartY = 58
	.label TableY = 177
	.label FrameTime = 4

	Index_X:		.fill 10, StartX + (i * 16)
					.fill 10, StartX + (i * 16)
					.fill 10, StartX + (i * 16)
					.fill 3, StartX + (i * 32) + 8
					.fill 3, StartX + 24 + (i * 8)
					.fill 3, StartX + 24 + (i * 8)
					.fill 3, StartX + 24 + (i * 8)
					.fill 3, StartX + 24 + (i * 8)
					.fill 3, StartX + 24 + (i * 8)
					.fill 5, StartX - 32

	Index_Y:		.fill 10, StartY
					.fill 10, StartY + 24
					.fill 10, StartY + 48
					.fill 3, StartY + 72
					.fill 3, TableY 
					.fill 3, TableY + 16
					.fill 3, TableY + 32
					.fill 3, TableY + 48
					.fill 3, TableY + 64
					.fill 5, TableY + (i * 16) - 8


	ScreenCodes:	.fill 26, i + 1
					.byte 45, 44, 63, 33
					.byte 32, 255, 64


	InitialLookup:	.fill 5, 33 + (i * 3)
	LetterToAdd:	.byte 0
	ExitTimer:		.byte 0


	Show: {


		cli 
		TurnOffScreen()

		jsr GAME.SetColours

		jsr SwitchCharset

		lda #11
		
		jsr MAPLOADER.DrawMap

		jsr ColourRows
		
		lda #BLACK
		sta VIC.BORDER_COLOR

		TurnOnScreen()

		lda #0
		sta VIC.SPRITE_MSB
		sta ExitTimer
		sta CurrentIndex
		sta TargetIndex
		sta CurrentFrame
		
		sta MAIN.GameMode

		lda #1
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR


		lda Mode
		bne EditMode

		lda #TIMEOUT
		sta Timer

		// lda #$04
		// sta SCORE.Value + 2

		// lda #$05
		// sta SCORE.Value + 1
//
		; lda #$75
		; sta SCORE.Value

		//jsr Check
		jsr PopulateTable

		jsr SetupSprite


	EditMode:


		jmp Loop


	}

	SetupSprite: {


		ldx CurrentIndex
		lda Index_X, x
		sta TargetX
		sta VIC.SPRITE_0_X
		sta CurrentX

		lda Index_Y, x
		sta TargetY
		sta VIC.SPRITE_0_Y
		sta CurrentY

		lda #WHITE
		sta VIC.SPRITE_COLOR_0

		lda #PETER.FRAME_CLIMB_DOWN
		sta SPRITE_POINTERS

		lda #8
		sta Cooldown

		rts

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
			cpx #10
			bcc RowLoop


		rts
	}

	Msg:	.text @"saving data\$00"

	ShowSave: {

		jsr UTILITY.ClearScreen

		ldx #15
		ldy #12
		jsr PLOT.GetCharacter

		ldy #0

		Loop:

			lda Msg, y
			beq Done
			sta (ZP.ScreenAddress), y

			lda #WHITE
			sta (ZP.ColourAddress), y

			iny
			jmp Loop

		Done:

		jsr DISK.SAVE

		rts
	}


	Loop: {

		jsr MAIN.WaitForIRQ

		lda ExitTimer
		beq NotExit

		dec ExitTimer
		bne Skip

		jsr ShowSave

		jmp HISCORE.Show

	NotExit:
		jsr CheckJoystick
	
	Skip:

		jsr UpdateSprite
		jsr PositionSprite

		jmp Loop

	}

	CheckJoystick: {

		lda Cooldown
		beq Okay

		dec Cooldown
		rts

	Okay:

		lda TargetIndex
		cmp CurrentIndex
		beq CanMove


		rts

	CanMove:

		lda INPUT.JOY_LEFT_NOW + 1
		beq CheckRight

		lda CurrentIndex
		beq CheckRight

		dec CurrentIndex
		dec TargetIndex

		sfx(SFX_MOVE)

		jmp SetupSprite

	CheckRight:

		lda INPUT.JOY_RIGHT_NOW + 1
		beq CheckDown

		lda CurrentIndex
		cmp #32
		beq CheckDown

		inc CurrentIndex
		inc TargetIndex

		sfx(SFX_MOVE)

		jmp SetupSprite

	CheckDown:

		lda INPUT.JOY_DOWN_NOW + 1
		beq CheckUp

		lda CurrentIndex
		cmp #30
		bcs CheckUp

		lda CurrentIndex
		clc
		adc #10	
		cmp #33
		bcc Valid

		lda #32

	Valid:

		sta TargetIndex
		sta CurrentIndex

		sfx(SFX_MOVE)

		jmp SetupSprite


	CheckUp:	

		lda INPUT.JOY_UP_NOW + 1
		beq CheckFire

		lda CurrentIndex
		cmp #10
		bcc CheckFire

		lda CurrentIndex
		sec
		sbc #10
		sta CurrentIndex
		sta TargetIndex

		sfx(SFX_MOVE)

		jmp SetupSprite


	CheckFire:

		lda INPUT.JOY_FIRE_NOW + 1
		beq Exit

		sfx(SFX_LETTER)

		ldx CurrentIndex
		lda ScreenCodes, x
		bmi Delete

		cmp #64
		beq End

	Letter:

		ldx CurrentIndex
		lda ScreenCodes, x
		sta LetterToAdd

		cmp #32
		beq IsSpace

		lda LetterToAdd
		bpl NotSpace

	IsSpace:

		jmp CheckAdd

	NotSpace:


		ldx PlayerPosition
		lda InitialLookup, x
		clc
		adc InitialPosition
		sta TargetIndex
		tay

		lda Index_X, y
		sta TargetX

		lda Index_Y, y
		sta TargetY

		rts


	End:

		lda #48
		clc
		adc PlayerPosition
		sta TargetIndex
		tay

		lda Index_X, y
		sta TargetX

		lda Index_Y, y
		sta TargetY

		rts


	Delete:

		lda InitialPosition
		beq Exit

		cmp #2
		beq NoDec

		dec InitialPosition

	NoDec:

		jmp Letter


	Exit:	


		rts
	}




	UpdateSprite: {

		CheckFrame:

			lda FrameTimer
			beq Ready

			dec FrameTimer
			jmp CheckMove

		Ready:

			lda #FrameTime
			sta FrameTimer

			lda CurrentFrame
			eor #%00000001
			sta CurrentFrame

		CheckMove:

			lda TargetIndex
			cmp CurrentIndex
			beq NoMove

		CheckX:

			lda CurrentX
			cmp TargetX
			beq CheckY
			bcc IncreaseX

			sec
			sbc #1
			sta CurrentX

			jmp CheckY

		IncreaseX:

			clc
			adc #1
			sta CurrentX


		CheckY:

			lda CurrentY
			cmp TargetY
			beq CheckArrived
			bcc IncreaseY

			sec
			sbc #1
			sta CurrentY

			jmp CheckArrived

		IncreaseY:

			clc
			adc #1
			sta CurrentY

		CheckArrived:

			lda CurrentY
			cmp TargetY
			bne NoMove

			lda CurrentX
			cmp TargetX
			bne NoMove

			lda TargetIndex
			sta CurrentIndex
			cmp #48
			bcc NotEnd

			sfx(SFX_END)

			lda #90
			sta ExitTimer

			rts

		NotEnd:

			jsr CheckAdd

		NoMove:



		rts
	}

	CheckAdd: {

		lda LetterToAdd
		
		ldx PlayerPosition
		ldy InitialPosition
		beq First

		cpy #1
		beq Second


	Third:

		sta ThirdInitials, x

		jsr PopulateTable

		lda CurrentIndex
		cmp #31
		bne NotRub

		jmp Capital_A

	NotRub:

		lda #32
		sta CurrentIndex
		sta TargetIndex

		jmp SetupSprite

		rts


	Second:

		sta SecondInitials, x
		
		jmp MoveStart

	First:

		sta FirstInitials, x
	
	MoveStart:	

		lda LetterToAdd
		bmi NoInc

		inc InitialPosition

	NoInc:

		jsr PopulateTable

	Capital_A:

		lda #0
		sta CurrentIndex
		sta TargetIndex
		jmp SetupSprite


		rts


	Exit:


		rts
	}

	PositionSprite: {

		lda CurrentY
		sta VIC.SPRITE_0_Y

		lda CurrentX
		sta VIC.SPRITE_0_X

		lda ExitTimer
		bne DoWave

		lda CurrentFrame
		clc
		adc #PETER.FRAME_CLIMB_DOWN
		sta SPRITE_POINTERS

		rts


		DoWave:

		ldx CurrentFrame
		lda Waving, x
		sta SPRITE_POINTERS

		rts
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


	Check: {


		//lda MENU.SelectedOption
		//sta Screen

		jmp Player1

		// Player2:


		// 	lda SCORE.Value2 
		// 	sta Scores

		// 	lda SCORE.Value2 + 1
		// 	sta Scores + 1

		// 	lda SCORE.Value2 + 2
		// 	sta Scores + 2


		// 	lda SCORE.Value2+ 3
		// 	sta Scores + 3

		// 	jmp CheckScore

		Player1:

			lda SCORE.Value
			sta Scores

			lda SCORE.Value + 1
			sta Scores + 1

			lda SCORE.Value + 2
			sta Scores + 2

			lda SCORE.Value + 3
			sta Scores + 3

		CheckScore:

			ldx Screen
			lda StartIndexes, x
			sta ZP.StartID

			lda #255
			sta ZP.Amount

			ldx #0

		Loop:

			stx ZP.StoredXReg

			ldx ZP.StartID 

			lda Scores + 3
			cmp MillByte, x
			bcc EndLoop

			beq EqualsMill

				stx ZP.Amount
				jmp Done

			EqualsMill:

				lda Scores + 2
				cmp HiByte, x
				bcc EndLoop

				beq EqualsHigh

			BiggerHigh:

				stx ZP.Amount
				jmp Done

			EqualsHigh:

				lda Scores + 1
				cmp MedByte, x
				bcc EndLoop

				beq EqualsMed

			BiggerMed:

				stx ZP.Amount
				jmp Done

			EqualsMed:

				lda Scores
				cmp LowByte, x
				bcc EndLoop

				stx ZP.Amount
				jmp Done

			EndLoop:	

				inc ZP.StartID

				ldx ZP.StoredXReg
				inx
				cpx #5
				bcc Loop


		Done:

			lda ZP.Amount
			bmi Finish

			stx PlayerPosition

			cpx #4
			bcs NoCopy


		ldx #3
		ldy #4

		CopyLoop:

			lda MillByte, x
			sta MillByte, y

			lda HiByte, x
			sta HiByte, y

			lda MedByte, x
			sta MedByte, y

			lda LowByte, x
			sta LowByte, y

			lda FirstInitials, x
			sta FirstInitials, y

			lda SecondInitials, x
			sta SecondInitials, y

			lda ThirdInitials, x
			sta ThirdInitials, y


			lda PlayerPosition

			dex
			dey
			cpx #255
			beq NoCopy
			cpx PlayerPosition
			bcs CopyLoop


		NoCopy:

			ldx PlayerPosition

			lda Scores + 3
			sta MillByte, x

			lda Scores + 2
			sta HiByte, x

			lda Scores + 1
			sta MedByte, x

			lda Scores
			sta LowByte, x

			lda #0
			sta InitialPosition

			lda #32
			sta FirstInitials, x

			lda #32
			
			sta SecondInitials, x
			sta ThirdInitials, X

			sei
			ldx #$FF
			txs

			jmp Show

			//lda #GAME_MODE_SWITCH_SCORE
			//sta MAIN.GameMode


		Finish:


		rts






	}

}