.namespace BURGER {

	ValidateWhack: {


		ldx #0
		ldy ZP.WalkerID

		lda WALKERS.CharY, y
		sec
		sbc ZP.Amount
		sta TreadStartY

		Loop:

			lda LayerState, x
			bpl Okay

			jmp Done

		Okay:

			cmp #STATE_FALLING
			bne EndLoop
 
			lda LayerCharX, x
			cmp TreadStartX
			bne EndLoop


			lda LayerCharY, x
			cmp TreadStartY
			bne EndLoop
		
		GotBurger:

			ldx ZP.WalkerID
			jmp ENEMY.MakeDead

		EndLoop:

			inx
			cpx #MAX_LAYERS
			beq Done

			jmp Loop



		Done:






		rts
	}

}