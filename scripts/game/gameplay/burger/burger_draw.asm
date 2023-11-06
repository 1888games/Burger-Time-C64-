.namespace BURGER {


	DepthStarts:		.byte 0, 5, 17, 29
	AddAmount:			.byte 0, 1, 1, 2, 7, 8, 8, 9
	LadderLook:			.byte 0, 3, 4, 2, 7, 10, 11, 7

	ScreenChunkOffsets:	.byte 0, 1, 2, 3, 40, 41, 42, 43
	ChunkStarts:		.byte 0, 16, 48, 80, 0, 16, 48, 80
	LadderAdd:			.byte 23, 21, 19, 17, 15, 13

	CharStarts:			.byte 46, 87, 128, 128, 169, 210


	DrawBurger: {

		ldx ZP.LayerID

		jsr GetLayerData

		ldy #0

		Loop:

			sty ZP.Y


			jsr DrawChunk

			ldy ZP.Y
			iny
			cpy #8
			bcc Loop



		rts
	}


	DrawChunk: {

		ldx ZP.LayerID


		tya
		and #%00000011
		clc
		adc PO4, x
		tax

		lda ChunkDepth, x
		sta TroddenAmount
		bne InMotion

		cpy #4
		bcc InMotion

		jmp Exit

	InMotion:


		ldx TroddenAmount
		lda DepthStarts, x
		sta ZP.CharID

		ldx ZP.LayerID

		lda LayerType, x
		sta ZP.LayerType
		tax

		lda CharStarts, x
		clc
		adc ZP.CharID
		sta ZP.CharID

		lda ScreenChunkOffsets, y
		tay

		lda (ZP.ScreenBackupAddress), y
		tax

		lda CHAR_COLORS, x
		and #%01100000
		bne IsLadder


	NotLadder:

		ldx ZP.Y
		lda AddAmount, x
		clc
		adc ZP.CharID
		jmp DrawChar

	IsLadder:

		and #%00100000
		bne DefinitelyLadder

		lda TroddenAmount
		beq NotLadder

		ldx ZP.Y
		cpx #4
		bcs NotLadder

		lda LadderLook, x
		clc
		adc #2
		clc
		adc ZP.CharID
		jmp DrawChar

	DefinitelyLadder:

		ldx ZP.Y
		lda LadderLook, x
		clc
		adc ZP.CharID
		
	DrawChar:

		sta (ZP.ScreenAddress), y
		tax

		lda ZP.LayerType
		cmp #CHEESE
		bne NotCheese

		lda CHAR_COLORS, x
		cmp #RED + 8
		bne StoreColour

		lda #YELLOW + 8
		jmp StoreColour


	NotCheese:

		lda CHAR_COLORS, x

	StoreColour:

		sta (ZP.ColourAddress), y

		cmp #BLUE + 8
		bne Exit

		lda (ZP.ColourBackupAddress), y
		cmp #BLUE + 8
		beq Exit

		lda #BLACK + 8
		sta (ZP.ColourAddress), y

	Exit:

		rts




	}





	RestoreMap: {


		ldx #0

	RestoreLoop:

		lda ScreenChunkOffsets, x
		tay

		lda (ZP.ScreenBackupAddress), y
		sta (ZP.ScreenAddress), y

		lda (ZP.ColourBackupAddress), y
		sta (ZP.ColourAddress), y

		inx
		cpx #8
		bcc RestoreLoop




		rts
	}


	GetLayerData: {

		lda LayerCharY, x
		tay

		lda LayerCharX, x
		tax

		jsr PLOT.GetCharacter

		ldx ZP.LayerID

		rts

	}



}