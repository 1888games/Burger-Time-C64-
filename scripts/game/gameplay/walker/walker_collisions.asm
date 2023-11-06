.namespace WALKERS {

	CheckCollisions: {

		//txa
		//sta $d020

		lda CharY, x
		tay
		dey
		bpl Okay

		iny

		Okay:

		lda CharX, x
		bmi OffScreen
		tax
		//dex

		jsr PLOT.GetCharacter

		ldx ZP.WalkerID

		
		jsr CheckCollideLeft
		jsr CheckCollideRight


		jsr CheckFloor
		jsr CheckLadder
		jsr CheckLadderBelow
		jsr CheckLost

		ldx ZP.WalkerID
		cpx #PETER_SPRITE
		beq Peter

		jsr CheckBurger

		ldx ZP.WalkerID

	Peter:

		rts

		OffScreen:

		//lda #DARK_GRAY

		//sta $d020

		rts
	}


	CheckLost: { 

		cpx #PETER_SPRITE
		bne NotPeter

		rts

	NotPeter:

		lda State,x 
		cmp #STATE_IDLE
		beq NotLost

		cmp #STATE_CLIMB_IDLE
		bcs NotLost

		lda OnFloor, x
		clc
		adc OverLadder, x
		bne NotLost

		CheckSide:

			lda PosX, x
			cmp #128
			bcc LeftSide

		RightSide:

			lda State, x
			cmp #STATE_WALK_LEFT
			beq NotLost


			lda #ENEMY.ENEMY_LOST
			sta ENEMY.State, x

			rts

		LeftSide:

			lda State, x
			cmp #STATE_WALK_RIGHT
			beq NotLost


			lda #ENEMY.ENEMY_LOST
			sta ENEMY.State, x


		NotLost:

	
			rts

	}
	CheckBurger: {

		lda #3
		sta ZP.Amount

		lda WALKERS.PosY, x
		cmp WALKERS.PosY + PETER_SPRITE
		beq NoBurger
	
		lda ZP.ScreenAddress
		sec
		sbc #79
		sta ZP.ScreenAddress

		lda ZP.ScreenAddress + 1
		sbc #0
		sta ZP.ScreenAddress + 1

		ldy #0

		CheckTwoCharsAbove:

			lda (ZP.ScreenAddress), y
			cmp #46
			bcs GetColumn

			dec ZP.Amount

			ldy #40
			lda (ZP.ScreenAddress), y
			cmp #46
			bcs GetColumn

			dec ZP.Amount
			ldy #80
			lda (ZP.ScreenAddress), y
			cmp #46
			bcc NoBurger


		GetColumn:


			ldy #255

			lda WALKERS.CharX, x
			clc
			adc #1
			tax
			cmp #21
			bcs Column4

			cmp #15
			bcs Column3

			cmp #9
			bcs Column2

		Column1:

			iny
			dex
			cpx #2
			bne Column1

			jmp GotChunk

		Column2:

			iny
			dex
			cpx #8
			bne Column2

			jmp GotChunk
		
		Column3:

			
			iny
			dex
			cpx #14
			bne Column3

			jmp GotChunk

		Column4:
	
			iny
			dex
			cpx #20
			bne Column4

		GotChunk:

			inx
		
			stx BURGER.TreadStartX

			sty BURGER.ChunkUnderFoot


			jmp BURGER.ValidateWhack

		NoBurger:






		rts
	}

	CheckFloor: {

		lda #0
		sta OnFloor, x

		lda OffsetY, x
		cmp #6
		bcs NotFloor

		ldy #1

		lda (ZP.ScreenBackupAddress), y
		tay

		lda CHAR_COLORS, y
		and #%00010000
		cmp #CHAR_FLOOR
		bne NotFloor

		inc OnFloor, x

		

		NotFloor:


		rts
	}

	CheckLadderBelow: {


		lda #0
		sta LadderBelow, x

		ldy #41

		//lda (ZP.ColourBackupAddress), y
		//sta VIC.COLOR_RAM + 30

		lda (ZP.ScreenBackupAddress), y
		//sta SCREEN_RAM + 30

		CheckFoot:

			cmp #LEFT_LADDER_FOOT
			beq OverLadderL

			cmp #LEFT_LADDER_FOOT_2
			beq OverLadderL

			cmp #LEFT_LADDER
			beq OverLadderL

			cmp #RIGHT_LADDER_FOOT
			beq OverLadderR

			cmp #RIGHT_LADDER_FOOT_2
			beq OverLadderR

			cmp #RIGHT_LADDER
			beq OverLadderR

			rts

		OverLadderR:

			lda #1
			sta LadderSide, x

			lda OffsetX, x
			cmp #3
			bcc IsLadder

			rts


		OverLadderL:

			lda #0
			sta LadderSide, x

			lda OffsetX, x
			cmp #4
			bcs IsLadder

			rts

		IsLadder:

		inc LadderBelow, x
		rts
	}

	CheckLadder: {

		lda #0
		sta OverLadder, x

		ldy #1

		


		//lda (ZP.ColourBackupAddress), y
		//ta VIC.COLOR_RAM + 12

		lda (ZP.ScreenBackupAddress), y
		//sta SCREEN_RAM + 12


		CheckFoot:

			cmp #LEFT_LADDER_FOOT
			beq OverLadderL

			cmp #LEFT_LADDER_FOOT_2
			beq OverLadderL

			cmp #LEFT_LADDER
			beq OverLadderL

			cmp #RIGHT_LADDER_FOOT
			beq OverLadderR

			cmp #RIGHT_LADDER_FOOT_2
			beq OverLadderR

			cmp #RIGHT_LADDER
			beq OverLadderR

			jmp CheckClimb

		OverLadderR:

			lda #1
			sta LadderSide, x

			lda OffsetX, x
			cmp #3
			bcc OverLaddery

			rts


		OverLadderL:

			lda #0
			sta LadderSide, x

			lda OffsetX, x
			cmp #2
			bcs OverLaddery

			rts


		OverLaddery:

			inc OverLadder, x

		CheckClimb:

		rts

	}

	CheckCollideLeft: {

		lda #0
		sta BlockedLeft, x

		CheckEdge:

			lda PosX, x
			cmp #32
			bcs NotEdgeLeft


		IsBlocked:

			inc BlockedLeft, x
			rts


		NotEdgeLeft:

			ldy #0
			//lda (ZP.ColourBackupAddress), y
			//sta VIC.COLOR_RAM + 18

			lda (ZP.ScreenBackupAddress), y
			//sta SCREEN_RAM + 18
			bne IsFloor

			lda OffsetX, x
			cmp #2
			bcs IsBlocked


		IsFloor:



		rts
	}	

	* = * "Collide Right"

	CheckCollideRight: {


		lda #0
		sta BlockedRight, x

		CheckEdge:

			lda PosX, x
			cmp #223
			bcc NotEdgeRight

		IsBlocked:

			inc BlockedRight, x


			rts

		NotEdgeRight:


			ldy #3
			//lda (ZP.ColourBackupAddress), y
			//sta VIC.COLOR_RAM + 18

			lda (ZP.ScreenBackupAddress), y
			//sta SCREEN_RAM, x
			bne IsFloor



		NoBreak:


			lda OffsetX, x
			cmp #6
			bcs IsBlocked


		IsFloor:


		rts
	}
}