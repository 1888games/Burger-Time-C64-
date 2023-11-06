.namespace DECO {


	Counter:	.byte 1, 1, 2
	Xs:			.byte 16, 19, 22
	CanExit:	.byte 0
	AutoTimer:	.byte 180
	Displayed:	.byte 0

	Show: {


		TurnOffScreen()

 		lda #BLUE
		sta VIC.BORDER_COLOR
		sta VIC.BACKGROUND_COLOR

		jsr SwitchCharset

		lda #10
		jsr MAPLOADER.DrawMap

		TurnOnScreen()

		lda #0
		sta VIC.SPRITE_ENABLE
		sta VIC.SPRITE_MULTICOLOR
		sta VIC.SPRITE_MSB
		sta CanExit
		sta Displayed

		jsr ShowCounter


		jmp Loop

   	}


   	Loop: {


		jsr MAIN.WaitForIRQ

		lda Displayed
		bne Done

		jsr MAIN.LoadScores

		inc Displayed

	Done:

		jsr UpdateCounter
		jsr ShowCounter

		
		lda INPUT.JOY_FIRE_NOW + 1
		beq NoFire

	Ready:

		jmp CAST.Show

	NoFire:	

		lda AutoTimer
		beq Ready

		dec AutoTimer
		jmp Loop


	}



   	UpdateCounter: {

   		lda CanExit
   		bne NoWrap1

   		lda Counter + 2
   		sec 
   		sbc #1
   		sta Counter + 2

   		bpl NoWrap1

   		lda #9
   		sta Counter + 2

   		lda Counter + 1
   		sec
   		sbc #1
   		sta Counter + 1

   		bpl NoWrap1

   		lda #9
   		sta Counter + 1

   		dec Counter
   		bpl NoWrap1

   		lda #0
   		sta Counter
   		sta Counter + 1
   		sta Counter + 2

   		inc CanExit
   		

   	NoWrap1:





   		rts
   	}


   	ShowCounter: {	


   		ldx #0


   		DigitLoop:

   			stx ZP.X

   			ldy #23

   			lda Xs, x
   			tax 

   			jsr PLOT.GetCharacter

   			ldx ZP.X

   			lda Counter, x
   			asl
   			asl
   			clc
   			adc #145
   			sta ZP.CharID

   			ldy #0

   			sta (ZP.ScreenAddress), y

   			clc
   			adc #1
   			iny

   			sta (ZP.ScreenAddress), y

   			tya
   			clc
   			adc #39
   			tay

   			lda ZP.CharID
   			clc
   			adc #2
   			sta (ZP.ScreenAddress), y

   			clc
   			adc #1
   			iny
   			sta (ZP.ScreenAddress), y

   			ldx ZP.X
   			inx
   			cpx #3
   			bcc DigitLoop






   		rts
   	}
   	SwitchCharset: {

		lda #%00001010
		sta VIC.MEMORY_SETUP

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		sta VIC.SCREEN_CONTROL_2

	
		rts
	}





 }