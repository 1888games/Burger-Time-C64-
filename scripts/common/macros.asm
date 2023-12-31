ShowDebug: .byte 0

.macro StoreState() {

	pha // A
	txa
	pha // X
	tya
	pha // Y

}

.macro RestoreState() {

	pla // Y
	tay
	pla // X
	tax
	pla // A

}

.macro SetDebugBorder(value) {

	lda ShowDebug
	beq Finish

	lda #value
	sta $d020

	Finish:
}

.macro TurnOffScreen() {

	lda $d011
	ora #%01100000
    sta $D011
}

.macro TurnOnScreen() {

	lda $d011
	and #%10011111
    sta $D011
}