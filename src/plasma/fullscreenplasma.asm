/**
 * Fullscreen plasma implementation 
 */

 output fullscreenplasma.o

STANDALONE equ 0
NB_FRAMES equ 50*3*12 + 25 ; 50*32

LOAD equ 0x1000
PLASMA_HEIGHT equ 35


CODE_INC_L   equ #2C
CODE_DEC_L   equ #2d
CODE_INC_H   equ #24
CODE_DEC_H   equ #25


 macro COLOR  
       ld bc, 0x7f00

 dup 16
       ld a,(hl)
       out (c),c
       out (c),a
       inc hl
       inc c
 edup
       defs 3+4+4+2
 endm

    org LOAD

 /**
  * Displaying code of the plasma
  * Read texture
  * Move in texture
  * Display texture 
  * Anything else
  */
 macro MACRO_PLASMA_LINE_BLOC
BLOC_POS=0
BLOC_POS=BLOC_POS+1
ADR_START=$
        ld e, (hl)  ; Read texture byte                            ;2
        ld d, e     ; Copy byte for displaying a word              ;1
        push de     ; Copy word on screen                          ;4
        
ADR_MOV_HOR=$
        nop       ; Move in texture                 ;1


ADR_END=$
    ;defs 96/4*5, 0
    ; => 432 nops

 endm

 /**
  * Select the screen to work on and the other to display
  */
 macro SELECT_SCREEN_TO_WORK nb
    ; Get the right things
    if nb == 0
SCREEN_ADRESS=0xc000+96
CRTC_ADRESS=0x3000 + 96/2
    else
SCREEN_ADRESS=0xc000+96+96
CRTC_ADRESS=0x3000
    endif
 
    ld sp, SCREEN_ADRESS
    ld de, CRTC_ADRESS
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), d 
    dec b : inc c
    out (c), c : inc b : out (c), e
 endm



/**
 * Move the texture
 *
 * HL' = last texture
 * BC' = last fixed point values
 * DE' = deltas
 *
 
 * TODO: need to patch the code when other rotation side
 */
 macro MOVE_TEXTURE_VERTICALLY
START_MOVE_TEXTURE_VERTICALLY=$
 exx
 ; Add values to curve
 ld a, (bc)
 add (hl)
 sra a 
 inc c
 inc c
 dec l
 exx
 ; Store first value of line
 ld l, a
 endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;

go

    call plasma_init

.main_loop
 ;; Main loop of the demo
    ld b, 0xf5
.vbl
    in a, (c)
    rra
    jr nc, .vbl
    
     ld hl, 0x0701 : ld b, 0xbc
     out (c), h : inc b : out (c), l
     di
effect_loop
  xor a
  ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a


;; Test if the effect is finished
.tempo_display 
    ld bc, NB_FRAMES
 if STANDALONE
    dw 0
 else
    dec bc
 endif
    ld (.tempo_display+1), bc
    ld a, b
    or c
    jp z, effect_end

  RST 0
  call manage_color_rotation
.selected_color  ld hl, TABCOLOR1
  COLOR
  defs 110-12


.texture_start
    ld hl, TEXTURE 
    exx
.curvey1
    ld hl, sintab1+128
.curvey2
    ld bc, sintab1
    inc c
    dec l
    dec l
    ld (.curvey2+1), bc
    ld (.curvey1+1), hl
    exx

    ;; Affiche plasma
    call PLASMA_LINE_BLOC

    call plasma_patch_code
    ld bc, 0xbc00+1 : xor a
    out (c), c : inc b : out (c), a


  ld a, 1
  ld bc, 0xbc00 + 4 : out (c), c : inc b : out (c), a
  ld bc, 0xbc00 + 9 : out (c), c : inc b : out (c), a

    ld b,16*4 -3
    djnz $
    jp effect_loop


/**
 * Leave effect
 */
