	output greetings.o

/**
 * Pour le moment:
 * ecran fixe et changement d'encre
 *
 * Pour le futur:
 * ligne à ligne et courbe
 */
	org 0x1000


SCREEN_WIDTH = 96
EFFECT_HEIGHT = 100

	call greetings_init
	;call COLOR : jp $
	call greetings_effect
	jp $


greetings_effect
	call FRAMEWORK_WAIT_VBL

	halt : halt
	ld hl, 0xc9fb : ld (0x38), hl
	call FRAMEWORK_WAIT_VBL
 	ld hl, 0x0701 : ld b, 0xbc
     	out (c), h : inc b : out (c), l
     	di
greetings_effect_loop
	xor a
  	ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  	ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a

	di:RST 0:ei
	call greetings_manage_vertical_movement

	halt
	di
	defs 64
	defs 64
	defs 40
.colors_adress
	ld hl, MAGIC_COLORS
	dup EFFECT_HEIGHT/2
		call set_colors1a
		call set_colors1b
	edup

	ld b, 55
.tempo_crtc
	defs 64-5
	djnz .tempo_crtc

	ld a, 1
  	ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  	ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a


    ld b,16*4 -3
    djnz $

	jp greetings_effect_loop


/**
 * Manage vertical movement of greetings
 * TODO: read a curve
 */
greetings_manage_vertical_movement
	ld hl, (greetings_effect_loop.colors_adress+1)
	ld de, 8
	add hl, de
	ld (greetings_effect_loop.colors_adress+1), hl
	ret


greetings_vertical_curve
  include data/greetings/vertical_curve.asm

/**
 * Change colors from a table
 */

/*
	out (c), c	; select ink		4
	ld a, (hl)  ; read color		2
	out (c), a	; select color		4
	inc hl		; move in table		2
	inc c		; next color		1
                ;					=> 13
    out (c), c	; 4
	outi		; 5
	inc b		; 1
	inc c		; 1
				; => 11

*/


 
 /**
  * Change the color of the eight inks
  */
  
  macro MAGIC_RASTERS
  /**
   * Color gestion
   */
  dup 7
	out (c), c	; Select ink
	outi		; Read color, move in table, output color
	inc b		; Get back to 0x7f
	inc c		; Go to next ink
  edup

	out (c), c	; Select ink
	outi		; Read color, move in table, output color


  defs 31 - 3 - (3+4+1+4+1+1+4+1+4)

  ld bc, 0xbc00 + 12
  out (c), c
  inc b
  out (c), d
  dec b
  inc c
  out (c), c
  inc b
  out (c), e
  /**
   * Adress gestion
   */
  endm


set_colors1a
	ld bc, 0x7f00
	ld de, 0x3000
	MAGIC_RASTERS
	ret


set_colors1b
	ld bc, 0x7f08
	ld de, 0x3000 + 96/2
	MAGIC_RASTERS
	ret


C1=0x54
C2=0x4b
MAGIC_COLORS
 include image.asm
/**
 * Build screen
 */
greetings_init
    ld bc, 0x7f8c : out (c), c
	ld bc, 0xbc00+6: out (c), c : ld bc, 0xbd00+38 : out (c), c
	ld bc, 0xbc00+1 : out (c), c : ld bc, 0xbd00 + SCREEN_WIDTH/2 : out (c),c 

.build_line1a
	ld hl, 0xc000
	push hl
	ld a, PIXEL_ENCRE0_G + PIXEL_ENCRE1_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE2_G + PIXEL_ENCRE3_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE4_G + PIXEL_ENCRE5_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE6_G + PIXEL_ENCRE7_D  : ld (hl), a : inc hl
	ld de, hl
	inc de
	pop hl
	ld bc, 96-4
	ldir
	

.build_line1b
	ld hl, 0xc000 + 96/4
	push hl
	ld a, PIXEL_ENCRE8_G + PIXEL_ENCRE9_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE10_G + PIXEL_ENCRE11_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE12_G + PIXEL_ENCRE13_D  : ld (hl), a : inc hl
	ld a, PIXEL_ENCRE14_G + PIXEL_ENCRE15_D  : ld (hl), a : inc hl
	ld de, hl
	inc de
	pop hl
	ld bc, 96-4
	ldir
	
	 ret
bc26
        ld a,8
        add h
        ld h,a
        and 64
        ret nz
        ld bc,0x3fa0
        sbc hl,bc
        ret
COLOR
    ld bc, 0x7f00
    ld hl, COLOR_set
.loop
    ld a, (hl)
    or a
    ret z

    inc hl
    
    out (c), c
    out (c), a

    inc c
    jr .loop

COLOR_set
	defb 84,93,68,85,88,93,87,95,91,67,71,78
	defb 77,69,95,88
        db 0
		include donneesEncre_greetings.asm
FRAMEWORK_WAIT_VBL: equ 0x000001A6
