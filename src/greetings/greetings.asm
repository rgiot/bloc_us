	output greetings.o

/**
 * Pour le moment:
 * ecran fixe et changement d'encre
 *
 * Pour le futur:
 * ligne à ligne et courbe
 */
	org 0x1000


EFFECT_DURATION equ 50*25
SCREEN_WIDTH = 96
EFFECT_HEIGHT = 122

	call greetings_init
	call greetings_effect
	ret

greetings_effect
	call FRAMEWORK_WAIT_VBL
	ld bc, 0x7f10: out (c), c
	ld bc, 0x7f58: out (c), c

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

.tempo_end
	ld hl, EFFECT_DURATION
	dec hl
	ld (.tempo_end+1), hl
	ld a, h
	or l
	jp z, quit_effect

	RST 0

	ld bc, 0x7f58
	ld a, 8
.color_loop
	out (c), a
	out (c), c
	inc a
	cp 16
	jr nz, .color_loop

	ld hl, 0x3000+96/2
	ld bc, 0xbc00+12
	out (c), c : inc b : out (c), h
	dec b : inc c
	out (c),c : inc b : out (c), l

	call greetings_manage_vertical_movement
	defs 64
	defs 64
	defs 64
	defs EFFECT_HEIGHT

	defs 64
	defs 64
	defs 40
.colors_adress
	ld hl, MAGIC_COLORS

	ld bc, 0xbc00+1 : out (c), c : ld bc, 0xbd00 + SCREEN_WIDTH/2 : out (c),c 
patch_start_adress
CRTC_ADR=0x3000
BASE=0x000
	dup 8/2
		ld de, CRTC_ADR + BASE
		call set_colors1a
BASE=(BASE+96/2) & %1111111111
		ld de, CRTC_ADR + BASE
		call set_colors1b
BASE=(BASE+96/2) & %1111111111

	edup

	dup (EFFECT_HEIGHT-8)/2
		ld de, 0x3000
		call set_colors1a
		ld de, 0x3000 + 96/2
		call set_colors1b
	edup


	defs 64
	ld bc, 0xbc00+1 : out (c), c : ld bc, 0xbd00  : out (c),c 
	defs 64
	defs 45
	call test_patch_adress
/*
	ld b, 4
.tempo_crtc
	defs 64-5
	djnz .tempo_crtc
*/
	ld a, 1
  	ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  	ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a


    ld b,16*4 -3
    djnz $

	jp greetings_effect_loop



quit_effect
 ld hl, 0x0907
 ld b, 0xbc
 out (c), h: inc b: out (c), l : dec b
 ld hl, 0x0400+38
 out (c), h : inc b : out (c), l


  di:RST 0:ei
	ret

/**
 * Manage vertical movement of greetings
 * TODO: read a curve
 */
greetings_manage_vertical_movement
	ld a, 0
	inc a
	ld (greetings_manage_vertical_movement+1), a
	and 1
	jr  z, .novmt

	ld hl, (greetings_effect_loop.colors_adress+1)
	ld de, 8
	add hl, de
	ld (greetings_effect_loop.colors_adress+1), hl
	ret

.novmt
	defs 15
	ret

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


  defs 5

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
	MAGIC_RASTERS
	ret


set_colors1b
	ld bc, 0x7f08
	MAGIC_RASTERS
	ret


MAGIC_COLORS
 dup 120
  db 0x58, 0x58, 0x58, 0x58
  db 0x58, 0x58, 0x58, 0x58
 edup
 include data/greetings/greetings_image.asm
 dup 120
  db 0x58, 0x58, 0x58, 0x58
  db 0x58, 0x58, 0x58, 0x58
 edup

 macro BUILD_LINE adress, c1, c2, c3, c4, c5, c6, c7, c8
	ld hl, adress
	push hl
	ld a, c1 + c2  : ld (hl), a : inc hl
	ld a, c3 + c4  : ld (hl), a : inc hl
	ld a, c5 + c6  : ld (hl), a : inc hl
	ld a, c7 + c8  : ld (hl), a : inc hl
	ld de, hl
	pop hl
	ld bc, 96-4
	ldir
	


 endm

 align 256