effect_end
 ld hl, 0x0907
 ld b, 0xbc
 out (c), h: inc b: out (c), l : dec b
 ld hl, 0x0400+38
 out (c), h : inc b : out (c), l


  di:RST 0:ei
 ret


/**
 * Manage palette change
 */
manage_color_rotation
.timing
 ld bc, 1
 dec bc
 ld a, b
 or c
 jr nz, .notendtiming

 
.colorpos
 ld hl, COLOR_CHOICE
 ld c, (hl)
 inc hl
 ld b, (hl)
 ld (.timing+1), bc
 inc hl
 ld e, (hl)
 inc hl
 ld d, (hl)
 inc hl
 ld a, (hl)
 inc hl
 ld (.colorpos+1), hl
 ld (effect_loop.selected_color+1), de
 ld (effect_loop.curvey2+2), a
 ret 
 
; TODO Need to stabilize routine
.notendtiming
 defs 2+2+2+2+2+6+2+2+2+2+2+5+6+4-4, 0
 ld (.timing+1), bc
 ret



/**
 * Code de copie de texture
 */
copy_texture
 dup 96/2
    MACRO_PLASMA_LINE_BLOC
 edup
    jp (ix)

/**
 * Code for displaying a line in the plasma
 */
PLASMA_LINE_BLOC
    ld (backsp+1), sp
    ld a, PLASMA_HEIGHT/2
    ld (PLASMA_LINE_BLOC_COUNT+1), a
     SELECT_SCREEN_TO_WORK 0
PLASMA_LINE_BLOC_LOOP

;;; Code for the odd lines
first_half
    ld ix, first_half_end_copy
    jp copy_texture
first_half_end_copy
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture
    defs 96/2
    MOVE_TEXTURE_VERTICALLY
    defs 27 - 9 - (3+2+4+1+4) - 2
   ;ld bc, 0xbc00+1 : ld a, 96/2
   ; out (c), c : inc b : out (c), a

first_half_real_end



;;; Code for the even lines
second_half    
    ld ix, second_half_end_copy
    jp copy_texture
second_half_end_copy
    SELECT_SCREEN_TO_WORK 0
second_half_before_move_texture
    defs 96/2
    MOVE_TEXTURE_VERTICALLY
    defs 27  - (2+1+3+1+4+9) - 2
    ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a


second_half_real_end

PLASMA_LINE_BLOC_COUNT
    ld a, PLASMA_HEIGHT/2
    dec a
    ld (PLASMA_LINE_BLOC_COUNT+1), a
    or a
    jp nz, PLASMA_LINE_BLOC_LOOP


PLASMA_LINE_BLOC_END
backsp ld sp, 0
    ret


plasma_init 

    ld hl, 0xc9fb
    ld (0x38), hl


.init_display_code
    ld de, 0
    call plasma_patch_code

 ld bc, 0x7f8c : out (c), c


    ld b, 0xbc
    ld hl, 0x0100 + 96/2
    out (c), h : inc b : out (c), l : dec b
    ld hl, 12*256 + 0x30
    out (c), h : inc b : out (c), l : dec b
    ld hl, 13*256
    out (c), h : inc b : out (c), l : dec b
    ld hl, 0x0200+50
    out (c), h : inc b : out (c), l : dec b
    

    ret

/**
 * Generate a step of plasma.
 * Read the curves and patch the code to increment or decrement in the texture
 * Only one of the dimensions must move. Texture is 1d
 */
plasma_patch_code

;; Launch code modification
.modify_code
  ld hl, copy_texture + ADR_MOV_HOR - ADR_START
  ld bc, LOOKUP_DELTA_OPCODE 
  
  exx
.cx1
  ld hl, sintab1
.cx2
  ld de, sintab1+123
 dec e  
 inc l 
 inc l 
 ld (.cx1+1), hl
 ld (.cx2+1), de

  exx

 
  ld a, 0
  ld d, a
  ld e, a
 dup 96/2
   ; Bakup old

   exx
   ld a, (de)
   add (hl)
   sra a
   inc e
   dec l
   exx

   ld e, a
   sub d
   ld d, e
   ld c, a

   ld a, (bc)
   ld (hl), a
   dup 4
    inc hl
   edup
 edup

 ret

 include donneesEncre.asm

