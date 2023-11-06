.namespace PETER {

	CheckCollisions: {

		ldx #PETER_SPRITE
		stx ZP.WalkerID

		jsr CheckBonus

		ldx ZP.WalkerID

		jmp WALKERS.CheckCollisions

	}



	CheckBonus: {

		lda WALKERS.CharY, x
		tay
		dey
		dey
		bpl Okay

		iny

		Okay:

		lda WALKERS.CharX, x
		tax

		jsr PLOT.GetCharacter

		ldy #0
		jsr CheckBonusChar

		iny
		jsr CheckBonusChar

		ldy #40
		jsr CheckBonusChar

		iny
		jsr CheckBonusChar


		//ldy #80
		//jsr CheckBonusChar

		//iny
		//jsr CheckBonusChar
		
		

		rts

	}
	

	CheckBonusChar: {

		lda (ZP.ScreenAddress), y
		tax

	
		lda CHAR_COLORS, x
		and #%10000000
		beq NoBonus

		pla
		pla

		jsr BONUS.Collect

		rts

	NoBonus:


		rts
	}

}