greetings_horizontal_curve
  include data/greetings/horizontal_curve.asm
 ; include data/greetings/horizontal_curve.asm


/**
 * Build screen
 */
greetings_init
    ld bc, 0x7f8c : out (c), c
	ld bc, 0xbc00+6: out (c), c : ld bc, 0xbd00+38 : out (c), c

.build_line1a
	BUILD_LINE 0xc000+0*96, PIXEL_ENCRE0_G, PIXEL_ENCRE1_D, PIXEL_ENCRE2_G, PIXEL_ENCRE3_D, PIXEL_ENCRE4_G, PIXEL_ENCRE5_D, PIXEL_ENCRE6_G, PIXEL_ENCRE7_D 
.build_line1b
	BUILD_LINE 0xc000+1*96, PIXEL_ENCRE8_G, PIXEL_ENCRE9_D, PIXEL_ENCRE10_G, PIXEL_ENCRE11_D, PIXEL_ENCRE12_G, PIXEL_ENCRE13_D, PIXEL_ENCRE14_G, PIXEL_ENCRE15_D 

.build_line2a
	BUILD_LINE 0xc000+2*96, PIXEL_ENCRE1_G, PIXEL_ENCRE2_D, PIXEL_ENCRE3_G, PIXEL_ENCRE4_D, PIXEL_ENCRE5_G, PIXEL_ENCRE6_D, PIXEL_ENCRE7_G, PIXEL_ENCRE0_D
.build_line2b
	BUILD_LINE 0xc000+3*96, PIXEL_ENCRE9_G, PIXEL_ENCRE10_D, PIXEL_ENCRE11_G, PIXEL_ENCRE12_D, PIXEL_ENCRE13_G, PIXEL_ENCRE14_D, PIXEL_ENCRE15_G , PIXEL_ENCRE8_D

.build_line3a
	BUILD_LINE 0xc000+4*96, PIXEL_ENCRE2_G, PIXEL_ENCRE3_D, PIXEL_ENCRE4_G, PIXEL_ENCRE5_D, PIXEL_ENCRE6_G, PIXEL_ENCRE7_D, PIXEL_ENCRE0_G, PIXEL_ENCRE1_D
.build_line3b
	BUILD_LINE 0xc000+5*96, PIXEL_ENCRE10_G, PIXEL_ENCRE11_D, PIXEL_ENCRE12_G, PIXEL_ENCRE13_D, PIXEL_ENCRE14_G, PIXEL_ENCRE15_D , PIXEL_ENCRE8_G, PIXEL_ENCRE9_D


.build_line4a
	BUILD_LINE 0xc000+6*96, PIXEL_ENCRE3_G, PIXEL_ENCRE4_D, PIXEL_ENCRE5_G, PIXEL_ENCRE6_D, PIXEL_ENCRE7_G, PIXEL_ENCRE0_D, PIXEL_ENCRE1_G, PIXEL_ENCRE2_D
.build_line4b
	BUILD_LINE 0xc000+7*96, PIXEL_ENCRE11_G, PIXEL_ENCRE12_D, PIXEL_ENCRE13_G, PIXEL_ENCRE14_D, PIXEL_ENCRE15_G , PIXEL_ENCRE8_D, PIXEL_ENCRE9_G, PIXEL_ENCRE10_D

.build_line5a
	BUILD_LINE 0xc000+8*96, PIXEL_ENCRE4_G, PIXEL_ENCRE5_D, PIXEL_ENCRE6_G, PIXEL_ENCRE7_D, PIXEL_ENCRE0_G, PIXEL_ENCRE1_D, PIXEL_ENCRE2_G, PIXEL_ENCRE3_D
.build_line5b
	BUILD_LINE 0xc000+9*96, PIXEL_ENCRE12_G, PIXEL_ENCRE13_D, PIXEL_ENCRE14_G, PIXEL_ENCRE15_D , PIXEL_ENCRE8_G, PIXEL_ENCRE9_D, PIXEL_ENCRE10_G, PIXEL_ENCRE11_D