/*
COLOR  
       ld bc,&7f00
BOUCOLOR
       out (c),c
       ld a,(hl)
       or a
       ret z
       out (c),a
       inc hl
       inc c
       jp BOUCOLOR
*/

TABCOLOR00
	defs 16, 79
	db 0

TABCOLOR01
	defb 88
	defs 15, 79
	db 0

TABCOLOR02
	defb 88, 68
	defs 14, 79
	db 0

TABCOLOR03
	defb 88, 68, 85
	defs 13, 79
	db 0

TABCOLOR04
	defb 88, 68, 85, 87
	defs 12, 79
	db 0

TABCOLOR05
	defb 88, 68, 85, 87, 95
	defs 11, 79
	db 0

TABCOLOR06
	defb 88, 68, 85, 87, 95, 93
	defs 10, 79
	db 0

TABCOLOR07
	defb 88,68,85,87,95,93,95
	defs 9, 79
	db 0

TABCOLOR08
	defb 88,68,85,87,95,93,95,91
	defs 8, 79
	db 0

TABCOLOR09
	defb 88,68,85,87,95,93,95,91,67
	defs 7, 79
	db 0

TABCOLOR0A
	defb 88,68,85,87,95,93,95,91,67,71
	defs 6, 79
	db 0

TABCOLOR0B
	defb 88,68,85,87,95,93,95,91,67,71,78
	defs 5, 79
	db 0

TABCOLOR0C
	defb 88,68,85,87,95,93,95,91,67,71,78
	defb 77
	defs 4, 79
	db 0

TABCOLOR0D
	defb 88,68,85,87,95,93,95,91,67,71,78
	defb 77, 69
	defs 3, 79
	db 0

TABCOLOR0E
	defb 88,68,85,87,95,93,95,91,67,71,78
	defb 77, 69,92
	defs 2, 79
	db 0

TABCOLOR0F
	defb 88,68,85,87,95,93,95,91,67,71,78
	defb 77, 69,92, 77
	defs 1, 79
	db 0



TABCOLOR1
	defb 88,68,85,87,95,93,95,91,67,71,78
        defb 77,69,92,77,79
    	db 0

 if 0
TABCOLOR2
	defb 64,70,87,95,81,91,89,75,67,71,78
        defb 77,69,88,93,95
        db 0


;#3- BLUE-RED-BLACK-SECOND2222222
TABCOLOR3
	defb 95,93,68,85,93,87,95,91,75,67,71,78
	defb 77,69,92,88
        db 0
;#4- PURPLE-GREEN
TABCOLOR4
	defb 88,68,85,87,95,93,95,91,67,71,78
	defb 77,69,92,77,79
        db 0
;#5- EXPERIMENTAL-RAINBOW 
TABCOLOR5
	defb 64,71,67,69,92,86,82,91,81
	defb 70,68,88,77,79,75,79
        db 0
;#6- experimental2w
TABCOLOR6
	defb 86,82,91,81
	defb 70,68,93,95,83,88,77,79,75,79,88,92
        db 0
;#7- RED-BLUE-SEPERATE.
TABCOLOR7
	defb 88,69,77,79,67,71,69,76
	defb 88,87,95,91,75,91,95,93
        db 0
;#8- FIRE
TABCOLOR8
	defb 92,88,69,77,79,91,75,67,71,69
	defb 76,92,84,84,84,84,84
        db 0
;#9- BLUE-RED-BLACK-SECOND
TABCOLOR9
	defb 84,93,68,85,88,93,87,95,91,67,71,78
	defb 77,69,95,88
        db 0
