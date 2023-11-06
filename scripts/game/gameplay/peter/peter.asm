.namespace PETER {

	* = * "Peter" 
	
	.label BASE_FRAME = 17
	
	.label FRAME_IDLE = BASE_FRAME
	.label FRAME_WALK_LEFT = BASE_FRAME + 6
	.label FRAME_WALK_RIGHT = BASE_FRAME + 9
	.label WALK_SPEED = 112
	.label FRAME_CLIMB_UP = BASE_FRAME + 4
	.label CLIMB_SPEED = 59
	.label FRAME_CLIMB_DOWN = BASE_FRAME + 1
	.label FRAME_CLIMB_DOWN_IDLE = BASE_FRAME
	.label FRAME_CLIMB_UP_IDLE = BASE_FRAME + 3
		
	



	#import "game/gameplay/peter/peter_collisions.asm"
	#import "game/gameplay/peter/peter_control.asm"
	#import "game/gameplay/peter/peter_state.asm"
	#import "game/gameplay/peter/peter_dead.asm"
	#import "game/gameplay/peter/peter_pepper.asm"
	#import "game/gameplay/peter/peter_win.asm"
	#import "game/gameplay/peter/peter_lives.asm"

	SpawnX:			.byte 127, 127, 127, 127, 175, 127
	SpawnX_Char:	.byte 12, 12, 12, 12, 16, 12
	SpawnY:			.byte 192, 208, 224, 160, 224, 192
	SpawnY_Char:	.byte 17, 19, 21, 13, 21, 17	
	AnyJoyMove:		.byte 0
	DidJoinLadder:	.byte 0
	LastDirection:	.byte 0

	DidWalkLastFrame:	.byte 0
	LastX:				.byte 0




	NewGame: {

		jsr SetupPepper
		jsr SetupLives

		rts
	}

	Spawn: {

		ldx GAME.MapLevel

		lda SpawnX, x
		sta WALKERS.PosX + PETER_SPRITE

		lda SpawnX_Char, x
		sta WALKERS.CharX + PETER_SPRITE

		lda #128
		sta WALKERS.PosX_Frac + PETER_SPRITE
		sta WALKERS.PosY_Frac + PETER_SPRITE

		lda #1
		sta LastDirection

		lda SpawnY, x
		sta WALKERS.PosY + PETER_SPRITE

		lda SpawnY_Char, x
		sta WALKERS.CharY + PETER_SPRITE

		lda #WHITE
		//sta SpriteColor	 + PETER_SPRITE

		sta VIC.SPRITE_COLOR_0

		lda #255
		sta WALKERS.DeadStatus + PETER_SPRITE

		lda #0
		sta DeadTimer
		sta PepperThrown
		sta PepperX
		sta PepperX + 1
		sta PepperX + 2

		jsr SetIdle


		jsr CopySpriteData

	
		rts

	}



	FrameUpdate: {



		ldx #PETER_SPRITE
		stx ZP.WalkerID

		lda WALKERS.DeadStatus + PETER_SPRITE
		bmi NotDead

		jmp HandleDead

	NotDead:

		lda GAME.LevelComplete
		beq NotComplete

		jmp HandleWin

	NotComplete:

		jsr WALKERS.CalculateOffsets

	
		jsr CheckCollisions
		jsr Control
		
		jsr CheckFire
		jsr CheckTread
		jsr UpdatePepper

// lda WALKERS.OffsetX + PETER_SPRITE
// 		clc
// 		adc #26
// 		sta SCREEN_RAM

// 		lda WALKERS.OffsetY + PETER_SPRITE
// 		clc
// 		adc #26
// 		sta SCREEN_RAM + 2
// 		jsr ShowDebug

		rts

	}


	
	CheckTread: {


		lda WALKERS.PosX + PETER_SPRITE
		cmp LastX
		beq Finish

		// lda WALKERS.OffsetX + PETER_SPRITE
		// clc
		// adc #26
		// sta SCREEN_RAM + 4

		ldy #1
		lda (ZP.ScreenAddress), y
		//sta SCREEN_RAM + 35
		cmp #46
		bcc Finish

			
		// 	lda WALKERS.State + PETER_SPRITE
		// 	cmp #STATE_WALK_LEFT
		// 	beq GoingLeft


		// GoingRight:

		// 	lda WALKERS.OffsetX + PETER_SPRITE
		// 	cmp #4
		// 	bcc Finish

		// 	jmp GetColumn

		// GoingLeft:

		// 	lda WALKERS.OffsetX + PETER_SPRITE
		// 	cmp #3
		// 	bcs Finish
			

		GetColumn:


			ldy #255

			lda WALKERS.CharX + PETER_SPRITE
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
			tya
			clc
			adc #NUM_CHAR
			//sta SCREEN_RAM + 78

			jsr BURGER.ValidateTread
		

		Finish:

		lda WALKERS.PosX + PETER_SPRITE
		sta LastX


			rts

	}


	ShowDebug: {

		lda WALKERS.OffsetX + PETER_SPRITE
		clc
		adc #NUM_CHAR 
		sta SCREEN_RAM

		lda WALKERS.OffsetY + PETER_SPRITE
		clc
		adc #NUM_CHAR 
		sta SCREEN_RAM + 2

		lda #WHITE
		sta ZP.Colour

		lda WALKERS.CharX + PETER_SPRITE
		ldx #4
		ldy #0
		jsr TEXT.DrawByte

		lda WALKERS.CharY + PETER_SPRITE
		ldx #8
		ldy #0
		jsr TEXT.DrawByte


		lda WALKERS.OverLadder + PETER_SPRITE
		clc
		adc #NUM_CHAR 
		sta SCREEN_RAM + 14

		lda WALKERS.State + PETER_SPRITE
		clc
		adc #NUM_CHAR 
		sta SCREEN_RAM + 20

		lda WALKERS.OnFloor + PETER_SPRITE
		clc
		adc #NUM_CHAR 
		sta SCREEN_RAM + 15


		rts
	}

	CopySpriteData: {

		lda WALKERS.PosY + PETER_SPRITE
		cmp #255
		beq Hide
		sec
		sbc #1
		//sta SpriteY + PETER_SPRITE

		sta VIC.SPRITE_0_Y


		lda WALKERS.PosX + PETER_SPRITE
		sta VIC.SPRITE_0_X

		lda WALKERS.Frame + PETER_SPRITE
		//sta SpritePointer + PETER_SPRITE

		sta SPRITE_POINTERS

		rts

	Hide:

		lda #16
		sta SPRITE_POINTERS


		rts

	}

	




	
	


}