.build_line6a
	BUILD_LINE 0xc000+10*96, PIXEL_ENCRE5_G, PIXEL_ENCRE6_D, PIXEL_ENCRE7_G, PIXEL_ENCRE0_D, PIXEL_ENCRE1_G, PIXEL_ENCRE2_D, PIXEL_ENCRE3_G, PIXEL_ENCRE4_D
.build_line6b
	BUILD_LINE 0xc000+11*96, PIXEL_ENCRE13_G, PIXEL_ENCRE14_D, PIXEL_ENCRE15_G , PIXEL_ENCRE8_D, PIXEL_ENCRE9_G, PIXEL_ENCRE10_D, PIXEL_ENCRE11_G, PIXEL_ENCRE12_D

.build_line7a
	BUILD_LINE 0xc000+12*96, PIXEL_ENCRE6_G, PIXEL_ENCRE7_D, PIXEL_ENCRE0_G, PIXEL_ENCRE1_D, PIXEL_ENCRE2_G, PIXEL_ENCRE3_D, PIXEL_ENCRE4_G, PIXEL_ENCRE5_D
.build_line7b
	BUILD_LINE 0xc000+13*96, PIXEL_ENCRE14_G, PIXEL_ENCRE15_D , PIXEL_ENCRE8_G, PIXEL_ENCRE9_D, PIXEL_ENCRE10_G, PIXEL_ENCRE11_D, PIXEL_ENCRE12_G, PIXEL_ENCRE13_D

.build_line8a
	BUILD_LINE 0xc000+14*96, PIXEL_ENCRE7_G, PIXEL_ENCRE0_D, PIXEL_ENCRE1_G, PIXEL_ENCRE2_D, PIXEL_ENCRE3_G, PIXEL_ENCRE4_D, PIXEL_ENCRE5_G, PIXEL_ENCRE6_D
.build_line8b
	BUILD_LINE 0xc000+15*96, PIXEL_ENCRE15_G , PIXEL_ENCRE8_D, PIXEL_ENCRE9_G, PIXEL_ENCRE10_D, PIXEL_ENCRE11_G, PIXEL_ENCRE12_D, PIXEL_ENCRE13_G, PIXEL_ENCRE14_D


/*
	ld hl, 0xc000 + 96
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
*/	
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


test_patch_adress
	ld b, high CRTC_TABLE_ODD_LINES
	ld d, high CRTC_TABLE_EVEN_LINES

.curve	ld hl, greetings_horizontal_curve
	dec l 
	nop
	ld (.curve+1), hl

ADRESS= patch_start_adress+1
  dup EFFECT_HEIGHT/2
  ; ODD
	ld a, (hl) : inc l
	add a
	ld c, a

  	ld a, (bc)
	ld (ADRESS), a
ADRESS=ADRESS+1
	inc c
	ld a, (bc)
	ld (ADRESS), a
ADRESS=ADRESS+1

ADRESS=ADRESS+4

 ; EVEN
	ld a, (hl) : inc l
	add a
	ld e, a

  	ld a, (de)
	ld (ADRESS), a
ADRESS=ADRESS+1
	inc e
	ld a, (de)
	ld (ADRESS), a
ADRESS=ADRESS+1

ADRESS=ADRESS+4

  edup
	ret
	
	/**
	 * Correspondance tables
	 */

	 align 256
CRTC_TABLE_ODD_LINES
  dup 256/2/8
	dw 0x3000 + 0*96/2
	dw 0x3000 + 2*96/2
	dw 0x3000 + 4*96/2
	dw 0x3000 + 6*96/2
	dw 0x3000 + 8*96/2
	dw 0x3000 + 10*96/2
	dw 0x3000 + 12*96/2
	dw 0x3000 + 14*96/2
  edup
	align 256
CRTC_TABLE_EVEN_LINES
  dup 256/2/8
	dw 0x3000 + 1*96/2
	dw 0x3000 + 3*96/2
	dw 0x3000 + 5*96/2
	dw 0x3000 + 7*96/2
	dw 0x3000 + 9*96/2
	dw 0x3000 + 11*96/2
	dw 0x3000 + 13*96/2
	dw 0x3000 + 15*96/2
  edup



	assert $<0xc0000
FRAMEWORK_WAIT_VBL: equ 0x000001A6
