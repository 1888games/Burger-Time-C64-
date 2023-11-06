.namespace ENEMY {

	.label MAX_ENEMIES = 6
	.label SAUSAGE = 0
	.label EGG = 1
	.label PICKLE = 2

	.label LEFT = 0
	.label RIGHT = 1

	.label ENEMY_WAIT_SPAWN = 0
	.label ENEMY_AI = 1
	.label ENEMY_PEPPERED = 2
	.label ENEMY_RIDING = 3
	.label ENEMY_STUNNED = 4
	.label ENEMY_LOST = 5
	.label ENEMY_DEAD = 6
	.label NO_ENEMY = 255


	.label LEFT_SPAWN_CHAR = -3
	.label RIGHT_SPAWN_CHAR = 29
	
	.label LEFT_SPAWN_X = 1
	.label RIGHT_SPAWN_X = 255

	.label SPRITE_WIDTH = 14
	.label SPRITE_HEIGHT = 16

	#import "game/gameplay/enemy/enemy_data.asm"
	#import "game/gameplay/enemy/enemy_state.asm"
	#import "game/gameplay/enemy/enemy_ai.asm"
	#import "game/gameplay/enemy/enemy_dead.asm"
	#import "game/gameplay/enemy/enemy_ride.asm"
	#import "game/gameplay/enemy/enemy_stun.asm"
	#import "game/gameplay/enemy/enemy_lost.asm"
	
	LevelID:		.byte 0

	SpawnY:			.fill 24, 47 + (i * 8)

	* = * "Enemy State"
	State:			.fill MAX_ENEMIES + 1, NO_ENEMY
	Type:			.fill MAX_ENEMIES, NO_ENEMY
	Colour:			.fill MAX_ENEMIES, 0
	ProcessAI:		.fill MAX_ENEMIES, 0
	OnBurger:		.fill MAX_ENEMIES, 0
	
	* = * "WalkSpeed"

	WalkSpeed:		.byte 0
	ClimbSpeed:		.byte 0
	BaseWalkSpeed:	.byte 0
	BaseClimbSpeed:	.byte 0
	SpeedTimer:		.byte 0
	SpeedTime:		.byte 250


	Respawning:		.byte 0
	RespawnStart:	.byte 0
	EnemiesThisLevel:	.byte 0
	RespawnID:		.byte 0

	BaseColour:		.byte RED, WHITE, WHITE


	NewGame: {

		lda #WALK_SPEED
		sta WalkSpeed
		sta BaseWalkSpeed

		lda #CLIMB_SPEED
		sta ClimbSpeed
		sta BaseClimbSpeed

		lda #250
		sta SpeedTime


		rts
	}

	NextLevel: {

		lda BaseClimbSpeed
		adc GAME.CurrentLevel
		sta ClimbSpeed

		lda BaseWalkSpeed
		clc
		adc GAME.CurrentLevel
		sta WalkSpeed

		lda LevelID
		clc
		adc #1

		cmp #12
		bcc NoWrap

		lda #6

	NoWrap:

		sta LevelID

		lda SpeedTime
		sec
		sbc #5
		sta SpeedTime
		sta SpeedTimer


		rts
	}

	SetupLevel: {

		lda #0
		sta Respawning


		lda #255
		sta RespawnID

		jsr BlankPointers

		ldy LevelID

		lda EnemiesPerLevel, y
		//lda #1
		sta EnemiesThisLevel

		lda DataStart, y
		tay

		ldx #0

		Loop:

			stx ZP.X2
			sty ZP.Y2

			jsr SpawnEnemy

			ldx ZP.X2
			ldy ZP.Y2
			iny
			inx
			cpx EnemiesThisLevel
			bcc Loop

		//jsr CopySpriteData

		rts
	}

	RespawnEnemy: {

		inc Respawning

		ldy LevelID
		lda DataStart, y
		sta RespawnStart

		txa
		clc
		adc RespawnStart
		tay

		stx ZP.X2

		jmp SpawnEnemy


	}

	SpawnEnemy: {

			lda #128
			sta WALKERS.PosX_Frac, x
			sta WALKERS.PosY_Frac, x


			lda SpawnType, y
			sta Type, x

			lda SpawnDelay, y
			sta WALKERS.DelayTimer, x

			lda #ENEMY_WAIT_SPAWN
			sta State, x

			lda #1
			sta WALKERS.OnFloor, x

			lda #0
			sta ProcessAI, x

		YPos:

			lda Respawning
			beq Respawn

			lda RespawnID
			clc
			adc #1
			cmp EnemiesThisLevel
			bcc Okay
			
			lda #0
		

		Okay:

			sta RespawnID
			clc
			adc RespawnStart
			tay

		Respawn:

			lda SpawnRow, y
			tax

			lda SpawnY, x
			ldx ZP.X2
			sta WALKERS.PosY, x
		

		XPos:

			lda SpawnSide, y
			beq Left

		Right:

			lda #RIGHT_SPAWN_X
			sta WALKERS.PosX, x
			
			jsr SetWalkLeft

			jmp DoType

		Left:

			lda #LEFT_SPAWN_X
			sta WALKERS.PosX, x

			jsr SetWalkRight


		DoType:	

			ldy ZP.Y2

			lda Type, x
			tay	
			lda BaseColour, y

			ldx ZP.X2
			sta Colour, x

	


			rts



	}	

	UpdateSpeed: {

		lda ZP.Counter
		and #%00000111
		bne NoUpdate

		lda SpeedTimer
		beq Ready

		dec SpeedTimer
		rts

	Ready:

		inc WalkSpeed
		inc ClimbSpeed

		lda SpeedTime
		sta SpeedTimer




	NoUpdate:


		rts
	}

	FrameUpdate: {

	
		lda GAME.LevelComplete
		bne Quit

		lda WALKERS.DeadStatus + PETER_SPRITE
		bpl Quit


		jsr UpdateSpeed

		ldx #0

		Loop:

			stx ZP.CurrentID

			lda WALKERS.State, x
			bmi EndLoop

		IsRiding:

			lda ENEMY.State, x
			cmp #ENEMY_RIDING
			bne NotRiding

			jsr HandleRide
			jmp NoAI

		NotRiding:

			cmp #ENEMY_STUNNED
			bne NotStunned

			jsr HandleStunned
			jmp NoAI

		NotStunned:

			cmp #ENEMY_PEPPERED
			bne NotPeppered

			jsr HandlePeppered
			jmp NoAI

		NotPeppered:

			cmp #ENEMY_LOST
			bne NotLost

			jsr HandleLost
			jmp NoAI

		NotLost:

			lda WALKERS.DeadStatus, x
			bmi NotDead

			jsr HandleDead
			jmp NoAI


		NotDead:



			jsr CheckSpawned
			jsr CheckCollision
			jsr CheckBurger

			lda ProcessAI, x
			beq NoAI	

			jsr AI


		NoAI:

			ldx ZP.CurrentID

		EndLoop:

			inx
			cpx #MAX_ENEMIES
			bcc Loop





		Quit:



		rts
	}


	CopySpriteData: {


		ldx #0
		ldy #0

		Loop:


			lda State, x
			bmi Done



			lda WALKERS.PosX, x
			sec 
			sbc #1
			sta VIC.SPRITE_1_X, y

			//jmp SpritePriority

			cmp #230
			bcc SpritePriority

		BGPriority:	


			lda VIC.SPRITE_PRIORITY
			ora VIC.MSB_On + 1, x
			sta VIC.SPRITE_PRIORITY

			jmp DoY


		SpritePriority: 

			lda VIC.SPRITE_PRIORITY
			and VIC.MSB_Off + 1, x
			sta VIC.SPRITE_PRIORITY


	    DoY:

			lda WALKERS.PosY, x
			sec
			sbc #1
			sta VIC.SPRITE_1_Y, y

			lda Colour, x
			sta VIC.SPRITE_COLOR_1, x

			lda WALKERS.Frame, x
			sta SPRITE_POINTERS + 1, x


			iny
			iny
			inx
			cpx #MAX_ENEMIES
			bcc Loop


		Done:


		
		rts





	}

	BlankPointers: {

		ldx #0

		Loop:

			lda #16
			sta SPRITE_POINTERS + 1, x

			lda #255
			sta State, x

			inx
			cpx #MAX_ENEMIES
			bcc Loop


		rts


	}


	CheckCollision: {


	

		lda WALKERS.DeadStatus + PETER_SPRITE
		bpl NoCollision

		lda ENEMY.State, x
		cmp #ENEMY_AI
		bne NoCollision

		lda WALKERS.PosX + PETER_SPRITE
		sec
		sbc WALKERS.PosX, x
		clc
		adc #SPRITE_WIDTH / 2
		cmp #SPRITE_WIDTH
		bcs NoCollision

		lda WALKERS.PosY + PETER_SPRITE
		sec
		sbc WALKERS.PosY, x
		clc 
		adc #SPRITE_HEIGHT / 2
		cmp #SPRITE_HEIGHT
		bcs NoCollision

		lda #0
		sta ProcessAI, x

		jmp PETER.MakeDead
	

	NoCollision:



		rts
	}


	CheckBurger: {








		rts
	}


	CheckSpawned: {

		lda WALKERS.DelayTimer, x
		bne Exit

		lda ENEMY.State, x
		cmp #ENEMY_WAIT_SPAWN
		bne Exit

		lda #ENEMY_AI
		sta ENEMY.State, x

	Exit:

		rts
	}

	


}