;#10- PURPLE-GREEN-UNKNOWN
TABCOLOR10
	defb 64,94,86,82,89,74,67,75,67,71,78
	defb 77,69,88,93,95
        db 0
;#11- GREEN-BLUE.asm
TABCOLOR11
	defb 64,86,82,90,74,67,75,67,89
	defb 94,64,93,85,70,87,95
        db 0
;#12- sur-rupture1
TABCOLOR12
	defb 64,86,82,90,74,67,75,67,74,67
	defb 79,71,78,76,69,79
        db 0


COLOR_CHOICE
   dw 9 : dw TABCOLOR00 : db high sintab1
   dw 9 : dw TABCOLOR01 : db high sintab1
   dw 9 : dw TABCOLOR02 : db high sintab1
   dw 9 : dw TABCOLOR03 : db high sintab1
   dw 9 : dw TABCOLOR04 : db high sintab1
   dw 9 : dw TABCOLOR05 : db high sintab1
   dw 9 : dw TABCOLOR06 : db high sintab1
   dw 9 : dw TABCOLOR07 : db high sintab1
   dw 9 : dw TABCOLOR08 : db high sintab1
   dw 9 : dw TABCOLOR09 : db high sintab1
   dw 9 : dw TABCOLOR0A : db high sintab1
   dw 9 : dw TABCOLOR0B : db high sintab1
   dw 9 : dw TABCOLOR0C : db high sintab1
   dw 9 : dw TABCOLOR0D : db high sintab1
   dw 9 : dw TABCOLOR0E : db high sintab1
   dw 50*3 : dw TABCOLOR2 : db high sintab2
   dw 50*3 : dw TABCOLOR3: db high sintab1
   dw 50*3 : dw TABCOLOR4: db high sintab3
   dw 50*3 : dw TABCOLOR5: db high sintab1
   dw 50*3 : dw TABCOLOR6: db high sintab2
   dw 50*3 : dw TABCOLOR7: db high sintab4
   dw 50*3 : dw TABCOLOR8: db high sintab3
   dw 50*3 : dw TABCOLOR9: db high sintab4
   dw 50*3 : dw TABCOLOR10: db high sintab2
   dw 50*3 : dw TABCOLOR11: db high sintab4
   dw 50*3 : dw TABCOLOR12: db high sintab3
   dw 9 : dw TABCOLOR0E : db high sintab1
   dw 9 : dw TABCOLOR0D : db high sintab1
   dw 9 : dw TABCOLOR0C : db high sintab1
   dw 9 : dw TABCOLOR0B : db high sintab1
   dw 9 : dw TABCOLOR0A : db high sintab1
   dw 9 : dw TABCOLOR09 : db high sintab1
   dw 9 : dw TABCOLOR08 : db high sintab1
   dw 9 : dw TABCOLOR07 : db high sintab1
   dw 9 : dw TABCOLOR06 : db high sintab1
   dw 9 : dw TABCOLOR05 : db high sintab1
   dw 9 : dw TABCOLOR04 : db high sintab1
   dw 9 : dw TABCOLOR03 : db high sintab1
   dw 9 : dw TABCOLOR02 : db high sintab1
   dw 9 : dw TABCOLOR01 : db high sintab1
   dw 9 : dw TABCOLOR00 : db high sintab1
 db 0
 
 else

                                              
TABCOLORnew0	
		defb 95,93,68,85,93,87,95,91,75,67,71,78
		defb 77,69,92,88

TABCOLORnew1
		defb 86,82,91,81
		defb 70,68,93,95,83,88,77,79,75,79,88,92

TABCOLORnew2
		defb 64,70,87,95,81,91,89,75,67,71,78
		defb 77,69,88,93,95

TABCOLORnew3
		defb 64,71,67,69,92,86,82,91,81
		defb 70,68,88,77,79,75,79



