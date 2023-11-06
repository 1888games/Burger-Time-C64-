.namespace ENEMY {

	HandleLost: {

	

		lda WALKERS.OnFloor, x
		clc
		adc WALKERS.OverLadder, x
		bne NotLost

	SkipCheck:

		lda WALKERS.PosX, x
		cmp #128
		bcc LeftSide


	RightSide:

		lda WALKERS.PosX, x
		cmp #222

		bcs GoUp2

	GoRight:



		jmp SetWalkRight

	GoUp2:	

		lda WALKERS.OffsetX, x
		cmp #6
		bne GoRight

		jmp SetClimbUp

	LeftSide:

		lda WALKERS.PosX, x
		cmp #35
		bcc GoUp

	GoLeft:

		jmp SetWalkLeft

	GoUp:	

		lda WALKERS.OffsetX, x
		cmp #6
		bne GoLeft

		jmp SetClimbUp

	NotLost:

		lda #ENEMY_AI
		sta State, x


		rts
	}
}