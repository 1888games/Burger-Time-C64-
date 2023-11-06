//exomizer sfx sys -t 64 -x "inc $d020" -o burger.prg bin/main.prg


.var sid = LoadSid("../assets/music/burger.sid")

MAIN: {

	#import "data/zeropage.asm"

	BasicUpstart2(Entry)

	*=$0840 "Modules"

	#import "data/labels.asm"

	#import "data/vic.asm"
	#import "game/system/irq.asm"
	#import "common/utility.asm"
	#import "common/macros.asm"
	#import "common/input.asm" 
	
	#import "common/maploader.asm"
	#import "common/plot.asm"
	#import "common/random.asm"
	#import "common/text.asm"
	#import "common/sfx.asm"

	#import "game/screens/game.asm"
	#import "game/screens/ready.asm"
	#import "game/screens/cast.asm"
	#import "game/screens/deco.asm"
	#import "game/screens/hi_score.asm"
	#import "game/screens/scoring.asm"
	#import "game/screens/game_over.asm"
	#import "game/screens/enter_name.asm"

	#import "game/gameplay/peter/peter.asm"
	#import "game/gameplay/burger/burger.asm"
	#import "game/gameplay/walker/walker.asm"
	#import "game/gameplay/enemy/enemy.asm"
	#import "game/gameplay/bonus/bonus.asm"


	#import "game/system/score.asm"
	#import "game/system/popup.asm"
	#import "game/system/disk.asm"
	#import "game/system/level.asm"


	* = * "Main"

	PerformFrameCodeFlag:	.byte FALSE
	MachineType: 			.byte PAL

	GameMode:				.byte 0
	Debounce:				.byte 0 

	FramesPerSecond:		.byte 50

	* = * "Entry"

	Entry: {


		lda $2A6
		sta MachineType
		bne Pal

		lda #60
		sta FramesPerSecond

	Pal: 

		jsr IRQ.DisableCIA
		jsr SaveKernalZPOnly

		jsr UTILITY.BankOutKernalAndBasic

		jsr RANDOM.init

		jsr set_sfx_routine
		
		

		jsr IRQ.SetupInterrupts

		lda #MUSIC_SILENT
		jsr sid.init

		jsr SetupVIC

	

	    lda #$50
	    //sta SCORE.Value + 1

		//jsr ENTER_NAME.Check

		//jmp ENTER_NAME.Show
		//jmp SCORING.Show
		//jmp HISCORE.Show
		jmp DECO.Show
		jmp CAST.Show

		//jmp READY.Show

		jmp GAME.Start

	}


	


	LoadScores: {

		jsr DISK.LOAD

		lda LowByte
		sta SCORE.Best + 0

		lda MedByte 
		sta SCORE.Best + 1

		lda HiByte 
		sta SCORE.Best + 2

		lda MillByte 
		sta SCORE.Best + 3

		rts
	}
	
	SetupVIC: {

		lda #%00001100
		sta VIC.MEMORY_SETUP


		//Set VIC BANK 3, last two bits = 00
		lda VIC.BANK_SELECT
		and #%11111100
		sta VIC.BANK_SELECT

	SwitchOnMulticolourMode:

		lda VIC.SCREEN_CONTROL_2
 		and #%11101111
 		ora #%00010000
 		sta VIC.SCREEN_CONTROL_2

		rts
	}
	  



	WaitForIRQ: {

		lda PerformFrameCodeFlag
		beq WaitForIRQ

		lda #0
		sta PerformFrameCodeFlag

		rts
	}

	CheckStart: {

		lda Debounce
		beq Okay

		dec Debounce
		rts

	Okay:

		lda INPUT.JOY_FIRE_NOW + 1
		beq Exit

		pla
		pla

		sfx(SFX_COIN)

		sei

		ldx #$FF
		txs

		jmp READY.Show


	Exit:





		rts
	}

	PlayFaster:	.byte 0

	SaveKernalZP: {

		ldx #2

		Loop:

			lda $00, x
			sta KernalZP, x

			lda GameZP, x
			sta $00, x

			inx
			bne Loop

		rts
	}

	SaveKernalZPOnly: {

		ldx #2

		Loop:

			lda $00, x
			sta KernalZP, x
			inx
			bne Loop

		rts
	}

	SaveGameZP: {

		ldx #2

		Loop:

			lda $00, x
			sta GameZP, x

			lda KernalZP, x
			sta $00, x

			inx
			bne Loop

		rts
	}
	
}

  

* = $810 "Hi score_Data"

		FirstInitials:		.text "nbsak"
		SecondInitials:		.text "gridx"
		ThirdInitials:		.text "mirtc"

		MillByte:			.byte $00, $00, $00, $00, $00
		HiByte:				.byte $02, $01, $00, $00, $00
		MedByte:			.byte $80, $01, $94, $65, $48
		LowByte:			.byte $00, $00, $00, $50, $50

* = $a600 "Game ZP Backup"
	
GameZP:		.fill 256, 0
KernalZP:	.fill 256, 0



#import "data/assets.asm"

* = SCREEN_BACKUP "Screen Backup"


.fill 1024, 0

* = COLOUR_BACKUP "Colour Backup"

.fill 1022, 0
 