
.macro sfx(sfx_id)
{		
		:StoreState()

		ldx #sfx_id
		jsr sfx_play

		

		:RestoreState()
}

.macro sfxFromA() {

		:StoreState()

		tax	
		jsr sfx_play

		:RestoreState()

}

* = * "-Sound"

music_on:  .byte 1
channel:	.byte 0

set_sfx_routine:
{
			lda music_on
			bne !on+
			
			lda #<play_no_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_no_music
			sta sfx_play.sfx_routine + 2
			rts
			
		!on:
			lda #<play_with_music
			sta sfx_play.sfx_routine + 1
			
			lda #>play_with_music
			sta sfx_play.sfx_routine + 2
			rts	
}

sfx_play:
{			
	sfx_routine:
			jmp play_with_music
}


//when sid is not playing, we can use any of the channels to play effects
play_no_music:
{			
			lda channels, x
			sta channel

			//lda channel
		//	cmp #3
		//	bne NoWrap

		//	lda #0
		//	sta channel
		//NoWrap:
			
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx channel
			pha
			lda times7,x
			tax
			pla
			jmp sid.init + 6			
			

times7:
.fill 3, 7 * i			
}


play_with_music:
{
			lda wavetable_l,x
			ldy wavetable_h,x
			ldx #7 * 2
			jmp sid.init + 6
			rts
}


StopChannel0: {

	lda #0
	sta $d404

	rts


}




//effects must appear in order of priority, lowest priority first.

.label SFX_TREAD = 0
.label SFX_BOUNCE = 1
.label SFX_COIN = 2
.label SFX_CRUSH = 3
.label SFX_MOVE = 4
.label SFX_LETTER = 5
.label SFX_END = 6
.label SFX_BONUS = 7
.label SFX_BONUS_GOT = 8
.label SFX_EXTRA = 9
.label SFX_THROW = 10
.label SFX_MISFIRE = 11
.label SFX_FALL = 12


channels:	.byte 0, 1, 2, 0, 1, 2

sfx_1: .import binary "../../Assets/sfx/Tread.sfx"
sfx_2: .import binary "../../Assets/sfx/Bounce.sfx"
sfx_3: .import binary "../../Assets/sfx/Coin.sfx"
sfx_4: .import binary "../../Assets/sfx/Crush.sfx"
sfx_5: .import binary "../../Assets/sfx/Move.sfx"
sfx_6: .import binary "../../Assets/sfx/Letter.sfx"
sfx_7: .import binary "../../Assets/sfx/End.sfx"
sfx_8: .import binary "../../Assets/sfx/Bonus.sfx"
sfx_9: .import binary "../../Assets/sfx/BonusGot.sfx"
sfx_10: .import binary "../../Assets/sfx/Extra.sfx"
sfx_11: .import binary "../../Assets/sfx/Throw.sfx"
sfx_12: .import binary "../../Assets/sfx/Misfire.sfx"
sfx_13: .import binary "../../Assets/sfx/Fall.sfx"
//.import binary "../../Assets/sfx/high_blip.sfx"





wavetable_l:
.byte <sfx_1, <sfx_2, <sfx_3, <sfx_4, <sfx_5, <sfx_6, <sfx_7, <sfx_8, <sfx_9, <sfx_10, <sfx_11, <sfx_12, <sfx_13

wavetable_h:
.byte >sfx_1, >sfx_2, >sfx_3, >sfx_4, >sfx_5, >sfx_6, >sfx_7, >sfx_8, >sfx_9, >sfx_10, >sfx_11, >sfx_12, >sfx_13