COLOR_CHOICE
   dw 9 : dw TABCOLOR00 : db high sintab1
   dw 9 : dw TABCOLOR01 : db high sintab1
   dw 9 : dw TABCOLOR02 : db high sintab1
   dw 9 : dw TABCOLOR03 : db high sintab1
   dw 9 : dw TABCOLOR04 : db high sintab1
   dw 9 : dw TABCOLOR05 : db high sintab1
   dw 9 : dw TABCOLOR06 : db high sintab1
   dw 9 : dw TABCOLOR07 : db high sintab1
   dw 9 : dw TABCOLOR08 : db high sintab1
   dw 9 : dw TABCOLOR09 : db high sintab1
   dw 9 : dw TABCOLOR0A : db high sintab1
   dw 9 : dw TABCOLOR0B : db high sintab1
   dw 9 : dw TABCOLOR0C : db high sintab1
   dw 9 : dw TABCOLOR0D : db high sintab1
   dw 9 : dw TABCOLOR0E : db high sintab1
   dw 50*3 : dw TABCOLORnew0 : db high sintab2
   dw 50*3 : dw TABCOLORnew0: db high sintab1
   dw 50*3 : dw TABCOLORnew0: db high sintab3
   dw 50*3 : dw TABCOLORnew1: db high sintab1
   dw 50*3 : dw TABCOLORnew1: db high sintab2
   dw 50*3 : dw TABCOLORnew1: db high sintab4
   dw 50*3 : dw TABCOLORnew2: db high sintab3
   dw 50*3 : dw TABCOLORnew2: db high sintab4
   dw 50*3 : dw TABCOLORnew2: db high sintab2
   dw 50*3 : dw TABCOLORnew3: db high sintab4
   dw 50*3 : dw TABCOLORnew3: db high sintab3
   dw 9 : dw TABCOLOR0E : db high sintab1
   dw 9 : dw TABCOLOR0D : db high sintab1
   dw 9 : dw TABCOLOR0C : db high sintab1
   dw 9 : dw TABCOLOR0B : db high sintab1
   dw 9 : dw TABCOLOR0A : db high sintab1
   dw 9 : dw TABCOLOR09 : db high sintab1
   dw 9 : dw TABCOLOR08 : db high sintab1
   dw 9 : dw TABCOLOR07 : db high sintab1
   dw 9 : dw TABCOLOR06 : db high sintab1
   dw 9 : dw TABCOLOR05 : db high sintab1
   dw 9 : dw TABCOLOR04 : db high sintab1
   dw 9 : dw TABCOLOR03 : db high sintab1
   dw 9 : dw TABCOLOR02 : db high sintab1
   dw 9 : dw TABCOLOR01 : db high sintab1
   dw 9 : dw TABCOLOR00 : db high sintab1
 db 0


 endif

/**
 * Table des delta
 * pour chaque valuer fait nop, inc l ou dec l
 */
 align 256
LOOKUP_DELTA_OPCODE
  nop
 dup 126
  inc l
 edup
 dup 256-126
  dec l
 edup

/**
 * Courbes du plasma
 */
 align 256
plasma_curve
sintab1
	include plasma_curve1.asm
sintab2 equ sintab1 + 256
sintab3 equ sintab2 + 256
sintab4 equ sintab3 + 256

 /**
  * Texture is simply composed of bytes of one unique color
  */
 align 256
TEXTURE
 dup 3
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;0
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;1
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;2
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;3
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;4
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;5
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;6
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;7
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;8
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;9
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;10
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;11
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;12
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;13
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;14
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;15
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;14
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;13
 .4    db 1*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;12
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;11
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;10
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;9
 .4    db 1*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;8
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;7
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;6
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;5
 .4    db 0*OCTET_ENCRE8 + 1*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;4
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;3
 .4    db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 1*OCTET_ENCRE2 + 0*OCTET_ENCRE1 ;2
 .4   db 0*OCTET_ENCRE8 + 0*OCTET_ENCRE4 + 0*OCTET_ENCRE2 + 1*OCTET_ENCRE1 ;1
 edup
     
    assert $ < 0x4000


