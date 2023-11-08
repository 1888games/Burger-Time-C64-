.namespace BONUS {

	* = * "Bonus"

	Bonus_LSB:	.byte <BONUS_CHARS, <[BONUS_CHARS + (8 * 8)], <[BONUS_CHARS + (8 * 16)]
	Bonus_MSB:	.byte >BONUS_CHARS, >[BONUS_CHARS + (8 * 8)], >[BONUS_CHARS + (8 * 16)]


	.label RandomInterval = 50
	.label RandomChanceStart = 20
	.label RandomOffset = 56
	.label ScreenTimeStart = 200


	Timer:				.byte 0
	RandomChance:		.byte 0

	BonusDisplayed:		.byte 0
	ScreenTime:			.byte 0

	BonusRows:		.byte 6, 10, 10, 0, 4, 8
	BonusColumns:	.byte 13, 13, 13, 13, 19, 13
	BonusLadder:	.byte 1, 1, 1, 0, 1, 1

	Row:			.byte 0
	Column:			.byte 0
	BonusType:		.byte 0
	IsLadder:		.byte 0

	Chars:			.byte 13, 37, 38, 22
					.byte 17, 18, 44, 45 

	Colours:		.byte WHITE + 8, WHITE + 8, RED + 8
	Colour:			.byte 0

	BonusTimes:		.byte 12, 8, 4, 0
					.byte 13, 7, 5, 0
					.byte 14, 8, 4, 0
					.byte 28, 22, 16, 12
					.byte 9, 6, 3
					.byte 14, 12, 7, 3


	BonusCount:		.byte 0

	NewGame: {

	
		lda #RandomChanceStart
		clc
		adc #RandomOffset
		sta RandomChance

		lda #255
		sta BonusType

		lda #ScreenTimeStart
		sta ScreenTime

		jsr NewLevel

		rts
	}


	Restart: {

		lda #0
		sta BonusDisplayed

		lda #RandomInterval
		sta Timer


		rts
	}


	CheckBonus: {


		stx ZP.X
		sty ZP.Y

		lda BURGER.TotalLayers

		lda GAME.MapLevel
		asl
		asl
		clc
		adc BonusCount
		tay
		lda BonusTimes, y

		cmp BURGER.TotalLayers
		bne NotSpawn

		inc BonusCount

		jsr SpawnBonus

		NotSpawn:


		ldx ZP.X
		ldy ZP.Y







		rts
	}
	NewLevel: {

		lda #0
		sta BonusCount

		lda RandomChance
		sec
		sbc #1
		cmp #8
		bcs Okay3

		lda #8

	Okay3:

		sta RandomChance

		ldx GAME.MapLevel
		lda BonusRows, x
		sta Row

		lda BonusColumns, x
		sta Column

		lda ScreenTime
		sec
		sbc #10
	
		cmp #140
		bcs Okay2

		lda #140

	Okay2:

		sta ScreenTime

		lda BonusLadder, x
		sta IsLadder

		lda BonusType
		clc
		adc #1
		cmp #3
		bcc Okay

		lda #0

	Okay:

		sta BonusType

		jsr CopyChars

		jsr Restart

		rts
	}


	CopyChars: {

		tax
		lda Bonus_LSB, x
		sta ZP.SourceAddress

		lda Bonus_MSB, x
		sta ZP.SourceAddress + 1

		lda Colours, x
		sta Colour

		
		ldy #0

		Loop1:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (17 * 8), y

			iny
			cpy #16
			bcc Loop1


		ldx #0

		Loop2:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (44 * 8), x

			iny
			inx
			cpy #32
			bcc Loop2


		ldx #0

		Loop3:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (13 * 8), x

			iny
			inx
			cpy #40
			bcc Loop3

		ldx #0

		Loop4:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (37 * 8), x

			iny
			inx
			cpy #48
			bcc Loop4


		ldx #0

		Loop5:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (38 * 8), x

			iny
			inx
			cpy #56
			bcc Loop5

		ldx #0

		Loop6:

			lda (ZP.SourceAddress), y
			sta CHAR_SET + (22 * 8), x

			iny
			inx
			cpy #64
			bcc Loop6



		rts
	}



	Collect: {

		sfx(SFX_BONUS_GOT)

		ldx #PETER_SPRITE
		lda BonusType
		clc
		adc #4
		jsr SCORE.AddScoreType

		jsr PETER.IncreasePepper
		jsr RestoreChars



		rts
	}

	RestoreChars: {


		ldy Row
		ldx Column
		jsr PLOT.GetCharacter

		ldx #0

		lda IsLadder
		beq NoLadder

		ldx #4
		ldy #0

	NoLadder:

		 lda (ZP.ScreenBackupAddress), y
		 sta (ZP.ScreenAddress), y

		 lda (ZP.ColourBackupAddress), y
		 sta (ZP.ColourAddress), y

		 iny
	
		 lda (ZP.ScreenBackupAddress), y
		 sta (ZP.ScreenAddress), y

		 lda (ZP.ColourBackupAddress), y
		 sta (ZP.ColourAddress), y

		 ldy #40

		 lda (ZP.ScreenBackupAddress), y
		 sta (ZP.ScreenAddress), y

		 lda (ZP.ColourBackupAddress), y
		 sta (ZP.ColourAddress), y

		 iny

		 lda (ZP.ScreenBackupAddress), y
		 sta (ZP.ScreenAddress), y

		 lda (ZP.ColourBackupAddress), y
		 sta (ZP.ColourAddress), y

		 lda #0
		 sta BonusDisplayed


		rts
	}


	SpawnBonus: {

		sfx(SFX_BONUS)

		ldy Row
		ldx Column
		jsr PLOT.GetCharacter

		ldx #0

		lda IsLadder
		beq NoLadder

		ldx #4
		ldy #0

	NoLadder:

		 lda Chars, x
		 sta (ZP.ScreenAddress), y

		 lda Colour
		 sta (ZP.ColourAddress), y

		 iny
		 inx

		 lda Chars, x
		 sta (ZP.ScreenAddress), y

		 lda Colour
		 sta (ZP.ColourAddress), y

		 tya
		 clc
		 adc #39
		 tay

		 inx

		 lda Chars, x
		 sta (ZP.ScreenAddress), y

		 lda Colour
		 sta (ZP.ColourAddress), y

		 iny
		 inx

		 lda Chars, x
		 sta (ZP.ScreenAddress), y

		 lda Colour
		 sta (ZP.ColourAddress), y

		 lda #1
		 sta BonusDisplayed

		 lda ScreenTime
		 sta Timer


		rts
	}
		

	FrameUpdate: {

		lda WALKERS.DeadStatus + PETER_SPRITE
		bpl Exit


		lda ZP.Counter
		and #%00000001
		beq Exit

		lda Timer
		beq Ready

		dec Timer
		rts


	Ready:

		lda #RandomInterval
		sta Timer

		lda BonusDisplayed
		bne RemoveBonus

		rts

	RemoveBonus:


		jsr RestoreChars

	Exit:



		rts
	}
}