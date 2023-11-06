
IRQ: {

	*= * "IRQ"

	.label OpenBorderIRQLine = 249
	.label MainIRQLine =255

	.label ResetBorderIRQLine = 0
	.label MultiplexerIRQLine = 1
	.label SidTime = 5

	MultiIRQLines:	.byte 40, 30
	SidTimer:		.byte 5

	
	DisableCIA: {

		// prevent CIA interrupts now the kernal is banked out
		lda #$7f
		sta IRQControlRegister1
		sta IRQControlRegister2

		rts

	}


	SetupInterrupts: {

		sei 	// disable interrupt flag
		lda VIC.INTERRUPT_CONTROL
		ora #%00000001		// turn on raster interrupts
		sta VIC.INTERRUPT_CONTROL

		lda #<MainIRQ
		ldx #>MainIRQ
		ldy #MainIRQLine
		jsr SetNextInterrupt

		asl VIC.INTERRUPT_STATUS
		cli

		lda #255
		sta SidTimer
		
		lda MAIN.MachineType
		beq NoSkip

	
		lda #SidTime
		sta SidTimer

		NoSkip:


		rts


	}


	CopyPeterIRQ: {


		:StoreState()

			lda MAIN.GameMode
			beq IgnoreSprites

			jsr PETER.CopySpriteData
			jsr ENEMY.CopySpriteData
			jsr POPUP.FrameUpdate

		IgnoreSprites:

			lda #<OpenBorderIRQ
			ldx #>OpenBorderIRQ
			ldy #OpenBorderIRQLine
			jsr SetNextInterrupt

			

			asl VIC.INTERRUPT_STATUS
		:RestoreState()


		rti

	}


	SetNextInterrupt: {

		sta INTERRUPT_VECTOR
		stx INTERRUPT_VECTOR + 1
		sty VIC.RASTER_Y
		lda VIC.SCREEN_CONTROL
		and #%01111111		// don't use 255+
		sta VIC.SCREEN_CONTROL

		rts
	}

	


	OpenBorderIRQ: {

			

		:StoreState()

			//lda #CYAN
		///	sta $d020

		OpenBorder:

			lda MAIN.GameMode
			beq Finish


			lda VIC.SCREEN_CONTROL 
			and #%11110111
			sta VIC.SCREEN_CONTROL 
			
		Finish:

			ldy #MainIRQLine
			lda #<MainIRQ
			ldx #>MainIRQ
			jsr SetNextInterrupt 
			

			lda #0
			sta $dc02

			ldy #2
			jsr INPUT.ReadJoystick
		

		//lda  #BLACK
		//sta $d020


		asl VIC.INTERRUPT_STATUS
		:RestoreState()


		rti

	}

	ResetBorderIRQ: {

		:StoreState()

		ResetBorder:

			lda MAIN.GameMode
			beq Finish


			lda VIC.SCREEN_CONTROL 
			ora #%00001000
			sta VIC.SCREEN_CONTROL 
			
		Finish:

			ldy MAIN.MachineType
			lda MultiIRQLines, y
			tay

			//ldy #MultiplexerIRQLine
			//lda #<PLEXOR.MP_IRQ
			//ldx #>PLEXOR.MP_IRQ
			//jsr SetNextInterrupt 

			lda #<MainIRQ
			ldx #>MainIRQ
			ldy #MainIRQLine
			jsr SetNextInterrupt


		asl VIC.INTERRUPT_STATUS
		:RestoreState()

		rti

	}

	MainIRQ: {

		:StoreState()

		SetDebugBorder(2)

		ResetBorder:	

			lda MAIN.GameMode
			beq KickOffFrameCode

			lda VIC.SCREEN_CONTROL 
			ora #%00001000
			sta VIC.SCREEN_CONTROL 

		KickOffFrameCode:

		

			CheckNTSC:

			lda MAIN.PlayFaster
			beq NoSkip

			ldy SidTimer
			bmi NoSkip
			
			dey
			sty SidTimer
			bne NoSkip

			lda #SidTime
			sta SidTimer
			jsr sid.play

			NoSkip:


			jsr sid.play

			NoPlay:

			lda #TRUE
			sta MAIN.PerformFrameCodeFlag
			
			inc ZP.Counter
	
		Finish:

			ldy #20
			lda #<CopyPeterIRQ
			ldx #>CopyPeterIRQ
			jsr SetNextInterrupt 

			lda #255
	
			sta VIC.SPRITE_0_Y
			sta VIC.SPRITE_1_Y
			sta VIC.SPRITE_2_Y
			sta VIC.SPRITE_3_Y
			sta VIC.SPRITE_4_Y
			sta VIC.SPRITE_5_Y
			sta VIC.SPRITE_6_Y
			sta VIC.SPRITE_7_Y


			lda #0
	
			sta VIC.SPRITE_0_X
			sta VIC.SPRITE_1_X
			sta VIC.SPRITE_2_X
			sta VIC.SPRITE_3_X
			sta VIC.SPRITE_4_X
			sta VIC.SPRITE_5_X
			sta VIC.SPRITE_6_X
			sta VIC.SPRITE_7_X


		NoSprites:


		asl VIC.INTERRUPT_STATUS

		SetDebugBorder(0)


		:RestoreState()

		rti

	}





}