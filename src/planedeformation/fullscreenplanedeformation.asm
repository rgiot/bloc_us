/**
 * Fullscreen plane deformation implementation 
 */

 output fullscreenplane_deformation.o

STANDALONE equ 0
NB_FRAMES equ 50*3*12-2 ; 50*32

LOAD equ 0x1000
PLASMA_HEIGHT equ 35


CODE_INC_L   equ #2C
CODE_DEC_L   equ #2d
CODE_INC_H   equ #24
CODE_DEC_H   equ #25


 macro COLOR  
       ld bc, 0x7f00

 dup 17
       ld a,(hl)
       out (c),c
       out (c),a
       inc hl
       inc c
 edup
 endm

    org LOAD


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




;;;;;;;;;;;;;;;;;;;;;;;;;;;

go

    call plane_deformation_init

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
  defs 110


.texture_start
    ld hl, TEXTURE 


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
 * Code for displaying a line in the plane_deformation
 */
PLASMA_LINE_BLOC
    ld (backsp+1), sp
PLASMA_LINE_BLOC_LOOP

	call generated_pd

backsp ld sp, 0
    ret


plane_deformation_init 

    ld hl, 0xc9fb
    ld (0x38), hl


.init_display_code
    ld de, 0

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



generated_pd
    include generated_pd.asm


 include ../plasma/donneesEncre.asm


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
     
    assert $ < 0xc000


