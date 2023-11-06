
.namespace BURGER {


	BurgerHead: {





		rts
	}

	TreadOnChunk: {

			stx ZP.LayerID

		GetChunkID:

			lda PO4, x
			sta ZP.Temp4
			clc
			adc ChunkUnderFoot
			sta ZP.Amount
			tax

		CheckTroddenAlready:

			lda ChunkTrodden, x
			bne Done

			inc ChunkTrodden, x

			lax ZP.Temp4
			clc
			adc #4
			sta ZP.EndID

		Cascade:

			lda ChunkDepth, x
			beq NoCascade

			lda ChunkDepth, x
			cmp #3
			bcs BurgerFall

			inc ChunkDepth, x

		NoCascade:

			inx
			cpx ZP.EndID
			bcc Cascade

			ldx ZP.Amount

			inc ChunkDepth, x

			jmp DrawAndSFX

		BurgerFall:

			ldx ZP.Temp4
			lda #3

		FallLoop:

			sta ChunkDepth, x

			inx
			cpx ZP.EndID
			bcc FallLoop	

			ldx ZP.LayerID


			lda #0
			sta LayerSmash, x
			jsr MakeBurgerFall
			jsr CheckEnemies


		DrawAndSFX:

			sfx(SFX_TREAD)

			ldx ZP.LayerID
			jmp DrawBurger

		Done:


		rts

	}


	CheckEnemies: {


		ldx ZP.LayerID
		ldy #0

		lda #0
		sta EnemiesDropped, x

		Loop:

			lda WALKERS.State, y
			beq EndLoop
			cmp #STATE_CLIMB_IDLE
			bcs EndLoop



			lda LayerCharY, x
			sec
			sbc WALKERS.CharY, y
			cmp #255
			bne EndLoop

	
			lda WALKERS.CharX, y
			clc
			adc #1
			sec
			sbc LayerCharX, x
			bmi EndLoop

			cmp #4
			bcs EndLoop

			bne NotZero

			lda WALKERS.OffsetX, y
			cmp #6
			bne EndLoop

		NotZero:

			lda LayerSmash, x
			bne AlreadySmashing

			clc
			adc #1

		AlreadySmashing:

			clc
			adc #1
			//lda #4
			sta LayerSmash, x

			lda WALKERS.PosY, y
			clc
			adc #3
			sta WALKERS.PosY, y
			
			tya
			sta EnemyDroppedID, x

			lda ENEMY.State, y
			cmp #ENEMY.ENEMY_PEPPERED
			bne NotPeppered

			lda ENEMY.OldColour, y
			sta ENEMY.Colour, y

		NotPeppered:
	
			lda #ENEMY.ENEMY_RIDING
			sta ENEMY.State, y

			sta WALKERS.DelayTimer, y

			txa
			sta ENEMY.OnBurger, y

			inc EnemiesDropped, x

			lda #0
			sta WALKERS.CharY, x
			

		EndLoop:

			iny
			cpy #ENEMY.MAX_ENEMIES
			bcc Loop


		lda EnemiesDropped, x
		beq NoSFX

		sfx(SFX_FALL)

		NoSFX:


		rts
	}

	MakeBurgerFall: {


		lda LayerState, x
		bne Exit
		
		lda #STATE_FALLING
		sta LayerState, x

		lda #FALL_FRAMES
		sta LayerTimer, x

		lda #0
		sta AboutToBounce, x


		Exit:

		rts


	}



	ValidateTread: {

		ldx #0

		lda WALKERS.CharY + PETER_SPRITE
		sec
		sbc #1
		sta TreadStartY

		Loop:

			lda LayerState, x
			bpl Okay

			jmp Done

		Okay:

			cmp #STATE_STILL
			bne EndLoop

			lda LayerCharX, x
			cmp TreadStartX
			bne EndLoop

			lda LayerCharY, x
			cmp TreadStartY
			bne EndLoop
		
		GotBurger:

			
			jmp TreadOnChunk

		EndLoop:

			inx
			cpx #MAX_LAYERS
			beq Done

			jmp Loop



		Done:





		rts
	}
	

}