	.text
	.global main
	.cpu cortex-m4
	.syntax unified

main:
		//Base address for Port A (0x48000000)
		MOV R4, #0x0000
		MOVT R4, #0x4800

		//Base address for Port C (0x48000800)
		MOV R5, #0x0800
		MOVT R5, #0x4800

		//Address of the RCC AHB2 ENR (0x4002104C)
		MOV R6, #0x104C
		MOVT R6, #0x4002
		//Enable the clocks for port A and Port C
		MOV R0, #0b00000101  // bit 0 for PA and bit 2 for PC
		STR R0, [R6]

		// Configure LED2 (PA5) as output
		MOV R1, #0x0800
		MVN R1, R1    //Flip the bits
		// read PA MODER, bitmask, writeback
		LDR R0, [R4]
		AND R0, R0, R1 // bitmask tasked to reset bit 11
		STR R0, [R4]   // put it back

		// Configure LED4 (PA0) as output
		MOV R1, #0x002
		MVN R1, R1    //Flip the bits
		// read PA MODER, bitmask, writeback
		LDR R0, [R4]
		AND R0, R0, R1 // bitmask tasked to reset bit 11
		STR R0, [R4]   // put it back



		//Configure Button1 (PC13) as input
	    // make a bitmask
		MOV R1, #0x0000
		MOVT R1, #0x0C00
		MVN R1, R1    //Flip the bits
		// read PC MODER, bitmask, writeback
		LDR R0, [R5]
		AND R0, R0, R1 // bitmask tasked to reset bits 26 and 27
		STR R0, [R5]   // put it back

		//Configure Button3 (PA1) as input
	    // make a bitmask
		MOV R1, #0x000C
		MVN R1, R1    //Flip the bits
		// read PA MODER, bitmask, writeback
		LDR R0, [R4]
		AND R0, R0, R1 // bitmask tasked to reset bits 2 and 3
		STR R0, [R4]   // put it back


		//Enable Pull-up for PA1

		// read PA port register
		MOV R1, #0x0004

		LDRH R0, [R4, #0x0C] // get PA PUPDR (PA base + 0x0C)
		ORR R0, R0, R1	    // set bit 2
		STRH R0, [R4, #0x0C] // put it back


loop:
		//Read the status of Button 1 (PC13)
		//create bitmask
		MOV R1, #0x2000
		// read the PC IDR and do the bitmask
		LDRH R0, [R5, #0x10]   //(PC base + 0x10)
		AND R0, R0, R1		  // bitmask to reset all but bit 13


		// Check the Value ( zero == pushed, not zero == not pushed)
		CMP R0, #0
		BNE button1notpushed
		BEQ button1pushed

button1pushed:
		BL turnonLED2
		B check3

button1notpushed:
		BL turnoffLED2



check3:
		//Read the status of Button 3 (PA1)
		//create bitmask
		MOV R1, #0x0002
		// read the PC IDR and do the bitmask
		LDRH R0, [R4, #0x10]   //(PC base + 0x10)
		AND R0, R0, R1		  // bitmask to reset all but bit 2


		// Check the Value ( zero == pushed, not zero == not pushed)
		CMP R0, #0
		BNE button3notpushed
		BEQ button3pushed

button3pushed:
		BL turnonLED4
		B loop

button3notpushed:
		BL turnoffLED4
		B loop

turnonLED2:
		// create bitmask
		MOV R1, #0x0020

		// read PA port register
		LDRH R0, [R4, #0x14] // get PA ODR (PA base + 0x14)
		ORR R0, R0, R1	    // set bit 5
		STRH R0, [R4, #0x14] // put it back

		BX  LR


turnoffLED2:
		// create bitmask
		MOV R1, #0x0020
		MVN R1, R1 // flip bits

		// read PA port register, bitmask, writeback
		LDRH R0, [R4, #0x14] // get PA ODR (PA base + 0x14)
		AND R0, R0, R1	    // set bit 5
		STRH R0, [R4, #0x14] // put it back

		BX  LR

turnonLED4:
		MOV R1, #0x0001

		// read PA port register
		LDRH R0, [R4, #0x14] // get PA ODR (PA base + 0x14)
		ORR R0, R0, R1	    // set bit 0
		STRH R0, [R4, #0x14] // put it back

		BX  LR

turnoffLED4:
		MOV R1, #0x0001
		MVN R1, R1 //flip bits
		// read PA port register
		LDRH R0, [R4, #0x14] // get PA ODR (PA base + 0x14)
		AND R0, R0, R1	    // set bit 0
		STRH R0, [R4, #0x14] // put it back

		BX  LR
	.end
