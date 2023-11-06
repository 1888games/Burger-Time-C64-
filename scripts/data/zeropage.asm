*=$02 "Temp vars zero page" virtual


.label PADDING = 4
.label MAX_SPRITES = 40
.label MAX_LAYERS = 32



ZP: {

	Counter:				.byte 0
	ScreenAddress:			.word 0
	ColourAddress:			.word 0
	Row:					.byte 0
	Column:					.byte 0
	RowOffset:				.byte 0
	CharID:					.byte 0
	Colour:					.byte 0
	StoredXReg:				.byte 0
	EndID:					.byte 0
	Amount:					.byte 0
	StoredYReg:				.byte 0
	CurrentID:				.byte 0
	X:						.byte 0
	Y:						.byte 0
	Temp1:					.byte 0
	Temp4:					.byte 0
	Temp2:					.byte 0
	Temp3:					.byte 0
	FrameCounter:			.byte 0
	LayerID:				.byte 0
	LayerType:				.byte 0
	SourceAddress:			.word 0
	DestinationAddress:		.word 0
	WalkerID:				.byte 0
	X2:						.byte 0
	Y2:						.byte 0
	X_Backup:				.byte 0
	StartID:				.byte 0

 * = * "Backup Addresses" virtual
	ScreenBackupAddress:	.word 0
	ColourBackupAddress:	.word 0
	FunctionAddress:		.word 0

	CharAddress:			.word 0
	CharColourAddress:			.word 0

}


	TextRow:	.byte 0
	TextColumn:	.byte 0

	* = * "Char Addresses" virtual

	CharAddresses_LSB:			.fill MAX_LAYERS, 0
	CharAddresses_MSB:			.fill MAX_LAYERS, 0


	* = * "Colour Addresses" virtual

	ColourAddresses_LSB:		.fill MAX_LAYERS, 0
	ColourAddresses_MSB:		.fill MAX_LAYERS, 0
	
	* = * "Screen Addresses" virtual

	ScreenAddresses_LSB:		.fill MAX_LAYERS, 0
	ScreenAddresses_MSB:		.fill MAX_LAYERS, 0