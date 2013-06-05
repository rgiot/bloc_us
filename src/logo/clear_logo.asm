/**
 * Clear one block
 * Input HL = Adresse du logo a effacer
 */
clear_logo_bloc
	ld (hl), 0
	inc hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	dec hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	inc hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	dec hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	inc hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	dec hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	inc hl
	ld (hl), 0

	call bc26
	ld (hl), 0
	dec hl
	ld (hl), 0


	ret


clear_logo_table
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 1*96

	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 15*96

	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 20*96


	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 17*96

	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 9*96

	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 5*96

	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 11*96

	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 8*96

	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 14*96

	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 6*96

	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 13*96

	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 18*96

	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 4*96

	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 14*96

	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 8*96

	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 0*96

	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 9*96


	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 5*96

	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 19*96

	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 8*96

	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 11*96

	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 0*96

	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 12*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 16*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 13*96

	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 15*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 13*96

	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 2*96
	dw 0xc000 + DISPLAYED_LOGO_START + 2*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 14*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 11*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 19*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 14*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 18*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 13*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 10*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 4*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 11*2 + 0*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 10*2 + 6*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 8*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 8*2 + 16*96
	dw 0xc000 + DISPLAYED_LOGO_START + 15*2 + 17*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 9*96
	dw 0xc000 + DISPLAYED_LOGO_START + 5*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 3*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 1*2 + 7*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 12*96
	dw 0xc000 + DISPLAYED_LOGO_START + 6*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 7*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 3*96
	dw 0xc000 + DISPLAYED_LOGO_START + 13*2 + 5*96
	dw 0xc000 + DISPLAYED_LOGO_START + 0*2 + 20*96
	dw 0xc000 + DISPLAYED_LOGO_START + 4*2 + 1*96
	dw 0xc000 + DISPLAYED_LOGO_START + 9*2 + 15*96


	dw 0
