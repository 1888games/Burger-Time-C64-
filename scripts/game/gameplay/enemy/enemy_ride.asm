.namespace ENEMY {

	StunFrame:		.byte 54, 84, 70


	HandleRide: {

		inc WALKERS.DelayTimer, x

		lda #0
		sta ZP.Amount

		lda OnBurger, x
		tay


		lda BURGER.LayerState, y
		cmp #BURGER.STATE_STILL
		bne NotStill


	Stun:

	Completed:	

		jsr WALKERS.CalculateOffsets
		jsr WALKERS.AttachToFloor

		lda #ENEMY_STUNNED
		sta State, x

		lda ENEMY.Type, x
		tay

		lda StunFrame, y
		sta WALKERS.Frame, x

		lda ENEMY.Colour, x
		sta OldColour, x

		lda #WHITE
		sta ENEMY.Colour, x

		lda #180
		sta WALKERS.DelayTimer, x

		lda #255
		sta OnBurger, x

		rts

	NotStill:

		cmp #BURGER.STATE_COMPLETE
		beq Completed



	// 	lda BURGER.Chunk1_Depth, y
	// 	sec
	// 	sbc BURGER.PrevDepth, y
	// 	beq NoFineMove
	// 	clc 
	// 	adc #3

	// 	asl
	// 	sec
	// 	sbc #6
	// 	sta ZP.Amount

	// NoFineMove:

	// 	lda BURGER.LayerCharY, y
	// 	sec 
	// 	sbc BURGER.PrevCharY, y
	// 	beq NoCharMove
	// 	clc
	// 	adc #1

	// 	asl
	// 	asl
	// 	asl
	// 	sec
	// 	sbc #8
	// 	clc
	// 	adc ZP.Amount
	// 	sta ZP.Amount

	// NoCharMove:

		lda BURGER.PixelsMoved, y
		beq NoMove

		clc
		adc WALKERS.PosY, x
		sta WALKERS.PosY, x


	NoMove:


		rts
	}


}