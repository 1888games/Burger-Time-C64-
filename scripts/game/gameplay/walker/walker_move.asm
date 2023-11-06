.namespace WALKERS {



	Move: {	

	
		lda DelayTimer,x 
		beq CanMove

		dec DelayTimer, x

	NotSpawned:

		rts

	CanMove:



		lda State, x
		cmp #STATE_IDLE
		beq NoMove

		cmp #STATE_CLIMB_IDLE
		beq NoMove

		cmp #STATE_THROW
		beq NoMove

		cmp #STATE_WALK_LEFT
		bne NotLeft

		jmp MoveLeft

	NotLeft:

		cmp #STATE_WALK_RIGHT
		bne NotRight

		jmp MoveRight

	NotRight:

		cmp #STATE_CLIMB_UP
		bne NotClimbUp

		jmp ClimbUp

	NotClimbUp:

		cmp #STATE_CLIMB_DOWN
		bne NotClimbDown

		jmp ClimbDown


	NotClimbDown:


	NoMove:


		rts
	}


	MoveLeft: {

		lda PosX_Frac, x
		sec
		sbc MoveSpeed, x
		sta PosX_Frac, x

		bcs NoMovePixel

		dec PosX, x
		dec PosX, x


		jsr AttachToFloor


		jmp NextFrame

	NoMovePixel:


		rts
	}

	MoveRight: {

		lda PosX_Frac, x
		clc
		adc MoveSpeed, x
		sta PosX_Frac, x

		bcc NoMovePixel

		inc PosX, x
		inc PosX, x

		jsr AttachToFloor

		jmp NextFrame

	NoMovePixel:


		rts
	}





	ClimbDown: {


		lda PosY_Frac, x
		clc
		adc MoveSpeed, x
		sta PosY_Frac, x

		bcc NoMovePixel

		inc PosY, x
		inc PosY, x
		inc PosY, x

		jmp NextFrame

		NoMovePixel:

		lda JerkNextFrame, x
		beq NoJerk

		dec PosY, x
		dec JerkNextFrame, x

		NoJerk:

		rts

	}

	ClimbUp: {


		lda PosY_Frac, x
		sec
		sbc MoveSpeed, x
		sta PosY_Frac, x

		bcs NoMovePixel

		dec PosY, x
		dec PosY, x
		dec PosY, x

		jmp NextFrame

	NoMovePixel:

		lda JerkNextFrame, x
		beq NoJerk

		inc PosY, x
		dec JerkNextFrame, x

		NoJerk:


	rts

	}

}